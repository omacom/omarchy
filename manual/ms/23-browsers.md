# Pelayar

Omarchy didatangkan dengan [Google Chrome](https://www.google.com/chrome/) sebagai pelayar lalai. Ia bertema sepadan dengan keseluruhan sistem anda, dan ia yang dibuka oleh `Super + Shift + Return` (atau `Super + Shift + B`), dengan `Super + Shift + Alt + B` untuk tetingkap peribadi, dan tempat setiap [aplikasi web](25-web-apps.md) berjalan. Ia terus membuka tetingkap pelayar: tiada skrin alu-aluan atau gesaan log masuk, statistik penggunaan dan laporan ranap tidak dihantar kepada Google, dan gesaan privasi iklan dimatikan. Anda masih boleh log masuk ke akaun Google anda daripada butang profil pada bila-bila masa anda mahukan penyegerakan.

Jika Chrome bukan citarasa anda, anda tidak terperangkap dengannya. Di bawah _Install > Browser_ dalam menu Omarchy, anda akan menemui [Chromium](https://www.chromium.org/) (binaan sumber terbuka biasa yang menjadi asas kepada Chrome), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/), dan [Ladybird](https://ladybird.org/) (Edge hanya pada mesin x86). Pilih satu dan Omarchy akan memasangnya, menyediakan direktori polisinya, dan menggunakan tema semasa anda padanya.

## Menjadikan satu sebagai lalai

Memasang pelayar tidak menjadikannya lalai. Untuk bertukar, pergi ke _Setup > Defaults > Browser_ dan pilih satu. Lalai semasa ditandakan dengan tanda rait, dan memilih pelayar yang belum anda miliki akan memasangnya dahulu.

Dari terminal, arahannya ialah:

```bash
omarchy default browser firefox
```

Jalankannya tanpa argumen dan ia akan memberitahu anda lalai semasa. Ini menetapkan pengendali XDG, jadi bukan sahaja kekunci pintas Omarchy yang turut mengikut — apa sahaja yang membuka pautan, daripada aplikasi sembang hinggalah arahan terminal, akan pergi ke pelayar yang anda pilih.

## Copy URL and Download Video

Pelayar keluarga Chromium (Chromium itu sendiri, Chrome, Edge, Brave, dan Brave Origin) didatangkan dengan tiga sambungan Omarchy: dua yang mencapai keluar dari pelayar dan masuk ke seluruh sistem anda, dan satu yang mengemas WhatsApp.

**Copy URL** meletakkan alamat tab semasa pada papan keratan anda dengan `Alt + Shift + L`. Itu lebih pantas daripada mengklik ke dalam bar alamat dan menyalin, dan kerana ia melalui papan keratan sistem dan bukannya papan keratan pelayar, anda mendapat pemberitahuan Omarchy yang mengesahkannya dan URL tersebut serta-merta tersedia dalam [sejarah papan keratan](08-unified-clipboard-history.md) dan setiap aplikasi lain. Terdapat juga butang bar alat, jika anda lebih suka mengklik.

**Download Video** mengambil video yang sedang dimainkan pada halaman yang anda lihat dengan `Alt + Shift + D`. Ia menyerahkan URL tersebut kepada [yt-dlp](https://github.com/yt-dlp/yt-dlp), jadi ia berfungsi pada jauh lebih banyak tempat daripada sekadar YouTube, dan muat turun itu akan mendarat di `~/Videos`. Kemajuan dipaparkan dalam paparan atas skrin yang sama yang digunakan oleh kelantangan dan kecerahan, dikemas kini di tempatnya dan bukannya menimbun pemberitahuan. Tetapkan `OMARCHY_YTDLP_DIR` jika anda mahu fail tersebut pergi ke tempat lain — lihat [FAQ](46-faq.md) untuk mengetahui tempat meletakkan pemboleh ubah persekitaran.

Kedua-dua sambungan itu bercakap dengan Omarchy melalui hos pemesejan asli yang kecil, yang dipasang untuk anda bersama-sama pelayar. Itulah bahagian yang membolehkan video pada halaman web berakhir dalam direktori utama anda dan URL berakhir dalam pengurus papan keratan anda, sesuatu yang tidak dapat dilakukan oleh sambungan biasa dengan sendirinya.

**WhatsApp Slim** menjadikan WhatsApp Web mengikut tema sistem anda dan meruntuhkan senarai sembangnya apabila tetingkap sempit.

Ini hanya untuk keluarga Chromium. Firefox dan Zen tidak mendapatnya.

## Firefox dan Zen

Firefox dan Zen ialah keluarga yang berbeza, jadi ia mendapat layanan yang berbeza: Omarchy memasang fail polisi untuk lalai yang munasabah dan menukarkannya kepada mod Wayland asli, yang anda mahukan untuk penskalaan pecahan dan penatalan pad jejak yang lancar.

Ia tidak mendapat sambungan Chromium di atas, dan ia tidak bertemakan Omarchy, jadi bahagian pengalaman tersebut adalah tanggungjawab anda untuk menyediakannya.

## Ladybird

Ladybird ialah pelayar yang ditulis dari kosong, dengan enjinnya sendiri dan bukannya enjin Chromium atau Firefox. Ia masih dalam alfa, jadi jangkakan tapak yang belum berfungsi, dan Omarchy memasangnya sebagaimana ia datang: tiada sambungan, tiada tema, tiada polisi. Ia juga tiada tetingkap peribadi, jadi `Super + Shift + Alt + B` membukanya dengan profil sementara yang dipadam apabila anda menutupnya. [Aplikasi web](25-web-apps.md) terus berjalan dalam Chrome atau Chromium.

## Mengalih keluarnya semula

Mana-mana pelayar ini, termasuk Chrome, boleh dialih keluar semula di bawah _Remove > Browser_. Pautan kemudiannya akan pergi ke Chrome atau Chromium jika pelayar yang satu lagi masih terpasang.
