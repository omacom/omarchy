# Latar Belakang

Setiap tema disertakan dengan set latar belakangnya sendiri, dan anda boleh menambah latar belakang tambahan anda sendiri di `~/.config/omarchy/backgrounds/[theme]`. Jika anda mahu menambah imej latar belakang tambahan pada, katakan, tema nord, anda hanya perlu meletakkan fail tersebut di `~/.config/omarchy/backgrounds/nord`.

Cara paling mudah untuk melakukan ini ialah dengan pergi ke _Install > Style > Background_ dalam Omarchy Menu. Itu akan membuka folder tempat latar belakang bagi tema tersebut disimpan. Tekan `Super + Shift + F` untuk membuka pengurus fail lain, cari latar belakang anda, salin fail tersebut ke sana. Sekarang ia akan disertakan dalam pilihan latar belakang yang boleh anda pilih menggunakan `Super + Ctrl + W`.

Latar belakang juga boleh berupa video dan bukan hanya imej pegun. Letakkan fail `mp4`, `m4v`, `mov`, `webm`, `mkv`, atau `avi` dalam folder yang sama dan ia akan muncul bersama-sama imej. Video dimainkan oleh enjin kertas dinding OWE. Ia menyahkod video sekali untuk semua monitor dan memainkan bunyinya melalui output audio lalai, dan ia menghentikan main balik apabila tiada apa yang dapat melihatnya. Kertas dinding video masih menggunakan jauh lebih banyak kuasa berbanding kertas dinding pegun.

Tema boleh menyertakan intro pendek untuk latar belakang pegun. Untuk `backgrounds/road.webp`, video yang sepadan terletak di `backgrounds/intros/road.mp4`. Ia dimainkan secara automatik semasa but, apabila bertukar kepada tema dengan latar belakang tersebut dipilih, dan apabila memilih latar belakang tersebut, kemudian kembali kepada imej pegun. Video intro tidak dipaparkan dalam pemilih latar belakang dan tidak pernah berulang.

Memilih _Appearance > Animations Off_ juga akan mematikan intro latar belakang. Omarchy melakukan ini secara lalai dalam mesin maya. Perintah `omarchy theme bg intro toggle` boleh menogol intro secara berasingan. Menyegar semula tema tidak akan memainkan intro.

Imej pegun juga boleh mempunyai gelung, versi senyap bagi gambar yang sama yang terus bergerak, di `backgrounds/loops/road.mp4`. Ia dimainkan menggantikan imej pegun, selepas intronya jika ada, dan berhenti apabila animasi dimatikan. Apabila menggunakan bateri, imej pegun akan dipaparkan sebagai ganti, dan gelung akan kembali sebaik sahaja anda memasang pengecas. Gelung tidak dipaparkan dalam pemilih latar belakang.

Anda boleh menemui koleksi besar latar belakang terpilih yang menarik di [dharmx/walls](https://github.com/dharmx/walls).

Skrin kunci menunjukkan bingkai pegun daripada latar belakang video, sama seperti cara ia menunjukkan bingkai pegun daripada GIF beranimasi.
