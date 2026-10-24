# Tangkap Skrin & Rakaman

Segala-galanya yang anda boleh ambil dari skrin bergantung pada kekunci Print Screen. Satu kekunci dengan sendirinya mengambil gambar, dan pengubah mengambil Rakaman, warna, atau teks di dalam kawasan. Jika papan kekunci anda tidak mempunyai kekunci Print Screen langsung, `Super + Ctrl + C` membuka set yang sama sebagai menu.

| Kekunci Panas | Fungsi |
| ------ | -------- |
| `Print Screen` | Tangkap Skrin |
| `Alt + Print Screen` | Rakam Skrin (atau hentikan yang sedang berjalan) |
| `Super + Print Screen` | Pemilih warna |
| `Super + Ctrl + Print Screen` | Ekstrak teks dari kawasan |
| `Super + Ctrl + C` | Menu tangkap |
| `Super + Ctrl + .` | Transkod gambar atau video |

## Tangkap Skrin

Tekan `Print Screen` dan Omasnap menangkap monitor yang difokuskan sebelum tindanannya muncul, jadi tiada apa-apa beralih di bawah anda semasa anda menyasar. Seret kawasan bentuk bebas, klik tetingkap untuk menangkapnya, atau klik ruang terbuka untuk menangkap keseluruhan monitor. Tekan `S` sebelum melukis untuk menangkap kawasan menatal. Berubah fikiran? Tekan `Print Screen` sekali lagi untuk menolak Omasnap.

Selepas anda memilih kawasan, Omasnap menyimpan tangkapan, menyalinnya ke papan keratan, dan memaparkan pratonton selama 10 saat. Gunakan butang pin pratonton atau `Ctrl + P` untuk mengekalkannya pada skrin, atau pilih Sunting untuk menganotasikannya.

Penyunting anotasi boleh melukis anak panah, garis, bentuk, serlahan, penanda bernombor, teks, dan penapisan selamat; memangkas atau memotong sebahagian daripada imej; OCR teksnya; dan menambah latar. Dalam penyunting, tekan `Enter` untuk menyalin dan menyimpan PNG yang siap, `Ctrl + C` untuk menyalinnya tanpa menyimpan, atau `Ctrl + S` untuk menyimpannya tanpa menyalin.

Tangkap Skrin yang disimpan tiba di `~/Pictures/Screenshots` secara lalai, dengan nama seperti `screenshot-2026-08-13_14-22-05-firefox.png`. Tetapkan `OMASNAP_SCREENSHOT_DIR` untuk menggunakan direktori lain — lihat [Soalan Lazim](46-faq.md) untuk tempat meletakkan pemboleh ubah persekitaran sesi. Omasnap mencipta direktori apabila ia menyimpan tangkapan pertama. Tetapkan `[output] autosave = false` dalam `~/.config/omasnap/omasnap.conf` untuk melumpuhkan penyimpanan automatik.

Dari terminal, `omarchy screenshot` membuka tindanan yang sama, dan anda boleh memilih mod permulaannya: `omarchy capture screenshot region`, `windows`, `fullscreen`, atau `scroll`. Argumen kedua `copy` atau `save` melangkau pratonton dan menghantar tangkapan terus ke destinasi itu. Untuk menyunting sebelum output, gunakan `omarchy screenshot --editor=overlay` untuk penyunting skrin penuh atau `omarchy screenshot --editor=window` untuk tetingkap berasingan.

### Memandu pemilih dari papan kekunci

Semasa pemilihan dipaparkan, anda tidak perlu menggunakan tetikus langsung:

| Kekunci | Fungsi |
| --- | -------- |
| `S` | Togol mod kawasan menatal |
| `Super + Arrow keys` | Bergerak antara tetingkap dalam mod Tetingkap |
| `Return` | Tangkap tetingkap yang diserlahkan |
| `Ctrl + A` | Tangkap monitor penuh yang difokuskan |
| `R` | Pulihkan kawasan terakhir yang dilukis dalam sesi ini |
| `Esc` | Tolak Omasnap |

Ikatan ini hanya wujud semasa Omasnap dibuka, jadi ia tidak boleh berlanggar dengan apa-apa dalam konfigurasi anda sendiri.

## Rakaman skrin

`Alt + Print Screen` membuka _Pencetus > Tangkap > Rakam Skrin_, yang bertanya apa yang anda mahukan pada runut bunyi: tanpa audio, audio desktop, desktop tambah mikrofon, atau desktop tambah mikrofon tambah webcam. Yang terakhir itu hanya muncul jika anda benar-benar mempunyai kamera yang dipalamkan. Pilih satu dan pemilih Rakaman Omarchy membenarkan anda menyeret kawasan atau mengklik tetingkap atau monitor.

Rakaman berjalan pada gpu-screen-recorder, yang mengekod pada GPU pada 60fps dan kembali kepada CPU jika terpaksa. Hasilnya ialah MP4 dalam `~/Videos`, bernama `screenrecording-2026-08-13_14-22-05.mp4`. Tetapkan `OMARCHY_SCREENRECORD_DIR` untuk menukarnya — tetapi ambil perhatian bahawa tidak seperti direktori Tangkap Skrin, direktori ini perlu sudah wujud, atau Rakaman enggan dimulakan.

