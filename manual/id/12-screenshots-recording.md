# Tangkapan Layar & Perekaman

Semua yang bisa Anda ambil dari layar bergantung pada tombol Print Screen. Satu tombol itu sendiri mengambil gambar, dan pengubahnya mengambil rekaman, warna, atau teks di dalam suatu area. Jika keyboard Anda sama sekali tidak memiliki tombol Print Screen, `Super + Ctrl + Alt + C` mengambil tangkapan layar yang sama, dan `Super + Ctrl + C` membuka seluruh rangkaian tersebut sebagai menu.

| Hotkey | Fungsi |
| ------ | -------- |
| `Print Screen` | Tangkapan layar |
| `Super + Ctrl + Alt + C` | Tangkapan layar |
| `Alt + Print Screen` | Rekam layar (atau hentikan rekaman yang sedang berjalan) |
| `Super + Print Screen` | Pemilih warna |
| `Super + Ctrl + Print Screen` | Ekstrak teks dari suatu area |
| `Super + Ctrl + C` | Menu tangkapan |
| `Super + Ctrl + .` | Transkode gambar atau video |

## Tangkapan Layar

Tekan `Print Screen` (atau `Super + Ctrl + Alt + C`) dan Omasnap menangkap monitor yang terfokus sebelum overlay-nya muncul, jadi tidak ada yang bergeser di bawah Anda saat Anda membidik. Seret area bebas, klik jendela untuk menangkapnya, atau klik ruang terbuka untuk menangkap seluruh monitor. Tekan `S` sebelum menggambar untuk menangkap area yang bergulir. Berubah pikiran? Tekan tombol yang sama lagi untuk menutup Omasnap.

Setelah Anda memilih suatu area, Omasnap menyimpan tangkapan tersebut, menyalinnya ke clipboard, dan menampilkan notifikasi beserta thumbnail-nya, seperti yang dilakukan rekaman layar yang tersimpan. Pilih Open untuk melihat tangkapan yang tersimpan di penampil gambar Anda, atau Edit untuk menganotasinya.

Editor anotasi dapat menggambar panah, garis, bentuk, sorotan, penanda bernomor, teks, dan redaksi aman; memotong atau menggunting sebagian gambar; melakukan OCR pada teksnya; dan menambahkan latar belakang. Di editor, tekan `Enter` untuk menyalin dan menyimpan PNG yang sudah selesai, `Ctrl + C` untuk menyalinnya tanpa menyimpan, atau `Ctrl + S` untuk menyimpannya tanpa menyalin.

Tangkapan layar yang tersimpan masuk ke `~/Pictures/Screenshots` secara default, dengan nama seperti `screenshot-2026-08-13_14-22-05-firefox.png`. Atur `OMASNAP_SCREENSHOT_DIR` untuk menggunakan direktori lain — lihat [FAQ](46-faq.md) untuk mengetahui di mana menempatkan variabel lingkungan sesi. Omasnap membuat direktori tersebut saat menyimpan tangkapan pertama. Atur `[output] autosave = false` di `~/.config/omasnap/omasnap.conf` untuk menonaktifkan penyimpanan otomatis; tangkapan kemudian hanya disalin, dan ditampilkan dalam pratinjau selama 10 detik yang dapat Anda pertahankan di layar dengan tombol pin-nya atau `Ctrl + P`.

Dari terminal, `omarchy screenshot` membuka overlay yang sama, dan Anda dapat memilih mode awalnya: `omarchy capture screenshot region`, `windows`, `fullscreen`, atau `scroll`. Argumen kedua berupa `copy` atau `save` mengirim tangkapan langsung ke tujuan tersebut. Untuk mengedit sebelum keluaran, gunakan `omarchy screenshot --editor=overlay` untuk editor layar penuh atau `omarchy screenshot --editor=window` untuk jendela terpisah.

### Mengendalikan pemilih dari keyboard

Saat pilihan sedang ditampilkan, Anda sama sekali tidak harus menggunakan mouse:

| Key | Fungsi |
| --- | -------- |
| `S` | Alihkan mode area bergulir |
| `Super + Arrow keys` | Berpindah antarjendela dalam mode Window |
| `Return` | Tangkap jendela yang disorot |
| `Ctrl + A` | Tangkap seluruh monitor yang terfokus |
| `R` | Pulihkan area terakhir yang digambar dalam sesi ini |
| `Esc` | Tutup Omasnap |

Ikatan ini hanya ada saat Omasnap terbuka, jadi tidak akan bertabrakan dengan apa pun di konfigurasi Anda sendiri.

## Perekaman layar

`Alt + Print Screen` membuka _Trigger > Capture > Screenrecord_, yang menanyakan apa yang Anda inginkan pada soundtrack-nya: tanpa audio, audio desktop, desktop plus mikrofon, atau desktop plus mikrofon plus webcam. Pilihan terakhir itu hanya muncul jika Anda benar-benar memiliki kamera yang terhubung. Pilih salah satu dan pemilih perekaman Omarchy memungkinkan Anda menyeret suatu area atau mengklik jendela atau monitor.

