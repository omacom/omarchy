# Pelayar

Omarchy dilengkapi dengan [Chromium](https://www.chromium.org/) sebagai pelayar lalai. Ia ialah binaan sumber terbuka biasa, dittemakan untuk sepadan dengan seluruh sistem anda, dan ia adalah apa yang dibuka oleh `Super + Shift + Return` dan tempat setiap [aplikasi web](25-web-apps.md) berjalan di dalamnya.

Jika Chromium bukan cita rasa anda, anda tidak terperangkap dengannya. Di bawah _Pasang > Pelayar_ dalam menu Omarchy anda akan jumpa Chrome, Edge, Brave, Brave Origin, Firefox, dan [Zen](https://zen-browser.app/). Pilih satu dan Omarchy memasangnya, menyediakan direktori polisinya, dan menggunakan tema semasa anda ke atasnya.

## Menjadikan satu sebagai lalai

Memasang pelayar tidak mengangkatnya. Setelah ia berada pada mesin, pergi ke _Persediaan > Lalai > Pelayar_ dan pilihnya — menu hanya menyenaraikan pelayar yang sebenarnya anda telah pasang, dan menandakan lalai semasa dengan tanda semak.

Daripada terminal, ia adalah:

```bash
omarchy default browser firefox
```

Jalankannya tanpa argumen dan ia memberitahu anda lalai semasa. Ini menetapkan pengendali XDG, jadi bukan sahaja kekunci pintas Omarchy yang mengikut — apa-apa yang membuka pautan, daripada aplikasi sembang kepada perintah terminal, pergi ke pelayar yang anda pilih.

## Salin URL dan Muat Turun Video

Pelayar keluarga Chromium (Chromium itu sendiri, Chrome, Edge, dan Brave) dilengkapi dengan dua sambungan Omarchy yang menjangkau keluar daripada pelayar dan ke dalam seluruh sistem anda.

**Copy URL** meletakkan alamat tab semasa pada papan keratan anda dengan `Alt + Shift + L`. Itu lebih pantas daripada mengklik ke dalam bar alamat dan menyalin, dan kerana ia melalui papan keratan sistem dan bukannya pelayar, anda mendapat pemberitahuan Omarchy yang mengesahkannya dan URL tersedia serta-merta dalam [sejarah papan keratan](08-unified-clipboard-history.md) dan setiap aplikasi lain. Ada juga butang bar alat, jika anda lebih suka mengklik.

**Download Video** mengambil video yang sedang dimainkan pada halaman yang anda lihat dengan `Alt + Shift + D`. Ia menyerahkan URL kepada [yt-dlp](https://github.com/yt-dlp/yt-dlp), jadi ia berfungsi pada lebih banyak daripada YouTube, dan muat turun sampai di `~/Videos`. Kemajuan muncul dalam paparan pada skrin yang sama yang digunakan oleh kelantangan dan kecerahan, dikemas kini di tempat dan bukannya menimbun pemberitahuan. Tetapkan `OMARCHY_YTDLP_DIR` jika anda mahu fail itu pergi ke tempat lain — lihat [Soalan Lazim](46-faq.md) untuk tempat meletakkan pemboleh ubah persekitaran.

Kedua-dua sambungan ini bercakap dengan Omarchy melalui hos pemesejan asli kecil, yang dipasang untuk anda bersama-sama pelayar. Itulah bahagian yang membolehkan video halaman web sampai di direktori rumah anda dan URL sampai di pengurus papan keratan anda, yang tidak dapat dilakukan oleh sambungan biasa sendiri.

Ini hanya untuk keluarga Chromium. Firefox dan Zen tidak mendapatnya.

## Firefox dan Zen

Firefox dan Zen adalah keluarga yang berbeza, jadi ia mendapat layanan yang berbeza: Omarchy memasang fail polisi untuk lalai yang munasabah dan menukarkannya ke mod Wayland asli, yang anda mahu untuk penskalaan pecahan dan penatalan pad sentuh yang lancar.

Ia tidak mendapat sambungan Chromium di atas, dan ia tidak dittemakan oleh Omarchy, jadi bahagian pengalaman itu adalah untuk anda sediakan.

## Membuang satu semula

Apa-apa yang anda pasang di sini boleh dibuang semula di bawah _Buang > Pelayar_. Chromium tidak berada dalam senarai itu — ia sebahagian daripada sistem asas.
