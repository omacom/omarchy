# Sokongan Mac

Omarchy mempunyai sokongan terbina dalam untuk **Mac Intel**. Terdapat beberapa batasan yang diketahui pada masa ini, tetapi selagi anda sedar dan OK dengannya; anda boleh memberi nafas baharu kepada Mac lama anda dengan memuatkan Omarchy.

Sila ambil perhatian bahawa pemasangan pada Mac siri M tidak disokong secara langsung pada masa ini. Anda boleh mengetahui lebih lanjut tentang keadaan ini di #omarchy-on-other dalam [Discord](https://discord.gg/tXFUdasqhY) kami.

Dalam ujian ringkas, kami dapat mencapai peningkatan prestasi 36% pada MacBook Pro 2019 hanya dengan memasang Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Memasang Omarchy pada Mac

Omarchy hanya menyokong menjadi **satu-satunya** OS yang dipasang pada masa ini. Semasa pemasangan, pemacu akan dipadamkan dan MacOS tidak lagi boleh dibut.

Anda masih boleh memulihkannya kemudian melalui Internet Recovery jika anda mahu.

Untuk bahagian ini, kami akan menganggap anda sudah menyemak [Bermula](02-getting-started.md) dan mempunyai pemacu USB anda sedia. Jika belum, lakukan sekarang.

#### Lumpuhkan Secure Boot

Adalah perlu untuk melumpuhkan Secure Boot Apple untuk membut USB boleh but, serta OS. Untuk melumpuhkannya, lakukan yang berikut:

1. Matikan Mac anda
2. Hidupkannya dan _serta-merta_ tekan dan tahan Command-R sehingga anda melihat skrin pemuatan muncul
3. Pilih pengguna anda dan masukkan kata laluan anda jika digesa
4. Setelah berada di skrin pemulihan, pilih **Utilities > Startup Security Utility** dari bar menu
5. Masukkan kata laluan anda apabila digesa untuk mengesahkan
6. Pilih "No Security" dari pilihan Secure Boot
7. Pilih "Allow booting from external or removable media" dari pilihan External Boot

#### Mulakan Pemasangan

1. Masukkan pemacu USB
2. Mulakan semula Mac anda dan _serta-merta_ tekan dan tahan Option sehingga anda melihat skrin peranti but
3. Pilih peranti EFI Boot berwarna jingga
4. Teruskan dengan [pemasangan seperti biasa](02-getting-started.md)

Pemasang mengesan perkakasan Mac dan menggunakan pembetulan yang diperlukan secara automatik: pemacu dan perisian tegar Wi-Fi Broadcom, pemacu papan kekunci SPI pada model MacBook yang memerlukannya, dan pembetulan suspend NVMe untuk model yang sama.

### Batasan yang Diketahui

Ahli komuniti sentiasa berusaha mencari penyelesaian kepada cabaran ini jadi jika ini bermasalah untuk anda, sertai #omarchy-on-other dalam [Discord](https://discord.gg/tXFUdasqhY) kami dan lihat sama ada terdapat kaedah terkini untuk menyelesaikannya.

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

Pada model ini, pemasang secara automatik menyediakan kernel `linux-t2` yang ditampal, konfigurasi audio T2, perisian tegar Wi-Fi/Bluetooth Broadcom Apple, dan kawalan kipas melalui `t2fanrd`. Touch Bar berjalan pada sokongan gaya Boot Camp terbina dalam kernel.
