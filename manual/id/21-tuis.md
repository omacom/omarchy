# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) adalah alternatif yang menyenangkan untuk sesuatu seperti aplikasi GitHub Desktop, dan aplikasi ini berjalan di dalam terminal.

Anda dapat menjalankannya secara langsung, dengan masuk ke direktori mana pun yang dikelola oleh git dan menjalankan `lazygit`. Atau Anda dapat menjalankannya di dalam Neovim, di mana ia dapat dimulai dengan `Space G G`.

Anda berpindah-pindah di antara panel yang berbeda menggunakan `Tab`. Di panel Files, Anda memilih file untuk staging menggunakan `Space`, lalu Anda dapat membuat commit baru menggunakan `c`. Anda dapat melihat semua perintah yang tersedia menggunakan `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) adalah manajer sumber daya yang indah yang menampilkan penggunaan memori, CPU, disk, dan jaringan. Ia juga mencantumkan semua proses yang aktif, dan memungkinkan Anda mengelolanya.

Omarchy menyebutnya Activity Monitor, dan Anda memulainya dari peluncur aplikasi atau dengan menekan `Super + Shift + T`. Ia terbuka sebagai jendela mengambang, yang dapat Anda jadikan tile dengan `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) adalah manajer ruang kerja terminal yang memberi Anda ruang kerja, tab, dan panel, serta menjaga semuanya tetap berjalan dalam sesi persisten yang dapat Anda lepaskan dan kembali lagi nanti.

Anda memulainya (atau menyambung kembali ke sesi Anda yang sudah ada) dari peluncur aplikasi atau dengan `Super + Ctrl + Return`. Omarchy menyertakan konfigurasi Herdr yang mencerminkan konfigurasi Tmux-nya, jadi tombol prefix-nya juga `Ctrl + Space` di sini. Anda dapat menelusuri semua keybinding dengan `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) menampilkan informasi sistem, seperti versi kernel, uptime, tema, CPU, memori, dan lainnya. Ini adalah penerus alat neofetch yang populer.

Omarchy telah mengemasnya sebagai _System > About_ di menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) adalah pemutar musik terminal retro yang terinspirasi oleh Winamp 2.x, lengkap dengan stasiun radio bawaan untuk lo-fi beats. Luncurkan dengan `Super + Shift + Alt + M`, atau dari menu Omarchy di bawah _Apps_. Tekan `?` untuk daftar keybinding lengkap.

## Bagaimana dengan Wi-Fi dan Bluetooth?

Anda tidak akan menemukan TUI untuk Wi-Fi dan Bluetooth — pekerjaan itu adalah milik shell Omarchy. Klik ikon Wi-Fi di bilah atas (atau tekan `Super + Ctrl + N`) untuk melihat jaringan dan terhubung, dan klik ikon Bluetooth (atau tekan `Super + Ctrl + B`) untuk memasangkan dan menghubungkan perangkat. Lihat [jaringan](35-networking.md) untuk cerita lengkapnya.

## Menambahkan milik Anda sendiri

Program terminal apa pun dapat mendapatkan perlakuan aplikasi sepenuhnya. Buka _Install > TUI_ di menu Omarchy (`Super + Space`), beri nama, perintah peluncuran, gaya jendela, dan ikon, dan ia akan muncul di peluncur aplikasi seperti aplikasi lainnya. Anda dapat menghapusnya lagi di bawah _Remove > TUI_.
