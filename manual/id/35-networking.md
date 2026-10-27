# Jaringan

Jaringan di Omarchy ditangani oleh NetworkManager, dan Anda mengendalikannya dari ikon jaringan di [bilah atas](05-the-top-bar.md) atau dengan `Super + Ctrl + N`.

Panel tersebut memindai jaringan Wi-Fi, menampilkan kekuatan sinyal, dan menghubungkan. Ethernet tidak memerlukan apa pun sama sekali — colokkan saja dan langsung berfungsi. Jika Anda lebih suka tetap di terminal, `nmtui` memberi Anda kontrol yang sama, dan ada juga grup perintah `omarchy network`.

## Berbagi Wi-Fi Anda

Daripada membacakan kata sandi yang panjang dengan suara keras, jalankan _Setup > Network > QR Code_ saat Anda terhubung ke Wi-Fi. Itu akan menampilkan kode QR di layar yang dapat dipindai oleh kamera ponsel mana pun untuk bergabung. Ini salah satu hal yang akan lebih sering Anda gunakan daripada yang Anda kira setelah Anda tahu fitur itu ada.

Jika Anda benar-benar memerlukan kata sandinya sendiri, `omarchy network password <interface>` akan menampilkannya.

## DNS

Omarchy menggunakan DNS apa pun yang diberikan jaringan Anda melalui DHCP. Anda dapat menggantinya untuk seluruh mesin di _Setup > Network > DNS_, tempat Cloudflare dan Google hanya berjarak satu klik. Pilih _Custom_ untuk mengetikkan server Anda sendiri.

Dari terminal, `omarchy dns` menampilkan penyedia saat ini dan `omarchy dns Cloudflare` menetapkan salah satunya.

## Mengunci pita Wi-Fi

Jika router Anda menempatkan 2.4GHz, 5GHz, dan 6GHz pada nama jaringan yang sama, laptop Anda terkadang akan terus menempel pada yang lambat. `omarchy network band` menunjukkan pita yang sedang Anda gunakan, dan `omarchy network band 5` menguncinya. Gunakan `auto` untuk membiarkannya memilih lagi.

Ini mengunci pita, bukan titik akses tertentu, jadi Anda tetap dapat berpindah antar AP secara normal.

## Seberapa cepat?

_Trigger > Speed Test > Network Speed Test_ mengukur kecepatan unduh dan unggah Anda yang sebenarnya dengan sepasang penunjuk. Dari terminal, perintahnya adalah `omarchy network speedtest down` atau `up`. Pengukuran dilakukan terhadap layanan milik Omarchy sendiri dan hanya menghitung transfer ujinya. Unduhan lain dapat bersaing memperebutkan bandwidth, tetapi tidak ditambahkan ke hasil tes kecepatan. (Ada tes kecepatan disk yang berada di sebelahnya dalam menu tersebut, jika Anda sedang mengukur bottleneck yang lainnya.)

## Firewall

Firewall aktif secara default dan memblokir semua lalu lintas masuk, dengan satu pengecualian: port 53317, agar [LocalSend](22-guis.md) berfungsi langsung tanpa pengaturan tambahan.

SSH nonaktif hingga Anda mengaktifkannya dengan _Setup > Security > SSHD_, yang memulai daemon, membuka port 22 dengan pembatasan laju terhadap brute force, dan mengotorisasi sebuah kunci. Docker juga dikunci, jadi container tidak dapat secara tidak sengaja mengekspos dirinya ke dunia luar. Lihat [keamanan](48-security.md) untuk cerita lengkapnya.

## Tailscale

[Tailscale](https://tailscale.com/) adalah VPN mesh yang membuat menjangkau semua komputer dan server Anda melalui internet menjadi sederhana dan aman. Instal dengan _Install > Service > Tailscale_.

Itu memberi Anda panel Tailscale di bilah, yang menghubungkan dan memutuskan tailnet, beralih akun, dan memilih exit node — mesin Anda sendiri dan wilayah Mullvad sama-sama muncul dalam daftar. Panel itu juga menelusuri mesin-mesin Anda, dan di sanalah Taildrop berada: pilih sebuah mesin dan tekan `s` untuk mengirimkan file kepadanya, atau `c`, `n`, dan `d` untuk menyalin IP, nama, atau nama DNS lengkapnya. Padanan terminalnya adalah `omarchy tailscale send <machine> [file...]`, dan file yang dikirimkan kepada Anda mendarat di `~/Downloads` secara otomatis. Notifikasi yang mengumumkan kedatangan akan menunggu hingga Anda mengekliknya untuk membukanya atau menutupnya, jadi file yang muncul saat Anda jauh dari mesin tetap ada untuk ditanggapi saat Anda kembali.

Menginstalnya juga menambahkan aplikasi web untuk konsol admin Tailscale.

## Saat berhenti berfungsi

Sebelum reboot, coba mulai ulang bagian yang bermasalah itu saja. _Update > Hardware_ memiliki Wi-Fi, Bluetooth, Audio, dan Trackpad, dan memuat ulang salah satunya akan mengatasi sebagian besar situasi "tadi lima menit yang lalu masih berfungsi". Lihat [pemecahan masalah](45-troubleshooting.md).
