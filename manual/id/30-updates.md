# Pembaruan

Omarchy dan paket-paket Anda selalu diperbarui melalui _Pembaruan > Omarchy_ di menu Omarchy (`Super + Space`).

Omarchy sendiri terpasang sebagai paket pacman biasa dari [Repositori Paket Omarchy](https://github.com/omacom-io/omarchy-pkgs), jadi pembaruan akan memasang [rilis Omarchy terbaru](https://github.com/omacom/omarchy/releases), menjalankan migrasi apa pun yang tertunda agar sistem Anda selaras dengan versi terbaru, dan memperbarui semua paket sistem dari [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) dan [AUR](https://aur.archlinux.org/) (jika Anda telah memasang paket AUR apa pun).

Saat rilis baru tersedia, ikon panah melingkar akan muncul di sebelah kanan jam Anda. Klik ikon tersebut dan proses pembaruan akan dimulai.

![update-available](images/update-available.webp)

### Empat kanal

Omarchy diperbarui melalui empat kanal: stable, RC, edge, dan dev. Instalasi baru dimulai di kanal stable, yang mengikuti [rilis resmi](https://github.com/omacom/omarchy/releases/), serta [mirror Arch Omarchy stable](https://github.com/omacom-io/omarchy-mirror) yang tertinggal satu bulan dari versi terbaru, agar kami dapat menemukan ketidakcocokan baru apa pun yang memerlukan perubahan konfigurasi sebelum hal itu menimbulkan masalah bagi pengguna.

Namun jika Anda ingin membantu menemukan potensi masalah tersebut, Anda dapat menggunakan kanal edge. Kanal itu akan membuat paket Omarchy Anda mengikuti build pengembangan terbaru, dan memungkinkan Anda memperbarui ke paket Arch terbaru segera setelah tersedia. Anda hanya boleh melakukan ini jika Anda berpengalaman dengan Linux, dan tahu cara memulihkan sistem yang bermasalah.

Sebelum setiap rilis besar baru, kami akan melakukan validasi akhir menggunakan kanal RC. Jika Anda tertarik membantu penyempurnaan akhir, bergabunglah di #omarchy-release-candidates di Discord.

Terakhir, ada kanal dev, yang menghubungkan Omarchy langsung ke checkout git kode sumber di `~/omarchy`, digabungkan dengan paket edge. Anda hanya boleh menggunakan kanal ini jika Anda adalah pengguna Linux berpengalaman, bekerja langsung pada Omarchy, dan bersedia menerima kerusakan.

Anda dapat beralih antar kanal menggunakan _Pembaruan > Kanal_ dari menu Omarchy (atau `omarchy-channel-set` di terminal).

### Beralih kernel

Omarchy mem-boot kernel `linux-omarchy` miliknya sendiri, tetapi Anda dapat tetap memasang kernel lain di sampingnya, seperti kernel Arch bawaan `linux` atau build eksperimental yang sedang Anda uji. Saat ada lebih dari satu kernel, _Pembaruan > Kernel_ di menu Omarchy akan mencantumkannya dengan tanda centang di samping kernel yang di-boot secara default. Pilih kernel lain, masukkan kata sandi Anda sekali, dan kernel itu akan di-boot setelah restart berikutnya. Kernel lain tetap ada di menu boot, jadi Anda masih dapat memilihnya secara manual jika default baru menimbulkan masalah. Di terminal, gunakan `omarchy-kernel` untuk melihat default saat ini, `omarchy-kernel list` untuk melihat yang terpasang, dan `omarchy-kernel set <kernel>` untuk beralih.

### Pembaruan firmware

Paket Anda bukan satu-satunya hal yang bisa menjadi usang. Banyak laptop dan periferal menyediakan firmware BIOS, SSD, dan dock melalui Linux Vendor Firmware Service, dan _Pembaruan > Firmware_ di menu Omarchy akan mengambil dan memasang apa pun yang menunggu untuk perangkat keras Anda. Fitur ini akan memasang `fwupd` saat pertama kali Anda menjalankannya. Banyak firmware hanya dapat ditulis saat reboot, jadi jangan terkejut jika Anda diminta untuk melakukannya.

### Peringatan tentang pembaruan langsung dengan pacman/yay

Jika Anda sudah familier dengan Arch, Anda mungkin tergoda untuk langsung menjalankan `pacman -Syu` atau `yay -Syu` sendiri, tetapi jika Anda melakukannya, Anda akan melewatkan snapshot, migrasi, dan pembaruan konfigurasi yang dijalankan Omarchy bersama paket baru. Itulah sebabnya Omarchy justru akan menghentikan peningkatan sistem secara langsung dan mengarahkan Anda ke `omarchy update`. (Jika Anda benar-benar tahu apa yang Anda lakukan, pelindung tersebut akan memberi tahu Anda cara melewatinya untuk satu transaksi.)

### Mengembalikan pembaruan yang bermasalah

Jika Anda pernah mengalami masalah setelah melakukan pembaruan, Anda dapat mengembalikan sistem Anda ke snapshot yang diambil sebelum pembaruan. Cukup restart dan pilih snapshot di menu boot loader dari sebelum Anda memulai pembaruan.

![bootloader](images/bootloader.webp)

Jika entah bagaimana file konfigurasi Anda rusak, Anda juga dapat melakukan pemasangan ulang Omarchy menggunakan `omarchy reinstall` di terminal. Ini akan memasang ulang semua paket default Omarchy, menempatkan Anda di stable dan menurunkan versi paket apa pun yang terlalu baru, serta mengatur ulang semua file konfigurasi. Perhatikan bahwa semua perubahan konfigurasi pengguna Anda terhadap default Omarchy akan ditimpa jika melakukan ini!
