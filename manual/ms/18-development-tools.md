# Alatan Pembangunan

## Penyunting Alternatif

Omarchy dilengkapi dengan [Neovim](https://neovim.io/) secara lalai, tetapi jika anda mahu sesuatu yang lebih arus perdana dan biasa, anda boleh membuka Menu Omarchy (`Super + Space`) dan melihat pilihan di bawah _Pasang > Penyunting_. Kami ada VSCode, Cursor, Zed, Sublime Text, Helix, Vim, dan Emacs disenaraikan di sana. Jika anda tidak jumpa apa yang anda cari, lihat _Pasang > Pakej_, dan semak sama ada ia ada dalam pakej Arch (dan jika tiada, cuba _Pasang > AUR_ untuk menyemak AUR).

Penyunting asal `vi` juga tersedia terus tanpa persediaan. Jalankan `vi filename` untuk menyunting fail dalam terminal.

Padanan tema ditawarkan untuk `VSCode`, `Cursor`, `VSCodium`, dan `Helix`.

Anda boleh menetapkan penyunting lalai seluruh sistem di bawah `Persediaan > Lalai > Penyunting`.

## Persekitaran

Omarchy menyokong penyediaan pelbagai persekitaran pembangunan melalui bahagian _Pasang > Pembangunan_ dalam Menu Omarchy (`Super + Space`). Sudah tentu anda akan jumpa _Ruby on Rails_, tetapi juga ketiga-tiga runtime utama untuk JavaScript (Node.js, Bun, Deno), serta rangka kerja PHP yang popular seperti Laravel dan Symfony. Oh, dan ada juga Go, Rust, Python, Java, Elixir (dengan Phoenix), .NET, OCaml, Zig, Clojure, dan Scala. Pilihannya memang sangat luas!

Kebanyakan persekitaran ini diuruskan oleh [Mise](https://mise.jdx.dev/). Ia ialah alat yang membolehkan anda memasang dan menjalankan berbilang versi bahasa pengaturcaraan pada mesin yang sama. Ia seperti rbenv atau rvm untuk Ruby atau virtualenv untuk Python, tetapi ia berfungsi untuk banyak persekitaran yang berbeza.

Untuk memasang, katakan, Ruby, anda jalankan `mise use -g ruby`, yang akan memasang Ruby dan menetapkannya sebagai lalai global. Atau, jika projek anda ada fail .ruby-version, anda boleh jalankan `mise i` di akar projek itu.

## Docker

[Docker](https://www.docker.com/) hampir tidak perlu diperkenalkan. Ia membolehkan anda menjalankan container yang terasing, dan Omarchy memasang semua yang diperlukan untuk menjalankannya dengan baik, termasuk Docker itu sendiri dan [Docker Compose](https://docs.docker.com/compose/).

Secara lalai pengguna anda *tidak* berada dalam kumpulan `docker`. Kumpulan itu sebenarnya sama seperti root tanpa kata laluan — apa-apa di dalamnya boleh `docker run -v /:/host` dan mengambil alih mesin — jadi satu skrip jahat atau kebergantungan yang berjalan sebagai anda hanya satu perintah sahaja jauhnya daripada root. Jadi pada baris perintah anda menjalankan Docker dengan `sudo` (`sudo docker ps`, `sudo docker compose up`), dan alatan grafik yang berhubung dengan daemon — VM Windows — akan meminta kebenaran apabila memerlukannya. Jika anda mahu kemudahan persediaan tanpa kumpulan kembali dan memahami pertukarannya, dayakannya daripada **Persediaan > Keselamatan > Docker Tanpa Sudo** (atau jalankan `omarchy-setup-security-sudoless-docker`), yang menambah anda ke kumpulan `docker` selepas amaran; kemudian `docker` biasa dan alias `d` berfungsi tanpa `sudo` semula.

Anda boleh menyediakan pangkalan data biasa untuk pembangunan tempatan dalam Docker menggunakan _Pasang > Pembangunan > Docker DB_ dalam menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) membolehkan anda mengesahkan dengan akaun GitHub anda dan mengklon repositori peribadi menggunakannya. Ia disambungkan sebagai salah satu stub mise yang dimuat secara malas, jadi kali pertama anda menjalankan `gh`, ia memasang dirinya sendiri. Untuk mengesahkan, jalankan `gh auth login`. Kemudian anda boleh checkout repositori peribadi menggunakan `gh repo clone org/repo`.

Anda juga boleh melakukan pelbagai operasi GitHub lain menggunakan perintah ini. Jalankan sahaja `gh` untuk melihat semua yang mungkin.

Ada juga stub pemasangan malas untuk `ghui` bagi menguruskan pull request anda dalam TUI. Dan [lazygit](https://github.com/jesseduffield/lazygit) diprapasang, jika anda mahu memacu git itu sendiri daripada TUI juga.
