# Aplikasi Web

Kamu dapat menambahkan aplikasi webmu sendiri menggunakan _Pasang > Web App_ di menu Omarchy (`Super + Space`). Ini akan memintamu nama aplikasi, URL aplikasi, dan URL ikon, jika tidak dapat mengambilnya melalui favicon. Kamu dapat mendapatkan ikon PNG yang bagus untuk banyak aplikasi web populer di [Dashboard Icons](https://dashboardicons.com).

Itu kemudian akan dapat diakses melalui peluncur aplikasi (`Super + Space`), dan menggunakan jendela aplikasi web tanpa bingkai yang indah.

Jika kamu ingin menghapus aplikasi web, cukup pergi ke _Hapus > Web App_ di menu Omarchy.

Sebaiknya kamu masuk ke semua akunmu menggunakan browser biasa sebelum menggunakan pintasan aplikasi web. Bingkai pembungkus tipis tidak bekerja dengan baik dengan 1password, jadi lebih mudah untuk masuk secara langsung terlebih dahulu.

Semua hotkey keyboard untuk aplikasi web ini dapat diubah di `~/.config/hypr/bindings.lua`.

Saat kamu berada di aplikasi web, kamu dapat menyalin URL saat ini ke papan klip menggunakan `Shift + Alt + L`.

Secara bawaan, Omarchy sudah dilengkapi dengan berbagai aplikasi bawaan:

## HEY

[HEY](https://www.hey.com/) adalah layanan email dan kalender yang berfungsi sebagai alternatif bagus bagi orang yang lelah dengan Gmail, Outlook, atau Apple Mail. Ini dibuat oleh [37signals](https://37signals.com/) tempat Omarchy berasal.

Kamu dapat memulai HEY Email menggunakan `Super + Shift + E`, langsung ke penulisan email baru menggunakan `Super + Shift + Alt + E`, dan memulai HEY Calendar menggunakan `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) adalah layanan manajemen proyek yang membantu tim kecil bergerak lebih cepat dan membuat lebih banyak kemajuan. Daripada menambal campuran Trello, Slack, Asana, Notion, atau apa pun, kamu dapat memiliki semuanya di satu tempat dengan Basecamp. Ini dibuat oleh [37signals](https://37signals.com/) tempat Omarchy berasal.

Kamu dapat memulai Basecamp menggunakan peluncur aplikasi (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) adalah bot obrolan AI paling populer di dunia.

Kamu dapat memulai ChatGPT menggunakan `Super + Shift + A`.

## Grok

[Grok](https://grok.com) adalah bot obrolan xAI.

Kamu dapat memulai Grok menggunakan `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) adalah salah satu layanan perpesanan paling populer di dunia, dan versi web adalah pilihan bagus untuk Linux.

Kamu dapat memulai WhatsApp menggunakan `Super + Shift + Alt + G`.

## Aplikasi Google

Google Messages, Google Photos, Google Maps, dan Google Contacts semuanya juga disertakan sebagai aplikasi web.

Kamu dapat memulai Google Messages menggunakan `Super + Shift + Ctrl + G`, Google Photos menggunakan `Super + Shift + P`, dan Google Maps menggunakan `Super + Shift + S`. Google Contacts tersedia melalui peluncur aplikasi (`Super + Space`).

## X

X adalah tempat berita pecah.

Kamu dapat memulai X menggunakan `Super + Shift + X` dan langsung menulis postingan baru dengan `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) adalah platform video paling populer di dunia.

Kamu dapat memulai YouTube menggunakan `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) adalah sistem obrolan video paling populer yang digunakan di AS. Koneksi bagus di seluruh dunia. Dan rapat 40 menit dapat diadakan tanpa akun berbayar. Omarchy membungkus klien web Zoom, dan tautan rapat zoom akan terbuka langsung ke dalamnya.

Kamu memulai Zoom menggunakan peluncur aplikasi (`Super + Space`).

## Discord

[Discord](https://discord.com/) adalah tempat sebagian besar komunitas gaming dan open source nongkrong, termasuk [milik Omarchy sendiri](https://discord.gg/tXFUdasqhY).

Kamu memulai Discord menggunakan peluncur aplikasi (`Super + Space`).

## Aplikasi Microsoft

Pilih _Pasang > Service > Microsoft_ untuk menambahkan Outlook, Word, Excel, PowerPoint, Teams, dan OneDrive sebagai aplikasi web. Setiap aplikasi memiliki peluncurnya sendiri dan terbuka secara langsung, menggunakan URL komersial Microsoft 365 dan profil browser yang ada. Mereka terbuka di jendela aplikasi browser yang sama seperti aplikasi web Omarchy lainnya; mereka tidak memasang klien Teams for Linux yang terpisah.

Hapus bundel dengan _Hapus > Service > Microsoft_, atau hapus aplikasi individual dengan _Hapus > Web App_. Kamu juga dapat memasang hanya aplikasi yang kamu inginkan melalui _Pasang > Web App_.

Untuk cloud pemerintah atau berdaulat, edit URL pada baris `Exec=` di peluncur yang relevan di bawah `~/.local/share/applications/`, seperti `Microsoft Teams.desktop`, menggunakan URL yang disediakan oleh organisasimu. Tulis `%` literal apa pun di baris tersebut sebagai `%%`. Perubahan berlaku pada peluncuran berikutnya. Menjalankan pemasang bundel lagi mengganti peluncurnya dengan URL bawaan.

Untuk memisahkan masuk kerja, tambahkan direktori data browser ke baris `Exec=` setiap peluncur:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Ganti direktori contoh dengan jalur absolut pilihanmu dan gunakan jalur yang sama untuk keenam peluncur untuk berbagi masuk kerja di antara mereka. Aplikasi web menggunakan browser yang didukung yang dipilih Omarchy, kembali ke Chromium saat browser bawaan tidak didukung.
