# Papan Keratan Bersepadu & Sejarah

Biasanya di Linux, anda perlu gunakan `Ctrl + Shift + C/V` untuk salin dan tampal di terminal dan `Ctrl + C/V` untuk melakukannya di semua tempat lain. Itu sukar untuk dibiasakan bagi sesiapa yang tidak lahir dan membesar dengan Linux! Begitu juga dengan peralihan daripada super kepada ctrl, jika anda datang daripada Mac.

Omarchy menangani kedua-dua masalah ini dengan kekunci pintas papan keratan bersepadu yang berfungsi (hampir) di semua tempat. Kekunci tersebut ialah:

| Kekunci Pintas | Perintah |
| ------- | ----------- |
| Super + A | Pilih semua |
| Super + C | Salin |
| Super + X | Potong |
| Super + V | Tampal |
| Super + Ctrl + V | Sejarah papan keratan |

_Perlu diingat bahawa kebanyakan harness ejen akan menggunakan `Ctrl + V` untuk menampal imej, tetapi `Super + V` untuk menampal teks._

Gunakan `Super + A`, kemudian `Super + C` untuk menyalin semua dalam medan teks yang sedang difokuskan atau aplikasi lain yang menyokong `Ctrl + A`. Dalam terminal, `Ctrl + A` mengalihkan ke permulaan baris perintah dan bukannya memilih teksnya.

### Sejarah papan keratan

Sejarah papan keratan disediakan oleh shell Omarchy dan berfungsi untuk kedua-dua teks dan imej. Anda mencetuskannya dengan `Super + Ctrl + V`, pilih entri anda dengan return, dan ia kemudian akan diletakkan pada papan keratan, sedia untuk ditampal dengan `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

Anda juga boleh mencari dalam sejarah hanya dengan mula menaip:

 ![clipboard-history-search](images/clipboard-history-search.webp)
