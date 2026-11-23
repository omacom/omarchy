# Browser

Omarchy hadir dengan [Google Chrome](https://www.google.com/chrome/) sebagai browser default. Browser ini bertema agar selaras dengan seluruh sistem Anda, dan inilah yang dibuka oleh `Super + Shift + Return` (atau `Super + Shift + B`), dengan `Super + Shift + Alt + B` untuk jendela privat, serta tempat semua [aplikasi web](25-web-apps.md) berjalan. Browser ini langsung membuka jendela browser: tidak ada layar sambutan atau perintah masuk, statistik penggunaan dan laporan kerusakan tidak dikirim ke Google, dan perintah privasi iklan dimatikan. Anda tetap bisa masuk ke akun Google Anda dari tombol profil kapan pun Anda ingin sinkronisasi.

Kalau Chrome bukan selera Anda, Anda tidak terjebak dengannya. Di bawah _Install > Browser_ pada menu Omarchy, Anda akan menemukan [Chromium](https://www.chromium.org/) (versi open source murni asal Chrome dibuat), Edge, Brave, Brave Origin, Firefox, dan [Zen](https://zen-browser.app/) (Edge hanya pada mesin x86). Pilih satu, dan Omarchy akan menginstalnya, menyiapkan direktori kebijakannya, serta menerapkan tema Anda saat ini ke browser itu.

## Menjadikan salah satunya sebagai default

Menginstal browser tidak otomatis mengangkatnya menjadi default. Untuk beralih, buka _Setup > Defaults > Browser_ dan pilih salah satu. Default saat ini ditandai dengan tanda centang, dan memilih browser yang belum Anda miliki akan menginstalnya terlebih dahulu.

Dari terminal, perintahnya adalah:

```bash
omarchy default browser firefox
```

Jalankan perintah itu tanpa argumen dan perintah itu akan memberi tahu Anda default saat ini. Perintah ini mengatur handler XDG, jadi bukan hanya hotkey Omarchy yang menyesuaikannya — apa pun yang membuka tautan, dari aplikasi chat hingga perintah terminal, akan membuka browser yang Anda pilih.

## Copy URL dan Download Video

Browser keluarga Chromium (Chromium sendiri, Chrome, Edge, Brave, dan Brave Origin) dilengkapi tiga ekstensi Omarchy: dua yang menjangkau keluar dari browser dan masuk ke seluruh sistem Anda, dan satu yang merapikan WhatsApp.

**Copy URL** menempatkan alamat tab saat ini ke clipboard Anda dengan `Alt + Shift + L`. Cara ini lebih cepat daripada mengeklik kolom alamat dan menyalinnya, dan karena cara ini melalui clipboard sistem, bukan clipboard browser, Anda mendapat notifikasi Omarchy yang mengonfirmasinya dan URL itu langsung tersedia di [riwayat clipboard](08-unified-clipboard-history.md) dan setiap aplikasi lain. Ada tombol toolbar juga, kalau Anda lebih suka mengeklik.

**Download Video** mengambil video yang sedang diputar di halaman yang Anda lihat dengan `Alt + Shift + D`. Ekstensi ini menyerahkan URL itu ke [yt-dlp](https://github.com/yt-dlp/yt-dlp), jadi ekstrensi ini berfungsi pada jauh lebih banyak situs daripada hanya YouTube, dan hasil unduhannya masuk ke `~/Videos`. Kemajuannya tampil di tampilan pada layar yang sama dengan yang digunakan volume dan kecerahan, diperbarui di tempatnya alih-alih menumpuk notifikasi. Atur `OMARCHY_YTDLP_DIR` jika Anda lebih suka file-file itu disimpan di tempat lain — lihat [FAQ](46-faq.md) untuk mengetahui tempat menaruh variabel lingkungan.

Kedua ekstensi itu berkomunikasi dengan Omarchy melalui host native messaging kecil, yang akan diinstal untuk Anda bersama browsernya. Itulah bagian yang memungkinkan video di halaman web berakhir di direktori home Anda dan sebuah URL berakhir di pengelola clipboard Anda, hal yang tidak bisa dilakukan ekstensi biasa sendirian.

**WhatsApp Slim** membuat WhatsApp Web mengikuti tema sistem Anda dan menciutkan daftar chat-nya saat jendelanya sempit.

Ekstensi-ekstensi ini hanya untuk keluarga Chromium. Firefox dan Zen tidak mendapatkannya.

## Firefox dan Zen

Firefox dan Zen berasal dari keluarga yang berbeda, jadi keduanya mendapatkan perlakuan yang berbeda: Omarchy menginstal berkas kebijakan untuk default yang masuk akal dan mengalihkannya ke mode Wayland native, yang Anda inginkan untuk penskalaan fraksional dan pengguliran trackpad yang mulus.

Keduanya tidak mendapatkan ekstensi Chromium di atas, dan keduanya tidak diberi tema oleh Omarchy, jadi bagian-bagian pengalaman itu terserah Anda untuk mengaturnya.

## Menghapusnya lagi

Browser mana pun dari daftar ini, termasuk Chrome, bisa dihapus lagi di bawah _Remove > Browser_. Tautan kemudian akan membuka Chrome atau Chromium jika yang satunya masih terinstal.
