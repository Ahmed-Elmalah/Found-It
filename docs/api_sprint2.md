# FOUND IT: Sprint 2 API (Backend Contract)

Everything the app can call for Sprint 2: matches, chat, recovery, notifications,
and ownership verification questions (Story #6).

> **Owner: Ahmed.** Backend = Ahmed only. Don't create tables, functions or policies,
> and don't edit `supabase/sql/`. Need a field or a function? Ask Ahmed.
>
> Until a function is live on Supabase, build your feature against a **fake repository**
> that returns the JSON shapes below, then switch to the real data source.

Sprint 1 functions (feeds, my reports, profile, areas...) are still in
[`database.md`](database.md). This file only adds what is new or changed.

---

## Contents

1. [Statuses and lifecycle](#1-statuses-and-lifecycle)
2. [Errors](#2-errors)
3. [Shared JSON shapes](#3-shared-json-shapes)
4. [Story #1: Report Details (Adham)](#4-story-1-report-details-adham)
5. [Story #2: Potential Matches (Ziad)](#5-story-2-potential-matches-ziad)
6. [Story #3: Chat (Youssef)](#6-story-3-chat-youssef)
7. [Story #4: Recovery (Ziad)](#7-story-4-recovery-ziad)
8. [Story #5: Notifications and push (Mohamed)](#8-story-5-notifications-and-push-mohamed)
9. [Who uses what](#9-who-uses-what)
10. [Story #6: Ownership verification questions](#10-story-6-ownership-verification-questions)

---

## 1. Statuses and lifecycle

### Match `status`

```
potential --(first chat message)--> chatting --(finder confirms)--> verified --(Mark as Recovered)--> recovered
    any of potential / chatting / verified --(Dismiss / Not my item / Reject / report deleted)--> rejected
```

| Value | Meaning | Open? |
|---|---|---|
| `potential` | Suggested, nobody acted yet | ✅ |
| `chatting` | At least one message was sent | ✅ |
| `verified` | Finder confirmed ownership (`ownership_verified = true`) | ✅ |
| `recovered` | Item handed over. Final | ❌ |
| `rejected` | Closed by a user (or the report was deleted). Final | ❌ |

Closed matches (`recovered`, `rejected`): the chat becomes read-only. The database
refuses new messages.

### Report `status` (automatic, you never set it)

| Value | When |
|---|---|
| `active` | No open match |
| `matching` | Has at least one open match |
| `recovered` | Its match was marked recovered. Final |

- **Home / Explore** show `active` + `matching`.
- `recovered` reports only appear in **My Reports → Recovered** (user history).

### Who can do what

| Action | Who |
|---|---|
| Confirm ownership | **Finder only** (owner of the Found side, `i_am_finder = true`), and only when status = `chatting` |
| Reject / Dismiss | Either user, while the match is open |
| Mark as recovered | Either user, only when status = `verified` |
| See phone / email | Nobody, except on the Handover screen after verification (`get_match_contact`) |
| See `private_details` | The report owner only |
| Add verification questions | The owner of a **Found** report (Story #6) |
| Answer verification questions | The **lost-side** user of the match, once, while `claim_status = pending` |
| Send messages / photos | Both users, but only when `claim_status` is `not_required` or `passed` |

### Match engine (automatic)

When a report is created, the database looks for reports that are:

- the **opposite type** (lost ↔ found),
- the **same category** and **same city**,
- with an **item date within 3 days**,
- from **another user**, still `active` or `matching`, and not deleted.

Every hit becomes a `potential` match, and both users get a `potential_match` notification.

Story #6 exceptions:

- A user who failed the questions of a Found report is **never matched with it again**.
- When the Found report has questions, the match starts with `claim_status = pending` and
  the **finder is not notified** yet. He gets `claim_passed` when the owner answers correctly.

**Similarity score:**

```
50 + 30 (same area) + 20 - 5 × days apart  ->  55..100
```

Example: same area, 1 day apart = **95%**.

---

## 2. Errors

Every function throws a `PostgrestException`. Map its `code` to your feature's Failure enum:

| `code` | Meaning | Example | Suggested failure |
|---|---|---|---|
| `P0002` | Not found (or not yours) | Wrong report / match id, deleted report | `notFound` |
| `42501` | Not allowed | Lost user taps Confirm ownership, claiming your own report | `notAllowed` |
| `55000` | Wrong state | Match already closed, ownership not verified yet | `invalidState` |
| `22023` | Invalid input (Story #6) | Bad verification questions, answers missing | `invalidInput` |
| other / `SocketException` | Network / unknown | | `network` / `unknown` |

```dart
try {
  await supabase.rpc('confirm_ownership', params: {'p_match_id': matchId});
} on PostgrestException catch (e) {
  throw switch (e.code) {
    'P0002' => const ChatFailure(ChatFailureType.notFound),
    '42501' => const ChatFailure(ChatFailureType.notAllowed),
    '55000' => const ChatFailure(ChatFailureType.invalidState),
    _       => const ChatFailure(ChatFailureType.unknown),
  };
}
```

Never show `e.message` to the user. Always show a translated text.

---

## 3. Shared JSON shapes

### `ReportSummary`

A report inside a match or chat answer. It can be **`null`** for a manual match where
one user has no report.

```json
{
  "id": "uuid",
  "ref_code": "RPT-1004",
  "type": "found",
  "title": "Brown wallet",
  "description": "Found near the metro",
  "image": "https://.../report-images/<user>/1.jpg",
  "images": ["https://...1.jpg", "https://...2.jpg"],
  "category_name_en": "Wallets",  "category_name_ar": "محافظ",
  "city_name_en": "Cairo",        "city_name_ar": "القاهرة",
  "area_name_en": "Maadi",        "area_name_ar": "المعادي",
  "item_date": "2026-11-06",
  "status": "matching",
  "is_deleted": false
}
```

### `Match`

Always seen from **your** side: `my_report` is yours, `other_report` belongs to the other person.

```json
{
  "match_id": "uuid",
  "status": "potential",
  "similarity": 86,
  "source": "auto",
  "ownership_verified": false,
  "i_am_finder": false,
  "created_at": "2026-11-20T10:12:00Z",
  "last_message_at": null,
  "my_report": { ReportSummary } | null,
  "other_report": { ReportSummary } | null,
  "other_user_name": "Mona K.",
  "claim_status": "pending",
  "i_must_answer": true,
  "questions_count": 2
}
```

- `source`: `auto` = found by the engine, `manual` = someone tapped "This is Mine" / "I Found This".
- `similarity` is `0` for manual matches. Hide the % when `source = manual`.
- `claim_status`, `i_must_answer`, `questions_count`: Story #6, see [section 10](#10-story-6-ownership-verification-questions).

---

## 4. Story #1: Report Details (Adham)

### `get_report_details(p_report_id)`

One report for the details screen.

```dart
final json = await supabase.rpc('get_report_details', params: {
  'p_report_id': reportId,
}) as Map<String, dynamic>;
```

Returns the same fields as the `report_details` view (see `database.md`), **plus**:

```json
{
  "...all report_details fields...": "",
  "is_mine": false,
  "owner_name": "Omar S.",
  "has_private_details": true,
  "private_details": null,
  "my_match_id": null,
  "my_match_status": null,
  "has_questions": true,
  "questions_count": 2,
  "questions": null,
  "i_am_blocked": false
}
```

| Field | Use |
|---|---|
| `is_mine` | `true` → owner view (Edit, Mark as Recovered, Potential Matches). `false` → "This is Mine" / "I Found This" button |
| `private_details` | Text for the owner. **Always `null` for others** |
| `has_private_details` | For others: if `true`, show the masked row "🔒 Private details hidden" |
| `my_match_id` / `my_match_status` | You (not the owner) already have a match on this report → show "Open chat" instead of "This is Mine", and open `/chat/:my_match_id` |
| `has_questions` / `questions_count` | Story #6. For others: show "🔐 Verification required ({count} questions)" |
| `questions` | Story #6. The owner's questions with the answers (to show them and pre-fill Edit). **Always `null` for others** |
| `i_am_blocked` | Story #6. `true` → you failed the questions: hide "This is Mine" and show "You can't claim this item" |

- Never shows phone / email.
- Errors: `P0002` when the report doesn't exist or was deleted by someone else.

### `create_report` / `update_report`: new param `p_private_details`

Old calls keep working. Just add the named param:

```dart
await supabase.rpc('create_report', params: {
  ...existingParams,
  'p_private_details': privateDetails, // optional, max 500 chars
});
```

`update_report`:

| `p_private_details` value | Effect |
|---|---|
| `null` or not sent | No change |
| `''` | Remove it |
| any text | Save / replace |

To pre-fill the Edit form, read `private_details` from `get_report_details`.

`p_questions` (Story #6) works the same way. See
[section 10](#create_report--update_report-new-param-p_questions).

### "This is Mine" / "I Found This"

Call [`create_manual_match`](#create_manual_matchp_report_id) (Story #2), then:

- `claim_status == 'pending'` → open `/matches/:match_id/verify` (Story #6),
- otherwise → open `/chat/:match_id`.

---

## 5. Story #2: Potential Matches (Ziad)

### `get_my_matches(p_report_id?)`

Your **open** matches (`potential`, `chatting`, `verified`), sorted by best similarity
first. Matches with a deleted report are hidden.

```dart
final list = await supabase.rpc('get_my_matches') as List;            // all (P28)
final forReport = await supabase.rpc('get_my_matches', params: {
  'p_report_id': reportId,                                             // owner's Report Details section
}) as List;
```

Returns `[ Match, Match, ... ]`, or `[]` when there are none.

### `get_match_details(p_match_id)`

One `Match`. Used for the P29 compare screen and the chat header (Youssef).

```dart
final match = await supabase.rpc('get_match_details', params: {'p_match_id': id})
    as Map<String, dynamic>;
```

P29 rows:

| Row | Your report | Other report |
|---|---|---|
| Category | `my_report.category_name_*` | `other_report.category_name_*` |
| Area | `my_report.area_name_*` | `other_report.area_name_*` |
| Date | `my_report.item_date` | `other_report.item_date` |

- Color / Brand are not stored, so don't show those rows.
- Error: `P0002`.

### `create_manual_match(p_report_id)`

"This is Mine" / "I Found This" on someone else's report.

```dart
final res = await supabase.rpc('create_manual_match', params: {'p_report_id': reportId})
    as Map<String, dynamic>;
final matchId = res['match_id'] as String;
// claim_status == 'pending' -> /matches/$matchId/verify, otherwise -> /chat/$matchId
```

Returns `{ "match_id": "uuid", "status": "potential", "claim_status": "pending", "is_new": true }`.

- Already have a match with this report (even a rejected one)? It returns that one with
  `is_new: false`. Never creates duplicates.
- The report owner gets a `potential_match` notification (not while `claim_status = pending`).
- Errors:
  - `42501`: your own report, or you are blocked from it (Story #6).
  - `P0002`: report deleted.
  - `55000`: report already recovered.

### `reject_match(p_match_id)`

Dismiss (P28), Not my item (P29), Reject Match (chat).

```dart
await supabase.rpc('reject_match', params: {'p_match_id': matchId});
```

- The match becomes `rejected`, and the chat becomes read-only.
- A report with no other open match goes back to `active`.
- The other user gets a `match_rejected` notification.
- Error: `55000` when the match is already closed.

### `get_my_matches_count()`

Number of **new** suggestions (status `potential`). Use it for the Home banner
("2 potential matches for you") and Profile → Activity.

```dart
final count = await supabase.rpc('get_my_matches_count') as int;
```

---

## 6. Story #3: Chat (Youssef)

**One match = one chat.** The chat id **is** the `match_id`.

### Live messages: Supabase Realtime (no RPC)

```dart
final Stream<List<Map<String, dynamic>>> messages = supabase
    .from('messages')
    .stream(primaryKey: ['id'])
    .eq('match_id', matchId)
    .order('created_at');   // oldest first
```

- Each item: `id, match_id, sender_id, body, image_path, read_at, created_at`.
- Mine = `sender_id == supabase.auth.currentUser!.id`.
- Every time a message is added, the stream emits the **whole list** again.
- Cancel the subscription in `Cubit.close()`.

### Send a message (normal insert)

```dart
await supabase.from('messages').insert({
  'match_id': matchId,
  'body': text,               // 1..2000 chars, or null if it's a photo only
  'image_path': imagePath,    // null for text only
});
```

- `sender_id` is set automatically.
- The **first message** moves the match `potential → chatting`.
- The other user gets a `new_message` notification.
- Insert fails (RLS error `42501`) when the match is `rejected` / `recovered`. Show the chat
  as closed.
- Insert (and photo upload) also fails while `claim_status = pending` (Story #6).

### Photos in chat (PRIVATE bucket `chat-images`)

```dart
final path = '$matchId/${DateTime.now().millisecondsSinceEpoch}.jpg'; // folder MUST be the match id
await supabase.storage.from('chat-images').upload(path, file);
// then insert a message with 'image_path': path

// show it: the bucket is private -> signed URL (valid 1 hour)
final url = await supabase.storage.from('chat-images').createSignedUrl(path, 3600);
```

JPG / PNG only, max 10 MB. Only the 2 people in the match can upload or view.

### `get_my_chats()`

Messages tab (P31): every match that has at least one message (including closed ones),
newest activity first.

```dart
final chats = await supabase.rpc('get_my_chats') as List;
```

Each item is a `Match` **plus**:

```json
{
  "last_message": { "body": "Can you tell me a detail...", "has_image": false, "is_mine": false, "created_at": "..." },
  "unread_count": 2
}
```

- P31 shows "Lost · Black leather wallet". Use the **lost** side:
  - `my_report` if `i_am_finder == false`
  - otherwise `other_report`
  - and if that one is `null`, use the other one.
- Refresh the list when you come back from a chat, and on pull-to-refresh.

### `get_match_details(p_match_id)`

Chat header: name, report, status, `i_am_finder` (see Story #2).

### `mark_messages_read(p_match_id)`

Call it when the chat opens and whenever a new message arrives while it is open.

### `get_unread_messages_count()`

`int` for the nav bar badge (replace the hardcoded `2`).

### `confirm_ownership(p_match_id)`

"Confirm Ownership Verification" button. **Show it only if `i_am_finder == true` and
`status == 'chatting'`.**

- The match becomes `verified` and `ownership_verified = true`.
- The lost user gets an `ownership_verified` notification.
- Then show the handover entry (`/chat/:matchId/handover`).
- Errors:
  - `42501`: not the finder.
  - `55000`: not in `chatting` (send a message first) or already closed.

### UI rules from the status

| `status` | Input bar | Header actions |
|---|---|---|
| `potential` + `claim_status == 'pending'` | **Disabled**. `i_must_answer` → redirect to `/matches/:id/verify`. Finder → "Waiting for {other_user_name} to answer your verification questions" | Reject |
| `potential` / `chatting` | Enabled | Reject. Confirm (finder only, `chatting`) |
| `verified` | Enabled | "Confirm recovery" (Ziad's `MarkRecoveredButton`) + handover link |
| `rejected` / `recovered` | **Disabled**, show "This chat is closed" | None |

The P32 safety banner stays visible until `verified`.

---

## 7. Story #4: Recovery (Ziad)

### `get_match_contact(p_match_id)`

Handover screen. Returns the **other** user's contact, only after verification.

```json
{ "full_name": "Omar S.", "phone": "+201012345678", "email": "omar@example.com" }
```

- `phone` can be `null`.
- Error: `55000` when ownership is not verified yet.

### `mark_item_recovered(p_match_id)`

"Mark as Item Recovered" / "Confirm recovery". Either user, only when status = `verified`.

```dart
await supabase.rpc('mark_item_recovered', params: {'p_match_id': matchId});
```

- Match → `recovered`. Both reports → `recovered`, so they leave Home / Explore and show
  in My Reports → Recovered.
- Every **other** open match on these 2 reports → `rejected`.
- Both users get an `item_recovered` notification.
- After success, refresh My Reports and go back.
- Error: `55000` when not verified.

---

## 8. Story #5: Notifications and push (Mohamed)

### Notifications list (P30): direct select + Realtime

```dart
// list (newest first)
final rows = await supabase
    .from('notifications')
    .select()
    .order('created_at', ascending: false)
    .limit(50);

// live updates (new rows appear instantly)
final stream = supabase
    .from('notifications')
    .stream(primaryKey: ['id'])
    .order('created_at', ascending: false)
    .limit(50);
```

RLS returns your own rows only. Each row:

| Field | |
|---|---|
| `id`, `created_at`, `read_at` | `read_at == null` → unread |
| `type` | `potential_match` · `new_message` · `ownership_verified` · `match_rejected` · `item_recovered` · `claim_passed` |
| `match_id` | The match it's about |
| `report_id`, `report_title`, `report_type` | **Your** report (title for the text, type = `lost` / `found`) |
| `actor_name` | Who did it ("Mona K."). `null` for automatic matches |
| `message_preview` | First 80 chars of a chat message. `null` for photo-only messages ("📷 Photo") |

**Build the text in the app** (EN/AR from `.arb`). Examples:

| `type` | P30 title | Body |
|---|---|---|
| `potential_match` | Potential match found | A {other type} report may match your {report_type} "{report_title}". |
| `new_message` | New message from {actor_name} | {message_preview} |
| `ownership_verified` | Ownership verified | {actor_name} confirmed the item is yours. Arrange the handover. |
| `match_rejected` | Match closed | {actor_name} closed the match for "{report_title}". |
| `item_recovered` | Report recovered | Your report "{report_title}" was marked Recovered. |
| `claim_passed` | Verification questions answered | {actor_name} answered the questions for "{report_title}" correctly. You can chat now. |

Group by date: **Today** / **Earlier**.

### `mark_notifications_read(p_ids?)`

```dart
await supabase.rpc('mark_notifications_read');                                 // "Mark all read"
await supabase.rpc('mark_notifications_read', params: {'p_ids': [notifId]});   // one, on tap
```

### `get_unread_notifications_count()`

`int` for the unread dot on the Home bell icon.

### `save_device_token(p_token, p_platform, p_lang)` / `delete_device_token(p_token)`

```dart
await supabase.rpc('save_device_token', params: {
  'p_token': fcmToken,
  'p_platform': 'android',   // 'android' | 'ios' | 'web'
  'p_lang': 'ar',            // current app language: push text uses it
});
```

Call `save_device_token`:

- after login and on app start when already logged in,
- on `onTokenRefresh`,
- **when the user changes the language**.

Call `delete_device_token(p_token)` on logout, **before** `signOut()`, because it needs
the logged-in user.

### Push payload (what the Edge Function sends)

Every push is created from a `notifications` row, so it has the same `type`:

```json
{
  "notification": { "title": "Potential Match Found!", "body": "We found a report matching your lost item. Tap to chat and verify ownership." },
  "data": {
    "type": "potential_match",
    "notification_id": "uuid",
    "match_id": "uuid",
    "report_id": "uuid"
  }
}
```

Title / body come in the language saved with the token.

The Android channel id is **`found_it_default`**. Create a channel with this exact id in
`flutter_local_notifications`, and use it for foreground notifications too.

The texts come from Story #5:

- **Potential match:** "Potential Match Found! We found a report matching your lost item. Tap to chat and verify ownership."
- **New message:** "New message from {Name}: Tap to view."

**On tap** (foreground, background and terminated):

| `data.type` | Open |
|---|---|
| `potential_match` | `/matches/{match_id}` |
| `new_message`, `ownership_verified`, `match_rejected`, `claim_passed` | `/chat/{match_id}` |
| `item_recovered` | `/reports/{report_id}` |

Then call `mark_notifications_read(p_ids: [notification_id])`.

> The Edge Function and the webhook are LIVE. Until the app saves a device token,
> test receiving with **Firebase Console → Messaging → "Send test message"** to your
> device token, using the `data` above.

---

## 9. Who uses what

| Person | Calls |
|---|---|
| **Adham** | `get_report_details`, `create_report` / `update_report` (`p_private_details`), `create_manual_match`, `get_my_matches_count` (Home banner + Profile) |
| **Ziad** | `get_my_matches`, `get_match_details`, `reject_match`, `get_match_contact`, `mark_item_recovered` |
| **Youssef** | `messages` stream + insert, `chat-images` storage, `get_my_chats`, `get_match_details`, `mark_messages_read`, `get_unread_messages_count`, `confirm_ownership`, `reject_match` |
| **Mohamed** | `notifications` select + stream, `mark_notifications_read`, `get_unread_notifications_count`, `save_device_token`, `delete_device_token` |

Story #6 additions:

| Person | Calls / uses |
|---|---|
| **Adham** | `create_report` / `update_report` (`p_questions`), `get_report_details` (`questions`, `has_questions`, `i_am_blocked`), `create_manual_match` (`claim_status`) |
| **Mohamed** | `get_claim_questions`, `submit_claim_answers`, notification type `claim_passed` |
| **Youssef** | `get_match_details` (`claim_status`, `i_must_answer`) for the chat lock |
| **Ziad** | `Match.i_must_answer` on MatchCard + Compare |

---

## 10. Story #6: Ownership verification questions

The finder adds **1–3 multiple-choice questions** to a **Found** report. Whoever claims
the item (the **lost** side of the match) must answer **all** of them before the chat
opens. **One chance:** any wrong answer closes the match and blocks that user from the
report forever. The app is never told which answer was wrong.

### `claim_status` (on every `Match`)

| Value | Meaning | Chat |
|---|---|---|
| `not_required` | No questions, or the match started from a **Lost** report ("I Found This") | Open |
| `pending` | The lost-side user must answer first | **Locked for both** |
| `passed` | Answered correctly | Open |
| `failed` | A wrong answer. The match is `rejected` and the user is blocked | Closed |

`i_must_answer == true` → **I** am the one who must answer now → open
`/matches/:match_id/verify`.

### `create_report` / `update_report`: new param `p_questions`

Same shape for both. Found reports only (a Lost report with questions → `22023`).

```dart
await supabase.rpc('create_report', params: {
  ...existingParams,
  'p_questions': [
    {'question': 'What color is the wallet?', 'correct': 'Black', 'wrong': ['Brown', 'Blue']},
    {'question': 'What is written inside?',   'correct': 'A.K.',  'wrong': ['M.S.', 'R.T.', 'Nothing']},
  ],
});
```

Rules (the server checks them, error `22023` with the reason in `message`):

- 0 to 3 questions. **The app requires at least 1 for a Found report.**
- `question`: 3–150 chars. Every answer: 1–80 chars.
- `wrong`: 2 or 3 answers. All answers of one question must be different.
- The server **shuffles** the choices, so the correct one isn't always first.

`update_report`:

| `p_questions` value | Effect |
|---|---|
| `null` or not sent | No change |
| `[]` | Remove all questions (waiting matches open their chat) |
| a list | Replace all questions |

Changing a report to **Lost** removes its questions.

To show them to the owner / pre-fill Edit, read `questions` from `get_report_details`:

```json
[ { "id": "uuid", "position": 1, "question": "What color is the wallet?",
    "correct": "Black", "wrong": ["Brown", "Blue"] } ]
```

### `get_claim_questions(p_match_id)`

The Verify Ownership screen. Returns the questions **without** the answer:

```dart
final list = await supabase.rpc('get_claim_questions', params: {'p_match_id': matchId})
    as List;
```

```json
[ { "question_id": "uuid", "position": 1, "question": "What color is the wallet?",
    "options": ["Brown", "Black", "Blue"] } ]
```

Show the options **in this order** (the answer uses their index).

Errors: `P0002` not your match · `42501` you are the finder · `55000` nothing to answer
(already answered, or the match was closed).

### `submit_claim_answers(p_match_id, p_answers)`

One call with **all** answers. `choice` = the **0-based index** inside `options`.

```dart
final res = await supabase.rpc('submit_claim_answers', params: {
  'p_match_id': matchId,
  'p_answers': [
    {'question_id': q1Id, 'choice': 1},
    {'question_id': q2Id, 'choice': 0},
  ],
}) as Map<String, dynamic>;

final passed = res['passed'] as bool;
```

Returns `{ "passed": true, "match_id": "uuid" }`.

| `passed` | What happened | App |
|---|---|---|
| `true` | `claim_status = passed`. The finder gets `claim_passed` | Open `/chat/:match_id` |
| `false` | Match `rejected`, `claim_status = failed`, you are blocked from this report | Show "You can't claim this item". Never say which answer was wrong |

Show a confirm dialog before sending: **"You only have one chance."**

Errors: same as `get_claim_questions`, plus `22023` when a question is missing or
answered twice.

### Who sees what

| | Finder (report owner) | Person claiming |
|---|---|---|
| Questions | ✅ with the correct answers | ✅ without the answers (`get_claim_questions`) |
| Other users | `has_questions` + `questions_count` only | |
| Blocked user | | `i_am_blocked = true`, can't claim again, never auto-matched again |
