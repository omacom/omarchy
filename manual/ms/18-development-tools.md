# Alat Pembangunan

## Penyunting Alternatif

Omarchy disertakan dengan Plain sebagai penyunting lalai pada pemasangan baharu dan [Neovim](https://neovim.io/) telah diprapasang, tetapi jika anda mahukan sesuatu yang lebih arus perdana dan biasa digunakan, anda boleh menjalankan Menu Omarchy (`Super + Space`) dan lihat pilihan di bawah _Pasang > Penyunting_. Kami menyenaraikan VSCode, Cursor, Zed, Sublime Text, Helix, Vim, dan Emacs di sana. Jika anda tidak menemui apa yang anda cari, lihat _Pasang > Pakej_, dan semak sama ada ia ada dalam pakej Arch (dan jika tiada, cuba _Pasang > AUR_ untuk menyemak AUR).

Penyunting `vi` asal juga tersedia terus dari kotak. Jalankan `vi filename` untuk menyunting fail dalam terminal.

Pemadanan tema ditawarkan untuk `VSCode`, `Cursor`, `VSCodium`, dan `Helix`.

Anda boleh menetapkan penyunting lalai seluruh sistem di bawah `Setup > Defaults > Editor`.

## Persekitaran

Omarchy menyokong penyediaan pelbagai jenis persekitaran pembangunan melalui bahagian _Pasang > Pembangunan_ dalam Menu Omarchy (`Super + Space`). Anda tentu akan menemui _Ruby on Rails_, tetapi juga ketiga-tiga masa jalan utama untuk JavaScript (Node.js, Bun, Deno), serta rangka kerja PHP popular seperti Laravel dan Symfony. Oh, dan Go, Rust, Python, Java, Elixir (dengan Phoenix), .NET, OCaml, Zig, Clojure, dan Scala juga ada. Pilihannya memang sangat luas!

Kebanyakan persekitaran ini diuruskan oleh [Mise](https://mise.jdx.dev/). Ia alat yang membolehkan anda memasang dan menjalankan berbilang versi bahasa pengaturcaraan pada mesin yang sama. Ia seperti rbenv atau rvm untuk Ruby atau virtualenv untuk Python, tetapi ia berfungsi untuk pelbagai persekitaran yang berbeza.

Untuk memasang, katakan, Ruby, anda jalankan `mise use -g ruby`, yang akan memasang Ruby dan menetapkannya sebagai lalai global. Atau, jika projek anda mempunyai fail .ruby-version, anda boleh jalankan sahaja `mise i` dalam akar projek tersebut.

## Alat CLI prapasang

`uv`, Node.js, dan `playwright-cli` (untuk ejen memacu pelayar, menggunakan Chrome yang dipasang) dipasang sebagai pakej, dan `omarchy update` memastikannya sentiasa terkini bersama-sama seluruh sistem. `ghui`, [Hunk](https://github.com/modem-dev/hunk), dan CLI Basecamp, Cloudflare dan HEY hanya perlu dipilih di bawah _Pasang > CLI_, dan [ejen pengekodan](17-ai.md) di bawah _Pasang > AI > CLI_.

mise hanya mengurus masa jalan yang anda sediakan dari _Pasang > Pembangunan_; Omarchy tidak memasang apa-apa melaluinya dengan sendirinya. Jalankan `omarchy update` untuk mengemas kininya bersama-sama seluruh Omarchy; alias `mup` mengemas kini alat yang diurus mise sahaja. Untuk menambah alat lain pada konfigurasi anda sendiri, gunakan `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) hampir tidak memerlukan pengenalan. Ia membolehkan anda menjalankan kontena terpencil, dan Omarchy memasang semua yang diperlukan untuk menjalankannya dengan baik, termasuk Docker itu sendiri dan [Docker Compose](https://docs.docker.com/compose/).

Secara lalai pengguna anda *tidak* berada dalam kumpulan `docker`. Kumpulan itu secara berkesan ialah root tanpa kata laluan — apa-apa sahaja di dalamnya boleh menjalankan `docker run -v /:/host` dan mengambil alih mesin — jadi satu skrip atau kebergantungan jahat yang berjalan sebagai anda sebaliknya hanya satu perintah sahaja lagi daripada root. Jadi pada baris perintah anda menjalankan Docker dengan `sudo` (`sudo docker ps`, `sudo docker compose up`), dan alat grafik yang berkomunikasi dengan daemon — VM Windows — meminta kebenaran apabila memerlukannya. Jika anda mahukan kembali kemudahan persediaan tanpa kumpulan dan memahami pertukarannya, dayakannya dari **Persediaan > Keselamatan > Docker Tanpa Sudo** (atau jalankan `omarchy-setup-security-sudoless-docker`), yang menambahkan anda ke dalam kumpulan `docker` selepas amaran; kemudian `docker` biasa dan alias `d` berfungsi tanpa `sudo` semula.

Anda boleh menyediakan pangkalan data biasa untuk pembangunan setempat dalam Docker menggunakan _Pasang > Pembangunan > Docker DB_ dalam menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) ialah `gh`, untuk bekerja dengan repositori, isu, dan pull request dari terminal. _Persediaan > Git_ memasangnya apabila anda memilih untuk log masuk ke GitHub di sana, kemudian `gh repo clone org/repo` mengklon repositori. Jalankan `gh --help` untuk meneroka perintahnya.

_Pasang > CLI > GitHub_ memasang GitHub CLI, `gh`, bersama-sama `ghui`, antara muka terminal untuk pull request. [Lazygit](https://github.com/jesseduffield/lazygit) telah diprapasang untuk bekerja dengan Git itu sendiri.