Perekaman berjalan di gpu-screen-recorder, yang mengenkode pada GPU pada 60fps dan beralih ke CPU jika terpaksa. Hasilnya adalah MP4 di `~/Videos`, bernama `screenrecording-2026-08-13_14-22-05.mp4`. Atur `OMARCHY_SCREENRECORD_DIR` untuk mengubahnya — tetapi perlu dicatat bahwa tidak seperti direktori tangkapan layar, direktori ini harus sudah ada, atau perekaman akan menolak untuk dimulai.

Saat Anda sedang merekam, indikator kecil muncul di bar. Klik indikator tersebut untuk berhenti. Anda juga dapat berhenti dengan `Alt + Print Screen` lagi, atau dengan entri _Stop Screenrecording_ di bawah _Trigger > Capture > Screenrecord_, yang hanya muncul saat sesuatu benar-benar sedang direkam.

Menghentikan melakukan sedikit perapian sebelum menyerahkan file kepada Anda: frame pertama dipangkas, dan jika ada audio, audio tersebut dinormalisasi ke -14 LUFS dengan pop tangkapan PipeWire di awal sekali dibisukan. Kemudian notifikasi muncul dengan thumbnail dari rekaman tersebut. Klik notifikasi itu untuk memutar file di Omaview.

### Overlay webcam

Saat Anda merekam dengan webcam, kamera muncul sebagai jendela potret yang disematkan dan dipotong di sudut kanan bawah dari apa pun yang Anda rekam. Jika kamera itu berada di atas sesuatu yang Anda butuhkan, ubah ukurannya secara langsung:

| Hotkey | Fungsi |
| ------ | -------- |
| `Super + Alt + [` | Buat overlay webcam lebih kecil |
| `Super + Alt + ]` | Buat overlay webcam lebih besar |

Ada tiga ukuran — kecil, sedang, dan besar — dan hotkey bergerak di antaranya. Sedang adalah default-nya. Ukuran-ukuran tersebut proporsional terhadap rekaman, jadi kamera menempati bagian frame yang sama baik Anda merekam monitor 1080p maupun monitor 6K. Dan jika Anda merekam suatu area dan bukan seluruh tampilan, overlay berlabuh ke sudut area tersebut dan bukan sudut monitor, jadi tetap berada di dalam tangkapan.

Anda juga dapat memanggilnya secara langsung dengan `omarchy-capture-webcam-resize small`, atau `reset` untuk kembali ke sedang.

## Teks, kode QR, dan warna

`Super + Ctrl + Print Screen` memilih suatu area dan melakukan OCR padanya ke clipboard. Hal itu dibahas dengan benar di [Ekstraksi Teks & Dikte](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ melakukan trik yang sama untuk kode QR. Pilih area yang berisi kode tersebut, dan nilai yang terdekode masuk ke clipboard. Ini hanya mencari kode QR — konten layar yang padat cenderung terdeteksi secara keliru sebagai barcode jika tidak begitu. Perlu diketahui: nilai yang terdekode masuk ke clipboard dan tidak ke mana pun lagi. Nilai itu tidak dicetak, tidak ada di notifikasi, dan ditandai sensitif sehingga tidak bertahan di [riwayat clipboard](08-unified-clipboard-history.md). Kode QR secara rutin membawa rahasia — URI `otpauth://` di balik kode penyiapan 2FA, misalnya — dan Anda tidak ingin itu ada di log. Menempel tetap berfungsi dengan baik.

`Super + Print Screen` (atau _Trigger > Capture > Color_) mengubah kursor menjadi eyedropper. Klik apa pun di layar dan warna tersebut masuk ke clipboard. Tekan hotkey lagi untuk keluar tanpa memilih.

## Transkode sebelum Anda berbagi

Rekaman layar 4K atau HEIC mentah dari ponsel Anda sering kali terlalu besar untuk langsung dikirim. `Super + Ctrl + .` (atau _Trigger > Transcode_) memperbaikinya. Ini menawarkan pemilih file fuzzy atas `~/Pictures` dan `~/Videos`, lalu menanyakan format dan ukuran.

Gambar menjadi jpg atau png pada tinggi, sedang, atau rendah, yang membatasi lebar pada 3160, 2160, dan 1080 piksel. Video menjadi mp4 atau gif animasi pada 4k, 1080p, atau 720p. File yang dikonversi ditulis di samping file asli dengan resolusi pada namanya — `demo-1080p.mp4` — dan path-nya disalin ke clipboard sebagai URI file, jadi Anda dapat menempelkannya langsung ke aplikasi yang menerima drop file.

Ini juga berfungsi dari terminal, jika Anda sudah tahu apa yang Anda inginkan: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Ada juga `omarchy transcode ascii`, yang mengubah gambar menjadi seni ASCII — yang satu itu sebagian besar untuk [branding](41-branding.md).

## Mengirimnya ke suatu tempat

Setelah Anda mendapatkan file tersebut, `Super + Ctrl + S` membuka menu Share dan mengirimnya ke perangkat lain di jaringan Anda melalui LocalSend. Lihat [GUIs](22-guis.md) untuk hal itu.
