# Keamanan

Omarchy memperlakukan keamanan dengan sangat serius. Ini dimaksudkan sebagai sistem operasi yang bisa kamu gunakan untuk melakukan _Pekerjaan Nyata_ di _Dunia Nyata_. Di mana kehilangan laptop tidak bisa berujung pada keadaan darurat keamanan. Jadi inilah yang kami lakukan:

1. *Enkripsi disk penuh wajib*: Ini adalah langkah terpenting untuk mengamankan perlindungan fisik datamu. Jika komputermu hilang atau dicuri, data terenkripsi sepenuhnya menggunakan LUKS standar (Linux Unified Key Setup).
2. *Firewall diaktifkan secara bawaan*: Semua lalu lintas masuk diblokir secara bawaan kecuali port 53317 untuk [LocalSend](https://localsend.org/). Bahkan ssh mati sampai kamu menyalakannya melalui _Pengaturan > Security > SSHD_, yang membuka port 22 (dengan pembatasan laju terhadap brute force) sebagai bagian dari pengaturan. Kami bahkan mengunci akses Docker menggunakan pengaturan [ufw-docker](https://github.com/chaifeng/ufw-docker) untuk mencegah kontainermu terekspos secara tidak sengaja ke dunia.
3. *Arch selalu memiliki pembaruan terbaru*: Arch, distro mendasar tempat Omarchy dibangun, adalah distribusi rolling. Ini berarti kerentanan keamanan apa pun yang ditemukan dan ditambal di paket mana pun dengan cepat tersedia untuk dipasang menggunakan `omarchy-update`. Dengan begitu kamu selalu menjalankan versi terbaru dan paling aman dari segalanya.
4. *Omarchy memelihara paket dan mirror-nya sendiri*: Omarchy hanya mengandalkan paket dari repositori core/extra/multilib Arch sendiri dan Repositori Paket Omarchy miliknya sendiri secara bawaan. Kamu bisa memasang perangkat lunak langsung dari AUR, tetapi pemasangan dasar tidak melakukannya — hanya beberapa pemasangan opsional, seperti browser pihak ketiga, yang mengambil dari AUR.
5. *Cloudflare melindungi kami dari DDoS*: Semua infrastruktur distribusi Omarchy — ISO, paket Omarchy, mirror Arch — dilindungi di balik perisai DDoS Cloudflare yang tangguh dan dihosting di CDN mereka. Ini memberikan ketersediaan yang luar biasa.

## Mengubah kata sandi kamu

Kamu memiliki dua kata sandi pada pemasangan terenkripsi: yang membuka kunci drive saat boot, dan yang kamu gunakan untuk login dan `sudo`. Pengaturan membuatnya sama. Keduanya bisa diubah di _Perbarui > Password_ di menu Omarchy — _Drive Encryption_ untuk yang pertama, _User_ untuk yang kedua. Mengubah kata sandi drive meminta yang saat ini terlebih dahulu, jadi siapkan itu. Jika perubahan terinterupsi, jalankan _Drive Encryption_ lagi: ia meminta kata sandi yang membuka kunci drive sekarang dan menyelesaikan perubahan.

## Menyerahkan mesin yang sudah kamu gunakan

Jika kamu menyerahkan mesinmu kepada orang lain, kamu tidak harus memasangnya ulang. Jalankan _Pengaturan > Reset Computer_ di menu Omarchy, ketik `reset` untuk mengonfirmasi, dan reboot. Itu menghapus setiap akun pengguna dan semua yang ada di `/home`, membuang semua paket dan perubahan sistem yang kamu buat sejak pemasangan, dan menghapus identitas mesin — koneksi jaringan, kunci host, dan semuanya. Yang muncul kembali adalah wizard pengaturan dari boot pertama, siap bagi pemilik barunya untuk memasukkan nama, kata sandi, dan kata sandi enkripsi mereka sendiri.

Ia bekerja dengan memulihkan snapshot baseline yang diambil pemasang, jadi ini hanya tersedia pada mesin yang dipasang dari ISO Omarchy. Dan pada drive tanpa enkripsi, reset adalah penghapusan alih-alih penghapusan aman, jadi jika datanya sensitif, lakukan pemasangan baru sebagai gantinya.

## Sudo tanpa kata sandi

Terkadang kamu ingin `sudo` berhenti meminta, paling sering saat agen AI melakukan pekerjaan sistem yang panjang untukmu. _Pengaturan > Security > Passwordless Sudo_ menanyakan berapa lama mengizinkan akses: **15 menit**, **1 Jam**, **1 Hari**, atau **Permanen**. Ikon peringatan merah muncul di samping indikator bilah menu lainnya selagi akses aktif. Klik ikon itu atau jalankan perintah lagi untuk mematikan akses. Kamu juga bisa memberikan jumlah menitmu sendiri (dari 1 hingga 1440) dengan `omarchy-sudo-passwordless 30`, atau menggunakan `omarchy-sudo-passwordless permanent`.

Akses berjangka waktu kedaluwarsa secara otomatis, termasuk segera setelah dilanjutkan dari penangguhan yang melintasi tenggat waktu. Memulai ulang komputer mengakhirinya lebih awal. Akses permanen bertahan dari reboot dan tetap aktif sampai kamu menonaktifkannya.

Memperbarui atau menghapus paket pengaturan Omarchy mengakhiri pemberian sementara apa pun sebelum dukungan kedaluwarsanya berubah. Jika perintah melaporkan kesalahan otorisasi atau pembersihan, atasi itu sebelum mencoba mengaktifkan pemberian lain; kesalahan tidak berarti akses tanpa kata sandi tidak aktif.

Bersikaplah jernih tentang yang satu ini: selagi aktif, apa pun yang berjalan sebagai penggunamu bisa melakukan apa pun sebagai root tanpa ditanya. Itulah intinya, dan itu juga seluruh risikonya.

## Kunci Penandatanganan

Kunci publik untuk semua tanda tangan ISO dan paket repo Omarchy adalah `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifikasi di openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paket `omarchy/omarchy-keyring` juga memuat ini dan akan digunakan untuk meluncurkan pembaruan potensial apa pun dengan mulus.

Kamu bisa menemukan tanda tangan untuk rilis ISO apa pun dengan menambahkan .sig ke URL. Seperti https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
