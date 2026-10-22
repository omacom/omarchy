# TUI

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) adalah alternatif yang menyenangkan untuk sesuatu seperti aplikasi GitHub Desktop, dan berjalan di dalam terminal.

Kamu dapat menjalankannya secara langsung, dengan pergi ke direktori mana pun yang dikelola oleh git dan menjalankan `lazygit`. Atau kamu dapat menjalankannya di dalam Neovim di mana itu dapat dimulai dengan `Space G G`.

Kamu melompat di antara panel yang berbeda menggunakan `Tab`. Di panel Files, kamu memilih berkas untuk staging menggunakan `Space`, dan kemudian kamu dapat membuat commit baru menggunakan `c`. Kamu dapat melihat semua perintah yang tersedia menggunakan `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) adalah manajer sumber daya yang indah yang menunjukkan penggunaan memori, CPU, disk, dan jaringan. Ini juga mencantumkan semua proses aktif, dan memungkinkan kamu mengelolanya.

Omarchy menyebutnya Activity, dan kamu memulainya dengan menekan `Super + Ctrl + T`. Ini terbuka sebagai jendela melayang, yang dapat kamu ubin dengan `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) adalah manajer ruang kerja terminal yang memberimu ruang kerja, tab, dan panel, dan membuat semuanya tetap berjalan dalam sesi persisten yang dapat kamu lepaskan dan kembali lagi nanti.

Kamu memulainya (atau menyambung kembali ke sesi yang ada) dengan `Super + Ctrl + Return`. Omarchy menyediakan konfigurasi Herdr yang mencerminkan konfigurasi Tmux-nya, jadi tombol prefix adalah `Ctrl + Space` di sini juga. Kamu dapat menelusuri semua pintasan tombol dengan `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) menunjukkan informasi sistem, seperti versi kernel, uptime, tema, CPU, memori, dan lainnya. Ini adalah penerus alat neofetch yang populer.

Omarchy telah mengemas ini sebagai _Tentang_ di menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) adalah pemutar musik terminal retro yang terinspirasi oleh Winamp 2.x, lengkap dengan stasiun radio bawaan untuk lo-fi beats. Luncurkan dengan `Super + Shift + Alt + M`, atau dari menu Omarchy di bawah _Aplikasi_. Tekan `?` untuk daftar pintasan tombol lengkap.

## Bagaimana dengan Wi-Fi dan Bluetooth?

Kamu tidak akan menemukan TUI untuk Wi-Fi dan Bluetooth — pekerjaan itu milik shell Omarchy. Klik ikon Wi-Fi di bilah atas (atau tekan `Super + Ctrl + W`) untuk melihat jaringan dan terhubung, dan klik ikon Bluetooth (atau tekan `Super + Ctrl + B`) untuk memasangkan dan menghubungkan perangkat. Lihat [jaringan](35-networking.md) untuk cerita lengkapnya.

## Menambahkan milikmu sendiri

Program terminal apa pun bisa mendapatkan perlakuan aplikasi penuh. Pergi ke _Pasang > TUI_ di menu Omarchy (`Super + Space`), beri nama, perintah peluncuran, gaya jendela, dan ikon, dan itu akan muncul di peluncur aplikasi seperti aplikasi lainnya. Kamu dapat menghapusnya lagi di bawah _Hapus > TUI_.
