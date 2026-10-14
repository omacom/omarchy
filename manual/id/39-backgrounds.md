# Latar Belakang

Setiap tema dilengkapi dengan rangkaian latar belakangnya sendiri, dan kamu bisa menambahkan tambahan milikmu sendiri di `~/.config/omarchy/backgrounds/[theme]`. Jika kamu ingin menambahkan gambar latar belakang tambahan ke, misalnya, tema nord, kamu cukup meletakkan berkasnya di `~/.config/omarchy/backgrounds/nord`.

Cara termudah melakukannya adalah dengan pergi ke _Pasang > Gaya > Latar Belakang_ di Menu Omarchy. Itu akan menampilkan folder tempat latar belakang untuk tema itu disimpan. Tekan `Super + Shift + F` untuk memulai pengelola berkas lain, temukan latar belakangmu, salin ke sana.  Sekarang itu akan disertakan dalam pilihan latar belakang yang bisa kamu pilih menggunakan `Super + Ctrl + Space`.

Latar belakang bisa berupa video maupun gambar diam. Letakkan berkas `mp4`, `m4v`, `mov`, `webm`, `mkv`, atau `avi` di folder yang sama dan itu akan muncul di samping gambar-gambar. Video diputar oleh mesin wallpaper OWE. Ia mendekode video sekali untuk semua monitor dan memutar suaranya melalui keluaran audio bawaan, dan ia menghentikan pemutaran setiap kali tidak ada yang bisa melihatnya. Layar kunci menggambar hasil dekode yang sama, tanpa suara, melalui OWE. Wallpaper video tetap menghabiskan daya jauh lebih banyak daripada yang diam.

Tema bisa menyertakan intro singkat untuk latar belakang diam. Untuk `backgrounds/road.webp`, video yang cocok berada di `backgrounds/intros/road.mp4`. Ia diputar otomatis saat boot dan saat beralih ke tema dengan latar belakang itu terpilih, lalu kembali ke gambar diam. Video intro tidak muncul di pemilih latar belakang dan tidak pernah berulang.

Mematikan _Pemicu > Tampilan > Animasi_ juga mematikan intro latar belakang. Omarchy melakukan ini secara bawaan di mesin virtual. Perintah `omarchy theme bg intro toggle` bisa mengalihkan intro secara terpisah. Menyegarkan tema atau memilih latar belakang lain dalam tema yang sama tidak memutar intro.

Kamu bisa menemukan koleksi besar latar belakang keren yang terkurasi di https://github.com/dharmx/walls.

Latar belakang video menyimpan gambar diam yang di-cache di layar kunci saat pemutaran dijeda atau tidak tersedia. GIF animasi diputar di desktop dan menunjukkan bingkai diam di layar kunci.
