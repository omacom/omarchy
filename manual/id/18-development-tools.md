# Alat Pengembangan

## Editor Alternatif

Omarchy menyertakan Plain sebagai editor default pada instalasi baru dan [Neovim](https://neovim.io/) yang sudah pra-instal, tetapi jika Anda menginginkan sesuatu yang sedikit lebih mainstream dan familiar, Anda bisa menjalankan Omarchy Menu (`Super + Space`) dan melihat opsi-opsi di bawah _Install > Editor_. Kami mencantumkan VSCode, Cursor, Zed, Sublime Text, Helix, Vim, dan Emacs di sana. Jika Anda tidak menemukan yang Anda cari, lihat _Install > Package_, dan periksa apakah itu ada dalam paket Arch (dan jika tidak, coba _Install > AUR_ untuk memeriksa AUR).

Editor `vi` asli juga tersedia langsung sejak awal. Jalankan `vi filename` untuk mengedit file di terminal.

Pencocokan tema ditawarkan untuk `VSCode`, `Cursor`, `VSCodium`, dan `Helix`.

Anda dapat mengatur editor default di seluruh sistem di bawah `Setup > Defaults > Editor`.

## Lingkungan

Omarchy mendukung penyiapan berbagai macam lingkungan pengembangan melalui bagian _Install > Development_ dari Omarchy Menu (`Super + Space`). Tentu saja Anda akan menemukan _Ruby on Rails_, tetapi juga ketiga runtime utama untuk JavaScript (Node.js, Bun, Deno), serta framework PHP populer seperti Laravel dan Symfony. Oh, dan ada juga Go, Rust, Python, Java, Elixir (dengan Phoenix), .NET, OCaml, Zig, Clojure, dan Scala. Pilihannya sangat luas!

Sebagian besar lingkungan ini dikelola oleh [Mise](https://mise.jdx.dev/). Ini adalah alat yang memungkinkan Anda menginstal dan menjalankan beberapa versi bahasa pemrograman pada mesin yang sama. Ini seperti rbenv atau rvm untuk Ruby atau virtualenv untuk Python, tetapi ini bekerja untuk berbagai lingkungan yang berbeda.

Untuk menginstal, misalnya, Ruby, Anda akan menjalankan `mise use -g ruby`, yang akan menginstal Ruby sekaligus mengaturnya sebagai default global. Atau, jika proyek Anda memiliki file .ruby-version, Anda cukup menjalankan `mise i` di root proyek tersebut.

## Alat CLI Pra-instal

`uv`, Node.js, dan `playwright-cli` (agar agen dapat mengendalikan browser, menggunakan Chrome yang terinstal) terinstal sebagai paket, dan `omarchy update` menjaganya tetap mutakhir bersama seluruh sistem. [Hunk](https://github.com/modem-dev/hunk) dan CLI GitHub, Basecamp, Cloudflare, dan HEY tinggal pilih di bawah _Install > CLI_, dan [agen coding](17-ai.md) di bawah _Install > AI > CLI_.

mise hanya mengelola runtime yang Anda siapkan dari _Install > Development_; Omarchy tidak menginstal apa pun melaluinya sendiri. Jalankan `omarchy update` untuk memperbaruinya bersama seluruh Omarchy; alias `mup` hanya memperbarui alat yang dikelola mise. Untuk menambahkan alat lain ke konfigurasi Anda sendiri, gunakan `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) hampir tidak perlu diperkenalkan lagi. Docker memungkinkan Anda menjalankan container yang terisolasi, dan Omarchy menginstal semua yang dibutuhkan untuk menjalankannya dengan baik, termasuk Docker itu sendiri dan [Docker Compose](https://docs.docker.com/compose/).

Secara default, pengguna Anda *tidak* termasuk dalam grup `docker`. Grup tersebut secara efektif adalah root tanpa kata sandi — apa pun di dalamnya dapat menjalankan `docker run -v /:/host` dan mengambil alih mesin — jadi satu skrip atau dependensi nakal yang berjalan sebagai Anda, jika tidak, hanya terpaut satu perintah dari root. Jadi di baris perintah Anda menjalankan Docker dengan `sudo` (`sudo docker ps`, `sudo docker compose up`), dan alat grafis yang berkomunikasi dengan daemon — Windows VM — meminta otorisasi saat membutuhkannya. Jika Anda menginginkan kembali kenyamanan pengaturan tanpa grup dan memahami komprominya, aktifkan dari **Setup > Security > Sudoless Docker** (atau jalankan `omarchy-setup-security-sudoless-docker`), yang akan menambahkan Anda ke grup `docker` setelah peringatan; kemudian `docker` biasa dan alias `d` berfungsi tanpa `sudo` lagi.

Anda dapat menyiapkan database umum untuk pengembangan lokal di Docker menggunakan _Install > Development > Docker DB_ di menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) adalah `gh`, untuk bekerja dengan repositori, issue, dan pull request dari terminal. _Setup > Git_ menginstalnya ketika Anda memilih untuk masuk ke GitHub di sana, atau instal secara terpisah dari _Install > CLI > GitHub_. Kemudian `gh repo clone org/repo` meng-clone sebuah repositori; jalankan `gh --help` untuk menjelajahi perintah-perintahnya.

[Lazygit](https://github.com/jesseduffield/lazygit) sudah pra-instal untuk bekerja dengan Git itu sendiri.
