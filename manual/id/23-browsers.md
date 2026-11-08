# Browser

Omarchy dilengkapi dengan [Chromium](https://www.chromium.org/) sebagai browser bawaan. Ini adalah build open-source biasa, bertema agar cocok dengan sisa sistemmu, dan itulah yang dibuka `Super + Shift + Return` dan tempat setiap [aplikasi web](25-web-apps.md) berjalan.

Jika Chromium bukan seleramu, kamu tidak terjebak dengannya. Di bawah _Pasang > Browser_ di menu Omarchy kamu akan menemukan Chrome, Edge, Brave, Brave Origin, Firefox, dan [Zen](https://zen-browser.app/). Pilih satu dan Omarchy memasangnya, menyiapkan direktori kebijakannya, dan menerapkan tema saat ini kepadanya.

## Menjadikan satu sebagai bawaan

Memasang browser tidak mempromosikannya. Setelah itu ada di mesin, pergi ke _Pengaturan > Defaults > Browser_ dan pilih itu — menu hanya mencantumkan browser yang benar-benar kamu pasang, dan menandai bawaan saat ini dengan centang.

Dari terminal itu adalah:

```bash
omarchy default browser firefox
```

Jalankan tanpa argumen dan itu memberitahumu bawaan saat ini. Ini mengatur handler XDG, jadi bukan hanya hotkey Omarchy yang mengikuti — apa pun yang membuka tautan, dari aplikasi obrolan hingga perintah terminal, pergi ke browser yang kamu pilih.

## Copy URL dan Download Video

Browser keluarga Chromium (Chromium itu sendiri, Chrome, Edge, dan Brave) dilengkapi dengan dua ekstensi Omarchy yang menjangkau keluar dari browser dan masuk ke sisa sistemmu.

**Copy URL** menempatkan alamat tab saat ini di papan klipmu dengan `Alt + Shift + L`. Itu lebih cepat daripada mengklik ke bilah alamat dan menyalin, dan karena melalui papan klip sistem daripada browser, kamu mendapatkan notifikasi Omarchy yang mengonfirmasinya dan URL segera tersedia di [riwayat papan klip](08-unified-clipboard-history.md) dan setiap aplikasi lain. Ada juga tombol toolbar, jika kamu lebih suka mengklik.

**Download Video** mengambil video yang diputar di halaman yang kamu lihat dengan `Alt + Shift + D`. Ini menyerahkan URL ke [yt-dlp](https://github.com/yt-dlp/yt-dlp), jadi bekerja di jauh lebih banyak daripada YouTube, dan unduhan mendarat di `~/Videos`. Kemajuan muncul di tampilan di layar yang sama yang digunakan volume dan kecerahan, diperbarui di tempat daripada menumpuk notifikasi. Atur `OMARCHY_YTDLP_DIR` jika kamu lebih suka berkas pergi ke tempat lain — lihat [FAQ](46-faq.md) untuk tempat menaruh variabel lingkungan.

Kedua ekstensi berbicara ke Omarchy melalui host native messaging kecil, yang dipasang untukmu bersama browser. Itulah bagian yang memungkinkan video halaman web berakhir di direktori rumahmu dan URL berakhir di manajer papan klipmu, yang tidak dapat dilakukan ekstensi biasa sendiri.

Ini hanya untuk keluarga Chromium. Firefox dan Zen tidak mendapatkannya.

## Firefox dan Zen

Firefox dan Zen adalah keluarga yang berbeda, jadi mereka mendapat perlakuan berbeda: Omarchy memasang berkas kebijakan untuk bawaan yang masuk akal dan mengalihkannya ke mode Wayland asli, yang kamu inginkan untuk penskalaan pecahan dan pengguliran trackpad yang halus.

Mereka tidak mendapatkan ekstensi Chromium di atas, dan mereka tidak bertema oleh Omarchy, jadi bagian pengalaman itu adalah milikmu untuk disiapkan.

## Menghapus satu lagi

Apa pun yang kamu pasang di sini dapat dilepas kembali di bawah _Hapus > Browser_. Chromium tidak ada dalam daftar itu — itu bagian dari sistem dasar.
