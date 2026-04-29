# 📊 بنية قاعدة بيانات Firebase Firestore

---

## 1️⃣ `topics` - الأقسام الرئيسية

```
📁 topics/{documentId}
```

| الحقل | النوع |
|-------|-------|
| `name` | `String` |
| `icon` | `String` |
| `order` | `int` |
| `isVisible` | `bool` |

---

## 2️⃣ `subtopics` - الأقسام الفرعية

```
📁 subtopics/{documentId}
```

| الحقل | النوع |
|-------|-------|
| `topicId` | `String` |
| `name` | `String` |
| `order` | `int` |

---

## 3️⃣ `questions` - الأسئلة والأجوبة

```
📁 questions/{documentId}
```

| الحقل | النوع |
|-------|-------|
| `question` | `String` |
| `answer` | `String` |
| `topicId` | `String` |
| `subtopicId` | `String` |
| `topicName` | `String` |
| `subtopicName` | `String` |
| `createdAt` | `Timestamp` |
| `userId` | `String?` |
| `tags` | `List<String>` |

---

## 4️⃣ `questions_search` - فهرس البحث

```
📁 questions_search/{documentId}
```

| الحقل | النوع |
|-------|-------|
| `q_prefix` | `String` |
| `topicId` | `String` |
| `subtopicId` | `String` |

---

## 5️⃣ `users` - المستخدمون

```
📁 users/{uid}
   └── 📁 favorites/{qaId}
```

### حقول `users`:

| الحقل | النوع |
|-------|-------|
| `email` | `String` |
| `displayName` | `String` |
| `createdAt` | `Timestamp` |

### حقول `favorites`:

| الحقل | النوع |
|-------|-------|
| `at` | `Timestamp` |

---

## 6️⃣ `auth_codes` - رموز التحقق

```
📁 auth_codes/{email}
```

| الحقل | النوع |
|-------|-------|
| `code` | `String` |
| `name` | `String` |
| `expiresAt` | `Timestamp` |

---

## 7️⃣ `inbox` - صندوق الأسئلة الواردة

```
📁 inbox/{documentId}
```

| الحقل | النوع |
|-------|-------|
| `uid` | `String` |
| `email` | `String` |
| `name` | `String` |
| `text` | `String` |
| `sentAt` | `Timestamp` |
| `status` | `String` (`new` / `reviewed`) |
| `answer` | `String?` |

---

## 🔄 العلاقات

```
topics ──► subtopics ──► questions
                              │
users ◄───────────────────────┘
  │
  └── favorites (subcollection)
  
inbox ◄── users
```
