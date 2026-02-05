# 🎮 Eğitim Oyun Platformu - MVP

AI destekli eğitim oyun platformu. Roblox, Scratch ve Duolingo'dan ilham alan, öğrencilerin oyunlar oluşturup paylaşabileceği bir mobil uygulama.

## 🚀 Özellikler

### ✅ Tamamlanan (Sprint 1-2)
- ✅ Firebase entegrasyonu (Auth, Firestore, Storage)
- ✅ Email/Password authentication
- ✅ Temiz Flutter proje mimarisi
- ✅ Model sınıfları (GameTemplate, User, etc.)
- ✅ Provider state management
- ✅ Gemini AI servisi
- ✅ Auth ekranları (Login, Register)
- ✅ Ana feed ekranı
- ✅ Profil ekranı
- ✅ Oyun oluşturma akışı (Subject → Topic → Generation)
- ✅ Oyun kartları ve görüntüleme

### 🔄 Devam Eden
- Flame game engine entegrasyonu
- Quiz Runner oyun şablonu
- Oyun oynatma ekranı

### 📅 Yakında
- Oyun beğeni ve yorum sistemi
- Kullanıcı profil detayları
- Firebase Security Rules
- Asset yönetimi

## 🛠️ Teknoloji Stack

- **Framework:** Flutter 3.9.2+
- **Game Engine:** Flame 1.35.0
- **Backend:** Firebase (Auth, Firestore, Storage)
- **AI:** Gemini API (google_generative_ai)
- **State Management:** Provider 6.1.5
- **Dil:** Dart

## 📁 Proje Yapısı

```
lib/
├── core/
│   ├── constants/     # Sabitler (Firebase, Game, App)
│   ├── theme/         # Tema ve renk tanımları
│   └── utils/         # Yardımcı fonksiyonlar
├── models/            # Veri modelleri
│   ├── game_template.dart
│   ├── user_model.dart
│   ├── game_metadata.dart
│   └── subject_topic.dart
├── services/          # Servis katmanı
│   ├── firebase/      # Firebase servisleri
│   ├── ai/            # Gemini AI servisi
│   └── game/          # Oyun factory
├── providers/         # State management
│   ├── auth_provider.dart
│   ├── game_provider.dart
│   └── feed_provider.dart
├── screens/           # UI ekranları
│   ├── auth/          # Login, Register
│   ├── home/          # Ana sayfa
│   ├── create/        # Oyun oluşturma
│   ├── play/          # Oyun oynatma
│   └── profile/       # Profil
├── widgets/           # Reusable widget'lar
├── game/              # Flame game bileşenleri
│   ├── components/    # Game component'leri
│   └── templates/     # Oyun şablonları
└── main.dart
```

## 🔧 Kurulum

### 1. Flutter Kurulumu
```bash
# Flutter SDK yüklü olmalı
flutter doctor
```

### 2. Proje Bağımlılıkları
```bash
cd egitim_oyun_platformu
flutter pub get
```

### 3. Firebase Yapılandırması

#### a) Firebase CLI Kurulumu
```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

#### b) Firebase Projesi Oluşturma
1. [Firebase Console](https://console.firebase.google.com/) adresine gidin
2. Yeni proje oluşturun: "egitim-oyun-platformu"
3. Authentication → Email/Password aktif edin
4. Firestore Database oluşturun (test mode)
5. Storage oluşturun

#### c) FlutterFire Yapılandırması
```bash
flutterfire configure
```

Bu komut `firebase_options.dart` dosyasını otomatik oluşturacak.

#### d) main.dart'da Firebase'i Aktif Etme
`lib/main.dart` dosyasındaki yorumları kaldırın:
```dart
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
```

### 4. Gemini API Anahtarı

#### a) API Key Alma
1. [Google AI Studio](https://makersuite.google.com/app/apikey) adresine gidin
2. API key oluşturun

#### b) Uygulamaya Ekleme
`lib/services/ai/gemini_service.dart` dosyasını düzenleyin:
```dart
static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
```

**ÖNEMLİ:** Production için `.env` dosyası kullanın!

### 5. Çalıştırma
```bash
# Android emulator veya cihaz
flutter run

