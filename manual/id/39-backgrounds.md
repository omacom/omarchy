# Latar Belakang

Setiap tema dilengkapi dengan kumpulan latar belakangnya sendiri, dan Anda dapat menambahkan latar belakang tambahan milik Anda sendiri di `~/.config/omarchy/backgrounds/[theme]`. Jika Anda ingin menambahkan gambar latar belakang tambahan ke, misalnya, tema nord, Anda cukup meletakkan file tersebut di `~/.config/omarchy/backgrounds/nord`.

Cara termudah untuk melakukannya adalah dengan membuka _Instal > Gaya > Latar Belakang_ di Omarchy Menu. Itu akan membuka folder tempat latar belakang untuk tema tersebut disimpan. Tekan `Super + Shift + F` untuk membuka pengelola file lain, temukan latar belakang Anda, lalu salin ke folder tersebut. Sekarang latar belakang itu akan tersedia dalam pilihan latar belakang yang dapat Anda pilih menggunakan `Super + Ctrl + W`.

Tema yang tidak memiliki latar belakang sendiri akan mendapatkan satu latar belakang yang digambar dari warnanya: logo Omarchy dalam warna aksen tema di atas warna latar belakangnya. Tambahkan latar belakang Anda sendiri untuk menggantikannya.

Latar belakang dapat berupa video maupun gambar diam. Letakkan file `mp4`, `m4v`, `mov`, `webm`, `mkv`, atau `avi` di folder yang sama dan file tersebut akan muncul bersama gambar-gambar. Video diputar oleh mesin wallpaper OWE. Mesin ini mendekode video satu kali untuk semua monitor dan memutar suaranya melalui output audio default, serta menghentikan pemutaran setiap kali tidak ada yang dapat melihatnya. Wallpaper video tetap menghabiskan daya jauh lebih banyak daripada wallpaper gambar diam.

Tema dapat menyertakan intro singkat untuk latar belakang gambar diam. Untuk `backgrounds/road.webp`, video yang sesuai berada di `backgrounds/intros/road.mp4`. Video ini diputar otomatis saat boot, saat beralih ke tema dengan latar belakang tersebut dipilih, dan saat memilih latar belakang tersebut, kemudian kembali ke gambar diam. Video intro tidak ditampilkan di pemilih latar belakang dan tidak pernah diputar berulang.

Memilih _Tampilan > Animasi Mati_ juga mematikan intro latar belakang. Omarchy melakukan ini secara default di mesin virtual. Perintah `omarchy theme bg intro toggle` dapat mengalihkan intro secara terpisah. Menyegarkan tema tidak memutar intro.

Gambar diam juga dapat memiliki loop, versi tenang dari gambar yang sama yang terus bergerak, di `backgrounds/loops/road.mp4`. Loop ini diputar sebagai ganti gambar diam, setelah intronya jika ada, dan berhenti saat animasi dimatikan. Saat menggunakan baterai, gambar diam akan ditampilkan sebagai gantinya, dan loop akan kembali setelah Anda mencolokkan daya. Loop tidak ditampilkan di pemilih latar belakang.

Anda dapat menemukan koleksi besar latar belakang keren yang telah dikurasi di [dharmx/walls](https://github.com/dharmx/walls).

Layar kunci menampilkan bingkai diam dari latar belakang video, dengan cara yang sama seperti layar kunci menampilkan bingkai diam dari GIF animasi.
