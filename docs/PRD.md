# Product Requirement Document (PRD)
## Zerro — Aplikasi Pengelola Password Lokal

---

## 1. Informasi Umum

| Item | Detail |
|------|--------|
| Nama Produk | Zerro |
| Versi | 1.0.0 |
| Platform | Android |
| Framework | Flutter (Dart) |
| Pengembang | YakaLabs Technologies |
| Tanggal Dokumen | Mei 2026 |
| Status | Release |

---

## 2. Ringkasan Produk

Zerro adalah aplikasi pengelola password berbasis mobile yang menyimpan seluruh data secara lokal di perangkat pengguna. Aplikasi ini dirancang untuk membantu pengguna menyimpan, mengelola, dan mengamankan berbagai informasi sensitif seperti kredensial login, data kartu, dokumen identitas, dan catatan rahasia — tanpa mengirimkan data ke server manapun.

---

## 3. Tujuan Produk

1. Memberikan solusi penyimpanan password dan data sensitif yang aman dan mudah digunakan
2. Menjamin privasi pengguna dengan penyimpanan 100% lokal (offline-first)
3. Menyediakan antarmuka yang intuitif dengan tema gelap yang nyaman di mata
4. Membantu pengguna membuat password yang kuat melalui generator otomatis
5. Mengorganisir data sensitif ke dalam kategori yang terstruktur

---

## 4. Target Pengguna

- Pengguna Android yang membutuhkan tempat aman untuk menyimpan password
- Pengguna yang mengutamakan privasi dan tidak ingin data disimpan di cloud
- Mahasiswa dan profesional yang memiliki banyak akun online
- Pengguna yang membutuhkan penyimpanan data kartu dan dokumen identitas digital

---

## 5. Arsitektur Teknis

### 5.1 Stack Teknologi

| Komponen | Teknologi |
|----------|-----------|
| UI Framework | Flutter 3.x |
| Bahasa | Dart |
| Database | SQLite (sqflite) |
| State Management | StatefulWidget + setState |
| Penyimpanan | Lokal (SQLite) |
| Minimum SDK | Android API 21 (Lollipop) |

### 5.2 Struktur Database

**Tabel `vault`** — Menyimpan semua entri data pengguna

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| id | INTEGER | Primary key, auto-increment |
| title | TEXT | Nama item (wajib) |
| category | TEXT | Kategori: login, kartu, identitas, catatan_aman |
| fields | TEXT | Data field dalam format JSON |
| created_at | TEXT | Timestamp pembuatan (ISO 8601) |
| updated_at | TEXT | Timestamp update terakhir (ISO 8601) |

**Tabel `settings`** — Menyimpan konfigurasi aplikasi

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| key | TEXT | Primary key (contoh: "pin") |
| value | TEXT | Nilai setting |

---

## 6. Fitur Utama

### 6.1 Autentikasi PIN

**Deskripsi:** Aplikasi dilindungi oleh PIN 6 digit yang harus dimasukkan setiap kali aplikasi dibuka.

**Perilaku:**
- PIN default: `000000`
- Teks hint "PIN default: 000000" ditampilkan di layar unlock
- Numpad custom dengan 10 tombol angka + tombol hapus
- Animasi shake + haptic feedback saat PIN salah
- 6 dot indikator yang terisi saat mengetik
- Auto-lock: jika aplikasi di-background lebih dari 30 detik, PIN diminta kembali
- PIN disimpan di tabel `settings` dalam database lokal

**Mode PIN:**
| Mode | Fungsi |
|------|--------|
| Unlock | Membuka aplikasi (layar awal) |
| Setup | Membuat PIN baru (input pertama) |
| Confirm | Konfirmasi PIN baru (input kedua) |

---

### 6.2 Dashboard (Beranda)

**Deskripsi:** Halaman utama menampilkan 4 kategori penyimpanan dalam bentuk tile vertikal.

**Komponen UI:**
- Header: Logo aplikasi (custom image) + nama "Zerro" + icon pencarian + icon settings
- 4 tile kategori dengan icon, label, deskripsi, dan badge jumlah item
- Floating Action Button (+) untuk menambah item baru

**Kategori yang tersedia:**

