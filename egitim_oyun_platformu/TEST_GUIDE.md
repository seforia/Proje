# 🧪 Test Rehberi - Eğitim Oyun Platformu MVP

Bu rehber, uygulamayı Firebase olmadan **TEST MODU**nda test etmek için adımları içerir.

## 🚀 Hızlı Başlangıç (1 dakika)

```bash
# 1. Terminalde
cd c:\Proje\egitim_oyun_platformu

# 2. Bağımlılıkları yükle
flutter pub get

# 3. Çalıştır
flutter run

# 4. Android Emulator veya iOS Simulator seçilir
# Otomatik olarak başlar
```

## 🧪 Test Senaryosu

### 1️⃣ Login Ekranı
**Ekran:** Eğitim Oyun Platformu giriş sayfası

```
┌─────────────────────────────────┐
│       🎮 OYUN PLATFORMU          │
│     Oyunla Öğren, Eğlenerek     │
│          Kazan!                  │
├─────────────────────────────────┤
│ E-posta:     [text input]        │
│ Şifre:       [password input]    │
├─────────────────────────────────┤
│ [Giriş Yap]  [Kayıt Ol]          │
└─────────────────────────────────┘
```

**Test Edilecekler:**
- ✅ E-posta validasyonu (@ kontrolü)
- ✅ Şifre validasyonu (minimum 6 karakter)
- ✅ Şifre göster/gizle toggle'ı
- ✅ "Kayıt Ol" linkine tıklama

**Test Verileri:**
```
E-posta: demo@test.com
Şifre:   demo123

Veya herhangi bir geçerli email:
E-posta: user@example.com
Şifre:   anypassword
```

### 2️⃣ Kayıt Ekranı
**Test:** "Kayıt Ol" linkine tıklayın

```
┌─────────────────────────────────┐
│      Kayıt Ol                    │
├─────────────────────────────────┤
│ Ad Soyad:     [text input]       │
│ E-posta:      [email input]      │
│ Şifre:        [password input]   │
│ Şifre Tekrar: [password input]   │
├─────────────────────────────────┤
│ [Kayıt Ol]                       │
└─────────────────────────────────┘
```

**Test Adımları:**
1. Ad Soyad: "Test Kullanıcı" girin
2. E-posta: "test@example.com" girin
3. Şifre: "test123" girin
4. Şifre Tekrar: Aynı şifreyi girin
5. "Kayıt Ol" butonuna tıklayın
6. **Ana Sayfaya yönlendirilir**

### 3️⃣ Ana Sayfa (Feed)
**Durum:** Boş feed (ilk kez)

```
┌─────────────────────────────────┐
│ ⊡ Eğitim Oyun Platformu   ⊡ 🚪  │
├─────────────────────────────────┤
│                                 │
│        Henüz oyun yok           │
│                                 │
│     İlk oyunu sen oluştur!      │
│                                 │
│     [➕ Oyun Oluştur]           │
│                                 │
├─────────────────────────────────┤
│  ⊡ Keşfet  ◯ Profil            │
└─────────────────────────────────┘
```

**Test Edilecekler:**
- ✅ Boş durumda mesaj
- ✅ "Oyun Oluştur" butonunun görünümü
- ✅ Bottom navigation

### 4️⃣ Oyun Oluşturma - Ders Seçimi
**Test:** Ana sayfada "Oyun Oluştur" butonuna tıklayın

```
┌─────────────────────────────────┐
│ ⊡ Ders Seç                  ⊡    │
├─────────────────────────────────┤
│ ┌─────────────────────────────┐  │
│ │ 🔢 Matematik                │  │
│ │ 6 konu                      │  │
│ │                         → ⤵️  │
│ └─────────────────────────────┘  │
│                                 │
│ ┌─────────────────────────────┐  │
│ │ 🔬 Fen Bilgisi              │  │
│ │ 7 konu                      │  │
│ │                         → ⤵️  │
│ └─────────────────────────────┘  │
│                                 │
│ ┌─────────────────────────────┐  │
│ │ 📚 Türkçe                   │  │
│ │ 6 konu                      │  │
│ │                         → ⤵️  │
│ └─────────────────────────────┘  │
│                                 │
│ ✓ Diğer dersler aşağıda...     │
└─────────────────────────────────┘
```

