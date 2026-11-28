# Alat Pembangunan

## Penyunting Alternatif

Omarchy didatangkan dengan Plain sebagai penyunting lalai pada pemasangan baharu dan [Neovim](https://neovim.io/) yang telah diprapasang, tetapi jika anda mahukan sesuatu yang lebih arus perdana dan biasa digunakan, anda boleh jalankan Omarchy Menu (`Super + Space`) dan lihat pilihan di bawah _Install > Editor_. Kami menyenaraikan VSCode, Cursor, Zed, Sublime Text, Helix, Vim, dan Emacs di sana. Jika anda tidak menemui apa yang anda cari, lihat _Install > Package_, dan semak sama ada ia ada dalam pakej Arch (dan jika tiada, cuba _Install > AUR_ untuk menyemak AUR).

Penyunting `vi` asal juga tersedia terus dari awal. Jalankan `vi filename` untuk menyunting fail dalam terminal.

Pemadanan tema ditawarkan untuk `VSCode`, `Cursor`, `VSCodium`, dan `Helix`.

Anda boleh menetapkan penyunting lalai seluruh sistem di bawah `Setup > Defaults > Editor`.

## Persekitaran

Omarchy menyokong penyediaan pelbagai jenis persekitaran pembangunan melalui bahagian _Install > Development_ dalam Omarchy Menu (`Super + Space`). Sudah tentu anda akan menemui _Ruby on Rails_, tetapi juga ketiga-tiga masa jalan utama untuk JavaScript (Node.js, Bun, Deno), serta rangka kerja PHP popular seperti Laravel dan Symfony. Oh, dan terdapat juga Go, Rust, Python, Java, Elixir (dengan Phoenix), .NET, OCaml, Zig, Clojure, dan Scala. Pilihannya sangat luas!

Majoriti persekitaran ini diuruskan oleh [Mise](https://mise.jdx.dev/). Ia ialah alat yang membolehkan anda memasang dan menjalankan berbilang versi bahasa pengaturcaraan pada mesin yang sama. Ia seperti rbenv atau rvm untuk Ruby atau virtualenv untuk Python, tetapi ia berfungsi untuk pelbagai persekitaran yang berbeza.

Untuk memasang, katakan, Ruby, anda perlu jalankan `mise use -g ruby`, yang akan memasang Ruby dan menetapkannya sebagai lalai global. Atau, jika projek anda mempunyai fail .ruby-version, anda hanya perlu jalankan `mise i` dalam direktori akar projek tersebut.

## Alat CLI yang telah diprapasang

`uv`, Node.js, dan `playwright-cli` (untuk ejen memacu pelayar, menggunakan Chrome yang telah dipasang) didatangkan sebagai pakej yang telah dipasang, dan `omarchy update` memastikannya sentiasa terkini bersama-sama seluruh sistem. [Hunk](https://github.com/modem-dev/hunk) serta CLI GitHub, Basecamp, Cloudflare dan HEY hanya selangkah pilihan di bawah _Install > CLI_, dan [ejen pengekodan](17-ai.md) di bawah _Install > AI > CLI_.

mise hanya menguruskan masa jalan yang anda sediakan dari _Install > Development_; Omarchy tidak memasang apa-apa melaluinya dengan sendirinya. Jalankan `omarchy update` untuk mengemas kininya bersama-sama seluruh Omarchy; alias `mup` mengemas kini alat yang diuruskan oleh mise sahaja. Untuk menambah alat lain pada konfigurasi anda sendiri, gunakan `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) hampir tidak perlu diperkenalkan lagi. Ia membolehkan anda menjalankan kontena terpencil, dan Omarchy memasang semua yang diperlukan untuk menjalankannya dengan baik, termasuk Docker itu sendiri dan [Docker Compose](https://docs.docker.com/compose/).

Secara lalai, pengguna anda *bukan* dalam kumpulan `docker`. Kumpulan itu pada hakikatnya ialah root tanpa kata laluan — apa-apa sahaja di dalamnya boleh menjalankan `docker run -v /:/host` dan mengambil alih mesin — jadi satu skrip atau kebergantungan jahat yang berjalan sebagai anda sebaliknya hanya selangkah arahan sahaja daripada root. Jadi pada baris arahan, anda menjalankan Docker dengan `sudo` (`sudo docker ps`, `sudo docker compose up`), dan alat grafik yang berkomunikasi dengan daemon — Windows VM — akan meminta kebenaran apabila memerlukannya. Jika anda mahukan semula kemudahan persediaan tanpa kumpulan dan memahami pertukarannya, dayakannya dari **Setup > Security > Sudoless Docker** (atau jalankan `omarchy-setup-security-sudoless-docker`), yang akan menambah anda ke dalam kumpulan `docker` selepas satu amaran; kemudian `docker` biasa dan alias `d` akan berfungsi tanpa `sudo` semula.

Anda boleh menyediakan pangkalan data lazim untuk pembangunan tempatan dalam Docker menggunakan _Install > Development > Docker DB_ dalam menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) ialah `gh`, untuk bekerja dengan repositori, isu, dan pull request dari terminal. _Setup > Git_ memasangnya apabila anda memilih untuk log masuk ke GitHub di sana, atau pasangnya secara berasingan dari _Install > CLI > GitHub_. Kemudian `gh repo clone org/repo` mengklon sesebuah repositori; jalankan `gh --help` untuk meneroka arahannya.

[Lazygit](https://github.com/jesseduffield/lazygit) telah diprapasang untuk bekerja dengan Git itu sendiri.
