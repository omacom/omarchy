# Aplikasi Web

Anda boleh menambah aplikasi web anda sendiri menggunakan _Install > Web App_ dalam menu Omarchy (`Super + Space`). Ia akan meminta nama aplikasi, URL aplikasi, dan URL ikon, jika ia tidak dapat mendapatkannya melalui favicon. Anda boleh mendapatkan ikon PNG yang hebat untuk banyak aplikasi web popular di [Dashboard Icons](https://dashboardicons.com).

Aplikasi tersebut kemudiannya boleh diakses melalui pelancar aplikasi (`Super + Space`), dan menggunakan tetingkap aplikasi web tanpa bingkai yang cantik.

Jika anda ingin membuang aplikasi web, pergi sahaja ke _Remove > Web App_ dalam menu Omarchy.

Sebaiknya anda log masuk ke semua akaun anda menggunakan pelayar biasa sebelum menggunakan pintasan aplikasi web. Bingkai pembalut nipis itu tidak berfungsi dengan baik dengan 1password, jadi lebih mudah untuk terus log masuk terlebih dahulu.

Semua kekunci pintas papan kekunci untuk aplikasi web ini boleh ditukar dalam `~/.config/hypr/bindings.lua`.

Apabila anda berada dalam aplikasi web, anda boleh menyalin URL semasa ke papan keratan menggunakan `Shift + Alt + L`.

Secara lalai, Omarchy sudah disertakan dengan pelbagai aplikasi lalai:

## HEY

[HEY](https://www.hey.com/) ialah perkhidmatan e-mel dan kalendar yang menjadi alternatif hebat untuk mereka yang sudah bosan dengan Gmail, Outlook, atau Apple Mail. Ia dibuat oleh [37signals](https://37signals.com/) tempat Omarchy berasal.

Anda boleh memulakan HEY Email menggunakan `Super + Shift + E`, terus melompat untuk mengarang e-mel baharu menggunakan `Super + Shift + Alt + E`, dan memulakan HEY Calendar menggunakan `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) ialah perkhidmatan pengurusan projek yang membantu pasukan kecil bergerak lebih pantas dan membuat lebih banyak kemajuan. Daripada menampal bersama campuran Trello, Slack, Asana, Notion, atau apa sahaja, anda boleh mendapatkan semuanya di satu tempat dengan Basecamp. Ia dibuat oleh [37signals](https://37signals.com/) tempat Omarchy berasal.

Anda boleh memulakan Basecamp menggunakan pelancar aplikasi (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) ialah bot sembang AI paling popular di dunia.

Anda boleh memulakan ChatGPT menggunakan `Super + Shift + A`.

## Grok

[Grok](https://grok.com) ialah bot sembang xAI.

Anda boleh memulakan Grok menggunakan `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) ialah salah satu perkhidmatan pemesejan paling popular di dunia, dan versi webnya ialah pilihan hebat untuk Linux.

Anda boleh memulakan WhatsApp menggunakan `Super + Shift + Alt + G`. Ia dibuka dengan sambungan WhatsApp Slim Omarchy, yang menjadikannya mengikut tema anda dan melipat senarai sembang apabila tetingkap sempit.

## Aplikasi Google

Google Messages, Google Photos, Google Maps, dan Google Contacts semuanya turut disertakan sebagai aplikasi web.

Anda boleh memulakan Google Messages menggunakan `Super + Shift + Ctrl + G`, Google Photos menggunakan `Super + Shift + P`, dan Google Maps menggunakan `Super + Shift + S`. Google Contacts tersedia melalui pelancar aplikasi (`Super + Space`).

## X

X ialah tempat berita mula-mula tersebar.

Anda boleh memulakan X menggunakan `Super + Shift + X` dan terus menulis catatan baharu dengan `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) ialah platform video paling popular di dunia.

Anda boleh memulakan YouTube menggunakan `Super + Shift + Y`.

## Netflix

[Netflix](https://www.netflix.com/) disertakan sebagai aplikasi web pada pemasangan baharu.

Anda memulakan Netflix menggunakan pelancar aplikasi (`Super + Space`).

## Zoom

[Zoom](https://zoom.us/) ialah sistem sembang video paling popular yang digunakan di US. Sambungan hebat di seluruh dunia. Dan mesyuarat selama 40 minit boleh diadakan tanpa akaun berbayar. Omarchy membalut klien web Zoom, dan pautan mesyuarat zoom akan dibuka terus ke dalamnya.

Anda memulakan Zoom menggunakan pelancar aplikasi (`Super + Space`).

## Discord

[Discord](https://discord.com/) ialah tempat kebanyakan komuniti permainan dan sumber terbuka melepak, termasuk [komuniti Omarchy sendiri](https://discord.gg/tXFUdasqhY).

Anda memulakan Discord menggunakan pelancar aplikasi (`Super + Space`).

## Aplikasi Microsoft

Pilih _Install > Service > Microsoft_ untuk menambah Outlook, Word, Excel, PowerPoint, Teams, dan OneDrive sebagai aplikasi web. Setiap aplikasi mempunyai pelancarnya sendiri dan dibuka terus, menggunakan URL komersial Microsoft 365 dan profil pelayar sedia ada anda. Ia dibuka dalam tetingkap aplikasi pelayar yang sama seperti aplikasi web Omarchy yang lain; ia tidak memasang klien Teams for Linux yang berasingan.

Buang pakej tersebut dengan _Remove > Services > Microsoft_, atau buang aplikasi individu dengan _Remove > Web App_. Anda juga boleh memasang hanya aplikasi yang anda mahu melalui _Install > Web App_.

Untuk awan kerajaan atau berdaulat, edit URL pada baris `Exec=` dalam pelancar yang berkaitan di bawah `~/.local/share/applications/`, seperti `Microsoft Teams.desktop`, menggunakan URL yang dibekalkan oleh organisasi anda. Tulis sebarang `%` literal dalam baris itu sebagai `%%`. Perubahan berkuat kuasa pada pelancaran seterusnya. Menjalankan pemasang pakej itu sekali lagi akan menggantikan pelancarnya dengan URL lalai.

Untuk memastikan log masuk kerja berasingan, tambahkan direktori data pelayar pada baris `Exec=` setiap pelancar:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Gantikan direktori contoh dengan laluan mutlak pilihan anda dan gunakan laluan yang sama untuk kesemua enam pelancar untuk berkongsi log masuk kerja antara mereka. Aplikasi web menggunakan pelayar disokong yang dipilih oleh Omarchy, kembali kepada Chrome apabila pelayar lalai tidak disokong.
