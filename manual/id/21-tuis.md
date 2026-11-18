# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) adalah alternatif yang menyenangkan untuk aplikasi seperti GitHub Desktop, dan ia berjalan di dalam terminal.

Kamu bisa menjalankannya langsung dengan membuka direktori mana pun yang dikelola oleh git dan menjalankan `lazygit`. Atau kamu bisa menjalankannya di dalam Neovim, tempat ia bisa dimulai dengan `Space G G`.

Kamu berpindah antar panel yang berbeda menggunakan `Tab`. Di panel Files, kamu memilih file untuk staging menggunakan `Space`, lalu kamu bisa membuat commit baru menggunakan `c`. Kamu bisa melihat semua perintah yang tersedia menggunakan `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) adalah manajer sumber daya yang indah yang menampilkan penggunaan memori, CPU, disk, dan jaringan. Ia juga mencantumkan semua proses aktif, dan memungkinkanmu untuk mengelolanya.

Omarchy menyebutnya Activity Monitor, dan kamu memulainya dari peluncur aplikasi atau dengan menekan `Super + Shift + T`. Ia terbuka sebagai jendela mengambang, yang bisa kamu ubah menjadi tile dengan `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) adalah manajer workspace terminal yang memberimu workspace, tab, dan panel, serta menjaga semuanya tetap berjalan dalam sesi persisten yang bisa kamu lepas dan kembali lagi nanti.

Kamu memulainya (atau menyambung kembali ke sesi yang sudah ada) dari peluncur aplikasi atau dengan `Super + Ctrl + Return`. Omarchy menyertakan konfigurasi Herdr yang mencerminkan konfigurasi Tmux-nya, jadi tombol prefix-nya juga `Ctrl + Space` di sini. Kamu bisa menelusuri semua keybinding dengan `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) menampilkan informasi sistem, seperti versi kernel, uptime, tema, CPU, memori, dan lainnya. Ini adalah penerus dari tool neofetch yang populer.

Omarchy telah mengemas ini sebagai _About_ di menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) adalah pemutar musik terminal retro yang terinspirasi oleh Winamp 2.x, lengkap dengan stasiun radio bawaan untuk lo-fi beats. Jalankan dengan `Super + Shift + Alt + M`, atau dari menu Omarchy di bawah _Apps_. Tekan `?` untuk daftar keybinding lengkap.

## Bagaimana dengan Wi-Fi dan Bluetooth?

Kamu tidak akan menemukan TUI untuk Wi-Fi dan Bluetooth — pekerjaan itu adalah urusan shell Omarchy. Klik ikon Wi-Fi di bilah atas (atau tekan `Super + Ctrl + N`) untuk melihat jaringan dan terhubung, dan klik ikon Bluetooth (atau tekan `Super + Ctrl + B`) untuk memasangkan dan menghubungkan perangkat. Lihat [jaringan](35-networking.md) untuk cerita lengkapnya.

## Menambahkan milikmu sendiri

Program terminal apa pun bisa mendapatkan perlakuan aplikasi penuh. Buka _Install > TUI_ di menu Omarchy (`Super + Space`), beri nama, perintah peluncuran, gaya jendela, dan ikon, dan ia akan muncul di peluncur aplikasi seperti aplikasi lainnya. Kamu bisa menghapusnya lagi di bawah _Remove > TUI_.
