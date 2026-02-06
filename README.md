# Hymnal App

A multi-language hymnal app supporting Spanish, English, Russian and Portuguese. Built with Flutter using Clean Architecture.

## Features

- **Multiple Hymnals**: Support for different language versions
  - English (1985 & 1941 versions)
  - Spanish (2009 & 1962 versions)
  - Portuguese (1996 version)
  - Russian (1997 version)

- **Home Screen**: Enter hymn number to open directly
- **Search**: Find hymns by title, lyrics, or number
- **History**: View last 50 opened hymns
- **Lists**: Browse hymns by number, alphabetically, or by theme
- **Favorites**: Save and reorder favorite hymns
- **Audio Playback**: Listen to instrumental and/or sung versions
- **Sheet Music**: View piano sheet music for hymns
- **Customization**: Font size, theme mode, background image toggle
- **Internationalization**: Supports EN, ES, PT, RU

## Architecture

This app follows Clean Architecture with the following layers:

```
lib/
├── constants/          # App-wide constants
├── services/           # Global services (DI, audio, settings)
├── styles/             # Theme, fonts
├── widgets/            # Reusable UI components
└── layers/             # Clean architecture layers
    ├── data/           # Repositories and data sources
    ├── domain/         # Models
    └── screens/        # UI screens
```

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK

### Installation

1. Clone the repository:
```bash
git clone https://github.com/isax5/Hymnal-Xamarin.git
cd Hymnal-Xamarin
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Build for Release

**Android:**
```bash
flutter build apk --release
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## Dependencies

- `get_it` & `get_it_mixin`: Dependency injection
- `just_audio` & `just_audio_background`: Audio playback with background support
- `shared_preferences`: Local storage
- `flutter_svg`: SVG support
- `photo_view`: Zoomable images for sheet music
- `share_plus`: Share functionality
- `url_launcher`: Open URLs

## Contributing

Contributions are welcome! Please visit our [GitHub Repository](https://github.com/isax5/Hymnal-Xamarin) for more information.

## License

This project is open source. See the repository for license details.

## Links

- Website: https://isax5.github.io/hymnal/
- App Store: https://apps.apple.com/cl/app/adventist-hymnal/id1153114394
- Play Store: https://play.google.com/store/apps/details?id=net.ddns.HimnarioAdventistaSPA
