# Pemecahan masalah

### Saya merusak sistem saya dengan pembaruan!

Pertama coba [kembalikan sistemmu](47-system-snapshots.md) ke versi sebelum pembaruan terbarumu. Jika itu tidak berhasil, gunakan `omarchy-debug` untuk membagikan masalahmu di #omarchy-help di Discord. Dan jika semua itu gagal, kamu bisa memasang ulang konfigurasi dan paket bawaan menggunakan `omarchy-reinstall`.

### Mengapa beberapa aplikasi sangat besar di layar saya?

Omarchy mengasumsikan layar resolusi tinggi 2x, yang membutuhkan pengaturan `GDK_SCALE` ke 2 di `~/.config/hypr/monitors.lua`. Tetapi jika kamu menggunakan layar 1x, kamu bisa mengubah `local omarchy_gdk_scale = 2` menjadi 1 (lalu mulai ulang aplikasi apa pun yang kebesaran). Lihat [manual tentang monitor](33-monitors.md).

Untuk Spotify, kamu bisa menggunakan `Ctrl + Minus` untuk mengecilkan UI (dan `Ctrl + Plus` untuk memperbesarnya).

### Wi-Fi, Bluetooth, audio, atau trackpad saya tiba-tiba berhenti berfungsi

Sebelum kamu melakukan reboot, coba mulai ulang subsistem yang bermasalah itu sendiri. _Perbarui > Hardware_ di menu Omarchy memiliki Wi-Fi, Bluetooth, Audio, dan Trackpad, dan memuat ulang salah satunya menyelesaikan mayoritas situasi "tadi lima menit yang lalu berfungsi" — headset Bluetooth yang tidak mau terhubung kembali, trackpad yang mati setelah penangguhan, suara yang hilang saat kamu mencabut monitor.

### Mengapa speaker eksternal saya tidak bersuara?

Mungkin karena mereka tidak diatur sebagai keluaran utama. Klik ikon speaker di sisi kanan bilah, dan itu akan membuka popup volume tempat kamu bisa memilih perangkat keluaran (dan mengatur volume per aplikasi juga).

### Speaker laptop saya terdengar aneh

Pada beberapa laptop, Omarchy secara otomatis menerapkan penalaan speaker yang mengoreksi respons frekuensi speaker bawaan. `omarchy audio tuning status` memberitahumu apakah salah satunya aktif di mesinmu, dan `omarchy audio tuning off` mematikannya jika kamu lebih suka mendengar speaker apa adanya.

### Mengapa saya tidak bisa login atau sudo dengan kata sandi saya?

Kamu mungkin salah mengetikkannya terlalu sering dan terkunci. Jika ini terjadi di layar kunci, kamu bisa menekan `CTRL + ALT + F2` untuk memulai TTY baru tempat kamu bisa login sebagai root, lalu jalankan `faillock --reset --user [your-username]`. Itu akan mengatur ulang penguncian, dan kamu siap melanjutkan.

### Mengapa prompt otorisasi 1Password saya untuk 1Password SSH Agent / CLI tidak muncul?

Ini bisa terjadi karena 2 alasan:

Agar prompt persetujuan yang kaya bisa muncul, Settings > Advanced > Use Hardware Acceleration harus dinyalakan. _Catatan: Ini membutuhkan reboot untuk mulai berfungsi._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Atau jika kamu belum meluncurkan 1Password sejak boot, prompt tidak akan muncul.
