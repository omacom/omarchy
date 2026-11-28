# Membuat tema Anda sendiri

Anda bisa menambahkan tema Anda sendiri ke `~/.config/omarchy/themes`. Cukup salin salah satu tema yang sudah ada sebagai dasar (lihat di `/usr/share/omarchy/themes`), lalu ubah sesuka hati Anda. Selama tema Anda berada di dalam folder itu, tema tersebut akan muncul di menu pemilihan tema.

File utama yang harus Anda ubah adalah `colors.toml`. Itu menentukan set warna yang kemudian digunakan untuk menghasilkan konfigurasi untuk terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, aplikasi Qt, lampu latar keyboard, metode input, pemilih berbagi layar, ikon aplikasi, beberapa alat AI (Claude, Pi, Hermes, T3 Code, Herdr), dan seluruh shell Omarchy (bilah atas, menu, notifikasi, OSD, dan layar kunci).

Anda juga bisa menggunakan aplikasi Aether yang disertakan untuk membuat tema baru menggunakan antarmuka GUI yang menyenangkan untuk bermain-main dengan warna dan mencari latar belakang. Cukup jalankan dari kisi aplikasi dengan `Super + Alt + Space`.

### Apa saja yang bisa dimuat oleh tema yang terpasang

Tema yang Anda tulis sendiri di `~/.config/omarchy/themes` bisa berisi apa pun yang Anda suka — ini mesin Anda dan file Anda, dan Omarchy menerapkan semuanya.

Tema yang Anda pasang dari repo milik orang lain dengan `omarchy theme install` mempertahankan semua yang berkaitan dengan warna, dan membuang segelintir file yang akan menjalankan kode di mesin Anda: file `.lua` apa pun, konfigurasi terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), dan `vscode.json`. `hyprland.lua` milik sebuah tema adalah Lua yang dijalankan compositor Anda saat login, konfigurasi terminal menyebutkan program yang dijalankan terminal Anda, dan `vscode.json` menyebutkan ekstensi VSCode yang akan dipasang. Memasang tema milik seseorang seharusnya mengubah tampilan desktop Anda, bukan apa yang dijalankannya.

Semua hal lainnya tetap bekerja persis seperti yang ditulis oleh pembuat tema — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, latar belakang dan pratinjaunya semuanya dipertahankan. Hanya yang dibuang saja yang dihasilkan ulang dari `colors.toml` di mesin Anda.

Omarchy membedakan keduanya berdasarkan apakah tema tersebut memiliki repo git-nya sendiri di dalamnya, yang merupakan yang ditinggalkan oleh `omarchy theme install` saat melakukan clone. Jadi tema yang Anda tulis tetap menjadi milik Anda, dan tema yang Anda ambil dari internet tetap hanya soal warna.

### Mode terang

Jika Anda membuat tema mode terang, atur `mode = "light"` di bagian atas `colors.toml` Anda. Maka tema itu akan otomatis dipasangkan dengan mode terang untuk semua aplikasi. (Cara lama dengan meletakkan file kosong bernama `light.mode` di root tema Anda juga masih berfungsi.)

### Layar boot dan login

Layar yang meminta kata sandi drive saat boot, dan layar login, menggambar logo Omarchy dalam warna `accent` tema Anda di atas `background`-nya, dengan kolom kata sandi dalam warna `foreground`-nya dan `red` untuk kata sandi yang salah. Tidak ada tambahan apa pun yang perlu disertakan untuk mereka: Omarchy tidak lagi menggunakan `unlock.png` atau `preview-unlock.png` milik sebuah tema. Di Mac Apple Silicon, layar kata sandi drive tetap mempertahankan tampilan default Omarchy apa pun temanya.

### Memberi tema pada aplikasi yang tidak dicakup Omarchy

Jika Anda menggunakan aplikasi yang tidak ada dalam daftar itu, Anda bisa mengajari Omarchy untuk memberi tema pada aplikasi tersebut sendiri dengan sebuah templat. Letakkan sebuah file di `~/.config/omarchy/themed/` yang dinamai sesuai konfigurasi yang dihasilkannya ditambah ekstensi `.tpl`, dan tulis konfigurasinya dengan `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` sampai `{{ color15 }}`, dan sisa paletnya sebagai placeholder. Setiap kali Anda berganti tema, file itu dihasilkan ulang dengan warna tema tersebut.

Ada `alacritty.toml.tpl.sample` yang diberi komentar lengkap di folder itu untuk disalin — file itu mencantumkan setiap variabel yang bisa Anda gunakan, ditambah pengubah `_strip` dan `_rgb` untuk aplikasi yang menginginkan warnanya tanpa `#` atau sebagai RGB desimal. Templat Anda diprioritaskan di atas templat bawaan Omarchy, jadi Anda juga bisa menggunakan ini untuk menimpa cara aplikasi bawaan diberi tema.

### Mendistribusikan tema Anda

Jika Anda ingin mendistribusikan tema Anda agar orang lain bisa menggunakannya, Anda perlu menaruhnya di server git publik, seperti GitHub. Lalu orang-orang bisa memasangnya menggunakan _Install > Style > Theme_ di menu Omarchy dengan menggunakan URL tersebut. Disarankan agar Anda mengikuti konvensi penamaan `omarchy-[themename]-theme`, karena tema itu akan tampil dengan benar hanya sebagai `[themename]` di menu pemilihan tema setelah pemasangan.

Sisa `[themename]` itu menjadi nama direktori tema, jadi harus berupa nama yang bisa Omarchy tangani dengan aman: harus diawali dengan huruf, digit, atau garis bawah, dan sisanya boleh berisi huruf, digit, `.`, `_`, `+`, dan `-`. Huruf kapital akan diubah menjadi huruf kecil untuk Anda, tetapi apa pun selain itu — spasi, tanda kutip, karakter non-Inggris — akan ditolak saat pemasangan alih-alih diubah menjadi nama direktori. Jadi `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, dan `omarchy-c++-theme` semuanya bisa dipasang dengan baik.

Ingat bahwa setelah tema itu dipasang dari sebuah repo, file `.lua`, konfigurasi terminal, atau `vscode.json` apa pun yang disertakannya akan dibuang, jadi jangan membangun tema Anda di sekitar file-file itu.

Anda bisa menambahkan tema Anda ke [halaman tema tambahan](https://omarchy.org/themes/) dengan mengirimkan pull request ke [repo omarchy-site](https://github.com/omacom-io/omarchy-site).
