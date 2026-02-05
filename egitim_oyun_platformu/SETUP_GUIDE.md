# 🚀 Kurulum Rehberi

Bu rehber, **Eğitim Oyun Platformu** MVP projesini sıfırdan çalıştırmanız için adım adım talimatlar içerir.

## ✅ Ön Gereksinimler

### 1. Geliştirme Ortamı

- **Flutter SDK:** 3.9.2 veya üzeri
- **Dart SDK:** (Flutter ile birlikte gelir)
- **VS Code** veya **Android Studio**
- **Git:** Versiyon kontrolü için

### 2. Platform Gereksinimleri

#### Android Geliştirme
- Android Studio
- Android SDK (API 21+)
- Android Emulator veya fiziksel cihaz

#### iOS Geliştirme (Mac gerekli)
- Xcode 14+
- CocoaPods
- iOS Simulator veya fiziksel cihaz

#### Web Geliştirme
- Chrome tarayıcı

## 📥 Kurulum Adımları

### Adım 1: Flutter Kurulumu ve Doğrulama

```bash
# Flutter SDK'nın kurulu olup olmadığını kontrol edin
flutter --version

# Sistem kontrolü yapın
flutter doctor

# Eksik bileşenleri kurun
# flutter doctor çıktısındaki talimatları takip edin
```

**Beklenen Çıktı:**
```
Flutter 3.9.2 • Dart 3.9.2
✓ Flutter
✓ Android toolchain
✓ Chrome - develop for the web
✓ VS Code
```

### Adım 2: Proje Bağımlılıklarını İndirin

```bash
# Proje dizinine gidin
cd egitim_oyun_platformu

# Bağımlılıkları yükleyin
flutter pub get
```

**Yüklenen Ana Paketler:**
- flame: 1.35.0 (Oyun motoru)
- firebase_core: 4.4.0
- firebase_auth: 6.1.4
- cloud_firestore: 6.1.2
- firebase_storage: 13.0.6
- provider: 6.1.5+1
- google_generative_ai: 0.4.7

### Adım 3: Firebase Kurulumu

#### 3.1. Firebase CLI Kurulumu

```bash
# Node.js yüklü olmalı (https://nodejs.org/)
npm install -g firebase-tools

# Firebase'e giriş yapın
firebase login

# FlutterFire CLI'yi yükleyin
dart pub global activate flutterfire_cli

# PATH'e eklendiğinden emin olun
export PATH="$PATH":"$HOME/.pub-cache/bin"  # macOS/Linux
# veya Windows için manuel PATH ekleme
```

#### 3.2. Firebase Projesi Oluşturma

1. [Firebase Console](https://console.firebase.google.com/) adresine gidin
2. **"Add project"** butonuna tıklayın
3. Proje adı: `egitim-oyun-platformu`
4. Google Analytics'i aktif edin (opsiyonel)
5. Projeyi oluşturun

#### 3.3. Firebase Authentication Kurulumu

1. Firebase Console → **Authentication**
2. **"Get Started"** butonuna tıklayın
3. **Sign-in method** sekmesine gidin
4. **Email/Password** seçeneğini aktif edin
5. **Save** butonuna tıklayın

#### 3.4. Firestore Database Kurulumu

1. Firebase Console → **Firestore Database**
2. **"Create database"** butonuna tıklayın
3. **Test mode** seçin (geliştirme için)
4. Lokasyon seçin (eur3 - Europe West önerilen)
5. **Enable** butonuna tıklayın

#### 3.5. Firebase Storage Kurulumu

1. Firebase Console → **Storage**
2. **"Get started"** butonuna tıklayın
3. **Test mode** seçin
4. Lokasyon seçin (Firestore ile aynı)
5. **Done** butonuna tıklayın

#### 3.6. Flutter Projesine Firebase Entegrasyonu

```bash
# Proje dizininde çalıştırın
flutterfire configure

# Soruları yanıtlayın:
# ? Select a Firebase project: egitim-oyun-platformu
# ? Which platforms should your configuration support? android, ios, web
```

**Bu komut şunları yapacak:**
- `firebase_options.dart` dosyasını oluşturur
- Android için `google-services.json` ekler
- iOS için `GoogleService-Info.plist` ekler

#### 3.7. main.dart'da Firebase'i Aktif Etme

`lib/main.dart` dosyasını açın ve şu satırların yorumunu kaldırın:

```dart
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Bu satırların yorumunu kaldırın ↓
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
```

### Adım 4: Gemini API Kurulumu

#### 4.1. API Key Alma

1. [Google AI Studio](https://makersuite.google.com/app/apikey) adresine gidin
2. Google hesabınızla giriş yapın
3. **"Create API Key"** butonuna tıklayın
4. **"Create API key in new project"** seçin
5. API key'i kopyalayın

#### 4.2. API Key'i Uygulamaya Ekleme

`lib/services/ai/gemini_service.dart` dosyasını açın:

```dart
class GeminiService {
  // Bu satırı değiştirin:
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
  
  // Kendi API key'inizi yapıştırın:
  static const String _apiKey = 'AIzaSy...'; // Kendi key'iniz
```

**⚠️ GÜVENLİK UYARISI:**
Production ortamı için API key'i kodda saklamayın!

**Doğru Yöntem (Production):**
```bash
# .env dosyası oluşturun (proje kök dizininde)
GEMINI_API_KEY=AIzaSy...

# .gitignore'a ekleyin
.env

# flutter_dotenv paketi ekleyin
flutter pub add flutter_dotenv
```

### Adım 5: Firebase Security Rules (Opsiyonel - Test İçin)

Firebase Console'dan geçici olarak test mode'da çalışabilirsiniz. Production için:

**Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /games/{gameId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.creatorId;
    }
    match /gamePlays/{playId} {
      allow read, write: if request.auth != null;
    }
    match /likes/{likeId} {
      allow read: if true;
      allow create, delete: if request.auth != null;
    }
    match /comments/{commentId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow delete: if request.auth.uid == resource.data.userId;
    }
  }
}
```

### Adım 6: Projeyi Çalıştırma

```bash
# Analiz çalıştırın (hataları kontrol edin)
flutter analyze

