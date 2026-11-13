# Pelayar

Omarchy disertakan dengan [Google Chrome](https://www.google.com/chrome/) sebagai pelayar lalai. Ia bertemakan supaya sepadan dengan keseluruhan sistem anda, dan ialah yang dibuka oleh `Super + Shift + Return` serta yang menjalankan setiap [aplikasi web](25-web-apps.md) di dalamnya. Ia terus dibuka kepada tetingkap pelayar: tiada skrin alu-aluan atau gesaan log masuk, statistik penggunaan dan laporan kerosakan tidak dihantar kepada Google, dan gesaan privasi iklan dimatikan. Anda masih boleh log masuk ke akaun Google anda daripada butang profil pada bila-bila masa anda mahukan penyegerakan.

Jika Chrome bukan citarasa anda, anda tidak terperangkap dengannya. Di bawah _Install > Browser_ dalam menu Omarchy anda akan menemui [Chromium](https://www.chromium.org/) (binaan sumber terbuka biasa yang menjadi asas Chrome), Edge, Brave, Brave Origin, Firefox, dan [Zen](https://zen-browser.app/). Pilih satu dan Omarchy akan memasangnya, menyediakan direktori polisinya, dan menggunakan tema semasa anda padanya.

## Menjadikan satu sebagai lalai

Memasang pelayar tidak menaikkannya sebagai lalai. Setelah ia ada pada mesin, pergi ke _Setup > Defaults > Browser_ dan pilihnya — menu hanya menyenaraikan pelayar yang sebenarnya telah anda pasang, dan menandakan lalai semasa dengan tanda semak.

Daripada terminal:

```bash
omarchy default browser firefox
```

Jalankannya tanpa argumen dan ia akan memberitahu anda lalai semasa. Ini menetapkan pengendali XDG, jadi bukan hanya kekunci pintas Omarchy yang mengikutinya — apa sahaja yang membuka pautan, daripada aplikasi sembang hingga arahan terminal, akan pergi ke pelayar yang anda pilih.

## Salin URL dan Muat Turun Video

Pelayar keluarga Chromium (Chromium itu sendiri, Chrome, Edge, dan Brave) disertakan dengan dua sambungan Omarchy yang mencapai keluar daripada pelayar dan ke dalam keseluruhan sistem anda.

**Copy URL** meletakkan alamat tab semasa pada papan keratan anda dengan `Alt + Shift + L`. Itu lebih pantas daripada mengklik ke dalam bar alamat dan menyalin, dan kerana ia melalui papan keratan sistem dan bukannya papan keratan pelayar, anda mendapat pemberitahuan Omarchy yang mengesahkannya dan URL itu serta-merta tersedia dalam [sejarah papan keratan](08-unified-clipboard-history.md) dan setiap aplikasi lain. Terdapat juga butang bar alat, jika anda lebih suka mengklik.

**Download Video** mengambil video yang sedang dimainkan pada halaman yang anda lihat dengan `Alt + Shift + D`. Ia menyerahkan URL kepada [yt-dlp](https://github.com/yt-dlp/yt-dlp), jadi ia berfungsi pada jauh lebih banyak daripada YouTube, dan muat turun itu tiba di `~/Videos`. Kemajuan dipaparkan dalam paparan atas skrin yang sama yang digunakan oleh kelantangan dan kecerahan, dikemas kini di tempat yang sama dan bukannya menimbun pemberitahuan. Tetapkan `OMARCHY_YTDLP_DIR` jika anda lebih suka fail itu pergi ke tempat lain — lihat [FAQ](46-faq.md) untuk mengetahui tempat meletakkan pemboleh ubah persekitaran.

Kedua-dua sambungan berkomunikasi dengan Omarchy melalui hos pemesejan natif yang kecil, yang dipasang untuk anda bersama-sama pelayar. Itulah bahagian yang membolehkan video halaman web berakhir dalam direktori utama anda dan URL berakhir dalam pengurus papan keratan anda, sesuatu yang tidak boleh dilakukan oleh sambungan biasa dengan sendirinya.

Ini hanya untuk keluarga Chromium. Firefox dan Zen tidak mendapatnya.

## Firefox dan Zen

Firefox dan Zen ialah keluarga yang berbeza, jadi mereka mendapat layanan yang berbeza: Omarchy memasang fail polisi untuk lalai yang munasabah dan menukarkannya kepada mod Wayland natif, yang anda mahukan untuk penskalaan pecahan dan penatalan pad jejak yang lancar.

Mereka tidak mendapat sambungan Chromium di atas, dan mereka tidak bertemakan oleh Omarchy, jadi bahagian-bahagian pengalaman itu adalah untuk anda sediakan sendiri.

## Mengalih keluar satu semula

Mana-mana pelayar ini, termasuk Chrome, boleh dialih keluar semula di bawah _Remove > Browser_. Pautan kemudian akan pergi ke Chrome atau Chromium jika yang satu lagi masih dipasang.
