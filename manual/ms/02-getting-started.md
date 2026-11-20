# Bermula

Omarchy dipasang menggunakan ISO. Anda boleh memilih antara pemasangan cakera penuh, yang mengambil alih keseluruhan pemacu, atau pemasangan ruang kosong, yang meletakkan Omarchy dalam ruang yang belum diperuntukkan pada pemacu — begitulah cara anda membuat dwi-but bersama Windows atau OS lain (lihat [pemasangan dwi-but](50-dual-boot-install.md) — ambil perhatian bahawa anda perlu mematikan BitLocker dalam Windows terlebih dahulu). Walau apa pun pilihan anda, pemasangan secara lalai menggunakan penyulitan penuh, dan pilihan cakera penuh akan memadam pemacu yang dipilih, jadi pastikan anda membuat sandaran sebelum menggunakan pemacu sedia ada!

[Muat turun ISO Omarchy](https://omarchy.org/) terlebih dahulu, letakkannya pada pemacu USB (gunakan [Rufus](https://rufus.ie/) pada Windows, [balenaEtcher](https://etcher.balena.io/) pada Mac, atau [caligula](https://github.com/ifd3f/caligula) pada Linux), dan but daripadanya.

_Anda mesti mematikan Secure Boot dan/atau TPM dalam BIOS. Anda perlu mematikannya untuk dapat memasang Omarchy. Ia ialah skim keselamatan Microsoft yang ditujukan untuk Windows dan pengedaran Linux yang bersekutu dengan Microsoft._

Kemudian jawab soalan konfigurasi, dan sahkannya seperti ini:

 ![install-config](images/install-config.webp)

Kemudian pilih pemacu untuk pemasangan anda, dan berehat sambil menonton persembahan pemasangan berjalan. Ia boleh selesai dalam masa kurang daripada seminit pada mesin moden terpantas, tetapi ia tidak sepatutnya mengambil masa lebih daripada 5 minit walaupun pada komputer yang lebih lama.

 ![install-done](images/install-done.webp)

Kini anda sudah bersedia untuk menggunakan Omarchy!

### Gunakan papan kekunci berwayar atau 2.4ghz!

Penyulitan cakera penuh tidak akan membenarkan anda memasukkan kata laluan daripada papan kekunci Bluetooth semasa permulaan. Sama seperti anda tidak boleh menggunakan papan kekunci Bluetooth untuk memasuki BIOS pada PC. Anda memerlukan papan kekunci yang sama ada menggunakan dongle 2.4ghz atau kabel (yang jauh lebih baik dari segi kependaman lagipun!). Saya sendiri amat menyukai [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Memasang untuk pemilik lain

Jika anda menyediakan mesin untuk orang lain — ahli keluarga, pekerja baharu, pembeli — anda tidak patut menjawab soalan peribadi bagi pihak mereka. Tekan `Ctrl + C` pada skrin pertama pemasang (pemilihan papan kekunci), dan Omarchy akan menawarkan untuk menyediakan mesin untuk pemilik lain. Sistem akan dipasang serta-merta, tetapi semua persediaan peribadi — susun atur papan kekunci, nama pengguna, kata laluan — ditangguhkan sehingga mesin dibut buat kali pertama. Pemacu masih disulitkan secara lalai, dan kata laluan yang dipilih oleh pemilik baharu pada but pertama itu juga menjadi kata laluan penyulitan. (Mesin yang telah anda gunakan juga boleh diserahkan tanpa pemasangan semula — lihat [menetapkan semula komputer](48-security.md).)

### Pemasangan tanpa pengawasan

ISO juga boleh memasang sepenuhnya dengan sendiri — tanpa papan kekunci, tanpa wizard — apabila konfigurasinya diberikan pada pemacu kedua. Begitulah cara untuk menganggap Omarchy sebagai imej asas untuk VM dan kumpulan mesin. Lihat [pemasangan tanpa pengawasan](51-unattended-installs.md).

### Pemasangan tanpa penyulitan

Omarchy dipasang dengan penyulitan secara lalai. Ia pilihan yang selamat dan bertanggungjawab untuk mana-mana komputer yang mungkin hilang atau dicuri. Anda tidak mahu sesiapa yang mempunyai akses kepada perkakasan anda dapat memperoleh data anda!

Tetapi dalam keadaan khas, seperti pemasangan Omarchy jauh pada komputer yang dilindungi atau untuk pemasangan sementara tanpa data sensitif, anda mungkin mahu memasang tanpa penyulitan. Anda boleh menekan `Ctrl + C` pada pengesahan pemformatan cakera untuk beralih kepada pemasangan tanpa penyulitan.

### Bahasa

Omarchy bertutur dalam 50 bahasa — set yang sama seperti omarchy.org — dan bahasa Inggeris ialah lalainya. Untuk menukarnya, buka menu Omarchy dan pergi ke _Tetapan > Wilayah > Bahasa_, atau jalankan `omarchy language <code>` dalam terminal (`omarchy language list` menunjukkan kod-kodnya). Menu, desktop, dan pemberitahuan Omarchy sendiri berubah bahasa serta-merta, dan setiap aplikasi yang anda buka selepas itu turut mengikutinya. Aplikasi yang sudah dibuka akan bertukar sebaik sahaja anda memulakannya semula.

Untuk mengekalkan bahasa tetapi menulis tarikh, masa, nombor, wang, unit dan saiz kertas mengikut cara wilayah lain (bahasa Inggeris dengan tarikh Eropah dan jam 24 jam, contohnya), pilih wilayah di bawah _Tetapan > Wilayah > Format_, di mana setiap pilihan menunjukkan contoh, atau jalankan `omarchy region <code>` (`omarchy region list` menunjukkan kod-kodnya). _Sama seperti bahasa_ mengembalikan kepada format bahasa itu sendiri. Seperti pertukaran bahasa, ia terpakai pada aplikasi yang anda buka selepas itu.

### Bantuan jika anda tersekat

Jika anda tersekat, anda biasanya boleh menemui seseorang yang sudi membantu dalam saluran _#omarchy-help_ di [Discord komuniti](https://omarchy.org/discord).
