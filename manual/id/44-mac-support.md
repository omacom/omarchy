# Dukungan Mac

Omarchy memiliki dukungan bawaan untuk **Mac Intel**. Ada beberapa keterbatasan yang diketahui saat ini, tetapi selama kamu menyadarinya dan tidak keberatan dengan hal itu; kamu bisa memberi kehidupan baru pada Mac lamamu dengan memuat Omarchy.

Harap dicatat bahwa pemasangan di Mac seri-M tidak didukung secara langsung saat ini. Kamu bisa mengetahui lebih lanjut tentang keadaan ini di #omarchy-on-other di [Discord](https://discord.gg/tXFUdasqhY) kami.

Dalam pengujian sederhana, kami mampu mencapai peningkatan performa 36% pada MacBook Pro 2019 hanya dengan memasang Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Memasang Omarchy di Mac

Omarchy saat ini hanya mendukung menjadi OS **satu-satunya** yang terpasang. Selama pemasangan, drive akan dihapus dan MacOS tidak lagi bisa di-boot.

Kamu masih bisa memulihkannya nanti melalui Internet Recovery jika kamu mau.

Untuk bagian ini, kami akan menganggap kamu sudah meninjau [Memulai](02-getting-started.md) dan drive USB kamu siap. Jika belum, lakukan itu sekarang.

#### Nonaktifkan Secure Boot

Secure Boot Apple perlu dinonaktifkan untuk bisa boot USB yang bisa di-boot, serta OS-nya. Untuk menonaktifkannya, lakukan hal berikut:

1. Matikan Mac kamu
2. Nyalakan dan _segera_ tekan dan tahan Command-R sampai kamu melihat layar pemuatan muncul
3. Pilih penggunamu dan masukkan kata sandimu jika diminta
4. Setelah berada di layar pemulihan, pilih **Utilities > Startup Security Utility** dari menubar
5. Masukkan kata sandimu saat diminta untuk autentikasi
6. Pilih "No Security" dari opsi Secure Boot
7. Pilih "Allow booting from external or removable media" dari opsi External Boot

#### Mulai Pemasangan

1. Masukkan drive USB
2. Mulai ulang Mac kamu dan _segera_ tekan dan tahan Option sampai kamu melihat layar perangkat boot
3. Pilih perangkat EFI Boot berwarna oranye
4. Lanjutkan dengan [pemasangan seperti biasa](02-getting-started.md)

Pemasang mendeteksi perangkat keras Mac dan menerapkan perbaikan yang dibutuhkan secara otomatis: driver dan firmware Wi-Fi Broadcom, driver keyboard SPI pada model MacBook yang membutuhkannya, dan perbaikan penangguhan NVMe untuk model-model yang sama.

### Keterbatasan yang Diketahui

Anggota komunitas terus-menerus mengerjakan solusi untuk tantangan-tantangan ini jadi jika ini bermasalah bagimu, bergabunglah dengan #omarchy-on-other di [Discord](https://discord.gg/tXFUdasqhY) kami dan lihat apakah ada metode terkini untuk mengatasinya.

#### Perangkat dengan Chip T1

Chip Apple T1 diperkenalkan pada akhir 2016 dan digunakan secara eksklusif pada model MacBook Pro generasi pertama dengan Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Masalah yang Diketahui

- Touch Bar tidak berfungsi
- Suara tidak berfungsi

#### Perangkat dengan Chip T2

Chip Keamanan Apple T2 diperkenalkan pada 2017. Chip T2 dihentikan dengan transisi ke Apple silicon (chip seri-M) mulai 2020.

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

Pada model-model ini, pemasang secara otomatis mengatur kernel `linux-t2` yang ditambal, konfigurasi audio T2, firmware Wi-Fi/Bluetooth Broadcom Apple, dan kontrol kipas melalui `t2fanrd`. Touch Bar berjalan pada dukungan bawaan kernel bergaya Boot Camp.
