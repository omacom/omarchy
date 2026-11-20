# Latar Belakang

Setiap tema dilengkapi dengan kumpulan latar belakangnya sendiri, dan Anda dapat menambahkan latar belakang tambahan milik Anda sendiri di `~/.config/omarchy/backgrounds/[theme]`. Jika Anda ingin menambahkan gambar latar belakang tambahan ke, misalnya, tema nord, Anda cukup meletakkan file tersebut di `~/.config/omarchy/backgrounds/nord`.

Anda dapat melakukannya dengan paling mudah dengan membuka _Install > Style > Background_ di Menu Omarchy. Itu akan membuka folder tempat latar belakang untuk tema tersebut disimpan. Tekan `Super + Shift + F` untuk membuka pengelola file lain, temukan latar belakang Anda, lalu salin ke sana. Sekarang latar belakang itu akan disertakan dalam pilihan latar belakang yang dapat Anda pilih menggunakan `Super + Ctrl + W`.

Latar belakang juga dapat berupa video, bukan hanya gambar diam. Letakkan file `mp4`, `m4v`, `mov`, `webm`, `mkv`, atau `avi` di folder yang sama dan file itu akan muncul di samping gambar-gambar tersebut. Video diputar oleh mesin wallpaper OWE. Mesin ini mendekode video satu kali untuk semua monitor dan memutar suaranya melalui output audio default, serta menghentikan pemutaran setiap kali tidak ada yang dapat melihatnya. Wallpaper video tetap menghabiskan jauh lebih banyak daya daripada wallpaper diam.

Tema dapat menyertakan intro singkat untuk latar belakang diam. Untuk `backgrounds/road.webp`, video yang sesuai berada di `backgrounds/intros/road.mp4`. Video itu diputar secara otomatis saat boot, saat beralih ke tema dengan latar belakang tersebut dipilih, dan saat memilih latar belakang tersebut, kemudian kembali ke gambar diam. Video intro tidak ditampilkan di pemilih latar belakang dan tidak pernah berulang.

Menonaktifkan _Appearance > Animations_ juga menonaktifkan intro latar belakang. Omarchy melakukan ini secara default di mesin virtual. Perintah `omarchy theme bg intro toggle` dapat mengaktifkan atau menonaktifkan intro secara terpisah. Menyegarkan tema tidak memutar intro.

Gambar diam juga dapat memiliki loop, versi tenang dari gambar yang sama yang terus bergerak, di `backgrounds/loops/road.mp4`. Video ini diputar menggantikan gambar diam, setelah intronya jika ada, dan berhenti saat animasi dinonaktifkan. Saat menggunakan baterai, gambar diam yang ditampilkan, dan loop kembali muncul setelah Anda menghubungkan daya. Loop tidak ditampilkan di pemilih latar belakang.

Anda dapat menemukan koleksi besar latar belakang keren yang dikurasi di [dharmx/walls](https://github.com/dharmx/walls).

Layar kunci menampilkan bingkai diam dari latar belakang video, dengan cara yang sama seperti menampilkan bingkai diam dari GIF animasi.
