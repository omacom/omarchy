# Papan Klip Terpadu & Riwayat

Biasanya di Linux, kamu perlu `Ctrl + Shift + C/V` untuk menyalin dan menempel di terminal dan `Ctrl + C/V` untuk melakukannya di semua tempat lain. Itu sulit dibiasakan oleh siapa pun yang tidak lahir dan besar di Linux! Begitu juga perpindahan dari Super ke Ctrl, jika kamu datang dari Mac.

Omarchy mengatasi kedua masalah itu dengan tombol pintas papan klip terpadu yang berfungsi (hampir) di semua tempat. Tombol pintas tersebut adalah:

| Hotkey | Command |
| ------- | ----------- |
| Super + A | Pilih semua |
| Super + C | Salin |
| Super + X | Potong |
| Super + V | Tempel |
| Super + Ctrl + V | Riwayat papan klip |

_Perlu dicatat bahwa sebagian besar agent harness akan menggunakan `Ctrl + V` untuk menempel gambar, tetapi `Super + V` untuk menempel teks._

Gunakan `Super + A`, lalu `Super + C` untuk menyalin semua isi kolom teks yang sedang aktif atau aplikasi lain yang mendukung `Ctrl + A`. Di terminal, `Ctrl + A` akan berpindah ke awal baris perintah, bukan memilih teksnya.

### Riwayat papan klip

Riwayat papan klip disediakan oleh shell Omarchy dan berfungsi untuk teks maupun gambar. Kamu membukanya dengan `Super + Ctrl + V`, memilih entri dengan return, lalu entri tersebut akan ditempatkan di papan klip dan siap ditempel dengan `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

Kamu juga bisa mencari di riwayat hanya dengan mulai mengetik:

 ![clipboard-history-search](images/clipboard-history-search.webp)
