# multai_mobile

## 1. Project Overview

`multai_mobile` is a Flutter project designed for micro-club to solve the problem of managing event images. It shows your photo only in the event you’re participating in—so you can find it quickly and share it easily.

## 2. Project Structure

This repo follows a feature-oriented structure under `lib/`:

- `lib/`
  - `main.dart`: Application entry point and top-level widget wiring.
  - `core/`: Shared infrastructure used across the app (theme, shared widgets, extensions, networking/router abstractions, validators, errors, constants).
    - `core/extensions/`: `BuildContext` extensions for theme, sizing, responsiveness, and helpers.
    - `core/theme/`: Centralized styling via `AppTheme`.
    - `core/widgets/`: Reusable shared UI components (the project’s shared `widgets/`).
  - `features/`: Feature modules grouped by user capability/workflow (e.g., `home/`, `gallery/`, `auth/`, `onboarding/`, `face_enrollment/`).
  - `di/`: Dependency injection setup (service locator / injection container).

Repository root:

- `assets/`: Images and icons used by the UI.
- `test/`: Widget/unit tests.
- `.env` / `.env.example`: Environment configuration (do not commit secrets).

## 3. Coding Standards

We aim for clean code, predictable patterns, and maintainability:

- Prefer small, focused classes and functions.
- Keep responsibilities separated (UI vs. state vs. business logic).
- Avoid UI duplication by extracting reusable widgets into `lib/core/widgets/` or appropriate feature folders.

### UI Value Rules (Very Important)

- Do NOT hardcode UI values such as widths/heights, paddings/margins, font sizes, and colors.
- Always use the shared theme (`AppTheme`) and `Theme`-derived values, plus `BuildContext` extension helpers for sizing and responsive values.

## 4. Extensions Usage (IMPORTANT)

This project uses `BuildContext` extensions to standardize theme access and responsive calculations.

Developers MUST use the following instead of direct framework calls:

- Use `context.width` / `context.height` instead of `MediaQuery.of(context)`
- Use `context.theme` / `context.textTheme` instead of `Theme.of(context)`
- Use responsive helpers like `context.logoSize()`, `context.hPadding()`, `context.iconSize()`, `context.radius()`, etc.

### Examples

Bad:

```dart
MediaQuery.of(context).size.height
```

Good:

```dart
context.height
```

Bad:

```dart
Theme.of(context).textTheme
```

Good:

```dart
context.textTheme
```

Responsive helpers example:

```dart
final padding = context.hPadding();
final logoSize = context.logoSize();
```

## 5. Responsive Design Rules

All UI must work correctly on a wide range of screen sizes and aspect ratios:

- Avoid fixed dimensions (no hardcoded pixel widths/heights/paddings).
- Use extension helpers for sizing/responsiveness (see `lib/core/extensions/extensions.dart`).
- When scaling is needed, rely on the extension methods that clamp values appropriately (instead of manual constants).

## 6. Git Workflow

We use a safe, team-friendly branching strategy:

- Create feature branches (e.g., `feature/<short-description>`).
- Keep your branch updated with `main`.
- If you see: "Your branch is behind the main branch", pull the latest changes from `main` before continuing work.

Suggested flow:

1. Create branch from `main`
2. Implement feature with the project standards
3. Sync with `main` as needed (to reduce merge conflicts)
4. Open a PR for review

## 7. Best Practices

- Prefer reusable widgets over copy/paste UI.
- Use a separation of concerns approach (UI focused on presentation; state/business logic lives outside widgets).
- Keep styling consistent by using `AppTheme` and theme-derived values.
- Follow existing architecture and patterns found in the current `core/` and `features/` modules.

## 8. Setup Instructions

1. Install dependencies:

```bash
flutter pub get
```

2. Run the app:

```bash
flutter run
```

Notes for local configuration:

- If the app requires environment variables, copy from `.env.example` to `.env` (and keep secrets out of version control).

## 9. Contribution Rules

When contributing:

- Follow the coding and UI standards listed above.
- Do not introduce hardcoded UI values (width/height/padding/font sizes/colors).
- Use `BuildContext` extensions and shared theme styles consistently.
- Keep code aligned with the existing architecture under `core/` and `features/`.

Before submitting a PR, ensure:

- The feature builds and runs on a real device or emulator.
- No formatting/lint issues were introduced.

