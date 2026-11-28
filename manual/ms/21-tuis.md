# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) ialah alternatif yang menyenangkan kepada sesuatu seperti aplikasi GitHub Desktop, dan ia berjalan di dalam terminal.

Anda boleh menjalankannya secara langsung, dengan pergi ke mana-mana direktori yang diuruskan oleh git dan menjalankan `lazygit`. Atau anda boleh menjalankannya di dalam Neovim di mana ia boleh dimulakan dengan `Space G G`.

Anda melompat antara anak tetingkap yang berbeza menggunakan `Tab`. Dalam anak tetingkap Files, anda memilih fail untuk staging menggunakan `Space`, dan kemudian anda boleh mencipta commit baharu menggunakan `c`. Anda boleh melihat semua arahan yang tersedia menggunakan `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) ialah pengurus sumber yang cantik yang menunjukkan penggunaan memori, CPU, cakera, dan rangkaian. Ia juga menyenaraikan semua proses aktif, dan membolehkan anda menguruskannya.

Omarchy memanggilnya Activity Monitor, dan anda memulakannya dari pelancar aplikasi atau dengan menekan `Super + Shift + T`. Ia dibuka sebagai tetingkap terapung, yang boleh anda jubinkan dengan `Super + T`.

## Herdr

[Herdr](https://herdr.dev) ialah pengurus ruang kerja terminal yang memberikan anda ruang kerja, tab, dan anak tetingkap, dan memastikan semuanya terus berjalan dalam sesi berterusan yang boleh anda tanggalkan dan kembali semula kemudian.

Anda memulakannya (atau menyambung semula ke sesi sedia ada anda) dari pelancar aplikasi atau dengan `Super + Ctrl + Return`. Omarchy membekalkan konfigurasi Herdr yang mencerminkan konfigurasi Tmuxnya, jadi kekunci awalan ialah `Ctrl + Space` di sini juga. Anda boleh menyemak semua ikatan kekunci dengan `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) menunjukkan maklumat sistem, seperti versi kernel, masa operasi, tema, CPU, memori, dan banyak lagi. Ia ialah pengganti kepada alat neofetch yang popular.

Omarchy telah membungkusnya sebagai _Sistem > Perihal_ dalam menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) ialah pemain muzik terminal retro yang diilhamkan oleh Winamp 2.x, lengkap dengan stesen radio terbina dalam untuk rentak lo-fi. Lancarkannya dengan `Super + Shift + Alt + M`, atau dari menu Omarchy di bawah _Aplikasi_. Tekan `?` untuk senarai penuh ikatan kekunci.

## Bagaimana pula dengan Wi-Fi dan Bluetooth?

Anda tidak akan menemui TUI untuk Wi-Fi dan Bluetooth — tugas-tugas itu milik shell Omarchy. Klik ikon Wi-Fi di bar atas (atau tekan `Super + Ctrl + N`) untuk melihat rangkaian dan menyambung, dan klik ikon Bluetooth (atau tekan `Super + Ctrl + B`) untuk memasangkan dan menyambungkan peranti. Lihat [rangkaian](35-networking.md) untuk kisah sepenuhnya.

## Menambah milik anda sendiri

Mana-mana program terminal boleh mendapat layanan aplikasi penuh. Pergi ke _Pasang > TUI_ dalam menu Omarchy (`Super + Space`), berikannya nama, arahan pelancaran, gaya tetingkap, dan ikon, dan ia akan muncul dalam pelancar aplikasi seperti mana-mana aplikasi lain. Anda boleh membuangnya semula di bawah _Buang > TUI_.
