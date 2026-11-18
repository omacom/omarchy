# Aplikasi Web

Kamu bisa menambahkan aplikasi webmu sendiri menggunakan _Install > Web App_ di menu Omarchy (`Super + Space`). Aplikasi ini akan menanyakan nama aplikasi, URL aplikasi, dan URL ikon, jika tidak bisa mengambilnya melalui favicon. Kamu bisa mendapatkan ikon PNG yang bagus untuk banyak aplikasi web populer di [Dashboard Icons](https://dashboardicons.com).

Aplikasi-aplikasi tersebut kemudian bisa diakses melalui peluncur aplikasi (`Super + Space`), dan menggunakan jendela aplikasi web tanpa bingkai yang indah.

Jika kamu ingin menghapus sebuah aplikasi web, cukup buka _Remove > Web App_ di menu Omarchy.

Sebaiknya kamu masuk ke semua akunmu menggunakan browser biasa sebelum menggunakan pintasan aplikasi web. Bingkai pembungkus tipisnya tidak bekerja dengan baik bersama 1password, jadi lebih mudah jika kamu sudah masuk secara langsung terlebih dahulu.

Semua hotkey keyboard untuk aplikasi web ini bisa diubah di `~/.config/hypr/bindings.lua`.

Saat kamu berada di dalam aplikasi web, kamu bisa menyalin URL saat ini ke clipboard menggunakan `Shift + Alt + L`.

Secara default, Omarchy sudah dilengkapi dengan berbagai aplikasi default:

## HEY

[HEY](https://www.hey.com/) adalah layanan email dan kalender yang menjadi alternatif yang bagus bagi orang-orang yang sudah bosan dengan Gmail, Outlook, atau Apple Mail. Layanan ini dibuat oleh [37signals](https://37signals.com/) tempat Omarchy berasal.

Kamu bisa memulai HEY Email menggunakan `Super + Shift + E`, langsung melompat untuk menulis email baru menggunakan `Super + Shift + Alt + E`, dan memulai HEY Calendar menggunakan `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) adalah layanan manajemen proyek yang membantu tim kecil bergerak lebih cepat dan membuat lebih banyak kemajuan. Daripada menggabungkan campuran Trello, Slack, Asana, Notion, atau apa pun itu, kamu bisa mendapatkan semuanya di satu tempat dengan Basecamp. Layanan ini dibuat oleh [37signals](https://37signals.com/) tempat Omarchy berasal.

Kamu bisa memulai Basecamp menggunakan peluncur aplikasi (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) adalah bot chat AI paling populer di dunia.

Kamu bisa memulai ChatGPT menggunakan `Super + Shift + A`.

## Grok

[Grok](https://grok.com) adalah bot chat milik xAI.

Kamu bisa memulai Grok menggunakan `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) adalah salah satu layanan pesan paling populer di dunia, dan versi web-nya adalah pilihan yang bagus untuk Linux.

Kamu bisa memulai WhatsApp menggunakan `Super + Shift + Alt + G`.

## Aplikasi Google

Google Messages, Google Photos, Google Maps, dan Google Contacts juga disertakan sebagai aplikasi web.

Kamu bisa memulai Google Messages menggunakan `Super + Shift + Ctrl + G`, Google Photos menggunakan `Super + Shift + P`, dan Google Maps menggunakan `Super + Shift + S`. Google Contacts tersedia melalui peluncur aplikasi (`Super + Space`).

## X

X adalah tempat berita pertama kali muncul.

Kamu bisa memulai X menggunakan `Super + Shift + X` dan langsung menulis postingan baru dengan `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) adalah platform video paling populer di dunia.

Kamu bisa memulai YouTube menggunakan `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) adalah sistem obrolan video paling populer yang digunakan di AS. Koneksi yang bagus di seluruh dunia. Dan rapat selama 40 menit bisa diadakan tanpa akun berbayar. Omarchy membungkus klien web Zoom, dan tautan rapat Zoom akan langsung terbuka di dalamnya.

Kamu memulai Zoom menggunakan peluncur aplikasi (`Super + Space`).

## Discord

[Discord](https://discord.com/) adalah tempat sebagian besar komunitas gaming dan open source berkumpul, termasuk [komunitas Omarchy sendiri](https://discord.gg/tXFUdasqhY).

Kamu memulai Discord menggunakan peluncur aplikasi (`Super + Space`).

## Aplikasi Microsoft

Pilih _Install > Service > Microsoft_ untuk menambahkan Outlook, Word, Excel, PowerPoint, Teams, dan OneDrive sebagai aplikasi web. Setiap aplikasi memiliki peluncurnya sendiri dan terbuka secara langsung, menggunakan URL Microsoft 365 komersial dan profil browser kamu yang sudah ada. Aplikasi-aplikasi tersebut terbuka di jendela aplikasi browser yang sama seperti aplikasi web Omarchy lainnya; mereka tidak menginstal klien Teams for Linux yang terpisah.

Hapus bundel tersebut dengan _Remove > Service > Microsoft_, atau hapus aplikasi satu per satu dengan _Remove > Web App_. Kamu juga bisa menginstal hanya aplikasi yang kamu inginkan melalui _Install > Web App_.

Untuk cloud pemerintah atau berdaulat, edit URL pada baris `Exec=` di peluncur yang relevan di bawah `~/.local/share/applications/`, seperti `Microsoft Teams.desktop`, menggunakan URL yang disediakan oleh organisasi kamu. Tulis setiap `%` literal pada baris tersebut sebagai `%%`. Perubahan berlaku pada peluncuran berikutnya. Menjalankan penginstal bundel lagi akan mengganti peluncurnya dengan URL default.

Untuk menjaga login pekerjaan tetap terpisah, tambahkan direktori data browser ke baris `Exec=` setiap peluncur:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Ganti direktori contoh dengan path absolut pilihan kamu dan gunakan path yang sama untuk keenam peluncur agar bisa berbagi login pekerjaan di antara mereka. Aplikasi web ini menggunakan browser yang didukung yang telah dipilih Omarchy, dan akan menggunakan Chrome sebagai cadangan jika browser default tidak didukung.
