# Dukungan Mac

Omarchy memiliki dukungan bawaan untuk **Mac Intel**. Saat ini ada beberapa keterbatasan yang diketahui, tetapi selama Anda menyadarinya dan tidak masalah dengan hal itu; Anda bisa memberikan kehidupan baru pada Mac lama Anda dengan memasang Omarchy.

Harap diperhatikan bahwa pemasangan di Mac seri M saat ini tidak didukung secara langsung. Anda bisa mengetahui lebih lanjut tentang keadaan hal ini di #omarchy-on-other di [Discord](https://discord.gg/tXFUdasqhY) kami.

Dalam sebuah pengujian sederhana, kami berhasil mencapai peningkatan performa sebesar 36% pada MacBook Pro 2019 hanya dengan menginstal Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Menginstal Omarchy di Mac

Omarchy saat ini hanya mendukung menjadi **satu-satunya** OS yang terinstal. Selama pemasangan, drive akan dihapus total dan MacOS tidak akan bisa di-boot lagi.

Anda tetap bisa memulihkannya nanti melalui Internet Recovery jika mau.

Untuk bagian ini, kami anggap Anda sudah meninjau [Memulai](02-getting-started.md) dan drive USB Anda sudah siap. Jika belum, silakan lakukan itu sekarang.

#### Nonaktifkan Secure Boot

Secure Boot dari Apple perlu dinonaktifkan agar bisa mem-boot USB yang dapat di-boot, begitu juga OS-nya. Untuk menonaktifkannya, lakukan hal berikut:

1. Matikan Mac Anda
2. Nyalakan dan _segera_ tekan dan tahan Command-R sampai Anda melihat layar pemuatan muncul
3. Pilih pengguna Anda dan masukkan kata sandi jika diminta
4. Setelah berada di layar pemulihan, pilih **Utilities > Startup Security Utility** dari bilah menu
5. Masukkan kata sandi Anda saat diminta untuk melakukan autentikasi
6. Pilih "No Security" dari opsi Secure Boot
7. Pilih "Allow booting from external or removable media" dari opsi External Boot

#### Mulai Pemasangan

1. Masukkan drive USB
2. Restart Mac Anda dan _segera_ tekan dan tahan Option sampai Anda melihat layar perangkat boot
3. Pilih perangkat EFI Boot yang berwarna oranye
4. Lanjutkan dengan [instal seperti biasa](02-getting-started.md)

Pemasang mendeteksi perangkat keras Mac dan menerapkan perbaikan yang diperlukan secara otomatis: driver dan firmware Wi-Fi Broadcom, driver keyboard SPI pada model MacBook yang membutuhkannya, dan perbaikan suspend NVMe untuk model yang sama.

### Keterbatasan yang Diketahui

Anggota komunitas terus-menerus mengerjakan solusi untuk tantangan-tantangan ini, jadi jika hal-hal ini bermasalah bagi Anda, bergabunglah dengan #omarchy-on-other di [Discord](https://discord.gg/tXFUdasqhY) kami dan lihat apakah ada metode terbaru untuk mengatasinya.

#### Perangkat dengan Chip T1

Chip Apple T1 diperkenalkan pada akhir 2016 dan hanya digunakan pada model MacBook Pro generasi pertama dengan Touch Bar.
- MacBook Pro 13-inch (2016, dua port Thunderbolt 3) – Model: A1706
- MacBook Pro 13-inch (2016, empat port Thunderbolt 3) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Masalah yang Diketahui

- Touch Bar tidak berfungsi
- Suara tidak berfungsi

#### Perangkat dengan Chip T2

Chip Keamanan Apple T2 diperkenalkan pada tahun 2017. Chip T2 dihentikan produksinya seiring transisi ke Apple silicon (chip seri M) yang dimulai pada tahun 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, empat port Thunderbolt 3) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, dua port Thunderbolt 3) – Model: A2159
- MacBook Pro 13-inch (2019, empat port Thunderbolt 3) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, dua port Thunderbolt 3) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

Pada model-model ini, pemasang secara otomatis menyiapkan kernel `linux-t2` yang sudah di-patch, konfigurasi audio T2, firmware Wi-Fi/Bluetooth Broadcom dari Apple, dan kontrol kipas melalui `t2fanrd`. Touch Bar berjalan dengan dukungan bawaan kernel bergaya Boot Camp.

#### iMac Retina 5K (2017)

IMac 27-inch tahun 2017 tidak memiliki chip T2, jadi pemasang menyiapkannya seperti Mac Intel lainnya.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Masalah yang Diketahui

- Layar tidak berjalan pada resolusi aslinya 5120×2880: panelnya terdiri dari dua tile, dan driver bawaan hanya menyalakan satu
- Suara tidak berfungsi
- Kontrol kecerahan tidak berpengaruh
- Sleep membuat mesin hang; hanya mematikan dan menyalakan ulang yang bisa memulihkannya

Sebuah patcher dari komunitas untuk model ini memperbaiki layar, suara, dan kecerahan: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
