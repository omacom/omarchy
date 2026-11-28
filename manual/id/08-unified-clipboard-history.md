# Clipboard Terpadu & Riwayat

Biasanya di Linux, kamu perlu `Ctrl + Shift + C/V` untuk copy-paste di terminal dan `Ctrl + C/V` untuk melakukannya di tempat lain. Itu sulit dibiasakan bagi siapa pun yang tidak lahir dan besar di Linux! Begitu juga perpindahannya dari super ke ctrl, kalau kamu datang dari Mac.

Omarchy mengatasi kedua masalah itu dengan pintasan clipboard terpadu yang bekerja (hampir) di mana-mana. Pintasannya adalah:

| Pintasan | Perintah |
| ------- | ----------- |
| Super + A | Pilih semua |
| Super + C | Salin |
| Super + X | Potong |
| Super + V | Tempel |
| Super + Ctrl + V | Riwayat clipboard |

_Perlu dicatat bahwa sebagian besar agent harness akan menggunakan `Ctrl + V` untuk menempel gambar, tetapi `Super + V` untuk menempel teks._

Gunakan `Super + A`, lalu `Super + C` untuk menyalin semua yang ada di bidang teks yang sedang fokus atau aplikasi lain yang mendukung `Ctrl + A`. Di terminal, `Ctrl + A` akan berpindah ke awal baris perintah alih-alih memilih teksnya.

### Riwayat clipboard

Riwayat clipboard disediakan oleh shell Omarchy dan bekerja untuk teks maupun gambar. Kamu memicunya dengan `Super + Ctrl + V` dan memilih entrimu dengan Return, yang akan langsung menempelkannya ke aplikasi yang tadi kamu gunakan. Gunakan `Shift + Return` untuk hanya menyalinnya ke clipboard, `Alt + Return` untuk membukanya, `Delete` untuk menghapusnya dari riwayat, dan `Shift + Delete` untuk menghapus seluruh riwayat.

 ![clipboard-history](images/clipboard-history.webp)

Kamu juga bisa mencari di riwayat hanya dengan mulai mengetik:

 ![clipboard-history-search](images/clipboard-history-search.webp)
