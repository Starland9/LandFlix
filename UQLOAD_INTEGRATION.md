# 🚀 Intégration UQLoad Downloader - LandFlix

## 📱 Nouveau Système de Téléchargement

Le projet LandFlix intègre maintenant **UQLoad Downloader Dart**, une bibliothèque moderne pour télécharger des vidéos depuis UQLoad.io avec suivi de progression et gestion d'erreurs avancée.

## 🎯 Workflow Utilisateur

```
1. 🔍 Recherche → Page des résultats
2. 🎬 Choix film/série → Page des vidéos disponibles
3. ⬇️ Clic bouton téléchargement → Téléchargement UQLoad
```

## 🏗️ Architecture

### 📁 Fichiers Ajoutés

```
lib/src/
├── core/services/
│   └── uqload_download_service.dart    # Service UQLoad principal
└── logic/cubits/download/
    ├── download_cubit.dart             # Cubit de gestion des téléchargements
    └── download_state.dart             # États de téléchargement
```

### 🔄 Fichiers Modifiés

```
lib/src/screens/result/components/
└── uqvideo_widget.dart                 # Widget intégrant UQLoad
```

## 🛠️ Fonctionnalités

### ✨ Service UQLoad (`uqload_download_service.dart`)
- ✅ **Téléchargement UQLoad** avec suivi de progression
- ✅ **Validation d'URL** UQLoad automatique
- ✅ **Gestion des dossiers** multi-plateformes (Android/iOS/Desktop)
- ✅ **Nettoyage automatique** des noms de fichiers
- ✅ **Récupération d'informations** vidéo avant téléchargement
- ✅ **Formatage intelligent** de la taille des fichiers

### 🎛️ Cubit de Téléchargement (`download_cubit.dart`)
- ✅ **États complets** : Initial, Preparing, Prepared, InProgress, Completed, Cancelled, Error
- ✅ **Progression en temps réel** avec pourcentage et messages
- ✅ **Annulation de téléchargement** propre
- ✅ **Gestion d'erreurs** robuste
- ✅ **Reset d'état** pour réutilisation

### 🎨 Widget UQVideo Modernisé (`uqvideo_widget.dart`)
- ✅ **Interface Bloc/Cubit** avec BlocProvider et BlocListener
- ✅ **Barre de progression** animée en temps réel
- ✅ **Messages de statut** dynamiques
- ✅ **Boutons contextuels** (Télécharger/Annuler)
- ✅ **Toasts modernes** pour le feedback utilisateur
- ✅ **Validation d'URL** avant téléchargement

## 📋 États de Téléchargement

```dart
sealed class DownloadState extends Equatable {
  DownloadInitial()           // État de base
  DownloadPreparing()         // Récupération des infos
  DownloadPrepared(details)   // Prêt à télécharger
  DownloadInProgress(%, msg)  // Téléchargement en cours
  DownloadCompleted(path)     // Téléchargement terminé
  DownloadCancelled()         // Téléchargement annulé
  DownloadError(message)      // Erreur rencontrée
}
```

## 🎯 Utilisation dans l'App

### 1. Le Widget UQVideo
```dart
// Le widget détecte automatiquement les URLs UQLoad
UqvideoWidget(uqvideo: videoInstance)

// Workflow:
// 1. Utilisateur clique sur bouton téléchargement
// 2. Validation de l'URL htmlUrl du modèle Uqvideo
// 3. Lancement du téléchargement via DownloadCubit
// 4. Suivi en temps réel avec BlocBuilder
// 5. Feedback visuel avec toasts et progression
```

### 2. Intégration BLoC
```dart
BlocProvider<DownloadCubit>(
  create: (context) => DownloadCubit(),
  child: BlocListener<DownloadCubit, DownloadState>(
    listener: (context, state) {
      // Gestion des états avec toasts automatiques
      if (state is DownloadCompleted) {
        ModernToast.show("✅ Téléchargement terminé !");
      }
      // ...
    },
    child: BlocBuilder<DownloadCubit, DownloadState>(
      builder: (context, state) {
        // UI réactive selon l'état
        if (state is DownloadInProgress) {
          return ProgressBar(value: state.progress);
        }
        // ...
      },
    ),
  ),
)
```

## 📁 Gestion des Dossiers

### 🤖 Android
```
/storage/emulated/0/Download/LandFlix/
```

### 🍎 iOS
```
/var/mobile/Containers/Data/Application/[ID]/Documents/Downloads/
```

### 💻 Desktop (Windows/macOS/Linux)
```
~/Downloads/LandFlix/  (ou ~/Documents/Downloads/ en fallback)
```

## 🔧 Configuration

### Dependencies Required
```yaml
dependencies:
  uqload_downloader_dart:
    path: /path/to/uqload_downloader_dart
  flutter_bloc: ^9.1.1
  path_provider: ^2.0.15
```

## 🎯 Points Clés d'Intégration

1. **URL Mapping** : `uqvideo.htmlUrl` → UQLoad URL
2. **State Management** : Utilisation complète de BLoC pattern
3. **UI Reactive** : Interface qui s'adapte aux états
4. **Error Handling** : Gestion complète des erreurs
5. **Progress Tracking** : Suivi en temps réel avec pourcentages
6. **File Management** : Gestion automatique des dossiers et noms

## 🚀 Avantages

- ✅ **Performance** : Téléchargements optimisés avec UQLoad
- ✅ **UX Moderne** : Interface réactive et feedback visuel
- ✅ **Robustesse** : Gestion d'erreurs et validation complètes
- ✅ **Maintenabilité** : Architecture BLoC claire et modulaire
- ✅ **Cross-Platform** : Fonctionne sur toutes les plateformes Flutter

## 🔮 Prochaines Étapes

- [ ] Tests unitaires pour le service UQLoad
- [ ] Gestion des téléchargements multiples simultanés
- [ ] Historique des téléchargements
- [ ] Gestion de la pause/reprise
- [ ] Notifications système pour les téléchargements

---
*Intégration réalisée avec succès dans LandFlix v1.0+* ✨