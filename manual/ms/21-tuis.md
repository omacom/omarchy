# TUI

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) ialah alternatif yang menyenangkan kepada sesuatu seperti aplikasi GitHub Desktop, dan ia berjalan di dalam terminal.

Anda boleh menjalankannya terus, dengan pergi ke mana-mana direktori yang diuruskan oleh git dan menjalankan `lazygit`. Atau anda boleh menjalankannya di dalam Neovim di mana ia boleh dimulakan dengan `Space G G`.

Anda melompat antara anak tetingkap berbeza menggunakan `Tab`. Dalam anak tetingkap Files, anda memilih fail untuk staging menggunakan `Space`, dan kemudian anda boleh mencipta commit baharu menggunakan `c`. Anda boleh melihat semua perintah yang tersedia menggunakan `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) ialah pengurus sumber yang cantik yang menunjukkan penggunaan memori, CPU, cakera, dan rangkaian. Ia juga menyenaraikan semua proses aktif, dan membolehkan anda mengurusnya.

Omarchy memanggilnya Activity, dan anda memulakannya dengan menekan `Super + Ctrl + T`. Ia dibuka sebagai tetingkap terapung, yang boleh anda jubinkan dengan `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) ialah pengurus ruang kerja terminal yang memberikan anda ruang kerja, tab, dan anak tetingkap, dan memastikan semuanya berjalan dalam sesi berterusan yang boleh anda lepaskan dan kembali kemudian.

Anda memulakannya (atau menyambung semula ke sesi sedia ada anda) dengan `Super + Ctrl + Return`. Omarchy menyediakan konfigurasi Herdr yang mencerminkan konfigurasi Tmuxnya, jadi kekunci prefix adalah `Ctrl + Space` di sini juga. Anda boleh menyemak semua ikatan kekunci dengan `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) menunjukkan maklumat sistem, seperti versi kernel, uptime, tema, CPU, memori, dan banyak lagi. Ia ialah pengganti kepada alat neofetch yang popular.

Omarchy telah membungkusnya sebagai _Perihal_ dalam menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) ialah pemain muzik terminal retro yang diinspirasikan oleh Winamp 2.x, lengkap dengan stesen radio terbina untuk beat lo-fi. Lancarkannya dengan `Super + Shift + Alt + M`, atau daripada menu Omarchy di bawah _Aplikasi_. Tekan `?` untuk senarai ikatan kekunci penuh.

## Bagaimana dengan Wi-Fi dan Bluetooth?

Anda tidak akan jumpa TUI untuk Wi-Fi dan Bluetooth — kerja itu milik shell Omarchy. Klik ikon Wi-Fi di bar atas (atau tekan `Super + Ctrl + W`) untuk melihat rangkaian dan menyambung, dan klik ikon Bluetooth (atau tekan `Super + Ctrl + B`) untuk memasang dan menyambung peranti. Lihat [rangkaian](35-networking.md) untuk cerita penuh.

## Tambah milik anda sendiri

Mana-mana program terminal boleh mendapat layanan aplikasi penuh. Pergi ke _Pasang > TUI_ dalam menu Omarchy (`Super + Space`), beri nama, perintah lancaran, gaya tetingkap, dan ikon, dan ia akan muncul dalam pelancar aplikasi seperti aplikasi lain. Anda boleh membuangnya semula di bawah _Buang > TUI_.
