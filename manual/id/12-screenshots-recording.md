# Tangkapan Layar & Perekaman

Semua yang bisa kamu ambil dari layar bergantung pada tombol Print Screen. Satu tombol itu sendiri mengambil gambar, dan tombol pengubahnya mengambil rekaman, warna, atau teks di dalam suatu wilayah. Jika keyboard-mu sama sekali tidak memiliki tombol Print Screen, `Super + Ctrl + Alt + C` mengambil tangkapan layar yang sama, dan `Super + Ctrl + C` membuka seluruh rangkaian tersebut sebagai menu.

| Tombol Pintas | Fungsi |
| ------ | -------- |
| `Print Screen` | Tangkapan layar |
| `Super + Ctrl + Alt + C` | Tangkapan layar |
| `Alt + Print Screen` | Rekam layar (atau hentikan yang sedang berjalan) |
| `Super + Print Screen` | Pemilih warna |
| `Super + Ctrl + Print Screen` | Ekstrak teks dari suatu wilayah |
| `Super + Ctrl + C` | Menu tangkapan |
| `Super + Ctrl + .` | Transkode gambar atau video |

## Tangkapan Layar

Tekan `Print Screen` (atau `Super + Ctrl + Alt + C`) dan Omasnap menangkap monitor yang terfokus sebelum overlay-nya muncul, jadi tidak ada yang bergeser di bawahmu saat kamu membidik. Seret wilayah bebas, klik jendela untuk menangkapnya, atau klik ruang terbuka untuk menangkap seluruh monitor. Tekan `S` sebelum menggambar untuk menangkap wilayah yang bergulir. Berubah pikiran? Tekan tombol yang sama lagi untuk menutup Omasnap.

Setelah kamu memilih suatu area, Omasnap menyimpan tangkapan tersebut, menyalinnya ke clipboard, dan menampilkan notifikasi dengan thumbnail-nya, seperti yang dilakukan rekaman layar yang tersimpan. Pilih Open untuk melihat tangkapan yang tersimpan di penampil gambarmu, atau Edit untuk menganotasinya.

Editor anotasi dapat menggambar panah, garis, bentuk, sorotan, penanda bernomor, teks, dan redaksi aman; memotong atau menghilangkan sebagian gambar; melakukan OCR pada teksnya; dan menambahkan latar belakang. Di editor, tekan `Enter` untuk menyalin dan menyimpan PNG yang sudah selesai, `Ctrl + C` untuk menyalinnya tanpa menyimpan, atau `Ctrl + S` untuk menyimpannya tanpa menyalin.

Secara default, tangkapan layar yang tersimpan masuk ke `~/Pictures/Screenshots`, dengan nama seperti `screenshot-2026-08-13_14-22-05-firefox.png`. Atur `OMASNAP_SCREENSHOT_DIR` untuk menggunakan direktori lain — lihat [FAQ](46-faq.md) untuk mengetahui tempat menaruh variabel lingkungan sesi. Omasnap membuat direktori tersebut saat menyimpan tangkapan pertama. Atur `[output] autosave = false` di `~/.config/omasnap/omasnap.conf` untuk menonaktifkan penyimpanan otomatis; tangkapan kemudian hanya disalin, dan ditampilkan dalam pratinjau selama 10 detik yang dapat kamu pertahankan di layar dengan tombol pin-nya atau `Ctrl + P`.

Dari terminal, `omarchy screenshot` membuka overlay yang sama, dan kamu dapat memilih mode awalnya: `omarchy capture screenshot region`, `windows`, `fullscreen`, atau `scroll`. Argumen kedua berupa `copy` atau `save` mengirim tangkapan langsung ke tujuan tersebut. Untuk mengedit sebelum menghasilkan keluaran, gunakan `omarchy screenshot --editor=overlay` untuk editor layar penuh atau `omarchy screenshot --editor=window` untuk jendela terpisah.

### Mengendalikan pemilih dari keyboard

Selagi pilihan tersebut tampil, kamu sama sekali tidak harus menggunakan mouse:

| Tombol | Fungsi |
| --- | -------- |
| `S` | Aktif/nonaktifkan mode wilayah bergulir |
| `Super + Arrow keys` | Berpindah antarjendela dalam mode Window |
| `Return` | Tangkap jendela yang disorot |
| `Ctrl + A` | Tangkap seluruh monitor yang terfokus |
| `R` | Pulihkan wilayah terakhir yang digambar dalam sesi ini |
| `Esc` | Tutup Omasnap |

Pengikatan ini hanya ada selagi Omasnap terbuka, jadi pengikatan tersebut tidak dapat bertabrakan dengan apa pun di config-mu sendiri.

## Perekaman layar

`Alt + Print Screen` membuka _Trigger > Capture > Screenrecord_, yang menanyakan apa yang kamu inginkan pada jalur suaranya: tanpa audio, audio desktop, desktop plus mikrofon, atau desktop plus mikrofon plus webcam. Pilihan terakhir itu hanya muncul jika kamu benar-benar memiliki kamera yang terhubung. Pilih salah satu dan pemilih perekaman Omarchy memungkinkanmu menyeret suatu wilayah atau mengklik jendela atau monitor.

