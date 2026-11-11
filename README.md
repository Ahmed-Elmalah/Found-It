# FOUND IT

A city-based Lost & Found mobile app. People report items they lost or found,
browse active reports in their own city, get suggested matches, and chat with
the other side to arrange a safe handover.

Built with **Flutter**, **Clean Architecture**, and **Cubit** (flutter_bloc).
Supports **Arabic (RTL) + English** and **Light + Dark** mode.

> The task list and progress live in **Azure DevOps**, not in this file.

---

## Design

Figma (screens, light + dark, Arabic + English):
[Smart Search – Lost & Found (Mobile UI) – FOUND IT](https://www.figma.com/design/ML26Gs1rpp10aXzljN38Wz/Smart-Search-%E2%80%93-Lost---Found--Mobile-UI--%E2%80%94-FOUND-IT?node-id=3-2&t=n8cBeP45PFkRtVo9-1)

Design frame: **390 x 844**. Always check the Figma file for sizes and spacing.

---

## What the app does

- **Onboarding and auth:** onboarding on first launch only, sign up, login, forgot password, email verification.
- **City:** the user picks a city, and the whole app is filtered to it. It can be changed later from the top bar.
- **Home:** latest active reports in the selected city.
- **Explore:** search by keyword and filter by category, date range, and city.
- **Create report:** a Lost or Found report with title, category, location, date, and 1-4 photos.
- **My reports:** view, edit, and delete your own reports, with a status on each (Active, Matching, Recovered).
- **Potential matches:** suggested matches between lost and found reports, with a similarity score.
- **Messages:** in-app chat between the owner and the finder, linked to a report.
- **Notifications:** new matches, new messages, and report status changes.
- **Profile:** account, city, language, and theme.

---

## Getting started

```bash
cp .env.example .env  # then fill in the Supabase values (ask Ahmed, shared privately)
flutter pub get
flutter gen-l10n      # generates the translations class
flutter run
```

> Run `flutter gen-l10n` again every time you add or edit text in the `.arb` files.
>
> The app won't build without a `.env` file. Never commit it.
> Database guide (tables, functions, Dart examples): [docs/database.md](docs/database.md)

---

## Packages

| Package | Used for |
|---|---|
| `flutter_bloc` + `equatable` | State management (Cubit) |
| `get_it` | Dependency injection |
| `go_router` | Navigation |
| `flutter_screenutil` | Responsive sizes (`.w` `.h` `.sp` `.r`) |
| `intl` + `flutter_localizations` | Arabic / English |

---

## Project structure

```
lib/
├── main.dart              # starts the app (initializes DI, then runApp)
├── found_it.dart          # root widget: theme, router, localization, screenutil
│
├── core/                  # shared by ALL features
│   ├── constants/         # app_limits, storage_keys, app_assets, app_durations
│   ├── di/                # injection.dart (get_it)
│   ├── localization/      # app_en.arb, app_ar.arb (+ generated files)
│   ├── router/            # app_routes.dart, app_router.dart
│   ├── theme/             # app_colors.dart, app_theme.dart
│   ├── utils/             # validators.dart
│   ├── error/             # failures / result types (when needed)
│   └── widgets/           # shared widgets
│
└── features/              # one folder per feature
    ├── auth/              # <- use it as the template for every feature
    │   ├── data/          # model, data source, repository implementation
    │   ├── domain/        # entity, repository (abstract), use cases
    │   └── view/
    │       ├── cubit/     # Cubit + State
    │       └── ui/        # screens and widgets
    └── city/  home/  explore/  reports/  matches/  messages/  profile/ ...
```

---

## Architecture rules

```
view (ui + cubit)  ->  domain  <-  data
```

1. **view** talks to **domain** only (use cases). Never import anything from `data` inside `view`.
2. **data** implements the abstract repository that lives in **domain**.
3. **domain** is plain Dart: no Flutter, no packages.
4. Screens never call the backend directly. The flow is always:
   `Screen -> Cubit -> UseCase -> Repository -> DataSource`
5. Features don't import each other's internals. Anything shared goes to `core/`.

---

## How to add a new feature

Example: a feature called `city`.

**1) Create the folders** (copy the structure of `auth`):

