# SpaceNews Core - Advanced International News Portal

Aplikasi Flutter portal berita internasional berbasis REST API
[Spaceflight News API](https://api.spaceflightnewsapi.net/v4/articles/?limit=20),
dengan autentikasi & database real-time menggunakan **Firebase**.


## 🗂️ Struktur Folder

```
lib/
 ├─ main.dart
 ├─ models/
 │   ├─ article_model.dart
 │   └─ user_model.dart
 ├─ services/
 │   ├─ auth_service.dart        # Firebase Authentication
 │   ├─ firestore_service.dart   # Firestore (users & favorites)
 │   ├─ news_api_service.dart    # REST API Spaceflight News
 │   └─ prefs_service.dart       # SharedPreferences (session lokal)
 ├─ screens/
 │   ├─ splash_screen.dart
 │   ├─ welcome_screen.dart
 │   ├─ detail_screen.dart
 │   ├─ auth/
 │   │   ├─ register_screen.dart
 │   │   ├─ login_screen.dart
 │   │   └─ forgot_password_screen.dart
 │   └─ home/
 │       ├─ home_screen.dart         # Scaffold + BottomNavigationBar
 │       ├─ dashboard_tab.dart
 │       ├─ favorite_tab.dart
 │       ├─ notification_tab.dart
 │       └─ profile_tab.dart
 ├─ widgets/
 │   ├─ news_card.dart
 │   └─ headline_banner.dart
 └─ utils/
     └─ app_colors.dart
```

## 🚀 Cara Menjalankan Project

### 1. Buat project Flutter (jika belum ada)
```bash
flutter create spacenews_core
cd spacenews_core
```

### 2. Salin file dari folder ini
Timpa/copy folder `lib/`, file `pubspec.yaml`, dan folder `assets/` dari paket ini
ke dalam project Flutter Anda.

### 3. Pasang logo
Sesuai ketentuan tugas, unduh gambar logo dari **Freepik** dengan keyword
**"E-COMMERCE"**, lalu simpan sebagai:
```
assets/images/logo.png
```
(Folder `assets/images/` sudah disiapkan, hanya perlu menambahkan file `logo.png`.)

### 4. Install dependency
```bash
flutter pub get
```

### 5. Setup Firebase
Project ini membutuhkan **Firebase Authentication** (Email/Password) dan
**Cloud Firestore**.

Cara tercepat menggunakan FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
Perintah di atas akan otomatis:
- Membuat/menghubungkan Firebase project
- Generate `lib/firebase_options.dart`
- Menambahkan `google-services.json` (Android) & `GoogleService-Info.plist` (iOS)

> Jika menggunakan `flutterfire configure`, ubah `main.dart` menjadi:
> ```dart
> import 'firebase_options.dart';
> ...
> await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
> ```

Aktifkan di Firebase Console:
1. **Authentication** → Sign-in method → aktifkan **Email/Password**
2. **Firestore Database** → buat database (mode test/production)

### Struktur data Firestore

**Collection `users`** (document id = uid user)
```
{
  name: string,
  email: string,
  instagram: string,
  photoUrl: string,
  createdAt: timestamp
}
```

**Collection `favorites`** (document id = `<uid>_<articleId>`)
```
{
  userId: string,
  articleId: string,
  title: string,
  summary: string,
  imageUrl: string,
  newsSite: string,
  publishedAt: string,
  url: string,
  createdAt: timestamp
}
```

Contoh Firestore Security Rules dasar (sesuaikan untuk production):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /favorites/{favId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }
  }
}
```

### 6. Jalankan aplikasi
```bash
flutter run
```

## 📤 Upload ke GitHub
```bash
git init
git add .
git commit -m "Initial commit - SpaceNews Core"
git branch -M main
git remote add origin <URL_REPO_GITHUB_ANDA>
git push -u origin main
```

> ⚠️ File `google-services.json`, `GoogleService-Info.plist`, dan
> `lib/firebase_options.dart` sudah di-exclude di `.gitignore` karena
> berisi kredensial. Jika dosen/penilai perlu menjalankan project,
> sertakan instruksi setup Firebase (seperti di atas) di README repo Anda,
> atau lampirkan file tersebut secara terpisah/aman sesuai kebijakan kelas.

## 🔧 Catatan Teknis
- **REST API**: `GET https://api.spaceflightnewsapi.net/v4/articles/?limit=20`
  diparsing field `results` menjadi list `ArticleModel`.
- **Session**: status login disimpan di `SharedPreferences` (`isLoggedIn`)
  dan diverifikasi ulang dengan `FirebaseAuth.currentUser` saat Splash Screen.
- **Logout**: menghapus `SharedPreferences`, `FirebaseAuth.signOut()`, dan
  `Navigator.pushAndRemoveUntil` ke `RegisterScreen` agar seluruh stack halaman bersih.
