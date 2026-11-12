# Alat Pengembangan

## Editor Alternatif

Omarchy dilengkapi dengan [Neovim](https://neovim.io/) secara bawaan, tetapi jika Anda ingin sesuatu yang sedikit lebih umum dan familiar, Anda dapat menjalankan Menu Omarchy (`Super + Space`) dan melihat pilihan di bawah _Install > Editor_. Di sana kami menyediakan VSCode, Cursor, Zed, Sublime Text, Helix, Vim, dan Emacs. Jika Anda tidak menemukan yang Anda cari, lihat _Install > Package_, dan periksa apakah itu ada dalam sebuah paket Arch (dan jika tidak, coba _Install > AUR_ untuk memeriksa AUR).

Editor `vi` asli juga tersedia langsung. Jalankan `vi filename` untuk mengedit sebuah file di terminal.

Pencocokan tema ditawarkan untuk `VSCode`, `Cursor`, `VSCodium`, dan `Helix`.

Anda dapat mengatur editor bawaan di seluruh sistem di bawah `Setup > Defaults > Editor`.

## Lingkungan

Omarchy mendukung penyiapan segudang lingkungan pengembangan melalui bagian _Install > Development_ dari Menu Omarchy (`Super + Space`). Tentu saja Anda akan menemukan _Ruby on Rails_, tetapi juga ketiga runtime utama untuk JavaScript (Node.js, Bun, Deno), serta framework PHP populer seperti Laravel dan Symfony. Oh, dan ada juga Go, Rust, Python, Java, Elixir (dengan Phoenix), .NET, OCaml, Zig, Clojure, dan Scala. Pilihannya sangat luas!

Sebagian besar lingkungan ini dikelola oleh [Mise](https://mise.jdx.dev/). Ini adalah alat yang memungkinkan Anda menginstal dan menjalankan beberapa versi sebuah bahasa pemrograman di mesin yang sama. Ini seperti rbenv atau rvm untuk Ruby atau virtualenv untuk Python, tetapi ini bekerja untuk banyak lingkungan yang berbeda.

Untuk menginstal, misalnya, Ruby, Anda akan menjalankan `mise use -g ruby`, yang akan menginstal Ruby sekaligus mengaturnya sebagai bawaan global. Atau, jika proyek Anda memiliki file .ruby-version, Anda cukup menjalankan `mise i` di root proyek tersebut.

## Alat CLI yang Sudah Terinstal

Omarchy menyediakan alat seperti `gh`, `uv`, dan sebagian besar [agen coding](17-ai.md) melalui [instalasi lazy mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Pertama kali Anda menjalankan salah satunya, mise menginstalnya. Penggunaan berikutnya menggunakan kembali versi yang terinstal; mereka tidak memeriksa pembaruan pada setiap peluncuran.

Anda juga dapat memeriksa bawaannya atau menginstalnya lebih awal:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Jalankan `omarchy update` untuk memperbarui alat yang terinstal bersama bagian lain dari Omarchy. Alias `mup` hanya memperbarui alat yang dikelola mise. Untuk menambahkan alat lain ke konfigurasi Anda sendiri, gunakan `mise use -g <tool>`.

Penyiapan Python juga menginstal `uv` melalui mise. Menghapus lingkungan pengembangan Python tetap membuat `uv` tersedia sebagai alat independen.

### Menggunakan instalasi Anda sendiri

Perintah mise berada sebelum `~/.local/bin` di `PATH`, jadi alat yang Anda instal sendiri, misalnya dengan penginstal bawaan Claude Code atau Cursor, tetap menjalankan salinan mise. Aplikasi yang diluncurkan dari desktop juga menemukan perintah mise sebelum paket sistem, jadi aplikasi yang menjalankan `gh` akan mendapatkan salinan mise bahkan jika Anda menginstal `github-cli` dengan pacman, dan mise menginstal salinan itu pada penggunaan pertama. Untuk menggunakan milik Anda sebagai gantinya, nonaktifkan salinan mise di `~/.config/mise/config.toml`. Misalnya, jika Anda menginstal Cursor CLI sendiri:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Jika Anda sudah memiliki tabel `[settings]`, tambahkan entri di sana; perluas daftar `disable_tools` yang sudah ada alih-alih menggantinya. Pastikan instalasi Anda ada di `PATH`. Gunakan nama alat mise, yang bisa berbeda dari perintahnya: `oh-my-pi` menyediakan `omp`, misalnya. Peluncur agen bawaan juga lebih mengutamakan Cursor atau Muse yang diinstal pengguna di `~/.local/bin`.

### Menghapus dan memulihkan bawaan

_Remove Preinstalls_ membuat mise melewati deklarasi alat Omarchy untuk pengguna Anda, dengan menambahkannya ke `ignored_config_paths` di `~/.config/mise/miserc.toml`. _Restore Preinstalls_ menghapus baris itu kembali. Alat yang Anda deklarasikan sendiri, di konfigurasi Anda sendiri atau di `mise.toml` sebuah proyek, tetap bekerja dengan cara mana pun. Jika Anda memilih agen bawaan atau menyiapkan Python setelah menghapus prainstal, alat itu ditambahkan ke konfigurasi Anda sendiri. Keduanya hanya berlaku untuk pengguna Anda; pengguna lain di mesin tetap memiliki pilihan mereka sendiri.

## Docker

[Docker](https://www.docker.com/) hampir tidak perlu diperkenalkan lagi. Ini memungkinkan Anda menjalankan kontainer terisolasi, dan Omarchy menginstal semua yang diperlukan untuk menjalankannya dengan baik, termasuk Docker itu sendiri dan [Docker Compose](https://docs.docker.com/compose/).

Secara bawaan pengguna Anda *tidak* berada dalam grup `docker`. Grup itu secara efektif adalah root tanpa kata sandi — apa pun di dalamnya dapat menjalankan `docker run -v /:/host` dan mengambil alih mesin — jadi satu skrip atau dependensi nakal yang berjalan sebagai Anda akan hanya berjarak satu perintah dari root. Jadi di baris perintah Anda menjalankan Docker dengan `sudo` (`sudo docker ps`, `sudo docker compose up`), dan alat grafis yang berkomunikasi dengan daemon — VM Windows — meminta otorisasi saat membutuhkannya. Jika Anda ingin kembali ke kenyamanan penyiapan tanpa grup dan memahami komprominya, aktifkan dari **Setup > Security > Sudoless Docker** (atau jalankan `omarchy-setup-security-sudoless-docker`), yang menambahkan Anda ke grup `docker` setelah sebuah peringatan; kemudian `docker` biasa dan alias `d` bekerja lagi tanpa `sudo`.

Anda dapat menyiapkan database umum untuk pengembangan lokal di Docker menggunakan _Install > Development > Docker DB_ di menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) tersedia sebagai `gh` untuk bekerja dengan repositori, issue, dan pull request dari terminal. Jalankan `gh auth login` untuk menginstalnya pada penggunaan pertama dan melakukan autentikasi, lalu `gh repo clone org/repo` untuk mengkloning sebuah repositori. Jalankan `gh --help` untuk menjelajahi perintahnya.

Untuk antarmuka terminal bagi pull request, jalankan `ghui`; mise juga menginstalnya pada penggunaan pertama. [Lazygit](https://github.com/jesseduffield/lazygit) sudah terinstal untuk bekerja dengan Git itu sendiri.
