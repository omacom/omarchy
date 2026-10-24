# Jaringan

Jaringan di Omarchy ditangani oleh NetworkManager, dan kamu mengendalikannya dari ikon jaringan di [bilah atas](05-the-top-bar.md) atau dengan `Super + Ctrl + W`.

Panel tersebut memindai jaringan Wi-Fi, menunjukkan kekuatan sinyal, dan menghubungkan. Ethernet tidak membutuhkan apa pun sama sekali — colokkan saja dan langsung berfungsi. Jika kamu lebih suka tetap di terminal, `nmtui` memberimu kontrol yang sama, dan ada juga grup perintah `omarchy network`.

## Berbagi Wi-Fi kamu

Daripada membacakan kata sandi yang panjang dengan lantang, jalankan _Pengaturan > Jaringan > Kode QR_ saat kamu terhubung ke Wi-Fi. Itu akan menampilkan kode QR di layar yang bisa dipindai oleh kamera ponsel mana pun untuk bergabung. Ini salah satu hal yang akan lebih sering kamu gunakan daripada yang kamu kira begitu kamu tahu fitur ini ada.

Jika kamu benar-benar membutuhkan kata sandinya sendiri, `omarchy network password <interface>` akan menampilkannya.

## DNS

Omarchy menggunakan DNS apa pun yang diberikan jaringanmu melalui DHCP. Kamu bisa menggantinya untuk seluruh mesin di _Pengaturan > Jaringan > DNS_, di mana Cloudflare dan Google hanya berjarak satu klik. Pilih _Kustom_ untuk mengetikkan servermu sendiri.

Dari terminal, `omarchy dns` menampilkan penyedia saat ini dan `omarchy dns Cloudflare` mengatur salah satunya.

## Mengunci pita Wi-Fi

Jika routermu menempatkan 2.4GHz, 5GHz, dan 6GHz pada nama jaringan yang sama, laptopmu terkadang akan tetap menempel pada yang lambat. `omarchy network band` menunjukkan pita mana yang kamu gunakan, dan `omarchy network band 5` menguncinya. Gunakan `auto` untuk membiarkannya memilih lagi.

Ini mengunci pita, bukan titik akses tertentu, jadi kamu tetap bisa berpindah antar AP secara normal.

## Seberapa cepat?

_Pemicu > Uji Kecepatan > Uji Kecepatan Jaringan_ mengukur kecepatan unggah dan unduh aktualmu dengan sepasang indikator. Dari terminal, perintahnya adalah `omarchy network speedtest down` atau `up`. (Ada uji kecepatan disk yang bersebelahan dengannya di menu itu, kalau kamu sedang mengukur hambatan yang lain.)

## Firewall

Firewall aktif secara bawaan dan memblokir semua lalu lintas masuk, dengan satu pengecualian: port 53317, sehingga [LocalSend](22-guis.md) berfungsi langsung sejak awal.

SSH mati sampai kamu menyalakannya dengan _Pengaturan > Security > SSHD_, yang memulai daemon, membuka port 22 dengan pembatasan laju terhadap serangan brute force, dan mengotorisasi sebuah kunci. Docker juga dikunci rapat, sehingga kontainer tidak bisa secara tidak sengaja mengekspos dirinya ke dunia luar. Lihat [keamanan](48-security.md) untuk cerita lengkapnya.

## Tailscale

[Tailscale](https://tailscale.com/) adalah VPN mesh yang membuat menjangkau semua komputer dan servermu melalui internet menjadi sederhana dan aman. Pasang dengan _Pasang > Service > Tailscale_.

Itu memberimu panel Tailscale di bilah, yang menghubungkan dan memutuskan tailnet, berganti akun, dan memilih exit node — mesin-mesinmu sendiri dan wilayah Mullvad keduanya muncul dalam daftar. Panel ini juga menelusuri mesin-mesinmu, dan di situlah Taildrop berada: pilih sebuah mesin dan tekan `s` untuk mengirimkan berkas kepadanya, atau `c`, `n`, dan `d` untuk menyalin IP, nama, atau nama DNS lengkapnya. Padanan terminalnya adalah `omarchy tailscale send <machine> [file...]`, dan berkas yang dikirimkan kepadamu mendarat di `~/Downloads` secara otomatis. Notifikasi yang mengumumkan kedatangan akan menunggu sampai kamu mengkliknya untuk membuka atau menutupnya, jadi berkas yang muncul saat kamu jauh dari mesin tetap ada untuk ditanggapi saat kamu kembali.

Memasangnya juga menambahkan aplikasi web untuk konsol admin Tailscale.

## Saat berhenti berfungsi

Sebelum melakukan reboot, coba mulai ulang bagian yang bermasalah itu sendiri. _Perbarui > Hardware_ memiliki Wi-Fi, Bluetooth, Audio, dan Trackpad, dan memuat ulang salah satunya menyelesaikan sebagian besar situasi "tadi lima menit yang lalu berfungsi". Lihat [pemecahan masalah](45-troubleshooting.md).
