# Sokongan Mac

Omarchy mempunyai sokongan terbina dalam untuk **Intel Macs**. Terdapat beberapa batasan yang diketahui buat masa ini, tetapi selagi anda sedar dan OK dengannya; anda boleh memberi nafas baharu kepada Mac lama anda dengan memasang Omarchy.

Sila ambil perhatian bahawa pemasangan pada Mac siri M tidak disokong secara langsung pada masa ini. Anda boleh mengetahui lebih lanjut tentang statusnya dalam #omarchy-on-other di [Discord](https://discord.gg/tXFUdasqhY) kami.

Dalam satu ujian ringkas, kami berjaya mencapai peningkatan prestasi sebanyak 36% pada MacBook Pro 2019 hanya dengan memasang Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Memasang Omarchy pada Mac

Omarchy hanya menyokong menjadi **satu-satunya** OS yang dipasang buat masa ini. Semasa pemasangan, pemacu akan dipadamkan sepenuhnya dan MacOS tidak lagi boleh dibut.

Anda masih boleh memulihkannya kemudian melalui Internet Recovery jika anda mahu.

Untuk bahagian ini, kami akan menganggap anda telah menyemak [Langkah Permulaan](02-getting-started.md) dan pemacu USB anda telah sedia. Jika belum, lakukan sekarang.

#### Nyahaktifkan Secure Boot

Secure Boot Apple perlu dinyahaktifkan untuk membut USB boleh but, serta OS tersebut. Untuk menyahaktifkannya, lakukan yang berikut:

1. Matikan Mac anda
2. Hidupkannya dan _segera_ tekan dan tahan Command-R sehingga anda melihat skrin pemuatan muncul
3. Pilih pengguna anda dan masukkan kata laluan anda jika diminta
4. Setelah berada dalam skrin pemulihan, pilih **Utilities > Startup Security Utility** daripada bar menu
5. Masukkan kata laluan anda apabila diminta untuk pengesahan
6. Pilih "No Security" daripada pilihan Secure Boot
7. Pilih "Allow booting from external or removable media" daripada pilihan External Boot

#### Mulakan Pemasangan

1. Masukkan pemacu USB
2. Mulakan semula Mac anda dan _segera_ tekan dan tahan Option sehingga anda melihat skrin peranti but
3. Pilih peranti EFI Boot berwarna oren
4. Teruskan dengan [pemasangan seperti biasa](02-getting-started.md)

Pemasang mengesan perkakasan Mac dan menggunakan pembaikan yang diperlukan secara automatik: pemacu dan firmware Wi-Fi Broadcom, pemacu papan kekunci SPI pada model MacBook yang memerlukannya, dan pembaikan gantung NVMe untuk model yang sama.

### Batasan yang Diketahui

Ahli komuniti sentiasa berusaha mencari penyelesaian kepada cabaran ini, jadi jika ini bermasalah untuk anda, sertai #omarchy-on-other di [Discord](https://discord.gg/tXFUdasqhY) kami dan lihat jika ada kaedah terkini untuk menyelesaikannya.

#### Peranti dengan Cip T1

Cip Apple T1 diperkenalkan pada akhir 2016 dan digunakan secara eksklusif dalam model MacBook Pro generasi pertama dengan Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Isu yang Diketahui

- Touch Bar tidak berfungsi
- Bunyi tidak berfungsi

#### Peranti dengan Cip T2

Cip Keselamatan Apple T2 diperkenalkan pada 2017. Cip T2 telah dihentikan dengan peralihan kepada Apple silicon (cip siri M) bermula pada 2020.

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

Pada model-model ini, pemasang secara automatik menyediakan kernel `linux-t2` yang telah ditampal, konfigurasi audio T2, firmware Wi-Fi/Bluetooth Broadcom Apple, dan kawalan kipas melalui `t2fanrd`. Touch Bar berjalan menggunakan sokongan gaya Boot Camp terbina dalam kernel.

#### iMac Retina 5K (2017)

iMac 27-inch 2017 tidak mempunyai cip T2, jadi pemasang menyediakannya seperti Intel Macs yang lain.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Isu yang Diketahui

- Paparan tidak berjalan pada resolusi asalnya 5120×2880: panel tersebut terdiri daripada dua jubin, dan pemacu stok hanya menyalakan satu
- Bunyi tidak berfungsi
- Kawalan kecerahan tidak memberi kesan
- Sleep membuatkan mesin tergantung; hanya kitaran kuasa dapat memulihkannya

Penampal komuniti untuk model ini membaiki paparan, bunyi dan kecerahan: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
