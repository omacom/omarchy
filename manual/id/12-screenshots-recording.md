# Tangkapan Layar & Perekaman

Segala sesuatu yang dapat Anda ambil dari layar bergantung pada tombol Print Screen. Satu tombol sendiri mengambil gambar, dan modifier mengambil rekaman, warna, atau teks di dalam sebuah wilayah. Jika keyboard Anda tidak memiliki tombol Print Screen sama sekali, `Super + Ctrl + C` membuka set yang sama sebagai menu.

| Hotkey | Fungsi |
| ------ | -------- |
| `Print Screen` | Tangkapan layar |
| `Alt + Print Screen` | Rekam layar (atau hentikan yang sedang berjalan) |
| `Super + Print Screen` | Pemilih warna |
| `Super + Ctrl + Print Screen` | Ekstrak teks dari sebuah wilayah |
| `Super + Ctrl + C` | Menu tangkap |
| `Super + Ctrl + .` | Transkode gambar atau video |

## Tangkapan layar

Tekan `Print Screen` dan Omasnap menangkap monitor yang fokus sebelum overlay-nya muncul, sehingga tidak ada yang bergeser di bawah Anda saat Anda membidik. Seret wilayah bentuk bebas, klik jendela untuk menangkapnya, atau klik ruang terbuka untuk menangkap seluruh monitor. Tekan `S` sebelum menggambar untuk menangkap wilayah bergulir. Berubah pikiran? Tekan `Print Screen` lagi untuk menutup Omasnap.

Setelah Anda memilih area, Omasnap menyimpan tangkapan, menyalinnya ke papan klip, dan menunjukkan pratinjau selama 10 detik. Gunakan tombol sematkan pratinjau atau `Ctrl + P` untuk menjaganya tetap di layar, atau pilih Edit untuk memberi anotasi.

Editor anotasi dapat menggambar panah, garis, bentuk, sorotan, penanda bernomor, teks, dan redaksi aman; memangkas atau memotong bagian gambar; meng-OCR teksnya; dan menambahkan latar belakang. Dalam editor, tekan `Enter` untuk menyalin dan menyimpan PNG yang selesai, `Ctrl + C` untuk menyalinnya tanpa menyimpan, atau `Ctrl + S` untuk menyimpannya tanpa menyalin.

Tangkapan layar yang disimpan mendarat di `~/Pictures/Screenshots` secara bawaan, dengan nama seperti `screenshot-2026-08-13_14-22-05-firefox.png`. Atur `OMASNAP_SCREENSHOT_DIR` untuk menggunakan direktori lain — lihat [FAQ](46-faq.md) untuk tempat meletakkan variabel lingkungan sesi. Omasnap membuat direktori ketika menyimpan tangkapan pertama. Atur `[output] autosave = false` dalam `~/.config/omasnap/omasnap.conf` untuk menonaktifkan penyimpanan otomatis.

Dari terminal, `omarchy screenshot` membuka overlay yang sama, dan Anda dapat memilih mode awalnya: `omarchy capture screenshot region`, `windows`, `fullscreen`, atau `scroll`. Argumen kedua `copy` atau `save` melewati pratinjau dan langsung mengirim tangkapan ke tujuan itu. Untuk mengedit sebelum keluaran, gunakan `omarchy screenshot --editor=overlay` untuk editor layar penuh atau `omarchy screenshot --editor=window` untuk jendela terpisah.

### Mengemudikan pemilih dari keyboard

Saat pilihan aktif, Anda tidak harus menggunakan mouse sama sekali:

| Tombol | Fungsi |
| --- | -------- |
| `S` | Alihkan mode wilayah bergulir |
| `Super + Arrow keys` | Berpindah di antara jendela dalam mode Jendela |
| `Return` | Tangkap jendela yang disorot |
| `Ctrl + A` | Tangkap monitor fokus penuh |
| `R` | Pulihkan wilayah terakhir yang digambar dalam sesi ini |
| `Esc` | Tutup Omasnap |

Binding ini hanya ada saat Omasnap terbuka, sehingga tidak dapat bertabrakan dengan apa pun dalam konfigurasi Anda sendiri.

## Perekaman layar

`Alt + Print Screen` membuka _Pemicu > Tangkap > Rekam Layar_, yang menanyakan apa yang Anda inginkan pada soundtrack: tanpa audio, audio desktop, desktop plus mikrofon, atau desktop plus mikrofon plus webcam. Yang terakhir hanya muncul jika Anda benar-benar memiliki kamera yang terpasang. Pilih salah satu dan pemilih perekaman Omarchy memungkinkan Anda menyeret wilayah atau mengklik jendela atau monitor.

Perekaman berjalan pada gpu-screen-recorder, yang mengenkode pada GPU pada 60fps dan kembali ke CPU jika harus. Hasilnya adalah MP4 di `~/Videos`, bernama `screenrecording-2026-08-13_14-22-05.mp4`. Atur `OMARCHY_SCREENRECORD_DIR` untuk mengubahnya — tetapi perlu dicatat bahwa tidak seperti direktori tangkapan layar, yang ini harus sudah ada, atau perekaman menolak untuk memulai.

