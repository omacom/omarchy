# Pemecahan Masalah

### Sistem saya rusak gara-gara update!

Pertama, coba [kembalikan sistem Anda](47-system-snapshots.md) ke versi sebelum update terakhir Anda. Jika itu tidak berhasil, gunakan `omarchy-debug` untuk membagikan masalah Anda di #omarchy-help di Discord. Dan jika semua itu gagal, Anda dapat menginstal ulang konfigurasi dan paket default menggunakan `omarchy-reinstall`.

### Kenapa beberapa aplikasi tampil begitu besar di layar saya?

Omarchy mengasumsikan layar beresolusi tinggi 2x, yang mengharuskan `GDK_SCALE` diatur ke 2 di `~/.config/hypr/monitors.lua`. Namun jika Anda menggunakan layar 1x, Anda dapat mengubah `local omarchy_gdk_scale = 2` menjadi 1 (lalu restart aplikasi apa pun yang tampil terlalu besar). Lihat [manual tentang monitor](33-monitors.md).

Untuk Spotify, Anda dapat menggunakan `Ctrl + Minus` untuk mengecilkan UI (dan `Ctrl + Plus` untuk memperbesarnya).

### Kenapa semua bind tombol Super saya berhenti berfungsi?

Di beberapa laptop ASUS ROG dan TUF, `Fn + Super` adalah kombinasi yang mudah terlewatkan yang mengaktifkan/menonaktifkan kunci tombol Windows di firmware (dimaksudkan untuk gaming agar Anda tidak keluar dari game secara tidak sengaja). Tidak ada apa pun di layar yang memberi tahu Anda hal itu terjadi. Saat kuncinya aktif, Super sama sekali tidak mengirim apa pun — jadi setiap bind Omarchy yang menggunakan Super berhenti begitu saja, dan terlihat seperti Hyprland yang rusak.

Tekan `Fn + Super` sekali sebelum Anda mengutak-atik `~/.config/hypr/`, dan jika itu tidak mengembalikan Super, tekan lagi agar Anda tidak membiarkan kuncinya tetap aktif. Ini bukan Fn-lock, yang hanya mengubah fungsi baris tombol F.

### Wi-Fi, Bluetooth, audio, atau trackpad saya tiba-tiba berhenti berfungsi

Sebelum reboot, coba restart subsistem yang bermasalah itu saja. _Update > Hardware_ di menu Omarchy memiliki Wi-Fi, Bluetooth, Audio, dan Trackpad, dan memuat ulang salah satunya menyelesaikan sebagian besar situasi "tadi lima menit lalu masih bisa" — headset Bluetooth yang tidak mau terhubung kembali, trackpad yang mati setelah suspend, suara yang hilang saat Anda mencabut monitor.

### Kenapa speaker eksternal saya tidak mengeluarkan suara?

Kemungkinan karena belum diatur sebagai output utama. Klik ikon speaker di sisi kanan bar, dan popup volume akan terbuka di mana Anda dapat memilih perangkat output (dan mengatur volume per aplikasi juga).

### Speaker laptop saya terdengar aneh

Di beberapa laptop, Omarchy secara otomatis menerapkan tuning speaker yang mengoreksi respons frekuensi speaker bawaan. `omarchy audio tuning status` memberi tahu Anda apakah tuning aktif di mesin Anda, dan `omarchy audio tuning off` menonaktifkannya jika Anda lebih suka mendengar speaker apa adanya.

### Kenapa saya tidak bisa login atau sudo dengan kata sandi saya?

Anda mungkin salah mengetikkannya terlalu sering dan terkunci. Jika ini terjadi di layar kunci, Anda dapat menekan `CTRL + ALT + F2` untuk memulai TTY baru di mana Anda dapat login sebagai root, lalu jalankan `faillock --reset --user [your-username]`. Itu akan mereset pengunciannya, dan Anda siap melanjutkan.

### Kenapa prompt otorisasi 1Password saya untuk 1Password SSH Agent / CLI tidak muncul?

Ini bisa terjadi karena 2 alasan:

Agar prompt persetujuan yang lengkap muncul, Settings > Advanced > Use Hardware Acceleration harus diaktifkan. _Catatan: Ini memerlukan reboot agar mulai berfungsi._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Atau jika Anda belum menjalankan 1Password sejak booting, prompt tidak akan muncul.
