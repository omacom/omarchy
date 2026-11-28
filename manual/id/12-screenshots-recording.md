# Tangkapan Layar & Perekaman

Semua yang bisa kamu ambil dari layar bergantung pada tombol Print Screen. Satu tombol saja mengambil gambar, dan tombol pengubahnya mengambil rekaman, warna, atau teks di dalam suatu wilayah. Jika keyboardmu sama sekali tidak punya tombol Print Screen, `Super + Ctrl + Alt + C` mengambil tangkapan layar yang sama, dan `Super + Ctrl + C` membuka seluruh rangkaian itu sebagai menu.

| Tombol pintas | Fungsi |
| ------ | -------- |
| `Print Screen` | Tangkapan layar |
| `Super + Ctrl + Alt + C` | Tangkapan layar |
| `Alt + Print Screen` | Rekam layar (atau hentikan yang sedang berjalan) |
| `Super + Print Screen` | Pemilih warna |
| `Super + Ctrl + Print Screen` | Ekstrak teks dari suatu wilayah |
| `Super + Ctrl + C` | Menu tangkapan |
| `Super + Ctrl + .` | Transkode gambar atau video |

## Tangkapan Layar

Tekan `Print Screen` (atau `Super + Ctrl + Alt + C`) dan Omasnap menangkap monitor yang terfokus sebelum overlay-nya muncul, jadi tidak ada yang bergeser di bawahmu saat kamu membidik. Seret wilayah dengan bentuk bebas, klik jendela untuk menangkapnya, atau klik ruang kosong untuk menangkap seluruh monitor. Tekan `S` sebelum menggambar untuk menangkap wilayah yang bergulir. Berubah pikiran? Tekan tombol yang sama lagi untuk menutup Omasnap.

Setelah kamu memilih suatu area, Omasnap menyimpan tangkapan itu, menyalinnya ke clipboard, dan menampilkan notifikasi dengan thumbnail-nya, seperti yang dilakukan rekaman layar yang tersimpan. Pilih Open untuk melihat tangkapan yang tersimpan di penampil gambarmu, atau Edit untuk menganotasinya.

Editor anotasi bisa menggambar panah, garis, bentuk, sorotan, penanda bernomor, teks, dan redaksi aman; memotong atau menggunting sebagian gambar; melakukan OCR pada teksnya; dan menambahkan latar. Di editor, tekan `Enter` untuk menyalin dan menyimpan PNG yang sudah selesai, `Ctrl + C` untuk menyalinnya tanpa menyimpan, atau `Ctrl + S` untuk menyimpannya tanpa menyalin.

Tangkapan layar yang tersimpan masuk ke `~/Pictures/Screenshots` secara default, dengan nama seperti `screenshot-2026-08-13_14-22-05-firefox.png`. Atur `OMASNAP_SCREENSHOT_DIR` untuk menggunakan direktori lain — lihat [FAQ](46-faq.md) untuk mengetahui tempat menaruh variabel lingkungan sesi. Omasnap membuat direktori itu saat menyimpan tangkapan pertama. Atur `[output] autosave = false` di `~/.config/omasnap/omasnap.conf` untuk menonaktifkan penyimpanan otomatis; tangkapan kemudian hanya disalin, dan ditampilkan dalam pratinjau selama 7 detik yang bisa kamu pertahankan di layar dengan tombol pin-nya atau `Ctrl + P`.

Dari terminal, `omarchy screenshot` membuka overlay yang sama, dan kamu bisa memilih mode awalnya: `omarchy capture screenshot region`, `windows`, `fullscreen`, atau `scroll`. Argumen kedua berupa `copy` atau `save` mengirim tangkapan itu langsung ke tujuan tersebut. Untuk mengedit sebelum dikeluarkan, gunakan `omarchy screenshot --editor=overlay` untuk editor layar penuh atau `omarchy screenshot --editor=window` untuk jendela terpisah.

### Mengendalikan pemilih dari keyboard

Selagi pilihan itu tampil, kamu tidak perlu menggunakan mouse sama sekali:

| Tombol | Fungsi |
| --- | -------- |
| `S` | Alihkan mode wilayah bergulir |
| `Super + Arrow keys` | Berpindah antarjendela dalam mode Window |
| `Return` | Tangkap jendela yang disorot |
| `Ctrl + A` | Tangkap monitor terfokus secara penuh |
| `R` | Pulihkan wilayah terakhir yang digambar dalam sesi ini |
| `Esc` | Tutup Omasnap |

Binding ini hanya ada selagi Omasnap terbuka, jadi binding ini tidak bisa bertabrakan dengan apa pun di konfigurasi milikmu sendiri.

## Perekaman layar

`Alt + Print Screen` membuka _Trigger > Capture > Screenrecord_, yang menanyakan apa yang kamu inginkan pada jalur suaranya: tanpa audio, audio desktop, desktop plus mikrofon, atau desktop plus mikrofon plus webcam. Yang terakhir itu hanya muncul jika kamu memang punya kamera yang tercolok. Pilih salah satu dan pemilih perekaman Omarchy memungkinkanmu menyeret suatu wilayah atau mengklik jendela atau monitor.

