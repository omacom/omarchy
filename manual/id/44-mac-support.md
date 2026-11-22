# Dukungan Mac

## Omarchy untuk Apple Silicon

Omarchy untuk Apple Silicon adalah solusi resmi Omacom, pertama kali dirilis bersama Omarchy 4.5. Omarchy ini terpasang di samping macOS, dan Anda memilih di antara keduanya saat Mac Anda mulai menyala.

Mendapat pemberitahuan tentang Omarchy Mac? Buka [Beralih dari Omarchy Mac](#coming-from-omarchy-mac).

Omarchy ini berjalan pada Mac berikut:

| Mac | Chip |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Mac M4 dan yang lebih baru belum didukung. Dukungan M4 sedang diuji pada saluran edge dan akan hadir berikutnya. Pemasang memeriksa Mac Anda sebelum mengubah apa pun.

Pada Mac Apple Silicon apa pun, termasuk M4 dan yang lebih baru, Anda dapat menjalankan Omarchy di mesin virtual dengan [Try Omarchy](https://github.com/omacom/try-omarchy).

### Yang Anda butuhkan

- macOS 15 Sequoia atau lebih baru, dan akun administrator
- Ruang disk kosong untuk Omarchy. Pemasang menyarankan ukurannya dan memungkinkan Anda mengubahnya.
- Cadangan Mac Anda, daya, dan koneksi internet. Pemasangan mengunduh beberapa gigabita.

### Memasang

Anda memasangnya dari macOS. Pasang Omarchy Installer dengan [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Atau unduh Omarchy Installer terbaru dari [halaman rilisnya](https://github.com/omacom/omarchy-mac-installer/releases) dan buka.

Pemasang memeriksa Mac Anda, menunjukkan rencananya kepada Anda, dan menyediakan ruang untuk Omarchy dengan mengecilkan partisi macOS. macOS tetap berada di disk dan tidak diperlukan drive USB. Saat tahap pertama selesai, pemasang memandu Anda menyelesaikan penyiapan di macOS Recovery: matikan, tahan tombol daya hingga "Loading startup options" muncul, pilih Omarchy, dan ikuti langkah-langkahnya.

Pada boot pertama, Omarchy meminta kata sandi yang mengenkripsi disknya. Tidak ada kunci pemulihan: jika Anda lupa kata sandinya, berkas Omarchy Anda tidak dapat dipulihkan.

Untuk beralih antara Omarchy dan macOS nanti, matikan, lalu tahan tombol daya hingga opsi mulai menyala muncul dan pilih salah satunya.

### Beralih dari Omarchy Mac

Omarchy Mac kini menjadi bagian dari Omarchy untuk Apple Silicon, dan setiap Mac yang menjalankannya didukung. Instalasi Anda saat ini tetap berjalan, dan paket sistemnya tetap diperbarui, tetapi tidak lagi menerima pembaruan Omarchy. Tidak ada tenggat dan tidak ada peningkatan di tempat: Anda mencadangkan, menghapus instalasi lama, memasang baru, dan memulihkan. Langkah 2 hingga 5 berlangsung di macOS, jadi buka halaman ini di ponsel Anda sebelum Anda memulai ulang.

1. **Cadangkan dari Omarchy, di luar Mac.** Menghapus instalasi lama akan menghapusnya, dan macOS tidak dapat membaca disk Omarchy. Salin folder home Anda ke drive eksternal atau komputer lain, termasuk kunci SSH dan GPG, profil browser, dan pekerjaan yang belum di-push. Simpan daftar paket Anda dengan `pacman -Qqe > ~/packages.txt`. Cadangkan macOS juga, karena menghapus dan memasang keduanya mengubah ukuran disknya.
2. **Mulai Mac Anda di macOS.** Matikan, tahan tombol daya hingga opsi mulai menyala muncul, dan pilih macOS.
3. **Pasang Omarchy Installer** seperti ditunjukkan pada [Memasang](#installing).
4. **Hapus instalasi lama.** Buka Omarchy Installer dan pilih Installation > Remove Omarchy. Pemasang menunjukkan apa yang akan dihapusnya dan mengembalikan ruangnya ke macOS. Jika pemasang tidak mengenali instalasi Anda, pemasang berhenti tanpa mengubah disk. Minta bantuan di [Discord](https://discord.gg/tXFUdasqhY) daripada menghapus partisi secara manual, yang dapat menghapus macOS.
5. **Pasang Omarchy untuk Apple Silicon** dengan pemasang.
6. **Pulihkan berkas Anda.** Kembalikan pengaturan Anda sepotong demi sepotong daripada menyalin seluruh `~/.config` menimpa default yang baru, karena pengaturan lama dapat menimpanya.

### Perlu diketahui

- Pada MacBook M1 dan M2, bangunkan dari tidur dengan membuka tutupnya atau menekan tombol daya.
- Pertanyaan atau masalah: tanyakan di [Discord](https://discord.gg/tXFUdasqhY) kami.

[README pemasang](https://github.com/omacom/omarchy-mac-installer#readme) mencakup saluran rilis, memperbarui pemasang, dan menghapus Omarchy.

## Mac Intel

Dalam pengujian sederhana, kami berhasil memperoleh peningkatan performa sebesar 36% pada MacBook Pro 2019 hanya dengan memasang Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Memasang Omarchy di Mac

Omarchy saat ini hanya mendukung menjadi **satu-satunya** OS yang terpasang. Selama pemasangan, drive akan dihapus dan MacOS tidak lagi dapat di-boot.

Anda tetap dapat memulihkannya nanti melalui Internet Recovery jika menginginkannya.

Untuk bagian ini, kami anggap Anda telah membaca [Memulai](02-getting-started.md) dan drive USB Anda sudah siap. Jika belum, lakukan sekarang.

#### Nonaktifkan Secure Boot

Secure Boot Apple perlu dinonaktifkan agar dapat mem-boot USB yang dapat di-boot, serta OS-nya. Untuk menonaktifkannya, lakukan hal berikut:

1. Matikan Mac Anda
2. Nyalakan dan _segera_ tekan dan tahan Command-R hingga Anda melihat layar pemuatan muncul
3. Pilih pengguna Anda dan masukkan kata sandi jika diminta
4. Setelah berada di layar pemulihan, pilih **Utilities > Startup Security Utility** dari bilah menu
5. Masukkan kata sandi Anda saat diminta untuk melakukan autentikasi
6. Pilih "No Security" dari opsi Secure Boot
7. Pilih "Allow booting from external or removable media" dari opsi External Boot

#### Mulai Pemasangan

1. Masukkan drive USB
2. Mulai ulang Mac Anda dan _segera_ tekan dan tahan Option hingga Anda melihat layar perangkat boot
3. Pilih perangkat EFI Boot berwarna oranye
4. Lanjutkan dengan [pemasangan seperti biasa](02-getting-started.md)

Pemasang mendeteksi perangkat keras Mac dan menerapkan perbaikan yang diperlukan secara otomatis: driver dan firmware Wi-Fi Broadcom, driver keyboard SPI pada model MacBook yang membutuhkannya, dan perbaikan penangguhan NVMe untuk model yang sama.

### Keterbatasan yang Diketahui

Anggota komunitas terus-menerus mengerjakan solusi untuk tantangan ini, jadi jika hal ini menjadi masalah bagi Anda, bergabunglah dengan #omarchy-on-other di [Discord](https://discord.gg/tXFUdasqhY) kami dan lihat apakah ada metode terbaru untuk mengatasinya.

#### Perangkat dengan Chip T1

Chip Apple T1 diperkenalkan pada akhir 2016 dan digunakan secara eksklusif pada model MacBook Pro generasi pertama dengan Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Masalah yang Diketahui

- Touch Bar tidak berfungsi
- Suara tidak berfungsi

#### Perangkat dengan Chip T2

Apple T2 Security Chip diperkenalkan pada 2017. Chip T2 dihentikan dengan peralihan ke Apple silicon (chip seri M) mulai 2020.

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

Pada model ini, pemasang secara otomatis menyiapkan kernel `linux-t2` yang telah di-patch, konfigurasi audio T2, firmware Wi-Fi/Bluetooth Broadcom Apple, dan kontrol kipas melalui `t2fanrd`. Touch Bar berjalan pada dukungan bawaan kernel bergaya Boot Camp.

#### iMac Retina 5K (2017)

iMac 27-inch 2017 tidak memiliki chip T2, jadi pemasang menyiapkannya seperti Mac Intel lainnya.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Masalah yang Diketahui

- Layar tidak berjalan pada resolusi aslinya 5120×2880: panel terdiri dari dua ubin, dan driver bawaan hanya menyalakan satu
- Suara tidak berfungsi
- Kontrol kecerahan tidak berpengaruh
- Tidur membuat mesin hang; hanya siklus daya yang dapat memulihkannya

Patcher komunitas untuk model ini memperbaiki layar, suara, dan kecerahan: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
