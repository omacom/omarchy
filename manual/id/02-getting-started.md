# Memulai

Omarchy diinstal menggunakan sebuah ISO. Anda bisa memilih antara instalasi seluruh disk, yang mengambil alih seluruh drive, atau instalasi ruang bebas, yang menempatkan Omarchy di ruang yang belum dialokasikan pada sebuah drive — itulah cara Anda melakukan dual boot bersama Windows atau OS lain (lihat [instalasi dual-boot](50-dual-boot-install.md) — perlu diperhatikan bahwa Anda harus mematikan BitLocker di Windows terlebih dahulu). Apa pun pilihannya, instalasi secara default menggunakan enkripsi penuh, dan opsi seluruh disk akan menghapus bersih drive yang dipilih, jadi pastikan untuk membuat cadangan sebelum menggunakan drive yang sudah ada!

[Unduh ISO Omarchy](https://omarchy.org/) terlebih dahulu, taruh di stik USB (gunakan [Rufus](https://rufus.ie/) di Windows, [balenaEtcher](https://etcher.balena.io/) di Mac, atau [caligula](https://github.com/ifd3f/caligula) di Linux), dan lakukan boot dari stik tersebut.

_Anda harus mematikan Secure Boot dan/atau TPM di BIOS. Anda harus mematikan keduanya agar dapat menginstal Omarchy. Keduanya adalah skema keamanan Microsoft yang dimaksudkan untuk Windows dan distribusi Linux yang berafiliasi dengan Microsoft._

Lalu jawab pertanyaan-pertanyaan konfigurasi, dan konfirmasikan seperti ini:

 ![install-config](images/install-config.webp)

Lalu pilih drive untuk instalasi Anda, dan duduk santai sambil menyaksikan pertunjukan instalasi berjalan. Instalasi bisa selesai dalam waktu kurang dari satu menit di mesin modern tercepat, tetapi seharusnya tidak memakan waktu lebih dari 5 menit bahkan di komputer yang lebih lama.

 ![install-done](images/install-done.webp)

Sekarang Anda siap ber-Omarchy!

### Gunakan keyboard berkabel atau 2.4ghz!

Enkripsi seluruh disk tidak akan memungkinkan Anda memasukkan kata sandi dari keyboard Bluetooth saat startup. Sama seperti Anda tidak bisa menggunakan keyboard Bluetooth untuk masuk ke BIOS di PC. Anda akan memerlukan keyboard yang menggunakan dongle 2.4ghz atau kabel (yang juga jauh lebih enak untuk latensi!). Saya pribadi sangat menyukai [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Menginstal untuk pemilik lain

Jika Anda menyiapkan mesin untuk orang lain — anggota keluarga, karyawan baru, pembeli — Anda tidak seharusnya menjawab pertanyaan-pertanyaan pribadi atas nama mereka. Tekan `Ctrl + C` di layar paling pertama installer (pilihan keyboard), dan Omarchy akan menawarkan untuk menyiapkan mesin untuk pemilik lain sebagai gantinya. Sistem langsung terinstal, tetapi semua penyiapan pribadi — tata letak keyboard, nama pengguna, kata sandi — ditunda hingga mesin melakukan boot untuk pertama kalinya. Drive tetap terenkripsi secara default, dan kata sandi yang dipilih pemilik baru pada boot pertama itu juga menjadi kata sandi enkripsi. (Mesin yang sudah Anda gunakan juga bisa diserahkan tanpa instalasi ulang — lihat [mengatur ulang komputer](48-security.md).)

### Instalasi tanpa pengawasan

ISO juga bisa menginstal sepenuhnya sendiri — tanpa keyboard, tanpa wizard — ketika konfigurasinya diberikan padanya di drive kedua. Itulah cara memperlakukan Omarchy sebagai citra dasar untuk VM dan armada mesin. Lihat [instalasi tanpa pengawasan](51-unattended-installs.md).

### Instalasi tanpa enkripsi

Omarchy diinstal dengan enkripsi secara default. Itu adalah pilihan yang aman dan bertanggung jawab untuk komputer mana pun yang mungkin hilang atau dicuri. Anda tidak ingin siapa pun yang memiliki akses ke perangkat keras Anda bisa mendapatkan data Anda!

Namun dalam keadaan khusus, seperti instalasi Omarchy jarak jauh di komputer yang terlindungi atau untuk instalasi sekali pakai tanpa data sensitif, Anda mungkin ingin menginstal tanpa enkripsi. Anda bisa menekan `Ctrl + C` pada konfirmasi pemformatan disk untuk beralih ke instalasi tanpa enkripsi.

### Bahasa

Omarchy berbicara dalam 50 bahasa — kumpulan yang sama seperti omarchy.org — dan bahasa Inggris adalah default-nya. Untuk beralih, buka menu Omarchy dan pergi ke _Pengaturan > Bahasa_, atau jalankan `omarchy language <code>` di terminal (`omarchy language list` menampilkan kode-kodenya). Menu, desktop, dan notifikasi Omarchy sendiri langsung berubah bahasa, dan setiap aplikasi yang Anda buka setelahnya juga mengikutinya. Aplikasi yang sudah terbuka akan beralih setelah Anda memulai ulangnya.

### Bantuan jika Anda mentok

Jika Anda mentok, Anda biasanya bisa menemukan seseorang yang bersedia membantu di kanal _#omarchy-help_ di [Discord komunitas](https://omarchy.org/discord).