Perekaman berjalan di gpu-screen-recorder, yang mengenkode pada GPU pada 60fps dan beralih ke CPU jika harus; pada GPU yang tidak didukungnya, seperti GPU Apple Silicon, Omarchy merekam dengan wf-recorder sebagai gantinya. Hasilnya adalah MP4 di `~/Videos`, bernama `screenrecording-2026-08-13_14-22-05.mp4`. Atur `OMARCHY_SCREENRECORD_DIR` untuk mengubahnya — tapi perhatikan bahwa tidak seperti direktori tangkapan layar, direktori ini harus sudah ada, atau perekaman menolak untuk dimulai.

Selagi kamu merekam, indikator kecil muncul di bar. Klik indikator itu untuk berhenti. Kamu juga bisa berhenti dengan `Alt + Print Screen` lagi, atau dengan entri _Stop Screenrecording_ di bawah _Trigger > Capture > Screenrecord_, yang hanya muncul selagi memang ada sesuatu yang sedang direkam.

Menghentikan melakukan sedikit perapian sebelum menyerahkan file itu kepadamu: frame pertama dipangkas, dan jika ada audio, audio itu dinormalisasi ke -14 LUFS dengan bunyi letup tangkapan PipeWire di paling awal dibisukan. Lalu notifikasi muncul dengan thumbnail dari rekaman itu. Pilih _Open_ untuk memutar file itu di Omaview, atau _Cut_ untuk memangkasnya di Omacut.

### Overlay webcam

Saat kamu merekam dengan webcam, kamera muncul sebagai jendela potret yang disematkan dan dipotong di sudut kanan bawah dari apa pun yang kamu rekam. Jika kamera itu berada di atas sesuatu yang kamu butuhkan, ubah ukurannya dengan cepat:

| Tombol pintas | Fungsi |
| ------ | -------- |
| `Super + Alt + [` | Buat overlay webcam lebih kecil |
| `Super + Alt + ]` | Buat overlay webcam lebih besar |

Ada tiga ukuran — kecil, sedang, dan besar — dan tombol pintasnya melangkah di antaranya. Sedang adalah default-nya. Ukuran-ukuran itu proporsional terhadap rekaman, jadi kamera menempati porsi frame yang sama baik kamu merekam monitor 1080p maupun 6K. Dan jika kamu merekam suatu wilayah bukan seluruh tampilan, overlay itu menambatkan diri ke sudut wilayah tersebut bukan ke sudut monitor, jadi overlay itu tetap berada di dalam tangkapan.

Kamu juga bisa memanggilnya langsung dengan `omarchy-capture-webcam-resize small`, atau `reset` untuk kembali ke sedang.

## Teks, kode QR, dan warna

`Super + Ctrl + Print Screen` memilih suatu wilayah dan melakukan OCR padanya ke clipboard. Itu dibahas dengan benar di [Ekstraksi Teks & Dikte](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ melakukan trik yang sama untuk kode QR. Pilih wilayah yang memuat kode itu, dan nilai yang terdekode masuk ke clipboard. Itu hanya mencari kode QR — konten layar yang padat punya kebiasaan terdeteksi palsu sebagai barcode kalau tidak begitu. Perlu diketahui: nilai yang terdekode masuk ke clipboard dan tidak ke tempat lain. Itu tidak dicetak, tidak ada di notifikasi, dan ditandai sensitif jadi tidak menetap di [riwayat clipboard](08-unified-clipboard-history.md). Kode QR rutin membawa rahasia — URI `otpauth://` di balik kode penyiapan 2FA, misalnya — dan kamu tidak ingin itu ada di log. Menempel tetap bekerja dengan baik.

`Super + Print Screen` (atau _Trigger > Capture > Color_) mengubah kursor menjadi pipet tetes mata. Klik apa pun di layar dan warna itu masuk ke clipboard. Tekan tombol pintas itu lagi untuk mundur tanpa memilih.

## Transkode sebelum kamu membagikan

Rekaman layar 4K atau HEIC mentah dari ponselmu sering terlalu besar untuk langsung dikirim. `Super + Ctrl + .` (atau _Trigger > Transcode_) memperbaiki itu. Itu menawarkanmu pemilih file fuzzy atas `~/Pictures` dan `~/Videos`, lalu menanyakan format dan ukuran.

Gambar menjadi jpg atau png pada tinggi, sedang, atau rendah, yang membatasi lebar pada 3160, 2160, dan 1080 piksel. Video menjadi mp4 atau gif animasi pada 4k, 1080p, atau 720p. File yang dikonversi ditulis di sebelah file aslinya dengan resolusi pada namanya — `demo-1080p.mp4` — dan jalurnya disalin ke clipboard sebagai URI file, jadi kamu bisa menempelnya langsung ke aplikasi yang menerima jatuhan file.

Itu juga bekerja dari terminal, jika kamu sudah tahu apa yang kamu inginkan: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Ada juga `omarchy transcode ascii`, yang mengubah gambar menjadi seni ASCII — yang itu kebanyakan untuk [branding](41-branding.md).

## Mengirimnya ke suatu tempat

Begitu kamu mendapatkan file itu, `Super + Ctrl + S` membuka menu Share dan mengirimnya ke perangkat lain di jaringanmu via LocalSend. Lihat [GUIs](22-guis.md) untuk itu.
