# Tangkapan Skrin & Rakaman

Semua yang anda boleh ambil dari skrin bergantung pada kekunci Print Screen. Satu kekunci itu sahaja mengambil gambar, dan pengubah suai mengambil rakaman, warna, atau teks di dalam sesuatu kawasan. Jika papan kekunci anda langsung tiada kekunci Print Screen, `Super + Ctrl + Alt + C` mengambil tangkapan skrin yang sama, dan `Super + Ctrl + C` membuka keseluruhan set sebagai menu.

| Kekunci pintas | Fungsi |
| ------ | -------- |
| `Print Screen` | Tangkapan skrin |
| `Super + Ctrl + Alt + C` | Tangkapan skrin |
| `Alt + Print Screen` | Rakaman skrin (atau hentikan rakaman yang sedang berjalan) |
| `Super + Print Screen` | Pemilih warna |
| `Super + Ctrl + Print Screen` | Ekstrak teks daripada sesuatu kawasan |
| `Super + Ctrl + C` | Menu tangkapan |
| `Super + Ctrl + .` | Transkod gambar atau video |

## Tangkapan Skrin

Tekan `Print Screen` (atau `Super + Ctrl + Alt + C`) dan Omasnap menangkap monitor yang berfokus sebelum lapisannya muncul, jadi tiada apa-apa yang beralih di bawah anda semasa anda menyasar. Seret kawasan bentuk bebas, klik tetingkap untuk menangkapnya, atau klik ruang kosong untuk menangkap keseluruhan monitor. Tekan `S` sebelum melukis untuk menangkap kawasan tatalan. Berubah fikiran? Tekan kekunci yang sama sekali lagi untuk menutup Omasnap.

Selepas anda memilih sesuatu kawasan, Omasnap menyimpan tangkapan itu, menyalinnya ke papan klip, dan menunjukkan pratonton selama 10 saat. Gunakan butang pin pada pratonton atau `Ctrl + P` untuk mengekalkannya pada skrin, atau pilih Edit untuk menganotasinya.

Editor anotasi boleh melukis anak panah, garisan, bentuk, sorotan, penanda bernombor, teks, dan redaksi selamat; memangkas atau memotong keluar sebahagian gambar; meng-OCR teksnya; dan menambah latar. Dalam editor, tekan `Enter` untuk menyalin dan menyimpan PNG yang siap, `Ctrl + C` untuk menyalinnya tanpa menyimpan, atau `Ctrl + S` untuk menyimpannya tanpa menyalin.

Tangkapan skrin yang disimpan masuk ke `~/Pictures/Screenshots` secara lalai, dengan nama seperti `screenshot-2026-08-13_14-22-05-firefox.png`. Tetapkan `OMASNAP_SCREENSHOT_DIR` untuk menggunakan direktori lain — lihat [Soalan Lazim](46-faq.md) untuk tempat meletakkan pemboleh ubah persekitaran sesi. Omasnap mencipta direktori itu apabila ia menyimpan tangkapan pertama. Tetapkan `[output] autosave = false` dalam `~/.config/omasnap/omasnap.conf` untuk melumpuhkan penyimpanan automatik.

Dari terminal, `omarchy screenshot` membuka lapisan yang sama, dan anda boleh memilih mod permulaannya: `omarchy capture screenshot region`, `windows`, `fullscreen`, atau `scroll`. Argumen kedua `copy` atau `save` melangkau pratonton dan menghantar tangkapan terus ke destinasi itu. Untuk mengedit sebelum output, gunakan `omarchy screenshot --editor=overlay` untuk editor skrin penuh atau `omarchy screenshot --editor=window` untuk tetingkap berasingan.

### Mengawal pemilih dari papan kekunci

Semasa pilihan sedang dipaparkan, anda tidak perlu menggunakan tetikus langsung:

| Kekunci | Fungsi |
| --- | -------- |
| `S` | Togol mod kawasan tatalan |
| `Super + Arrow keys` | Bergerak antara tetingkap dalam mod Tetingkap |
| `Return` | Tangkap tetingkap yang diserlahkan |
| `Ctrl + A` | Tangkap keseluruhan monitor yang berfokus |
| `R` | Pulihkan kawasan terakhir yang dilukis dalam sesi ini |
| `Esc` | Tutup Omasnap |

Ikatan ini hanya wujud semasa Omasnap terbuka, jadi ia tidak boleh bertembung dengan apa-apa dalam konfigurasi anda sendiri.

## Rakaman skrin

`Alt + Print Screen` membuka _Trigger > Capture > Screenrecord_, yang bertanya apa yang anda mahu pada runut bunyi: tiada audio, audio desktop, desktop tambah mikrofon, atau desktop tambah mikrofon tambah kamera web. Pilihan terakhir itu hanya muncul jika anda benar-benar mempunyai kamera yang dipasang. Pilih satu dan pemilih rakaman Omarchy membenarkan anda menyeret kawasan atau mengklik tetingkap atau monitor.

