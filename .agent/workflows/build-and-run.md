---
description: How to build and run the Flutter Hymnal app
---

## Prerequisites

- Flutter 3.38.9 managed via FVM

## Steps

// turbo
1. Install dependencies:
```bash
fvm flutter pub get
```

// turbo
2. Run the app in debug mode:
```bash
fvm flutter run
```

3. Build for release (only if explicitly requested):
```bash
fvm flutter build apk --release   # Android
fvm flutter build ios --release    # iOS
```
