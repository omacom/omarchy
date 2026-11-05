# Alatan Shell

Selain alatan Linux standard, Omarchy juga dilengkapi dengan banyak alatan shell yang dipertingkat. Berikut ialah yang utama.

## fzf

[fzf](https://junegunn.github.io/fzf/) memberikan anda pencarian kabur fail melalui alias `ff`. Pergi ke mana-mana direktori, taip `ff`, dan anda boleh mencari secara kabur ke mana-mana fail dalam pokok itu, sambil melihat pratonton fail yang anda saring di sebelah kanan.

Anda boleh menggunakan `Ctrl + R` untuk menggunakan fzf mencari secara kabur dalam sejarah perintah anda.

Alat ini juga digunakan oleh Neovim apabila anda menaip `Space Space`.

Manual penuh boleh didapati melalui `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) ialah pengganti untuk cd. Ia mengingati direktori yang pernah anda masuki, jadi anda boleh melompat ke sana dengan lebih mudah pada kali seterusnya. Katakan anda buat `cd ~/.config/omarchy` sekali. Lain kali, anda boleh buat `cd omarchy` sahaja (atau `cd oma` sahaja), dan Zoxide akan membawa anda terus ke sana.

Manual penuh boleh didapati melalui `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) mencari kandungan fail dengan menggunakan `rg <pattern> <path>`, seperti `rg Controller app/` untuk mencari semua sebutan `Controller` dalam direktori app.

Alat ini juga digunakan oleh Neovim apabila anda menaip `Space S G`.

Manual penuh boleh didapati melalui `man rg`.

## eza

[eza](https://eza.rocks/) ialah pengganti untuk ls. Ia memberikan anda senarai direktori dengan lebih banyak maklumat, warna, dan ikon. Secara lalai, eza telah dialiaskan sebagai ls. Anda juga boleh menggunakan `lt` untuk mendapatkan senarai dua tahap sarang. `lsa` memberikan anda senarai termasuk fail tersembunyi. Dan `lta` senarai bersarang dengan fail tersembunyi.

Manual penuh boleh didapati melalui `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) ialah pengganti `find` yang lebih mudah digunakan. Gunakan `fd person.rb` untuk mencari fail bernama `person.rb` dalam pokok semasa. `fd person.rb /` akan mencari seluruh sistem fail. `fd person.rb / -H` mencari seluruh sistem fail, termasuk direktori tersembunyi.

Manual penuh boleh didapati melalui `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) ialah `cat` dengan penyerlahan sintaks, nombor baris, dan halaman. Jalankan `bat somefile.rb` dan anda akan lihat mengapa sukar untuk kembali. Ia juga bekerja secara senyap untuk anda di tempat lain: ia yang mewarnakan halaman man anda, dan yang memaparkan pratonton dalam `ff`.

Manual penuh boleh didapati melalui `man bat`.

## tldr

[tldr](https://tldr.sh/) ialah penawar kepada halaman man yang dibuka dengan tiga skrin sejarah sebelum menunjukkan satu contoh pun. `tldr tar` memberikan anda beberapa invocation yang sebenarnya anda mahu.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) memuat turun video dari YouTube dan ratusan tapak lain. `yt-dlp <url>` mengambil kualiti terbaik yang tersedia ke dalam direktori semasa.

Manual penuh boleh didapati melalui `man yt-dlp`.

## try

[try](https://github.com/tobi/try) memudahkan pengurusan eksperimen pengaturcaraan dengan direktori bercop tarikh. Semua eksperimen berada dalam `~/Work/tries` dan anda boleh mengaksesnya melalui `try`.

Omarchy tidak menambah direktori `bin/` projek ke `PATH` secara automatik. Jalankan alatan tempatan projek yang dipercayai dengan laluan relatif yang eksplisit, seperti `bin/rails` atau `./bin/dev`.
