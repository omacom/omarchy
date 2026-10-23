# Pembaruan

Omarchy dan paketmu tetap mutakhir melalui _Perbarui > Omarchy_ di menu Omarchy (`Super + Space`).

Omarchy itu sendiri dipasang sebagai paket pacman biasa dari [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), jadi pembaruan memasang [rilis Omarchy terbaru](https://github.com/omacom/omarchy/releases), menjalankan migrasi yang tertunda untuk menyinkronkan sistemmu dengan yang terbaru, dan memperbarui semua paket sistem dari [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) dan [AUR](https://aur.archlinux.org/) (jika kamu telah memasang paket AUR apa pun).

Saat rilis baru dibuat, ikon panah lingkaran akan muncul di sebelah kanan jam-mu. Klik itu dan proses pembaruan akan dimulai.

![update-available](images/update-available.webp)

### Empat saluran

Omarchy diperbarui sepanjang empat saluran: stable, RC, edge, dan dev. Pemasangan baru dimulai pada saluran stable, yang melacak [rilis resmi](https://github.com/omacom/omarchy/releases/), serta [mirror Arch Omarchy stable](https://github.com/omacom-io/omarchy-mirror) yang berjalan satu bulan di belakang yang terbaru, jadi kami dapat menangkap ketidakcocokan baru apa pun yang memerlukan perubahan konfigurasi sebelum menyebabkan masalah bagi orang-orang.

Tetapi jika kamu ingin membantu menemukan potensi masalah tersebut, kamu dapat berjalan di saluran edge. Itu akan membuat paket Omarchy-mu melacak build pengembangan terbaru, dan memungkinkan kamu memperbarui ke paket Arch terbaru segera setelah tersedia. Kamu hanya boleh melakukan ini jika kamu berpengalaman dengan Linux, dan tahu cara memulihkan sistem yang bermasalah.

Sebelum rilis besar baru apa pun, kami akan melakukan validasi akhir menggunakan saluran RC. Jika kamu tertarik membantu pemolesan akhir, datanglah nongkrong di #omarchy-release-candidates di Discord.

Terakhir, ada saluran dev, yang menghubungkan Omarchy langsung ke checkout git dari kode sumber di `~/omarchy`, digabungkan dengan paket edge. Kamu hanya boleh menggunakan saluran ini jika kamu pengguna Linux berpengalaman, bekerja langsung pada Omarchy, dan bersedia mentolerir kerusakan.

Kamu dapat beralih antar saluran menggunakan _Perbarui > Channel_ dari menu Omarchy (atau `omarchy-channel-set` di terminal).

### Pembaruan firmware

Paketmu bukan satu-satunya hal yang menjadi basi. Banyak laptop dan periferal mengirimkan firmware BIOS, SSD, dan dock melalui Linux Vendor Firmware Service, dan _Perbarui > Firmware_ di menu Omarchy akan mengambil dan memasang apa pun yang menunggu perangkat kerasmu. Ini memasang `fwupd` pertama kali kamu menjalankannya. Banyak firmware hanya dapat ditulis selama reboot, jadi jangan terkejut jika diminta untuk itu.

### Peringatan tentang pembaruan pacman/yay langsung

Jika kamu sudah familier dengan Arch, kamu mungkin tergoda untuk hanya menjalankan `pacman -Syu` atau `yay -Syu` sendiri, tetapi jika kamu melakukan itu, kamu akan melewatkan snapshot, migrasi, dan pembaruan konfigurasi yang dijalankan Omarchy bersama paket baru. Itulah mengapa Omarchy akan benar-benar menghentikan peningkatan sistem langsung dan mengarahkan kamu ke `omarchy update` sebagai gantinya. (Jika kamu benar-benar tahu apa yang kamu lakukan, penjaga akan memberitahumu cara melewatinya untuk satu transaksi.)

### Mengembalikan pembaruan yang buruk

Jika kamu pernah mengalami masalah setelah melakukan pembaruan, kamu dapat mengembalikan sistemmu ke snapshot yang diambil sebelum pembaruan. Cukup mulai ulang dan pilih snapshot di menu pemuatan boot dari sebelum kamu memulai pembaruan.

![bootloader](images/bootloader.webp)

Jika entah bagaimana berkas konfigurasimu telah rusak, kamu juga dapat melakukan pemasangan ulang Omarchy menggunakan `omarchy reinstall` di terminal. Ini akan memasang ulang semua paket Omarchy bawaan, menempatkan kamu di stable dan menurunkan paket apa pun yang terlalu baru, dan mengatur ulang semua berkas konfigurasi. Perhatikan bahwa semua perubahan konfigurasi pengguna terhadap bawaan Omarchy akan ditimpa dengan melakukan ini!
