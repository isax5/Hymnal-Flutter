---
description: How to run tests for the Hymnal app
---

## Steps

// turbo
1. Run all tests:
```bash
fvm flutter test
```

2. Run a specific test file:
```bash
fvm flutter test test/widget_test.dart
```

3. Run tests with coverage:
```bash
fvm flutter test --coverage
```

## Test Structure

- Unit tests: `test/unit/` (not yet created)
- Widget tests: `test/widget_test.dart`
- Integration tests: `integration_test/` (not yet created)

## Test Setup

Always initialize the service locator in test `setUp()`:

```dart
setUp(() {
  setupLocator();
});
```
