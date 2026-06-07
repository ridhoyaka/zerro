# Zerro - Secure Password Manager

Zerro adalah aplikasi manajemen password berbasis Flutter yang dirancang untuk menyimpan informasi sensitif secara lokal di perangkat Android. Aplikasi ini menempatkan privasi pengguna di depan, dengan autentikasi PIN dan struktur data yang terorganisir untuk akun login, kartu, dokumen identitas, dan catatan aman.

## Ringkasan Proyek

- Nama aplikasi: Zerro
- Package: `zerro_app`
- Platform utama: Android
- Framework: Flutter / Dart
- Database lokal: SQLite (`sqflite`)
- Fokus: keamanan lokal, estetika gelap, dan pengalaman pengguna intuitif

## Fitur Utama

- Autentikasi PIN 6 digit dengan auto-lock setelah aplikasi berbackground selama 30 detik
- Penyimpanan lokal seluruh data menggunakan SQLite
- Kategori data terorganisir: Login, Kartu, Identitas, Catatan Aman
- Generator password kuat untuk membantu membuat kata sandi acak
- Indikator kekuatan password untuk password login
- Navigasi dashboard sederhana dengan akses cepat ke pencarian dan pengaturan

## Struktur Repository

- `lib/main.dart` - Titik masuk aplikasi dan logika gerbang PIN
- `lib/screens/` - Layout layar utama, detail item, daftar kategori, dan pengaturan PIN
- `lib/database/` - Helper SQLite dan model data vault
- `lib/utils/` - Tema aplikasi, generator password, dan utilitas input
- `lib/widgets/` - Komponen UI reusable seperti indikator kekuatan password
- `assets/` - Asset gambar dan ikon aplikasi

## Menjalankan Proyek

### Prasyarat

- Flutter SDK versi terbaru yang kompatibel dengan SDK Dart 3.11.x
- Android SDK / emulator
- `flutter` CLI tersedia di PATH

### Langkah

1. Buka terminal di folder proyek
2. Jalankan:
   ```bash
   flutter pub get
   flutter run
   ```

> Jika Anda menggunakan Android Studio atau Visual Studio Code, pastikan emulator atau perangkat fisik sudah terpasang.

## Catatan Penting

- Aplikasi menyimpan data secara lokal, jadi pastikan perangkat terlindungi jika Anda menyimpan informasi sensitif.
- `pubspec.yaml` sudah mengonfigurasi asset dan ikon peluncur.

## Tujuan

README ini dimaksudkan untuk menjelaskan konteks proyek dengan profesional dan memudahkan kolaborator atau pengguna baru memahami arsitektur, fungsi, dan cara menjalankan aplikasi.
