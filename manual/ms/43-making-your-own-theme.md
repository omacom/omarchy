# Membuat tema anda sendiri

Anda boleh menambah tema anda sendiri ke `~/.config/omarchy/themes`. Salin sahaja salah satu yang sedia ada sebagai asas (lihat dalam `/usr/share/omarchy/themes`), kemudian ubah suai sesuka hati. Selagi tema anda berada di dalam folder itu, ia akan disertakan dalam menu pemilihan tema.

Fail utama yang perlu anda ubah suai ialah `colors.toml`. Itu mentakrifkan set warna yang kemudian digunakan untuk menjana konfigurasi untuk terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, dan seluruh shell Omarchy (bar atas, menu, pemberitahuan, OSD, dan skrin kunci).

Anda juga boleh menggunakan aplikasi Aether yang disertakan untuk mencipta tema baharu menggunakan antara muka GUI yang menarik untuk bermain dengan warna dan mencari latar belakang. Mulakannya sahaja dari grid aplikasi pada `Super + Alt + Space`.

### Apa yang boleh terkandung dalam tema yang dipasang

Tema yang anda tulis sendiri dalam `~/.config/omarchy/themes` boleh mengandungi apa sahaja yang anda suka — ini mesin anda dan fail anda, dan Omarchy menggunakan semuanya.

Tema yang anda pasang dari repo orang lain dengan `omarchy theme install` mengekalkan segala yang berkaitan warna, dan kehilangan sebilangan kecil fail yang akan menjalankan kod pada mesin anda: mana-mana fail `.lua`, konfigurasi terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), dan `vscode.json`. `hyprland.lua` tema ialah Lua yang dijalankan kompositor anda semasa log masuk, konfigurasi terminal menamakan atur cara yang dimulakan terminal anda, dan `vscode.json` menamakan sambungan VSCode untuk dipasang. Memasang tema seseorang sepatutnya menukar rupa desktop anda, tidak pernah apa yang dijalankannya.

Semua yang lain masih berfungsi tepat seperti yang ditulis oleh pengarang tema — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, latar belakang dan pratonton semuanya dikekalkan. Hanya apa yang digugurkan dijana semula daripada `colors.toml` pada mesin anda.

Omarchy membezakan kedua-duanya berdasarkan sama ada tema itu mempunyai repo gitnya sendiri di dalamnya, yang merupakan apa yang ditinggalkan oleh `omarchy theme install` apabila ia mengklon. Jadi tema yang anda tulis kekal milik anda, dan yang anda ambil dari internet kekal sebagai warna.

### Mod cerah

Jika anda membuat tema mod cerah, tetapkan `mode = "light"` di bahagian atas `colors.toml` anda. Kemudian ia akan dipasangkan secara automatik dengan mod cerah untuk semua aplikasi. (Cara lama meletakkan fail kosong dipanggil `light.mode` di akar tema anda juga masih berfungsi.)

### Warna ikon

Jika anda mahu memadankan warna ikon pengurus fail dengan tema anda, tambahkan fail dipanggil `icons.theme` dengan nama set ikon yang anda mahu gunakan. Secara lalai, pilihannya ialah: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Imej buka kunci

Tema yang dibekalkan dengan imej `unlock.png` dan `preview-unlock.png` akan disenaraikan di bawah _Gaya > Buka Kunci_. `unlock.png` anda sebaiknya ialah png lutsinar. Dan anda boleh mencipta imej pratonton menggunakan `omarchy plymouth preview`.

### Menematikkan aplikasi yang tidak diliputi Omarchy

Jika anda menggunakan aplikasi yang tiada dalam senarai itu, anda boleh mengajar Omarchy untuk menematikkannya sendiri dengan templat. Letakkan fail dalam `~/.config/omarchy/themed/` dinamakan sempena konfigurasi yang dijananya tambah sambungan `.tpl`, dan tulis konfigurasi dengan `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` hingga `{{ color15 }}`, dan baki palet sebagai pemegang tempat. Setiap kali anda menukar tema, fail itu dijana semula dengan warna tema itu.

Terdapat `alacritty.toml.tpl.sample` yang dikomen penuh dalam folder itu untuk disalin — ia menyenaraikan setiap pemboleh ubah yang boleh anda gunakan, tambah pengubah suai `_strip` dan `_rgb` untuk aplikasi yang mahukan warnanya tanpa `#` atau sebagai RGB perpuluhan. Templat anda diutamakan berbanding templat Omarchy sendiri, jadi anda juga boleh menggunakan ini untuk mengatasi cara aplikasi terbina dalam ditematikkan.

### Mengedarkan tema anda

Jika anda mahu mengedarkan tema anda supaya orang lain boleh menggunakannya, anda perlu meletakkannya pada pelayan git awam, seperti GitHub. Kemudian orang boleh memasangnya menggunakan _Pasang > Gaya > Tema_ dalam menu Omarchy menggunakan URL itu. Adalah disyorkan agar anda mengikuti konvensyen penamaan `omarchy-[themename]-theme`, kerana tema itu akan dipaparkan dengan betul sebagai hanya `[themename]` dalam menu pemilihan tema selepas pemasangan.

Lebihan `[themename]` itu menjadi nama direktori tema, jadi ia mestilah yang boleh diedarkan Omarchy dengan selamat: ia mesti bermula dengan huruf, digit, atau garis bawah, dan bakinya boleh mengandungi huruf, digit, `.`, `_`, `+`, dan `-`. Huruf besar diturunkan huruf untuk anda, tetapi apa sahaja selain itu — ruang, petikan, aksara bukan Inggeris — ditolak semasa pemasangan dan bukannya dijadikan nama direktori. Jadi `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, dan `omarchy-c++-theme` semuanya dipasang dengan baik.

Ingat bahawa sebaik sahaja ia dipasang dari repo, mana-mana `.lua`, konfigurasi terminal atau `vscode.json` yang dibekalkannya akan digugurkan, jadi jangan bina tema berasaskan itu.

Anda boleh mendapatkan tema anda ditambah ke [halaman tema tambahan](https://omarchy.org/themes/) dengan menghantar pull request ke [repo omarchy-site](https://github.com/omacom-io/omarchy-site).
