# LandFlix

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-Private-red.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows%20%7C%20Linux-blue.svg)](https://flutter.dev)

A powerful cross-platform application for searching and downloading French streaming content. Built with Flutter for seamless performance across mobile, web, and desktop platforms.

## ✨ Features

- 🔍 **Smart Search**: Search for movies and series with intelligent query handling
- 📱 **Cross-Platform**: Runs on Android, iOS, Web, Windows, Linux, and macOS
- 🎬 **Video Management**: Browse and manage video content efficiently
- 💾 **Wishlist**: Save your favorite content for later viewing
- 🎨 **Modern UI**: Beautiful, responsive interface with Material Design 3
- 🌐 **Multi-Language Support**: Optimized for French content
- ⚡ **Fast Performance**: Built with efficient state management using BLoC pattern

## 📸 Screenshots

<!-- Add screenshots here when available -->
*Screenshots coming soon*

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: Version 3.8.1 or higher ([Installation Guide](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: Version 3.8.1 or higher (included with Flutter)
- **Git**: For version control
- **IDE**: VS Code or Android Studio with Flutter plugins

#### Platform-Specific Requirements

- **Android**: Android Studio, Android SDK (API level 21+)
- **iOS**: Xcode 14+ (macOS only)
- **Windows**: Visual Studio 2022 with C++ Desktop Development
- **Linux**: GTK+ 3.0 development libraries
- **macOS**: Xcode Command Line Tools

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Starland9/french_stream_downloader_mobile_app.git
   cd french_stream_downloader_mobile_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate launcher icons**
   ```bash
   dart pub global run flutter_launcher_icons:generate
   ```

4. **Generate router files** (if needed)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**
   ```bash
   # For mobile (Android/iOS)
   flutter run
   
   # For web
   flutter run -d chrome
   
   # For desktop
   flutter run -d windows  # or linux, macos
   ```

## 🏗️ Project Structure

```
lib/
├── main.dart                 # Application entry point
└── src/
    ├── app.dart             # Main app widget
    ├── core/                # Core functionality
    │   ├── routing/        # Auto-route navigation
    │   ├── themes/         # App themes and colors
    │   └── env/            # Environment configuration
    ├── logic/              # Business logic
    │   ├── cubits/        # State management (BLoC)
    │   ├── models/        # Data models
    │   ├── repos/         # Repository pattern
    │   └── services/      # API services
    └── screens/            # UI screens
        ├── home/          # Home/search screen
        ├── result/        # Search results
        ├── wishlist/      # Saved content
        └── splash/        # Splash screen
```

## 🛠️ Technology Stack

### Core Technologies
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language

### Key Packages
- **State Management**: `flutter_bloc` (9.1.1), `bloc` (9.0.0)
- **Navigation**: `auto_route` (10.1.0+1)
- **Network**: `dio` (5.8.0+1)
- **Storage**: `path_provider` (2.0.15)
- **UI/UX**: `google_fonts` (6.2.1), Material Design 3
- **Utilities**: `equatable` (2.0.7), `url_launcher` (6.3.1)

### Development Tools
- **Code Generation**: `auto_route_generator`, `lean_builder`
- **Linting**: `flutter_lints` (5.0.0)
- **Assets**: `flutter_launcher_icons`

## 💻 Development

### Code Generation

This project uses code generation for routing and other features:

```bash
# Watch for changes and auto-generate
dart run build_runner watch

# One-time generation
dart run build_runner build --delete-conflicting-outputs
```

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ipa --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release

# macOS
flutter build macos --release
```

## 🔧 Configuration

### App Icons

The app uses custom launcher icons. To regenerate them:

```bash
dart pub global run flutter_launcher_icons:generate
```

Icon configuration is in `flutter_launcher_icons.yaml`.

### Environment Variables

Configure your environment settings in `lib/src/core/env/env.dart`.

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (12.0+)
- ✅ Web (modern browsers)
- ✅ Windows (Windows 10+)
- ✅ Linux (GTK+ 3.0)
- ✅ macOS (10.14+)

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style

This project follows the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style). Use the provided linter:

```bash
flutter analyze
```

## 📄 License

This project is private and not published to pub.dev. All rights reserved.

## 👨‍💻 Author

**Starland9**
- GitHub: [@Starland9](https://github.com/Starland9)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- The open-source community for the excellent packages
- Contributors and testers

## 📞 Support

For support, please open an issue in the GitHub repository or contact the maintainers.

---

Made with ❤️ using Flutter
