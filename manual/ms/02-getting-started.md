# Memulakan Langkah

Omarchy dipasang menggunakan ISO. Anda boleh memilih antara pemasangan cakera penuh, yang mengambil alih keseluruhan pemacu, atau pemasangan ruang kosong, yang meletakkan Omarchy dalam ruang yang belum diperuntukkan pada pemacu — begitulah caranya anda melakukan dwi-but bersama Windows atau OS lain (lihat [pemasangan dwi-but](50-dual-boot-install.md) — ambil perhatian bahawa anda perlu mematikan BitLocker dalam Windows terlebih dahulu). Walau apa pun, pemasangan secara lalai menggunakan penyulitan penuh, dan pilihan cakera penuh akan memadam pemacu yang dipilih, jadi pastikan anda membuat sandaran sebelum menggunakan pemacu sedia ada!

[Muat turun ISO Omarchy](https://omarchy.org/) dahulu, masukkannya ke dalam pemacu USB (gunakan [Rufus](https://rufus.ie/) pada Windows, [balenaEtcher](https://etcher.balena.io/) pada Mac, atau [caligula](https://github.com/ifd3f/caligula) pada Linux), dan but daripadanya.

_Anda mesti mematikan Secure Boot dan/atau TPM dalam BIOS. Anda perlu mematikan perkara ini untuk dapat memasang Omarchy. Ia merupakan skim keselamatan Microsoft yang dimaksudkan untuk Windows dan pengedaran Linux yang bersekutu dengan Microsoft._

Kemudian jawab soalan konfigurasi, dan sahkannya seperti ini:

 ![install-config](images/install-config.webp)

Kemudian pilih pemacu untuk pemasangan anda, dan duduk berehat sambil menyaksikan pertunjukan pemasangan berjalan. Ia boleh selesai dalam masa kurang daripada seminit pada mesin moden terpantas, tetapi tidak sepatutnya mengambil masa lebih daripada 5 minit walaupun pada komputer yang lebih lama.

 ![install-done](images/install-done.webp)

Kini anda sudah bersedia untuk ber-Omarchy!

### Gunakan papan kekunci berwayar atau 2.4ghz!

Penyulitan cakera penuh tidak akan membenarkan anda memasukkan kata laluan daripada papan kekunci Bluetooth semasa permulaan. Sama seperti anda tidak boleh menggunakan papan kekunci Bluetooth untuk memasuki BIOS pada PC. Anda memerlukan papan kekunci yang sama ada menggunakan dongle 2.4ghz atau kabel (yang jauh lebih baik untuk kependaman lagipun!). Saya sendiri amat menyukai [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Memasang untuk pemilik lain

Jika anda menyediakan mesin untuk orang lain — ahli keluarga, pekerja baharu, pembeli — anda tidak sepatutnya menjawab soalan peribadi bagi pihak mereka. Tekan `Ctrl + C` pada skrin pertama pemasang (pemilihan papan kekunci), dan Omarchy akan menawarkan untuk menyediakan mesin untuk pemilik lain sebaliknya. Sistem dipasang serta-merta, tetapi semua persediaan peribadi — susun atur papan kekunci, nama pengguna, kata laluan — ditangguhkan sehingga mesin dibut buat kali pertama. Pemacu masih disulitkan secara lalai, dan kata laluan yang dipilih pemilik baharu pada but pertama itu turut menjadi kata laluan penyulitan. (Mesin yang anda sudah gunakan juga boleh diserahkan tanpa pemasangan semula — lihat [menetapkan semula komputer](48-security.md).)

### Pemasangan tanpa pengawasan

ISO juga boleh memasang sepenuhnya dengan sendiri — tanpa papan kekunci, tanpa wizard — apabila konfigurasinya diberikan pada pemacu kedua. Itulah cara untuk menganggap Omarchy sebagai imej asas untuk VM dan mesin armada. Lihat [pemasangan tanpa pengawasan](51-unattended-installs.md).

### Pemasangan tanpa penyulitan

Omarchy dipasang dengan penyulitan secara lalai. Ia merupakan pilihan yang selamat dan bertanggungjawab untuk mana-mana komputer yang berkemungkinan hilang atau dicuri. Anda tidak mahu sesiapa yang mempunyai akses kepada perkakasan anda dapat mendapatkan data anda!

Tetapi dalam keadaan khas, seperti pemasangan Omarchy jauh pada komputer terlindung atau untuk pemasangan pakai buang tanpa data sensitif, anda mungkin mahu memasang tanpa penyulitan. Anda boleh menekan `Ctrl + C` pada pengesahan pemformatan cakera untuk bertukar kepada pemasangan tanpa penyulitan.

### Bahasa

Omarchy bertutur dalam 50 bahasa — set yang sama seperti omarchy.org — dan bahasa Inggeris ialah lalainya. Untuk bertukar, buka menu Omarchy dan pergi ke _Setup > Region > Language_, atau jalankan `omarchy language <code>` dalam terminal (`omarchy language list` menunjukkan kod-kodnya). Menu, desktop dan pemberitahuan Omarchy sendiri bertukar bahasa serta-merta, dan setiap aplikasi yang anda buka selepas itu turut mengikutinya. Aplikasi yang sudah dibuka akan bertukar sebaik sahaja anda memulakannya semula.

Untuk mengekalkan bahasa tetapi menulis tarikh, masa, nombor, wang, unit dan saiz kertas mengikut cara rantau lain (contohnya bahasa Inggeris dengan tarikh Eropah dan jam 24 jam), pilih rantau di bawah _Setup > Region > Formats_, di mana setiap pilihan menunjukkan contoh, atau jalankan `omarchy region formats <code>` (`omarchy region formats list` menunjukkan kod-kodnya). _Same as language_ kembali kepada format bahasa itu sendiri. Seperti pertukaran bahasa, ia terpakai pada aplikasi yang anda buka selepas itu.

### Bantuan jika anda buntu

Jika anda buntu, anda biasanya boleh menemui seseorang yang sudi membantu dalam saluran _#omarchy-help_ di [Discord komuniti](https://omarchy.org/discord).
