# Bermula

Omarchy dipasang menggunakan ISO. Anda boleh memilih antara pemasangan cakera penuh, yang mengambil alih keseluruhan pemacu, atau pemasangan ruang kosong, yang meletakkan Omarchy dalam ruang yang tidak diperuntukkan pada pemacu — begitulah cara anda membuat dual boot bersama Windows atau OS lain (lihat [pemasangan dual-boot](50-dual-boot-install.md) — ambil perhatian bahawa anda perlu mematikan BitLocker dalam Windows terlebih dahulu). Walau apa pun, pemasangan secara lalai menggunakan penyulitan penuh, dan pilihan cakera penuh akan memadam pemacu yang dipilih, jadi pastikan anda membuat sandaran sebelum menggunakan pemacu sedia ada!

[Muat turun ISO Omarchy](https://omarchy.org/) terlebih dahulu, masukkannya ke dalam pemacu USB (gunakan [balenaEtcher](https://etcher.balena.io/) pada Mac/Windows atau [caligula](https://github.com/ifd3f/caligula) pada Linux), dan boot daripada pemacu tersebut.

_Anda mesti mematikan Secure Boot dan/atau TPM dalam BIOS. Anda perlu mematikan kedua-duanya untuk dapat memasang Omarchy. Kedua-duanya ialah skema keselamatan Microsoft yang ditujukan untuk Windows dan pengedaran Linux yang bersekutu dengan Microsoft._

Kemudian jawab soalan konfigurasi, dan sahkan seperti ini:

 ![install-config](images/install-config.webp)

Kemudian pilih pemacu untuk pemasangan anda, dan duduk santai sambil menonton pertunjukan pemasangan berlangsung. Ia boleh siap dalam masa kurang seminit pada mesin moden terpantas, tetapi ia tidak sepatutnya mengambil masa lebih daripada 5 minit walaupun pada komputer yang lebih lama.

 ![install-done](images/install-done.webp)

Kini anda sudah bersedia untuk Omarchy!

### Gunakan papan kekunci berwayar atau 2.4ghz!

Penyulitan cakera penuh tidak akan membenarkan anda memasukkan kata laluan daripada papan kekunci Bluetooth semasa permulaan. Sama seperti anda tidak boleh menggunakan papan kekunci Bluetooth untuk memasuki BIOS pada PC. Anda memerlukan papan kekunci yang menggunakan sama ada dongle 2.4ghz atau kabel (yang jauh lebih baik untuk kependaman lagipun!). Saya secara peribadi sangat menggemari [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Memasang untuk pemilik lain

Jika anda menyediakan mesin untuk orang lain — ahli keluarga, pekerja baharu, pembeli — anda tidak sepatutnya menjawab soalan peribadi bagi pihak mereka. Tekan `Ctrl + C` pada skrin pertama sekali pemasang (pilihan papan kekunci), dan Omarchy akan menawarkan untuk menyediakan mesin tersebut untuk pemilik lain sebaliknya. Sistem akan dipasang serta-merta, tetapi semua persediaan peribadi — susun atur papan kekunci, nama pengguna, kata laluan — ditangguhkan sehingga mesin boot buat kali pertama. Pemacu masih disulitkan secara lalai, dan kata laluan yang dipilih oleh pemilik baharu semasa boot pertama itu juga menjadi kata laluan penyulitan. (Mesin yang anda telah pun gunakan boleh diserahkan tanpa pemasangan semula juga — lihat [menetapkan semula komputer](48-security.md).)

### Pemasangan tanpa pengawasan

ISO juga boleh memasang sepenuhnya dengan sendirinya — tanpa papan kekunci, tanpa wizard — apabila konfigurasinya diserahkan kepadanya pada pemacu kedua. Begitulah cara melayan Omarchy sebagai imej asas untuk VM dan mesin fleet. Lihat [pemasangan tanpa pengawasan](51-unattended-installs.md).

### Pemasangan tanpa penyulitan

Omarchy dipasang dengan penyulitan secara lalai. Ia ialah pilihan yang selamat dan bertanggungjawab untuk mana-mana komputer yang mungkin hilang atau dicuri. Anda tidak mahu sesiapa yang mempunyai akses kepada perkakasan anda dapat memperoleh data anda!

Tetapi dalam keadaan istimewa, seperti pemasangan Omarchy jauh pada komputer yang dilindungi atau untuk pemasangan pakai buang tanpa data sensitif, anda mungkin mahu memasang tanpa penyulitan. Anda boleh menekan `Ctrl + C` pada pengesahan pemformatan cakera untuk beralih kepada pemasangan tanpa penyulitan.

### Bahasa

Omarchy bertutur dalam 50 bahasa — set yang sama seperti omarchy.org — dan Bahasa Inggeris ialah lalainya. Untuk menukar, buka menu Omarchy dan pergi ke _Persediaan > Bahasa_, atau jalankan `omarchy language <code>` dalam terminal (`omarchy language list` menunjukkan kod-kod tersebut). Menu, desktop, dan pemberitahuan Omarchy sendiri akan bertukar bahasa serta-merta, dan setiap aplikasi yang anda buka selepas itu akan turut mengikutinya. Apl yang telah pun dibuka akan bertukar sebaik sahaja anda memulakannya semula.

### Bantuan jika anda tersekat

Jika anda tersekat, anda biasanya boleh mencari seseorang yang sudi membantu dalam saluran _#omarchy-help_ di [Discord komuniti](https://omarchy.org/discord).
