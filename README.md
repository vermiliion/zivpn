# 🚀 ZIVPN UDP - Premium Hybrid Management System

<p align="center">
  <img src="https://img.shields.io/badge/Version-4.0.0--Modular-blue?style=for-the-badge&logo=github" alt="Version">
  <img src="https://img.shields.io/badge/Language-Python_%26_Bash-yellow?style=for-the-badge&logo=python" alt="Language">
  <img src="https://img.shields.io/badge/Optimization-100%25-green?style=for-the-badge" alt="Optimization">
  <img src="https://img.shields.io/badge/Developer-Vermiliion-orange?style=for-the-badge" alt="Developer">
</p>

---

## 📢 Deskripsi Proyek
**ZIVPN UDP Premium Management System** adalah infrastruktur manajemen VPN berbasis UDP tingkat lanjut yang dirancang khusus untuk stabilitas jaringan, otomatisasi total, dan kontrol multi-user. Mengubah biner inti ZIVPN standar menjadi ekosistem bisnis VPN pintar yang aman dari manipulasi akun (*anti-sharing*).

Dengan integrasi **Hybrid Core Engine**, sistem ini secara konstan menyinkronkan data pengguna lokal melalui enkapsulasi JSON yang cepat, efisien, dan andal di latar belakang VPS.

---

## 📊 Presentase & Distribusi Performa Sistem

Dioptimalkan secara penuh untuk meminimalkan beban CPU dan RAM pada VPS Server:
```text
██████████████████████████████ 85%  Keamanan & Anti-Concurrency (IP Lock)
████████████████████████      65%  Efisiensi RAM Engine (Python Backend)
████████████████████████████  80%  Kecepatan Cron Auto-Purge Daemon
██████████████████████████████ 95%  UI/UX Kemudahan Navigasi Admin Menu
✨ Fitur Utama (Premium Features)
🛡️ Advanced Anti-MultiLogin (IP Lock): Memutus akses dan mengunci akun secara otomatis jika terdeteksi digunakan pada perangkat melebihi batas Limit IP yang ditentukan admin.

📉 Quota-Based Auto Disconnect: Membaca penggunaan data real-time, lalu memblokir akses pengguna secara instan begitu kuota data (GB/MB) habis.

⏳ Auto-Purge Expired Account: Daemon pembersih otomatis yang berjalan setiap 60 detik untuk menghapus akun mati agar database VPS tetap bersih.

🔘 Revolusioner Dual-Input Menu: Tidak perlu lagi mengetik nama pengguna yang rumit saat mengedit atau menghapus. Cukup masukkan Nomor Urut akun dari tabel bantuan atau ketik Nama Akunnya.

📟 Live Concurrency Monitoring: Dashboard interaktif untuk melacak status akun, sisa kuota, jumlah IP yang aktif, hingga melacak akun yang sedang terkena hukuman penguncian (LOCKED).

🏗️ Perbandingan Fitur Standar vs Premium
Kemampuan Manajemen	Core ZIVPN Standar	Sistem Premium Modular
Batasi Jumlah Perangkat (Limit IP)	❌ Tidak Didukung	✅ Otomatis (Lock Sistem)
Batasi Volume Data Pengguna (Quota GB)	❌ Tidak Didukung	✅ Otomatis (Auto Kick)
Manajemen Masa Aktif Akun	❌ Manual	✅ Otomatis (Cron Daemon)
Sistem Input Navigasi	Ketik Manual	✅ Dual-Input (Nomor / Nama)
Penyimpanan Struktur Anggota	Tidak Ada	✅ JSON Database Encrypted
🧩 Struktur Repositori Modular
Sistem ini dipecah menjadi modul-modul terpisah agar pemeliharaan skrip menjadi sangat mudah:

install.sh ➜ Otomasi pemasangan dependensi, pembuatan direktori database, dan registrasi cron background.

config.json ➜ Gerbang utama konfigurasi jaringan inti server UDP.

zivpn.py ➜ Backend API berbasis Python untuk memvalidasi status dan sinkronisasi data user.

m-zivpn ➜ Konsol Menu Interaktif (Frontend) untuk mempermudah administrator mengelola server.

uninstall.sh ➜ Skrip pembersih total yang mengembalikan VPS ke kondisi semula sampai ke akar-akarnya.

🚀 Panduan Pemasangan di VPS
Gunakan perintah satu baris (one-line command) di bawah ini pada terminal SSH root VPS maseee:

▶️ Instalasi Otomatis (Install)
Bash
bash <(wget -qO- [https://raw.githubusercontent.com/vermiliion/zivpn/main/install.sh](https://raw.githubusercontent.com/vermiliion/zivpn/main/install.sh))
❌ Penghapusan Total (Uninstall)
Bash
bash <(wget -qO- [https://raw.githubusercontent.com/vermiliion/zivpn/main/uninstall.sh](https://raw.githubusercontent.com/vermiliion/zivpn/main/uninstall.sh))
🖥️ Preview Menu Utama Terminal (m-zivpn)
Plaintext
──────────────────────────────────────
         PREMIUM ZIVPN MANAGER        
──────────────────────────────────────
 Engine : Hybrid Core V4 Full Dual-Input
──────────────────────────────────────
 [01] Buat Akun Premium (Add User)
 [02] Hapus Akun (Delete User)
 [03] Perpanjang Akun (Renew)
 [04] Ubah Password Akun
 ──────────────────────────────────────
 [05] Ubah Limit IP HP
 [06] Ubah Limit Quota Data
 ──────────────────────────────────────
 [07] LIVE MONITORING (Cek Login IP)
 [08] Daftar Anggota (List Member)
 [09] Buka Kunci Akun (Unlock User)
──────────────────────────────────────
Pilih Menu : 
🤝 Dukungan Proyek
Skrip ini dikembangkan dan dirawat secara berkala oleh Vermiliion. Jika maseee terbantu atau menyukai infrastruktur manajemen modular ini, tolong berikan kontribusi kecil dengan menekan tombol Star ⭐ di bagian atas repositori ini!

Copyright © 2026 Vermiliion Project. All Rights Reserved.