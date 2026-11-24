# Pembaruan

Omarchy dan paket-paket Anda tetap diperbarui melalui _Pembaruan > Omarchy_ di menu Omarchy (`Super + Space`).

Omarchy sendiri terpasang sebagai paket pacman biasa dari [Repositori Paket Omarchy](https://github.com/omacom-io/omarchy-pkgs), jadi pembaruan akan memasang [rilis Omarchy terbaru](https://github.com/omacom/omarchy/releases), menjalankan migrasi apa pun yang tertunda agar sistem Anda selaras dengan versi terbaru, dan memperbarui semua paket sistem dari [Mirror Arch Omarchy](https://github.com/omacom-io/omarchy-mirror) dan [AUR](https://aur.archlinux.org/) (jika Anda telah memasang paket AUR apa pun).

Ketika rilis baru dibuat, ikon panah melingkar akan muncul di sebelah kanan jam Anda. Klik ikon tersebut dan proses pembaruan akan dimulai.

![update-available](images/update-available.webp)

### Empat kanal

Omarchy diperbarui melalui empat kanal: stable, RC, edge, dan dev. Instalasi baru dimulai di kanal stable, yang mengikuti [rilis resmi](https://github.com/omacom/omarchy/releases/), serta [mirror Arch Omarchy stable](https://github.com/omacom-io/omarchy-mirror) yang berjalan satu bulan di belakang versi terbaru, agar kami bisa menangkap ketidakcocokan baru apa pun yang memerlukan perubahan konfigurasi sebelum hal itu menimbulkan masalah bagi orang-orang.

Namun jika Anda ingin membantu menemukan potensi masalah tersebut, Anda bisa menggunakan kanal edge. Itu akan membuat paket Omarchy Anda tetap mengikuti build pengembangan terbaru, dan memungkinkan Anda memperbarui ke paket Arch terbaru segera setelah tersedia. Anda hanya boleh melakukan ini jika Anda berpengalaman dengan Linux, dan tahu cara memulihkan sistem yang bermasalah.

Sebelum rilis mayor baru apa pun, kami akan melakukan validasi akhir menggunakan kanal RC. Jika Anda tertarik membantu penyempurnaan akhir, mampirlah ke #omarchy-release-candidates di Discord.

Terakhir, ada kanal dev, yang menghubungkan Omarchy langsung ke checkout git kode sumber di `~/omarchy`, dikombinasikan dengan paket edge. Anda hanya boleh menggunakan kanal ini jika Anda pengguna Linux berpengalaman, bekerja langsung pada Omarchy, dan bersedia menoleransi kerusakan.

Anda bisa berpindah antar kanal menggunakan _Pembaruan > Kanal_ dari menu Omarchy (atau `omarchy channel set <stable|rc|edge|dev>` di terminal, dengan `omarchy channel current` untuk melihat posisi Anda saat ini).

### Berpindah kernel

Omarchy mem-boot kernel `linux-omarchy` miliknya sendiri, tetapi Anda bisa tetap memasang kernel lain di sampingnya, seperti kernel Arch bawaan `linux` atau build eksperimental yang sedang Anda uji. Ketika ada lebih dari satu kernel, _Pembaruan > Kernel_ di menu Omarchy akan mencantumkannya dengan tanda centang di samping kernel yang di-boot secara default. Pilih kernel lain, masukkan kata sandi Anda sekali, dan kernel itu akan di-boot setelah restart berikutnya. Kernel lainnya tetap ada di menu boot, jadi Anda masih bisa memilihnya secara manual jika default yang baru memberi Anda masalah. Di terminal, gunakan `omarchy kernel` untuk melihat default saat ini, `omarchy kernel list` untuk melihat yang terpasang, dan `omarchy kernel set <kernel>` untuk berpindah.

### Pembaruan firmware

Paket Anda bukan satu-satunya hal yang menjadi usang. Banyak laptop dan periferal mengirimkan firmware BIOS, SSD, dan dock melalui Linux Vendor Firmware Service, dan _Pembaruan > Firmware_ di menu Omarchy akan mengambil dan memasang apa pun yang sedang menunggu untuk perangkat keras Anda. Fitur ini memasang `fwupd` saat pertama kali Anda menjalankannya. Banyak firmware hanya bisa ditulis saat reboot, jadi jangan heran jika Anda diminta untuk melakukannya.

Ketika Anda perlu mengubah pengaturan di BIOS itu sendiri, tahan `Alt` di menu sistem (`Super + Escape`) dan _Mulai Ulang_ berubah menjadi _Mulai Ulang ke BIOS_, yang akan melakukan restart langsung ke pengaturan firmware tanpa harus menekan tombol yang tepat saat boot. Dari terminal, gunakan `omarchy system firmware`.

### Peringatan tentang pembaruan langsung pacman/yay

Jika Anda sudah familier dengan Arch, Anda mungkin tergoda untuk langsung menjalankan `pacman -Syu` atau `yay -Syu` sendiri, tetapi jika Anda melakukan itu, Anda akan melewatkan snapshot, migrasi, dan pembaruan konfigurasi yang dijalankan Omarchy bersama paket baru. Karena itulah Omarchy justru akan menghentikan upgrade sistem langsung dan mengarahkan Anda ke `omarchy update`. (Jika Anda benar-benar tahu apa yang Anda lakukan, pelindung tersebut akan memberi tahu Anda cara melewatinya untuk satu transaksi.)

### Mengembalikan pembaruan yang buruk

Jika Anda pernah mengalami masalah setelah melakukan pembaruan, Anda bisa mengembalikan sistem Anda ke snapshot yang diambil sebelum pembaruan. Cukup restart dan pilih snapshot di menu boot loading dari sebelum Anda memulai pembaruan.

![bootloader](images/bootloader.webp)

Jika entah bagaimana file konfigurasi Anda telah rusak, Anda juga bisa melakukan instalasi ulang Omarchy menggunakan `omarchy reinstall` di terminal. Ini akan memasang ulang semua paket Omarchy default, menempatkan Anda di stable (edge di Apple Silicon) dan menurunkan paket apa pun yang terlalu baru, serta mengatur ulang semua file konfigurasi. Perhatikan bahwa semua perubahan konfigurasi pengguna Anda terhadap default Omarchy akan ditimpa dengan melakukan ini!
