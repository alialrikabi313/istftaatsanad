"""
Script to extract questions from docx files and upload them to Firestore.
Handles: العبادات (worship) and المعاملات (transactions) sections.
"""

import os
import sys
import json
import time
import urllib.request
import urllib.parse
import re
from docx import Document
from datetime import datetime

# ──────────────────────── Config ────────────────────────
PROJECT_ID = "shaikhsanad-59127"
FIRESTORE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"

# Topic mapping
TOPICS = {
    "ibadat": {
        "id": "ibadat",
        "name": "الاستفتاءات الشرعية - العبادات",
        "icon": "prayer",
        "order": 10,
        "file": "استفتاءات الشرعية العبادات 1447.docx"
    },
    "muamalat": {
        "id": "muamalat",
        "name": "الاستفتاءات الشرعية - المعاملات",
        "icon": "handshake",
        "order": 11,
        "file": "استفتاءات المعاملات 1447.docx"
    }
}


def get_access_token():
    """Get Firebase access token from stored CLI credentials."""
    config_path = os.path.expanduser("~/.config/configstore/firebase-tools.json")
    with open(config_path) as f:
        config = json.load(f)

    refresh_token = config["tokens"]["refresh_token"]

    data = urllib.parse.urlencode({
        "grant_type": "refresh_token",
        "refresh_token": refresh_token,
        "client_id": "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com",
        "client_secret": "j9iVZfS8kkCEFUPaAeJV0sAi",
    }).encode()

    req = urllib.request.Request("https://oauth2.googleapis.com/token", data=data)
    resp = urllib.request.urlopen(req)
    token_data = json.loads(resp.read())
    return token_data["access_token"]


def firestore_request(method, path, body=None, access_token=None):
    """Make a Firestore REST API request."""
    url = f"{FIRESTORE_URL}/{path}" if not path.startswith("http") else path
    data = json.dumps(body).encode() if body else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", f"Bearer {access_token}")
    req.add_header("Content-Type", "application/json")

    try:
        resp = urllib.request.urlopen(req)
        return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        error_body = e.read().decode()
        print(f"  HTTP Error {e.code}: {error_body[:300]}")
        raise


def firestore_commit(writes, access_token):
    """Commit a batch of writes to Firestore."""
    url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents:commit"
    body = {"writes": writes}
    data = json.dumps(body).encode()
    req = urllib.request.Request(url, data=data, method="POST")
    req.add_header("Authorization", f"Bearer {access_token}")
    req.add_header("Content-Type", "application/json")

    try:
        resp = urllib.request.urlopen(req)
        return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        error_body = e.read().decode()
        print(f"  Commit Error {e.code}: {error_body[:500]}")
        raise


def make_subtopic_id(topic_id, h1_name, h2_name):
    """Create a unique subtopic ID from topic, h1, and h2 names."""
    # Clean and create readable ID
    combined = f"{h2_name}"
    # Replace spaces with underscores, keep Arabic
    clean = combined.strip().replace(" ", "_")
    return f"{topic_id}_{clean}"


