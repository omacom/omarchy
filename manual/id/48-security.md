# Keamanan

Omarchy menganggap keamanan sangat serius. Ini dimaksudkan sebagai sistem operasi yang dapat Anda gunakan untuk melakukan _Kerja Nyata_ di _Dunia Nyata_. Di mana kehilangan laptop tidak dapat menyebabkan darurat keamanan. Jadi inilah yang kami lakukan:

1. *Enkripsi disk penuh aktif secara default*: Ini adalah langkah terpenting untuk mengamankan perlindungan fisik data Anda. Jika komputer Anda hilang atau dicuri, data terenkripsi sepenuhnya menggunakan LUKS standar (Linux Unified Key Setup). Installer memungkinkan Anda untuk tidak menggunakannya pada mesin sekali pakai (lihat [Memulai](02-getting-started.md)); instalasi tanpa enkripsi tidak memiliki perlindungan ini sama sekali, dan siapa pun yang memegang drive tersebut dapat membacanya.
2. *Firewall aktif secara default*: Semua lalu lintas masuk diblokir secara default, dengan beberapa pengecualian: port 53317 untuk [LocalSend](https://localsend.org/); kueri DNS ke resolver milik komputer itu sendiri di alamat bridge Docker (172.17.0.1), yang diterima dari rentang alamat privat yang diberikan Docker kepada container-nya; dan DNS multicast (port 5353), yang memungkinkan printer dan perangkat lain di jaringan Anda saling menemukan dan juga mengumumkan nama komputer Anda di sana. Selain itu, firewall mempertahankan izin standar UFW untuk ping, mendapatkan alamat dari router Anda (DHCP), dan penemuan UPnP. Bahkan ssh mati sampai Anda menyalakannya melalui _Setup > Security > SSHD_, yang membuka port 22 (dibatasi kecepatannya terhadap brute force) sebagai bagian dari penyiapan. Kami bahkan mengunci akses Docker menggunakan penyiapan [ufw-docker](https://github.com/chaifeng/ufw-docker) untuk mencegah container Anda terekspos ke dunia secara tidak sengaja.
3. *Arch selalu memiliki pembaruan terbaru*: Arch, distro dasar yang menjadi fondasi Omarchy, adalah distribusi rolling. Ini berarti setiap kerentanan keamanan yang ditemukan dan ditambal di paket mana pun dengan cepat tersedia untuk diinstal menggunakan `omarchy-update`. Dengan cara itu Anda selalu menjalankan versi terbaru dan paling aman dari segalanya.
4. *Omarchy memelihara paket dan mirror-nya sendiri*: Omarchy hanya mengandalkan paket dari repositori core/extra/multilib milik Arch sendiri dan Omarchy Package Repository miliknya sendiri secara default. Anda dapat menginstal perangkat lunak langsung dari AUR, tetapi instalasi dasar tidak melakukannya — hanya beberapa instalasi opsional, seperti browser pihak ketiga, yang mengambil dari AUR.
5. *Cloudflare melindungi kami dari DDoS*: Infrastruktur distribusi Omarchy — ISO, paket Omarchy, mirror Arch — dilindungi di balik perisai DDoS Cloudflare yang tangguh dan dihosting di CDN mereka. Ini memberikan ketersediaan yang luar biasa.

## Mengubah kata sandi Anda

Anda memiliki dua kata sandi pada instalasi terenkripsi: satu yang membuka kunci drive saat boot, dan satu yang Anda gunakan untuk masuk dan `sudo`. Penyiapan membuat keduanya sama. Keduanya dapat diubah di bawah _Update > Password_ di menu Omarchy — _Drive Encryption_ untuk yang pertama, _User_ untuk yang kedua. Mengubah kata sandi drive akan meminta kata sandi saat ini terlebih dahulu, jadi siapkanlah. Jika perubahan terinterupsi, jalankan _Drive Encryption_ lagi: itu akan meminta kata sandi yang membuka kunci drive saat ini dan menyelesaikan perubahan.

## Menyerahkan mesin yang sudah Anda gunakan

Jika Anda menyerahkan mesin Anda kepada orang lain, Anda tidak harus menginstal ulang. Jalankan _Setup > Reset Computer_ di menu Omarchy, ketik `reset` untuk mengonfirmasi, dan reboot. Itu menghapus setiap akun pengguna dan semua yang ada di `/home`, membuang semua paket dan perubahan sistem yang Anda buat sejak instalasi, dan membersihkan identitas mesin — koneksi jaringan, host keys, dan semuanya. Yang muncul kembali adalah wizard penyiapan dari boot pertama, siap bagi pemilik barunya untuk memasukkan nama, kata sandi, dan kata sandi enkripsi mereka sendiri.

Ini bekerja dengan memulihkan snapshot baseline yang diambil installer, jadi ini hanya tersedia pada mesin yang diinstal dari ISO Omarchy. Dan pada drive tanpa enkripsi, reset adalah penghapusan biasa daripada penghapusan aman, jadi jika datanya sensitif, lakukan instalasi baru sebagai gantinya.

## Sudo tanpa kata sandi

Terkadang Anda ingin `sudo` berhenti meminta, paling sering ketika agen AI sedang melakukan pekerjaan sistem yang panjang untuk Anda. _Setup > Security > Passwordless Sudo_ menanyakan berapa lama akses diizinkan: **15 menit**, **1 Jam**, **1 Hari**, atau **Secara Permanen**. Ikon peringatan merah muncul di samping indikator bilah menu lainnya selama akses aktif. Klik ikon tersebut atau jalankan perintah lagi untuk mematikan akses. Anda juga dapat memberikan jumlah menit Anda sendiri (dari 1 hingga 1440) dengan `omarchy-sudo-passwordless 30`, atau gunakan `omarchy-sudo-passwordless permanent`.

Akses berwaktu kedaluwarsa secara otomatis, termasuk segera setelah melanjutkan dari suspend yang melewati batas waktu. Memulai ulang komputer mengakhirinya lebih awal. Akses permanen tetap bertahan setelah reboot dan tetap aktif sampai Anda menonaktifkannya.

Memperbarui atau menghapus paket pengaturan Omarchy mengakhiri pemberian sementara apa pun sebelum dukungan kedaluwarsanya berubah. Jika perintah melaporkan kesalahan otorisasi atau pembersihan, selesaikan sebelum mencoba mengaktifkan pemberian lain; kesalahan tidak berarti akses tanpa kata sandi tidak aktif.

Bersikaplah jernih tentang yang satu ini: selama ini aktif, apa pun yang berjalan sebagai pengguna Anda dapat melakukan apa pun sebagai root tanpa diminta. Itulah inti tujuannya, dan itulah juga seluruh risikonya.

## Kunci Penandatanganan

Kunci publik untuk semua tanda tangan ISO dan paket repo Omarchy adalah `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifikasi di openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paket `omarchy/omarchy-keyring` juga berisi kunci ini dan akan digunakan untuk meluncurkan pembaruan potensial apa pun dengan mulus.

Anda dapat menemukan tanda tangan untuk rilis ISO apa pun dengan menambahkan `.sig` ke URL-nya, seperti `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
