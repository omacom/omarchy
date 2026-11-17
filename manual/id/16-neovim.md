# Neovim

[Neovim](https://neovim.io/) adalah implementasi modern dari [editor vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) yang diciptakan oleh Bill Joy jauh di tahun 1976. Ia adalah editor modal di mana mode sisipkan dan mode perintah dipisahkan, dan ia sedikit merupakan kekuatan super begitu Anda mempelajari bahkan hanya sebagian kecil dari set perintah tombol yang sangat dalam. Namun kurva belajarnya juga cukup curam!

Jika Anda benar-benar baru dalam penyuntingan bergaya vim, saya sarankan Anda melihat [seri Vim As Your Editor oleh ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) di YouTube. Itu akan mengajarkan Anda dasar-dasarnya. Ketahuilah bahwa tidak seperti editor arus utama yang lebih mirip, Anda akan membutuhkan waktu lebih lama untuk mendapatkan kemahiran dasar dengan vim. Namun begitu Anda melakukannya, hasilnya juga lebih besar.

Sekarang Neovim pada dasarnya dapat dikonfigurasi tanpa batas. Jika Anda benar-benar ingin gila, Anda dapat membuat konfigurasi Neovim Anda sendiri dari awal. Ada kursus bagus dari [Typecraft tentang menyiapkan Neovim dari awal](https://www.youtube.com/watch?v=zHTeCSVAFNY). Dan [ThePrimeagen juga memilikinya](https://www.youtube.com/watch?v=w7i4amO_zaE).

Namun Omarchy dikirim dengan penyiapan Neovim lengkap — paket `omarchy-nvim` — yang telah disetel dengan penuh kasih untuk menampilkan yang terbaik dari yang mungkin langsung dari kotak. Tanpa Anda harus menulis satu baris konfigurasi pun! Ia dibangun di atas [LazyVim](https://www.lazyvim.org/), distribusi plugin dan konfigurasi Neovim. Ia luar biasa.

## Dasar-dasar LazyVim

Seperti yang disebutkan, saya tidak akan mengajari Anda vim dalam pengantar singkat ini, tetapi saya dapat menunjukkan beberapa dasar LazyVim, dan cara berkeliling.

Pertama, Neovim memiliki ide tentang tombol pemimpin. Itu pada dasarnya adalah gerbang ke semua perintah. LazyVim telah mengaturnya ke `Space`. Jadi cukup tekan itu, tunggu sebentar, dan Anda akan melihat banyak opsi dijelaskan sebaris seperti ini:

Berikut adalah beberapa perintah dasar yang saya gunakan sepanjang waktu:

- `Space Space` - Temukan secara fuzzy berkas apa pun dalam direktori saat ini.
- `Space S G` - Cari semua berkas menggunakan grep dengan pratinjau.
- `Space E` - Alihkan pohon berkas aktif/mati.
- `Ctrl + W W` - Lompat dari pohon berkas ke editor dan kembali.
- `Shift + H` - Pindah kiri di antara tab yang terbuka (vim menyebutnya buffer).
- `Shift + L` - Pindah kanan di antara tab yang terbuka.
- `Space B D` - Tutup tab.
- `Space B O` - Tutup semua tab lain kecuali yang saat ini.
- `Space G G` - Luncurkan LazyGit dalam pane melayang dari direktori saat ini.
- `Space U W` - Alihkan bungkus lembut.

Saat Anda berada dalam pohon berkas (`Space E` untuk menampilkan, `Ctrl + W W` untuk melompat ke sana), Anda dapat menambahkan berkas baru dengan `a` atau direktori baru dengan `A`. Tekan `?` saat berada dalam pohon untuk melihat semua perintah.

Jika Anda ingin mempelajari bahasa vim dasar, saya telah menulis tentang [sintaks tiga bagian](https://world.hey.com/dhh/wonderful-vi-a1d034d3) dan cara melakukan gerakan kombo yang keren itu!

Anda dapat melihat semua perintah yang mungkin di [halaman Keymaps LazyVim](https://www.lazyvim.org/keymaps).

## Memulai Neovim

Anda dapat memulai Neovim menggunakan `Super + Shift + N` (binding meluncurkan editor bawaan Anda, yang adalah Neovim langsung dari kotak), tetapi biasanya lebih mudah mengemudikannya dari terminal dengan menavigasi ke direktori yang ingin Anda kerjakan dan mengetik `n`. `n` adalah alias untuk `nvim`, yang akan menggunakan direktori saat ini untuk membuka secara bawaan. Anda dapat membuka satu berkas dengan `n myfile.txt`.

## Menggunakan Neovim untuk edit sudo

Jika Anda perlu mengedit berkas yang hanya dapat Anda ubah sebagai pengguna super, Anda dapat menggunakan neovim dengan semua plugin Anda disiapkan dengan menjalankan `sudoedit /etc/sudoers.d/00-sudo-only-file`.