Perekaman berjalan pada gpu-screen-recorder, yang melakukan encoding pada GPU pada 60fps dan beralih kembali ke CPU jika terpaksa. Hasilnya adalah MP4 di `~/Videos`, bernama `screenrecording-2026-08-13_14-22-05.mp4`. Atur `OMARCHY_SCREENRECORD_DIR` untuk mengubahnya — tetapi perhatikan bahwa tidak seperti direktori tangkapan layar, direktori ini harus sudah ada, atau perekaman menolak untuk dimulai.

Selagi kamu merekam, indikator kecil muncul di bar. Klik indikator tersebut untuk berhenti. Kamu juga dapat berhenti dengan `Alt + Print Screen` lagi, atau dengan entri _Stop Screenrecording_ di bawah _Trigger > Capture > Screenrecord_, yang hanya muncul selagi ada sesuatu yang benar-benar sedang direkam.

Berhenti melakukan sedikit perapihan sebelum menyerahkan file tersebut kepadamu: frame pertama dipangkas, dan jika ada audio, audio tersebut dinormalisasi ke -14 LUFS dengan letupan tangkapan PipeWire di paling awal dibisukan. Kemudian notifikasi muncul dengan thumbnail dari rekaman tersebut. Klik notifikasi tersebut untuk memutar file di mpv.

### Overlay webcam

Saat kamu merekam dengan webcam, kamera muncul sebagai jendela potret yang disematkan dan dipotong di sudut kanan bawah dari apa pun yang kamu rekam. Jika kamera tersebut berada di atas sesuatu yang kamu butuhkan, ubah ukurannya secara langsung:

| Tombol Pintas | Fungsi |
| ------ | -------- |
| `Super + Alt + [` | Buat overlay webcam lebih kecil |
| `Super + Alt + ]` | Buat overlay webcam lebih besar |

Ada tiga ukuran — kecil, sedang, dan besar — dan tombol pintas melangkah di antaranya. Sedang adalah default-nya. Ukuran tersebut proporsional terhadap perekaman, jadi kamera mengambil bagian frame yang sama baik kamu merekam monitor 1080p maupun monitor 6K. Dan jika kamu merekam suatu wilayah alih-alih seluruh layar, overlay tersebut berlabuh ke sudut wilayah tersebut alih-alih sudut monitor, jadi overlay tetap berada di dalam tangkapan.

Kamu juga dapat memanggilnya langsung dengan `omarchy-capture-webcam-resize small`, atau `reset` untuk kembali ke sedang.

## Teks, kode QR, dan warna

`Super + Ctrl + Print Screen` memilih suatu wilayah dan melakukan OCR padanya ke clipboard. Hal itu dibahas dengan benar di [Ekstraksi Teks & Dikte](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ melakukan trik yang sama untuk kode QR. Pilih wilayah yang memuat kode tersebut, dan nilai yang terdekode masuk ke clipboard. Ini hanya mencari kode QR — konten layar yang padat cenderung terdeteksi secara keliru sebagai barcode jika tidak begitu. Perlu diketahui: nilai yang terdekode masuk ke clipboard dan tidak ke tempat lain. Nilai tersebut tidak dicetak, tidak ada di notifikasi, dan ditandai sensitif agar tidak bertahan di [riwayat clipboard](08-unified-clipboard-history.md). Kode QR secara rutin membawa rahasia — URI `otpauth://` di balik kode penyiapan 2FA, misalnya — dan kamu tidak menginginkan hal itu di log. Menempel tetap berfungsi dengan baik.

`Super + Print Screen` (atau _Trigger > Capture > Color_) mengubah kursor menjadi pipet. Klik apa pun di layar dan warna tersebut masuk ke clipboard. Tekan tombol pintas lagi untuk keluar tanpa memilih.

## Transkode sebelum kamu membagikannya

Rekaman layar 4K atau HEIC mentah dari ponselmu sering kali terlalu besar untuk langsung dikirim. `Super + Ctrl + .` (atau _Trigger > Transcode_) memperbaiki hal itu. Ini menawarkan pemilih file fuzzy atas `~/Pictures` dan `~/Videos`, kemudian menanyakan format dan ukuran.

Gambar menjadi jpg atau png pada tinggi, sedang, atau rendah, yang membatasi lebar pada 3160, 2160, dan 1080 piksel. Video menjadi mp4 atau gif animasi pada 4k, 1080p, atau 720p. File yang dikonversi ditulis di samping file aslinya dengan resolusi pada namanya — `demo-1080p.mp4` — dan jalurnya disalin ke clipboard sebagai URI file, jadi kamu dapat menempelkannya langsung ke aplikasi yang menerima file yang dijatuhkan.

Ini juga berfungsi dari terminal, jika kamu sudah tahu apa yang kamu inginkan: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Ada juga `omarchy transcode ascii`, yang mengubah gambar menjadi seni ASCII — yang satu itu sebagian besar untuk [branding](41-branding.md).

## Mengirimnya ke suatu tempat

Setelah kamu mendapatkan file tersebut, `Super + Ctrl + S` membuka menu Share dan mengirimnya ke perangkat lain di jaringanmu via LocalSend. Lihat [GUIs](22-guis.md) untuk hal itu.
