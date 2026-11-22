# Sokongan Mac

## Omarchy untuk Apple Silicon

Omarchy untuk Apple Silicon ialah penyelesaian rasmi Omacom, pertama kali dikeluarkan dengan Omarchy 4.5. Ia dipasang bersebelahan dengan macOS, dan anda memilih antara kedua-duanya apabila Mac anda dimulakan.

Terima notis tentang Omarchy Mac? Pergi ke [Berasal daripada Omarchy Mac](#coming-from-omarchy-mac).

Ia berjalan pada Mac berikut:

| Mac | Cip |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Mac M4 dan yang lebih baharu belum disokong lagi. Sokongan M4 sedang diuji pada saluran edge dan akan datang seterusnya. Pemasang akan menyemak Mac anda sebelum ia mengubah apa-apa.

Pada mana-mana Mac Apple Silicon, termasuk M4 dan yang lebih baharu, anda boleh menjalankan Omarchy dalam mesin maya dengan [Try Omarchy](https://github.com/omacom/try-omarchy).

### Apa yang anda perlukan

- macOS 15 Sequoia atau yang lebih baharu, dan akaun pentadbir
- Ruang cakera kosong untuk Omarchy. Pemasang mencadangkan saiz dan membenarkan anda mengubahnya.
- Sandaran Mac anda, kuasa, dan sambungan internet. Pemasangan memuat turun beberapa gigabait.

### Pemasangan

Anda memasang daripada macOS. Pasang Omarchy Installer dengan [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Atau muat turun Omarchy Installer terbaharu daripada [halaman keluarannya](https://github.com/omacom/omarchy-mac-installer/releases) dan bukanya.

Pemasang menyemak Mac anda, menunjukkan pelan kepada anda, dan menyediakan ruang untuk Omarchy dengan mengecilkan partisi macOS. macOS kekal pada cakera dan tiada pemacu USB diperlukan. Apabila peringkat pertama selesai, ia membimbing anda menyelesaikan persediaan dalam macOS Recovery: matikan, tahan butang kuasa sehingga "Loading startup options" muncul, pilih Omarchy, dan ikut langkah-langkahnya.

Pada but pertama, Omarchy meminta kata laluan yang menyulitkan cakeranya. Tiada kunci pemulihan: jika anda terlupa kata laluan, fail Omarchy anda tidak boleh dipulihkan.

Untuk bertukar antara Omarchy dan macOS kemudian, matikan, kemudian tahan butang kuasa sehingga pilihan permulaan muncul dan pilih satu.

### Berasal daripada Omarchy Mac

Omarchy Mac kini sebahagian daripada Omarchy untuk Apple Silicon, dan setiap Mac yang menjalankannya disokong. Pemasangan semasa anda terus berjalan, dan pakej sistemnya masih dikemas kini, tetapi ia tidak lagi menerima kemas kini Omarchy. Tiada tarikh akhir dan tiada naik taraf di tempat: anda membuat sandaran, membuang pemasangan lama, memasang semula dari awal, dan memulihkan. Langkah 2 hingga 5 berlaku dalam macOS, jadi buka halaman ini pada telefon anda sebelum anda memulakan semula.

1. **Buat sandaran daripada Omarchy, di luar Mac.** Membuang pemasangan lama akan memadamkannya, dan macOS tidak boleh membaca cakera Omarchy. Salin folder utama anda ke pemacu luaran atau komputer lain, termasuk kunci SSH dan GPG, profil pelayar dan kerja yang belum ditolak. Simpan senarai pakej anda dengan `pacman -Qqe > ~/packages.txt`. Buat sandaran macOS juga, kerana membuang dan memasang kedua-duanya mengubah saiz cakeranya.
2. **Mulakan Mac anda dalam macOS.** Matikan, tahan butang kuasa sehingga pilihan permulaan muncul, dan pilih macOS.
3. **Pasang Omarchy Installer** seperti yang ditunjukkan dalam [Pemasangan](#installing).
4. **Buang pemasangan lama.** Buka Omarchy Installer dan pilih Installation > Remove Omarchy. Ia menunjukkan apa yang akan dipadamkan dan mengembalikan ruang kepada macOS. Jika ia tidak mengenali pemasangan anda, ia berhenti tanpa mengubah cakera. Minta bantuan dalam [Discord](https://discord.gg/tXFUdasqhY) dan bukannya memadam partisi secara manual, yang boleh memadam macOS.
5. **Pasang Omarchy untuk Apple Silicon** dengan pemasang.
6. **Pulihkan fail anda.** Kembalikan tetapan anda sedikit demi sedikit dan bukannya menyalin semua `~/.config` ke atas lalai baharu, kerana tetapan lama boleh mengatasinya.

### Perkara yang perlu diketahui

- Pada MacBook M1 dan M2, bangun daripada tidur dengan membuka penutup atau menekan butang kuasa.
- Soalan atau masalah: bertanya dalam [Discord](https://discord.gg/tXFUdasqhY) kami.

[README pemasang](https://github.com/omacom/omarchy-mac-installer#readme) merangkumi saluran keluaran, mengemas kini pemasang dan membuang Omarchy.

## Mac Intel

Dalam ujian ringkas, kami dapat mencapai peningkatan prestasi 36% pada MacBook Pro 2019 hanya dengan memasang Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Memasang Omarchy pada Mac

Omarchy buat masa ini hanya menyokong menjadi **satu-satunya** OS yang dipasang. Semasa pemasangan, pemacu akan dipadamkan sepenuhnya dan MacOS tidak lagi boleh dibutkan.

Anda masih boleh memulihkannya kemudian melalui Internet Recovery jika anda mahu.

Untuk bahagian ini, kami anggap anda sudah menyemak [Bermula](02-getting-started.md) dan pemacu USB anda sudah sedia. Jika belum, lakukannya sekarang.

#### Lumpuhkan Secure Boot

Secure Boot Apple perlu dilumpuhkan untuk membutkan USB boleh but, serta OS. Untuk melumpuhkannya, lakukan yang berikut:

1. Matikan Mac anda
2. Hidupkannya dan _segera_ tekan dan tahan Command-R sehingga anda melihat skrin pemuatan muncul
3. Pilih pengguna anda dan masukkan kata laluan anda jika diminta
4. Setelah berada dalam skrin pemulihan, pilih **Utilities > Startup Security Utility** daripada bar menu
5. Masukkan kata laluan anda apabila diminta untuk mengesahkan
6. Pilih "No Security" daripada pilihan Secure Boot
7. Pilih "Allow booting from external or removable media" daripada pilihan External Boot

#### Mulakan Pemasangan

1. Masukkan pemacu USB
2. Mulakan semula Mac anda dan _segera_ tekan dan tahan Option sehingga anda melihat skrin peranti but
3. Pilih peranti EFI Boot berwarna oren
4. Teruskan dengan [pemasangan seperti biasa](02-getting-started.md)

Pemasang mengesan perkakasan Mac dan menggunakan pembaikan yang diperlukan secara automatik: pemacu dan perisian tegar Wi-Fi Broadcom, pemacu papan kekunci SPI pada model MacBook yang memerlukannya, dan pembaikan gantung NVMe untuk model yang sama tersebut.

### Had yang Diketahui

Ahli komuniti sentiasa berusaha mencari penyelesaian untuk cabaran ini jadi jika ini bermasalah untuk anda, sertai #omarchy-on-other dalam [Discord](https://discord.gg/tXFUdasqhY) kami dan lihat sama ada terdapat sebarang kaedah terkini untuk menyelesaikannya.

#### Peranti dengan Cip T1

Cip Apple T1 diperkenalkan pada akhir 2016 dan digunakan secara eksklusif dalam model MacBook Pro generasi pertama dengan Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Isu yang Diketahui

- Touch Bar tidak berfungsi
- Bunyi tidak berfungsi

#### Peranti dengan Cip T2

Cip Keselamatan Apple T2 diperkenalkan pada 2017. Cip T2 telah ditamatkan dengan peralihan kepada Apple silicon (cip siri M) bermula pada 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

Pada model ini, pemasang menyediakan secara automatik kernel `linux-t2` yang ditampal, konfigurasi audio T2, perisian tegar Wi-Fi/Bluetooth Broadcom Apple, dan kawalan kipas melalui `t2fanrd`. Touch Bar berjalan pada sokongan gaya Boot Camp terbina dalam kernel.

#### iMac Retina 5K (2017)

27-inch iMac 2017 tidak mempunyai cip T2, jadi pemasang menyediakannya seperti Mac Intel yang lain.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Isu yang Diketahui

- Paparan tidak berjalan pada resolusi asalnya 5120×2880: panel tersebut ialah dua jubin, dan pemacu stok hanya menyalakan satu
- Bunyi tidak berfungsi
- Kawalan kecerahan tidak memberi kesan
- Tidur menyebabkan mesin tergantung; hanya kitaran kuasa yang memulihkannya

Penampal komuniti untuk model ini membaiki paparan, bunyi dan kecerahan: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