**Test Adımları:**
1. **Matematik**'e tıklayın
2. Sonraki ekrana geçecek

### 5️⃣ Oyun Oluşturma - Konu & Ayarlar
**Test:** Matematik dersi seçildikten sonra

```
┌─────────────────────────────────┐
│ ⊡ Matematik                     │
├─────────────────────────────────┤
│ 🔢 Matematik                    │
│ "Bir konu seçin..."             │
├─────────────────────────────────┤
│                                 │
│ Konular:                        │
│ [Toplama] [Çıkarma]             │
│ [Çarpım Tablosu] [Bölme]        │
│ [Kesirler] [Geometri]           │
│                                 │
│ Yaş Grubu:                      │
│ [6-8] [9-11] [12-14] [15+]      │
│                                 │
│ Zorluk:                         │
│ [😊 Kolay] [😐 Orta] [😨 Zor]  │
│                                 │
│ [AI ile Oyun Oluştur]           │
└─────────────────────────────────┘
```

**Test Adımları:**
1. **"Çarpım Tablosu"** konusuna tıklayın
2. Yaş grubu: **"9-11"** (varsayılan)
3. Zorluk: **"Kolay"** (varsayılan)
4. **"AI ile Oyun Oluştur"** butonuna tıklayın

### 6️⃣ Oyun Oluşturma - AI İşlemi
**Durum:** AI oyunu üretirken

```
┌─────────────────────────────────┐
│ ⊡ Oyun Oluşturuluyor         ⊡   │
├─────────────────────────────────┤
│                                 │
│           ⏳ Loading...          │
│                                 │
│     AI oyununu hazırlıyor...    │
│                                 │
│ Matematik - Çarpım Tablosu     │
│                                 │
└─────────────────────────────────┘
```

**Beklenen Davranış:**
- İlerleme göstergesi görünür
- ~2-3 saniye sonra oyun önizlemesi gelir

### 7️⃣ Oyun Oluşturma - Önizleme
**Durum:** AI tarafından oyun oluşturuldu

```
┌─────────────────────────────────┐
│ ⊡ Oyun Oluşturuluyor         ⊡   │
├─────────────────────────────────┤
│                                 │
│           ✅ Oyun Hazır!        │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ Uzay Çarpımı                │ │
│ │ Uzayda koşarak çarpım...   │ │
│ │ [Matematik] [Çarpım]        │ │
│ │ [Kolay]                     │ │
│ └─────────────────────────────┘ │
│                                 │
│ 📊 Bilgiler:                    │
│ - Oyun Tipi: Koşarak Soru      │
│ - Soru Sayısı: 3 soru          │
│ - Süre: 60 saniye              │
│ - Hedef Puan: 100 puan         │
│                                 │
│ [İptal]  [Kaydet ve Paylaş]    │
└─────────────────────────────────┘
```

**Test Edilecekler:**
- ✅ Oyun başlığı: "Uzay Çarpımı"
- ✅ Açıklama ve etiketler
- ✅ Oyun bilgileri (3 soru, 60 sn)
- ✅ İptal ve Kaydet butonları

**Test Adımları:**
1. **"Kaydet ve Paylaş"** butonuna tıklayın
2. Başarı mesajı göreceksiniz
3. Ana sayfaya dönecek

### 8️⃣ Ana Sayfa - Oyun Feed'i
**Durum:** Oyun kaydedildikten sonra

```
┌─────────────────────────────────┐
│ ⊡ Eğitim Oyun Platformu   ⊡ 🚪  │
├─────────────────────────────────┤
│                                 │
│ ┌─────────────────────────────┐ │
│ │ 🔢 Test Kullanıcı            │ │
│ │                              │ │
│ │ Uzay Çarpımı                 │ │
│ │                              │ │
│ │ [Matematik][Çarpım][Kolay]  │ │
│ │                              │ │
│ │ 🎮 0 oynandı  ❤️  0 beğeni  │ │
│ │                              │ │
│ │ [▶️ Oyna]                    │ │
│ └─────────────────────────────┘ │
│                                 │
├─────────────────────────────────┤
│  ⊡ Keşfet  ◯ Profil            │
└─────────────────────────────────┘
```

