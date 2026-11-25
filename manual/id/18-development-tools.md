# Alat Pengembangan

## Editor Alternatif

Omarchy dikirimkan dengan Plain sebagai editor default pada instalasi baru dan [Neovim](https://neovim.io/) yang sudah terpasang, tetapi jika Anda menginginkan sesuatu yang sedikit lebih umum dan familier, Anda dapat menjalankan Omarchy Menu (`Super + Space`) dan melihat opsi-opsi di bawah _Install > Editor_. Di sana kami mencantumkan VSCode, Cursor, Zed, Sublime Text, Helix, Vim, dan Emacs. Jika Anda tidak menemukan yang Anda cari, lihat _Install > Package_, dan periksa apakah itu ada dalam paket Arch (dan jika tidak, coba _Install > AUR_ untuk memeriksa AUR).

Editor `vi` asli juga tersedia langsung sejak awal. Jalankan `vi filename` untuk mengedit file di terminal.

Pencocokan tema ditawarkan untuk `VSCode`, `Cursor`, `VSCodium`, dan `Helix`.

Anda dapat mengatur editor default di seluruh sistem di bawah `Setup > Defaults > Editor`.

## Lingkungan

Omarchy mendukung penyiapan berbagai macam lingkungan pengembangan melalui bagian _Install > Development_ dari Omarchy Menu (`Super + Space`). Tentu saja Anda akan menemukan _Ruby on Rails_, tetapi juga ketiga runtime utama untuk JavaScript (Node.js, Bun, Deno), serta framework PHP populer seperti Laravel dan Symfony. Oh, dan ada juga Go, Rust, Python, Java, Elixir (dengan Phoenix), .NET, OCaml, Zig, Clojure, dan Scala. Pilihannya sangat luas!

Sebagian besar lingkungan ini dikelola oleh [Mise](https://mise.jdx.dev/). Ini adalah alat yang memungkinkan Anda memasang dan menjalankan beberapa versi bahasa pemrograman pada mesin yang sama. Ini seperti rbenv atau rvm untuk Ruby atau virtualenv untuk Python, tetapi bekerja untuk berbagai macam lingkungan yang berbeda.

Untuk memasang, misalnya, Ruby, Anda akan menjalankan `mise use -g ruby`, yang akan memasang Ruby sekaligus mengaturnya sebagai default global. Atau, jika proyek Anda memiliki file .ruby-version, Anda cukup menjalankan `mise i` di root proyek itu.

## Alat CLI yang Sudah Terpasang

`uv`, Node.js, dan `playwright-cli` (agar agen dapat mengendalikan browser, menggunakan Chrome yang terpasang) sudah terpasang sebagai paket, dan `omarchy update` menjaganya tetap mutakhir bersama bagian sistem lainnya. `ghui`, [Hunk](https://github.com/modem-dev/hunk), dan CLI Basecamp, Cloudflare, dan HEY hanya perlu dipilih di bawah _Install > CLI_, dan [agen pemrograman](17-ai.md) di bawah _Install > AI > CLI_.

mise hanya mengelola runtime yang Anda siapkan dari _Install > Development_; Omarchy tidak memasang apa pun melaluinya atas kemauannya sendiri. Jalankan `omarchy update` untuk memperbaruinya bersama bagian Omarchy lainnya; alias `mup` memperbarui alat yang dikelola mise saja. Untuk menambahkan alat lain ke konfigurasi Anda sendiri, gunakan `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) hampir tidak perlu diperkenalkan lagi. Docker memungkinkan Anda menjalankan container yang terisolasi, dan Omarchy memasang semua yang diperlukan untuk menjalankannya dengan baik, termasuk Docker itu sendiri dan [Docker Compose](https://docs.docker.com/compose/).

Secara default pengguna Anda *tidak* berada dalam grup `docker`. Grup itu secara efektif adalah root tanpa kata sandi — apa pun di dalamnya dapat menjalankan `docker run -v /:/host` dan mengambil alih mesin — jadi satu skrip atau dependensi nakal yang berjalan sebagai Anda hanya akan berjarak satu perintah dari root. Jadi di command line Anda menjalankan Docker dengan `sudo` (`sudo docker ps`, `sudo docker compose up`), dan alat grafis yang berkomunikasi dengan daemon — VM Windows — akan meminta otorisasi ketika membutuhkannya. Jika Anda menginginkan kembali kemudahan pengaturan tanpa grup dan memahami konsekuensinya, aktifkan dari **Setup > Security > Sudoless Docker** (atau jalankan `omarchy-setup-security-sudoless-docker`), yang menambahkan Anda ke grup `docker` setelah sebuah peringatan; kemudian `docker` biasa dan alias `d` bekerja tanpa `sudo` lagi.

Anda dapat menyiapkan database umum untuk pengembangan lokal di Docker menggunakan _Install > Development > Docker DB_ di menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) adalah `gh`, untuk bekerja dengan repository, issue, dan pull request dari terminal. _Setup > Git_ memasangnya ketika Anda memilih untuk masuk ke GitHub di sana, kemudian `gh repo clone org/repo` melakukan clone terhadap sebuah repository. Jalankan `gh --help` untuk menjelajahi perintah-perintahnya.

_Install > CLI > GitHub_ memasang GitHub CLI, `gh`, bersama dengan `ghui`, sebuah antarmuka terminal untuk pull request. [Lazygit](https://github.com/jesseduffield/lazygit) sudah terpasang untuk bekerja dengan Git itu sendiri.
