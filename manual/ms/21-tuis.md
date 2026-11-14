# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) ialah alternatif yang menyenangkan kepada sesuatu seperti aplikasi GitHub Desktop, dan ia berjalan di dalam terminal.

Anda boleh menjalankannya secara langsung, dengan pergi ke mana-mana direktori yang diurus oleh git dan menjalankan `lazygit`. Atau anda boleh menjalankannya di dalam Neovim di mana ia boleh dimulakan dengan `Space G G`.

Anda melompat antara panel yang berbeza menggunakan `Tab`. Dalam panel Files, anda memilih fail untuk staging menggunakan `Space`, dan kemudian anda boleh mencipta commit baharu menggunakan `c`. Anda boleh melihat semua perintah yang tersedia menggunakan `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) ialah pengurus sumber yang cantik yang menunjukkan penggunaan memori, CPU, cakera, dan rangkaian. Ia juga menyenaraikan semua proses aktif, dan membenarkan anda mengurusnya.

Omarchy memanggilnya Activity Monitor, dan anda memulakannya dari pelancar aplikasi atau dengan menekan `Super + Shift + T`. Ia dibuka sebagai tetingkap terapung, yang anda boleh jadikan berjubin dengan `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) ialah pengurus ruang kerja terminal yang memberikan anda ruang kerja, tab, dan panel, dan memastikan semuanya terus berjalan dalam sesi berterusan yang boleh anda putuskan daripada sesi itu dan kembali kepadanya kemudian.

Anda memulakannya (atau menyambung semula ke sesi sedia ada anda) dengan `Super + Ctrl + Return`. Omarchy menyertakan konfigurasi Herdr yang mencerminkan konfigurasi Tmux miliknya, jadi kekunci awalan ialah `Ctrl + Space` di sini juga. Anda boleh menyemak semua ikatan kekunci dengan `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) menunjukkan maklumat sistem, seperti versi kernel, masa operasi, tema, CPU, memori, dan banyak lagi. Ia ialah pengganti kepada alat neofetch yang popular.

Omarchy telah membungkus ini sebagai _Perihal_ dalam menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) ialah pemain muzik terminal retro yang diilhamkan oleh Winamp 2.x, lengkap dengan stesen radio terbina dalam untuk beat lo-fi. Lancarkannya dengan `Super + Shift + Alt + M`, atau dari menu Omarchy di bawah _Aplikasi_. Tekan `?` untuk senarai penuh ikatan kekunci.

## Bagaimana pula dengan Wi-Fi dan Bluetooth?

Anda tidak akan menemui TUI untuk Wi-Fi dan Bluetooth — tugas-tugas itu milik shell Omarchy. Klik ikon Wi-Fi di bar atas (atau tekan `Super + Ctrl + N`) untuk melihat rangkaian dan menyambung, dan klik ikon Bluetooth (atau tekan `Super + Ctrl + B`) untuk memasangkan dan menyambungkan peranti. Lihat [rangkaian](35-networking.md) untuk kisah penuhnya.

## Menambah TUI anda sendiri

Mana-mana program terminal boleh mendapat layanan penuh sebagai aplikasi. Pergi ke _Pasang > TUI_ dalam menu Omarchy (`Super + Space`), berikan ia nama, perintah pelancaran, gaya tetingkap, dan ikon, dan ia akan muncul dalam pelancar aplikasi seperti mana-mana aplikasi lain. Anda boleh membuangnya semula di bawah _Buang > TUI_.