**Test Edilecekler:**
- ✅ Oyun kartı görüntüleniyor
- ✅ Başlık: "Uzay Çarpımı"
- ✅ Etiketler: Matematik, Çarpım, Kolay
- ✅ İstatistikler: 0 oynandı, 0 beğeni
- ✅ Oyna butonu

**Interaktif Testler:**
1. Oyun kartında **sağa kaydırma** → Detay modal'ı açılır
2. **"Oyna"** butonuna tıklayın
3. "Oyun oynatma yakında eklenecek" mesajı görülür

### 9️⃣ Profil Ekranı
**Test:** Bottom navigation'da **Profil** sekmesine tıklayın

```
┌─────────────────────────────────┐
│ ⊡ Eğitim Oyun Platformu   ⊡ 🚪  │
├─────────────────────────────────┤
│                                 │
│           👤 Test Kullanıcı      │
│        test@example.com          │
│                                 │
│  [Games: 1]  [Score: 0]         │
│                                 │
│ 📅 Katılma Tarihi:              │
│    5 Şubat 2026                 │
│                                 │
│ 🚀 Yakında Gelecek Özellikler: │
│    ✓ Oluşturduğum Oyunlar       │
│    ✓ Oynadığım Oyunlar          │
│    ✓ Başarılar & Rozetler       │
│    ✓ İstatistikler              │
│                                 │
├─────────────────────────────────┤
│  ⊡ Keşfet  ◉ Profil            │
└─────────────────────────────────┘
```

**Test Edilecekler:**
- ✅ Kullanıcı adı görüntüleniyor
- ✅ E-posta görüntüleniyor
- ✅ Oyun sayısı: 1
- ✅ Katılma tarihi

## 📋 Test Kontrol Listesi

- [ ] Login ekranı açılıyor
- [ ] Email validasyonu çalışıyor
- [ ] Şifre göster/gizle çalışıyor
- [ ] Kayıt ekranına gidilebiliyor
- [ ] Kayıt başarılı oluyor
- [ ] Ana sayfa (feed) açılıyor
- [ ] "Oyun Oluştur" butonuna tıklanabiliyor
- [ ] Ders seçimi çalışıyor
- [ ] Konu seçimi çalışıyor
- [ ] Yaş grubu seçimi çalışıyor
- [ ] Zorluk seçimi çalışıyor
- [ ] AI oyun üretimi başlıyor
- [ ] Oyun önizlemesi gösteriliyor
- [ ] Oyun kaydediliyor
- [ ] Feed'de oyun görünüyor
- [ ] Oyun detayları modal'da açılıyor
- [ ] Profil sayfası görünüyor
- [ ] Çıkış yapılabiliyor

## 🐛 Bilinen Test Sorunları

1. **Firebase Olmadan**
   - Oyunlar disk'te (memory'de) depolanır
   - Uygulamayı kapatıp açarsanız oyunlar kaybolur

2. **Gemini API Olmadan**
   - Sample oyun JSON kullanılır
   - Gerçek AI üretimi yapılmaz

3. **Asset Olmadan**
   - Sprite'lar yerleştirilmedi
   - Oyun görsel olarak tam değil

## ✨ Diğer Testler

### Performance Test
```bash
flutter run --profile
```

### Lint Check
```bash
flutter analyze
```

### Build Test
```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

## 🎯 Sonraki Adımlar

1. Firebase kurulumunu tamamla
2. Gemini API key'i ekle
3. Asset (sprite) dosyaları ekle
4. Flame game engine'i integrate et
5. Quiz Runner oyun şablonunu geliştir

---

**Son Güncellenme:** 5 Şubat 2026  
**Test Platformu:** Android/iOS/Web
