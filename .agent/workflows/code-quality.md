---
description: How to check code quality (analyze, format, generate)
---

## Steps

// turbo
1. Analyze code for issues:
```bash
fvm flutter analyze
```

// turbo
2. Format code:
```bash
fvm dart format .
```

3. Generate localization files (after updating l10n):
```bash
fvm flutter gen-l10n
```

4. Generate app icons (after pubspec changes):
```bash
fvm flutter pub run flutter_launcher_icons
```
