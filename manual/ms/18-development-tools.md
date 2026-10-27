# Alat Pembangunan

## Editor Alternatif

Omarchy didatangkan dengan [Neovim](https://neovim.io/) secara lalai, tetapi jika anda mahukan sesuatu yang lebih arus perdana dan lebih biasa, anda boleh menjalankan Omarchy Menu (`Super + Space`) dan lihat pilihan di bawah _Install > Editor_. Kami menyenaraikan VSCode, Cursor, Zed, Sublime Text, Helix, Vim, dan Emacs di sana. Jika anda tidak menemui apa yang anda cari, lihat _Install > Package_, dan semak sama ada ia ada dalam pakej Arch (dan jika tiada, cuba _Install > AUR_ untuk menyemak AUR).

Editor asal `vi` juga tersedia terus daripada kotak. Jalankan `vi filename` untuk menyunting fail dalam terminal.

Pemadanan tema ditawarkan untuk `VSCode`, `Cursor`, `VSCodium`, dan `Helix`.

Anda boleh menetapkan editor lalai seluruh sistem di bawah `Setup > Defaults > Editor`.

## Persekitaran

Omarchy menyokong penyediaan pelbagai persekitaran pembangunan melalui bahagian _Install > Development_ dalam Omarchy Menu (`Super + Space`). Sudah tentu anda akan menemui _Ruby on Rails_, tetapi juga ketiga-tiga runtime utama untuk JavaScript (Node.js, Bun, Deno), serta framework PHP popular seperti Laravel dan Symfony. Oh, dan ada juga Go, Rust, Python, Java, Elixir (dengan Phoenix), .NET, OCaml, Zig, Clojure, dan Scala. Pilihannya sangat luas!

Kebanyakan persekitaran ini diuruskan oleh [Mise](https://mise.jdx.dev/). Ia alat yang membolehkan anda memasang dan menjalankan berbilang versi bahasa pengaturcaraan pada mesin yang sama. Ia seperti rbenv atau rvm untuk Ruby atau virtualenv untuk Python, tetapi ia berfungsi untuk pelbagai persekitaran yang berbeza.

Untuk memasang, katakan, Ruby, anda jalankan `mise use -g ruby`, yang akan memasang Ruby dan menetapkannya sebagai lalai global. Atau, jika projek anda mempunyai fail .ruby-version, anda hanya perlu menjalankan `mise i` di root projek tersebut.

## Alat CLI Prapasang

Omarchy menjadikan alat seperti `gh`, `uv`, dan kebanyakan [ejen pengekodan](17-ai.md) tersedia melalui [pemasangan malas mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Kali pertama anda menjalankan salah satu daripadanya, mise memasangnya. Penggunaan seterusnya menggunakan semula versi yang telah dipasang; ia tidak menyemak kemas kini pada setiap pelancaran.

Anda juga boleh menyemak tetapan lalai atau memasangnya lebih awal:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Jalankan `omarchy update` untuk mengemas kini alat yang telah dipasang bersama seluruh Omarchy. Alias `mup` hanya mengemas kini alat yang diuruskan oleh mise. Untuk menambah alat lain pada konfigurasi anda sendiri, gunakan `mise use -g <tool>`.

Penyediaan Python juga memasang `uv` melalui mise. Membuang persekitaran pembangunan Python membiarkan `uv` kekal tersedia sebagai alat bebas.

### Menggunakan pemasangan anda sendiri

Arahan mise mendahului `~/.local/bin` pada `PATH`, jadi alat yang anda pasang sendiri, contohnya dengan pemasang Claude Code atau Cursor sendiri, tetap menjalankan salinan mise. Aplikasi yang dilancarkan dari desktop juga menemui arahan mise sebelum pakej sistem, jadi aplikasi yang menjalankan `gh` mendapat salinan mise walaupun anda memasang `github-cli` dengan pacman, dan mise memasang salinan itu pada kali pertama. Untuk menggunakan salinan anda sebaliknya, lumpuhkan salinan mise dalam `~/.config/mise/config.toml`. Contohnya, jika anda memasang Cursor CLI sendiri:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Jika anda sudah mempunyai jadual `[settings]`, tambahkan entri itu di sana; lanjutkan senarai `disable_tools` sedia ada dan bukannya menggantikannya. Pastikan pemasangan anda berada pada `PATH`. Gunakan nama alat mise, yang boleh berbeza daripada arahannya: `oh-my-pi` menyediakan `omp`, contohnya. Pelancar ejen lalai juga mengutamakan Cursor atau Muse yang dipasang pengguna dalam `~/.local/bin`.

### Membuang dan memulihkan tetapan lalai

_Remove Preinstalls_ membuat mise melangkau pengisytiharan alat Omarchy untuk pengguna anda, dengan menambahkannya pada `ignored_config_paths` dalam `~/.config/mise/miserc.toml`. _Restore Preinstalls_ membuang baris itu semula. Alat yang anda isytiharkan sendiri, dalam konfigurasi anda sendiri atau dalam `mise.toml` projek, terus berfungsi dalam kedua-dua keadaan. Jika anda memilih ejen lalai atau menyediakan Python selepas membuang prapemasangan, alat itu ditambahkan pada konfigurasi anda sendiri. Kedua-duanya hanya terpakai pada pengguna anda; pengguna lain pada mesin mengekalkan pilihan mereka sendiri.

## Docker

[Docker](https://www.docker.com/) hampir tidak memerlukan sebarang pengenalan. Ia membolehkan anda menjalankan kontena terpencil, dan Omarchy memasang semua yang diperlukan untuk menjalankannya dengan baik, termasuk Docker itu sendiri dan [Docker Compose](https://docs.docker.com/compose/).

Secara lalai pengguna anda *bukan* dalam kumpulan `docker`. Kumpulan itu sebenarnya root tanpa kata laluan — apa-apa sahaja di dalamnya boleh menjalankan `docker run -v /:/host` dan mengambil alih mesin — jadi satu skrip atau kebergantungan jahat yang berjalan sebagai anda sebaliknya hanya satu arahan sahaja lagi daripada root. Jadi pada baris arahan anda menjalankan Docker dengan `sudo` (`sudo docker ps`, `sudo docker compose up`), dan alat grafik yang berkomunikasi dengan daemon — Windows VM — meminta kebenaran apabila memerlukannya. Jika anda mahukan semula kemudahan persediaan tanpa kumpulan itu dan memahami pertukarannya, dayakannya daripada **Setup > Security > Sudoless Docker** (atau jalankan `omarchy-setup-security-sudoless-docker`), yang menambahkan anda ke dalam kumpulan `docker` selepas amaran; kemudian `docker` biasa dan alias `d` berfungsi tanpa `sudo` semula.

Anda boleh menyediakan pangkalan data biasa untuk pembangunan setempat dalam Docker menggunakan _Install > Development > Docker DB_ dalam menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) tersedia sebagai `gh` untuk bekerja dengan repositori, isu, dan pull request dari terminal. Jalankan `gh auth login` untuk memasangnya pada penggunaan pertama dan membuat pengesahan, kemudian `gh repo clone org/repo` untuk mengklon repositori. Jalankan `gh --help` untuk meneroka arahannya.

Untuk antara muka terminal bagi pull request, jalankan `ghui`; mise juga memasangnya pada penggunaan pertama. [Lazygit](https://github.com/jesseduffield/lazygit) telah diprapasang untuk bekerja dengan Git itu sendiri.
