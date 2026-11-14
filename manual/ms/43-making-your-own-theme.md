# Membuat tema anda sendiri

Anda boleh menambah tema anda sendiri ke `~/.config/omarchy/themes`. Salin sahaja salah satu tema sedia ada sebagai asas (lihat dalam `/usr/share/omarchy/themes`), kemudian ubah suai mengikut citarasa anda. Selagi tema anda berada di dalam folder itu, ia akan disertakan dalam menu pemilihan tema.

Fail utama yang perlu anda ubah suai ialah `colors.toml`. Fail itu mentakrifkan set warna yang kemudian digunakan untuk menjana konfigurasi bagi terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, dan seluruh shell Omarchy (bar atas, menu, pemberitahuan, OSD, dan skrin kunci).

Anda juga boleh menggunakan aplikasi Aether yang disertakan untuk mencipta tema baharu menggunakan antara muka GUI yang menarik untuk bermain dengan warna dan mencari latar belakang. Lancarkannya sahaja dari grid aplikasi pada `Super + Alt + Space`.

### Apa yang boleh terkandung dalam tema yang dipasang

Tema yang anda tulis sendiri dalam `~/.config/omarchy/themes` boleh mengandungi apa sahaja yang anda suka — ini mesin anda dan fail anda, dan Omarchy menggunakan kesemuanya.

Tema yang anda pasang dari repo orang lain dengan `omarchy theme install` mengekalkan semua yang berkaitan dengan warna, dan membuang segelintir fail yang akan menjalankan kod pada mesin anda: sebarang fail `.lua`, konfigurasi terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), dan `vscode.json`. `hyprland.lua` bagi sesebuah tema ialah Lua yang compositor anda jalankan semasa log masuk, konfigurasi terminal menamakan program yang terminal anda mulakan, dan `vscode.json` menamakan sambungan VSCode untuk dipasang. Memasang tema seseorang sepatutnya mengubah rupa desktop anda, bukan apa yang ia jalankan.

Semua yang lain masih berfungsi tepat seperti yang ditulis oleh pengarang tema — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, latar belakang dan pratonton semuanya dikekalkan. Hanya yang dibuang itu akan dijana semula daripada `colors.toml` pada mesin anda.

Omarchy membezakan kedua-duanya berdasarkan sama ada tema itu mempunyai repo git sendiri di dalamnya, iaitu apa yang ditinggalkan oleh `omarchy theme install` apabila ia mengklon. Jadi tema yang anda tulis kekal milik anda, dan tema yang anda ambil dari internet kekal sebagai warna sahaja.

### Mod cerah

Jika anda membuat tema mod cerah, tetapkan `mode = "light"` di bahagian atas `colors.toml` anda. Kemudian ia akan dipadankan secara automatik dengan mod cerah untuk semua aplikasi. (Cara lama dengan meletakkan fail kosong bernama `light.mode` di akar tema anda masih berfungsi juga.)

### Imej buka kunci

Tema yang dibekalkan dengan imej `unlock.png` dan `preview-unlock.png` akan disenaraikan di bawah _Appearance > Unlock_. `unlock.png` anda sebaik-baiknya ialah png lutsinar. Dan anda boleh mencipta imej pratonton menggunakan `omarchy plymouth preview`.

### Menematikkan aplikasi yang tidak diliputi Omarchy

Jika anda menggunakan aplikasi yang tiada dalam senarai itu, anda boleh mengajar Omarchy untuk menematikkannya sendiri dengan templat. Letakkan fail dalam `~/.config/omarchy/themed/` yang dinamakan sempena konfigurasi yang dijananya ditambah sambungan `.tpl`, dan tulis konfigurasi itu dengan `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` hingga `{{ color15 }}`, dan selebihnya palet sebagai pemegang tempat. Setiap kali anda menukar tema, fail itu dijana semula dengan warna tema tersebut.

Terdapat `alacritty.toml.tpl.sample` yang dikomen sepenuhnya dalam folder itu untuk anda salin — ia menyenaraikan setiap pemboleh ubah yang boleh anda gunakan, serta pengubah suai `_strip` dan `_rgb` untuk aplikasi yang mahukan warnanya tanpa `#` atau sebagai RGB perpuluhan. Templat anda diutamakan berbanding templat Omarchy sendiri, jadi anda juga boleh menggunakan ini untuk mengatasi cara aplikasi terbina dalam ditematikkan.

### Mengedarkan tema anda

Jika anda mahu mengedarkan tema anda supaya orang lain boleh menggunakannya, anda perlu meletakkannya pada pelayan git awam, seperti GitHub. Kemudian orang ramai boleh memasangnya menggunakan _Install > Style > Theme_ dalam menu Omarchy menggunakan URL itu. Anda disyorkan mengikuti konvensyen penamaan `omarchy-[themename]-theme`, kerana tema itu akan dipaparkan dengan betul sebagai hanya `[themename]` dalam menu pemilihan tema selepas pemasangan.

Baki `[themename]` itu menjadi nama direktori tema, jadi ia mestilah nama yang boleh Omarchy kendalikan dengan selamat: ia mesti bermula dengan huruf, digit, atau garis bawah, dan selebihnya boleh mengandungi huruf, digit, `.`, `_`, `+`, dan `-`. Huruf besar akan direndahkan untuk anda, tetapi apa-apa yang lain — ruang, tanda petik, aksara bukan bahasa Inggeris — akan ditolak semasa pemasangan dan bukannya dijadikan nama direktori. Jadi `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, dan `omarchy-c++-theme` semuanya boleh dipasang tanpa masalah.

Ingat bahawa sebaik sahaja ia dipasang dari repo, sebarang `.lua`, konfigurasi terminal atau `vscode.json` yang disertakannya akan dibuang, jadi jangan bina tema anda berasaskan fail-fail itu.

Anda boleh menambah tema anda ke [halaman tema tambahan](https://omarchy.org/themes/) dengan menghantar pull request ke [repo omarchy-site](https://github.com/omacom-io/omarchy-site).
