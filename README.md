# NutriPath - Nutrition Tracking App

Aplikasi Flutter untuk tracking nutrisi harian dengan fitur AI-powered food recognition. NutriPath membantu user memantau asupan kalori, protein, lemak, karbohidrat, dan gula dengan mudah menggunakan kamera atau input manual.

## 📱 Features

✅ **User Authentication** (email-based, local)  
✅ **Nutrition Tracking** (daily logging)  
✅ **AI-Powered Food Recognition** (Google Gemini API)  
✅ **Food Recommendations** (local database)  
✅ **Analytics & Insights** (BMR, calorie calculation)  
✅ **Gamification** (streak, points system)  
✅ **Multi-user Support** (per email)  
✅ **Offline-first** (tidak perlu internet kecuali scan foto)

---

## 🏗️ Backend Architecture

Aplikasi menggunakan **local storage** tanpa backend server remote. Data disimpan di device menggunakan SharedPreferences.

### State Management Layer (Provider Pattern)

#### AuthProvider (`lib/state/auth_provider.dart`)
Mengelola autentikasi user dan manajemen session:
- Register dengan profil lengkap (nama, berat, tinggi, umur, gender, activity level)
- Login session per email
- Validasi duplikasi email
- Mock storage di SharedPreferences

**Data yang disimpan:**
```json
{
  "id": "user_id",
  "email": "user@example.com",
  "name": "John Doe",
  "weight": 70.5,
  "targetWeight": 65.0,
  "height": 175,
  "age": 28,
  "gender": "male",
  "activityLevel": "moderate"
}
```

#### NutritionProvider (`lib/state/nutrition_provider.dart`)
Mengelola food logging dan nutrition tracking:
- Tambah/hapus makanan dari daily log
- Menghitung total kalori, protein, lemak, karbohidrat, gula
- Manajemen streak days & points (gamification)
- Sinkronisasi data per user
- Analisis nutrisi harian

---

### Services Layer (Business Logic)

#### FoodSearchService (`lib/core/services/food_search_service.dart`)
Mencari rekomendasi makanan dari local database:
- Pencarian berdasarkan target nutrisi (kalori, protein, fat, gula)
- Return 5 rekomendasi teratas
- Menggunakan `FoodDatabase` (dataset lokal)

```dart
Future<List<FoodModel>> searchFoodRecommendations(
  double calories, {
  double? sugar,
  double? fat,
  double? protein,
}) async { ... }
```

#### OpenAIFoodService (`lib/core/services/openai_food_service.dart`)
Menggunakan Google Gemini API untuk AI features:
- **Analisis gambar makanan** → ekstrak nutrisi menggunakan AI vision
- **Generate insight** → saran nutrisi berdasarkan konsumsi harian user
> Catatan: `OpenAIFoodService` merupakan nama file internal (legacy naming), namun implementasi saat ini menggunakan Google Gemini API untuk analisis makanan berbasis AI.

**Konfigurasi:**
- Model: `gemini-1.5-flash`
- API Key: Disimpan di local storage (SharedPreferences)
- Source: `assets/config.json`

---

### Data Layer (Storage)

#### AppLocalStorage (`lib/core/storage/app_local_storage.dart`)
Menggunakan **SharedPreferences** untuk persistent storage:

**Keys yang digunakan:**
```
- users                    → Semua profile & password pengguna (JSON)
- nutrition_{email}        → Daily log, history, points, streak per user
- session_email            → Email user yang sedang login
- openai_api_key           → Google AI API key
```

**Struktur data nutrition:**
```json
{
  "history": [
    {
      "id": "food_id",
      "name": "Nasi Goreng",
      "calories": 450,
      "protein": 12,
      "fat": 15,
      "carbs": 60,
      "sugar": 2,
      "consumedAt": "2026-05-10T12:30:00.000Z",
      "isScanned": false
    }
  ],
  "points": 100,
  "streakDays": 5,
  "lastLogDate": "2026-05-10T23:59:59.999Z"
}
```

---

### Data Models

#### FoodModel (`lib/models/food_model.dart`)
```dart
{
  id,                    // Unique identifier
  name,                  // Nama makanan
  calories,              // Kalori
  protein,               // Protein (gram)
  fat,                   // Lemak (gram)
  carbs,                 // Karbohidrat (gram)
  sugar,                 // Gula (gram)
  consumedAt,            // Waktu konsumsi
  imageUrl,              // URL gambar (jika ada)
  isScanned              // Apakah hasil scan AI
}
```

#### UserModel (`lib/models/user_model.dart`)
```dart
{
  id,                    // User ID
  email,                 // Email login
  name,                  // Nama lengkap
  weight,                // Berat badan (kg)
  targetWeight,          // Target berat badan (kg)
  height,                // Tinggi badan (cm)
  age,                   // Umur (tahun)
  gender,                // 'male' atau 'female'
  activityLevel          // 'sedentary', 'light', 'moderate', 'active', 'very_active'
}
```

**Kalkulasi:**
- **BMR** menggunakan Mifflin-St Jeor Equation
- **Daily Calorie Goal** = BMR × Activity Level Multiplier

---

### Local Database

#### FoodDatabase (`lib/core/data/food_database.dart`)
- Dataset makanan hardcoded di aplikasi
- Fitur: `searchByNutrition()` untuk rekomendasi
- Digunakan oleh FoodSearchService

