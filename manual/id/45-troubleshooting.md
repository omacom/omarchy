# Pemecahan Masalah

### Sistem saya rusak gara-gara pembaruan!

Pertama, coba [kembalikan sistem Anda](47-system-snapshots.md) ke versi sebelum pembaruan terakhir Anda. Jika itu tidak berhasil, gunakan `omarchy-debug` untuk membagikan masalah Anda di #omarchy-help di Discord. Dan jika semua itu gagal, Anda dapat menginstal ulang konfigurasi dan paket default menggunakan `omarchy-reinstall`.

### Mengapa beberapa aplikasi terlihat sangat besar di layar saya?

Omarchy mengasumsikan layar beresolusi tinggi 2x, jadi Omarchy mengatur `GDK_SCALE` ke 2 sampai Anda memilih skala di panel monitor. Jika Anda menggunakan layar 1x dan aplikasi GTK atau X11 tampil terlalu besar, pilih 1x untuk layar tersebut di panel monitor, atau tambahkan `hl.env("GDK_SCALE", "1")` ke `~/.config/hypr/monitors.lua` (lalu mulai ulang aplikasi apa pun yang tampil terlalu besar). Lihat [manual tentang monitor](33-monitors.md).

Untuk Spotify, Anda dapat menggunakan `Ctrl + Minus` untuk mengecilkan UI (dan `Ctrl + Plus` untuk memperbesarnya).

### Mengapa semua bind tombol Super saya berhenti berfungsi?

Pada beberapa laptop ASUS ROG dan TUF, `Fn + Super` adalah kombinasi yang mudah terlewatkan dan mengaktifkan atau menonaktifkan kunci tombol Windows di firmware (dimaksudkan untuk bermain game agar Anda tidak keluar dari game secara tidak sengaja). Tidak ada apa pun di layar yang memberi tahu Anda bahwa itu terjadi. Saat kunci tersebut aktif, Super tidak mengeluarkan apa pun sama sekali — jadi setiap bind Omarchy yang menggunakan Super langsung berhenti, dan terlihat seperti Hyprland yang rusak.

Tekan `Fn + Super` sekali sebelum Anda mengutak-atik `~/.config/hypr/`, dan jika itu tidak mengembalikan Super, tekan lagi agar Anda tidak meninggalkan kunci tersebut dalam keadaan aktif. Ini bukan Fn-lock, yang hanya mengubah fungsi baris tombol F.

### Wi-Fi, Bluetooth, audio, atau trackpad saya tiba-tiba berhenti berfungsi

Sebelum Anda melakukan reboot, coba mulai ulang subsistem yang bermasalah itu saja. _Update > Hardware_ di menu Omarchy menyediakan Wi-Fi, Bluetooth, Audio, dan Trackpad, dan memuat ulang salah satunya akan mengatasi sebagian besar situasi "lima menit yang lalu masih berfungsi" — headset Bluetooth yang tidak mau terhubung kembali, trackpad yang mati setelah suspend, suara yang hilang saat Anda mencabut monitor.

### Mengapa speaker eksternal saya tidak mengeluarkan suara?

Kemungkinan karena speaker tersebut belum diatur sebagai output utama. Klik ikon speaker di sisi kanan bar, dan popup volume akan terbuka sehingga Anda dapat memilih perangkat output (dan mengatur volume per aplikasi juga).

### Speaker laptop saya terdengar aneh

Pada beberapa laptop, Omarchy secara otomatis menerapkan tuning speaker yang mengoreksi respons frekuensi speaker bawaan. `omarchy audio tuning status` memberi tahu Anda apakah tuning tersebut aktif di mesin Anda, dan `omarchy audio tuning off` menonaktifkannya jika Anda lebih suka mendengar speaker apa adanya.

### Mengapa saya tidak bisa login atau sudo dengan kata sandi saya?

Anda mungkin salah mengetiknya sepuluh kali dan terkunci. Kuncian itu akan hilang dengan sendirinya setelah dua menit. Jika Anda tidak bisa menunggu, dan ini terjadi di layar kunci, Anda dapat menekan `CTRL + ALT + F2` untuk memulai TTY baru tempat Anda dapat login sebagai root, lalu jalankan `faillock --reset --user [your-username]`. Itu akan mengatur ulang kuncian tersebut, dan Anda siap melanjutkan.

### Kata sandi saya diterima, tetapi saya kembali ke layar login

File lingkungan sesi yang rusak dapat mencegah desktop untuk dimulai meskipun kata sandi Anda benar. Hal ini sangat patut diperiksa setelah mengedit `~/.config/uwsm/env.d/`.

Tekan `Ctrl + Alt + F2`, login dengan nama pengguna dan kata sandi biasa Anda, dan periksa jurnal pengguna dari boot saat ini:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Cari error yang menyebutkan salah satu file lingkungan Anda, seperti `bad substitution`, tepat sebelum pesan bahwa tanda output env tidak ditemukan. Pindahkan file tersebut keluar dari `env.d` sebelum mencoba login lagi. Misalnya, jika error tersebut menyebutkan `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM melewati file dengan kesalahan sintaks, tetapi error fatal yang hanya muncul saat file dijalankan, seperti `bad substitution`, masih dapat mencegah desktop untuk dimulai. Rollback snapshot sistem tidak memperbaiki file-file ini, karena `/home` tidak dikembalikan.

Setelah Anda dapat login, perbaiki salinan yang disimpan sebelum memindahkannya kembali. `sh -n` menangkap kesalahan sintaks tanpa menjalankan file, tetapi tidak dapat menangkap setiap error yang terjadi saat file tersebut di-source. Biarkan terminal yang berfungsi tetap terbuka saat menguji perubahan.

### Mengapa prompt otorisasi 1Password saya untuk 1Password SSH Agent / CLI tidak muncul?

Hal ini dapat terjadi karena 2 alasan:

Agar prompt persetujuan lengkap tersebut muncul, Settings > Advanced > Use Hardware Acceleration harus diaktifkan. _Catatan: Ini memerlukan reboot agar mulai berfungsi._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Atau jika Anda belum membuka 1Password sejak booting, prompt tersebut tidak akan muncul.
