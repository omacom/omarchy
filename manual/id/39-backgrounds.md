# Latar Belakang

Setiap tema dilengkapi dengan set latar belakangnya sendiri, dan kamu bisa menambahkan latar belakang tambahan milikmu sendiri di `~/.config/omarchy/backgrounds/[theme]`. Jika kamu ingin menambahkan gambar latar belakang tambahan ke, misalnya, tema nord, cukup letakkan file tersebut di `~/.config/omarchy/backgrounds/nord`.

Cara paling mudah melakukannya adalah dengan membuka _Instal > Gaya > Latar Belakang_ di Omarchy Menu. Itu akan membuka folder tempat latar belakang untuk tema tersebut disimpan. Tekan `Super + Shift + F` untuk memulai manajer file lain, temukan latar belakangmu, lalu salin ke sana. Sekarang latar belakang itu akan disertakan dalam pilihan latar belakang yang bisa kamu pilih menggunakan `Super + Ctrl + W`.

Latar belakang bisa berupa video maupun gambar diam. Letakkan file `mp4`, `m4v`, `mov`, `webm`, `mkv`, atau `avi` di folder yang sama dan file itu akan muncul di samping gambar-gambar tersebut. Video diputar oleh mesin wallpaper OWE. Mesin ini mendekode video sekali untuk semua monitor dan memutar suaranya melalui output audio default, serta menghentikan pemutaran setiap kali tidak ada yang bisa melihatnya. Wallpaper video tetap menghabiskan daya jauh lebih banyak daripada wallpaper gambar diam.

Tema bisa menyertakan intro singkat untuk latar belakang gambar diam. Untuk `backgrounds/road.webp`, video yang cocok berada di `backgrounds/intros/road.mp4`. Video itu diputar secara otomatis saat boot, saat beralih ke tema dengan latar belakang tersebut terpilih, dan saat memilih latar belakang tersebut, lalu kembali ke gambar diam. Video intro tidak muncul di pemilih latar belakang dan tidak pernah berulang.

Mematikan _Tampilan > Animasi_ juga mematikan intro latar belakang. Omarchy melakukan ini secara default di mesin virtual. Perintah `omarchy theme bg intro toggle` bisa mengaktifkan/menonaktifkan intro secara terpisah. Menyegarkan tema tidak memutar intro.

Gambar diam juga bisa memiliki loop, versi tenang dari gambar yang sama yang terus bergerak, di `backgrounds/loops/road.mp4`. Loop itu diputar menggantikan gambar diam, setelah intronya jika ada, dan berhenti saat animasi dimatikan. Loop tidak muncul di pemilih latar belakang dan, seperti latar belakang video mana pun, menghabiskan daya lebih banyak daripada gambar diam.

Kamu bisa menemukan koleksi besar latar belakang keren yang dikurasi di [dharmx/walls](https://github.com/dharmx/walls).

Layar kunci menampilkan frame diam dari latar belakang video, dengan cara yang sama seperti menampilkan frame diam dari GIF animasi.
