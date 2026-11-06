# Pemecahan Masalah

### Sistem saya rusak gara-gara pembaruan!

Pertama, coba [kembalikan sistem Anda](47-system-snapshots.md) ke versi sebelum pembaruan terakhir Anda. Jika itu tidak berhasil, gunakan `omarchy-debug` untuk membagikan masalah Anda di #omarchy-help di Discord. Dan jika semua itu gagal, Anda bisa menginstal ulang konfigurasi dan paket default menggunakan `omarchy-reinstall`.

### Kenapa beberapa aplikasi terlihat begitu besar di layar saya?

Omarchy mengasumsikan layar beresolusi tinggi 2x, jadi Omarchy mengatur `GDK_SCALE` ke 2 sampai Anda memilih skala di panel monitor. Jika Anda menggunakan layar 1x dan aplikasi GTK atau X11 tampil terlalu besar, pilih 1x untuk layar tersebut di panel monitor, atau tambahkan `hl.env("GDK_SCALE", "1")` ke `~/.config/hypr/monitors.lua` (lalu mulai ulang aplikasi apa pun yang tampil terlalu besar). Lihat [panduan tentang monitor](33-monitors.md).

Untuk Spotify, Anda bisa menggunakan `Ctrl + Minus` untuk mengecilkan UI (dan `Ctrl + Plus` untuk memperbesarnya).

### Kenapa semua bind tombol Super saya berhenti berfungsi?

Pada beberapa laptop ASUS ROG dan TUF, `Fn + Super` adalah kombinasi yang mudah terlewat yang mengaktifkan kunci Windows-key firmware (dimaksudkan untuk gaming agar Anda tidak keluar dari game tanpa sengaja). Tidak ada apa pun di layar yang memberi tahu Anda bahwa itu terjadi. Saat kunci tersebut aktif, Super tidak mengirimkan apa pun sama sekali — jadi setiap bind Omarchy yang menggunakan Super langsung berhenti, dan terlihat seperti Hyprland yang rusak.

Tekan `Fn + Super` sekali sebelum Anda mengutak-atik `~/.config/hypr/`, dan jika itu tidak mengembalikan Super, tekan lagi agar Anda tidak membiarkan kuncinya tetap aktif. Ini bukan Fn-lock, yang hanya mengubah fungsi baris tombol F.

### Wi-Fi, Bluetooth, audio, atau trackpad saya tiba-tiba berhenti berfungsi

Sebelum reboot, coba mulai ulang subsistem yang bermasalah itu saja. _Update > Hardware_ di menu Omarchy memiliki Wi-Fi, Bluetooth, Audio, dan Trackpad, dan memuat ulang salah satunya menyelesaikan sebagian besar situasi "tadi lima menit yang lalu masih bisa" — headset Bluetooth yang tidak mau terhubung kembali, trackpad yang mati setelah suspend, suara yang hilang saat Anda mencabut monitor.

### Kenapa speaker eksternal saya tidak mengeluarkan suara?

Mungkin karena speaker tersebut belum diatur sebagai output utama. Klik ikon speaker di sisi kanan bar, dan popup volume akan terbuka tempat Anda bisa memilih perangkat output (dan mengatur volume per aplikasi juga).

### Speaker laptop saya terdengar aneh

Pada beberapa laptop, Omarchy secara otomatis menerapkan tuning speaker yang mengoreksi respons frekuensi speaker bawaan. `omarchy audio tuning status` memberi tahu Anda apakah tuning tersebut aktif di mesin Anda, dan `omarchy audio tuning off` mematikannya jika Anda lebih suka mendengar speaker apa adanya.

### Kenapa saya tidak bisa login atau sudo dengan kata sandi saya?

Anda mungkin salah mengetiknya terlalu banyak kali dan terkunci. Jika ini terjadi di layar kunci, Anda bisa menekan `CTRL + ALT + F2` untuk memulai TTY baru tempat Anda bisa login sebagai root, lalu jalankan `faillock --reset --user [your-username]`. Itu akan mereset penguncian tersebut, dan Anda siap melanjutkan.

### Kata sandi saya diterima, tetapi saya kembali ke layar login

File lingkungan sesi yang rusak dapat mencegah desktop untuk dimulai bahkan saat kata sandi Anda benar. Ini terutama patut diperiksa setelah mengedit `~/.config/uwsm/env.d/`.

Tekan `Ctrl + Alt + F2`, login dengan nama pengguna dan kata sandi normal Anda, dan periksa jurnal pengguna dari boot saat ini:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Cari kesalahan yang menyebutkan salah satu file lingkungan Anda, seperti `bad substitution`, tepat sebelum pesan bahwa tanda output env tidak ditemukan. Pindahkan file tersebut keluar dari `env.d` sebelum mencoba login lagi. Misalnya, jika kesalahan menyebutkan `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM melewati file dengan kesalahan sintaks, tetapi kesalahan fatal yang hanya muncul saat file tersebut dijalankan, seperti `bad substitution`, masih dapat mencegah desktop untuk dimulai. Rollback snapshot sistem tidak memperbaiki file-file ini, karena `/home` tidak dikembalikan.

Setelah Anda bisa login, perbaiki salinan yang tersimpan sebelum memindahkannya kembali. `sh -n` menangkap kesalahan sintaks tanpa menjalankan file, tetapi tidak dapat menangkap setiap kesalahan yang terjadi saat file tersebut di-source. Biarkan terminal yang masih berfungsi tetap terbuka saat menguji perubahan.

### Kenapa prompt otorisasi 1Password saya untuk 1Password SSH Agent / CLI tidak muncul?

Ini bisa terjadi karena 2 alasan:

Agar prompt persetujuan yang lengkap dapat muncul, Settings > Advanced > Use Hardware Acceleration harus diaktifkan. _Catatan: Ini memerlukan reboot agar mulai bekerja._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Atau jika Anda belum membuka 1Password sejak booting, prompt tersebut tidak akan muncul.
