# Alat Pengembangan

## Editor Alternatif

Omarchy dilengkapi dengan [Neovim](https://neovim.io/) secara bawaan, tetapi jika kamu menginginkan sesuatu yang sedikit lebih umum dan familier, kamu dapat menjalankan Menu Omarchy (`Super + Space`) dan melihat pilihan di bawah _Pasang > Editor_. Kami menyediakan VSCode, Cursor, Zed, Sublime Text, Helix, Vim, dan Emacs di sana. Jika kamu tidak menemukan yang kamu cari, lihat _Pasang > Package_, dan lihat apakah itu tersedia dalam paket Arch (dan jika tidak, coba _Pasang > AUR_ untuk memeriksa AUR).

Editor `vi` asli juga tersedia langsung. Jalankan `vi filename` untuk mengedit berkas di terminal.

Pencocokan tema ditawarkan untuk `VSCode`, `Cursor`, `VSCodium`, dan `Helix`.

Kamu dapat mengatur editor bawaan di seluruh sistem di bawah `Pengaturan > Defaults > Editor`.

## Lingkungan

Omarchy mendukung penyiapan berbagai macam lingkungan pengembangan melalui bagian _Pasang > Development_ pada Menu Omarchy (`Super + Space`). Kamu tentu saja akan menemukan _Ruby on Rails_, tetapi juga ketiga runtime utama untuk JavaScript (Node.js, Bun, Deno), serta framework PHP populer seperti Laravel dan Symfony. Oh, dan ada juga Go, Rust, Python, Java, Elixir (dengan Phoenix), .NET, OCaml, Zig, Clojure, dan Scala. Pilihannya sangat luas!

Sebagian besar lingkungan ini dikelola oleh [Mise](https://mise.jdx.dev/). Ini adalah alat yang memungkinkan kamu memasang dan menjalankan beberapa versi bahasa pemrograman di mesin yang sama. Ini seperti rbenv atau rvm untuk Ruby atau virtualenv untuk Python, tetapi bekerja untuk bermacam-macam lingkungan yang berbeda.

Untuk memasang, misalnya, Ruby, kamu menjalankan `mise use -g ruby`, yang akan memasang Ruby sekaligus mengaturnya sebagai bawaan global. Atau, jika proyekmu memiliki berkas .ruby-version, kamu cukup menjalankan `mise i` di akar proyek tersebut.

## Docker

[Docker](https://www.docker.com/) hampir tidak perlu pengenalan. Ini memungkinkan kamu menjalankan kontainer yang terisolasi, dan Omarchy memasang semua yang dibutuhkan untuk menjalankannya dengan baik, termasuk Docker itu sendiri dan [Docker Compose](https://docs.docker.com/compose/).

Secara bawaan penggunamu *tidak* berada dalam grup `docker`. Grup tersebut secara efektif adalah root tanpa kata sandi — apa pun di dalamnya dapat menjalankan `docker run -v /:/host` dan mengambil alih mesin — jadi satu skrip atau dependensi nakal yang berjalan sebagai dirimu hanya berjarak satu perintah dari root. Jadi di baris perintah kamu menjalankan Docker dengan `sudo` (`sudo docker ps`, `sudo docker compose up`), dan alat grafis yang berbicara ke daemon — Windows VM — meminta otorisasi saat membutuhkannya. Jika kamu menginginkan kenyamanan penyiapan tanpa grup kembali dan memahami konsekuensinya, aktifkan dari **Pengaturan > Security > Sudoless Docker** (atau jalankan `omarchy-setup-security-sudoless-docker`), yang menambahkan kamu ke grup `docker` setelah peringatan; kemudian `docker` biasa dan alias `d` bekerja tanpa `sudo` lagi.

Kamu dapat menyiapkan basis data umum untuk pengembangan lokal di Docker menggunakan _Pasang > Development > Docker DB_ di menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) memungkinkan kamu mengautentikasi dengan akun GitHub-mu dan mengklon repositori privat menggunakan itu. Ini terhubung sebagai salah satu stub mise yang dimuat secara malas, jadi pertama kali kamu menjalankan `gh`, itu memasang dirinya sendiri. Untuk mengautentikasi, jalankan `gh auth login`. Kemudian kamu dapat melakukan checkout repositori privat menggunakan `gh repo clone org/repo`.

Kamu juga dapat melakukan berbagai operasi GitHub lainnya menggunakan perintah ini. Cukup jalankan `gh` untuk melihat semua yang mungkin.

Ada juga stub yang memasang secara malas untuk `ghui` untuk mengelola pull request-mu dalam TUI. Dan [lazygit](https://github.com/jesseduffield/lazygit) sudah terpasang, jika kamu ingin menjalankan git itu sendiri dari TUI juga.