```
features/city/
├── data/
├── domain/
└── view/
    ├── cubit/
    └── ui/
```

**2) Register everything in `core/di/injection.dart`:**

```dart
sl
  ..registerLazySingleton<CityDataSource>(() => CityDataSourceImpl())
  ..registerLazySingleton<CityRepository>(() => CityRepositoryImpl(sl()))
  ..registerLazySingleton(() => GetCityUseCase(sl()))
  ..registerFactory(() => CityCubit(sl()));
```

| Register as | For |
|---|---|
| `registerLazySingleton` | data sources, repositories, use cases |
| `registerFactory` | Cubits (a fresh one for every screen) |

**3) Add the route.** First the path in `core/router/app_routes.dart`:

```dart
static const city = '/city';
```

Then the route in `core/router/app_router.dart`:

```dart
GoRoute(
  path: AppRoutes.city,
  builder: (context, state) => BlocProvider(
    create: (_) => sl<CityCubit>(),
    child: const CityScreen(),
  ),
),
```

**4) Navigate:**

```dart
context.go(AppRoutes.home);      // replaces the current screen (e.g. after login)
context.push(AppRoutes.signUp);  // opens on top, back button works
context.pop();                   // go back
```

---

## Rules for the UI code

### Colors: from the theme, never hardcoded

```dart
final colors = Theme.of(context).colorScheme;

colors.primary                  // brand blue (buttons, links)
colors.onPrimary                // text on primary
colors.surface                  // cards, fields
colors.onSurface                // normal text
colors.onSurfaceVariant         // muted text (dates, hints)
colors.outline                  // borders
colors.surfaceContainerHighest  // image placeholders
colors.error                    // errors
```

Light and Dark switch automatically. **Never write `Color(0xFF...)` inside a widget.**

Buttons (`FilledButton`, `OutlinedButton`), `TextField`, `AppBar`, and bottom
sheets already get their size, shape and colors from `AppTheme`.
Don't restyle them in every screen.

### Sizes: use ScreenUtil with the Figma numbers

The design frame is **390 x 844**. Write the number exactly as in Figma:

```dart
SizedBox(height: 16.h)
Padding(padding: EdgeInsets.all(16.w))
Text('Hello', style: TextStyle(fontSize: 14.sp))
BorderRadius.circular(12.r)
```

### Texts: from the translations, never hardcoded

1. Add the key to **both** `lib/core/localization/app_en.arb` and `app_ar.arb`.
2. Run `flutter gen-l10n`.
3. Use it:

```dart
import 'package:found_it/core/localization/app_localizations.dart';

final l10n = AppLocalizations.of(context);
Text(l10n.chooseCityTitle);
```

For margins and paddings use `EdgeInsetsDirectional` (start/end) instead of
left/right, so the screen flips correctly in Arabic.

### Constants

Don't type numbers or keys that repeat. Use:

| File | Example |
|---|---|
| `constants/app_limits.dart` | `AppLimits.passwordMinLength` (8), report title 3-50, 1-4 images, 10 MB |
| `constants/storage_keys.dart` | `StorageKeys.isFirstLaunch` |
| `constants/app_assets.dart` | image / icon paths |
| `constants/app_durations.dart` | splash and snackbar durations |

### Validation

```dart
TextFormField(
  validator: (value) => Validators.isValidPassword(value)
      ? null                       // null = no error
      : l10n.passwordTooShort,     // add this key to the .arb files first
)
```

`Validators` returns `true` / `false` only. The error message is chosen in the
screen because it needs the translations.

---

## Before you push

```bash
flutter gen-l10n    # only if you touched the .arb files
flutter analyze
```

Run the app once in **Light** and **Dark** mode.