---

## 📊 Data Flow Workflow

```
┌──────────────────────────────────────────────────────┐
│                 LOGIN/REGISTER                        │
│  AuthProvider → SharedPreferences (local storage)    │
└─────────────────────┬────────────────────────────────┘
                      ↓
┌──────────────────────────────────────────────────────┐
│              ADD FOOD TO LOG                          │
│  User dapat memilih:                                 │
│  1. Dari rekomendasi (FoodSearchService)             │
│  2. Scan gambar (OpenAIFoodService + Camera)        │
│  3. Input manual                                     │
└─────────────────────┬────────────────────────────────┘
                      ↓
┌──────────────────────────────────────────────────────┐
│        STORE IN NutritionProvider                    │
│  - Save to SharedPreferences (nutrition_{email})     │
│  - Notify UI via Provider listeners                  │
│  - Update daily log                                  │
└─────────────────────┬────────────────────────────────┘
                      ↓
┌──────────────────────────────────────────────────────┐
│     CALCULATE & DISPLAY ANALYTICS                    │
│  - Total kalori, protein, fat, carbs, gula          │
│  - Progress vs daily target                         │
│  - Generate AI insight (Gemini API)                 │
│  - Update streak & points                           │
└──────────────────────────────────────────────────────┘
```

---

## 🔌 External Integrations

| Service | Fungsi | Konfigurasi |
|---------|--------|-------------|
| **Google Gemini** | AI food analysis dari gambar | API Key di `assets/config.json` |
| **Camera Plugin** | Ambil foto makanan | Via `image_picker` package |
| **SharedPreferences** | Local data storage | Built-in |

---

## 📦 Dependencies

```yaml
dependencies:
  flutter: sdk
  provider: ^6.1.5+1           # State management
  google_generative_ai: ^0.4.7  # Google Gemini API
  image_picker: ^1.2.1          # Camera & gallery
  camera: ^0.11.2+1             # Camera API
  shared_preferences: ^2.5.3     # Local storage
  http: ^1.2.2                   # HTTP requests
  intl: ^0.20.2                  # Internationalization
  fl_chart: ^0.69.0              # Charts & analytics
  google_fonts: ^6.3.2           # Fonts
  flutter_animate: ^4.5.2        # Animations
  lucide_icons: ^0.257.0         # Icons
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.8.1
- Google Gemini API Key

### Installation

1. Clone repository
```bash
git clone <repository-url>
cd nutri_path
```

2. Install dependencies
```bash
flutter pub get
```

3. Setup API Key

Buka `assets/config.json` dan masukkan Google Gemini API Key Anda:
```json
{
  "GoogleApiKey": "YOUR_API_KEY_HERE"
}
```

4. Run app
```bash
flutter run
```

---

## 📂 Project Structure

```
lib/
├── main.dart                 # Entry point
├── models/
│   ├── food_model.dart      # Food data model
│   └── user_model.dart      # User data model
├── screens/
│   ├── auth/               # Login & register screens
│   ├── main_wrapper.dart   # Main app layout
│   ├── history/            # Food history
│   └── ...
├── state/
│   ├── auth_provider.dart        # Authentication state
│   └── nutrition_provider.dart   # Nutrition state
├── core/
│   ├── services/
│   │   ├── food_search_service.dart      # Food recommendations
│   │   └── openai_food_service.dart      # AI food analysis
│   ├── data/
│   │   └── food_database.dart            # Local food database
│   ├── storage/
│   │   └── app_local_storage.dart        # Local storage manager
│   ├── theme.dart                        # App theme
│   └── config/
│       └── app_config.dart               # App configuration
└── assets/
    └── config.json                 # API keys configuration
```

---

## Backend System Overview

NutriPath menggunakan arsitektur **local-first backend** tanpa server eksternal. Seluruh data pengguna, riwayat nutrisi, streak, dan session disimpan secara lokal menggunakan SharedPreferences. Backend logic dibagi menjadi tiga layer utama:

- **State Layer (Provider):** Mengelola state aplikasi seperti autentikasi dan data nutrisi.
- **Service Layer:** Menjalankan business logic seperti pencarian makanan dan AI analysis menggunakan Google Gemini API.
- **Storage Layer:** Menyimpan data pengguna dan history nutrisi secara persisten pada perangkat.

Dengan pendekatan ini, aplikasi dapat berjalan secara **offline-first**, ringan, dan tidak membutuhkan database server eksternal.

## 🎯 Key Technical Details

### Local-First Architecture
- Semua user data disimpan di device menggunakan SharedPreferences
- Tidak ada backend server
- Cocok untuk aplikasi offline-first

### Nutrition Calculations
- **BMR (Basal Metabolic Rate)** menggunakan Mifflin-St Jeor Equation
- **Daily Calorie Goal** berdasarkan activity level
- **Macro calculations** real-time dari daily log

### AI Integration
- Google Gemini 1.5 Flash untuk analisis gambar makanan
- Extract nutrisi otomatis dari foto
- Generate personalized insights

### Gamification
- Streak system untuk konsistensi harian
- Points accumulation
- Stored per user

---

## 📝 License
This project is developed for educational purposes.
This project is private.

## 👨‍💻 Author
NutriPath Development Team
