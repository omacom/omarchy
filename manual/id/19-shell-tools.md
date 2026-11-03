# Alat Shell

Selain alat Linux standar, Omarchy juga dilengkapi dengan berbagai alat shell yang ditingkatkan. Berikut yang utama.

## fzf

[fzf](https://junegunn.github.io/fzf/) memberimu pencarian berkas secara fuzzy melalui alias `ff`. Pergi ke direktori mana pun, ketik `ff`, dan kamu akan dapat menemukan jalanmu secara fuzzy ke berkas mana pun dalam pohon tersebut, sambil melihat pratinjau berkas yang kamu persempit di sisi kanan.

Kamu dapat menggunakan `Ctrl + R` untuk menggunakan fzf guna mencari secara fuzzy melalui riwayat perintahmu.

Alat ini juga digunakan oleh Neovim saat kamu mengetik `Space Space`.

Manual lengkap dapat ditemukan melalui `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) adalah pengganti cd. Ini mengingat direktori yang pernah kamu kunjungi, jadi kamu dapat lebih mudah melompat ke sana lain kali. Misalnya kamu melakukan `cd ~/.config/omarchy` sekali. Lain kali, kamu cukup melakukan `cd omarchy` (atau bahkan hanya `cd oma`), dan Zoxide akan membawamu langsung ke sana.

Manual lengkap dapat ditemukan melalui `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) mencari isi berkas dengan menggunakan `rg <pattern> <path>`, seperti `rg Controller app/` untuk menemukan semua sebutan `Controller` di direktori app.

Alat ini juga digunakan oleh Neovim saat kamu mengetik `Space S G`.

Manual lengkap dapat ditemukan melalui `man rg`.

## eza

[eza](https://eza.rocks/) adalah pengganti ls. Ini memberimu daftar direktori dengan lebih banyak informasi, warna, dan ikon. Secara bawaan, eza telah dibuat alias sebagai ls. Kamu juga dapat menggunakan `lt` untuk mendapatkan daftar dua tingkat kedalaman bersarang. `lsa` memberimu daftar termasuk berkas tersembunyi. Dan `lta` daftar bersarang dengan berkas tersembunyi.

Manual lengkap dapat ditemukan melalui `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) adalah pengganti `find` yang lebih mudah digunakan. Gunakan `fd person.rb` untuk menemukan berkas bernama `person.rb` dalam pohon saat ini. `fd person.rb /` akan mencari seluruh sistem berkas. `fd person.rb / -H` mencari seluruh sistem berkas, termasuk direktori tersembunyi.

Manual lengkap dapat ditemukan melalui `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) adalah `cat` dengan penyorotan sintaks, nomor baris, dan paging. Jalankan `bat somefile.rb` dan kamu akan melihat mengapa sulit untuk kembali. Ini juga diam-diam bekerja untukmu di tempat lain: inilah yang mewarnai halaman man-mu, dan yang merender pratinjau di `ff`.

Manual lengkap dapat ditemukan melalui `man bat`.

## tldr

[tldr](https://tldr.sh/) adalah penawar untuk halaman man yang dibuka dengan tiga layar sejarah sebelum menunjukkan satu contoh pun kepadamu. `tldr tar` memberimu segelintir pemanggilan yang sebenarnya kamu inginkan.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) mengunduh video dari YouTube dan ratusan situs lainnya. `yt-dlp <url>` mengambil kualitas terbaik yang tersedia ke direktori saat ini.

Manual lengkap dapat ditemukan melalui `man yt-dlp`.

## try

[try](https://github.com/tobi/try) memudahkan pengelolaan eksperimen pemrograman dengan direktori berstempel tanggal. Semua eksperimen berada di `~/Work/tries` dan kamu dapat mengaksesnya melalui `try`.

Omarchy tidak menambahkan direktori `bin/` proyek ke `PATH` secara otomatis. Jalankan alat lokal proyek yang tepercaya dengan jalur relatif eksplisit, seperti `bin/rails` atau `./bin/dev`.