# Testleri çalıştırın (opsiyonel)
flutter test

# Android emulator'de çalıştırın
flutter run

# iOS simulator'de çalıştırın (Mac)
flutter run -d ios

# Web'de çalıştırın
flutter run -d chrome

# Belirli bir cihazda çalıştırın
flutter devices  # Kullanılabilir cihazları listeler
flutter run -d <device-id>
```

### Adım 7: İlk Çalıştırma

1. **Uygulama açılır** → Login ekranı görünür
2. **"Kayıt Ol"** linkine tıklayın
3. Test kullanıcısı oluşturun:
   - Ad: Test Kullanıcı
   - Email: test@example.com
   - Şifre: test123
4. **Ana sayfa açılır** → Feed boş görünür
5. **"Oyun Oluştur"** butonuna tıklayın
6. Ders seçin (örn: Matematik)
7. Konu seçin (örn: Çarpım Tablosu)
8. Yaş grubu ve zorluk seçin
9. **"AI ile Oyun Oluştur"** → Sample oyun oluşturulur
10. **"Kaydet ve Paylaş"** → Oyun feed'e eklenir

## 🔧 Troubleshooting

### Problem 1: Flutter doctor hatası

```bash
# Android SDK yolu bulunamıyor
flutter config --android-sdk /path/to/android/sdk

# Lisansları kabul edin
flutter doctor --android-licenses
```

### Problem 2: Firebase initialization hatası

```bash
# flutterfire yeniden yapılandırın
flutterfire configure --force
```

### Problem 3: Pod install hatası (iOS)

```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
```

### Problem 4: Build hatası

```bash
# Temizlik yapın
flutter clean

# Pub cache'i temizleyin
flutter pub cache repair

# Yeniden build
flutter pub get
flutter run
```

### Problem 5: Gemini API hatası

- API key'in doğru olduğundan emin olun
- [Google AI Studio](https://makersuite.google.com/app/apikey) üzerinden key'in aktif olduğunu kontrol edin
- API kotalarınızı kontrol edin

## 📱 Platform-Specific Setup

### Android

**AndroidManifest.xml** (otomatik eklenir):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

**build.gradle** (app level):
```gradle
minSdkVersion 21
targetSdkVersion 34
```

### iOS

**Info.plist** (gerekirse ekleyin):
```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

### Web

**web/index.html** (Firebase için otomatik eklenir):
```html
<script src="https://www.gstatic.com/firebasejs/..."></script>
```

## ✅ Kurulum Tamamlandı!

Artık uygulamanız çalışır durumda. Geliştirmeye devam etmek için:

1. [README.md](README.md) dosyasını okuyun
2. Proje yapısını inceleyin
3. Sprint 3-4 özelliklerini geliştirmeye başlayın

## 🆘 Yardım

Sorun yaşıyorsanız:
- GitHub Issues'da bildirin
- Ekip ile iletişime geçin
- Flutter dokümantasyonunu kontrol edin: https://docs.flutter.dev

---

**Güncelleme:** 5 Şubat 2026
