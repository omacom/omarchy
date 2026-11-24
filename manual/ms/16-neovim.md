# Neovim

[Neovim](https://neovim.io/) ialah pelaksanaan moden bagi [editor vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) yang dicipta oleh Bill Joy sejak tahun 1976 lagi. Ia ialah editor modal yang mod sisip dan mod perintahnya diasingkan, dan ia agak seperti kuasa besar sebaik sahaja anda mempelajari walaupun hanya sebahagian daripada set perintah kekunci yang amat mendalam itu. Tetapi lengkung pembelajarannya juga agak curam!

Jika anda benar-benar baharu dengan penyuntingan gaya vim, saya cadangkan anda menonton siri [ThePrimeagen's Vim As Your Editor](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) di YouTube. Siri itu akan mengajar anda asasnya. Cuma ketahuilah bahawa berbanding editor arus perdana yang lebih serupa, anda akan mengambil masa yang lebih lama untuk mencapai kemahiran asas dengan vim. Tetapi sebaik sahaja anda mencapainya, ganjarannya juga lebih besar.

Kini Neovim pada asasnya boleh dikonfigurasikan tanpa had. Jika anda benar-benar mahu menjadi gila, anda boleh mencipta konfigurasi Neovim anda sendiri dari awal. Terdapat kursus yang hebat daripada [Typecraft tentang menyediakan Neovim dari awal](https://www.youtube.com/watch?v=zHTeCSVAFNY). Dan [ThePrimeagen juga mempunyai satu](https://www.youtube.com/watch?v=w7i4amO_zaE).

Tetapi Omarchy disertakan dengan persediaan Neovim yang lengkap — pakej `omarchy-nvim` — yang telah ditala dengan penuh teliti untuk mempamerkan yang terbaik daripada apa yang mungkin serta-merta. Tanpa anda perlu menulis sebaris konfigurasi pun! Ia dibina berasaskan [LazyVim](https://www.lazyvim.org/), sebuah pengedaran plugin dan konfigurasi Neovim. Ia sungguh hebat.

## Asas LazyVim

Seperti yang dinyatakan, saya tidak akan mengajar anda vim dalam pengenalan ringkas ini, tetapi saya boleh menunjukkan kepada anda beberapa asas LazyVim, dan cara untuk bergerak di dalamnya.

Pertama, Neovim mempunyai konsep kekunci leader. Itu pada asasnya ialah pintu masuk kepada semua perintah. LazyVim telah menetapkannya kepada `Space`. Jadi tekan sahaja kekunci itu, tunggu sebentar, dan anda akan melihat sekumpulan pilihan diterangkan sebaris seperti ini:

Berikut ialah beberapa perintah asas yang saya gunakan sepanjang masa:

- `Space Space` - Cari mana-mana fail secara kabur dalam direktori semasa.
- `Space S G` - Cari semua fail menggunakan grep dengan pratonton.
- `Space E` - Togol pokok fail hidup/mati.
- `Ctrl + W W` - Lompat dari pokok fail ke editor dan kembali semula.
- `Shift + H` - Bergerak ke kiri antara tab yang terbuka (vim memanggilnya buffers).
- `Shift + L` - Bergerak ke kanan antara tab yang terbuka.
- `Space B D` - Tutup satu tab.
- `Space B O` - Tutup semua tab lain kecuali tab semasa.
- `Space G G` - Lancarkan LazyGit dalam anak tetingkap terapung dari direktori semasa.
- `Space U W` - Togol balut lembut.

Semasa anda berada dalam pokok fail (`Space E` untuk memaparkannya, `Ctrl + W W` untuk melompat ke sana), anda boleh menambah fail baharu dengan `a` atau direktori baharu dengan `A`. Tekan `?` semasa berada dalam pokok itu untuk melihat semua perintah.

Jika anda mahu mempelajari bahasa asas vim, saya telah menulis tentang [sintaks tiga bahagian](https://world.hey.com/dhh/wonderful-vi-a1d034d3) dan cara untuk melakukan gerakan kombo yang hebat itu!

Anda boleh melihat semua perintah yang mungkin pada [halaman LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Memulakan Neovim

`Super + Shift + N` melancarkan editor lalai anda, iaitu Plain pada pemasangan baharu; pilih Neovim di bawah _Setup > Defaults > Editor_ supaya ia melancarkan Neovim sebaliknya. Tetapi biasanya lebih mudah untuk mengendalikannya dari terminal dengan menavigasi ke direktori yang anda mahu gunakan dan menaip `n`. `n` ialah alias untuk `nvim`, yang akan menggunakan direktori semasa untuk dibuka secara lalai. Anda boleh membuka satu fail dengan `n myfile.txt`.

## Menggunakan Neovim untuk suntingan sudo

Jika anda perlu menyunting fail yang hanya boleh anda ubah sebagai pengguna super, jalankan `sudoedit /etc/sudoers.d/00-sudo-only-file`. Ia membuka editor lalai anda, jadi tetapkan Neovim di bawah _Setup > Defaults > Editor_ jika anda mahukannya di sana dengan semua plugin anda.
