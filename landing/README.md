# LandFlix Landing Page

## Structure du Projet

```
landing/
├── index.html              # Page principale
├── css/
│   ├── main.css            # Styles principaux et système de design
│   └── sections.css        # Styles spécifiques aux sections
├── js/
│   └── main.js            # JavaScript principal
└── assets/
    └── favicon.ico        # Icône du site
```

## Fonctionnalités

### Design Moderne
- Interface sombre élégante avec dégradés violets
- Animations fluides et effets de hover
- Design responsive pour tous les appareils
- Thème cohérent avec l'application Flutter

### Sections
1. **Header Navigation** - Menu fixe avec logo animé
2. **Hero Section** - Présentation principale avec call-to-action
3. **Features** - Fonctionnalités clés de l'application
4. **Screenshots** - Aperçu visuel de l'interface
5. **Downloads** - Boutons de téléchargement multi-plateformes
6. **Footer** - Liens et informations supplémentaires

### Interactions JavaScript
- Navigation smooth scroll
- Menu mobile responsive
- Animations au scroll (Intersection Observer)
- Carrousel automatique des captures d'écran
- Modales de téléchargement
- Éléments flottants animés

### Optimisations
- Performance optimisée avec debouncing
- Lazy loading des animations
- Design system CSS avec variables
- Code modulaire et réutilisable

## Personnalisation

### Couleurs
Les couleurs sont définies dans `css/main.css` avec des variables CSS :
- `--primary-purple` : Couleur principale
- `--secondary-blue` : Couleur secondaire
- `--dark-background` : Arrière-plan sombre
- `--text-primary` : Texte principal

### Liens de Téléchargement
Modifier les liens dans `js/main.js` dans la méthode `handleDownload()` pour pointer vers les vrais liens de téléchargement.

### Analytics
Ajouter Google Analytics ou autres services de tracking dans `trackDownload()`.

## Déploiement

1. Uploader tous les fichiers sur un serveur web
2. Configurer les liens de téléchargement réels
3. Ajouter un certificat SSL pour HTTPS
4. Optimiser les images et assets pour la production

## Technologies Utilisées

- HTML5 sémantique
- CSS3 avec variables et Grid/Flexbox
- JavaScript ES6+ avec classes
- Font Awesome pour les icônes
- Google Fonts (Outfit)
- Intersection Observer API
- CSS Animations et Transitions