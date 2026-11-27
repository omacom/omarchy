# Memulai

Omarchy diinstal menggunakan sebuah ISO. Anda dapat memilih antara instalasi full-disk, yang mengambil alih seluruh drive, atau instalasi free-space, yang menempatkan Omarchy di ruang yang belum dialokasikan pada sebuah drive — begitulah cara Anda melakukan dual boot bersama Windows atau OS lain (lihat [instalasi dual-boot](50-dual-boot-install.md) — perhatikan bahwa Anda harus mematikan BitLocker di Windows terlebih dahulu). Bagaimanapun juga, instalasi secara default menggunakan enkripsi penuh, dan opsi full-disk akan menghapus drive yang dipilih, jadi pastikan untuk membuat cadangan sebelum menggunakan drive yang sudah ada!

Di Mac Apple Silicon, Anda menginstalnya dari macOS sebagai gantinya, tanpa ISO atau stik USB. Lihat [Omarchy untuk Apple Silicon](44-mac-support.md#omarchy-for-apple-silicon).

[Unduh ISO Omarchy](https://omarchy.org/) terlebih dahulu, letakkan di stik USB (gunakan [Rufus](https://rufus.ie/) di Windows, [balenaEtcher](https://etcher.balena.io/) di Mac, atau [caligula](https://github.com/ifd3f/caligula) di Linux), dan boot dari stik tersebut.

_Anda harus mematikan Secure Boot dan/atau TPM di BIOS. Anda harus mematikan keduanya agar dapat menginstal Omarchy. Keduanya adalah skema keamanan Microsoft yang dimaksudkan untuk Windows dan distribusi Linux yang berafiliasi dengan Microsoft._

Lalu jawab pertanyaan konfigurasinya, dan konfirmasikan seperti ini:

 ![install-config](images/install-config.webp)

Lalu pilih drive untuk instalasi Anda, dan duduk santai dan saksikan pertunjukan instalasinya berjalan. Ini dapat selesai dalam waktu kurang dari satu menit di mesin modern tercepat, tetapi tidak akan memakan waktu lebih dari 5 menit bahkan di komputer yang lebih tua.

 ![install-done](images/install-done.webp)

Sekarang Anda siap untuk Omarchy!

### Gunakan keyboard kabel atau 2.4ghz!

Enkripsi full-disk tidak akan mengizinkan Anda memasukkan kata sandi dari keyboard Bluetooth saat startup. Sama seperti Anda tidak dapat menggunakan keyboard Bluetooth untuk masuk ke BIOS di PC. Anda akan memerlukan keyboard yang menggunakan dongle 2.4ghz atau kabel (yang jauh lebih enak untuk latensi juga!). Saya pribadi menyukai [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Menginstal untuk pemilik lain

Jika Anda menyiapkan mesin untuk orang lain — anggota keluarga, karyawan baru, pembeli — Anda tidak seharusnya menjawab pertanyaan pribadi atas nama mereka. Tekan `Ctrl + C` di layar paling pertama installer (pemilihan keyboard), dan Omarchy akan menawarkan untuk menyiapkan mesin untuk pemilik lain sebagai gantinya. Sistem langsung terinstal, tetapi semua pengaturan pribadi — tata letak keyboard, nama pengguna, kata sandi — ditunda sampai mesin boot untuk pertama kalinya. Drive tetap terenkripsi secara default, dan kata sandi yang dipilih pemilik baru pada boot pertama itu juga menjadi kata sandi enkripsi. (Mesin yang sudah Anda gunakan juga dapat diserahkan tanpa instalasi ulang — lihat [mengatur ulang komputer](48-security.md).)

### Instalasi tanpa pengawasan

ISO juga dapat menginstal sepenuhnya sendiri — tanpa keyboard, tanpa wizard — ketika diberikan konfigurasinya pada drive kedua. Itulah cara memperlakukan Omarchy sebagai base image untuk VM dan mesin-mesin fleet. Lihat [instalasi tanpa pengawasan](51-unattended-installs.md).

### Instalasi tanpa enkripsi

Omarchy diinstal dengan enkripsi secara default. Itu adalah pilihan yang aman dan bertanggung jawab untuk komputer mana pun yang mungkin bisa hilang atau dicuri. Anda tidak ingin siapa pun yang memiliki akses ke perangkat keras Anda dapat memperoleh data Anda!

Namun dalam keadaan khusus, seperti instalasi Omarchy jarak jauh pada komputer yang terlindungi atau untuk instalasi sekali pakai tanpa data sensitif, Anda mungkin ingin menginstal tanpa enkripsi. Anda dapat menekan `Ctrl + C` pada konfirmasi pemformatan disk untuk beralih ke instalasi tanpa enkripsi.

### Bahasa

Omarchy mendukung 50 bahasa — rangkaian yang sama seperti omarchy.org — dan bahasa Inggris adalah default-nya. Untuk beralih, buka menu Omarchy dan pergi ke _Setup > Region > Language_, atau jalankan `omarchy language <code>` di terminal (`omarchy language list` menampilkan kode-kodenya). Menu, desktop, dan notifikasi Omarchy sendiri langsung berubah bahasa, dan setiap aplikasi yang Anda buka setelahnya juga mengikutinya. Aplikasi yang sudah terbuka akan beralih setelah Anda memulai ulangnya.

Untuk mempertahankan bahasa tetapi menulis tanggal, waktu, angka, uang, satuan, dan ukuran kertas dengan cara yang dilakukan wilayah lain (bahasa Inggris dengan tanggal Eropa dan jam 24 jam, misalnya), pilih wilayah di bawah _Setup > Region > Formats_, di mana setiap pilihan menampilkan contoh, atau jalankan `omarchy region formats <code>` (`omarchy region formats list` menampilkan kode-kodenya). _Same as language_ kembali ke format bawaan bahasa tersebut. Seperti pergantian bahasa, ini berlaku untuk aplikasi yang Anda buka setelahnya.

### Bantuan jika Anda terjebak

Jika Anda terjebak, Anda biasanya dapat menemukan seseorang yang bersedia membantu di kanal _#omarchy-help_ di [Discord komunitas](https://omarchy.org/discord).
