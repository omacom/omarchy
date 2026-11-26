# Papan Klip Terpadu & Sejarah

Biasanya pada Linux, anda perlu `Ctrl + Shift + C/V` untuk menyalin dan menampal dalam terminal dan `Ctrl + C/V` untuk melakukannya di semua tempat lain. Itu sukar untuk dibiasakan bagi sesiapa yang tidak dilahirkan dan dibesarkan dengan Linux! Begitu juga dengan peralihan daripada super kepada ctrl, jika anda datang daripada Mac.

Omarchy menangani kedua-dua masalah ini dengan kekunci pintas papan klip terpadu yang berfungsi (hampir) di mana-mana. Kekunci tersebut ialah:

| Kekunci Pintas | Perintah |
| ------- | ----------- |
| Super + A | Pilih semua |
| Super + C | Salin |
| Super + X | Potong |
| Super + V | Tampal |
| Super + Ctrl + V | Sejarah papan klip |

_Nota bahawa kebanyakan harness ejen akan menggunakan `Ctrl + V` untuk menampal imej, tetapi `Super + V` untuk menampal teks._

Gunakan `Super + A`, kemudian `Super + C` untuk menyalin semua dalam medan teks yang difokuskan atau aplikasi lain yang menyokong `Ctrl + A`. Dalam terminal, `Ctrl + A` bergerak ke permulaan baris perintah dan bukannya memilih teksnya.

### Sejarah papan klip

Sejarah papan klip disediakan oleh shell Omarchy dan berfungsi untuk kedua-dua teks dan imej. Anda mencetuskannya dengan `Super + Ctrl + V` dan memilih entri anda dengan return, yang menampalnya terus ke dalam aplikasi yang anda gunakan. Gunakan `Shift + Return` untuk hanya menyalinnya ke papan klip, `Alt + Return` untuk membukanya, `Delete` untuk mengalih keluarnya daripada sejarah, dan `Shift + Delete` untuk mengosongkan keseluruhan sejarah.

 ![clipboard-history](images/clipboard-history.webp)

Anda juga boleh mencari sejarah hanya dengan mula menaip:

 ![clipboard-history-search](images/clipboard-history-search.webp)
