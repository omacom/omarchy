# Jaringan

Jaringan di Omarchy ditangani oleh NetworkManager, dan kamu mengendalikannya dari ikon jaringan di [bilah atas](05-the-top-bar.md) atau dengan `Super + Ctrl + N`.

Panel itu memindai jaringan Wi-Fi, menunjukkan kekuatan sinyal, dan menghubungkan. Ethernet tidak perlu apa pun sama sekali — colokkan saja dan langsung berfungsi. Jika kamu lebih suka tetap di terminal, `nmtui` memberi kamu kontrol yang sama, dan ada juga grup perintah `omarchy network`.

## Membagikan Wi-Fi kamu

Daripada membacakan kata sandi yang panjang dengan suara keras, jalankan _Setup > Network > QR Code_ saat kamu terhubung ke Wi-Fi. Itu menaruh kode QR di layar yang dapat dipindai kamera ponsel mana pun untuk bergabung. Ini salah satu hal yang akan lebih sering kamu pakai daripada yang kamu kira setelah kamu tahu itu ada.

Jika kamu benar-benar perlu kata sandinya sendiri, `omarchy network password <interface>` akan menampilkannya.

## DNS

Omarchy menggunakan DNS apa pun yang diberikan jaringan kamu lewat DHCP. Kamu dapat mengesampingkan itu untuk seluruh mesin di _Setup > Network > DNS_, tempat Cloudflare dan Google hanya sejauh sekali klik. Pilih _Custom_ untuk mengetikkan server kamu sendiri.

Dari terminal, `omarchy dns` menampilkan penyedia saat ini dan `omarchy dns Cloudflare` menetapkan salah satunya.

## Mengunci pita Wi-Fi

Jika router kamu menaruh 2.4GHz, 5GHz, dan 6GHz pada nama jaringan yang sama, laptop kamu kadang akan terus menempel pada yang lambat. `omarchy network band` menunjukkan pita mana yang sedang kamu pakai, dan `omarchy network band 5` menguncinya. Gunakan `auto` untuk membiarkannya memilih lagi.

Ini mengunci pita, bukan titik akses tertentu, jadi kamu tetap melakukan roaming antar-AP seperti biasa.

## Seberapa cepat?

_Trigger > Speed Test > Network Speed Test_ mengukur kecepatan unduh dan unggah kamu yang sebenarnya dengan sepasang dial. Dari terminal, perintahnya adalah `omarchy network speedtest down` atau `up`. (Ada tes kecepatan disk yang berada di sebelahnya dalam menu itu, jika kamu sedang mengukur bottleneck yang lain.)

## Firewall

Firewall aktif secara bawaan dan memblokir semua lalu lintas masuk, dengan satu pengecualian: port 53317, agar [LocalSend](22-guis.md) langsung berfungsi sejak awal.

SSH nonaktif sampai kamu menyalakannya dengan _Setup > Security > SSHD_, yang memulai daemon, membuka port 22 dengan pembatasan laju terhadap brute force, dan mengotorisasi sebuah kunci. Docker juga dikunci, jadi kontainer tidak dapat secara tidak sengaja mengekspos dirinya ke dunia. Lihat [keamanan](48-security.md) untuk cerita lengkapnya.

## Tailscale

[Tailscale](https://tailscale.com/) adalah mesh VPN yang membuat menjangkau semua komputer dan server kamu lewat internet menjadi sederhana dan aman. Instal dengan _Install > Service > Tailscale_.

Itu memberi kamu panel Tailscale di bilah, yang menghubungkan dan memutuskan tailnet, mengganti akun, dan memilih exit node — mesin kamu sendiri dan region Mullvad sama-sama muncul dalam daftar. Panel itu juga menelusuri mesin kamu, dan di sanalah Taildrop berada: pilih sebuah mesin dan tekan `s` untuk mengirimkan file kepadanya, atau `c`, `n`, dan `d` untuk menyalin IP, nama, atau nama DNS lengkapnya. Padanan terminalnya adalah `omarchy tailscale send <machine> [file...]`, dan file yang dikirimkan kepadamu mendarat di `~/Downloads` secara otomatis. Notifikasi yang mengumumkan kedatangan menunggu sampai kamu mengekliknya untuk membukanya atau menutupnya, jadi file yang muncul saat kamu jauh dari mesin tetap ada untuk ditanggapi saat kamu kembali.

Menginstalnya juga menambahkan aplikasi web untuk konsol admin Tailscale.

## Saat berhenti berfungsi

Sebelum reboot, coba mulai ulang bagian yang bermasalah itu sendiri. _Update > Hardware_ memiliki Wi-Fi, Bluetooth, Audio, dan Trackpad, dan memuat ulang salah satunya membereskan sebagian besar situasi "tadi lima menit lalu masih berfungsi". Lihat [pemecahan masalah](45-troubleshooting.md).
