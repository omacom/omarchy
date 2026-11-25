# Dukungan Mac

## Omarchy untuk Apple Silicon

Omarchy untuk Apple Silicon adalah solusi resmi Omacom, pertama kali dirilis bersama Omarchy 4.5. Ia terinstal berdampingan dengan macOS, dan Anda memilih di antara keduanya saat Mac Anda menyala.

Mendapat pemberitahuan tentang Omarchy Mac? Buka [Datang dari Omarchy Mac](#coming-from-omarchy-mac).

Ia berjalan di Mac berikut ini:

| Mac | Chip |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Mac M4 dan yang lebih baru belum didukung. Dukungan M4 sedang dalam pengujian di kanal edge dan akan hadir berikutnya. Penginstal memeriksa Mac Anda sebelum mengubah apa pun.

Di Mac Apple Silicon mana pun, termasuk M4 dan yang lebih baru, Anda dapat menjalankan Omarchy di mesin virtual dengan [Try Omarchy](https://github.com/omacom/try-omarchy).

### Yang Anda butuhkan

- macOS 15 Sequoia atau yang lebih baru, dan akun administrator
- Ruang disk kosong untuk Omarchy. Penginstal menyarankan ukuran dan membiarkan Anda mengubahnya.
- Cadangan Mac Anda, daya, dan koneksi internet. Instalasi mengunduh beberapa gigabita.

### Menginstal

Anda menginstal dari macOS. Instal Omarchy Installer dengan [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Atau unduh Omarchy Installer terbaru dari [halaman rilisnya](https://github.com/omacom/omarchy-mac-installer/releases) dan buka.

Penginstal memeriksa Mac Anda, menunjukkan rencananya kepada Anda, dan membuat ruang untuk Omarchy dengan mengecilkan partisi macOS. macOS tetap berada di disk dan tidak perlu drive USB. Setelah tahap pertama selesai, ia memandu Anda menyelesaikan penyiapan di macOS Recovery: matikan, tahan tombol daya hingga "Loading startup options" muncul, pilih Omarchy, dan ikuti langkah-langkahnya.

Saat pertama kali boot, Omarchy meminta kata sandi yang mengenkripsi disknya. Tidak ada kunci pemulihan: jika Anda lupa kata sandinya, file Omarchy Anda tidak dapat dipulihkan.

Untuk beralih antara Omarchy dan macOS nanti, matikan, lalu tahan tombol daya hingga opsi startup muncul dan pilih salah satu.

### Datang dari Omarchy Mac

Omarchy Mac kini menjadi bagian dari Omarchy untuk Apple Silicon, dan setiap Mac yang menjalankannya didukung. Instalasi Anda saat ini tetap berjalan, dan paket sistemnya tetap diperbarui, tetapi tidak lagi mendapat pembaruan Omarchy. Tidak ada tenggat waktu dan tidak ada peningkatan di tempat: Anda mencadangkan, menghapus instalasi lama, menginstal dari awal, dan memulihkan. Langkah 2 sampai 5 berlangsung di macOS, jadi buka halaman ini di ponsel Anda sebelum Anda memulai ulang.

1. **Cadangkan dari Omarchy, ke luar Mac.** Menghapus instalasi lama akan menghapusnya, dan macOS tidak dapat membaca disk Omarchy. Salin folder home Anda ke drive eksternal atau komputer lain, termasuk kunci SSH dan GPG, profil browser, dan pekerjaan yang belum di-push. Simpan daftar paket Anda dengan `pacman -Qqe > ~/packages.txt`. Cadangkan juga macOS, karena menghapus dan menginstal sama-sama mengubah ukuran disknya.
2. **Nyalakan Mac Anda di macOS.** Matikan, tahan tombol daya hingga opsi startup muncul, dan pilih macOS.
3. **Instal Omarchy Installer** seperti yang ditunjukkan di [Menginstal](#installing).
4. **Hapus instalasi lama.** Buka Omarchy Installer dan pilih Installation > Remove Omarchy. Ia menunjukkan apa yang akan dihapusnya dan mengembalikan ruangnya ke macOS. Jika ia tidak mengenali instalasi Anda, ia berhenti tanpa mengubah disk. Minta bantuan di [Discord](https://discord.gg/tXFUdasqhY) daripada menghapus partisi secara manual, yang dapat menghapus macOS.
5. **Instal Omarchy untuk Apple Silicon** dengan penginstal.
6. **Pulihkan file Anda.** Kembalikan pengaturan Anda sedikit demi sedikit daripada menyalin seluruh `~/.config` menimpa default baru, karena pengaturan lama dapat menimpanya.

### Perlu diketahui

- Di MacBook M1 dan M2, bangunkan dari tidur dengan membuka tutupnya atau menekan tombol daya.
- Pertanyaan atau masalah: tanyakan di [Discord](https://discord.gg/tXFUdasqhY) kami.

[README penginstal](https://github.com/omacom/omarchy-mac-installer#readme) mencakup kanal rilis, memperbarui penginstal, dan menghapus Omarchy.

## Mac Intel

Dalam pengujian sederhana, kami berhasil mencapai peningkatan performa 36% pada MacBook Pro 2019 hanya dengan menginstal Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Menginstal Omarchy di Mac

Omarchy hanya mendukung menjadi **satu-satunya** OS yang terinstal saat ini. Selama instalasi, drive akan dibersihkan dan MacOS tidak lagi dapat di-boot.

Anda masih dapat memulihkannya nanti melalui Internet Recovery jika Anda mau.

Untuk bagian ini, kami anggap Anda sudah meninjau [Memulai](02-getting-started.md) dan drive USB Anda sudah siap. Jika belum, lakukan itu sekarang.

#### Nonaktifkan Secure Boot

Perlu menonaktifkan Secure Boot Apple untuk dapat mem-boot USB yang dapat di-boot, serta OS-nya. Untuk menonaktifkannya, lakukan hal berikut:

1. Matikan Mac Anda
2. Nyalakan dan _segera_ tekan dan tahan Command-R hingga Anda melihat layar pemuatan muncul
3. Pilih pengguna Anda dan masukkan kata sandi Anda jika diminta
4. Setelah berada di layar pemulihan, pilih **Utilities > Startup Security Utility** dari menubar
5. Masukkan kata sandi Anda saat diminta untuk mengautentikasi
6. Pilih "No Security" dari opsi Secure Boot
7. Pilih "Allow booting from external or removable media" dari opsi External Boot

#### Mulai Instalasi

1. Masukkan drive USB
2. Mulai ulang Mac Anda dan _segera_ tekan dan tahan Option hingga Anda melihat layar perangkat boot
3. Pilih perangkat EFI Boot berwarna oranye
4. Lanjutkan dengan [instal seperti biasa](02-getting-started.md)

Penginstal mendeteksi perangkat keras Mac dan menerapkan perbaikan yang dibutuhkan secara otomatis: driver dan firmware Wi-Fi Broadcom, driver kamera FaceTime HD pada mesin dengan Broadcom 1570 (firmware-nya diunduh dari Apple setelah Mac online, karena penginstal bekerja offline), driver keyboard SPI pada model MacBook yang membutuhkannya, dan perbaikan suspend NVMe untuk model yang sama tersebut.

### Batasan yang Diketahui

Anggota komunitas terus-menerus mengerjakan solusi untuk tantangan-tantangan ini, jadi jika hal ini bermasalah bagi Anda, bergabunglah dengan #omarchy-on-other di [Discord](https://discord.gg/tXFUdasqhY) kami dan lihat apakah ada metode terbaru untuk mengatasinya.

#### Kamera FaceTime HD

Driver kamera membuat mesin hang jika dimuat saat Mac berhibernasi, jadi driver tersebut dibongkar terlebih dahulu. Driver itu tidak dapat dibongkar saat ada aplikasi yang membuka kamera, jadi hibernasi dibatalkan dengan notifikasi yang menyebutkan nama aplikasinya: tutup aplikasi itu dan lakukan hibernasi lagi. Itu termasuk hibernasi otomatis saat baterai kritis, dan suspend-then-hibernate, yang ditolak sebelum melakukan suspend. Suspend biasa ditolak oleh driver itu sendiri saat kamera terbuka, tanpa notifikasi.

Firmware kamera diunduh dari Apple, jadi kamera hanya berfungsi setelah Mac online. Pengunduhan dimulai saat boot dan dicoba ulang setiap 15 menit selagi masalahnya adalah jaringan; jika file dari Apple telah berubah, pengunduhan berhenti dan menunggu pembaruan Omarchy. Jika kamera tidak muncul, `journalctl -u facetimehd-firmware-fetcher` menjelaskan alasannya, `sudo systemctl restart facetimehd-firmware-fetcher` mencoba lagi, dan reboot memuat driver jika pengunduhan selesai tetapi kamera masih belum ada.

#### Perangkat dengan Chip T1

Chip Apple T1 diperkenalkan pada akhir 2016 dan digunakan secara eksklusif pada model MacBook Pro generasi pertama dengan Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Masalah yang Diketahui

- Touch Bar tidak berfungsi
- Suara tidak berfungsi

#### Perangkat dengan Chip T2

Chip Keamanan Apple T2 diperkenalkan pada 2017. Chip T2 dihentikan seiring transisi ke Apple silicon (chip seri M) mulai 2020.

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

Pada model-model ini, penginstal secara otomatis menyiapkan kernel `linux-t2` yang telah di-patch, konfigurasi audio T2, firmware Wi-Fi/Bluetooth Broadcom dari Apple, dan kontrol kipas melalui `t2fanrd`. Touch Bar berjalan pada dukungan bawaan kernel bergaya Boot Camp.

#### iMac Retina 5K (2017)

IMac 27 inci tahun 2017 tidak memiliki chip T2, jadi penginstal menyiapkannya seperti Mac Intel lainnya.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Masalah yang Diketahui

- Layar tidak berjalan pada resolusi asli 5120×2880: panelnya terdiri dari dua tile, dan driver bawaan hanya menyalakan satu
- Suara tidak berfungsi
- Kontrol kecerahan tidak berpengaruh
- Tidur membuat mesin hang; hanya power cycle yang dapat memulihkannya

Patcher komunitas untuk model ini memperbaiki layar, suara, dan kecerahan: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