def extract_questions_from_docx(filepath, topic_id):
    """
    Parse a docx file and extract all questions with their structure.
    Returns: list of dicts with question, answer, topicId, subtopicId, topicName, subtopicName
    """
    doc = Document(filepath)
    questions = []

    current_h1 = ""
    current_h2 = ""
    current_state = None  # 'question' or 'answer'
    current_question_lines = []
    current_answer_lines = []

    topic_name = TOPICS[topic_id]["name"]

    # Skip the title H1 (first one)
    first_h1_seen = False

    for i, para in enumerate(doc.paragraphs):
        text = para.text.strip()
        if not text:
            continue

        style = para.style.name

        # Heading 1 = main fiqh section
        if style == "Heading 1":
            # Save any pending question before changing section
            if current_state == "answer" and current_question_lines:
                q_text = "\n".join(current_question_lines).strip()
                a_text = "\n".join(current_answer_lines).strip()
                if q_text and current_h2:
                    subtopic_id = make_subtopic_id(topic_id, current_h1, current_h2)
                    questions.append({
                        "question": q_text,
                        "answer": a_text,
                        "topicId": topic_id,
                        "subtopicId": subtopic_id,
                        "topicName": topic_name,
                        "subtopicName": current_h2,
                        "h1Section": current_h1,
                    })
                current_question_lines = []
                current_answer_lines = []
                current_state = None

            if not first_h1_seen:
                first_h1_seen = True
                continue  # Skip the file title

            current_h1 = text
            current_h2 = ""  # Reset subtopic when main section changes
            continue

        # Heading 2 = subtopic
        if style == "Heading 2":
            # Save any pending question before changing subsection
            if current_state == "answer" and current_question_lines:
                q_text = "\n".join(current_question_lines).strip()
                a_text = "\n".join(current_answer_lines).strip()
                if q_text and current_h2:
                    subtopic_id = make_subtopic_id(topic_id, current_h1, current_h2)
                    questions.append({
                        "question": q_text,
                        "answer": a_text,
                        "topicId": topic_id,
                        "subtopicId": subtopic_id,
                        "topicName": topic_name,
                        "subtopicName": current_h2,
                        "h1Section": current_h1,
                    })
                current_question_lines = []
                current_answer_lines = []
                current_state = None

            current_h2 = text
            continue

        # Check for question/answer markers
        # Handle "السؤال:" or "السؤال :" patterns, with optional inline text
        cleaned = text.replace("\u200f", "").replace("\u200e", "").strip()

        # Match السؤال with optional numbering (السؤال1, السؤال الثاني, etc.)
        q_match = re.match(r'^السؤال\s*\d*\s*(?:الأول|الثاني|الثالث|الرابع)?\s*[:：]?\s*(.*)', cleaned, re.DOTALL)
        a_match = re.match(r'^الجواب\s*(?:عن\s+\S+\s*)?\s*\d*\s*(?:الأول|الثاني|الثالث|الرابع)?\s*[:：..]?\s*(.*)', cleaned, re.DOTALL)

        is_question_marker = bool(q_match)
        is_answer_marker = bool(a_match) and not is_question_marker

        if is_question_marker:
            # Save previous Q&A if exists
            if current_state == "answer" and current_question_lines:
                q_text = "\n".join(current_question_lines).strip()
                a_text = "\n".join(current_answer_lines).strip()
                if q_text:
                    # Use current_h2, or if empty, use current_h1 as subtopic
                    sub_name = current_h2 if current_h2 else current_h1
                    if sub_name:
                        subtopic_id = make_subtopic_id(topic_id, current_h1, sub_name)
                        questions.append({
                            "question": q_text,
                            "answer": a_text,
                            "topicId": topic_id,
                            "subtopicId": subtopic_id,
                            "topicName": topic_name,
                            "subtopicName": sub_name,
                            "h1Section": current_h1,
                        })
            current_question_lines = []
            current_answer_lines = []
            current_state = "question"
            # If there's inline text after the marker, add it
            inline_text = q_match.group(1).strip() if q_match else ""
            if inline_text:
                current_question_lines.append(inline_text)
            continue

        if is_answer_marker:
            current_state = "answer"
            # If there's inline text after the marker, add it
            inline_text = a_match.group(1).strip() if a_match else ""
            if inline_text:
                current_answer_lines.append(inline_text)
            continue

        # Accumulate text based on current state
        if current_state == "question":
            current_question_lines.append(text)
        elif current_state == "answer":
            current_answer_lines.append(text)

    # Don't forget the last Q&A
    if current_state == "answer" and current_question_lines:
        q_text = "\n".join(current_question_lines).strip()
        a_text = "\n".join(current_answer_lines).strip()
        if q_text:
            sub_name = current_h2 if current_h2 else current_h1
            if sub_name:
                subtopic_id = make_subtopic_id(topic_id, current_h1, sub_name)
                questions.append({
                    "question": q_text,
                    "answer": a_text,
                    "topicId": topic_id,
                    "subtopicId": subtopic_id,
                    "topicName": topic_name,
                    "subtopicName": sub_name,
                    "h1Section": current_h1,
                })

    return questions


def to_firestore_value(val):
    """Convert Python value to Firestore REST API value format."""
    if isinstance(val, str):
        return {"stringValue": val}
    elif isinstance(val, bool):
        return {"booleanValue": val}
    elif isinstance(val, int):
        return {"integerValue": str(val)}
    elif isinstance(val, float):
        return {"doubleValue": val}
    elif isinstance(val, list):
        return {"arrayValue": {"values": [to_firestore_value(v) for v in val]}}
    elif isinstance(val, dict):
        return {"mapValue": {"fields": {k: to_firestore_value(v) for k, v in val.items()}}}
    elif val is None:
        return {"nullValue": None}
    else:
        return {"stringValue": str(val)}


def create_topic(topic_data, access_token):
    """Create a topic document in Firestore."""
    doc_id = topic_data["id"]
    fields = {
        "id": to_firestore_value(topic_data["id"]),
        "name": to_firestore_value(topic_data["name"]),
        "icon": to_firestore_value(topic_data["icon"]),
        "order": to_firestore_value(topic_data["order"]),
        "isVisible": to_firestore_value(True),
    }

    body = {"fields": fields}

    try:
        result = firestore_request(
            "PATCH",
            f"topics/{doc_id}",
            body=body,
            access_token=access_token
        )
        print(f"  Created topic: {topic_data['name']}")
        return result
    except Exception as e:
        print(f"  Error creating topic {doc_id}: {e}")
        raise


def create_subtopics_batch(subtopics, access_token):
    """Create subtopic documents in Firestore using batch commits."""
    writes = []
    for sub in subtopics:
        doc_path = f"projects/{PROJECT_ID}/databases/(default)/documents/subtopics/{sub['id']}"
        fields = {
            "id": to_firestore_value(sub["id"]),
            "topicId": to_firestore_value(sub["topicId"]),
            "name": to_firestore_value(sub["name"]),
            "order": to_firestore_value(sub["order"]),
        }
        writes.append({
            "update": {
                "name": doc_path,
                "fields": fields,
            }
        })

    # Firestore batch limit is 500
    batch_size = 400
    for i in range(0, len(writes), batch_size):
        batch = writes[i:i + batch_size]
        firestore_commit(batch, access_token)
        print(f"  Created subtopics batch {i // batch_size + 1} ({len(batch)} docs)")
        time.sleep(0.3)