# iOS simulator
flutter run -d ios

# Web
flutter run -d chrome
```

## 🎯 MVP Geliştirme Planı

### Sprint 1-2 ✅ (Tamamlandı)
- Temel altyapı
- Firebase kurulumu
- Authentication flow
- AI entegrasyonu

### Sprint 3-4 (Devam Ediyor)
- Flame game engine
- Quiz Runner şablonu
- Oyun oynatma

### Sprint 5-6 (Planlanan)
- Sosyal özellikler (like, comment)
- UI polish
- Testing
- Launch hazırlığı

## 📚 Kullanım

### Oyun Oluşturma Akışı

1. **Ders Seçimi**
   - Ana sayfada "Oyun Oluştur" butonuna tıklayın
   - Matematik, Fen, Türkçe, İngilizce, Sosyal Bilgiler

2. **Konu ve Ayarlar**
   - Konu seçin veya kendiniz yazın
   - Yaş grubu seçin (6-8, 9-11, 12-14, 15+)
   - Zorluk seviyesi seçin (Kolay, Orta, Zor)

3. **AI Üretimi**
   - "AI ile Oyun Oluştur" butonuna tıklayın
   - AI oyunu otomatik oluşturur (JSON formatında)

4. **Önizleme ve Kaydetme**
   - Oyun detaylarını inceleyin
   - "Kaydet ve Paylaş" ile feed'e ekleyin

### JSON Schema Örneği

```json
{
  "gameType": "quiz_runner",
  "subject": "Matematik",
  "topic": "Çarpım Tablosu",
  "title": "Uzay Çarpımı",
  "description": "Uzayda koşarak çarpım sorularını çöz!",
  "difficulty": "kolay",
  "config": {
    "duration": 60,
    "targetScore": 100,
    "speed": 1.0,
    "timeLimit": true
  },
  "entities": [
    {
      "id": "player1",
      "type": "player",
      "name": "Astronot Ali",
      "sprite": "astronaut_blue"
    }
  ],
  "questions": [
    {
      "id": "q1",
      "text": "3 x 4 = ?",
      "answers": [
        {"id": "a1", "text": "12"},
        {"id": "a2", "text": "7"},
        {"id": "a3", "text": "15"}
      ],
      "correctAnswerId": "a1",
      "points": 10
    }
  ],
  "aesthetics": {
    "theme": "space",
    "backgroundColor": "#0a0a2e",
    "primaryColor": "#00d9ff"
  }
}
```

## 🔒 Firebase Security Rules

Production öncesi Firestore ve Storage security rules ekleyin.

## 🐛 Bilinen Sorunlar

- Firebase initialization yorumda (manuel yapılandırma gerekli)
- Gemini API key hardcoded (production için environment variable kullanın)
- Oyun oynatma henüz implemente edilmedi
- Asset sprite'ları eksik (placeholder kullanılıyor)

## 📝 TODO

- [ ] Flame game engine tam entegrasyonu
- [ ] Quiz Runner oyun şablonu implementation
- [ ] Oyun play ekranı
- [ ] Like/Comment sistemi
- [ ] User profile detayları
- [ ] Firebase security rules
- [ ] Asset management
- [ ] Error handling iyileştirmeleri
- [ ] Loading state'leri
- [ ] Unit & Widget tests

## 🤝 Katkıda Bulunma

Bu MVP bir startup projesidir. Katkılarınız için pull request açabilirsiniz.

## 📄 Lisans

Bu proje özel bir projedir.

## 👥 Ekip

- **Senior Mobile Game Architect**
- **AI Integration Engineer**
- **Flutter Developer**

---

**Son Güncelleme:** 5 Şubat 2026  
**Versiyon:** 1.0.0-mvp  
**Platform:** Android, iOS, Web (Flutter)
