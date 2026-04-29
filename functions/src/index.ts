import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue, Timestamp } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import {
  onDocumentCreated,
} from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions";

initializeApp();
const db = getFirestore();
const fcm = getMessaging();

const REGION = "us-central1";

/**
 * عند إنشاء مستند سؤال منشور، أرسل إشعار FCM للمستخدم المعنيّ.
 * النشر نفسه يتم بشكل ذرّي من تطبيق الإدارة (batch)؛
 * هذه الدالة مسؤولة فقط عن جانب الإشعار.
 */
export const onQuestionCreated = onDocumentCreated(
  { document: "questions/{qId}", region: REGION },
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const {
      uid,
      question,
      status,
      topicId,
      subtopicId,
      inboxId,
      createdBy,
    } = data;

    // فقط للأسئلة المنشورة من قبل المشرف لمستخدم معروف
    if (status !== "published") return;
    if (createdBy !== "admin") return;
    if (!uid || !question) return;

    const userSnap = await db.collection("users").doc(uid).get();
    const token: string | undefined = userSnap.data()?.fcmToken;
    if (!token) {
      logger.info("no fcm token for user; skipping", { uid });
      return;
    }

    try {
      await fcm.send({
        token,
        notification: {
          title: "تم الرد على استفتائك",
          body:
            question.length > 80 ? question.substring(0, 80) + "…" : question,
        },
        data: {
          type: "answer_published",
          questionId: event.params.qId,
          inboxId: inboxId ?? "",
          topicId: String(topicId ?? ""),
          subtopicId: String(subtopicId ?? ""),
        },
        android: {
          priority: "high",
          notification: { channelId: "sanad_answers", sound: "default" },
        },
        apns: {
          payload: { aps: { sound: "default", badge: 1 } },
        },
      });
    } catch (err) {
      logger.error("FCM send failed", { uid, err });
    }
  }
);

/**
 * تأمين حقل createdAt على inbox الواردة (مفيد لو المرسل نسيه).
 */
export const onInboxCreated = onDocumentCreated(
  { document: "inbox/{inboxId}", region: REGION },
  async (event) => {
    const data = event.data?.data();
    if (!data) return;
    if (data.createdAt instanceof Timestamp) return;
    await event.data?.ref.update({ createdAt: FieldValue.serverTimestamp() });
  }
);