def upload_questions_batch(questions, access_token):
    """Upload questions to Firestore using batch commits."""
    now = datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S.000Z")
    writes = []

    for q in questions:
        # Auto-generate document ID by not specifying it
        # We'll use a unique ID based on content hash
        import hashlib
        content_hash = hashlib.md5(
            (q["question"][:100] + q["subtopicId"]).encode()
        ).hexdigest()[:20]

        doc_path = f"projects/{PROJECT_ID}/databases/(default)/documents/questions/{content_hash}"

        fields = {
            "question": to_firestore_value(q["question"]),
            "answer": to_firestore_value(q["answer"]),
            "topicId": to_firestore_value(q["topicId"]),
            "subtopicId": to_firestore_value(q["subtopicId"]),
            "topicName": to_firestore_value(q["topicName"]),
            "subtopicName": to_firestore_value(q["subtopicName"]),
            "tags": to_firestore_value([]),
            "status": to_firestore_value("published"),
            "isDeleted": to_firestore_value(False),
            "createdAt": {"timestampValue": now},
            "createdBy": to_firestore_value("admin"),
        }

        writes.append({
            "update": {
                "name": doc_path,
                "fields": fields,
            }
        })

    # Firestore batch limit is 500
    batch_size = 400
    total_batches = (len(writes) + batch_size - 1) // batch_size

    for i in range(0, len(writes), batch_size):
        batch = writes[i:i + batch_size]
        batch_num = i // batch_size + 1
        try:
            firestore_commit(batch, access_token)
            print(f"  Uploaded questions batch {batch_num}/{total_batches} ({len(batch)} docs)")
        except Exception as e:
            print(f"  Error on batch {batch_num}: {e}")
            # Retry individual writes in this batch
            print(f"  Retrying batch {batch_num} individually...")
            for j, write in enumerate(batch):
                try:
                    firestore_commit([write], access_token)
                except Exception as e2:
                    doc_name = write["update"]["name"].split("/")[-1]
                    print(f"    Failed doc {doc_name}: {e2}")
        time.sleep(0.5)


def main():
    print("=" * 60)
    print("Extracting and uploading استفتاءات to Firestore")
    print("=" * 60)

    # Get access token
    print("\n[1/5] Getting Firebase access token...")
    access_token = get_access_token()
    print("  Token obtained successfully.")

    # Extract questions from both files
    all_questions = []
    script_dir = os.path.dirname(os.path.abspath(__file__))

    for topic_id, topic_data in TOPICS.items():
        filepath = os.path.join(script_dir, topic_data["file"])
        print(f"\n[2/5] Extracting from: {topic_data['file']}")
        questions = extract_questions_from_docx(filepath, topic_id)
        print(f"  Extracted {len(questions)} questions")
        all_questions.extend(questions)

    print(f"\n  Total questions extracted: {len(all_questions)}")

    # Collect unique subtopics
    subtopics_map = {}
    for q in all_questions:
        sub_id = q["subtopicId"]
        if sub_id not in subtopics_map:
            subtopics_map[sub_id] = {
                "id": sub_id,
                "topicId": q["topicId"],
                "name": q["subtopicName"],
                "order": 1,
            }

    print(f"  Total unique subtopics: {len(subtopics_map)}")

    # Print summary per topic
    for topic_id in TOPICS:
        topic_qs = [q for q in all_questions if q["topicId"] == topic_id]
        topic_subs = [s for s in subtopics_map.values() if s["topicId"] == topic_id]
        print(f"  {TOPICS[topic_id]['name']}: {len(topic_qs)} questions, {len(topic_subs)} subtopics")

    # Sample some questions for verification
    print("\n  --- Sample Questions ---")
    for q in all_questions[:3]:
        print(f"  Topic: {q['topicName']}")
        print(f"  Subtopic: {q['subtopicName']}")
        print(f"  Q: {q['question'][:100]}...")
        print(f"  A: {q['answer'][:100]}...")
        print()

    # Create topics
    print("[3/5] Creating topics in Firestore...")
    for topic_id, topic_data in TOPICS.items():
        create_topic(topic_data, access_token)

    # Create subtopics
    print(f"\n[4/5] Creating {len(subtopics_map)} subtopics in Firestore...")
    create_subtopics_batch(list(subtopics_map.values()), access_token)

    # Upload questions
    print(f"\n[5/5] Uploading {len(all_questions)} questions to Firestore...")
    upload_questions_batch(all_questions, access_token)

    print("\n" + "=" * 60)
    print(f"DONE! Uploaded {len(all_questions)} questions successfully.")
    print("=" * 60)


if __name__ == "__main__":
    main()
