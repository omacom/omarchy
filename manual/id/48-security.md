# Keamanan

Omarchy memandang keamanan dengan sangat serius. Ini dimaksudkan sebagai sistem operasi yang dapat Anda gunakan untuk melakukan _Real Work_ di _Real World_. Di mana kehilangan laptop tidak dapat berujung pada keadaan darurat keamanan. Jadi inilah yang kami lakukan:

1. *Enkripsi full-disk bersifat wajib*: Ini adalah langkah terpenting untuk mengamankan perlindungan fisik data Anda. Jika komputer Anda hilang atau dicuri, data terenkripsi sepenuhnya menggunakan LUKS (Linux Unified Key Setup) standar.
2. *Firewall diaktifkan secara default*: Semua lalu lintas masuk diblokir secara default kecuali port 53317 untuk [LocalSend](https://localsend.org/). Bahkan ssh pun nonaktif sampai Anda mengaktifkannya melalui _Setup > Security > SSHD_, yang membuka port 22 (dibatasi kecepatannya terhadap brute force) sebagai bagian dari setup. Kami bahkan mengunci akses Docker menggunakan setup [ufw-docker](https://github.com/chaifeng/ufw-docker) untuk mencegah container Anda terekspos ke dunia secara tidak sengaja.
3. *Arch selalu memiliki pembaruan terbaru*: Arch, distro dasar yang menjadi fondasi Omarchy, adalah distribusi rolling. Ini berarti setiap kerentanan keamanan yang ditemukan dan ditambal di paket mana pun akan segera tersedia untuk diinstal menggunakan `omarchy-update`. Dengan cara itu Anda selalu menjalankan versi terbaru dan paling aman dari segala sesuatu.
4. *Omarchy memelihara paket dan mirror-nya sendiri*: Omarchy hanya bergantung pada paket dari repositori core/extra/multilib milik Arch sendiri dan Omarchy Package Repository miliknya sendiri secara default. Anda dapat menginstal perangkat lunak langsung dari AUR, tetapi instalasi dasar tidak melakukannya — hanya beberapa instalasi opsional, seperti browser pihak ketiga, yang mengambil dari AUR.
5. *Cloudflare melindungi kami dari DDoS*: Infrastruktur distribusi Omarchy — ISO, paket-paket Omarchy, mirror Arch — dilindungi di balik perisai DDoS Cloudflare yang tangguh dan dihosting di CDN mereka. Ini memberikan ketersediaan yang luar biasa.

## Mengubah kata sandi Anda

Anda memiliki dua kata sandi pada instalasi terenkripsi: satu yang membuka kunci drive saat boot, dan satu yang Anda gunakan untuk login dan `sudo`. Setup membuatnya sama. Keduanya dapat diubah di bawah _Update > Password_ di menu Omarchy — _Drive Encryption_ untuk yang pertama, _User_ untuk yang kedua. Mengubah kata sandi drive akan meminta kata sandi saat ini terlebih dahulu, jadi siapkan kata sandi tersebut. Jika perubahan terinterupsi, jalankan _Drive Encryption_ lagi: ia akan meminta kata sandi yang membuka kunci drive saat ini dan menyelesaikan perubahan.

## Menyerahkan mesin yang sudah pernah Anda gunakan

Jika Anda menyerahkan mesin Anda kepada orang lain, Anda tidak perlu menginstalnya ulang. Jalankan _Setup > Reset Computer_ di menu Omarchy, ketik `reset` untuk mengonfirmasi, dan reboot. Itu akan menghapus setiap akun pengguna dan semua yang ada di `/home`, membuang semua paket dan perubahan sistem yang Anda buat sejak instalasi, dan membersihkan identitas mesin — koneksi jaringan, host keys, dan semuanya. Yang akan muncul kembali adalah wizard setup dari boot pertama, siap bagi pemilik barunya untuk memasukkan nama, kata sandi, dan kata sandi enkripsi mereka sendiri.

Ini bekerja dengan memulihkan snapshot baseline yang diambil installer, jadi ini hanya tersedia pada mesin yang diinstal dari ISO Omarchy. Dan pada drive tanpa enkripsi, reset adalah penghapusan, bukan secure erase, jadi jika datanya sensitif, lakukan instalasi baru sebagai gantinya.

## sudo tanpa kata sandi

Terkadang Anda ingin `sudo` berhenti meminta, paling sering ketika agen AI sedang melakukan pekerjaan sistem yang panjang untuk Anda. _Setup > Security > Passwordless Sudo_ menanyakan berapa lama akses diizinkan: **15 menit**, **1 Jam**, **1 Hari**, atau **Permanen**. Ikon peringatan merah muncul di samping indikator menu bar lainnya selama akses aktif. Klik ikon tersebut atau jalankan perintah lagi untuk menonaktifkan akses. Anda juga dapat memberikan jumlah menit Anda sendiri (dari 1 hingga 1440) dengan `omarchy-sudo-passwordless 30`, atau menggunakan `omarchy-sudo-passwordless permanent`.

Akses berbatas waktu berakhir secara otomatis, termasuk segera setelah melanjutkan dari suspend yang melewati batas waktunya. Merestart komputer akan mengakhirinya lebih awal. Akses permanen tetap bertahan melewati reboot dan tetap aktif sampai Anda menonaktifkannya.

Memperbarui atau menghapus paket settings Omarchy akan mengakhiri setiap pemberian sementara sebelum dukungan kedaluwarsanya berubah. Jika perintah melaporkan kesalahan otorisasi atau pembersihan, selesaikan kesalahan tersebut sebelum mencoba mengaktifkan pemberian lain; kesalahan tidak berarti akses tanpa kata sandi tidak aktif.

Bersikaplah jernih soal yang satu ini: selama ini aktif, apa pun yang berjalan sebagai pengguna Anda dapat melakukan apa pun sebagai root tanpa ditanya. Itulah intinya, dan itulah juga seluruh risikonya.

## Kunci Penandatanganan

Kunci publik untuk semua tanda tangan ISO dan paket repo Omarchy adalah `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifikasi di openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paket `omarchy/omarchy-keyring` juga berisi kunci ini dan akan digunakan untuk meluncurkan setiap pembaruan potensial dengan lancar.

Anda dapat menemukan tanda tangan untuk setiap rilis ISO dengan menambahkan `.sig` ke URL-nya, seperti `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
