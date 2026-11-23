# Alat Pengembangan

## Editor Alternatif

Omarchy disertai Plain sebagai editor bawaan pada instalasi baru dan [Neovim](https://neovim.io/) yang sudah terpasang, tetapi jika Anda ingin sesuatu yang sedikit lebih mainstream dan familier, Anda dapat menjalankan Omarchy Menu (`Super + Space`) dan melihat opsi-opsi di bawah _Install > Editor_. Di sana kami mencantumkan VSCode, Cursor, Zed, Sublime Text, Helix, Vim, dan Emacs. Jika Anda tidak menemukan yang Anda cari, lihat _Install > Package_, dan lihat apakah itu ada dalam paket Arch (dan jika tidak, coba _Install > AUR_ untuk memeriksa AUR).

Editor `vi` asli juga tersedia langsung. Jalankan `vi filename` untuk mengedit file di terminal.

Pencocokan tema ditawarkan untuk `VSCode`, `Cursor`, `VSCodium`, dan `Helix`.

Anda dapat mengatur editor bawaan di seluruh sistem di bawah `Setup > Defaults > Editor`.

## Lingkungan

Omarchy mendukung penyiapan berbagai macam lingkungan pengembangan melalui bagian _Install > Development_ di Omarchy Menu (`Super + Space`). Tentu saja Anda akan menemukan _Ruby on Rails_, tetapi juga ketiga runtime utama untuk JavaScript (Node.js, Bun, Deno), serta framework PHP populer seperti Laravel dan Symfony. Oh, dan ada juga Go, Rust, Python, Java, Elixir (dengan Phoenix), .NET, OCaml, Zig, Clojure, dan Scala. Pilihannya sangat luas!

Mayoritas lingkungan ini dikelola oleh [Mise](https://mise.jdx.dev/). Ini adalah alat yang memungkinkan Anda memasang dan menjalankan beberapa versi bahasa pemrograman pada mesin yang sama. Ini seperti rbenv atau rvm untuk Ruby atau virtualenv untuk Python, tetapi bekerja untuk berbagai lingkungan yang berbeda.

Untuk memasang, misalnya, Ruby, Anda akan menjalankan `mise use -g ruby`, yang akan memasang Ruby dan mengaturnya sebagai bawaan global. Atau, jika proyek Anda memiliki file .ruby-version, Anda cukup menjalankan `mise i` di root proyek tersebut.

## Alat CLI Prainstal

Omarchy menyediakan alat seperti `gh`, `uv`, dan sebagian besar [agen pemrograman](17-ai.md) melalui [instalasi lazy mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Pertama kali Anda menjalankan salah satunya, mise memasangnya. Agen pemrograman kemudian memeriksa adanya pembaruan sebelum berjalan, paling sering sekali setiap empat jam; alat lain, seperti `gh` dan `uv`, menggunakan kembali versi yang telah terpasang hingga Anda memperbaruinya.

Anda juga bisa memeriksa konfigurasi bawaannya atau memasangnya lebih awal:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Jalankan `omarchy update` untuk memperbarui alat-alat yang terpasang bersama seluruh Omarchy lainnya. Alias `mup` hanya memperbarui alat yang dikelola oleh mise. Untuk menambahkan alat lain ke konfigurasi Anda sendiri, gunakan `mise use -g <tool>`.

Penyiapan Python juga memasang `uv` melalui mise. Menghapus lingkungan pengembangan Python akan tetap menyisakan `uv` sebagai alat yang berdiri sendiri.

### Menggunakan instalasi Anda sendiri

Perintah-perintah mise berada di depan `~/.local/bin` pada `PATH`, sehingga alat yang Anda pasang sendiri, misalnya menggunakan installer bawaan Claude Code atau Cursor, tetap akan menjalankan salinan milik mise. Aplikasi yang diluncurkan dari desktop juga akan menemukan perintah mise sebelum paket sistem, sehingga aplikasi yang menjalankan `gh` akan mendapatkan salinan mise meskipun Anda memasang `github-cli` dengan pacman, dan mise akan memasang salinan tersebut pada kali pertama. Untuk menggunakan milik Anda, nonaktifkan salinan mise di `~/.config/mise/config.toml`. Misalnya, jika Anda memasang Cursor CLI sendiri:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Jika Anda sudah memiliki tabel `[settings]`, tambahkan entri tersebut di sana; kembangkan daftar `disable_tools` yang sudah ada, jangan menggantinya. Pastikan instalasi Anda berada di `PATH`. Gunakan nama alat mise, yang bisa berbeda dengan perintahnya: `oh-my-pi` menyediakan `omp`, sebagai contoh. Peluncur agen bawaan juga lebih mengutamakan Cursor atau Muse yang dipasang oleh pengguna di `~/.local/bin`.

### Menghapus dan memulihkan bawaan

_Remove > Preinstalls_ menghapus aplikasi web, TUI, dan aplikasi prainstal Omarchy, serta membuat mise melewatkan deklarasi alat Omarchy untuk pengguna Anda, dengan menambahkannya ke `ignored_config_paths` di `~/.config/mise/miserc.toml`. _Install > Preinstalls_ mengembalikannya dan menghapus baris tersebut kembali. Alat yang Anda deklarasikan sendiri, baik di konfigurasi Anda sendiri maupun di `mise.toml` sebuah proyek, tetap berfungsi dalam kedua keadaan tersebut. Jika Anda memilih agen bawaan atau menyiapkan Python setelah menghapus prainstal, alat tersebut akan ditambahkan ke konfigurasi Anda sendiri. Pengaturan mise ini hanya berlaku untuk pengguna Anda, dan pengguna lain tetap mempertahankan pilihan mereka sendiri; namun aplikasi-aplikasi tersebut merupakan paket, sehingga menghapus atau mengembalikannya akan mengubahnya untuk semua orang di mesin tersebut.

## Docker

[Docker](https://www.docker.com/) hampir tidak perlu diperkenalkan. Ini memungkinkan Anda menjalankan container yang terisolasi, dan Omarchy memasang semua yang diperlukan untuk menjalankannya dengan baik, termasuk Docker itu sendiri dan [Docker Compose](https://docs.docker.com/compose/).

Secara bawaan pengguna Anda *tidak* termasuk dalam grup `docker`. Grup itu secara efektif adalah root tanpa kata sandi — apa pun di dalamnya dapat `docker run -v /:/host` dan mengambil alih mesin — jadi satu skrip atau dependensi nakal yang berjalan sebagai Anda sebaliknya hanya berjarak satu perintah dari root. Jadi pada baris perintah Anda menjalankan Docker dengan `sudo` (`sudo docker ps`, `sudo docker compose up`), dan alat grafis yang berbicara dengan daemon — Windows VM — meminta otorisasi saat mereka membutuhkannya. Jika Anda ingin kenyamanan penyiapan tanpa grup kembali dan memahami konsekuensinya, aktifkan dari **Setup > Security > Sudoless Docker** (atau jalankan `omarchy-setup-security-sudoless-docker`), yang menambahkan Anda ke grup `docker` setelah peringatan; kemudian `docker` biasa dan alias `d` bekerja tanpa `sudo` lagi.

Anda dapat menyiapkan database umum untuk pengembangan lokal di Docker menggunakan _Install > Development > Docker DB_ di menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) tersedia sebagai `gh` untuk bekerja dengan repositori, issue, dan pull request dari terminal. Jalankan `gh auth login` untuk memasangnya saat pertama kali digunakan dan melakukan autentikasi, lalu `gh repo clone org/repo` untuk mengkloning sebuah repositori. Jalankan `gh --help` untuk menjelajahi perintah-perintahnya.

Untuk antarmuka terminal bagi pull request, jalankan `ghui`; mise juga akan memasangnya saat pertama kali digunakan. [Lazygit](https://github.com/jesseduffield/lazygit) sudah terpasang untuk bekerja dengan Git itu sendiri.
