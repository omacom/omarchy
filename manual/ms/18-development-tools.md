# Alat Pembangunan

## Penyunting Alternatif

Omarchy disertakan dengan Plain sebagai penyunting lalai pada pemasangan baharu dan [Neovim](https://neovim.io/) yang telah diprapasang, tetapi jika anda mahukan sesuatu yang lebih arus perdana dan biasa digunakan, anda boleh menjalankan Menu Omarchy (`Super + Space`) dan lihat pilihan di bawah _Pasang > Penyunting_. Kami menyenaraikan VSCode, Cursor, Zed, Sublime Text, Helix, Vim, dan Emacs di sana. Jika anda tidak menemui apa yang anda cari, lihat _Pasang > Pakej_, dan semak sama ada ia ada dalam pakej Arch (dan jika tiada, cuba _Pasang > AUR_ untuk menyemak AUR).

Penyunting `vi` asal juga tersedia secara langsung. Jalankan `vi filename` untuk menyunting fail dalam terminal.

Padanan tema ditawarkan untuk `VSCode`, `Cursor`, `VSCodium`, dan `Helix`.

Anda boleh menetapkan penyunting lalai seluruh sistem di bawah `Setup > Defaults > Editor`.

## Persekitaran

Omarchy menyokong penyediaan pelbagai persekitaran pembangunan melalui bahagian _Pasang > Pembangunan_ dalam Menu Omarchy (`Super + Space`). Sudah tentu anda akan menemui _Ruby on Rails_, tetapi juga ketiga-tiga runtime utama untuk JavaScript (Node.js, Bun, Deno), serta rangka kerja PHP popular seperti Laravel dan Symfony. Oh, dan ada juga Go, Rust, Python, Java, Elixir (dengan Phoenix), .NET, OCaml, Zig, Clojure, dan Scala. Pilihannya memang sangat luas!

Kebanyakan persekitaran ini diuruskan oleh [Mise](https://mise.jdx.dev/). Ia ialah alat yang membolehkan anda memasang dan menjalankan berbilang versi bahasa pengaturcaraan pada mesin yang sama. Ia seperti rbenv atau rvm untuk Ruby atau virtualenv untuk Python, tetapi ia berfungsi untuk pelbagai persekitaran yang berbeza.

Untuk memasang, katakan, Ruby, anda perlu menjalankan `mise use -g ruby`, yang akan memasang Ruby dan menetapkannya sebagai lalai global. Atau, jika projek anda mempunyai fail .ruby-version, anda hanya perlu menjalankan `mise i` dalam direktori akar projek tersebut.

## Alat CLI Prapasang

Omarchy menyediakan alat seperti `gh`, `uv`, dan kebanyakan [ejen pengekodan](17-ai.md) melalui [pemasangan malas mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Kali pertama anda menjalankan salah satunya, mise akan memasangnya. Ejen pengekodan kemudiannya akan menyemak kemas kini sebelum dijalankan, paling kerap sekali setiap empat jam; alat lain, seperti `gh` dan `uv`, menggunakan semula versi yang telah dipasang sehingga anda mengemas kininya.

Anda juga boleh menyemak tetapan lalai atau memasangnya lebih awal:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Jalankan `omarchy update` untuk mengemas kini alat yang telah dipasang bersama-sama dengan keseluruhan Omarchy. Alias `mup` hanya mengemas kini alat yang diuruskan oleh mise. Untuk menambah alat lain pada konfigurasi anda sendiri, gunakan `mise use -g <tool>`.

Penyediaan Python juga memasang `uv` melalui mise. Mengalih keluar persekitaran pembangunan Python membiarkan `uv` tersedia sebagai alat bebas.

### Menggunakan pemasangan anda sendiri

Perintah mise mendahului `~/.local/bin` pada `PATH`, jadi alat yang anda pasang sendiri, contohnya dengan pemasang Claude Code atau Cursor sendiri, masih menjalankan salinan mise. Aplikasi yang dilancarkan dari desktop juga menemui perintah mise sebelum pakej sistem, jadi aplikasi yang menjalankan `gh` akan mendapat salinan mise walaupun anda memasang `github-cli` dengan pacman, dan mise memasang salinan itu pada kali pertama. Untuk menggunakan salinan anda sebaliknya, lumpuhkan salinan mise dalam `~/.config/mise/config.toml`. Contohnya, jika anda memasang Cursor CLI sendiri:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Jika anda sudah mempunyai jadual `[settings]`, tambahkan entri itu di sana; lanjutkan senarai `disable_tools` yang sedia ada dan bukannya menggantikannya. Pastikan pemasangan anda berada pada `PATH`. Gunakan nama alat mise, yang boleh berbeza daripada perintahnya: `oh-my-pi` menyediakan `omp`, sebagai contoh. Pelancar ejen lalai juga mengutamakan Cursor atau Muse yang dipasang oleh pengguna dalam `~/.local/bin`.

### Mengalih keluar dan memulihkan tetapan lalai

_Alih Keluar > Prapasang_ mengalih keluar aplikasi web, TUI dan aplikasi prapasang Omarchy, dan menyebabkan mise melangkau pengisytiharan alat Omarchy untuk pengguna anda, dengan menambahkannya pada `ignored_config_paths` dalam `~/.config/mise/miserc.toml`. _Pasang > Prapasang_ membawanya kembali dan mengalih keluar baris itu semula. Alat yang anda isytiharkan sendiri, dalam konfigurasi anda sendiri atau dalam `mise.toml` projek, terus berfungsi dalam kedua-dua keadaan. Jika anda memilih ejen lalai atau menyediakan Python selepas mengalih keluar prapasang, alat itu ditambahkan pada konfigurasi anda sendiri. Tetapan mise hanya terpakai untuk pengguna anda, dan pengguna lain mengekalkan pilihan mereka sendiri; aplikasi tersebut ialah pakej, walau bagaimanapun, jadi mengalih keluar atau memulihkannya mengubahnya untuk semua orang pada mesin itu.

## Docker

[Docker](https://www.docker.com/) hampir tidak memerlukan sebarang pengenalan. Ia membolehkan anda menjalankan kontena terpencil, dan Omarchy memasang semua yang diperlukan untuk menjalankannya dengan baik, termasuk Docker itu sendiri dan [Docker Compose](https://docs.docker.com/compose/).

Secara lalai pengguna anda *tidak* berada dalam kumpulan `docker`. Kumpulan itu sebenarnya ialah root tanpa kata laluan — apa-apa sahaja di dalamnya boleh menjalankan `docker run -v /:/host` dan mengambil alih mesin — jadi satu skrip atau kebergantungan jahat yang berjalan sebagai anda sebaliknya hanya satu perintah sahaja lagi untuk menjadi root. Jadi pada baris perintah anda menjalankan Docker dengan `sudo` (`sudo docker ps`, `sudo docker compose up`), dan alat grafik yang berkomunikasi dengan daemon — VM Windows — meminta kebenaran apabila memerlukannya. Jika anda mahukan kembali kemudahan persediaan tanpa kumpulan dan memahami pertukarannya, dayakannya daripada **Persediaan > Keselamatan > Docker Tanpa Sudo** (atau jalankan `omarchy-setup-security-sudoless-docker`), yang menambahkan anda pada kumpulan `docker` selepas amaran; kemudian `docker` biasa dan alias `d` berfungsi tanpa `sudo` semula.

Anda boleh menyediakan pangkalan data biasa untuk pembangunan setempat dalam Docker menggunakan _Pasang > Pembangunan > Docker DB_ dalam menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) tersedia sebagai `gh` untuk bekerja dengan repositori, isu, dan pull request dari terminal. Jalankan `gh auth login` untuk memasangnya pada penggunaan pertama dan mengesahkan, kemudian `gh repo clone org/repo` untuk mengklon repositori. Jalankan `gh --help` untuk meneroka perintahnya.

Untuk antara muka terminal bagi pull request, jalankan `ghui`; mise juga memasangnya pada penggunaan pertama. [Lazygit](https://github.com/jesseduffield/lazygit) telah diprapasang untuk bekerja dengan Git itu sendiri.
