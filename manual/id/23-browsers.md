# Browser

Omarchy dibundel dengan [Google Chrome](https://www.google.com/chrome/) sebagai browser default. Temanya disesuaikan dengan tampilan sistem Anda secara keseluruhan, dan browser inilah yang dibuka dengan `Super + Shift + Return` serta tempat semua [aplikasi web](25-web-apps.md) berjalan. Browser ini langsung membuka jendela browser: tidak ada layar selamat datang atau prompt masuk, statistik penggunaan dan laporan crash tidak dikirim ke Google, dan prompt privasi iklan dimatikan. Anda tetap bisa masuk ke akun Google Anda dari tombol profil kapan pun Anda ingin sinkronisasi.

Jika Chrome bukan selera Anda, Anda tidak terjebak dengannya. Di bawah _Install > Browser_ pada menu Omarchy, Anda akan menemukan [Chromium](https://www.chromium.org/) (build open-source polos asal Chrome dibuat), Edge, Brave, Brave Origin, Firefox, dan [Zen](https://zen-browser.app/). Pilih salah satu dan Omarchy akan menginstalnya, menyiapkan direktori kebijakannya, dan menerapkan tema Anda saat ini ke browser tersebut.

## Menjadikan salah satunya sebagai default

Menginstal browser tidak otomatis menjadikannya default. Setelah browser terpasang di mesin, buka _Setup > Defaults > Browser_ dan pilih browser tersebut — menu hanya menampilkan browser yang benar-benar sudah Anda instal, dan menandai default saat ini dengan tanda centang.

Dari terminal, perintahnya adalah:

```bash
omarchy default browser firefox
```

Jalankan tanpa argumen dan perintah itu akan memberi tahu default saat ini. Ini mengatur handler XDG, jadi bukan hanya hotkey Omarchy yang mengikuti — apa pun yang membuka tautan, dari aplikasi chat hingga perintah terminal, akan membuka browser yang Anda pilih.

## Copy URL dan Download Video

Browser keluarga Chromium (Chromium itu sendiri, Chrome, Edge, dan Brave) dilengkapi dua ekstensi Omarchy yang menjangkau keluar dari browser ke bagian sistem Anda yang lain.

**Copy URL** menempatkan alamat tab saat ini ke clipboard Anda dengan `Alt + Shift + L`. Itu lebih cepat daripada mengklik bilah alamat lalu menyalin, dan karena melalui clipboard sistem, bukan clipboard browser, Anda mendapat notifikasi Omarchy yang mengonfirmasinya dan URL tersebut langsung tersedia di [riwayat clipboard](08-unified-clipboard-history.md) serta setiap aplikasi lain. Ada juga tombol toolbar, jika Anda lebih suka mengklik.

**Download Video** mengambil video yang diputar di halaman yang sedang Anda lihat dengan `Alt + Shift + D`. Ekstensi ini menyerahkan URL ke [yt-dlp](https://github.com/yt-dlp/yt-dlp), jadi ini berfungsi di jauh lebih banyak situs daripada hanya YouTube, dan hasil unduhannya masuk ke `~/Videos`. Kemajuan ditampilkan di on-screen display yang sama yang digunakan volume dan kecerahan, diperbarui di tempatnya alih-alih menumpuk notifikasi. Atur `OMARCHY_YTDLP_DIR` jika Anda ingin file disimpan di tempat lain — lihat [FAQ](46-faq.md) untuk mengetahui tempat menaruh variabel lingkungan.

Kedua ekstensi berbicara dengan Omarchy melalui native messaging host kecil, yang terinstal untuk Anda bersama browser. Itulah bagian yang memungkinkan video dari halaman web berakhir di direktori home Anda dan URL berakhir di pengelola clipboard Anda, hal yang tidak bisa dilakukan ekstensi biasa sendirian.

Ini hanya untuk keluarga Chromium. Firefox dan Zen tidak mendapatkannya.

## Firefox dan Zen

Firefox dan Zen adalah keluarga yang berbeda, jadi perlakuannya pun berbeda: Omarchy menginstal file kebijakan untuk default yang masuk akal dan mengalihkannya ke mode Wayland native, yang Anda inginkan untuk penskalaan fraksional dan pengguliran trackpad yang mulus.

Mereka tidak mendapatkan ekstensi Chromium di atas, dan mereka tidak diberi tema oleh Omarchy, jadi bagian-bagian pengalaman tersebut harus Anda atur sendiri.

## Menghapusnya lagi

Semua browser ini, termasuk Chrome, dapat dihapus lagi melalui _Remove > Browser_. Tautan kemudian akan membuka Chrome atau Chromium jika yang satunya masih terinstal.
