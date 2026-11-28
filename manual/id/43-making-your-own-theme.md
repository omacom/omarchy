# Membuat tema Anda sendiri

Anda dapat menambahkan tema Anda sendiri ke `~/.config/omarchy/themes`. Cukup salin salah satu tema yang sudah ada sebagai dasar (lihat di `/usr/share/omarchy/themes`), lalu sesuaikan sesuka hati Anda. Selama tema Anda berada di dalam folder tersebut, tema itu akan disertakan dalam menu pemilihan tema.

File utama yang harus Anda sesuaikan adalah `colors.toml`. File itu mendefinisikan rangkaian warna yang kemudian digunakan untuk menghasilkan konfigurasi untuk terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, aplikasi Qt, lampu latar keyboard, metode input, pemilih berbagi layar, ikon aplikasi, beberapa alat AI (Claude, Pi, Hermes, T3 Code, Herdr), dan seluruh shell Omarchy (bilah atas, menu, notifikasi, OSD, dan layar kunci).

Anda juga dapat menggunakan aplikasi Aether yang disertakan untuk membuat tema baru menggunakan antarmuka GUI yang menyenangkan untuk bermain-main dengan warna dan mencari latar belakang. Cukup jalankan dari kisi aplikasi dengan `Super + Alt + Space`.

### Apa saja yang dapat dimuat oleh tema yang terpasang

Tema yang Anda tulis sendiri di `~/.config/omarchy/themes` dapat berisi apa pun yang Anda suka — ini mesin Anda dan file Anda, dan Omarchy menerapkan semuanya.

Tema yang Anda pasang dari repo orang lain dengan `omarchy theme install` mempertahankan semua yang berupa warna, dan membuang segelintir file yang akan menjalankan kode di mesin Anda: setiap file `.lua`, konfigurasi terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), dan `vscode.json`. `hyprland.lua` milik sebuah tema adalah Lua yang dijalankan compositor Anda saat masuk, konfigurasi terminal menyebutkan program yang dijalankan terminal Anda, dan `vscode.json` menyebutkan ekstensi VSCode yang akan dipasang. Memasang tema milik seseorang seharusnya mengubah tampilan desktop Anda, bukan apa yang dijalankannya.

Semua hal lainnya tetap berfungsi persis seperti yang ditulis oleh pembuat tema — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, latar belakang, dan pratinjau semuanya dipertahankan. Hanya yang dibuang saja yang dibuat ulang dari `colors.toml` di mesin Anda.

Omarchy membedakan keduanya berdasarkan apakah tema tersebut memiliki repo git-nya sendiri di dalamnya, yaitu yang ditinggalkan oleh `omarchy theme install` ketika melakukan kloning. Jadi tema yang Anda tulis tetap menjadi milik Anda, dan tema yang Anda ambil dari internet tetap hanya berupa warna.

### Mode terang

Jika Anda membuat tema mode terang, tetapkan `mode = "light"` di bagian atas `colors.toml` Anda. Maka tema itu akan secara otomatis dipasangkan dengan mode terang untuk semua aplikasi. (Cara lama dengan menaruh file kosong bernama `light.mode` di akar tema Anda juga masih berfungsi.)

### Gambar buka kunci

Tema yang disertai gambar `unlock.png` dan `preview-unlock.png` akan dicantumkan di bawah _Appearance > Unlock_. `unlock.png` Anda sebaiknya berupa png transparan. Dan Anda dapat membuat gambar pratinjau menggunakan `omarchy plymouth preview`.

### Memberi tema pada aplikasi yang tidak dicakup Omarchy

Jika Anda menggunakan aplikasi yang tidak ada dalam daftar itu, Anda dapat mengajari Omarchy untuk memberi tema padanya sendiri dengan sebuah templat. Taruh sebuah file di `~/.config/omarchy/themed/` yang dinamai sesuai konfigurasi yang dihasilkannya ditambah ekstensi `.tpl`, dan tulis konfigurasinya dengan `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` hingga `{{ color15 }}`, dan sisa palet sebagai placeholder. Setiap kali Anda beralih tema, file itu dibuat ulang dengan warna tema tersebut.

Ada `alacritty.toml.tpl.sample` yang diberi komentar lengkap di folder itu untuk disalin — file itu mencantumkan setiap variabel yang dapat Anda gunakan, ditambah pengubah `_strip` dan `_rgb` untuk aplikasi yang menginginkan warnanya tanpa `#` atau sebagai RGB desimal. Templat Anda diutamakan di atas templat milik Omarchy sendiri, jadi Anda juga dapat menggunakan ini untuk menimpa cara aplikasi bawaan diberi tema.

### Mendistribusikan tema Anda

Jika Anda ingin mendistribusikan tema Anda agar orang lain dapat menggunakannya, Anda harus menaruhnya di server git publik, seperti GitHub. Kemudian orang-orang dapat memasangnya menggunakan _Install > Style > Theme_ di menu Omarchy menggunakan URL tersebut. Disarankan agar Anda mengikuti konvensi penamaan `omarchy-[themename]-theme`, karena tema itu akan tampil dengan benar hanya sebagai `[themename]` di menu pemilihan tema setelah pemasangan.

Sisa `[themename]` itu menjadi nama direktori tema, jadi nama itu haruslah nama yang dapat Omarchy operkan dengan aman: nama itu harus diawali dengan huruf, digit, atau garis bawah, dan sisanya boleh berisi huruf, digit, `.`, `_`, `+`, dan `-`. Huruf kapital akan diubah menjadi huruf kecil untuk Anda, tetapi apa pun selain itu — spasi, tanda kutip, karakter non-Inggris — ditolak pada saat pemasangan alih-alih diubah menjadi nama direktori. Jadi `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, dan `omarchy-c++-theme` semuanya dapat dipasang dengan baik.

Ingatlah bahwa setelah tema itu dipasang dari sebuah repo, setiap `.lua`, konfigurasi terminal, atau `vscode.json` yang disertakannya akan dibuang, jadi jangan membangun tema dengan berpusat pada hal-hal tersebut.

Anda dapat membuat tema Anda ditambahkan ke [halaman tema tambahan](https://omarchy.org/themes/) dengan mengirimkan pull request ke [repo omarchy-site](https://github.com/omacom-io/omarchy-site).
