# Tangkapan Layar & Perekaman

Semua yang bisa kamu ambil dari layar bergantung pada tombol Print Screen. Tombol itu sendiri mengambil gambar, dan tombol pengubahnya mengambil rekaman, warna, atau teks di dalam suatu wilayah. Jika keyboard kamu sama sekali tidak punya tombol Print Screen, `Super + Ctrl + Alt + C` mengambil tangkapan layar yang sama, dan `Super + Ctrl + C` membuka seluruh rangkaian itu sebagai menu.

| Tombol pintas | Fungsi |
| ------ | -------- |
| `Print Screen` | Tangkapan layar |
| `Super + Ctrl + Alt + C` | Tangkapan layar |
| `Alt + Print Screen` | Rekam layar (atau hentikan yang sedang berjalan) |
| `Super + Print Screen` | Pemilih warna |
| `Super + Ctrl + Print Screen` | Ekstrak teks dari suatu wilayah |
| `Super + Ctrl + C` | Menu tangkap |
| `Super + Ctrl + .` | Transkode gambar atau video |

## Tangkapan layar

Tekan `Print Screen` (atau `Super + Ctrl + Alt + C`) dan Omasnap menangkap monitor yang terfokus sebelum overlay-nya muncul, jadi tidak ada yang bergeser di bawah kamu saat kamu membidik. Seret wilayah bebas, klik jendela untuk menangkapnya, atau klik ruang kosong untuk menangkap seluruh monitor. Tekan `S` sebelum menggambar untuk menangkap wilayah yang bergulir. Berubah pikiran? Tekan tombol yang sama lagi untuk menutup Omasnap.

Setelah kamu memilih suatu area, Omasnap menyimpan tangkapan itu, menyalinnya ke clipboard, dan menampilkan pratinjau selama 10 detik. Gunakan tombol pin pada pratinjau atau `Ctrl + P` untuk tetap menampilkannya di layar, atau pilih Edit untuk menganotasinya.

Editor anotasi dapat menggambar panah, garis, bentuk, sorotan, penanda bernomor, teks, dan redaksi aman; memotong atau memotong keluar sebagian gambar; melakukan OCR pada teksnya; dan menambahkan latar belakang. Di editor, tekan `Enter` untuk menyalin dan menyimpan PNG yang sudah selesai, `Ctrl + C` untuk menyalinnya tanpa menyimpan, atau `Ctrl + S` untuk menyimpannya tanpa menyalin.

Tangkapan layar yang disimpan masuk ke `~/Pictures/Screenshots` secara default, dengan nama seperti `screenshot-2026-08-13_14-22-05-firefox.png`. Atur `OMASNAP_SCREENSHOT_DIR` untuk menggunakan direktori lain — lihat [FAQ](46-faq.md) untuk mengetahui tempat menaruh variabel lingkungan sesi. Omasnap membuat direktori itu saat menyimpan tangkapan pertama. Atur `[output] autosave = false` di `~/.config/omasnap/omasnap.conf` untuk menonaktifkan penyimpanan otomatis.

Dari terminal, `omarchy screenshot` membuka overlay yang sama, dan kamu dapat memilih mode awalnya: `omarchy capture screenshot region`, `windows`, `fullscreen`, atau `scroll`. Argumen kedua `copy` atau `save` melewati pratinjau dan mengirim tangkapan langsung ke tujuan itu. Untuk mengedit sebelum keluaran, gunakan `omarchy screenshot --editor=overlay` untuk editor layar penuh atau `omarchy screenshot --editor=window` untuk jendela terpisah.

### Mengendalikan pemilih dari keyboard

Saat pilihan tampil, kamu sama sekali tidak harus menggunakan mouse:

| Tombol | Fungsi |
| --- | -------- |
| `S` | Alihkan mode wilayah bergulir |
| `Super + Arrow keys` | Berpindah antarjendela dalam mode Window |
| `Return` | Tangkap jendela yang disorot |
| `Ctrl + A` | Tangkap monitor terfokus secara penuh |
| `R` | Pulihkan wilayah terakhir yang digambar dalam sesi ini |
| `Esc` | Tutup Omasnap |

Pengikatan ini hanya ada saat Omasnap terbuka, jadi tidak bisa bertabrakan dengan apa pun di konfigurasi kamu sendiri.

## Perekaman layar

`Alt + Print Screen` membuka _Trigger > Capture > Screenrecord_, yang menanyakan apa yang kamu inginkan pada soundtrack: tanpa audio, audio desktop, desktop ditambah mikrofon, atau desktop ditambah mikrofon ditambah webcam. Yang terakhir itu hanya muncul jika kamu benar-benar punya kamera yang terhubung. Pilih salah satu dan pemilih perekaman Omarchy memungkinkan kamu menyeret suatu wilayah atau mengklik jendela atau monitor.

