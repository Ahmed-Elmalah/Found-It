# FOUND IT: Database Guide

How to use the Supabase database from the app: the tables, the functions you can
call, how to upload photos, and the rules everyone follows.

> Owner: Ahmed. Want a new column, table, or function? Ask before changing anything
> in Supabase, so the SQL files in `supabase/sql/` stay the single source of truth.

---

## Contents

1. [Quick start](#1-quick-start)
2. [Rules for the team](#2-rules-for-the-team)
3. [Tables](#3-tables)
4. [The `report_details` view](#4-the-report_details-view)
5. [Functions (RPC)](#5-functions-rpc)
6. [Uploading photos](#6-uploading-photos)
7. [Auth (sign up / login)](#7-auth-sign-up--login)
8. [Errors](#8-errors)
9. [Who uses what](#9-who-uses-what)
10. [Changing the database](#10-changing-the-database)

---

## 1. Quick start

The Supabase client is set up once in `main.dart` (stage 2 of the auth work).
After that, any **data source** gets it like this:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;
```

Call a function:

```dart
final rows = await supabase.rpc('get_home_feed', params: {
  'p_city_id': cityId,
});
// rows is a List<dynamic>; every item is a Map<String, dynamic>
```

> Following the README architecture, Supabase calls go **only in the data source**
> (`features/<feature>/data/..._data_source.dart`), never in a screen or a cubit.

---

## 2. Rules for the team

1. **Use the functions** in section 5 when one exists. They already apply the
   filters (city, not deleted, newest first).
2. **Never delete a report.** Use `soft_delete_report`. A real `DELETE` is blocked.
3. **Status values** are lowercase in the database: `active`, `matching`, `recovered`.
   **Type values:** `lost`, `found`. Show the translated text in the UI.
4. **Dates:** `item_date` is a `date` (`'2026-11-06'`), and `created_at` / `updated_at` are
   `timestamptz` (ISO strings). Parse them with `DateTime.parse(...)`.
5. **City and category names** come in both languages (`name_en` / `name_ar`).
   Pick one based on the app language.
6. **Photos:** upload them to Storage first, then save the URLs in the report (section 6).
7. **Never** put the `service_role` key in the app. The app uses the publishable
   (anon) key only.

---

## 3. Tables

### `cities` (read only)
| Column | Type | Notes |
|---|---|---|
| `id` | uuid | |
| `name_en` / `name_ar` | text | "Cairo" / "القاهرة" |
| `is_active` | bool | Only active cities are returned |
| `sort_order` | int | Order in the list |

Seeded with: Cairo, Alexandria, Giza.

```dart
final cities = await supabase.from('cities').select().order('sort_order');
```

### `categories` (read only)
| Column | Type | Notes |
|---|---|---|
| `id` | uuid | |
| `name_en` / `name_ar` | text | |
| `icon` | text | Material icon name, e.g. `devices`, mapped to `Icons.devices` in Flutter |
| `is_active` / `sort_order` | | Same as `cities` |

Seeded with: Electronics, Wallets, Keys, Bags, Documents, Pets, Other.

```dart
final categories = await supabase.from('categories').select().order('sort_order');
```

### `areas` (read only)
The districts inside each city. Every area belongs to **one** city.

| Column | Type | Notes |
|---|---|---|
| `id` | uuid | |
| `city_id` | uuid | → `cities` |
| `name_en` / `name_ar` | text | "Maadi" / "المعادي" |
| `is_active` / `sort_order` | | `sort_order` 99 = "Other", always last |

Seeded with: Cairo 30, Giza 17, Alexandria 30 (each city has an "Other / أخرى").
Get them with `get_city_areas` (section 5).

### `profiles` (one row per user)
Created **automatically** when someone signs up. Nobody inserts it from the app.

| Column | Type | Editable from the app? |
|---|---|---|
| `id` | uuid (= auth user id) | no |
| `full_name` | text | yes |
| `email` | text | no |
| `phone` | text | yes |
| `address` | text | yes |
| `avatar_url` | text | yes |
| `city_id` | uuid, null until the user picks a city | yes (use `set_my_city`) |
| `role` | `user` / `admin` | no |
| `created_at` / `updated_at` | timestamptz | no (automatic) |

A user can read and edit **only their own** profile.

```dart
await supabase.from('profiles')
    .update({'full_name': 'Ahmed Ali', 'phone': '+201012345678'})
    .eq('id', supabase.auth.currentUser!.id);
```

### `reports`
| Column | Type | Notes |
|---|---|---|
| `id` | uuid | |
| `ref_code` | text | Automatic: `RPT-1001`, `RPT-1002`, ... |
| `user_id` | uuid | Automatic: the logged-in user |
| `type` | text | `lost` / `found` |
| `title` | text | 3 to 50 characters |
| `description` | text | Optional, max 1000 |
| `category_id` | uuid | → `categories` |
| `city_id` | uuid | → `cities` |
| `area_id` | uuid | → `areas`. **Must be an area of that same city** (the database rejects anything else) |
| `item_date` | date | The day it was lost/found (default: today) |
| `images` | text[] | 1 to 4 public photo URLs |
| `status` | text | `active` (default) / `matching` / `recovered` |
| `deleted_at` | timestamptz | `null` = visible. Set means deleted (soft delete) |
| `created_at` / `updated_at` | timestamptz | Automatic |

Who sees what:
- Everyone logged in sees reports that are **not deleted**.
- The owner also sees their own deleted ones (they are hidden by the functions anyway).
- Only the owner can edit a report.

### How the tables are linked

```
auth.users  ─1:1─  profiles   ─1:N─  reports      (a user has many reports)
cities      ─1:N─  areas      ─1:N─  reports      (a city has many areas)
cities      ─1:N─  reports                        (report's city)
categories  ─1:N─  reports
cities      ─1:N─  profiles                       (the user's chosen city)
```

| From | To | On delete |
|---|---|---|
| `profiles.id` | `auth.users.id` | user deleted → profile deleted |
| `profiles.city_id` | `cities.id` | city removed → `city_id` becomes null |
| `areas.city_id` | `cities.id` | blocked (a city with areas can't be deleted) |
| `reports.user_id` | `profiles.id` | profile deleted → their reports deleted |
| `reports.category_id` | `categories.id` | blocked while reports use it |
| `reports.city_id` | `cities.id` | blocked while reports use it |
| `reports.(area_id, city_id)` | `areas.(id, city_id)` | blocked. Also guarantees the area is in the report's city |

Cities, categories and areas are never deleted. To hide one, set `is_active = false`.

---

## 4. The `report_details` view

A ready-to-display report: all the `reports` columns **plus**:

| Extra column | Example |
|---|---|
| `category_name_en` / `category_name_ar` / `category_icon` | "Wallets" / "محافظ" / "account_balance_wallet" |
| `city_name_en` / `city_name_ar` | "Cairo" / "القاهرة" |
| `area_name_en` / `area_name_ar` | "Maadi" / "المعادي" |
| `is_mine` | `true` if the logged-in user owns it |

Every function that returns reports returns rows of this shape. So **one
`ReportModel.fromJson`** works everywhere (Home, Explore, My Reports, Create).

Example row:

```json
{
  "id": "6f1c...",
  "ref_code": "RPT-1001",
  "user_id": "a2b4...",
  "type": "lost",
  "title": "Black leather wallet",
  "description": null,
  "category_id": "c9d1...",
  "category_name_en": "Wallets",
  "category_name_ar": "محافظ",
  "category_icon": "account_balance_wallet",
  "city_id": "11aa...",
  "city_name_en": "Cairo",
  "city_name_ar": "القاهرة",
  "area_id": "5e7f...",
  "area_name_en": "Maadi",
  "area_name_ar": "المعادي",
  "item_date": "2026-11-06",
  "images": ["https://<project>.supabase.co/storage/v1/object/public/report-images/a2b4.../1731300000000_0.jpg"],
  "status": "active",
  "deleted_at": null,
  "created_at": "2026-11-06T10:12:00.000+00:00",
  "updated_at": "2026-11-06T10:12:00.000+00:00",
  "is_mine": true
}
```

---

## 5. Functions (RPC)

All functions need a **logged-in user**. They run with that user's permissions, so the
security rules always apply. Parameters marked *optional* can be left out or sent as `null`.

### `get_my_profile()`: the logged-in user's profile
Returns: `id, full_name, email, phone, address, avatar_url, role, city_id, city_name_en, city_name_ar, created_at`

```dart
final profile = await supabase.rpc('get_my_profile').single();
final hasCity = profile['city_id'] != null;
```

### `set_my_city(p_city_id)`: save the chosen city
```dart
await supabase.rpc('set_my_city', params: {'p_city_id': cityId});
```
Error `P0002` means the city was not found.

### `get_city_areas(p_city_id, p_lang)`: the areas of one city
`p_lang` is optional: `'en'` (default) or `'ar'`, and sets which name the list is sorted by.
"Other" always comes last. Returns `id, city_id, name_en, name_ar, is_active, sort_order, created_at`.

```dart
final areas = await supabase.rpc('get_city_areas', params: {
  'p_city_id': cityId,
  'p_lang': 'ar',
});
```

### `get_home_feed(...)`: latest active reports in a city (Home)
| Param | Type | |
|---|---|---|
| `p_city_id` | uuid | required |
| `p_type` | text | optional: `lost` / `found` (`null` = All) |
| `p_limit` | int | optional, default 20, max 50 |
| `p_offset` | int | optional, default 0 (for "load more") |

```dart
final rows = await supabase.rpc('get_home_feed', params: {
  'p_city_id': cityId,
  'p_type': null,     // All tab
  'p_limit': 20,
});
```

### `search_reports(...)`: Explore search and filters
Returns active, not-deleted reports in the city, newest first.

| Param | Type | |
|---|---|---|
| `p_city_id` | uuid | required |
| `p_query` | text | optional: searches the title and description |
| `p_type` | text | optional: `lost` / `found` |
| `p_category_ids` | uuid[] | optional: one or more categories |
| `p_area_ids` | uuid[] | optional: one or more areas |
| `p_date_from` / `p_date_to` | date | optional: `'2026-11-01'` |
| `p_limit` / `p_offset` | int | optional, default 20 / 0 |

```dart
final rows = await supabase.rpc('search_reports', params: {
  'p_city_id': cityId,
  'p_query': 'airpods',
  'p_category_ids': [electronicsId],
  'p_area_ids': [maadiId, zamalekId],
  'p_date_from': '2026-11-01',
  'p_date_to': '2026-11-07',
});
```

### `create_report(...)`: publish a report
Upload the photos **first** (section 6), then:

| Param | Type | |
|---|---|---|
| `p_type` | text | `lost` / `found` |
| `p_title` | text | 3 to 50 characters |
| `p_category_id` | uuid | |
| `p_city_id` | uuid | |
| `p_area_id` | uuid | Must be an area of `p_city_id` |
| `p_images` | text[] | 1 to 4 public URLs |
| `p_item_date` | date | optional, default today |
| `p_description` | text | optional |

Returns one `report_details` row. The success screen uses its `ref_code`.

```dart
final report = await supabase.rpc('create_report', params: {
  'p_type': 'lost',
  'p_title': 'Black leather wallet',
  'p_category_id': categoryId,
  'p_city_id': cityId,
  'p_area_id': areaId,
  'p_images': imageUrls,
  'p_item_date': '2026-11-06',
}).single();
print(report['ref_code']); // RPT-1001
```

### `get_my_reports(p_status)`: My Reports list
`p_status` is optional: `null` = All, `active`, `matching`, or `recovered`.
Deleted reports are never returned.

```dart
final rows = await supabase.rpc('get_my_reports', params: {'p_status': 'active'});
```

### `get_my_reports_counts()`: numbers on the My Reports tabs
Returns `total, active, matching, recovered`.

```dart
final counts = await supabase.rpc('get_my_reports_counts').single();
// {total: 3, active: 1, matching: 1, recovered: 1}
```

### `update_report(...)`: edit your report
Send `p_report_id` plus **only the fields that changed**. Everything else stays as it is.
To clear the description, send `''`.

```dart
final updated = await supabase.rpc('update_report', params: {
  'p_report_id': reportId,
  'p_title': 'Brown leather wallet',
  'p_area_id': zamalekId,
}).single();
```

Optional params: `p_type, p_title, p_description, p_category_id, p_city_id, p_area_id, p_item_date, p_images`.
If you change `p_city_id`, also send a `p_area_id` from the new city.

### `update_report_status(p_report_id, p_status)`
```dart
await supabase.rpc('update_report_status', params: {
  'p_report_id': reportId,
  'p_status': 'recovered',
});
```

### `soft_delete_report(p_report_id)`: delete your report
Hides it from Home, Explore and My Reports. The row stays in the database.

```dart
await supabase.rpc('soft_delete_report', params: {'p_report_id': reportId});
```

---

## 6. Uploading photos

- Bucket: **`report-images`** (public: anyone with the URL can view a photo)
- Max **10 MB** per photo, **JPG / PNG** only. Anything else is rejected by Supabase.
- Path rule: **`<user_id>/<file name>`**. You can only upload inside your own user id folder.

```dart
final userId = supabase.auth.currentUser!.id;
final urls = <String>[];

for (var i = 0; i < files.length; i++) {
  final ext = files[i].path.split('.').last.toLowerCase();        // jpg / png
  final path = '$userId/${DateTime.now().millisecondsSinceEpoch}_$i.$ext';

  await supabase.storage.from('report-images').upload(
    path,
    files[i],                                                       // a dart:io File
    fileOptions: FileOptions(contentType: ext == 'png' ? 'image/png' : 'image/jpeg'),
  );

  urls.add(supabase.storage.from('report-images').getPublicUrl(path));
}
// then: create_report(..., p_images: urls)
```

Still check the size and type **in the app** before uploading (`AppLimits.maxImageSizeBytes`,
`AppLimits.allowedImageExtensions`), so the user sees the error from the design right away.

---

## 7. Auth (sign up / login)

- Email + password. **Confirm email is OFF** during development, so sign up logs the user in right away.
- Send the extra sign-up fields as `data`. The database copies them into `profiles` automatically:

```dart
await supabase.auth.signUp(
  email: email,
  password: password,
  data: {
    'full_name': fullName,
    'phone': '+20$phone',
    'address': address,
  },
);
```

- Current user: `supabase.auth.currentUser` (`null` = logged out)
- Log out: `await supabase.auth.signOut();`

---

## 8. Errors

Supabase throws a `PostgrestException` (database / functions) or an `AuthException` (auth).
Use `e.code` to decide which message to show:

| `code` | Meaning | Example cause |
|---|---|---|
| `23514` | A value breaks a rule | Title shorter than 3, more than 4 images, wrong status |
| `23503` | A wrong id | `category_id` that does not exist, or an area from another city |
| `P0002` | Not found / not yours | Editing or deleting someone else's report |
| `42501` | Not allowed | Not logged in, or editing a column that is locked |

```dart
try {
  await supabase.rpc('soft_delete_report', params: {'p_report_id': id});
} on PostgrestException catch (e) {
  if (e.code == 'P0002') { /* report not found */ }
}
```

---

## 9. Who uses what

| Who | Feature | Uses |
|---|---|---|
| Youssef | City + Home | `cities`, `set_my_city`, `get_my_profile`, `get_home_feed` |
| Ahmed | Auth | `auth.signUp / signIn`, `get_my_profile` |
| Adham | My Reports + Profile | `get_my_reports`, `get_my_reports_counts`, `update_report`, `update_report_status`, `soft_delete_report`, `get_city_areas`, `profiles` update |
| Mohamed | Explore | `search_reports`, `categories`, `get_city_areas` |
| Ziad | Create report | `categories`, `get_city_areas`, Storage upload, `create_report` |

---

## 10. Changing the database

The SQL lives in `supabase/sql/`, run in order in the Supabase **SQL Editor**:

| File | What it does |
|---|---|
| `01_tables.sql` | Tables + indexes |
| `02_triggers.sql` | Automatic `updated_at` + profile on sign up |
| `03_security.sql` | RLS policies + column permissions |
| `04_storage.sql` | `report-images` bucket + its rules |
| `05_functions.sql` | `report_details` view + all functions |
| `06_seed.sql` | Cities + categories |
| `07_areas.sql` | Areas table + seed, reports `district` → `area_id`, functions updated |
| `99_verify.sql` | Checks to confirm everything works |

To change something: **add a new numbered file** (e.g. `07_add_report_color.sql`).
Don't edit a file that was already run. Then tell Ahmed and update this guide.
