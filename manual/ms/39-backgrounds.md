# Latar Belakang

Setiap tema disertakan dengan set latar belakangnya sendiri, dan anda boleh menambah latar belakang tambahan anda sendiri dalam `~/.config/omarchy/backgrounds/[theme]`. Jika anda mahu menambah imej latar belakang tambahan pada, katakan, tema nord, anda hanya perlu letakkan fail tersebut dalam `~/.config/omarchy/backgrounds/nord`.

Cara paling mudah untuk melakukannya ialah dengan pergi ke _Pasang > Gaya > Latar Belakang_ dalam Omarchy Menu. Itu akan membuka folder tempat latar belakang bagi tema tersebut disimpan. Tekan `Super + Shift + F` untuk memulakan pengurus fail yang lain, cari latar belakang anda, salin fail tersebut ke sana. Sekarang ia akan disertakan dalam pilihan latar belakang yang boleh anda pilih menggunakan `Super + Ctrl + W`.

Tema yang tiada latar belakangnya sendiri akan mendapat satu latar belakang yang dilukis daripada warnanya: logo Omarchy dalam warna aksen tema tersebut pada warna latar belakangnya. Tambah latar belakang anda sendiri untuk menggantikannya.

Latar belakang juga boleh berupa video dan bukan hanya imej pegun. Letakkan fail `mp4`, `m4v`, `mov`, `webm`, `mkv`, atau `avi` dalam folder yang sama dan ia akan muncul di samping imej-imej tersebut. Video dimainkan oleh enjin kertas dinding OWE. Ia menyahkod video sekali untuk semua monitor dan memainkan bunyinya melalui output audio lalai, dan ia menghentikan main semula apabila tiada apa-apa yang dapat melihatnya. Kertas dinding video masih menggunakan jauh lebih banyak kuasa berbanding kertas dinding pegun.

Tema boleh menyertakan intro pendek untuk latar belakang pegun. Untuk `backgrounds/road.webp`, video yang sepadan terletak di `backgrounds/intros/road.mp4`. Ia dimainkan secara automatik semasa but, apabila bertukar kepada tema dengan latar belakang tersebut dipilih, dan apabila memilih latar belakang tersebut, kemudian kembali kepada imej pegun. Video intro tidak muncul dalam pemilih latar belakang dan tidak pernah berulang.

Memilih _Rupa > Animasi Mati_ juga akan mematikan intro latar belakang. Omarchy melakukan ini secara lalai dalam mesin maya. Arahan `omarchy theme bg intro toggle` boleh menogol intro secara berasingan. Menyegar semula tema tidak memainkan intro.

Imej pegun juga boleh mempunyai gelung, versi senyap bagi gambar yang sama yang terus bergerak, di `backgrounds/loops/road.mp4`. Ia dimainkan menggantikan imej pegun, selepas intronya jika ada, dan berhenti apabila animasi dimatikan. Apabila menggunakan bateri, imej pegun akan dipaparkan sebaliknya, dan gelung akan kembali sebaik sahaja anda memasang palam. Gelung tidak muncul dalam pemilih latar belakang.

Anda boleh menemui koleksi besar latar belakang terpilih yang menarik dalam [dharmx/walls](https://github.com/dharmx/walls).

Skrin kunci menunjukkan bingkai pegun bagi latar belakang video, sama seperti ia menunjukkan bingkai pegun bagi GIF beranimasi.
