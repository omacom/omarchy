# Memulai

Omarchy diinstal menggunakan sebuah ISO. Anda dapat memilih antara instalasi full-disk, yang mengambil alih seluruh drive, atau instalasi free-space, yang menempatkan Omarchy di ruang yang belum dialokasikan pada sebuah drive — begitulah cara Anda melakukan dual boot bersama Windows atau OS lain (lihat [instalasi dual-boot](50-dual-boot-install.md) — perlu diingat bahwa Anda harus mematikan BitLocker di Windows terlebih dahulu). Apa pun pilihannya, instalasi secara default menggunakan enkripsi penuh, dan opsi full-disk akan menghapus drive yang dipilih, jadi pastikan untuk membuat cadangan sebelum menggunakan drive yang sudah ada!

[Unduh ISO Omarchy](https://omarchy.org/) terlebih dahulu, letakkan di USB stick (gunakan [Rufus](https://rufus.ie/) di Windows, [balenaEtcher](https://etcher.balena.io/) di Mac, atau [caligula](https://github.com/ifd3f/caligula) di Linux), dan boot dari stick tersebut.

_Anda harus mematikan Secure Boot dan/atau TPM di BIOS. Anda harus mematikan keduanya agar dapat menginstal Omarchy. Keduanya adalah skema keamanan Microsoft yang dimaksudkan untuk Windows dan distribusi Linux yang berafiliasi dengan Microsoft._

Kemudian jawab pertanyaan konfigurasi, dan konfirmasi seperti ini:

 ![install-config](images/install-config.webp)

Kemudian pilih sebuah drive untuk instalasi Anda, dan duduk santai sambil menyaksikan pertunjukan instalasinya. Instalasi dapat selesai dalam waktu kurang dari satu menit di mesin modern tercepat, tetapi tidak akan memakan waktu lebih dari 5 menit bahkan di komputer yang lebih lama.

 ![install-done](images/install-done.webp)

Sekarang Anda siap untuk Omarchy!

### Gunakan keyboard berkabel atau 2.4ghz!

Enkripsi full-disk tidak akan memungkinkan Anda memasukkan kata sandi dari keyboard Bluetooth saat startup. Sama seperti Anda tidak dapat menggunakan keyboard Bluetooth untuk masuk ke BIOS di PC. Anda memerlukan keyboard yang menggunakan dongle 2.4ghz atau kabel (yang jauh lebih enak untuk latensi!). Saya pribadi sangat menyukai [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Menginstal untuk pemilik lain

Jika Anda menyiapkan mesin untuk orang lain — anggota keluarga, karyawan baru, pembeli — Anda tidak boleh menjawab pertanyaan pribadi atas nama mereka. Tekan `Ctrl + C` di layar paling pertama installer (pemilihan keyboard), dan Omarchy akan menawarkan untuk menyiapkan mesin untuk pemilik lain sebagai gantinya. Sistem langsung terinstal, tetapi semua pengaturan pribadi — tata letak keyboard, nama pengguna, kata sandi — ditunda hingga mesin boot untuk pertama kalinya. Drive tetap terenkripsi secara default, dan kata sandi yang dipilih pemilik baru pada boot pertama itu juga menjadi kata sandi enkripsi. (Mesin yang sudah pernah Anda gunakan juga dapat diserahkan tanpa instalasi ulang — lihat [mengatur ulang komputer](48-security.md).)

### Instalasi tanpa pengawasan

ISO ini juga dapat menginstal sepenuhnya dengan sendirinya — tanpa keyboard, tanpa wizard — ketika konfigurasinya diberikan di drive kedua. Itulah cara memperlakukan Omarchy sebagai base image untuk VM dan mesin-mesin fleet. Lihat [instalasi tanpa pengawasan](51-unattended-installs.md).

### Instalasi tanpa enkripsi

Omarchy diinstal dengan enkripsi secara default. Ini adalah pilihan yang aman dan bertanggung jawab untuk komputer mana pun yang mungkin hilang atau dicuri. Anda tidak ingin siapa pun yang memiliki akses ke hardware Anda dapat mengambil data Anda!

Tetapi dalam keadaan khusus, seperti instalasi Omarchy jarak jauh di komputer yang terlindungi atau untuk instalasi sekali pakai tanpa data sensitif, Anda mungkin ingin menginstal tanpa enkripsi. Anda dapat menekan `Ctrl + C` pada konfirmasi pemformatan disk untuk beralih ke instalasi tanpa enkripsi.

### Bahasa

Omarchy mendukung 50 bahasa — set yang sama seperti omarchy.org — dan bahasa Inggris adalah default-nya. Untuk beralih, buka menu Omarchy dan buka _Setup > Region > Language_, atau jalankan `omarchy language <code>` di terminal (`omarchy language list` menampilkan kode-kodenya). Menu, desktop, dan notifikasi Omarchy sendiri langsung berubah bahasa, dan setiap aplikasi yang Anda buka setelahnya juga mengikutinya. Aplikasi yang sudah terbuka akan beralih setelah Anda memulai ulangnya.

Untuk mempertahankan bahasa tetapi menulis tanggal, waktu, angka, uang, satuan, dan ukuran kertas seperti yang dilakukan wilayah lain (bahasa Inggris dengan tanggal Eropa dan jam 24 jam, misalnya), pilih sebuah wilayah di _Setup > Region > Formats_, di mana setiap pilihan menampilkan contoh, atau jalankan `omarchy region <code>` (`omarchy region list` menampilkan kode-kodenya). _Same as language_ kembali ke format bawaan bahasa tersebut. Seperti pergantian bahasa, ini berlaku untuk aplikasi yang Anda buka setelahnya.

### Bantuan jika Anda kesulitan

Jika Anda kesulitan, Anda biasanya dapat menemukan seseorang yang bersedia membantu di kanal _#omarchy-help_ di [Discord komunitas](https://omarchy.org/discord).
