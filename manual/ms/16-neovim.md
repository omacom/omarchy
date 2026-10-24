# Neovim

[Neovim](https://neovim.io/) ialah pelaksanaan moden [penyunting vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) yang dicipta oleh Bill Joy jauh kembali pada tahun 1976. Ia ialah penyunting modal di mana mod sisip dan mod arahan dipisahkan, dan ia sedikit kuasa besar sebaik sahaja anda mempelajari walaupun hanya subset set arahan kekunci yang sangat mendalam. Tetapi ia juga keluk pembelajaran yang ketara!

Jika anda benar-benar baharu kepada penyuntingan gaya vim, saya cadangkan anda menyemak [siri Vim As Your Editor ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) di YouTube. Itu akan mengajar anda asasnya. Ketahui sahaja bahawa tidak seperti penyunting arus perdana yang lebih serupa, ia akan mengambil masa yang lebih lama untuk anda mendapat kemahiran asas dengan vim. Tetapi sebaik sahaja anda melakukannya, ganjarannya juga lebih besar.

Kini Neovim pada dasarnya boleh dikonfigurasikan tanpa had. Jika anda benar-benar mahu berlebih-lebihan, anda boleh mencipta konfigurasi Neovim anda sendiri dari awal. Terdapat kursus hebat dari [Typecraft mengenai menyediakan Neovim dari awal](https://www.youtube.com/watch?v=zHTeCSVAFNY). Dan [ThePrimeagen juga mempunyainya](https://www.youtube.com/watch?v=w7i4amO_zaE).

Tetapi Omarchy dihantar dengan persediaan Neovim yang lengkap — pakej `omarchy-nvim` — yang telah ditala dengan penuh kasih sayang untuk mempamerkan yang terbaik daripada apa yang mungkin di luar kotak. Tanpa anda perlu menulis sebaris konfigurasi pun! Ia dibina di atas [LazyVim](https://www.lazyvim.org/), edaran plugin dan konfigurasi Neovim. Ia hebat.

## Asas LazyVim

Seperti yang dinyatakan, saya tidak akan mengajar anda vim dalam pengenalan ringkas ini, tetapi saya boleh menunjukkan kepada anda beberapa asas LazyVim, dan cara untuk bergerak.

Pertama, Neovim mempunyai idea kekunci pemimpin. Itu pada dasarnya ialah gerbang ke semua arahan. LazyVim telah menetapkannya kepada `Space`. Jadi hanya tekannya, tunggu sesaat, dan anda akan melihat banyak pilihan diterangkan sebaris seperti ini:

Berikut ialah beberapa arahan asas yang saya gunakan sepanjang masa:

- `Space Space` - Cari kabur mana-mana fail dalam direktori semasa.
- `Space S G` - Cari semua fail menggunakan grep dengan pratonton.
- `Space E` - Togol pokok fail hidup/mati.
- `Ctrl + W W` - Lompat dari pokok fail ke penyunting dan kembali.
- `Shift + H` - Bergerak ke kiri antara tab yang terbuka (vim memanggilnya penimbal).
- `Shift + L` - Bergerak ke kanan antara tab yang terbuka.
- `Space B D` - Tutup tab.
- `Space B O` - Tutup semua tab lain kecuali yang semasa.
- `Space G G` - Lancarkan LazyGit dalam anak tetingkap terapung dari direktori semasa.
- `Space U W` - Togol balutan lembut.

Semasa anda berada dalam pokok fail (`Space E` untuk mendedahkan, `Ctrl + W W` untuk melompat ke sana), anda boleh menambah fail baharu dengan `a` atau direktori baharu dengan `A`. Tekan `?` semasa dalam pokok untuk melihat semua arahan.

Jika anda mahu mengambil bahasa vim asas, saya telah menulis mengenai [sintaks tiga bahagian](https://world.hey.com/dhh/wonderful-vi-a1d034d3) dan cara untuk melaksanakan gerakan kombo yang hebat itu!

Anda boleh melihat semua arahan yang mungkin pada [halaman LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Memulakan Neovim

Anda boleh memulakan Neovim menggunakan `Super + Shift + N` (ikatan melancarkan penyunting lalai anda, iaitu Neovim di luar kotak), tetapi biasanya lebih mudah untuk memandunya dari terminal dengan menavigasi ke direktori yang anda ingin bekerja padanya dan menaip `n`. `n` ialah alias untuk `nvim`, yang akan menggunakan direktori semasa untuk dibuka secara lalai. Anda boleh membuka satu fail dengan `n myfile.txt`.

## Menggunakan Neovim untuk suntingan sudo

Jika anda perlu menyunting fail yang anda hanya boleh tukar sebagai pengguna super, anda boleh menggunakan neovim dengan semua plugin anda disediakan dengan menjalankan `sudoedit /etc/sudoers.d/00-sudo-only-file`.
