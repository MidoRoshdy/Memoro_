# Memoro

Memoro is a Flutter application with Firebase integration.

## Tech Stack

- Flutter (Dart)
- Firebase (`firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`)
- Riverpod (`flutter_riverpod`)

## Prerequisites

Install these before running the app:

- Flutter SDK
- Dart SDK (included with Flutter)
- Git
- A code editor (VS Code / Cursor / Android Studio)
- Platform-specific toolchains:
  - Android: Android Studio + Android SDK
  - iOS/macOS: Xcode (macOS only)
  - Windows desktop: Visual Studio with **Desktop development with C++**

## Getting Started

1. Clone the repository:

```bash
git clone <your-repo-url>
cd memoro
```

2. Install dependencies:

```bash
flutter pub get
```

3. Verify Flutter setup:

```bash
flutter doctor
```

4. Run the app:

```bash
flutter run
```

## Running On Windows

If you want to share this project and run it on Windows:

1. Install Flutter and Visual Studio (with Desktop C++).
2. Enable desktop support:

```bash
flutter config --enable-windows-desktop
```

3. From project root, restore packages:

```bash
flutter pub get
```

4. Run the app on Windows:

```bash
flutter run -d windows
```

## Firebase Setup

This project uses Firebase and includes `lib/firebase_options.dart`.

If you connect to a different Firebase project:

1. Install FlutterFire CLI.
2. Reconfigure Firebase:

```bash
flutterfire configure
```

3. Confirm platform configuration files are generated/updated correctly.

## Share Across macOS/Windows/Linux Safely

To avoid environment issues when sharing code:

- Use relative paths in code (do not hardcode machine-specific absolute paths).
- Keep secrets out of Git (`.env`, service-account files, API keys).
- Commit source and config, not build outputs.
- Ensure line endings are normalized.

Recommended `.gitattributes`:

```gitattributes
* text=auto eol=lf
*.bat text eol=crlf
```

## Useful Commands

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
```

## Project Structure (high level)

- `lib/` - application source code
- `assets/` - images, music, and UI assets
- `android/`, `ios/`, `linux/`, `macos/`, `windows/` - platform-specific code

## Troubleshooting

- If packages fail to resolve: run `flutter pub get` again.
- If platform build fails: run `flutter doctor` and fix reported issues.
- If Firebase fails to initialize: verify your Firebase config files and project setup.
# Memoro_
