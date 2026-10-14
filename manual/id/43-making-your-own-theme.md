# Membuat tema sendiri

Kamu bisa menambahkan temamu sendiri ke `~/.config/omarchy/themes`. Cukup salin salah satu yang sudah ada sebagai dasar (lihat di `/usr/share/omarchy/themes`), lalu sesuaikan sesukamu. Selama temamu berada di dalam folder itu, ia akan disertakan dalam menu pemilihan tema.

Berkas utama yang harus kamu sesuaikan adalah `colors.toml`. Itu mendefinisikan rangkaian warna yang kemudian digunakan untuk menghasilkan konfigurasi untuk terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, dan seluruh shell Omarchy (bilah atas, menu, notifikasi, OSD, dan layar kunci).

Kamu juga bisa menggunakan aplikasi Aether yang disertakan untuk membuat tema baru menggunakan antarmuka GUI yang menyenangkan untuk bermain dengan warna dan mencari latar belakang. Cukup mulai dari grid aplikasi di `Super + Alt + Space`.

### Apa yang bisa dimuat oleh tema yang dipasang

Tema yang kamu tulis sendiri di `~/.config/omarchy/themes` bisa memuat apa pun yang kamu suka — ini mesinmu dan berkasmu, dan Omarchy menerapkan semuanya.

Tema yang kamu pasang dari repo orang lain dengan `omarchy theme install` menyimpan semua yang berwarna, dan kehilangan segelintir berkas yang akan menjalankan kode di mesinmu: berkas `.lua` mana pun, konfigurasi terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), dan `vscode.json`. `hyprland.lua` milik tema adalah Lua yang dijalankan compositor-mu saat login, konfigurasi terminal menyebutkan program yang dimulai terminalmu, dan `vscode.json` menyebutkan ekstensi VSCode yang harus dipasang. Memasang tema seseorang seharusnya mengubah tampilan desktopmu, bukan apa yang dijalankannya.

Semua hal lain tetap berfungsi persis seperti yang ditulis penulis tema — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, latar belakang dan pratinjau semuanya disimpan. Hanya yang dibuang yang dihasilkan ulang dari `colors.toml` di mesinmu.

Omarchy membedakan keduanya berdasarkan apakah tema tersebut punya repo git-nya sendiri di dalamnya, yang merupakan apa yang ditinggalkan `omarchy theme install` saat ia mengkloning. Jadi tema yang kamu tulis tetap milikmu, dan yang kamu ambil dari internet tetap berwarna.

### Mode terang

Jika kamu membuat tema mode terang, atur `mode = "light"` di bagian atas `colors.toml` kamu. Lalu ia akan otomatis dipasangkan dengan mode terang untuk semua aplikasi. (Cara lama meletakkan berkas kosong bernama `light.mode` di akar temamu juga masih berfungsi.)

### Warna ikon

Jika kamu ingin mencocokkan warna ikon pengelola berkas dengan temamu, tambahkan berkas bernama `icons.theme` dengan nama rangkaian ikon yang ingin kamu gunakan. Secara bawaan, opsinya adalah: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Gambar buka kunci

Tema yang dilengkapi dengan gambar `unlock.png` dan `preview-unlock.png` akan tercantum di _Gaya > Buka Kunci_. `unlock.png` kamu sebaiknya berupa png transparan. Dan kamu bisa membuat gambar pratinjau menggunakan `omarchy plymouth preview`.

### Memberi tema pada aplikasi yang tidak dicakup Omarchy

Jika kamu menggunakan aplikasi yang tidak ada dalam daftar itu, kamu bisa mengajari Omarchy untuk memberi tema padanya sendiri dengan templat. Letakkan berkas di `~/.config/omarchy/themed/` yang diberi nama sesuai konfigurasi yang dihasilkannya ditambah ekstensi `.tpl`, dan tulis konfigurasinya dengan `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` sampai `{{ color15 }}`, dan sisa palet sebagai placeholder. Setiap kali kamu berganti tema, berkas tersebut dihasilkan ulang dengan warna tema itu.

Ada `alacritty.toml.tpl.sample` yang berkomentar lengkap di folder itu untuk disalin — ia mencantumkan setiap variabel yang bisa kamu gunakan, plus pengubah `_strip` dan `_rgb` untuk aplikasi yang menginginkan warnanya tanpa `#` atau sebagai RGB desimal. Templatmu diprioritaskan di atas milik Omarchy sendiri, jadi kamu juga bisa menggunakan ini untuk menimpa cara aplikasi bawaan diberi tema.

### Mendistribusikan temamu

Jika kamu ingin mendistribusikan temamu agar orang lain bisa menggunakannya, kamu perlu meletakkannya di server git publik, seperti GitHub. Lalu orang bisa memasangnya menggunakan _Pasang > Gaya > Tema_ di menu Omarchy menggunakan URL itu. Disarankan kamu mengikuti konvensi penamaan `omarchy-[themename]-theme`, karena tema akan tampil dengan benar hanya sebagai `[themename]` di menu pemilihan tema setelah pemasangan.

Sisa `[themename]` itu menjadi nama direktori tema, jadi ia harus menjadi nama yang bisa diberikan Omarchy dengan aman: ia harus diawali huruf, angka, atau garis bawah, dan sisanya boleh memuat huruf, angka, `.`, `_`, `+`, dan `-`. Huruf kapital diubah menjadi huruf kecil untukmu, tetapi apa pun selain itu — spasi, tanda kutip, karakter non-Inggris — ditolak saat pemasangan alih-alih diubah menjadi nama direktori. Jadi `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, dan `omarchy-c++-theme` semuanya terpasang dengan baik.

Ingat bahwa begitu ia dipasang dari repo, `.lua`, konfigurasi terminal, atau `vscode.json` apa pun yang disertakannya akan dibuang, jadi jangan membangun tema di sekitar hal-hal itu.

Kamu bisa menambahkan temamu ke [halaman tema tambahan](https://omarchy.org/themes/) dengan mengirimkan pull request ke [repo omarchy-site](https://github.com/omacom-io/omarchy-site).
