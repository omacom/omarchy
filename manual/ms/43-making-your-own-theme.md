# Membuat tema anda sendiri

Anda boleh menambah tema anda sendiri ke `~/.config/omarchy/themes`. Salin sahaja salah satu tema sedia ada sebagai asas (lihat dalam `/usr/share/omarchy/themes`), kemudian ubah suai mengikut citarasa anda. Selagi tema anda berada di dalam folder itu, ia akan disertakan dalam menu pemilihan tema.

Fail utama yang perlu anda ubah suai ialah `colors.toml`. Fail itu mentakrifkan set warna yang kemudian digunakan untuk menjana konfigurasi bagi terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, aplikasi Qt, lampu latar papan kekunci, kaedah input, pemilih perkongsian skrin, ikon aplikasi, beberapa alat AI (Claude, Pi, Hermes, T3 Code, Herdr), dan keseluruhan shell Omarchy (bar atas, menu, pemberitahuan, OSD, dan skrin kunci).

Anda juga boleh menggunakan aplikasi Aether yang disertakan untuk mencipta tema baharu menggunakan antara muka GUI yang menarik untuk bermain dengan warna dan mencari latar belakang. Lancarkannya sahaja dari grid aplikasi dengan `Super + Alt + Space`.

### Apa yang boleh terkandung dalam tema yang dipasang

Tema yang anda tulis sendiri dalam `~/.config/omarchy/themes` boleh mengandungi apa sahaja yang anda mahu — ini mesin anda dan fail anda, dan Omarchy akan menggunakan kesemuanya.

Tema yang anda pasang dari repo orang lain dengan `omarchy theme install` mengekalkan semua yang berkaitan dengan warna, dan membuang segelintir fail yang akan menjalankan kod pada mesin anda: mana-mana fail `.lua`, konfigurasi terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), dan `vscode.json`. `hyprland.lua` sesebuah tema ialah Lua yang dijalankan oleh compositor anda semasa log masuk, konfigurasi terminal menamakan program yang dimulakan oleh terminal anda, dan `vscode.json` menamakan sambungan VSCode untuk dipasang. Memasang tema seseorang sepatutnya mengubah rupa desktop anda, bukan apa yang dijalankannya.

Semua yang lain masih berfungsi tepat seperti yang ditulis oleh pengarang tema — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, latar belakang dan pratonton semuanya dikekalkan. Hanya apa yang dibuang akan dijana semula daripada `colors.toml` pada mesin anda.

Omarchy membezakan kedua-duanya berdasarkan sama ada tema itu mempunyai repo git sendiri di dalamnya, iaitu apa yang ditinggalkan oleh `omarchy theme install` apabila ia mengklon. Jadi tema yang anda tulis kekal milik anda, dan tema yang anda ambil dari internet kekal sebagai warna sahaja.

### Mod cerah

Jika anda membuat tema mod cerah, tetapkan `mode = "light"` di bahagian atas `colors.toml` anda. Kemudian ia akan dipadankan secara automatik dengan mod cerah untuk semua aplikasi. (Cara lama dengan meletakkan fail kosong bernama `light.mode` di akar tema anda juga masih berfungsi.)

### Imej buka kunci

Tema yang dibekalkan dengan imej `unlock.png` dan `preview-unlock.png` akan disenaraikan di bawah _Appearance > Unlock_. `unlock.png` anda sebaiknya ialah png lutsinar. Dan anda boleh mencipta imej pratonton menggunakan `omarchy plymouth preview`.

### Menetapkan tema untuk aplikasi yang tidak diliputi Omarchy

Jika anda menggunakan aplikasi yang tiada dalam senarai itu, anda boleh mengajar Omarchy untuk menetapkan temanya sendiri dengan templat. Letakkan fail dalam `~/.config/omarchy/themed/` yang dinamakan sempena konfigurasi yang dijananya ditambah sambungan `.tpl`, dan tulis konfigurasi itu dengan `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` hingga `{{ color15 }}`, dan selebihnya palet sebagai pemegang tempat. Setiap kali anda menukar tema, fail itu akan dijana semula dengan warna tema tersebut.

Terdapat `alacritty.toml.tpl.sample` yang dikomen sepenuhnya dalam folder itu untuk disalin — ia menyenaraikan setiap pemboleh ubah yang boleh anda gunakan, serta pengubah suai `_strip` dan `_rgb` untuk aplikasi yang mahukan warnanya tanpa `#` atau sebagai RGB perpuluhan. Templat anda diutamakan berbanding templat Omarchy sendiri, jadi anda juga boleh menggunakannya untuk mengatasi cara aplikasi terbina dalam ditetapkan temanya.

### Mengedarkan tema anda

Jika anda mahu mengedarkan tema anda supaya orang lain boleh menggunakannya, anda perlu meletakkannya pada pelayan git awam, seperti GitHub. Kemudian orang ramai boleh memasangnya menggunakan _Install > Style > Theme_ dalam menu Omarchy menggunakan URL itu. Anda disyorkan mengikuti konvensyen penamaan `omarchy-[themename]-theme`, kerana tema itu akan dipaparkan dengan betul sebagai hanya `[themename]` dalam menu pemilihan tema selepas pemasangan.

`[themename]` yang tinggal itu menjadi nama direktori tema, jadi ia mestilah nama yang boleh dikendalikan oleh Omarchy dengan selamat: ia mesti bermula dengan huruf, digit, atau garis bawah, dan selebihnya boleh mengandungi huruf, digit, `.`, `_`, `+`, dan `-`. Huruf besar akan ditukar kepada huruf kecil untuk anda, tetapi apa-apa selain itu — ruang, tanda petik, aksara bukan bahasa Inggeris — akan ditolak semasa pemasangan dan bukannya dijadikan nama direktori. Jadi `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, dan `omarchy-c++-theme` semuanya boleh dipasang tanpa masalah.

Ingat bahawa sebaik sahaja ia dipasang dari repo, mana-mana `.lua`, konfigurasi terminal atau `vscode.json` yang disertakannya akan dibuang, jadi jangan bina tema anda berasaskan fail-fail tersebut.

Anda boleh menambahkan tema anda pada [halaman tema tambahan](https://omarchy.org/themes/) dengan menghantar pull request kepada [repo omarchy-site](https://github.com/omacom-io/omarchy-site).