Semasa anda merakam, penunjuk kecil muncul dalam bar. Kliknya untuk berhenti. Anda juga boleh berhenti dengan `Alt + Print Screen` sekali lagi, atau dengan entri _Henti Rakam Skrin_ di bawah _Pencetus > Tangkap > Rakam Skrin_, yang hanya muncul semasa sesuatu benar-benar sedang dirakam.

Berhenti melakukan sedikit pengemasan sebelum ia menyerahkan fail kepada anda: bingkai pertama dipangkas, dan jika terdapat audio ia dinormalisasikan kepada -14 LUFS dengan letusan tangkapan PipeWire pada permulaan sekali disenyapkan. Kemudian pemberitahuan muncul dengan lakaran kenit daripada Rakaman. Kliknya untuk memainkan fail dalam mpv.

### Tindanan webcam

Apabila anda merakam dengan webcam, kamera muncul sebagai tetingkap potret tersemat yang dipangkas di sudut kanan bawah apa sahaja yang anda rakam. Jika ia berada di atas sesuatu yang anda perlukan, ubah saiznya dengan segera:

| Kekunci Panas | Fungsi |
| ------ | -------- |
| `Super + Alt + [` | Kecilkan tindanan webcam |
| `Super + Alt + ]` | Besarkan tindanan webcam |

Terdapat tiga saiz — kecil, sederhana, dan besar — dan kekunci panas melangkah antaranya. Sederhana ialah lalainya. Ia berkadaran dengan Rakaman, jadi kamera mengambil bahagian bingkai yang sama sama ada anda merakam monitor 1080p atau 6K. Dan jika anda merakam kawasan dan bukannya keseluruhan paparan, tindanan bertambat pada sudut kawasan itu dan bukannya monitor, jadi ia kekal di dalam tangkapan.

Anda juga boleh memanggilnya terus dengan `omarchy-capture-webcam-resize small`, atau `reset` untuk kembali kepada sederhana.

## Teks, kod QR, dan warna

`Super + Ctrl + Print Screen` memilih kawasan dan melakukan OCR padanya ke papan keratan. Itu dibincangkan dengan betul dalam [Pengekstrakan Teks & Pendiktean](11-text-extraction-dictation.md).

_Pencetus > Tangkap > Kod QR_ melakukan helah yang sama untuk kod QR. Pilih kawasan dengan kod di dalamnya, dan nilai yang dinyahkod pergi ke papan keratan. Ia hanya mencari kod QR — kandungan skrin yang padat mempunyai tabiat positif palsu sebagai kod bar sebaliknya. Berbaloi untuk diketahui: nilai yang dinyahkod pergi ke papan keratan dan tidak ke mana-mana lagi. Ia tidak dicetak, ia tidak berada dalam pemberitahuan, dan ia ditandakan sensitif jadi ia tidak kekal dalam [Sejarah Papan Keratan](08-unified-clipboard-history.md). Kod QR kerap membawa rahsia — URI `otpauth://` di sebalik kod persediaan 2FA, sebagai contoh — dan anda tidak mahu itu dalam log. Penampalan masih berfungsi dengan baik.

`Super + Print Screen` (atau _Pencetus > Tangkap > Warna_) menjadikan kursor penitis mata. Klik apa-apa pada skrin dan warna tiba pada papan keratan. Tekan kekunci panas sekali lagi untuk berundur tanpa memilih.

## Pentranskoda sebelum anda berkongsi

Rakaman skrin 4K atau HEIC mentah dari telefon anda selalunya terlalu besar untuk dihantar begitu sahaja. `Super + Ctrl + .` (atau _Pencetus > Transkod_) membetulkannya. Ia menawarkan anda pemilih fail kabur ke atas `~/Pictures` dan `~/Videos`, kemudian meminta format dan saiz.

Gambar pergi ke jpg atau png pada tinggi, sederhana, atau rendah, yang mengehadkan lebar pada 3160, 2160, dan 1080 piksel. Video pergi ke mp4 atau gif beranimasi pada 4k, 1080p, atau 720p. Fail yang ditukar ditulis di sebelah yang asal dengan resolusi dalam namanya — `demo-1080p.mp4` — dan laluan disalin ke papan keratan sebagai URI fail, jadi anda boleh menampalnya terus ke dalam aplikasi yang mengambil jatuhan fail.

Ia juga berfungsi dari terminal, jika anda sudah tahu apa yang anda mahukan: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Terdapat juga `omarchy transcode ascii`, yang menukar imej kepada seni ASCII — itu kebanyakannya untuk [penjenamaan](41-branding.md).

## Menghantarnya ke suatu tempat

Sebaik sahaja anda mendapat fail, `Super + Ctrl + S` membuka menu Kongsi dan menghantarnya ke peranti lain pada Rangkaian anda melalui LocalSend. Lihat [GUI](22-guis.md) untuk itu.
