# LandFlix 🎬

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-Privée-red.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Plateformes-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows%20%7C%20Linux-blue.svg)](https://flutter.dev)

**Votre passerelle vers l'univers du streaming français**

LandFlix est une application multiplateforme moderne et puissante pour rechercher, découvrir et télécharger vos films et séries préférés. Développée avec Flutter, elle offre une expérience fluide et élégante sur mobile, web et bureau.

## ✨ Fonctionnalités

### 🎯 Principales Fonctionnalités
- 🔍 **Recherche Intelligente** : Recherchez vos films et séries avec un système de requêtes optimisé
- 📥 **Téléchargement Rapide** : Téléchargez vos contenus favoris avec le système UQLoad intégré
- 📁 **Gestionnaire de Téléchargements** : Interface dédiée pour gérer tous vos téléchargements
- 💾 **Liste Personnalisée** : Sauvegardez vos contenus préférés pour un visionnage ultérieur
- 🎨 **Interface Moderne** : Design élégant et réactif avec Material Design 3
- 📱 **Multiplateforme** : Compatible Android, iOS, Web, Windows, Linux et macOS
- ⚡ **Performance Optimale** : Architecture BLoC pour une gestion d'état efficace

### 🚀 Nouvelles Fonctionnalités v1.0+
- ✅ **Intégration UQLoad** : Téléchargement optimisé depuis UQLoad avec suivi de progression
- ✅ **Gestionnaire Complet** : Écran dédié pour visualiser et gérer tous vos téléchargements
- ✅ **Persistance Locale** : Sauvegarde automatique de l'historique avec SharedPreferences
- ✅ **Marquage Visuel** : Badges et indicateurs sur les médias déjà téléchargés
- ✅ **Gestion Automatique** : Vérification de l'intégrité des fichiers et nettoyage intelligent

## 📸 Captures d'Écran

<!-- Captures d'écran à ajouter -->
*Captures d'écran à venir*

## 🚀 Démarrage Rapide

### Prérequis

Avant de commencer, assurez-vous d'avoir installé :

- **Flutter SDK** : Version 3.8.1 ou supérieure ([Guide d'installation](https://docs.flutter.dev/get-started/install))
- **Dart SDK** : Version 3.8.1 ou supérieure (inclus avec Flutter)
- **Git** : Pour le contrôle de version
- **IDE** : VS Code ou Android Studio avec les plugins Flutter

#### Prérequis Spécifiques aux Plateformes

- **Android** : Android Studio, Android SDK (API niveau 21+)
- **iOS** : Xcode 14+ (macOS uniquement)
- **Windows** : Visual Studio 2022 avec outils de développement C++ pour le bureau
- **Linux** : Bibliothèques de développement GTK+ 3.0
- **macOS** : Xcode Command Line Tools

### Installation

1. **Cloner le dépôt**
   ```bash
   git clone https://github.com/Starland9/LandFlix.git
   cd LandFlix
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Configurer UQLoad Downloader** (si nécessaire)
   
   Le projet utilise `uqload_downloader_dart` en local. Si vous devez le configurer :
   ```yaml
   # Dans pubspec.yaml, ajustez le chemin si nécessaire
   uqload_downloader_dart:
     path: /chemin/vers/uqload_downloader_dart
   ```

4. **Générer les icônes de l'application**
   ```bash
   dart pub global run flutter_launcher_icons:generate
   ```

5. **Générer les fichiers de routage** (si nécessaire)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

6. **Lancer l'application**
   ```bash
   # Pour mobile (Android/iOS)
   flutter run
   
   # Pour le web
   flutter run -d chrome
   
   # Pour bureau
   flutter run -d windows  # ou linux, macos
   ```

## 🏗️ Structure du Projet

```
lib/
├── main.dart                 # Point d'entrée de l'application
└── src/
    ├── app.dart             # Widget principal de l'application
    ├── core/                # Fonctionnalités de base
    │   ├── routing/        # Navigation avec Auto-route
    │   ├── themes/         # Thèmes et couleurs de l'application
    │   ├── components/     # Composants réutilisables (badges, cartes, etc.)
    │   ├── env/            # Configuration d'environnement
    │   └── services/       # Services (UQLoad, Download Manager, etc.)
    ├── logic/              # Logique métier
    │   ├── cubits/        # Gestion d'état avec BLoC/Cubit
    │   ├── models/        # Modèles de données
    │   ├── repos/         # Pattern Repository
    │   └── services/      # Services API
    └── screens/            # Écrans de l'interface utilisateur
        ├── home/          # Écran d'accueil et recherche
        ├── result/        # Résultats de recherche
        ├── downloads/     # Gestionnaire de téléchargements
        ├── wishlist/      # Liste de contenus sauvegardés
        └── splash/        # Écran de démarrage
```

### 📁 Fichiers Importants

#### Gestionnaire de Téléchargements
- `lib/src/core/services/download_manager.dart` - Service principal de gestion des téléchargements
- `lib/src/screens/downloads/downloads_screen.dart` - Interface du gestionnaire
- `lib/src/core/components/downloaded_badge.dart` - Badges visuels pour les médias téléchargés

#### Intégration UQLoad
- `lib/src/core/services/uqload_download_service.dart` - Service de téléchargement UQLoad
- `lib/src/logic/cubits/download/` - Gestion d'état des téléchargements

### 📄 Documentation Complémentaire

Pour plus de détails sur les fonctionnalités spécifiques :
- 📥 [DOWNLOAD_MANAGER.md](DOWNLOAD_MANAGER.md) - Documentation du gestionnaire de téléchargements
- 🚀 [UQLOAD_INTEGRATION.md](UQLOAD_INTEGRATION.md) - Intégration UQLoad Downloader
- 🎨 [UI_UX_IMPROVEMENTS.md](UI_UX_IMPROVEMENTS.md) - Améliorations de l'interface utilisateur

## 🛠️ Stack Technologique

### Technologies Principales
- **Flutter** : Framework d'interface utilisateur multiplateforme
- **Dart** : Langage de programmation (version 3.8.1+)

### Packages Clés
- **Gestion d'État** : `flutter_bloc` (9.1.1), `bloc` (9.0.0)
- **Navigation** : `auto_route` (10.1.0+1)
- **Réseau** : `dio` (5.8.0+1)
- **Stockage** : `shared_preferences` (2.3.2), `path_provider` (2.0.15)
- **Téléchargement** : `uqload_downloader_dart` (intégration locale)
- **Interface** : `google_fonts` (6.2.1), `shimmer` (3.0.0), Material Design 3
- **Utilitaires** : `equatable` (2.0.7), `url_launcher` (6.3.1)

### Outils de Développement
- **Génération de Code** : `auto_route_generator`, `lean_builder`
- **Linting** : `flutter_lints` (5.0.0)
- **Assets** : `flutter_launcher_icons`

## 💻 Développement

### Génération de Code

Ce projet utilise la génération de code pour le routage et d'autres fonctionnalités :

```bash
# Observer les changements et générer automatiquement
dart run build_runner watch

# Génération ponctuelle
dart run build_runner build --delete-conflicting-outputs
```

### Initialisation des Services

Le gestionnaire de téléchargements doit être initialisé au démarrage de l'application :

```dart
// Dans main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation obligatoire du gestionnaire de téléchargements
  await DownloadManager.instance.initialize();
  
  runApp(MyApp());
}
```

### Exécution des Tests

```bash
# Exécuter tous les tests
flutter test

# Exécuter avec couverture
flutter test --coverage
```

### Analyse du Code

```bash
# Analyser le code avec le linter
flutter analyze

# Formater le code
flutter format .
```

### Construction pour la Production

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

### Icônes de l'Application

L'application utilise des icônes de lancement personnalisées. Pour les régénérer :

```bash
dart pub global run flutter_launcher_icons:generate
```

La configuration des icônes se trouve dans `flutter_launcher_icons.yaml`.

### Variables d'Environnement

Configurez vos paramètres d'environnement dans `lib/src/core/env/env.dart`.

### Configuration UQLoad

Le téléchargeur UQLoad est configuré pour gérer automatiquement :
- 📁 **Dossiers de téléchargement** : Créés automatiquement selon la plateforme
- 📊 **Suivi de progression** : Mise à jour en temps réel
- 💾 **Persistance** : Sauvegarde automatique de l'historique
- 🏷️ **Marquage visuel** : Badges sur les médias téléchargés

Pour plus de détails, consultez [UQLOAD_INTEGRATION.md](UQLOAD_INTEGRATION.md).

### Gestion des Téléchargements

Le gestionnaire de téléchargements utilise `SharedPreferences` pour la persistance :
- Historique complet des téléchargements
- Vérification de l'intégrité des fichiers
- Nettoyage automatique des fichiers supprimés
- Statistiques en temps réel

Pour plus de détails, consultez [DOWNLOAD_MANAGER.md](DOWNLOAD_MANAGER.md).

## 📱 Plateformes Supportées

- ✅ **Android** (API 21+)
- ✅ **iOS** (12.0+)
- ✅ **Web** (navigateurs modernes)
- ✅ **Windows** (Windows 10+)
- ✅ **Linux** (GTK+ 3.0)
- ✅ **macOS** (10.14+)

## 🎯 Fonctionnalités Avancées

### 📥 Système de Téléchargement

LandFlix intègre un système de téléchargement avancé avec :

- **Téléchargement UQLoad** : Intégration complète avec UQLoad Downloader
- **Suivi en temps réel** : Progression et statut des téléchargements
- **Gestion intelligente** : Organisation automatique des fichiers
- **Interface dédiée** : Écran de gestion des téléchargements avec statistiques
- **Persistance** : Sauvegarde automatique de l'historique
- **Marquage visuel** : Badges sur les médias déjà téléchargés

### 💾 Gestionnaire de Téléchargements

Accédez à tous vos téléchargements depuis le 3ᵉ onglet de la navigation :

- 📊 **Statistiques** : Nombre total et espace utilisé
- 🎬 **Aperçu** : Miniatures et informations détaillées
- 📂 **Ouverture** : Lecture directe avec le lecteur système
- 🗑️ **Gestion** : Suppression individuelle ou nettoyage groupé
- ✅ **Vérification** : Contrôle automatique de l'intégrité des fichiers

### 🎨 Interface Utilisateur Moderne

- **Material Design 3** : Design moderne et élégant
- **Animations fluides** : Transitions et effets visuels
- **Mode sombre** : Interface optimisée pour un confort visuel
- **Responsive** : Adaptation automatique à tous les écrans
- **Accessibilité** : Support complet des fonctionnalités d'accessibilité

## 🤝 Contribution

Les contributions sont les bienvenues ! Veuillez suivre ces étapes :

1. Forkez le dépôt
2. Créez une branche de fonctionnalité (`git checkout -b feature/NouvelleFonctionnalite`)
3. Commitez vos changements (`git commit -m 'Ajout d'une nouvelle fonctionnalité'`)
4. Poussez vers la branche (`git push origin feature/NouvelleFonctionnalite`)
5. Ouvrez une Pull Request

### Style de Code

Ce projet suit le [guide de style officiel Dart](https://dart.dev/guides/language/effective-dart/style). Utilisez le linter fourni :

```bash
flutter analyze
```

## 📄 Licence

Ce projet est privé et n'est pas publié sur pub.dev. Tous droits réservés.

## 👨‍💻 Auteur

**Starland9**
- GitHub : [@Starland9](https://github.com/Starland9)

## 🙏 Remerciements

- L'équipe Flutter pour leur incroyable framework
- La communauté open-source pour les excellents packages
- Les contributeurs et testeurs

## 📞 Support

Pour obtenir de l'aide, veuillez ouvrir une issue dans le dépôt GitHub ou contacter les mainteneurs.

## 🌐 Liens Utiles

- 🎬 [Page d'accueil LandFlix](landing/index.html) - Landing page marketing
- 📥 [Documentation Download Manager](DOWNLOAD_MANAGER.md) - Gestionnaire de téléchargements
- 🚀 [Documentation UQLoad](UQLOAD_INTEGRATION.md) - Intégration UQLoad
- 🎨 [Améliorations UI/UX](UI_UX_IMPROVEMENTS.md) - Améliorations de l'interface

---

Fait avec ❤️ en utilisant Flutter | **LandFlix v1.0+** ✨