| Kategori | Icon | Warna | Deskripsi |
|----------|------|-------|-----------|
| Login | 🔑 Key | Indigo (#6C63FF) | Username & password akun |
| Kartu | 💳 Credit Card | Cyan (#00D4FF) | Kartu debit, kredit & rekening |
| Identitas | 🪪 Badge | Mint (#00E5A0) | KTP, SIM, paspor & dokumen |
| Catatan Aman | 📝 Sticky Note | Amber (#FFB347) | Catatan terenkripsi |

---

### 6.3 Manajemen Data per Kategori

#### 6.3.1 Kategori Login

**Field yang disimpan:**
| Field | Label | Tipe Input | Wajib |
|-------|-------|------------|-------|
| title | Nama Item | Text | Ya |
| username | Username / Email | Email keyboard | Ya |
| password | Password | Obscured text | Ya |

**Fitur tambahan:**
- Toggle show/hide password
- Tombol copy password ke clipboard
- Indikator kekuatan password (4 bar: Sangat Lemah → Sangat Kuat)
- Generator password otomatis

#### 6.3.2 Kategori Kartu

**Field yang disimpan:**
| Field | Label | Tipe Input | Wajib |
|-------|-------|------------|-------|
| title | Nama Item | Text | Ya |
| nama_lengkap | Nama Lengkap (sesuai kartu) | Text (capitalize words) | Ya |
| nomor_rekening | Nomor Rekening / Kartu | Number only | Ya |
| merk | Merk / Bank | Text (capitalize words) | Ya |
| kode_keamanan | Kode Keamanan | 6 digit, obscured | Ya |

**Validasi khusus:**
- Nomor rekening: hanya angka
- Kode keamanan: tepat 6 digit, toggle show/hide

#### 6.3.3 Kategori Identitas

**Field yang disimpan:**
| Field | Label | Tipe Input | Wajib |
|-------|-------|------------|-------|
| title | Nama Item | Text | Ya |
| nomor | Nomor Dokumen | Text | Ya |
| nama_lengkap | Nama Lengkap | Text (capitalize words) | Ya |
| tempat_lahir | Tempat Lahir | Text (capitalize words) | Ya |
| tanggal_lahir | Tanggal Lahir | Text | Ya |
| jenis_kelamin | Jenis Kelamin | Dropdown (Laki-laki / Perempuan) | Ya |
| alamat | Alamat Lengkap | Multiline (3 baris) | Ya |
| kode_pos | Kode Pos | 5 digit | Tidak |
| golongan_darah | Golongan Darah | Dropdown (A, B, AB, O, +/-) | Tidak |
| agama | Agama | Text | Tidak |
| status_perkawinan | Status Perkawinan | Dropdown | Tidak |
| pekerjaan | Pekerjaan | Text | Tidak |
| kewarganegaraan | Kewarganegaraan | Text | Tidak |

#### 6.3.4 Kategori Catatan Aman

**Field yang disimpan:**
| Field | Label | Tipe Input | Wajib |
|-------|-------|------------|-------|
| title | Nama Item | Text | Ya |
| catatan | Catatan | Multiline (5-8 baris) | Ya |

---

### 6.4 Generator Password

**Deskripsi:** Fitur untuk membuat password acak yang kuat secara otomatis.

**Parameter yang dapat dikonfigurasi:**
| Parameter | Range | Default |
|-----------|-------|---------|
| Panjang | 8 – 32 karakter | 16 |
| Huruf Besar (A-Z) | On/Off | On |
| Huruf Kecil (a-z) | On/Off | On |
| Angka (0-9) | On/Off | On |
| Simbol (!@#$%^&*) | On/Off | On |

**Perilaku:**
- Ditampilkan dalam bottom sheet
- Slider untuk mengatur panjang
- Toggle switch untuk setiap jenis karakter
- Tombol "Generate & Gunakan" untuk langsung mengisi field password
- Menggunakan `Random.secure()` untuk keamanan kriptografis
- Minimal 1 karakter dari setiap jenis yang diaktifkan dijamin ada

---

### 6.5 Indikator Kekuatan Password

**Algoritma scoring (0-4):**
| Kriteria | Poin |
|----------|------|
| Panjang ≥ 8 karakter | +1 |
| Panjang ≥ 12 karakter | +1 |
| Mengandung huruf besar DAN kecil | +1 |
| Mengandung angka | +1 |
| Mengandung simbol | +1 |

**Label:**
| Skor | Label | Warna |
|------|-------|-------|
| 0 | Sangat Lemah | Merah (#FF5C7A) |
| 1 | Lemah | Merah (#FF5C7A) |
| 2 | Cukup | Kuning (#FFB347) |
| 3 | Kuat | Hijau (#00E5A0) |
| 4 | Sangat Kuat | Hijau (#00E5A0) |

---

### 6.6 Pencarian

**Deskripsi:** Fitur pencarian global untuk menemukan item berdasarkan nama.

**Perilaku:**
- Diakses melalui icon 🔍 di header dashboard
- Keyboard langsung fokus saat layar dibuka
- Pencarian real-time (setiap karakter yang diketik)
- Mencari di kolom `title` dan `fields` (JSON)
- Hasil menampilkan: nama item, badge kategori, subtitle (field utama)
- Tap hasil → navigasi ke halaman detail item

---

### 6.7 Halaman Detail

**Deskripsi:** Menampilkan semua informasi dari sebuah item.

**Komponen:**
- Header: icon kategori + nama item + badge kategori
- Daftar field dalam card dengan border
- Field sensitif (password, kode keamanan, nomor rekening, nomor dokumen): hidden by default, tap icon mata untuk reveal
- Tombol copy untuk setiap field yang berisi data
- Indikator kekuatan password (khusus field password)
- Timestamp: tanggal dibuat dan terakhir diperbarui
- Action: Edit (icon) dan Hapus (icon merah) di AppBar

---

### 6.8 Halaman Settings (Pengaturan)

**Menu yang tersedia:**

| Menu | Fungsi |
|------|--------|
| Ubah PIN | Verifikasi PIN lama → Input PIN baru → Konfirmasi PIN baru |
| Help & Support | Panduan penggunaan aplikasi (bottom sheet) |
| About | Informasi versi, platform, dan fitur (bottom sheet) |
| Credits | Tim pengembang dan teknologi (bottom sheet) |
| Legal | Kebijakan privasi & ketentuan penggunaan (bottom sheet) |

**Footer:** Logo + nama "Zerro" + nama perusahaan + copyright — selalu nempel di bawah layar.

---

## 7. Desain UI/UX

### 7.1 Tema Visual

| Elemen | Nilai |
|--------|-------|
| Mode | Dark theme |
| Background | #0D0D14 |
| Surface | #16161F |
| Card | #1E1E2C |
| Primary | #6C63FF (Indigo-violet) |
| Accent | #00D4FF (Cyan) |
| Text Primary | #F0F0FF |
| Text Secondary | #9090B0 |
| Text Hint | #5A5A7A |
| Danger | #FF5C7A |
| Warning | #FFB347 |
| Success | #00E5A0 |

### 7.2 Komponen UI

- **Border radius:** 12-16px untuk card dan input, 20px untuk dialog
- **Spacing:** 8px antar elemen kecil, 16-20px antar section
- **Font weight:** 700 untuk heading, 600 untuk title, 500 untuk body
- **Icon style:** Material Rounded
- **Animasi:** 150-300ms untuk transisi, elastic curve untuk FAB

### 7.3 Logo

- Mendukung custom logo dari file `assets/images/logo.png`
- Fallback ke gradient icon (Primary → Accent) jika file tidak ada
- Ditampilkan di: PIN screen, Dashboard header, Settings footer

---

## 8. Keamanan

| Aspek | Implementasi |
|-------|-------------|
| Penyimpanan data | 100% lokal (SQLite), tidak ada koneksi internet |
| Proteksi akses | PIN 6 digit wajib saat membuka aplikasi |
| Auto-lock | Kunci otomatis setelah 30 detik di background |
| Field sensitif | Hidden by default di halaman detail |
| Password generator | Menggunakan `Random.secure()` (CSPRNG) |
| Data transmission | Tidak ada — zero network calls |

---

## 9. Alur Pengguna (User Flow)

### 9.1 First Launch
```
Buka App → PIN Screen (default: 000000) → Dashboard
```

### 9.2 Menambah Item
```
Dashboard → Tap FAB (+) → Pilih Kategori (bottom sheet) → Form Input → Simpan → Kembali ke Dashboard
```

### 9.3 Melihat Item
```
Dashboard → Tap Kategori → List Item → Tap Item → Detail Screen
```

### 9.4 Edit Item
```
Detail Screen → Tap Edit (icon) → Form Edit (pre-filled) → Simpan → Kembali
```

### 9.5 Hapus Item
```
Detail/List → Tap Hapus → Dialog Konfirmasi → Hapus → Snackbar notifikasi
```

### 9.6 Ubah PIN
```
Settings → Ubah PIN → Verifikasi PIN Lama → Input PIN Baru → Konfirmasi PIN Baru → Snackbar sukses
```

### 9.7 Pencarian
```
Dashboard → Tap icon 🔍 → Ketik keyword → Hasil real-time → Tap item → Detail
```

---

## 10. Batasan & Keterbatasan

1. **Tidak ada backup/restore** — jika aplikasi di-uninstall, data hilang
2. **Tidak ada sinkronisasi** — data hanya ada di satu perangkat
3. **Tidak ada biometrik** — hanya PIN 6 digit
4. **Tidak ada enkripsi field** — data disimpan plain text di SQLite (dilindungi oleh sandbox Android)
5. **Tidak ada recovery PIN** — jika lupa PIN, tidak ada cara memulihkan data
6. **Tidak ada export/import** — data tidak bisa dipindahkan antar perangkat

---

## 11. Rencana Pengembangan (Roadmap)

### Versi 1.1 (Planned)
- [ ] Autentikasi biometrik (fingerprint)
- [ ] Export/import data (encrypted JSON)
- [ ] Backup ke penyimpanan lokal

### Versi 1.2 (Planned)
- [ ] Enkripsi AES-256 untuk field sensitif
- [ ] Kategori custom (user-defined)
- [ ] Tema terang (light mode)

### Versi 2.0 (Future)
- [ ] Sinkronisasi end-to-end encrypted (opsional)
- [ ] Password breach checker
- [ ] Autofill service integration

---

## 12. Persyaratan Non-Fungsional

| Aspek | Requirement |
|-------|-------------|
| Performa | Aplikasi harus bisa dibuka dalam < 2 detik |
| Ukuran APK | < 20 MB |
| Kompatibilitas | Android 5.0+ (API 21+) |
| Offline | 100% fungsional tanpa internet |
| Aksesibilitas | Kontras warna memenuhi WCAG AA untuk dark theme |
| Responsif | Mendukung berbagai ukuran layar Android |

---

## 13. Lampiran

### 13.1 Struktur Folder Project

```
lib/
├── main.dart                    — Entry point + PIN gate
├── database/
│   └── db_helper.dart           — SQLite CRUD + settings
├── models/
│   └── vault_entry.dart         — Model data + enum kategori
├── screens/
│   ├── dashboard.dart           — Halaman utama (4 kategori)
│   ├── category_list_screen.dart — List item per kategori
│   ├── add_edit_screen.dart     — Form dinamis per kategori
│   ├── detail_screen.dart       — Detail item
│   ├── search_screen.dart       — Pencarian global
│   ├── pin_screen.dart          — Layar PIN (unlock/setup/confirm)
│   └── settings_screen.dart     — Pengaturan
├── utils/
│   ├── app_theme.dart           — Tema & warna
│   ├── field_definitions.dart   — Definisi field per kategori
│   ├── password_generator.dart  — Generator password
│   └── pin_storage.dart         — Wrapper PIN storage
└── widgets/
    └── strength_indicator.dart  — Bar kekuatan password
```

### 13.2 Dependencies

| Package | Versi | Fungsi |
|---------|-------|--------|
| flutter | SDK | UI framework |
| sqflite | ^2.3.0 | SQLite database |
| path | ^1.9.0 | Path utilities |
| cupertino_icons | ^1.0.8 | iOS-style icons |
| flutter_launcher_icons | ^0.14.4 | Generate app icon (dev) |

---

*Dokumen ini dibuat berdasarkan implementasi aktual aplikasi Zerro versi 1.0.0.*
