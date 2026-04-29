import os
import json
from docx import Document
import shutil

# 1. إعداد المسار الرئيسي
BASE_DIR = "assets/books"
if os.path.exists(BASE_DIR):
    shutil.rmtree(BASE_DIR)
os.makedirs(BASE_DIR)

# 2. تنسيق CSS
CSS_STYLE = """
<style>
    body { direction: rtl; font-family: 'Tahoma', sans-serif; padding: 10px; line-height: 1.8; }
    h1, h2 { color: #4c5dcd; text-align: center; margin-bottom: 20px; }
    h3 { color: #6a1b9a; border-right: 4px solid #6a1b9a; padding-right: 10px; margin-top: 30px; background: #f4f4f4; padding: 8px; }
    p { font-size: 18px; text-align: justify; margin-bottom: 15px; color: #333; }
</style>
"""


def text_to_html(text, is_heading=False):
    clean = text.strip()
    if not clean: return ""
    if is_heading:
        return f"<h3>{clean}</h3>"
    else:
        return f"<p>{clean}</p>"


def get_book_category(filename):
    name = filename.lower()
    if any(x in name for x in ["منهاج", "مسائل", "حدود", "ديات", "فقه"]):
        return "figh"
    elif any(x in name for x in ["عقائد", "شعائر"]):
        return "aqidah"
    elif "تاريخ" in name:
        return "history"
    elif "ناسكين" in name:
        return "hajj"
    return "general"


# قائمة الفهرس
books_index = []

# البحث عن الملفات
files = [f for f in os.listdir('.') if f.endswith('.docx') and not f.startswith('~$')]

print(f"🚀 بدء تحويل {len(files)} كتاب (بأسماء إنجليزية)...")

# عداد لتوليد أسماء إنجليزية فريدة
counter = 1

for fname in files:
    # الاسم العربي للعرض
    arabic_title = os.path.splitext(fname)[0]

    # الاسم الإنجليزي للمجلد (لحل مشكلة الخطأ)
    # سنسمي المجلدات book_1, book_2, ... لتجنب أي مشاكل
    folder_slug = f"book_{counter}"
    counter += 1

    print(f"📘 معالجة: {arabic_title} -> {folder_slug}...")

    book_dir = os.path.join(BASE_DIR, folder_slug)
    os.makedirs(book_dir)

    try:
        doc = Document(fname)
        chapters = []
        current_chapter_content = [CSS_STYLE]
        current_chapter_title = "المقدمة"

        split_keywords = ["كتاب ", "فصل ", "المقصد ", "المبحث ", "الباب ", "مسألة"]

        for para in doc.paragraphs:
            text = para.text.strip()
            if not text: continue

            is_new_chapter = False
            if any(text.startswith(k) for k in ["كتاب ", "المقصد ", "فصل :", "فصل في", "الباب"]):
                is_new_chapter = True

            if is_new_chapter and len(current_chapter_content) > 5:
                chap_filename = f"ch_{len(chapters)}.html"
                with open(os.path.join(book_dir, chap_filename), "w", encoding="utf-8") as f:
                    f.write("\n".join(current_chapter_content))

                chapters.append({"title": current_chapter_title, "file": chap_filename})

                current_chapter_title = text
                current_chapter_content = [CSS_STYLE, f"<h2>{text}</h2>"]
            else:
                is_heading = (len(text.split()) < 7) or any(text.startswith(k) for k in split_keywords)
                current_chapter_content.append(text_to_html(text, is_heading))

        if current_chapter_content:
            chap_filename = f"ch_{len(chapters)}.html"
            with open(os.path.join(book_dir, chap_filename), "w", encoding="utf-8") as f:
                f.write("\n".join(current_chapter_content))
            chapters.append({"title": current_chapter_title, "file": chap_filename})

        # حفظ المانيفت
        manifest = {
            "id": folder_slug,
            "title": arabic_title,  # هنا نحفظ الاسم العربي
            "category": get_book_category(fname),
            "chapters": chapters
        }

        with open(os.path.join(book_dir, "manifest.json"), "w", encoding="utf-8") as f:
            json.dump(manifest, f, ensure_ascii=False, indent=2)

        books_index.append({
            "id": folder_slug,
            "title": arabic_title,
            "category": manifest['category'],
            "path": f"assets/books/{folder_slug}/manifest.json"
        })

    except Exception as e:
        print(f"❌ خطأ في {fname}: {e}")

# حفظ الفهرس العام
with open(os.path.join(BASE_DIR, "index.json"), "w", encoding="utf-8") as f:
    json.dump(books_index, f, ensure_ascii=False, indent=2)

print("✅ تم الانتهاء! المجلدات الآن بأسماء إنجليزية آمنة.")