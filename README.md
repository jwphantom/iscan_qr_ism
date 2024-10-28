# iScan QR - Application de Scan QR Sécurisée

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Framework](https://img.shields.io/badge/framework-Flutter-blue.svg)
![Licence](https://img.shields.io/badge/license-MIT-green.svg)

## 📝 Description

iScan QR est une application mobile développée avec Flutter pour scanner les codes QR des établissements. L'application se distingue par sa sécurité renforcée, utilisant le chiffrement Fernet pour la transmission des données vers le serveur.

## ✨ Fonctionnalités Principales

- **Scan QR Code**: Interface intuitive pour scanner les codes QR
- **Cryptage Fernet**: Sécurisation des données avant transmission
- **Mode Double Caméra**: Support des caméras avant et arrière
- **Gestion de Flash**: Contrôle de la lampe torche pour la caméra arrière
- **Anti-veille**: Maintien de l'écran actif pendant le scan
- **Feedback Visuel**: Animations et indications visuelles lors du scan
- **Cache Management**: Stockage local sécurisé des badges scannés

## 🏗️ Architecture du Projet

```
lib/
├── controllers/
│   └── qr_controller.dart
├── helpers/
│   └── ...
├── model/
│   └── ...
├── screens/
│   ├── qr_view_screen.dart
│   └── ...
├── services/
│   ├── audio_service.dart
│   ├── camera_service.dart
│   ├── screen_timer_service.dart
│   └── ...
└── widget/
    └── qr/
        └── qr_result_widget.dart
```

## 🚀 Installation

1. **Prérequis**

   ```bash
   # Assurez-vous d'avoir Flutter installé
   flutter doctor
   ```

2. **Cloner le projet**

   ```bash
   git clone https://github.com/votre-username/iscan_qr.git
   cd iscan_qr
   ```

3. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

## 🔧 Configuration

1. Créez un fichier `.env` à la racine du projet :

   ```env
   SERVER_URL=votre_url_serveur
   FERNET_KEY=votre_clé_fernet
   ```

2. Configuration Android (`android/app/build.gradle`) :
   ```gradle
   android {
       ...
       defaultConfig {
           ...
           minSdkVersion 21
           targetSdkVersion 33
       }
   }
   ```

## 📱 Permissions Requises

### Android

Dans `android/app/src/main/AndroidManifest.xml` :

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

### iOS

Dans `ios/Runner/Info.plist` :

```xml
<key>NSCameraUsageDescription</key>
<string>Cette application nécessite l'accès à la caméra pour scanner les codes QR</string>
```

## 💻 Utilisation

```dart
// Exemple d'utilisation du QRController
final qrController = QRController(
  verificationService: QRVerificationService(),
  storageService: BadgeStorageService(),
  onResultReceived: (result) {
    // Traitement du résultat
  },
);
```

## 🧪 Tests

```bash
# Exécuter les tests unitaires
flutter test

# Exécuter les tests d'intégration
flutter drive --target=test_driver/app.dart
```

## 🔐 Sécurité

- Chiffrement Fernet pour la transmission des données
- Validation des QR codes avant traitement
- Stockage sécurisé des données locales
- Nettoyage automatique du cache après utilisation

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Forkez le projet
2. Créez votre branche (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add AmazingFeature'`)
4. Poussez vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📦 Dépendances Principales

- `qr_code_scanner: ^1.0.1`
- `wakelock_plus: ^1.2.8`
- `shared_preferences: ^2.0.0`
- `path_provider: ^2.1.4`
- `audioplayers: ^6.1.0`

## 🐛 Problèmes Connus

- Le flash peut ne pas fonctionner sur certains appareils Android
- La caméra frontale peut avoir des problèmes de mise au point sur certains appareils

## 📝 Licence

Ce projet est sous licence MIT.

## 👥 Auteurs et Contact

Pour toute question ou suggestion, contactez :

- Email : jawill.olongo@gmail.com
- GitHub : [votre-username](https://github.com/jwphantom)

---

⌨️ Développé avec ❤️ par James Olongo
