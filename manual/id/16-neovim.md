# Neovim

[Neovim](https://neovim.io/) adalah implementasi modern dari [editor vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) yang dibuat oleh Bill Joy jauh di tahun 1976. Ini adalah editor modal di mana mode insert dan mode command terpisah, dan ini semacam kekuatan super begitu kamu mempelajari bahkan hanya sebagian dari rangkaian perintah tombol yang luar biasa mendalam itu. Tapi kurva pembelajarannya juga cukup curam!

Kalau kamu benar-benar baru dalam pengeditan gaya vim, aku merekomendasikan kamu menonton [seri Vim As Your Editor dari ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) di YouTube. Seri itu akan mengajarkan dasar-dasarnya kepadamu. Perlu diketahui, tidak seperti editor mainstream yang lebih umum, kamu akan butuh waktu lebih lama untuk mencapai kemahiran dasar dengan vim. Tapi begitu kamu mencapainya, hasilnya juga lebih besar.

Nah, Neovim pada dasarnya bisa dikonfigurasi tanpa batas. Kalau kamu benar-benar ingin menggila, kamu bisa membuat konfigurasi Neovim-mu sendiri dari nol. Ada kursus hebat dari [Typecraft tentang menyiapkan Neovim dari nol](https://www.youtube.com/watch?v=zHTeCSVAFNY). Dan [ThePrimeagen juga punya satu](https://www.youtube.com/watch?v=w7i4amO_zaE).

Tapi Omarchy disertai dengan setup Neovim yang lengkap — paket `omarchy-nvim` — yang telah disetel dengan penuh cinta untuk menampilkan yang terbaik dari apa yang mungkin, langsung sejak pertama pakai. Tanpa kamu harus menulis satu baris konfigurasi pun! Setup ini dibangun di atas [LazyVim](https://www.lazyvim.org/), sebuah distribusi plugin dan konfigurasi Neovim. Keren sekali.

## Dasar-Dasar LazyVim

Seperti yang sudah kusebutkan, aku tidak akan mengajarkan vim kepadamu dalam pengantar singkat ini, tetapi aku bisa menunjukkan beberapa dasar LazyVim, dan cara menjelajahinya.

Pertama, Neovim punya konsep tombol leader. Itu pada dasarnya adalah gerbang menuju semua perintah. LazyVim telah mengaturnya ke `Space`. Jadi tekan saja tombol itu, tunggu sebentar, dan kamu akan melihat sekumpulan opsi yang dijelaskan secara inline seperti ini:

Berikut beberapa perintah dasar yang selalu kupakai:

- `Space Space` - Cari file apa pun di direktori saat ini secara fuzzy.
- `Space S G` - Cari di semua file menggunakan grep dengan pratinjau.
- `Space E` - Tampilkan/sembunyikan pohon file.
- `Ctrl + W W` - Loncat dari pohon file ke editor dan kembali.
- `Shift + H` - Pindah ke kiri antar tab yang terbuka (vim menyebutnya buffer).
- `Shift + L` - Pindah ke kanan antar tab yang terbuka.
- `Space B D` - Tutup sebuah tab.
- `Space B O` - Tutup semua tab lain kecuali tab saat ini.
- `Space G G` - Jalankan LazyGit di panel mengambang dari direktori saat ini.
- `Space U W` - Aktifkan/nonaktifkan soft wrap.

Selagi kamu berada di pohon file (`Space E` untuk menampilkannya, `Ctrl + W W` untuk loncat ke sana), kamu bisa menambahkan file baru dengan `a` atau direktori baru dengan `A`. Tekan `?` selagi berada di pohon file untuk melihat semua perintah.

Kalau kamu ingin mempelajari bahasa dasar vim, aku sudah menulis tentang [sintaks tiga bagian](https://world.hey.com/dhh/wonderful-vi-a1d034d3) dan cara melakukan gerakan kombo keren itu!

Kamu bisa melihat semua perintah yang mungkin di [halaman Keymaps LazyVim](https://www.lazyvim.org/keymaps).

## Memulai Neovim

`Super + Shift + N` menjalankan editor default-mu, yaitu Plain pada instalasi baru; pilih Neovim di _Setup > Defaults > Editor_ agar tombol itu menjalankan Neovim sebagai gantinya. Tapi biasanya lebih mudah menjalankannya dari terminal dengan berpindah ke direktori tempat kamu ingin bekerja dan mengetik `n`. `n` adalah alias untuk `nvim`, yang secara default akan menggunakan direktori saat ini untuk dibuka. Kamu bisa membuka satu file dengan `n myfile.txt`.

## Menggunakan Neovim untuk Pengeditan sudo

Jika kamu perlu mengedit file yang hanya bisa kamu ubah sebagai super user, jalankan `sudoedit /etc/sudoers.d/00-sudo-only-file`. Perintah itu membuka editor default-mu, jadi atur Neovim di _Setup > Defaults > Editor_ jika kamu ingin Neovim di sana lengkap dengan semua plugin-mu.
