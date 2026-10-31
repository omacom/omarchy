# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) adalah alternatif yang menyenangkan untuk sesuatu seperti aplikasi GitHub Desktop, dan ia berjalan di dalam terminal.

Kamu bisa menjalankannya secara langsung, dengan membuka direktori mana pun yang dikelola oleh git dan menjalankan `lazygit`. Atau kamu bisa menjalankannya di dalam Neovim, tempat ia bisa dimulai dengan `Space G G`.

Kamu berpindah di antara panel-panel yang berbeda menggunakan `Tab`. Di panel Files, kamu memilih file untuk staging menggunakan `Space`, lalu kamu bisa membuat commit baru menggunakan `c`. Kamu bisa melihat semua perintah yang tersedia menggunakan `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) adalah pengelola sumber daya yang cantik yang menampilkan penggunaan memori, CPU, disk, dan jaringan. Ia juga mencantumkan semua proses yang aktif, dan memungkinkanmu mengelolanya.

Omarchy menyebutnya Activity, dan kamu memulainya dengan menekan `Super + Shift + T`. Ia terbuka sebagai jendela mengambang, yang bisa kamu jadikan tile dengan `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) adalah pengelola workspace terminal yang memberimu workspace, tab, dan panel, serta membuat semuanya tetap berjalan dalam sesi persisten yang bisa kamu lepaskan dan kamu datangi lagi nanti.

Kamu memulainya (atau menyambung kembali ke sesimu yang sudah ada) dengan `Super + Ctrl + Return`. Omarchy menyertakan konfigurasi Herdr yang mencerminkan konfigurasi Tmux-nya, jadi tombol prefix-nya juga `Ctrl + Space` di sini. Kamu bisa menelusuri semua keybinding dengan `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) menampilkan informasi sistem, seperti versi kernel, uptime, tema, CPU, memori, dan banyak lagi. Ia adalah penerus alat neofetch yang populer.

Omarchy telah mengemasnya sebagai _About_ di menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) adalah pemutar musik terminal retro yang terinspirasi dari Winamp 2.x, lengkap dengan stasiun radio bawaan untuk lo-fi beats. Luncurkan dengan `Super + Shift + Alt + M`, atau dari menu Omarchy di bawah _Apps_. Tekan `?` untuk daftar keybinding lengkap.

## Bagaimana dengan Wi-Fi dan Bluetooth?

Kamu tidak akan menemukan TUI untuk Wi-Fi dan Bluetooth — tugas-tugas itu adalah urusan shell Omarchy. Klik ikon Wi-Fi di bilah atas (atau tekan `Super + Ctrl + N`) untuk melihat jaringan dan terhubung, dan klik ikon Bluetooth (atau tekan `Super + Ctrl + B`) untuk memasangkan dan menghubungkan perangkat. Lihat [jaringan](35-networking.md) untuk cerita lengkapnya.

## Menambahkan milikmu sendiri

Program terminal apa pun bisa mendapatkan perlakuan aplikasi sepenuhnya. Buka _Install > TUI_ di menu Omarchy (`Super + Space`), beri ia nama, perintah peluncuran, gaya jendela, dan ikon, dan ia akan muncul di peluncur aplikasi seperti aplikasi lainnya. Kamu bisa menghapusnya lagi di bawah _Remove > TUI_.
