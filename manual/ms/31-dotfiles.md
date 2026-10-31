# Dotfiles

Omarchy dikonfigurasikan terutamanya melalui apa yang dipanggil dotfiles yang berada dalam `~/.config`. Fail-fail itu dianggap sebagai fail anda untuk perubahan anda. Fail yang berada dalam `/usr/share/omarchy` adalah milik Omarchy itu sendiri, dan anda tidak sepatutnya mengusiknya. Jika anda perlu mengubah apa-apa dalam `/usr/share/omarchy`, anda sebaliknya harus menulis ganti nilai tersebut dalam `~/.config`.

Konfigurasi utama boleh diedit terus daripada menu Omarchy (`Super + Space`), seperti _Setup > Keybindings_, _Setup > Input_, dan _Setup > Config > [file]_. Apabila anda melakukannya dengan cara ini, mana-mana proses yang perlu dimulakan semula selepas pengeditan konfigurasi akan dimulakan semula secara automatik selepas anda keluar daripada editor (Neovim secara lalai — `:wq`, ingat! — tetapi anda boleh mengubahnya melalui _Setup > Defaults > Editor_).

Berikut ialah senarai fail utama dalam `~/.config` dan perkara yang dikawalnya:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Konfigurasi utama Hyprland. Memuatkan tetapan lalai Omarchy serta fail gantian anda di bawah. [Ketahui lebih lanjut tentang konfigurasi Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Pengikatan kekunci anda sendiri dan gantian kepada tetapan lalai. |
| `~/.config/hypr/monitors.lua` | Tetapan monitor yang tidak diliputi oleh panel monitor, seperti putaran, mod tambahan, atau memastikan monitor kekal dimatikan. |
| `~/.config/hypr/input.lua` | Mengawal susun atur papan kekunci, tetikus, dan tetapan pad jejak anda. |
| `~/.config/hypr/looknfeel.lua` | Mengawal jurang, sempadan, animasi, dan selebihnya dari segi penampilan. |
| `~/.config/hypr/autostart.lua` | Mengawal proses tambahan yang dimulakan bersama sesi. |
| `~/.config/omarchy/shell.json` | Mengawal shell Omarchy: kedudukan bar, susun atur, dan widget, serta penyelamat skrin, kunci, dan masa leka. |
| `~/.config/foot/foot.ini` | Mengawal terminal anda (foot ialah lalai). |
| `~/.XCompose` | Mentakrifkan emoji capaian pantas dan pelengkapan automatik nama/e-mel anda. Pastikan anda menjalankan `omarchy-restart-xcompose` selepas membuat perubahan. |

Jika anda akhirnya membuat banyak perubahan untuk mengubah suai persediaan anda sendiri, adalah idea yang baik untuk membuat sandaran semua dotfiles ini. [Stow ialah cara yang hebat untuk melakukannya](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Memulakan aplikasi anda sendiri bersama sesi

Jika anda mahu sesuatu dijalankan setiap kali anda log masuk — daemon penyegerakan, aplikasi sembang, skrip anda sendiri — letakkannya dalam `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Itu memulakan perintah tersebut sebagai sebahagian daripada sesi, jadi ia dibersihkan dengan betul apabila anda log keluar semula.

### Menjalankan skrip pada peristiwa sistem

Omarchy mencetuskan hook pada beberapa ketika, dan anda boleh menggantung skrip anda sendiri padanya. Ia berada dalam `~/.config/omarchy/hooks/<event>.d/`, satu direktori bagi setiap peristiwa, dan setiap fail boleh laksana di dalamnya akan dijalankan apabila peristiwa itu berlaku:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Sejurus selepas desktop telah dimulakan |
| `post-update` | Hampir pada penghujung `omarchy update`, selepas pakej, migrasi, dan permulaan semula perkhidmatan, sebelum alat mise dikemas kini |
| `pre-refresh-pacman` | Selepas `omarchy refresh pacman` menyegerakkan semula konfigurasi pakej, sebelum ia mengemas kini pakej; pertukaran saluran menjalankannya semasa langkah penyegaran yang sama itu |
| `theme-set` | Selepas perubahan tema (nama tema dalam `$1`) |
| `font-set` | Selepas perubahan fon (nama fon dalam `$1`) |
| `battery-low` | Apabila bateri menjadi rendah (peratusan dalam `$1`) |

Hook `pre-refresh-pacman` ialah tempat repositori tersuai atau baris `IgnorePkg` sepatutnya diletakkan, kerana ia dijalankan sebelum transaksi pakej. Kedua-dua hook berkaitan kemas kini dijalankan sebagai pengguna anda selepas Omarchy mengosongkan kebenaran sudo yang dicachenya, jadi hook yang menggunakan `sudo` memerlukan kebenarannya sendiri dan mungkin meminta kata laluan anda.

Setiap direktori tersebut sudah mengandungi fail `.sample` yang menunjukkan bentuk hook — buang `.sample` daripada namanya untuk menggunakannya. Untuk memasang skrip yang telah anda tulis di tempat lain, gunakan `omarchy hook install post-boot ~/my-hook`, yang menyalinnya masuk dan menjadikannya boleh laksana.

### Menambah entri menu anda sendiri

Menu Omarchy (`Super + Space`) boleh dilanjutkan dengan baris anda sendiri dengan mengedit `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Entri dikunci mengikut id bertitik, dan id itulah yang meletakkannya dalam pokok, jadi `personal` muncul pada menu akar dan `personal.notes` muncul di dalamnya:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Guna semula id yang sedia ada dan anda akan menggantikan baris tersebut dan bukannya menambah baris baharu. Fail ini dihantar dengan semua medan yang tersedia didokumenkan sebagai komen.

### Menambah eksport shell, fungsi, dan alias anda sendiri

Omarchy dihantar dengan sekumpulan alias ergonomik dan fungsi yang membantu, tetapi sangat biasa untuk anda mahu menambah milik anda sendiri. Anda harus menambah alias, fungsi, dan eksport dalam `~/.bashrc`. Fail ini tidak akan ditulis ganti semasa kemas kini. Jika anda mahu menukar mana-mana tetapan lalai Omarchy, anda juga boleh menambahnya di sini dengan selamat.

### Menetapkan pemboleh ubah persekitaran untuk desktop

Eksport sesi desktop sepatutnya berada dalam `~/.config/uwsm/env.d/`. Fail-fail ini dijalankan sebelum desktop anda bermula, jadi ralat shell boleh menghantar anda kembali ke skrin log masuk. Pastikan terminal yang berfungsi kekal terbuka semasa mengeditnya. Untuk melumpuhkan gantian, alihkannya keluar daripada `env.d`. Lihat [pemulihan log masuk](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) jika perubahan menghalang log masuk.

### Mengubah fail dalaman Omarchy

Dengar, ini komputer anda. Anda boleh buat apa sahaja yang anda mahu dengannya, tetapi saya nasihatkan supaya jangan membuat perubahan terus pada fail dalam `/usr/share/omarchy`. Fail-fail itu milik pakej pacman Omarchy, jadi perubahan anda hanya akan ditulis ganti pada kemas kini seterusnya. Lebih baik anda hanya menulis ganti mana-mana nilai lalai yang anda tidak suka dalam folder `~/.config/*` sebaliknya.

Anda boleh mengubah hampir segala-galanya dengan cara itu, seperti pengikatan kekunci lalai. Hanya edit `~/.config/hypr/bindings.lua` untuk, katakan, menggantikan [Obsidian](https://obsidian.md/) dengan [Joplin](https://joplinapp.org/) (pasang dengan `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` membuang pengikatan sedia ada sebelum menambah penggantinya. Ia mengambil argumen yang sama seperti `o.bind`, termasuk pembantu pelancaran dan pilihan pengikatan. Gunakan `o.bind` untuk menambah pengikatan, atau `hl.unbind` untuk membuang satu pengikatan tanpa menggantikannya.

Jika anda berkeras mahu menggodam fail dalaman Omarchy, tukar kepada saluran dev melalui _Update > Channel > Dev_. Itu memautkan Omarchy kepada checkout git bagi kod sumber dalam `~/omarchy`, yang bebas untuk anda ubah sepuas hati anda. Tiada sesiapa di sini yang boleh memberitahu anda apa yang perlu dibuat!

### Menetapkan semula sebarang perubahan

Jika anda akhirnya mengucar-ngacirkan konfigurasi, anda sentiasa boleh mengembalikannya kepada tetapan lalai melalui _Update > Config_ dalam menu Omarchy. Atau dengan menjalankan `omarchy reinstall configs` untuk menetapkan semula semuanya.
