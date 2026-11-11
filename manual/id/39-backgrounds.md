# Latar Belakang

Setiap tema dilengkapi dengan kumpulan latar belakangnya sendiri, dan kamu bisa menambahkan latar belakang ekstra milikmu sendiri di `~/.config/omarchy/backgrounds/[theme]`. Jika kamu ingin menambahkan gambar latar belakang ekstra ke, misalnya, tema nord, kamu cukup menaruh file tersebut di `~/.config/omarchy/backgrounds/nord`.

Cara paling mudah untuk melakukannya adalah dengan membuka _Install > Style > Background_ di Omarchy Menu. Itu akan membuka folder tempat latar belakang untuk tema tersebut disimpan. Tekan `Super + Shift + F` untuk memulai file manager lain, temukan latar belakangmu, lalu salin ke sana. Sekarang latar belakang itu akan termasuk dalam pilihan latar belakang yang bisa kamu pilih menggunakan `Super + Ctrl + W`.

Latar belakang bisa berupa video maupun gambar diam. Taruh file `mp4`, `m4v`, `mov`, `webm`, `mkv`, atau `avi` di folder yang sama dan file itu akan muncul di samping gambar-gambar tersebut. Video diputar oleh mesin wallpaper OWE. Mesin ini mendekode video satu kali untuk semua monitor dan memutar suaranya melalui output audio default, serta menghentikan pemutaran setiap kali tidak ada yang bisa melihatnya. Wallpaper video tetap menghabiskan daya jauh lebih besar daripada wallpaper diam.

Tema dapat menyertakan intro singkat untuk latar belakang diam. Untuk `backgrounds/road.webp`, video yang cocok berada di `backgrounds/intros/road.mp4`. Video ini diputar secara otomatis saat boot, saat beralih ke tema dengan latar belakang tersebut terpilih, dan saat memilih latar belakang tersebut, lalu kembali ke gambar diam. Video intro tetap berada di luar pemilih latar belakang dan tidak pernah diputar berulang.

Mematikan _Appearance > Animations_ juga mematikan intro latar belakang. Omarchy melakukan ini secara default di mesin virtual. Perintah `omarchy theme bg intro toggle` dapat mengaktifkan atau menonaktifkan intro secara terpisah. Menyegarkan tema tidak memutar intro.

Kamu bisa menemukan koleksi besar latar belakang keren yang dikurasi di [dharmx/walls](https://github.com/dharmx/walls).

Layar kunci menampilkan frame diam dari latar belakang video, sama seperti ia menampilkan frame diam dari GIF animasi.