Rakaman berjalan pada gpu-screen-recorder, yang mengekod pada GPU pada 60fps dan kembali kepada CPU jika terpaksa. Hasilnya ialah MP4 dalam `~/Videos`, bernama `screenrecording-2026-08-13_14-22-05.mp4`. Tetapkan `OMARCHY_SCREENRECORD_DIR` untuk mengubahnya — tetapi ambil perhatian bahawa tidak seperti direktori tangkapan skrin, direktori ini mesti sudah wujud, atau rakaman enggan bermula.

Semasa anda merakam, satu penunjuk kecil muncul dalam bar. Klik penunjuk itu untuk berhenti. Anda juga boleh berhenti dengan `Alt + Print Screen` sekali lagi, atau dengan entri _Stop Screenrecording_ di bawah _Trigger > Capture > Screenrecord_, yang hanya muncul semasa sesuatu benar-benar sedang dirakam.

Menghentikan rakaman membuat sedikit kerja kemas sebelum menyerahkan fail kepada anda: bingkai pertama dipangkas, dan jika ada audio ia dinormalkan kepada -14 LUFS dengan bunyi pop tangkapan PipeWire pada permulaan sekali disenyapkan. Kemudian pemberitahuan muncul dengan lakaran kecil daripada rakaman itu. Klik pemberitahuan itu untuk memainkan fail dalam mpv.

### Lapisan kamera web

Apabila anda merakam dengan kamera web, kamera itu muncul sebagai tetingkap potret yang dipin dan dipangkas di sudut kanan bawah apa sahaja yang anda rakam. Jika ia berada di atas sesuatu yang anda perlukan, ubah saiznya dengan segera:

| Kekunci pintas | Fungsi |
| ------ | -------- |
| `Super + Alt + [` | Kecilkan lapisan kamera web |
| `Super + Alt + ]` | Besarkan lapisan kamera web |

Ada tiga saiz — kecil, sederhana, dan besar — dan kekunci pintas melangkah antaranya. Sederhana ialah lalai. Ia berkadar dengan rakaman, jadi kamera mengambil bahagian bingkai yang sama sama ada anda merakam monitor 1080p atau monitor 6K. Dan jika anda merakam kawasan dan bukannya keseluruhan paparan, lapisan itu berlabuh pada sudut kawasan itu dan bukannya sudut monitor, jadi ia kekal di dalam tangkapan.

Anda juga boleh memanggilnya terus dengan `omarchy-capture-webcam-resize small`, atau `reset` untuk kembali kepada sederhana.

## Teks, kod QR, dan warna

`Super + Ctrl + Print Screen` memilih kawasan dan meng-OCR-nya ke papan klip. Itu dibincangkan dengan betul dalam [Pengekstrakan Teks & Dikte](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ melakukan helah yang sama untuk kod QR. Pilih kawasan yang mengandungi kod itu, dan nilai yang dinyahkod masuk ke papan klip. Ia hanya mencari kod QR — kandungan skrin yang padat selalunya cenderung memberi positif palsu sebagai kod bar jika sebaliknya. Perlu diketahui: nilai yang dinyahkod masuk ke papan klip dan tidak ke tempat lain. Ia tidak dicetak, ia tidak ada dalam pemberitahuan, dan ia ditanda sensitif supaya ia tidak kekal dalam [sejarah papan klip](08-unified-clipboard-history.md). Kod QR lazimnya membawa rahsia — URI `otpauth://` di sebalik kod persediaan 2FA, sebagai satu contoh — dan anda tidak mahu itu dalam log. Menampal tetap berfungsi dengan baik.

`Super + Print Screen` (atau _Trigger > Capture > Color_) menukar kursor menjadi penitis mata. Klik apa sahaja pada skrin dan warna itu masuk ke papan klip. Tekan kekunci pintas itu sekali lagi untuk keluar tanpa memilih.

## Transkod sebelum anda berkongsi

Rakaman skrin 4K atau HEIC mentah dari telefon anda selalunya terlalu besar untuk dihantar begitu sahaja. `Super + Ctrl + .` (atau _Trigger > Transcode_) membetulkannya. Ia menawarkan pemilih fail kabur ke atas `~/Pictures` dan `~/Videos`, kemudian bertanya format dan saiz.

Gambar pergi ke jpg atau png pada tinggi, sederhana, atau rendah, yang mengehadkan lebar kepada 3160, 2160, dan 1080 piksel. Video pergi ke mp4 atau gif beranimasi pada 4k, 1080p, atau 720p. Fail yang ditukar ditulis di sebelah fail asal dengan resolusi dalam nama — `demo-1080p.mp4` — dan laluannya disalin ke papan klip sebagai URI fail, jadi anda boleh menampalnya terus ke dalam aplikasi yang menerima jatuhan fail.

Ia juga berfungsi dari terminal, jika anda sudah tahu apa yang anda mahu: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Ada juga `omarchy transcode ascii`, yang menukar gambar menjadi seni ASCII — yang itu kebanyakannya untuk [penjenamaan](41-branding.md).

## Menghantarnya ke suatu tempat

Sebaik sahaja anda mempunyai fail itu, `Super + Ctrl + S` membuka menu Share dan menghantarnya ke peranti lain pada rangkaian anda melalui LocalSend. Lihat [GUIs](22-guis.md) untuk itu.
