# Keamanan

Omarchy menganggap keamanan dengan sangat serius. Ini dimaksudkan sebagai sistem operasi yang dapat Anda gunakan untuk melakukan _Pekerjaan Nyata_ di _Dunia Nyata_. Di mana kehilangan laptop tidak dapat menyebabkan darurat keamanan. Jadi inilah yang kami lakukan:

1. *Enkripsi disk penuh wajib*: Ini adalah langkah terpenting untuk mengamankan perlindungan fisik data Anda. Jika komputer Anda hilang atau dicuri, data terenkripsi sepenuhnya menggunakan LUKS standar (Linux Unified Key Setup).
2. *Firewall diaktifkan secara default*: Semua lalu lintas masuk diblokir secara default kecuali untuk port 53317 untuk [LocalSend](https://localsend.org/). Bahkan ssh mati sampai Anda mengaktifkannya melalui _Setup > Security > SSHD_, yang membuka port 22 (dibatasi lajunya terhadap brute force) sebagai bagian dari pengaturan. Kami bahkan mengunci akses Docker menggunakan pengaturan [ufw-docker](https://github.com/chaifeng/ufw-docker) untuk mencegah container Anda terekspos ke dunia secara tidak sengaja.
3. *Arch selalu memiliki pembaruan terbaru*: Arch, distro yang mendasari Omarchy, adalah distribusi rolling. Ini berarti setiap kerentanan keamanan yang ditemukan dan ditambal di paket mana pun akan segera tersedia untuk diinstal menggunakan `omarchy-update`. Dengan cara itu Anda selalu menjalankan versi terbaru dan paling aman dari segalanya.
4. *Omarchy memelihara paket dan mirror-nya sendiri*: Secara default Omarchy hanya mengandalkan paket dari repositori core/extra/multilib milik Arch sendiri dan Omarchy Package Repository miliknya sendiri. Anda dapat menginstal perangkat lunak langsung dari AUR, tetapi instalasi dasar tidak melakukannya — hanya beberapa instalasi opsional, seperti browser pihak ketiga, yang mengambil dari AUR.
5. *Cloudflare melindungi kami dari DDoS*: Infrastruktur distribusi Omarchy — ISO, paket Omarchy, mirror Arch — dilindungi di balik perisai DDoS Cloudflare yang tangguh dan di-hosting di CDN mereka. Ini memberikan ketersediaan yang luar biasa.

## Mengubah kata sandi Anda

Anda memiliki dua kata sandi pada instalasi terenkripsi: satu yang membuka kunci drive saat boot, dan satu yang Anda gunakan untuk masuk dan `sudo`. Setup membuatnya sama. Keduanya dapat diubah di bawah _Update > Password_ di menu Omarchy — _Drive Encryption_ untuk yang pertama, _User_ untuk yang kedua. Mengubah kata sandi drive akan meminta kata sandi saat ini terlebih dahulu, jadi siapkanlah. Jika perubahan terputus, jalankan _Drive Encryption_ lagi: ia akan meminta kata sandi yang membuka kunci drive sekarang dan menyelesaikan perubahan.

## Memberikan mesin yang sudah Anda gunakan kepada orang lain

Jika Anda memberikan mesin Anda kepada orang lain, Anda tidak harus menginstalnya ulang. Jalankan _Setup > Reset Computer_ di menu Omarchy, ketik `reset` untuk mengonfirmasi, dan reboot. Itu menghapus setiap akun pengguna dan semua yang ada di `/home`, membuang semua paket dan perubahan sistem yang Anda buat sejak instalasi, dan membersihkan identitas mesin — koneksi jaringan, host keys, dan semuanya. Yang muncul kembali adalah wizard setup dari boot pertama, siap bagi pemilik barunya untuk memasukkan nama, kata sandi, dan kata sandi enkripsi mereka sendiri.

Ini bekerja dengan memulihkan snapshot baseline yang diambil installer, jadi ini hanya tersedia pada mesin yang diinstal dari ISO Omarchy. Dan pada drive tanpa enkripsi, reset adalah penghapusan, bukan penghapusan aman, jadi jika datanya sensitif, lakukan instalasi baru saja.

## sudo tanpa kata sandi

Terkadang Anda ingin `sudo` berhenti meminta, paling sering ketika agen AI sedang melakukan pekerjaan sistem yang panjang untuk Anda. _Setup > Security > Passwordless Sudo_ menanyakan berapa lama akses diizinkan: **15 menit**, **1 Jam**, **1 Hari**, atau **Permanen**. Ikon peringatan merah muncul di samping indikator bilah menu lainnya selagi akses aktif. Klik ikon itu atau jalankan perintah lagi untuk mematikan akses. Anda juga dapat memberikan jumlah menit Anda sendiri (dari 1 hingga 1440) dengan `omarchy-sudo-passwordless 30`, atau menggunakan `omarchy-sudo-passwordless permanent`.

Akses berbatas waktu kedaluwarsa secara otomatis, termasuk segera setelah melanjutkan dari suspend yang melewati tenggat. Memulai ulang komputer mengakhirinya lebih awal. Akses permanen bertahan melewati reboot dan tetap aktif sampai Anda menonaktifkannya.

Memperbarui atau menghapus paket settings Omarchy mengakhiri setiap pemberian sementara sebelum dukungan kedaluwarsanya berubah. Jika perintah melaporkan kesalahan otorisasi atau pembersihan, selesaikan itu sebelum mencoba mengaktifkan pemberian lain; kesalahan tidak berarti akses tanpa kata sandi tidak aktif.

Bersikaplah jernih soal yang satu ini: selagi ini aktif, apa pun yang berjalan sebagai pengguna Anda dapat melakukan apa pun sebagai root tanpa diminta. Itulah intinya, dan itulah juga seluruh risikonya.

## Kunci Penandatanganan

Kunci publik untuk semua tanda tangan ISO dan paket repo Omarchy adalah `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifikasi di openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paket `omarchy/omarchy-keyring` juga berisi kunci ini dan akan digunakan untuk meluncurkan setiap potensi pembaruan dengan mulus.

Anda dapat menemukan tanda tangan untuk rilis ISO mana pun dengan menambahkan .sig ke URL. Seperti https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