Saat Anda merekam, indikator kecil muncul di bilah. Klik untuk berhenti. Anda juga dapat berhenti dengan `Alt + Print Screen` lagi, atau dengan entri _Hentikan Rekam Layar_ di bawah _Pemicu > Tangkap > Rekam Layar_, yang hanya muncul saat ada sesuatu yang benar-benar direkam.

Menghentikan melakukan sedikit perapian sebelum menyerahkan berkas kepada Anda: bingkai pertama dipangkas, dan jika ada audio dinormalisasi ke -14 LUFS dengan pop tangkapan PipeWire di bagian paling awal dibisukan. Kemudian notifikasi muncul dengan thumbnail dari perekaman. Klik untuk memutar berkas di mpv.

### Overlay webcam

Ketika Anda merekam dengan webcam, kamera muncul sebagai jendela potret terpangkas yang disematkan di sudut kanan bawah apa pun yang Anda rekam. Jika ia duduk di atas sesuatu yang Anda butuhkan, ubah ukurannya secara langsung:

| Hotkey | Fungsi |
| ------ | -------- |
| `Super + Alt + [` | Perkecil overlay webcam |
| `Super + Alt + ]` | Perbesar overlay webcam |

Ada tiga ukuran — kecil, sedang, dan besar — dan hotkey melangkah di antara mereka. Sedang adalah bawaannya. Mereka proporsional terhadap perekaman, sehingga kamera mengambil bagian bingkai yang sama apakah Anda merekam monitor 1080p atau 6K. Dan jika Anda merekam wilayah alih-alih seluruh tampilan, overlay menjangkar ke sudut wilayah itu alih-alih sudut monitor, sehingga ia tetap di dalam tangkapan.

Anda juga dapat memanggilnya langsung dengan `omarchy-capture-webcam-resize small`, atau `reset` untuk kembali ke sedang.

## Teks, kode QR, dan warna

`Super + Ctrl + Print Screen` memilih wilayah dan meng-OCR-nya ke papan klip. Itu dibahas dengan benar dalam [Ekstraksi Teks & Dikte](11-text-extraction-dictation.md).

_Pemicu > Tangkap > Kode QR_ melakukan trik yang sama untuk kode QR. Pilih wilayah dengan kode di dalamnya, dan nilai yang didekodekan pergi ke papan klip. Ia hanya mencari kode QR — konten layar yang padat memiliki kebiasaan ber-positif palsu sebagai kode batang jika tidak. Layak diketahui: nilai yang didekodekan pergi ke papan klip dan tidak ke tempat lain. Ia tidak dicetak, tidak ada dalam notifikasi, dan ditandai sensitif sehingga tidak bertahan dalam [riwayat papan klip](08-unified-clipboard-history.md). Kode QR secara rutin membawa rahasia — URI `otpauth://` di balik kode penyiapan 2FA, misalnya — dan Anda tidak menginginkan itu dalam log. Penempelan tetap berfungsi dengan baik.

`Super + Print Screen` (atau _Pemicu > Tangkap > Warna_) mengubah kursor menjadi pipet. Klik apa pun di layar dan warna mendarat di papan klip. Tekan hotkey lagi untuk keluar tanpa memilih.

## Transkode sebelum Anda membagikan

Rekaman layar 4K atau HEIC mentah dari ponsel Anda sering kali terlalu besar untuk langsung dikirim. `Super + Ctrl + .` (atau _Pemicu > Transkode_) memperbaikinya. Ia menawarkan Anda pemilih berkas fuzzy di atas `~/Pictures` dan `~/Videos`, lalu menanyakan format dan ukuran.

Gambar pergi ke jpg atau png pada tinggi, sedang, atau rendah, yang membatasi lebar pada 3160, 2160, dan 1080 piksel. Video pergi ke mp4 atau gif animasi pada 4k, 1080p, atau 720p. Berkas yang dikonversi ditulis di samping yang asli dengan resolusi dalam namanya — `demo-1080p.mp4` — dan jalur disalin ke papan klip sebagai URI berkas, sehingga Anda dapat menempelnya langsung ke aplikasi yang menerima penurunan berkas.

Ia juga berfungsi dari terminal, jika Anda sudah tahu apa yang Anda inginkan: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Ada juga `omarchy transcode ascii`, yang mengubah gambar menjadi seni ASCII — yang itu sebagian besar untuk [branding](41-branding.md).

## Mengirimnya ke suatu tempat

Setelah Anda memiliki berkas, `Super + Ctrl + S` membuka menu Bagikan dan mengirimnya ke perangkat lain di jaringan Anda melalui LocalSend. Lihat [GUI](22-guis.md) untuk itu.
