# UQLoad Downloader Dart

Une bibliothèque Dart pour télécharger des vidéos depuis UQLoad.io, équivalente à la version Python.

## Fonctionnalités

- ✅ Téléchargement de vidéos UQLoad
- ✅ Récupération d'informations sur les vidéos (titre, résolution, durée, etc.)
- ✅ Barre de progression pour le téléchargement
- ✅ Support des callbacks de progression personnalisés
- ✅ Interface en ligne de commande
- ✅ Gestion robuste des erreurs
- ✅ Support Flutter-ready

## Installation

Ajoutez cette dépendance à votre `pubspec.yaml` :

```yaml
dependencies:
  uqload_downloader_dart: ^1.0.0
```

Ou installez-la directement avec :

```bash
dart pub add uqload_downloader_dart
```

## Usage

### Utilisation de base

```dart
import 'package:uqload_downloader_dart/uqload_downloader_dart.dart';

void main() async {
  final downloader = UQLoad(
    url: 'https://uqload.cx/embed-abc123def456.html',
    outputDir: '/chemin/vers/dossier', // optionnel
    outputFile: 'ma_video',           // optionnel
  );

  // Télécharger la vidéo
  await downloader.download();
}
```

### Avec callback de progression

```dart
import 'package:uqload_downloader_dart/uqload_downloader_dart.dart';

void main() async {
  // Créer une barre de progression
  ProgressBar? progressBar;
  
  void progressCallback(int downloaded, int total) {
    progressBar ??= ProgressBar(total: total);
    progressBar!.update(downloaded);
  }

  final downloader = UQLoad(
    url: 'https://uqload.cx/embed-abc123def456.html',
    onProgressCallback: progressCallback,
  );

  await downloader.download();
}
```

### Récupérer les informations de la vidéo

```dart
final downloader = UQLoad(url: 'https://uqload.cx/embed-abc123def456.html');
final info = await downloader.getVideoInfo();

print('Titre: ${info.title}');
print('Résolution: ${info.resolution}');
print('Durée: ${info.duration}');
print('Taille: ${sizeOfFmt(info.size)}');
```

### Interface en ligne de commande

```bash
# Télécharger une vidéo
dart run uqload_downloader_dart.dart -u "https://uqload.cx/embed-abc123def456.html"

# Avec nom de fichier personnalisé
dart run uqload_downloader_dart.dart -u "url" -o "ma_video" -d "/downloads"

# Afficher seulement les informations
dart run uqload_downloader_dart.dart -u "url" --info

# Aide
dart run uqload_downloader_dart.dart --help
```

## API

### Classe UQLoad

```dart
UQLoad({
  required String url,           // URL de la vidéo UQLoad
  String? outputFile,            // Nom de fichier de sortie (optionnel)
  String? outputDir,             // Dossier de sortie (optionnel)
  ProgressCallback? onProgressCallback, // Callback de progression (optionnel)
})
```

**Méthodes :**
- `Future<VideoInfo> getVideoInfo()` - Récupère les informations de la vidéo
- `Future<void> download()` - Télécharge la vidéo

### Classe VideoInfo

```dart
class VideoInfo {
  final String url;           // URL de téléchargement direct
  final String title;         // Titre de la vidéo
  final String imageUrl;      // URL de l'image de prévisualisation
  final String? resolution;   // Résolution (peut être null)
  final String? duration;     // Durée (peut être null)
  final int size;            // Taille du fichier en octets
  final String type;         // Type MIME
}
```

### Utilitaires

```dart
// Formater la taille d'un fichier
String sizeOfFmt(int bytes) // "1.5 MiB"

// Valider une URL UQLoad
bool isUqloadUrl(String url)

// Nettoyer les caractères spéciaux
String removeSpecialCharacters(String input)
```

## Utilisation avec Flutter

Cette bibliothèque est compatible Flutter. Exemple d'usage dans une application Flutter :

```dart
import 'package:flutter/material.dart';
import 'package:uqload_downloader_dart/uqload_downloader_dart.dart';

class VideoDownloader extends StatefulWidget {
  @override
  _VideoDownloaderState createState() => _VideoDownloaderState();
}

class _VideoDownloaderState extends State<VideoDownloader> {
  double _progress = 0.0;
  
  void _downloadVideo(String url) async {
    final downloader = UQLoad(
      url: url,
      onProgressCallback: (downloaded, total) {
        setState(() {
          _progress = downloaded / total;
        });
      },
    );
    
    await downloader.download();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(value: _progress),
        ElevatedButton(
          onPressed: () => _downloadVideo('https://uqload.cx/embed-abc123def456.html'),
          child: Text('Télécharger'),
        ),
      ],
    );
  }
}
```

## Tests

Exécuter les tests :

```bash
dart test
```

## Comparaison avec la version Python

Cette bibliothèque Dart offre les mêmes fonctionnalités que la version Python originale :

| Fonctionnalité | Python | Dart |
|----------------|--------|------|
| Téléchargement UQLoad | ✅ | ✅ |
| Informations vidéo | ✅ | ✅ |
| Barre de progression | ✅ | ✅ |
| Callbacks personnalisés | ✅ | ✅ |
| CLI | ✅ | ✅ |
| Tests unitaires | ✅ | ✅ |
| Gestion d'erreurs | ✅ | ✅ |

## Licence

MIT License - voir le fichier [LICENSE](LICENSE) pour plus de détails.
