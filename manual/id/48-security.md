# Keamanan

Omarchy menganggap keamanan sangat serius. Sistem operasi ini memang dimaksudkan untuk bisa Anda gunakan untuk melakukan _Pekerjaan Nyata_ di _Dunia Nyata_. Di mana kehilangan laptop tidak sampai menimbulkan keadaan darurat keamanan. Jadi inilah yang kami lakukan:

1. *Enkripsi full-disk aktif secara default*: Ini adalah langkah terpenting untuk mengamankan perlindungan fisik data Anda. Jika komputer Anda hilang atau dicuri, data tersebut terenkripsi sepenuhnya menggunakan LUKS (Linux Unified Key Setup) standar. Penginstal memberi Anda opsi untuk tidak menggunakannya untuk mesin sekali pakai (lihat [Memulai](02-getting-started.md)); instalasi tanpa enkripsi tidak memiliki perlindungan ini sama sekali, dan siapa pun yang memegang drive tersebut dapat membacanya.
2. *Firewall aktif secara default*: Semua lalu lintas masuk diblokir secara default, dengan beberapa pengecualian: port 53317 untuk [LocalSend](https://localsend.org/); kueri DNS ke resolver milik komputer itu sendiri di alamat bridge Docker (172.17.0.1), diterima dari rentang alamat privat yang diberikan Docker kepada container-nya; dan DNS multicast (port 5353), yang memungkinkan printer dan perangkat lain di jaringan Anda saling menemukan dan juga mengumumkan nama komputer Anda di sana. Di atas itu semua, firewall tetap mempertahankan izin standar UFW untuk ping, mendapatkan alamat dari router Anda (DHCP), dan penemuan UPnP. Bahkan ssh mati sampai Anda menyalakannya lewat _Setup > Security > SSHD_, yang membuka port 22 (dibatasi laju percobaannya untuk melawan brute force) sebagai bagian dari proses penyiapan. Kami bahkan mengunci akses Docker menggunakan penyiapan [ufw-docker](https://github.com/chaifeng/ufw-docker) untuk mencegah container Anda terekspos ke dunia luar tanpa sengaja.
3. *Arch selalu memiliki pembaruan terbaru*: Arch, distro dasar yang menjadi fondasi Omarchy, adalah distribusi rolling. Ini berarti setiap kerentanan keamanan yang ditemukan dan diperbaiki di paket mana pun akan dengan cepat tersedia untuk dipasang menggunakan `omarchy-update`. Dengan cara itu, Anda selalu menjalankan versi terbaru dan paling aman dari segalanya.
4. *Omarchy memelihara paket dan mirror-nya sendiri*: Secara default, Omarchy hanya mengandalkan paket dari repositori core/extra/multilib milik Arch sendiri dan Omarchy Package Repository miliknya sendiri. Anda bisa memasang perangkat lunak langsung dari AUR, tetapi instalasi dasar tidak melakukannya — hanya beberapa instalasi opsional, seperti browser pihak ketiga, yang mengambil dari AUR.
5. *Cloudflare melindungi kami dari DDoS*: Infrastruktur distribusi Omarchy — ISO, paket Omarchy, mirror Arch — dilindungi di balik perisai DDoS Cloudflare yang tangguh dan dihosting di CDN mereka. Ini memberikan ketersediaan yang luar biasa.

## Mengganti kata sandi Anda

Anda memiliki dua kata sandi pada instalasi terenkripsi: satu yang membuka kunci drive saat boot, dan satu yang Anda gunakan untuk masuk dan `sudo`. Setup membuatnya sama. Keduanya dapat diganti di bawah _Update > Password_ di menu Omarchy — _Drive Encryption_ untuk yang pertama, _User_ untuk yang kedua. Mengganti kata sandi drive akan meminta kata sandi Anda saat ini terlebih dahulu, jadi siapkanlah. Jika perubahan terinterupsi, jalankan _Drive Encryption_ lagi: ia akan meminta kata sandi yang membuka kunci drive saat ini dan menyelesaikan perubahan tersebut.

## Memberikan mesin yang sudah Anda gunakan kepada orang lain

Jika Anda akan menyerahkan mesin Anda kepada orang lain, Anda tidak harus memasangnya ulang. Jalankan _Remove > Factory Reset_ di menu Omarchy, ketik `reset` untuk mengonfirmasi, dan reboot. Itu menghapus setiap akun pengguna dan semua yang ada di `/home`, membuang semua paket dan perubahan sistem yang Anda buat sejak instalasi, dan menghapus identitas mesin — koneksi jaringan, host key, dan semuanya. Yang akan muncul kembali adalah wizard penyiapan dari boot pertama, siap bagi pemilik barunya untuk memasukkan nama, kata sandi, dan kata sandi enkripsi mereka sendiri.

Cara kerjanya adalah dengan memulihkan snapshot baseline yang diambil penginstal, jadi fitur ini hanya tersedia pada mesin yang dipasang dari ISO Omarchy. Dan pada drive tanpa enkripsi, reset adalah penghapusan, bukan penghapusan aman, jadi jika datanya sensitif, lakukan instalasi baru sebagai gantinya.

## sudo tanpa kata sandi

Kadang Anda ingin `sudo` berhenti meminta kata sandi, paling sering ketika agen AI sedang melakukan pekerjaan sistem yang panjang untuk Anda. _Setup > Security > Passwordless Sudo_ menanyakan berapa lama akses diizinkan: **15 menit**, **1 Jam**, **1 Hari**, atau **Secara Permanen**. Ikon peringatan merah muncul di samping indikator bilah menu lainnya selama akses aktif. Klik ikon tersebut atau jalankan perintah itu lagi untuk mematikan akses. Anda juga bisa memberikan jumlah menit Anda sendiri (dari 1 hingga 1440) dengan `omarchy-sudo-passwordless 30`, atau menggunakan `omarchy-sudo-passwordless permanent`.

Akses berjangka waktu kedaluwarsa secara otomatis, termasuk segera setelah melanjutkan dari suspend yang melewati batas waktu. Memulai ulang komputer mengakhirinya lebih awal. Akses permanen tetap bertahan setelah reboot dan tetap aktif sampai Anda menonaktifkannya.

Memperbarui atau menghapus paket pengaturan Omarchy mengakhiri setiap pemberian sementara sebelum dukungan kedaluwarsanya berubah. Jika perintah melaporkan kesalahan otorisasi atau pembersihan, selesaikan terlebih dahulu sebelum mencoba mengaktifkan pemberian lain; kesalahan bukan berarti akses tanpa kata sandi tidak aktif.

Bersikaplah jernih soal yang satu ini: selama fitur ini aktif, apa pun yang berjalan sebagai pengguna Anda dapat melakukan apa pun sebagai root tanpa ditanya. Itulah intinya, dan itulah juga seluruh risikonya.

## Kunci Penandatanganan

Kunci publik untuk semua tanda tangan ISO dan paket repo Omarchy adalah `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifikasi di openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paket `omarchy/omarchy-keyring` juga berisi kunci ini dan akan digunakan untuk meluncurkan setiap potensi pembaruan dengan mulus.

Anda dapat menemukan tanda tangan untuk rilis ISO mana pun dengan menambahkan `.sig` ke URL-nya, seperti `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