Perekaman berjalan pada gpu-screen-recorder, yang mengenkode pada GPU pada 60fps dan beralih ke CPU jika terpaksa. Hasilnya adalah MP4 di `~/Videos`, bernama `screenrecording-2026-08-13_14-22-05.mp4`. Atur `OMARCHY_SCREENRECORD_DIR` untuk mengubahnya — tetapi perlu dicatat bahwa tidak seperti direktori tangkapan layar, direktori ini harus sudah ada, atau perekaman menolak untuk mulai.

Saat kamu merekam, indikator kecil muncul di bar. Klik untuk berhenti. Kamu juga dapat berhenti dengan `Alt + Print Screen` lagi, atau dengan entri _Stop Screenrecording_ di bawah _Trigger > Capture > Screenrecord_, yang hanya muncul saat sesuatu benar-benar sedang direkam.

Berhenti melakukan sedikit perapian sebelum memberikan file itu kepadamu: frame pertama dipangkas, dan jika ada audio, audio itu dinormalisasi ke -14 LUFS dengan letupan tangkapan PipeWire di paling awal dibisukan. Lalu notifikasi muncul dengan thumbnail dari rekaman itu. Klik untuk memutar file itu di mpv.

### Overlay webcam

Saat kamu merekam dengan webcam, kamera muncul sebagai jendela potret yang disematkan dan dipotong di sudut kanan bawah dari apa pun yang kamu rekam. Jika posisinya menutupi sesuatu yang kamu butuhkan, ubah ukurannya secara langsung:

| Tombol pintas | Fungsi |
| ------ | -------- |
| `Super + Alt + [` | Buat overlay webcam lebih kecil |
| `Super + Alt + ]` | Buat overlay webcam lebih besar |

Ada tiga ukuran — kecil, sedang, dan besar — dan tombol pintas melangkah di antaranya. Sedang adalah default-nya. Ukurannya proporsional terhadap rekaman, jadi kamera menempati porsi frame yang sama baik kamu merekam monitor 1080p maupun monitor 6K. Dan jika kamu merekam suatu wilayah bukan seluruh tampilan, overlay berlabuh ke sudut wilayah itu bukan sudut monitor, jadi tetap berada di dalam tangkapan.

Kamu juga dapat memanggilnya langsung dengan `omarchy-capture-webcam-resize small`, atau `reset` untuk kembali ke sedang.

## Teks, kode QR, dan warna

`Super + Ctrl + Print Screen` memilih suatu wilayah dan melakukan OCR padanya ke clipboard. Itu dibahas dengan benar di [Ekstraksi Teks & Diktasi](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ melakukan trik yang sama untuk kode QR. Pilih wilayah yang berisi kode itu, dan nilai yang didekode masuk ke clipboard. Ini hanya mencari kode QR — konten layar yang padat cenderung terdeteksi palsu sebagai barcode jika tidak begitu. Perlu diketahui: nilai yang didekode masuk ke clipboard dan tidak ke tempat lain. Nilai itu tidak dicetak, tidak ada di notifikasi, dan ditandai sensitif agar tidak bertahan di [riwayat clipboard](08-unified-clipboard-history.md). Kode QR secara rutin membawa rahasia — URI `otpauth://` di balik kode penyiapan 2FA, misalnya — dan kamu tidak ingin itu ada di log. Menempel tetap berfungsi dengan baik.

`Super + Print Screen` (atau _Trigger > Capture > Color_) mengubah kursor menjadi pipet tetes mata. Klik apa saja di layar dan warna itu masuk ke clipboard. Tekan tombol pintas lagi untuk keluar tanpa memilih.

## Transkode sebelum kamu membagikan

Rekaman layar 4K atau HEIC mentah dari ponsel kamu sering terlalu besar untuk langsung dikirim. `Super + Ctrl + .` (atau _Trigger > Transcode_) memperbaiki itu. Ini menawarkan pemilih file fuzzy atas `~/Pictures` dan `~/Videos`, lalu menanyakan format dan ukuran.

Gambar diubah ke jpg atau png pada tinggi, sedang, atau rendah, yang membatasi lebar pada 3160, 2160, dan 1080 piksel. Video diubah ke mp4 atau gif animasi pada 4k, 1080p, atau 720p. File yang dikonversi ditulis di samping aslinya dengan resolusi pada namanya — `demo-1080p.mp4` — dan path-nya disalin ke clipboard sebagai URI file, jadi kamu dapat menempelnya langsung ke aplikasi yang menerima jatuhan file.

Ini juga berfungsi dari terminal, jika kamu sudah tahu apa yang kamu inginkan: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Ada juga `omarchy transcode ascii`, yang mengubah gambar menjadi seni ASCII — yang itu kebanyakan untuk [branding](41-branding.md).

## Mengirimnya ke suatu tempat

Setelah kamu mendapatkan file itu, `Super + Ctrl + S` membuka menu Share dan mengirimnya ke perangkat lain di jaringan kamu melalui LocalSend. Lihat [GUIs](22-guis.md) untuk itu.
