# Pembaruan

Omarchy dan paket-paket Anda tetap diperbarui melalui _Update > Omarchy_ di menu Omarchy (`Super + Space`).

Omarchy sendiri terpasang sebagai paket pacman biasa dari [Repositori Paket Omarchy](https://github.com/omacom-io/omarchy-pkgs), jadi sebuah pembaruan akan memasang [rilis Omarchy terbaru](https://github.com/omacom/omarchy/releases), menjalankan migrasi apa pun yang tertunda untuk menyinkronkan sistem Anda dengan versi terbaru, dan memperbarui semua paket sistem dari [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) dan [AUR](https://aur.archlinux.org/) (jika Anda telah memasang paket AUR apa pun).

Ketika rilis baru dibuat, ikon panah melingkar akan muncul di sebelah kanan jam Anda. Klik ikon tersebut dan proses pembaruan akan dimulai.

![update-available](images/update-available.webp)

### Empat kanal

Omarchy diperbarui melalui empat kanal: stable, RC, edge, dan dev. Instalasi baru dimulai pada kanal stable, yang mengikuti [rilis resmi](https://github.com/omacom/omarchy/releases/), serta [mirror Arch Omarchy stable](https://github.com/omacom-io/omarchy-mirror) yang berjalan satu bulan di belakang versi terbaru, jadi kami dapat menangkap ketidakcocokan baru apa pun yang memerlukan perubahan konfigurasi sebelum hal itu menyebabkan masalah bagi orang-orang.

Namun jika Anda ingin membantu menemukan potensi masalah tersebut, Anda dapat menggunakan kanal edge. Itu akan membuat paket Omarchy Anda tetap mengikuti build pengembangan terbaru, dan memungkinkan Anda memperbarui ke paket Arch terbaru segera setelah tersedia. Anda hanya boleh melakukan ini jika Anda berpengalaman dengan Linux, dan tahu cara memulihkan sistem yang bermasalah.

Sebelum setiap rilis besar baru, kami akan melakukan validasi akhir menggunakan kanal RC. Jika Anda tertarik membantu penyempurnaan akhir, datanglah dan bergabung di #omarchy-release-candidates di Discord.

Terakhir, ada kanal dev, yang menghubungkan Omarchy langsung ke checkout git kode sumber di `~/omarchy`, digabungkan dengan paket edge. Anda hanya boleh menggunakan kanal ini jika Anda pengguna Linux berpengalaman, bekerja langsung pada Omarchy, dan bersedia menoleransi kerusakan.

Anda dapat beralih antar kanal menggunakan _Update > Channel_ dari menu Omarchy (atau `omarchy-channel-set` di terminal).

### Beralih kernel

Omarchy mem-boot kernel `linux-omarchy` miliknya sendiri, tetapi Anda dapat menyimpan kernel lain terpasang di sampingnya, seperti kernel Arch bawaan `linux` atau build eksperimental yang sedang Anda uji. Ketika ada lebih dari satu kernel, _Update > Kernel_ di menu Omarchy mencantumkannya dengan tanda centang di samping kernel yang melakukan boot secara default. Pilih yang lain, masukkan kata sandi Anda sekali, dan kernel tersebut akan melakukan boot setelah restart berikutnya. Kernel lainnya tetap berada di menu boot, jadi Anda masih dapat memilih salah satunya secara manual jika default baru memberi Anda masalah. Di terminal, perintahnya adalah `omarchy-kernel` untuk melihat default saat ini, `omarchy-kernel list` untuk melihat apa saja yang terpasang, dan `omarchy-kernel set <kernel>` untuk beralih.

### Pembaruan firmware

Paket Anda bukan satu-satunya hal yang menjadi usang. Banyak laptop dan periferal mengirimkan firmware BIOS, SSD, dan dock melalui Linux Vendor Firmware Service, dan _Update > Firmware_ di menu Omarchy akan mengambil dan memasang apa pun yang sedang menunggu untuk perangkat keras Anda. Fitur ini akan memasang `fwupd` pada pertama kali Anda menjalankannya. Banyak firmware hanya dapat ditulis selama reboot, jadi jangan terkejut jika Anda diminta untuk melakukannya.

Ketika Anda perlu mengubah pengaturan di BIOS itu sendiri, tahan `Alt` di menu sistem (`Super + Escape`) dan _Reboot_ berubah menjadi _Reboot to BIOS_, yang akan melakukan restart langsung ke pengaturan firmware tanpa harus menekan tombol yang tepat pada saat boot. Dari terminal, perintahnya adalah `omarchy system firmware`.

### Peringatan tentang pembaruan langsung pacman/yay

Jika Anda sudah familiar dengan Arch, Anda mungkin tergoda untuk langsung menjalankan `pacman -Syu` atau `yay -Syu` sendiri, tetapi jika Anda melakukan itu, Anda akan melewatkan snapshot, migrasi, dan pembaruan konfigurasi yang dijalankan Omarchy bersama paket baru. Itulah mengapa Omarchy justru akan menghentikan peningkatan sistem langsung dan mengarahkan Anda ke `omarchy update` sebagai gantinya. (Jika Anda benar-benar tahu apa yang Anda lakukan, pengaman tersebut akan memberi tahu Anda cara melewatinya untuk satu transaksi.)

### Mengembalikan pembaruan yang buruk

Jika Anda pernah mengalami masalah setelah melakukan pembaruan, Anda dapat mengembalikan sistem Anda ke snapshot yang diambil sebelum pembaruan. Cukup restart dan pilih snapshot di menu pemuatan boot dari sebelum Anda memulai pembaruan.

![bootloader](images/bootloader.webp)

Jika entah bagaimana file konfigurasi Anda telah rusak, Anda juga dapat melakukan instalasi ulang Omarchy menggunakan `omarchy reinstall` di terminal. Ini akan memasang ulang semua paket default Omarchy, menempatkan Anda di stable dan menurunkan versi paket apa pun yang terlalu baru, serta mengatur ulang semua file konfigurasi. Perhatikan bahwa semua perubahan konfigurasi pengguna yang Anda buat terhadap default Omarchy akan ditimpa saat melakukan ini!
