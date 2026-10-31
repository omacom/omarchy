# Pemecahan Masalah

### Sistem saya rusak gara-gara pembaruan!

Pertama, coba [kembalikan sistem Anda](47-system-snapshots.md) ke versi sebelum pembaruan terakhir Anda. Jika itu tidak berhasil, gunakan `omarchy-debug` untuk membagikan masalah Anda di #omarchy-help di Discord. Dan jika semua itu gagal, Anda dapat menginstal ulang konfigurasi dan paket default menggunakan `omarchy-reinstall`.

### Mengapa beberapa aplikasi tampil begitu besar di layar saya?

Omarchy mengasumsikan layar beresolusi tinggi 2x, jadi Omarchy menetapkan `GDK_SCALE` ke 2 sampai Anda memilih skala di panel monitor. Jika Anda menggunakan layar 1x dan aplikasi GTK atau X11 tampil terlalu besar, pilih 1x untuk layar tersebut di panel monitor, atau tambahkan `hl.env("GDK_SCALE", "1")` ke `~/.config/hypr/monitors.lua` (lalu mulai ulang aplikasi apa pun yang tampil terlalu besar). Lihat [manual tentang monitor](33-monitors.md).

Untuk Spotify, Anda dapat menggunakan `Ctrl + Minus` untuk memperkecil UI (dan `Ctrl + Plus` untuk memperbesarnya).

### Mengapa semua bind tombol Super saya berhenti berfungsi?

Di beberapa laptop ASUS ROG dan TUF, `Fn + Super` adalah kombinasi tombol yang mudah terlewatkan yang mengaktifkan/menonaktifkan kunci tombol Windows di firmware (dimaksudkan untuk gaming agar Anda tidak keluar dari game secara tidak sengaja). Tidak ada apa pun di layar yang memberi tahu Anda bahwa itu terjadi. Saat kunci aktif, Super tidak mengirim apa pun sama sekali — jadi setiap bind Omarchy yang menggunakan Super langsung berhenti, dan terlihat seolah-olah Hyprland yang rusak.

Tekan `Fn + Super` sekali sebelum Anda mengutak-atik `~/.config/hypr/`, dan jika itu tidak mengembalikan Super, tekan lagi agar Anda tidak membiarkan kuncinya tetap aktif. Ini bukan Fn-lock, yang hanya mengubah fungsi deretan tombol F.

### Wi-Fi, Bluetooth, audio, atau trackpad saya tiba-tiba berhenti berfungsi

Sebelum Anda reboot, coba mulai ulang subsistem yang bermasalah itu saja. _Update > Hardware_ di menu Omarchy menyediakan Wi-Fi, Bluetooth, Audio, dan Trackpad, dan memuat ulang salah satunya menyelesaikan sebagian besar situasi "tadi lima menit lalu masih berfungsi" — headset Bluetooth yang tidak mau terhubung kembali, trackpad yang mati setelah suspend, suara yang hilang saat Anda mencabut monitor.

### Mengapa speaker eksternal saya tidak mengeluarkan suara?

Kemungkinan karena speaker tersebut belum diatur sebagai output utama. Klik ikon speaker di sisi kanan bar, dan popup volume akan terbuka tempat Anda dapat memilih perangkat output (dan mengatur volume per aplikasi juga).

### Speaker laptop saya terdengar aneh

Di beberapa laptop, Omarchy secara otomatis menerapkan tuning speaker yang mengoreksi respons frekuensi speaker bawaan. `omarchy audio tuning status` memberi tahu Anda apakah tuning tersebut aktif di mesin Anda, dan `omarchy audio tuning off` menonaktifkannya jika Anda lebih suka mendengar suara speaker apa adanya.

### Mengapa saya tidak bisa login atau sudo dengan kata sandi saya?

Kemungkinan Anda salah mengetiknya terlalu banyak kali dan terkunci. Jika ini terjadi di layar kunci, Anda dapat menekan `CTRL + ALT + F2` untuk memulai TTY baru tempat Anda dapat login sebagai root, lalu jalankan `faillock --reset --user [your-username]`. Itu akan mereset penguncian tersebut, dan Anda siap melanjutkan.

### Mengapa prompt otorisasi 1Password untuk 1Password SSH Agent / CLI tidak muncul?

Ini dapat terjadi karena 2 alasan:

Agar prompt persetujuan lengkap muncul, Settings > Advanced > Use Hardware Acceleration harus diaktifkan. _Catatan: Ini memerlukan reboot agar mulai berfungsi._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Atau jika Anda belum membuka 1Password sejak booting, prompt tidak akan muncul.
