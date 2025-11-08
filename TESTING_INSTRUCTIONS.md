# Instructions de Test - Notifications de Téléchargement

## Prérequis

Avant de tester, assurez-vous que :
1. Flutter SDK est installé (version 3.8.1+)
2. Un appareil Android ou un émulateur est connecté
3. Les dépendances sont installées

## Installation

### Étape 1 : Installer les dépendances

```bash
cd /path/to/LandFlix
flutter pub get
```

### Étape 2 : Vérifier l'installation

```bash
flutter doctor
```

### Étape 3 : Compiler et lancer l'application

Pour Android :
```bash
flutter run -d android
```

Pour iOS (nécessite macOS) :
```bash
flutter run -d ios
```

## Tests à Effectuer

### Test 1 : Notification de Progression

**Objectif** : Vérifier que les notifications de progression s'affichent correctement

**Étapes** :
1. Ouvrir l'application LandFlix
2. Rechercher une vidéo
3. Lancer le téléchargement d'une vidéo
4. Minimiser l'application (appuyer sur le bouton Home)
5. Ouvrir le panneau de notifications

**Résultat attendu** :
- ✅ Une notification "Téléchargement" apparaît
- ✅ Le nom du fichier est affiché
- ✅ Une barre de progression est visible
- ✅ Le pourcentage s'affiche et se met à jour (ex: 23%, 45%, 67%)
- ✅ La notification ne peut pas être balayée (persistante)

### Test 2 : Notification de Succès

**Objectif** : Vérifier que la notification de succès apparaît à la fin du téléchargement

**Étapes** :
1. Continuer avec le téléchargement du Test 1
2. Attendre que le téléchargement se termine
3. Observer les notifications

**Résultat attendu** :
- ✅ La notification de progression disparaît
- ✅ Une nouvelle notification "Téléchargement terminé" apparaît
- ✅ Le message indique "Téléchargement de [nom_fichier] terminé avec succès"
- ✅ Un son de notification se fait entendre (Android)
- ✅ Le téléphone vibre brièvement (Android)
- ✅ La notification peut être balayée

### Test 3 : Notification d'Erreur

**Objectif** : Vérifier que les erreurs sont correctement notifiées

**Étapes** :
1. Désactiver le WiFi et les données mobiles
2. Lancer un nouveau téléchargement
3. Observer les notifications

**Résultat attendu** :
- ✅ Une notification "Téléchargement échoué" apparaît
- ✅ Un message d'erreur est affiché
- ✅ Un son de notification se fait entendre
- ✅ La notification peut être balayée

**Alternative** :
1. Lancer un téléchargement
2. Attendre quelques secondes
3. Activer le mode avion
4. Attendre que l'erreur se produise

### Test 4 : Annulation de Téléchargement

**Objectif** : Vérifier que les notifications sont supprimées lors de l'annulation

**Étapes** :
1. Lancer un téléchargement
2. Ouvrir le panneau de notifications pour voir la progression
3. Retourner dans l'application
4. Annuler le téléchargement en cours
5. Vérifier le panneau de notifications

**Résultat attendu** :
- ✅ La notification de progression disparaît immédiatement
- ✅ Aucune notification d'erreur n'apparaît

### Test 5 : Téléchargements Multiples

**Objectif** : Vérifier que plusieurs téléchargements ont chacun leur notification

**Étapes** :
1. Lancer 3 téléchargements différents successivement
2. Ouvrir le panneau de notifications

**Résultat attendu** :
- ✅ 3 notifications différentes sont visibles
- ✅ Chaque notification affiche le bon nom de fichier
- ✅ Chaque notification a sa propre barre de progression
- ✅ Les pourcentages sont différents pour chaque téléchargement

### Test 6 : Permissions (Android 13+)

**Objectif** : Vérifier que les permissions sont demandées correctement

**Étapes** :
1. Installer l'application pour la première fois sur Android 13 ou supérieur
2. Ouvrir l'application
3. Observer si une demande de permission apparaît

**Résultat attendu** :
- ✅ Une demande de permission pour les notifications apparaît
- ✅ Après acceptation, les notifications fonctionnent
- ✅ Après refus, l'application continue de fonctionner (sans notifications)

## Vérifications Supplémentaires

### Console de Débogage

Pendant les tests, surveillez les logs de l'application :

```bash
flutter logs
```

**Messages attendus** :
- `NotificationService initialisé avec succès`
- `FileDownloader configured: true`

**Aucune erreur ne devrait apparaître concernant** :
- `Erreur lors de l'initialisation du NotificationService`
- `Erreur lors de l'affichage de la notification`

### Permissions Système

#### Android
1. Ouvrir Paramètres > Applications > LandFlix > Notifications
2. Vérifier que "Téléchargements LandFlix" est activé

#### iOS
1. Ouvrir Réglages > Notifications > LandFlix
2. Vérifier que "Autoriser les notifications" est activé

## Problèmes Courants et Solutions

### ❌ Les notifications n'apparaissent pas

**Solutions** :
1. Vérifier que les permissions sont accordées dans les paramètres système
2. Vérifier les logs : `flutter logs | grep Notification`
3. Redémarrer l'application
4. Sur Android 13+, vérifier que la permission POST_NOTIFICATIONS est accordée

### ❌ Erreur "FlutterLocalNotificationsPlugin not initialized"

**Solution** :
```bash
flutter clean
flutter pub get
flutter run
```

### ❌ Les pourcentages ne se mettent pas à jour

**Solutions** :
1. Vérifier que le téléchargement progresse bien (dans l'app)
2. Vérifier les logs pour des erreurs de mise à jour
3. Essayer avec une vidéo différente (URL différente)

### ❌ Compilation échoue

**Solution** :
```bash
flutter clean
rm -rf build/
flutter pub get
flutter run
```

## Plateformes de Test Recommandées

### Priorité 1 : Android
- **Android 13+ (API 33+)** : Pour tester les permissions runtime
- **Android 10-12 (API 29-32)** : Pour tester sans permission runtime
- **Android 8+ (API 26+)** : Pour tester les canaux de notification

### Priorité 2 : iOS
- **iOS 14+** : Recommandé
- **iOS 12-13** : Pour compatibilité minimale

### Optionnel : macOS
- **macOS 10.14+** : Si disponible

## Rapport de Test

Après les tests, veuillez rapporter :

✅ Tests réussis :
- [ ] Test 1 : Notification de progression
- [ ] Test 2 : Notification de succès
- [ ] Test 3 : Notification d'erreur
- [ ] Test 4 : Annulation
- [ ] Test 5 : Téléchargements multiples
- [ ] Test 6 : Permissions

❌ Tests échoués : (décrire les problèmes)

📱 Environnement de test :
- Appareil : 
- Version OS : 
- Version Flutter : 

## Support

Pour toute question ou problème :
1. Consulter `NOTIFICATIONS_FEATURE.md` pour la documentation technique
2. Vérifier les logs avec `flutter logs`
3. Créer une issue GitHub avec les détails du problème

---

**Bonne chance avec les tests ! 🎉**
