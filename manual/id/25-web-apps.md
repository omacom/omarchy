# Aplikasi Web

Kamu bisa menambahkan aplikasi web kamu sendiri menggunakan _Pasang > Aplikasi Web_ di menu Omarchy (`Super + Space`). Menu itu akan memintamu memasukkan nama aplikasi, URL aplikasi, dan URL ikon, jika ikonnya tidak bisa diambil lewat favicon. Kamu bisa mendapatkan ikon PNG yang bagus untuk banyak aplikasi web populer di [Dashboard Icons](https://dashboardicons.com).

Aplikasi-aplikasi itu kemudian akan bisa diakses melalui peluncur aplikasi (`Super + Space`), dan menggunakan jendela aplikasi web tanpa bingkai yang indah.

Jika kamu ingin menghapus aplikasi web, cukup buka _Hapus > Aplikasi Web_ di menu Omarchy.

Sebaiknya kamu masuk ke semua akunmu menggunakan browser biasa sebelum menggunakan pintasan aplikasi web. Bingkai pembungkus tipisnya tidak bekerja dengan baik bersama 1password, jadi lebih mudah jika kamu sudah masuk langsung terlebih dahulu.

Semua hotkey keyboard untuk aplikasi web ini bisa diubah di `~/.config/hypr/bindings.lua`.

Saat kamu berada di aplikasi web, kamu bisa menyalin URL saat ini ke clipboard menggunakan `Shift + Alt + L`.

Secara bawaan, Omarchy sudah dilengkapi dengan berbagai aplikasi bawaan:

## HEY

[HEY](https://www.hey.com/) adalah layanan email dan kalender yang menjadi alternatif hebat bagi orang-orang yang bosan dengan Gmail, Outlook, atau Apple Mail. Layanan ini dibuat oleh [37signals](https://37signals.com/) tempat Omarchy berasal.

Kamu bisa memulai HEY Email menggunakan `Super + Shift + E`, langsung melompat untuk menulis email baru menggunakan `Super + Shift + Alt + E`, dan memulai HEY Calendar menggunakan `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) adalah layanan manajemen proyek yang membantu tim kecil bergerak lebih cepat dan membuat lebih banyak kemajuan. Daripada menambal-nambal campuran Trello, Slack, Asana, Notion, atau apa pun itu, kamu bisa mendapatkan semuanya di satu tempat dengan Basecamp. Layanan ini dibuat oleh [37signals](https://37signals.com/) tempat Omarchy berasal.

Kamu bisa memulai Basecamp menggunakan peluncur aplikasi (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) adalah bot chat AI paling populer di dunia.

Kamu bisa memulai ChatGPT menggunakan `Super + Shift + A`.

## Grok

[Grok](https://grok.com) adalah bot chat milik xAI.

Kamu bisa memulai Grok menggunakan `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) adalah salah satu layanan pesan paling populer di dunia, dan versi webnya adalah pilihan yang hebat untuk Linux.

Kamu bisa memulai WhatsApp menggunakan `Super + Shift + Alt + G`. Aplikasi ini terbuka dengan ekstensi WhatsApp Slim milik Omarchy, yang membuatnya mengikuti temamu dan menciutkan daftar chat saat jendelanya sempit.

## Aplikasi Google

Google Messages, Google Photos, Google Maps, dan Google Contacts semuanya juga disertakan sebagai aplikasi web.

Kamu bisa memulai Google Messages menggunakan `Super + Shift + Ctrl + G`, Google Photos menggunakan `Super + Shift + P`, dan Google Maps menggunakan `Super + Shift + S`. Google Contacts tersedia melalui peluncur aplikasi (`Super + Space`).

## X

X adalah tempat berita bermunculan.

Kamu bisa memulai X menggunakan `Super + Shift + X` dan langsung melompat untuk menulis postingan baru dengan `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) adalah platform video paling populer di dunia.

Kamu bisa memulai YouTube menggunakan `Super + Shift + Y`.

## Netflix

[Netflix](https://www.netflix.com/) disertakan sebagai aplikasi web pada instalasi baru.

Kamu memulai Netflix menggunakan peluncur aplikasi (`Super + Space`).

## Zoom

[Zoom](https://zoom.us/) adalah sistem obrolan video paling populer yang digunakan di AS. Koneksi hebat di seluruh dunia. Dan rapat 40 menit bisa diadakan tanpa akun berbayar. Omarchy membungkus klien web Zoom, dan tautan rapat Zoom akan langsung terbuka di dalamnya.

Kamu memulai Zoom menggunakan peluncur aplikasi (`Super + Space`).

## Discord

[Discord](https://discord.com/) adalah tempat berkumpulnya sebagian besar komunitas gaming dan open source, termasuk [komunitas Omarchy sendiri](https://discord.gg/tXFUdasqhY).

Kamu memulai Discord menggunakan peluncur aplikasi (`Super + Space`).

## Aplikasi Microsoft

Pilih _Pasang > Layanan > Microsoft_ untuk menambahkan Outlook, Word, Excel, PowerPoint, Teams, dan OneDrive sebagai aplikasi web. Setiap aplikasi memiliki peluncurnya sendiri dan terbuka secara langsung, menggunakan URL komersial Microsoft 365 dan profil browser kamu yang sudah ada. Aplikasi-aplikasi itu terbuka di jendela aplikasi browser yang sama seperti aplikasi web Omarchy lainnya; aplikasi-aplikasi itu tidak memasang klien Teams for Linux yang terpisah.

Hapus bundelnya dengan _Hapus > Layanan > Microsoft_, atau hapus aplikasi satu per satu dengan _Hapus > Aplikasi Web_. Kamu juga bisa memasang hanya aplikasi yang kamu inginkan melalui _Pasang > Aplikasi Web_.

Untuk cloud pemerintah atau cloud berdaulat, edit URL pada baris `Exec=` di peluncur yang relevan di bawah `~/.local/share/applications/`, seperti `Microsoft Teams.desktop`, menggunakan URL yang disediakan oleh organisasimu. Tulis setiap `%` literal pada baris itu sebagai `%%`. Perubahan berlaku pada peluncuran berikutnya. Menjalankan pemasang bundel lagi akan mengganti peluncurnya dengan URL bawaan.

Untuk memisahkan login kerja, tambahkan direktori data browser ke baris `Exec=` setiap peluncur:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Ganti direktori contoh dengan jalur absolut pilihanmu dan gunakan jalur yang sama untuk keenam peluncur agar bisa berbagi login kerja di antara mereka. Aplikasi web menggunakan browser yang didukung yang dipilih oleh Omarchy, dan akan beralih ke Chrome ketika browser bawaan tidak didukung.
