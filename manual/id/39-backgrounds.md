# Latar Belakang

Setiap tema dilengkapi dengan set latar belakangnya sendiri, dan Anda bisa menambahkan latar belakang tambahan milik Anda sendiri di `~/.config/omarchy/backgrounds/[theme]`. Jika Anda ingin menambahkan gambar latar belakang tambahan ke, misalnya, tema nord, Anda cukup meletakkan file tersebut di `~/.config/omarchy/backgrounds/nord`.

Cara termudah untuk melakukannya adalah dengan membuka _Instal > Gaya > Latar Belakang_ di Omarchy Menu. Itu akan membuka folder tempat latar belakang untuk tema tersebut disimpan. Tekan `Super + Shift + F` untuk membuka file manager lain, temukan latar belakang Anda, lalu salin ke folder tersebut. Sekarang latar belakang itu akan tersedia dalam pilihan latar belakang yang bisa Anda pilih menggunakan `Super + Ctrl + W`.

Latar belakang juga bisa berupa video, bukan hanya gambar diam. Letakkan file `mp4`, `m4v`, `mov`, `webm`, `mkv`, atau `avi` di folder yang sama dan file tersebut akan muncul bersama gambar-gambar lainnya. Video diputar oleh mesin wallpaper OWE. Mesin ini mendekode video satu kali untuk semua monitor dan memutar suaranya melalui output audio default, serta menghentikan pemutaran setiap kali tidak ada yang bisa melihatnya. Latar belakang video tetap mengonsumsi daya jauh lebih besar daripada latar belakang diam.

Tema bisa menyertakan intro pendek untuk latar belakang diam. Untuk `backgrounds/road.webp`, video yang sesuai berada di `backgrounds/intros/road.mp4`. Video ini diputar otomatis saat boot dan saat beralih ke tema dengan latar belakang tersebut terpilih, lalu kembali ke gambar diam. Video intro tidak muncul di pemilih latar belakang dan tidak pernah berputar ulang.

Mematikan _Tampilan > Animasi_ juga akan mematikan intro latar belakang. Omarchy melakukan ini secara default di mesin virtual. Perintah `omarchy theme bg intro toggle` bisa mengaktifkan atau menonaktifkan intro secara terpisah. Menyegarkan tema atau memilih latar belakang lain dalam tema yang sama tidak akan memutar intro.

Anda bisa menemukan koleksi besar latar belakang keren yang telah dikurasi di [dharmx/walls](https://github.com/dharmx/walls).

Layar kunci menampilkan frame diam dari latar belakang video, sama seperti ia menampilkan frame diam dari GIF animasi.
