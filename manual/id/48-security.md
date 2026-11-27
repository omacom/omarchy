# Keamanan

Omarchy menganggap keamanan sangat serius. Ini dimaksudkan sebagai sistem operasi yang bisa Anda gunakan untuk melakukan _Real Work_ di _Real World_. Di mana kehilangan laptop tidak bisa berujung pada darurat keamanan. Jadi inilah yang kami lakukan:

1. *Enkripsi full-disk aktif secara default*: Ini adalah langkah terpenting untuk mengamankan perlindungan fisik data Anda. Jika komputer Anda hilang atau dicuri, data tersebut terenkripsi sepenuhnya menggunakan LUKS standar (Linux Unified Key Setup). Installer memungkinkan Anda menonaktifkannya untuk mesin sekali pakai (lihat [Memulai](02-getting-started.md)); instalasi tanpa enkripsi tidak memiliki perlindungan ini sama sekali, dan siapa pun yang memegang drive tersebut bisa membacanya.
2. *Firewall aktif secara default*: Semua lalu lintas masuk diblokir secara default, dengan beberapa pengecualian: port 53317 untuk [LocalSend](https://localsend.org/); kueri DNS ke resolver milik komputer itu sendiri di alamat bridge Docker (172.17.0.1), yang diterima dari rentang alamat privat yang diberikan Docker kepada container-containernya; dan multicast DNS (port 5353), yang memungkinkan printer dan perangkat lain di jaringan Anda saling menemukan dan juga mengumumkan nama komputer Anda di sana. Di luar itu, firewall mempertahankan izin standar UFW untuk ping, mendapatkan alamat dari router Anda (DHCP), dan penemuan UPnP. Bahkan ssh pun nonaktif sampai Anda mengaktifkannya melalui _Setup > Security > SSHD_, yang mengotorisasi kunci SSH Anda, menonaktifkan login dengan kata sandi, dan baru setelah itu membuka port 22 (dibatasi laju percobaannya untuk melawan brute force). Kami bahkan mengunci akses Docker menggunakan setup [ufw-docker](https://github.com/chaifeng/ufw-docker) untuk mencegah container Anda terekspos ke dunia luar secara tidak sengaja.
3. *Arch selalu memiliki pembaruan terbaru*: Arch, distro dasar tempat Omarchy dibangun, adalah distribusi rolling. Artinya, setiap kerentanan keamanan yang ditemukan dan diperbaiki di paket mana pun akan dengan cepat tersedia untuk diinstal menggunakan `omarchy-update`. Dengan begitu, Anda selalu menjalankan versi terbaru dan paling aman dari semuanya.
4. *Omarchy memelihara paket dan mirror-nya sendiri*: Secara default, Omarchy hanya mengandalkan paket dari repositori core/extra/multilib milik Arch sendiri (milik Arch Linux ARM di mesin ARM, ditambah Asahi ALARM di Apple Silicon) dan Omarchy Package Repository miliknya sendiri. Anda bisa menginstal perangkat lunak langsung dari AUR, tetapi instalasi dasar tidak melakukannya — hanya beberapa instalasi opsional, seperti browser pihak ketiga, yang mengambil dari AUR.
5. *Cloudflare melindungi kami dari DDoS*: Infrastruktur distribusi Omarchy — ISO, paket Omarchy, mirror Arch — dilindungi di balik perisai DDoS Cloudflare yang tangguh dan dihosting di CDN mereka. Ini memberikan ketersediaan yang sangat baik.

## Mengganti kata sandi Anda

Anda memiliki dua kata sandi pada instalasi terenkripsi: satu yang membuka kunci drive saat boot, dan satu yang Anda gunakan untuk login dan `sudo`. Setup membuat keduanya sama. _Update > Password_ di menu Omarchy mengganti keduanya sekaligus, sehingga keduanya tetap sama: ia meminta kata sandi drive saat ini, lalu kata sandi yang baru, mengganti kata sandi drive, lalu mengatur kata sandi login Anda agar cocok. Tanpa enkripsi drive, ia hanya mengganti kata sandi login Anda. Jika penggantian terputus di tengah jalan, jalankan _Update > Password_ lagi: ia meminta kata sandi yang membuka kunci drive saat ini, menyelesaikan penggantian, dan mengatur kata sandi login Anda menjadi kata sandi tersebut. Untuk mengganti kata sandi drive terenkripsi lain, jalankan `omarchy-drive-password` di terminal.

## Menyerahkan mesin yang sudah Anda gunakan

Jika Anda menyerahkan mesin Anda kepada orang lain, Anda tidak perlu menginstalnya ulang. Jalankan _Remove > Factory Reset_ di menu Omarchy, ketik `reset` untuk mengonfirmasi, masukkan kata sandi enkripsi drive Anda jika diminta, dan reboot. Itu akan menghapus setiap akun pengguna dan semua yang ada di `/home`, membuang semua paket dan perubahan sistem yang Anda buat sejak instalasi, dan menghapus identitas mesin — koneksi jaringan, host key, dan semuanya. Yang muncul kembali adalah wizard setup dari boot pertama, siap bagi pemilik barunya untuk memasukkan nama, kata sandi, dan kata sandi enkripsi mereka sendiri.

Cara kerjanya adalah dengan memulihkan snapshot baseline yang diambil installer, jadi ini hanya tersedia di mesin yang diinstal dari ISO Omarchy. Dan pada drive tanpa enkripsi, reset adalah penghapusan biasa, bukan penghapusan aman, jadi jika datanya sensitif, lakukan instalasi baru saja sebagai gantinya.

## sudo tanpa kata sandi

Terkadang Anda ingin `sudo` berhenti meminta kata sandi, paling sering ketika agen AI sedang melakukan pekerjaan sistem yang panjang untuk Anda. _Setup > Security > Passwordless Sudo_ menanyakan berapa lama akses diizinkan: **15 menit**, **1 Jam**, **1 Hari**, atau **Permanen**. Ikon peringatan berwarna merah muncul di samping indikator bilah menu lainnya selama akses aktif. Klik ikon tersebut atau jalankan perintahnya lagi untuk menonaktifkan akses. Anda juga bisa memberikan jumlah menit Anda sendiri (dari 1 sampai 1440) dengan `omarchy-sudo-passwordless 30`, atau menggunakan `omarchy-sudo-passwordless permanent`.

Akses berjangka waktu berakhir secara otomatis, termasuk segera setelah melanjutkan dari suspend yang melewati batas waktunya. Merestart komputer akan mengakhirinya lebih awal. Akses permanen tetap bertahan setelah reboot dan tetap aktif sampai Anda menonaktifkannya.

Memperbarui atau menghapus paket pengaturan Omarchy akan mengakhiri setiap pemberian sementara sebelum dukungan kedaluwarsanya berubah. Jika perintah melaporkan kesalahan otorisasi atau pembersihan, selesaikan itu sebelum mencoba mengaktifkan pemberian lain; kesalahan bukan berarti akses tanpa kata sandi tidak aktif.

Sadari ini dengan jernih: selama ini aktif, apa pun yang berjalan sebagai pengguna Anda bisa melakukan apa pun sebagai root tanpa ditanya. Itulah inti tujuannya, dan itulah juga seluruh risikonya.

## Kunci Penandatanganan

Kunci publik untuk semua tanda tangan ISO dan paket repo Omarchy adalah `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifikasi di openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paket `omarchy/omarchy-keyring` juga berisi kunci ini dan akan digunakan untuk meluncurkan setiap pembaruan potensial dengan mulus.

Anda bisa menemukan tanda tangan untuk setiap rilis ISO dengan menambahkan `.sig` ke URL-nya, seperti `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
