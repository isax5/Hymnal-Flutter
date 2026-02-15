---
description: How to create a new screen following project architecture
---

## Project Architecture

This app uses Clean Architecture with GetIt for DI. Screens live under `lib/layers/screens/`.

```
lib/
├── constants/           # App-wide constants
├── services/            # Global services (locator, localization)
├── styles/              # Theme, fonts, sizes, assets
├── utils/               # Utility functions and mixins
├── widgets/             # Reusable UI components
└── layers/
    ├── data/            # Data sources, repositories, DTOs
    ├── domain/          # Use cases, models, business logic
    └── screens/         # UI screens and controllers
```

## Steps

1. Create a new directory under `lib/layers/screens/<screen_name>/`.

2. Create the screen file following this pattern:

```dart
// my_screen.dart
part 'my_controller.dart';

class MyScreen extends StatefulWidget with GetItStatefulWidgetMixin {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends MyController {
  @override
  Widget build(BuildContext context) {
    // UI implementation
  }
}
```

3. Create the controller file:

```dart
// my_controller.dart
part of 'my_screen.dart';

abstract class MyController extends ScreenBase<MyScreen> {
  // Business logic and state management
}
```

4. Register any new services in `lib/services/locator_service.dart`.

5. Use `const` constructors where possible and prefer `StatelessWidget` when state is not needed.

## Code Style

- **Files**: snake_case (`main_screen.dart`)
- **Classes**: PascalCase (`MainScreen`)
- **Variables/Methods**: camelCase (`userName`, `getUserData()`)
- **Private members**: Prefix with underscore (`_privateMethod`)

## Import Order

1. Flutter/Dart SDK imports
2. Package imports (sorted alphabetically)
3. Project imports (sorted by path depth)

## Error Handling

- Use `try-catch` blocks for async operations
- Log errors with `debugPrint()` in debug mode
- Use Either pattern with `dartz` for operations that can fail
- Use `flutter_secure_storage` for sensitive data
