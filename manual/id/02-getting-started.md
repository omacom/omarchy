# Memulai

Omarchy dipasang menggunakan ISO. Kamu bisa memilih antara pemasangan full-disk, yang mengambil alih seluruh drive, atau pemasangan free-space, yang menempatkan Omarchy di ruang yang belum dialokasikan pada sebuah drive — begitulah caramu dual boot di samping Windows atau OS lain (lihat [pemasangan dual-boot](50-dual-boot-install.md) — perlu diketahui bahwa kamu harus mematikan BitLocker di Windows terlebih dahulu). Apa pun pilihannya, pemasangan secara default menggunakan enkripsi penuh, dan opsi full-disk akan menghapus drive yang dipilih, jadi pastikan untuk membuat cadangan sebelum menggunakan drive yang sudah ada!

[Unduh ISO Omarchy](https://omarchy.org/) terlebih dahulu, masukkan ke USB stick (gunakan [balenaEtcher](https://etcher.balena.io/) di Mac/Windows atau [caligula](https://github.com/ifd3f/caligula) di Linux), dan boot dari stick tersebut.

_Kamu harus mematikan Secure Boot dan/atau TPM di BIOS. Kamu harus mematikannya agar bisa memasang Omarchy. Itu adalah skema keamanan Microsoft yang ditujukan untuk Windows dan distribusi Linux yang berafiliasi dengan Microsoft._

Kemudian jawab pertanyaan konfigurasi, dan konfirmasi seperti ini:

 ![install-config](images/install-config.webp)

Kemudian pilih drive untuk pemasanganmu, lalu duduk santai dan saksikan pertunjukan pemasangannya. Ini bisa selesai dalam waktu kurang dari satu menit pada mesin modern tercepat, tetapi seharusnya tidak memakan waktu lebih dari 5 menit bahkan pada komputer yang lebih lama.

 ![install-done](images/install-done.webp)

Sekarang kamu siap ber-Omarchy!

### Gunakan keyboard kabel atau 2.4ghz!

Enkripsi full-disk tidak akan mengizinkan kamu memasukkan kata sandi dari keyboard Bluetooth saat startup. Sama seperti kamu tidak bisa menggunakan keyboard Bluetooth untuk masuk ke BIOS pada PC. Kamu akan memerlukan keyboard yang menggunakan dongle 2.4ghz atau kabel (yang juga jauh lebih baik untuk latensi!). Aku pribadi sangat menyukai [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Memasang untuk pemilik lain

Jika kamu menyiapkan mesin untuk orang lain — anggota keluarga, karyawan baru, pembeli — kamu tidak seharusnya menjawab pertanyaan pribadi atas nama mereka. Tekan `Ctrl + C` pada layar pertama installer (pemilihan keyboard), dan Omarchy akan menawarkan untuk menyiapkan mesin untuk pemilik lain sebagai gantinya. Sistem langsung terpasang, tetapi semua pengaturan pribadi — tata letak keyboard, nama pengguna, kata sandi — ditunda sampai mesin boot untuk pertama kalinya. Drive tetap terenkripsi secara default, dan kata sandi yang dipilih pemilik baru pada boot pertama itu juga menjadi kata sandi enkripsi. (Mesin yang sudah kamu gunakan juga bisa diserahkan tanpa pemasangan ulang — lihat [mengatur ulang komputer](48-security.md).)

### Pemasangan unattended

ISO juga bisa memasang sepenuhnya sendiri — tanpa keyboard, tanpa wizard — ketika diberikan konfigurasinya pada drive kedua. Itulah caranya memperlakukan Omarchy sebagai base image untuk VM dan mesin fleet. Lihat [pemasangan unattended](51-unattended-installs.md).

### Pemasangan tanpa enkripsi

Omarchy dipasang dengan enkripsi secara default. Ini pilihan yang aman dan bertanggung jawab untuk komputer apa pun yang mungkin hilang atau dicuri. Kamu tidak mau siapa pun yang memiliki akses ke perangkat kerasmu bisa mendapatkan datamu!

Tetapi dalam keadaan khusus, seperti pemasangan Omarchy jarak jauh pada komputer yang terlindungi atau untuk pemasangan sekali pakai tanpa data sensitif, kamu mungkin ingin memasang tanpa enkripsi. Kamu bisa menekan `Ctrl + C` pada konfirmasi pemformatan disk untuk beralih ke pemasangan tanpa enkripsi.

### Bahasa

Omarchy berbicara dalam 50 bahasa — set yang sama seperti omarchy.org — dan bahasa Inggris adalah default-nya. Untuk beralih, buka menu Omarchy dan pergi ke _Setup > Language_, atau jalankan `omarchy language <code>` di terminal (`omarchy language list` menunjukkan kode-kodenya). Menu, desktop, dan notifikasi Omarchy sendiri langsung berubah bahasa, dan setiap aplikasi yang kamu buka setelahnya juga mengikutinya. Aplikasi yang sudah terbuka akan beralih setelah kamu memulai ulangnya.

### Bantuan jika kamu terjebak

Jika kamu terjebak, kamu biasanya bisa menemukan seseorang yang bersedia membantu di kanal _#omarchy-help_ pada [Discord komunitas](https://omarchy.org/discord).
