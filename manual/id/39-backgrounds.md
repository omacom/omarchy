# Latar Belakang

Setiap tema dilengkapi dengan kumpulan latar belakangnya sendiri, dan kamu bisa menambahkan latar belakang tambahan milikmu sendiri di `~/.config/omarchy/backgrounds/[theme]`. Jika kamu ingin menambahkan gambar latar belakang tambahan ke, misalnya, tema nord, kamu cukup meletakkan file tersebut di `~/.config/omarchy/backgrounds/nord`.

Cara termudah untuk melakukannya adalah dengan membuka _Install > Style > Background_ di Omarchy Menu. Itu akan membuka folder tempat latar belakang untuk tema tersebut disimpan. Tekan `Super + Shift + F` untuk membuka file manager lain, temukan latar belakangmu, lalu salin file tersebut ke sana. Sekarang latar belakang itu akan disertakan dalam pilihan latar belakang yang bisa kamu pilih dengan menggunakan `Super + Ctrl + W`.

Latar belakang juga bisa berupa video, bukan hanya gambar diam. Letakkan file `mp4`, `m4v`, `mov`, `webm`, `mkv`, atau `avi` di folder yang sama dan file itu akan muncul di samping gambar-gambar. Video diputar oleh mesin wallpaper OWE. Mesin ini mendekode video satu kali untuk semua monitor dan memutar suaranya melalui output audio default, dan menghentikan pemutaran setiap kali tidak ada yang bisa melihatnya. Wallpaper video tetap menghabiskan daya jauh lebih besar daripada wallpaper gambar diam.

Tema bisa menyertakan intro singkat untuk latar belakang gambar diam. Untuk `backgrounds/road.webp`, video yang cocok berada di `backgrounds/intros/road.mp4`. Video itu diputar secara otomatis saat boot, saat beralih ke tema dengan latar belakang tersebut terpilih, dan saat memilih latar belakang tersebut, lalu kembali ke gambar diam. Video intro tidak muncul di pemilih latar belakang dan tidak pernah berulang.

Memilih _Appearance > Animations Off_ juga mematikan intro latar belakang. Omarchy melakukan ini secara default di virtual machine. Perintah `omarchy theme bg intro toggle` bisa mengaktifkan atau menonaktifkan intro secara terpisah. Menyegarkan tema tidak memutar intro.

Gambar diam juga bisa memiliki loop, versi tenang dari gambar yang sama yang terus bergerak, di `backgrounds/loops/road.mp4`. Loop itu diputar menggantikan gambar diam, setelah intronya jika ada, dan berhenti saat animasi dimatikan. Saat menggunakan baterai, gambar diam yang ditampilkan sebagai gantinya, dan loop kembali muncul setelah kamu mencolokkan daya. Loop tidak muncul di pemilih latar belakang.

Kamu bisa menemukan koleksi besar latar belakang keren yang dikurasi di [dharmx/walls](https://github.com/dharmx/walls).

Layar kunci menampilkan frame diam dari latar belakang video, dengan cara yang sama seperti menampilkan frame diam dari GIF animasi.
