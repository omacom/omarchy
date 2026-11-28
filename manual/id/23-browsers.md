# Browser

Omarchy dikirimkan dengan [Google Chrome](https://www.google.com/chrome/) sebagai browser default. Temanya diselaraskan dengan bagian lain dari sistem Anda, dan browser inilah yang dibuka oleh `Super + Shift + Return` (atau `Super + Shift + B`), dengan `Super + Shift + Alt + B` untuk jendela privat, serta tempat setiap [aplikasi web](25-web-apps.md) berjalan di dalamnya. Browser ini langsung membuka jendela browser: tidak ada layar sambutan atau perintah masuk, statistik penggunaan dan laporan kerusakan tidak dikirim ke Google, dan perintah privasi iklan dimatikan. Anda tetap bisa masuk ke akun Google Anda dari tombol profil kapan pun Anda ingin sinkronisasi.

Jika Chrome bukan selera Anda, Anda tidak terikat padanya. Di bawah _Install > Browser_ pada menu Omarchy Anda akan menemukan [Chromium](https://www.chromium.org/) (build open-source polos asal Chrome dibuat), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/), dan [Ladybird](https://ladybird.org/) (Edge hanya pada mesin x86). Pilih salah satu dan Omarchy akan menginstalnya, menyiapkan direktori kebijakannya, dan menerapkan tema Anda saat ini padanya.

## Menjadikan salah satunya sebagai default

Menginstal browser tidak otomatis menjadikannya default. Untuk beralih, buka _Setup > Defaults > Browser_ dan pilih salah satu. Default saat ini ditandai dengan tanda centang, dan memilih browser yang belum Anda miliki akan menginstalnya terlebih dahulu.

Dari terminal, perintahnya:

```bash
omarchy default browser firefox
```

Jalankan tanpa argumen dan perintah itu akan memberi tahu Anda default saat ini. Ini mengatur handler XDG, jadi bukan hanya hotkey Omarchy yang mengikuti — apa pun yang membuka tautan, dari aplikasi chat hingga perintah terminal, akan menuju ke browser yang Anda pilih.

## Copy URL dan Download Video

Browser keluarga Chromium (Chromium itu sendiri, Chrome, Edge, Brave, dan Brave Origin) dilengkapi dengan tiga ekstensi Omarchy: dua yang menjangkau keluar dari browser ke bagian lain sistem Anda, dan satu yang merapikan WhatsApp.

**Copy URL** menempatkan alamat tab saat ini ke clipboard Anda dengan `Alt + Shift + L`. Itu lebih cepat daripada mengklik kolom alamat dan menyalin, dan karena melalui clipboard sistem bukan clipboard browser, Anda mendapat notifikasi Omarchy yang mengonfirmasinya dan URL tersebut langsung tersedia di [riwayat clipboard](08-unified-clipboard-history.md) dan setiap aplikasi lainnya. Ada juga tombol toolbar, jika Anda lebih suka mengklik.

**Download Video** mengambil video yang sedang diputar pada halaman yang Anda lihat dengan `Alt + Shift + D`. Ia menyerahkan URL tersebut ke [yt-dlp](https://github.com/yt-dlp/yt-dlp), jadi ini bekerja pada jauh lebih banyak situs daripada YouTube, dan unduhan akan masuk ke `~/Videos`. Kemajuan ditampilkan pada on-screen display yang sama yang digunakan volume dan kecerahan, memperbarui di tempatnya alih-alih menumpuk notifikasi. Atur `OMARCHY_YTDLP_DIR` jika Anda lebih suka berkas masuk ke tempat lain — lihat [FAQ](46-faq.md) untuk tempat meletakkan variabel lingkungan.

Kedua ekstensi berkomunikasi dengan Omarchy melalui native messaging host kecil, yang diinstal untuk Anda bersama dengan browser. Itulah bagian yang memungkinkan video dari halaman web masuk ke direktori home Anda dan URL masuk ke manajer clipboard Anda, yang tidak dapat dilakukan ekstensi biasa sendiri.

**WhatsApp Slim** membuat WhatsApp Web mengikuti tema sistem Anda dan mengecilkan daftar chat-nya ketika jendela sempit.

Ini hanya untuk keluarga Chromium. Firefox dan Zen tidak mendapatkannya.

## Firefox dan Zen

Firefox dan Zen adalah keluarga yang berbeda, jadi perlakuannya berbeda: Omarchy menginstal file policies untuk default yang masuk akal dan mengalihkannya ke mode Wayland native, yang Anda inginkan untuk fractional scaling dan pengguliran trackpad yang mulus.

Mereka tidak mendapatkan ekstensi Chromium di atas, dan tidak diberi tema oleh Omarchy, jadi bagian-bagian pengalaman tersebut terserah Anda untuk mengaturnya.

## Ladybird

Ladybird adalah browser yang ditulis dari awal, dengan engine-nya sendiri bukan milik Chromium atau Firefox. Masih dalam tahap alpha, jadi bersiaplah menghadapi situs yang belum berfungsi, dan Omarchy menginstalnya apa adanya: tanpa ekstensi, tanpa tema, tanpa policies. Browser ini juga tidak memiliki jendela privat, jadi `Super + Shift + Alt + B` membukanya dengan profil sementara yang dihapus ketika Anda menutupnya. [Aplikasi web](25-web-apps.md) tetap berjalan di Chrome atau Chromium.

## Menghapus salah satunya lagi

Browser mana pun ini, termasuk Chrome, dapat dihapus kembali di bawah _Remove > Browser_. Tautan kemudian akan menuju ke Chrome atau Chromium jika yang lainnya masih terinstal.
