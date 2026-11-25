# Pelayar

Omarchy dibekalkan dengan [Google Chrome](https://www.google.com/chrome/) sebagai pelayar lalai. Ia diberi tema supaya sepadan dengan seluruh sistem anda, dan ialah yang dibuka oleh `Super + Shift + Return` (atau `Super + Shift + B`), dengan `Super + Shift + Alt + B` untuk tetingkap peribadi, dan yang menjalankan setiap [aplikasi web](25-web-apps.md) di dalamnya. Ia terus membuka tetingkap pelayar: tiada skrin alu-aluan atau gesaan log masuk, statistik penggunaan dan laporan ranap tidak dihantar kepada Google, dan gesaan privasi iklan dimatikan. Anda masih boleh log masuk ke akaun Google anda daripada butang profil pada bila-bila masa anda mahukan penyegerakan.

Jika Chrome bukan citarasa anda, anda tidak terperangkap dengannya. Di bawah _Install > Browser_ dalam menu Omarchy anda akan menemui [Chromium](https://www.chromium.org/) (binaan sumber terbuka biasa yang menjadi asas Chrome), Edge, Brave, Brave Origin, Firefox, dan [Zen](https://zen-browser.app/) (Edge hanya pada mesin x86). Pilih satu dan Omarchy akan memasangnya, menyediakan direktori polisinya, dan menggunakan tema semasa anda padanya.

## Menjadikan satu sebagai lalai

Memasang pelayar tidak menjadikannya lalai. Untuk menukar, pergi ke _Setup > Defaults > Browser_ dan pilih satu. Lalai semasa ditandakan dengan tanda semak, dan memilih pelayar yang anda belum miliki akan memasangnya dahulu.

Dari terminal, arahannya ialah:

```bash
omarchy default browser firefox
```

Jalankannya tanpa argumen dan ia akan memberitahu anda lalai semasa. Ini menetapkan pengendali XDG, jadi bukan sahaja kekunci pintas Omarchy yang mengikutinya — apa sahaja yang membuka pautan, daripada aplikasi sembang hingga arahan terminal, akan pergi ke pelayar yang anda pilih.

## Copy URL dan Download Video

Pelayar keluarga Chromium (Chromium itu sendiri, Chrome, Edge, Brave, dan Brave Origin) dibekalkan dengan tiga sambungan Omarchy: dua yang mencapai keluar dari pelayar dan masuk ke seluruh sistem anda, dan satu yang merapikan WhatsApp.

**Copy URL** meletakkan alamat tab semasa pada papan klip anda dengan `Alt + Shift + L`. Itu lebih pantas daripada mengklik ke bar alamat dan menyalin, dan kerana ia melalui papan klip sistem dan bukannya papan klip pelayar, anda mendapat pemberitahuan Omarchy yang mengesahkannya dan URL itu serta-merta tersedia dalam [sejarah papan klip](08-unified-clipboard-history.md) dan setiap aplikasi lain. Ada juga butang bar alat, jika anda lebih suka mengklik.

**Download Video** mengambil video yang sedang dimainkan pada halaman yang anda lihat dengan `Alt + Shift + D`. Ia menyerahkan URL kepada [yt-dlp](https://github.com/yt-dlp/yt-dlp), jadi ia berfungsi pada jauh lebih banyak daripada sekadar YouTube, dan muat turun itu tiba di `~/Videos`. Kemajuan dipaparkan pada paparan atas skrin yang sama yang digunakan oleh kelantangan dan kecerahan, dikemas kini di tempatnya dan bukannya menimbun pemberitahuan. Tetapkan `OMARCHY_YTDLP_DIR` jika anda lebih suka fail itu pergi ke tempat lain — lihat [FAQ](46-faq.md) untuk mengetahui tempat meletakkan pemboleh ubah persekitaran.

Kedua-dua sambungan itu berkomunikasi dengan Omarchy melalui hos pemesejan natif kecil, yang dipasang untuk anda bersama-sama pelayar. Itulah bahagian yang membolehkan video pada halaman web berakhir di direktori rumah anda dan URL berakhir di pengurus papan klip anda, sesuatu yang tidak boleh dilakukan oleh sambungan biasa dengan sendirinya.

**WhatsApp Slim** menjadikan WhatsApp Web mengikut tema sistem anda dan meruntuhkan senarai sembangnya apabila tetingkap sempit.

Ini hanya untuk keluarga Chromium. Firefox dan Zen tidak mendapatnya.

## Firefox dan Zen

Firefox dan Zen ialah keluarga yang berbeza, jadi ia mendapat layanan berbeza: Omarchy memasang fail polisi untuk tetapan lalai yang munasabah dan menukarkannya ke mod Wayland natif, yang anda perlukan untuk penskalaan pecahan dan penatalan pad jejak yang lancar.

Ia tidak mendapat sambungan Chromium di atas, dan tidak diberi tema oleh Omarchy, jadi bahagian-bahagian pengalaman itu perlu anda sediakan sendiri.

## Membuangnya semula

Mana-mana pelayar ini, termasuk Chrome, boleh dibuang semula di bawah _Remove > Browser_. Pautan kemudian akan pergi ke Chrome atau Chromium jika yang satu lagi masih terpasang.
