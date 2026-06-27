# 🔧 Supabase Integration Setup Guide

## 📋 Langkah-Langkah Setup

### 1. **Create Supabase Project**
- Buka https://supabase.com
- Login atau buat akun baru
- Click "New Project"
- Isi nama project: `nutripath`
- Setup region terdekat dengan Anda
- Click "Create new project"

### 2. **Dapatkan Credentials**
- Masuk ke project Anda
- Buka **Settings** > **API**
- Copy:
  - **Project URL** (gunakan untuk `supabaseUrl`)
  - **Anon Key** (gunakan untuk `supabaseAnonKey`)

### 3. **Update Konfigurasi di Flutter App**
Edit file [lib/core/config/supabase_config.dart](lib/core/config/supabase_config.dart):

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://qjruqqheyyysbxlodplv.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqcnVxcWhleXl5c2J4bG9kcGx2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkxNzQ0MjMsImV4cCI6MjA5NDc1MDQyM30.2tX1OHBabeO59zwxk-bUNXwLvlElWPpN7aVz5sjUrqU';
  static const bool debugMode = true;
}
```

### 4. **Setup Database Tables**

Buka **SQL Editor** di Supabase Dashboard dan jalankan SQL berikut:

```sql
-- Create users table
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  name TEXT NOT NULL,
  weight FLOAT NOT NULL,
  target_weight FLOAT NOT NULL,
  height FLOAT NOT NULL,
  age INTEGER NOT NULL,
  gender TEXT NOT NULL,
  activity_level TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create nutrition_logs table
CREATE TABLE nutrition_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  food_name TEXT NOT NULL,
  calories FLOAT NOT NULL,
  protein FLOAT NOT NULL,
  fat FLOAT NOT NULL,
  carbs FLOAT NOT NULL,
  sugar FLOAT NOT NULL,
  serving_size FLOAT DEFAULT 1.0,
  food_image TEXT,
  is_scanned BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create user_stats table
CREATE TABLE user_stats (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  streak_days INTEGER DEFAULT 0,
  points INTEGER DEFAULT 0,
  last_log_date TEXT,
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for faster queries
CREATE INDEX idx_nutrition_logs_user_id ON nutrition_logs(user_id);
CREATE INDEX idx_nutrition_logs_created_at ON nutrition_logs(created_at);
CREATE INDEX idx_users_email ON users(email);

-- Enable Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE nutrition_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
-- Users can only read their own data
CREATE POLICY "Users can read their own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Users can only update their own data
CREATE POLICY "Users can update their own data"
  ON users FOR UPDATE
  USING (auth.uid() = id);

-- Users can only read their own nutrition logs
CREATE POLICY "Users can read their own nutrition logs"
  ON nutrition_logs FOR SELECT
  USING (auth.uid() = user_id);

-- Users can only insert their own nutrition logs
CREATE POLICY "Users can insert their own nutrition logs"
  ON nutrition_logs FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can only delete their own nutrition logs
CREATE POLICY "Users can delete their own nutrition logs"
  ON nutrition_logs FOR DELETE
  USING (auth.uid() = user_id);

-- Users can read their own stats
CREATE POLICY "Users can read their own stats"
  ON user_stats FOR SELECT
  USING (auth.uid() = user_id);

-- Users can update their own stats
CREATE POLICY "Users can update their own stats"
  ON user_stats FOR UPSERT
  USING (auth.uid() = user_id);
```

### 5. **Test Integration**

Run aplikasi Flutter:
```bash
flutter pub get
flutter run
```

- Coba Register akun baru
- Login dengan akun tersebut
- Tambahkan nutrition log
- Data harus tersimpan di Supabase database

### 6. **Verify Data di Supabase**

- Buka **Table Editor** di Supabase Dashboard
- Lihat tabel `users`, `nutrition_logs`, `user_stats`
- Pastikan data sudah tersimpan dengan benar

---

## 🔐 Security Notes

✅ **Sudah diimplementasi:**
- Row Level Security (RLS) di semua tabel
- Users hanya bisa akses data mereka sendiri
- Password di-hash oleh Supabase Auth

⚠️ **Untuk Production:**
- Disable anonymous sign-ups (di Auth settings)
- Setup email verification
- Setup email templates
- Implement refresh token strategy
- Monitor untuk suspicious activity

---

## 📱 Testing Credentials

Untuk development/testing, Anda bisa membuat test user:

1. Buka **Authentication** > **Users**
2. Click "Invite"
3. Masukkan email test (contoh: `test@example.com`)
4. Set password manual
5. Invite akan dikirim ke email (atau manual setup)

---

## 🚀 Next Steps

1. ✅ Update credentials di `supabase_config.dart`
2. ✅ Setup database tables via SQL
3. ✅ Test register & login
4. ✅ Test menambah nutrition log
5. ⏭️ (Optional) Setup Cloud Functions untuk async operations
6. ⏭️ (Optional) Setup Storage untuk food images
7. ⏭️ (Optional) Setup Realtime untuk live updates

---

## ❓ Troubleshooting

### Error: "Invalid API Key"
- Pastikan `supabaseUrl` dan `supabaseAnonKey` di-copy dengan benar
- Jangan sampai ada space tambahan
- Pastikan key adalah **Anon Key**, bukan **Service Key**

### Error: "User already exists"
- Email sudah terdaftar
- Coba dengan email yang berbeda

### Data tidak tersimpan
- Check RLS policies di Supabase Dashboard
- Pastikan user sudah authenticated
- Check error logs di server Flutter

### Connection timeout
- Check internet connection
- Pastikan Supabase project aktif
- Check Supabase project status di dashboard

---

## 📚 Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter Package](https://pub.dev/packages/supabase_flutter)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
