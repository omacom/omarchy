# Sokongan Mac

## Omarchy untuk Apple Silicon

Omarchy untuk Apple Silicon ialah penyelesaian rasmi Omacom, pertama kali dikeluarkan dengan Omarchy 4.5. Ia dipasang bersebelahan dengan macOS, dan anda memilih antara kedua-duanya apabila Mac anda dimulakan.

Menerima notis tentang Omarchy Mac? Pergi ke [Beralih daripada Omarchy Mac](#coming-from-omarchy-mac).

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

Mac M4 dan yang lebih baharu belum disokong lagi. Sokongan M4 sedang diuji pada saluran edge dan akan menyusul. Pemasang akan menyemak Mac anda sebelum ia mengubah apa-apa.

Pada mana-mana Mac Apple Silicon, termasuk M4 dan yang lebih baharu, anda boleh menjalankan Omarchy dalam mesin maya dengan [Try Omarchy](https://github.com/omacom/try-omarchy).

### Apa yang anda perlukan

- macOS 15 Sequoia atau yang lebih baharu, dan akaun pentadbir
- Ruang cakera kosong untuk Omarchy. Pemasang mencadangkan satu saiz dan membenarkan anda mengubahnya.
- Sandaran Mac anda, kuasa, dan sambungan internet. Pemasangan akan memuat turun beberapa gigabait.

### Pemasangan

Anda memasangnya daripada macOS. Pasang Omarchy Installer dengan [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Atau muat turun Omarchy Installer terbaharu daripada [halaman keluarannya](https://github.com/omacom/omarchy-mac-installer/releases) dan bukanya.

Pemasang akan menyemak Mac anda, menunjukkan pelannya kepada anda, dan menyediakan ruang untuk Omarchy dengan mengecilkan partition macOS. macOS kekal pada cakera dan tiada pemacu USB diperlukan. Apabila peringkat pertama selesai, ia akan memandu anda menyelesaikan persediaan dalam macOS Recovery: matikan, tahan butang kuasa sehingga "Loading startup options" muncul, pilih Omarchy, dan ikuti langkah-langkahnya.

Pada but pertama, Omarchy meminta kata laluan yang menyulitkan cakeranya. Tiada kunci pemulihan: jika anda terlupa kata laluan itu, fail Omarchy anda tidak boleh dipulihkan.

Untuk bertukar antara Omarchy dan macOS kemudian, matikan, kemudian tahan butang kuasa sehingga pilihan permulaan muncul dan pilih satu daripadanya.

### Beralih daripada Omarchy Mac

Omarchy Mac kini sebahagian daripada Omarchy untuk Apple Silicon, dan setiap Mac yang menjalankannya disokong. Pemasangan semasa anda terus berjalan, dan pakej sistemnya masih dikemas kini, tetapi ia tidak lagi menerima kemas kini Omarchy. Tiada tarikh akhir dan tiada naik taraf di tempat: anda membuat sandaran, membuang pemasangan lama, memasang semula dari awal, dan memulihkan. Langkah 2 hingga 5 berlaku dalam macOS, jadi buka halaman ini pada telefon anda sebelum anda memulakan semula.

1. **Buat sandaran daripada Omarchy, di luar Mac.** Membuang pemasangan lama akan memadamkannya, dan macOS tidak boleh membaca cakera Omarchy. Salin folder utama anda ke pemacu luaran atau komputer lain, termasuk kunci SSH dan GPG, profil pelayar dan kerja yang belum ditolak. Simpan senarai pakej anda dengan `pacman -Qqe > ~/packages.txt`. Buat sandaran macOS juga, kerana membuang dan memasang kedua-duanya mengubah saiz cakeranya.
2. **Mulakan Mac anda dalam macOS.** Matikan, tahan butang kuasa sehingga pilihan permulaan muncul, dan pilih macOS.
3. **Pasang Omarchy Installer** seperti yang ditunjukkan dalam [Pemasangan](#installing).
4. **Buang pemasangan lama.** Buka Omarchy Installer dan pilih Installation > Remove Omarchy. Ia menunjukkan apa yang akan dipadamkannya dan mengembalikan ruang itu kepada macOS. Jika ia tidak mengenali pemasangan anda, ia berhenti tanpa mengubah cakera. Minta bantuan dalam [Discord](https://discord.gg/tXFUdasqhY) dan bukannya memadam partition secara manual, yang boleh memadam macOS.
5. **Pasang Omarchy untuk Apple Silicon** dengan pemasang tersebut.
6. **Pulihkan fail anda.** Bawa kembali tetapan anda sedikit demi sedikit dan bukannya menyalin semua `~/.config` ke atas tetapan lalai baharu, kerana tetapan lama boleh menggantikannya.

### Perkara yang perlu diketahui

- Pada MacBook M1 dan M2, bangunkan daripada tidur dengan membuka penutupnya atau menekan butang kuasa.
- Soalan atau masalah: tanya dalam [Discord](https://discord.gg/tXFUdasqhY) kami.

[README pemasang](https://github.com/omacom/omarchy-mac-installer#readme) merangkumi saluran keluaran, mengemas kini pemasang dan membuang Omarchy.

## Mac Intel

Dalam satu ujian ringkas, kami berjaya mencapai peningkatan prestasi sebanyak 36% pada MacBook Pro 2019 hanya dengan memasang Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Memasang Omarchy pada Mac

Omarchy pada masa ini hanya menyokong menjadi **satu-satunya** OS yang dipasang. Semasa pemasangan, pemacu akan dipadamkan sepenuhnya dan MacOS tidak lagi boleh dibut.

Anda masih boleh memulihkannya kemudian melalui Internet Recovery jika anda mahu.

Untuk bahagian ini, kami akan menganggap anda sudah menyemak [Bermula](02-getting-started.md) dan pemacu USB anda sudah sedia. Jika belum, teruskan dan buat sekarang.

#### Lumpuhkan Secure Boot

Anda perlu melumpuhkan Secure Boot Apple untuk membut USB boleh but tersebut, serta OS itu. Untuk melumpuhkannya, lakukan yang berikut:

1. Matikan Mac anda
2. Hidupkannya dan _serta-merta_ tekan dan tahan Command-R sehingga anda melihat skrin pemuatan muncul
3. Pilih pengguna anda dan masukkan kata laluan anda jika diminta
4. Setelah berada dalam skrin pemulihan, pilih **Utilities > Startup Security Utility** daripada bar menu
5. Masukkan kata laluan anda apabila diminta untuk mengesahkan
6. Pilih "No Security" daripada pilihan Secure Boot
7. Pilih "Allow booting from external or removable media" daripada pilihan External Boot

#### Mulakan Pemasangan

1. Masukkan pemacu USB
2. Mulakan semula Mac anda dan _serta-merta_ tekan dan tahan Option sehingga anda melihat skrin peranti but
3. Pilih peranti EFI Boot berwarna jingga
4. Teruskan dengan [pemasangan seperti biasa](02-getting-started.md)

Pemasang mengesan perkakasan Mac dan menggunakan pembaikan yang diperlukan secara automatik: pemacu dan perisian tegar Wi-Fi Broadcom, pemacu kamera FaceTime HD pada mesin dengan Broadcom 1570 (perisian tegarnya dimuat turun daripada Apple sebaik sahaja Mac dalam talian, kerana pemasang berfungsi di luar talian), pemacu papan kekunci SPI pada model MacBook yang memerlukannya, dan pembaikan penggantungan NVMe untuk model yang sama.

### Had yang Diketahui

Ahli komuniti sentiasa berusaha mencari penyelesaian kepada cabaran ini jadi jika perkara ini bermasalah untuk anda, sertai #omarchy-on-other dalam [Discord](https://discord.gg/tXFUdasqhY) kami dan lihat jika terdapat sebarang kaedah terkini untuk menyelesaikannya.

#### Kamera FaceTime HD

Pemacu kamera menyebabkan mesin tergantung jika ia dimuatkan ketika Mac berhibernasi, jadi ia dinyahmuatkan terlebih dahulu. Ia tidak boleh dinyahmuatkan semasa aplikasi membuka kamera, jadi hibernasi dibatalkan dengan pemberitahuan yang menamakan aplikasi tersebut: tutup aplikasi itu dan berhibernasi semula. Ini termasuk berhibernasi secara automatik ketika bateri kritikal, dan suspend-then-hibernate, yang ditolak sebelum ia digantung. Penggantungan biasa ditolak oleh pemacu itu sendiri semasa kamera terbuka, tanpa pemberitahuan.

Perisian tegar kamera dimuat turun daripada Apple, jadi kamera hanya berfungsi sebaik sahaja Mac telah berada dalam talian. Muat turun bermula pada masa but dan dicuba semula setiap 15 minit selagi rangkaian menjadi masalah; jika fail Apple telah berubah, ia berhenti dan menunggu kemas kini Omarchy. Jika kamera tidak muncul, `journalctl -u facetimehd-firmware-fetcher` memberitahu sebabnya, `sudo systemctl restart facetimehd-firmware-fetcher` mencuba lagi, dan but semula memuatkan pemacu jika muat turun telah selesai tetapi kamera masih tiada di sana.

#### Peranti dengan Cip T1

Cip Apple T1 diperkenalkan pada akhir 2016 dan digunakan secara eksklusif dalam model MacBook Pro generasi pertama dengan Touch Bar.
- MacBook Pro 13 inci (2016, dua port Thunderbolt 3) – Model: A1706
- MacBook Pro 13 inci (2016, empat port Thunderbolt 3) – Model: A1708
- MacBook Pro 15 inci (2016) – Model: A1707

#### Isu yang Diketahui

- Touch Bar tidak berfungsi
- Bunyi tidak berfungsi

#### Peranti dengan Cip T2

Cip Keselamatan Apple T2 diperkenalkan pada 2017. Cip T2 telah dihentikan dengan peralihan kepada Apple silicon (cip siri M) bermula pada 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13 inci (2018, empat port Thunderbolt 3) – Model: A1989
- MacBook Pro 15 inci (2018) – Model: A1990
- MacBook Air (Retina, 13 inci, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13 inci (2019, dua port Thunderbolt 3) – Model: A2159
- MacBook Pro 13 inci (2019, empat port Thunderbolt 3) – Model: A2178
- MacBook Pro 15 inci (2019) – Model: A1990
- iMac (Retina 5K, 27 inci, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13 inci (2020, dua port Thunderbolt 3) – Model: A2265
- MacBook Pro 15 inci (2020) – Model: A1990

Pada model ini, pemasang menyediakan secara automatik kernel `linux-t2` yang telah ditampal, konfigurasi audio T2, perisian tegar Wi-Fi/Bluetooth Broadcom Apple, dan kawalan kipas melalui `t2fanrd`. Touch Bar berjalan pada sokongan gaya Boot Camp terbina dalam kernel.

#### iMac Retina 5K (2017)

27 inci iMac 2017 tidak mempunyai cip T2, jadi pemasang menyediakannya seperti Mac Intel yang lain.

- iMac (Retina 5K, 27 inci, 2017) – Model: A1419

#### Isu yang Diketahui

- Paparan tidak berjalan pada resolusi asalnya 5120×2880: panel tersebut terdiri daripada dua jubin, dan pemacu stok hanya menyalakan satu daripadanya
- Bunyi tidak berfungsi
- Kawalan kecerahan tiada kesan
- Tidur menyebabkan mesin tergantung; hanya kitaran kuasa dapat memulihkannya

Penampal komuniti untuk model ini membaiki paparan, bunyi dan kecerahan: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
