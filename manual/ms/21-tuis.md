# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) ialah alternatif yang menyeronokkan kepada sesuatu seperti aplikasi GitHub Desktop, dan ia berjalan di dalam terminal.

Anda boleh menjalankannya secara terus, dengan pergi ke mana-mana direktori yang diuruskan oleh git dan menjalankan `lazygit`. Atau anda boleh menjalankannya di dalam Neovim, di mana ia boleh dimulakan dengan `Space G G`.

Anda beralih antara anak tetingkap yang berbeza menggunakan `Tab`. Dalam anak tetingkap Files, anda memilih fail untuk staging menggunakan `Space`, dan kemudian anda boleh mencipta commit baharu menggunakan `c`. Anda boleh melihat semua perintah yang tersedia menggunakan `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) ialah pengurus sumber yang cantik yang menunjukkan penggunaan memori, CPU, cakera, dan rangkaian. Ia juga menyenaraikan semua proses aktif, dan membolehkan anda mengurusnya.

Omarchy memanggilnya Activity Monitor, dan anda memulakannya daripada pelancar aplikasi atau dengan menekan `Super + Shift + T`. Ia dibuka sebagai tetingkap terapung, yang boleh anda susun secara jubin dengan `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) ialah pengurus ruang kerja terminal yang memberikan anda ruang kerja, tab, dan anak tetingkap, serta memastikan semuanya terus berjalan dalam sesi berterusan yang boleh anda tanggalkan dan kembali semula kemudian.

Anda memulakannya (atau menyambung semula ke sesi sedia ada anda) daripada pelancar aplikasi atau dengan `Super + Ctrl + Return`. Omarchy menyertakan konfigurasi Herdr yang mencerminkan konfigurasi Tmux-nya, jadi kekunci awalan di sini juga ialah `Ctrl + Space`. Anda boleh menyemak imbas semua ikatan kekunci dengan `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) menunjukkan maklumat sistem, seperti versi kernel, masa operasi, tema, CPU, memori, dan banyak lagi. Ia ialah pengganti kepada alat neofetch yang popular.

Omarchy telah membungkusnya sebagai _About_ dalam menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) ialah pemain muzik terminal retro yang diinspirasikan oleh Winamp 2.x, lengkap dengan stesen radio terbina dalam untuk rentak lo-fi. Lancarkannya dengan `Super + Shift + Alt + M`, atau daripada menu Omarchy di bawah _Apps_. Tekan `?` untuk senarai penuh ikatan kekunci.

## Bagaimana pula dengan Wi-Fi dan Bluetooth?

Anda tidak akan menemui TUI untuk Wi-Fi dan Bluetooth — tugas tersebut adalah milik shell Omarchy. Klik ikon Wi-Fi pada bar atas (atau tekan `Super + Ctrl + N`) untuk melihat rangkaian dan menyambung, dan klik ikon Bluetooth (atau tekan `Super + Ctrl + B`) untuk memasangkan dan menyambungkan peranti. Lihat [rangkaian](35-networking.md) untuk cerita penuh.

## Menambah TUI anda sendiri

Mana-mana program terminal boleh mendapat layanan aplikasi yang penuh. Pergi ke _Install > TUI_ dalam menu Omarchy (`Super + Space`), berikan nama, perintah pelancaran, gaya tetingkap, dan ikon, dan ia akan muncul dalam pelancar aplikasi seperti mana-mana aplikasi lain. Anda boleh membuangnya semula di bawah _Remove > TUI_.
