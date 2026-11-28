# Dotfiles

Omarchy dikonfigurasikan terutamanya melalui dotfiles yang terletak di `~/.config`. Fail-fail itu dianggap fail anda untuk perubahan anda. Fail-fail yang terletak di `/usr/share/omarchy` adalah milik Omarchy itu sendiri, dan anda tidak sepatutnya mengusik fail-fail tersebut. Jika anda perlu menukar apa-apa di dalam `/usr/share/omarchy`, anda sebaliknya sepatutnya menulis ganti nilai tersebut di dalam `~/.config`.

Konfigurasi-konfigurasi utama boleh disunting terus daripada menu Omarchy (`Super + Space`), seperti _Setup > Keyboard > Keybindings_, _Setup > Input_, dan _Setup > Config > [file]_. Apabila anda melakukannya dengan cara ini, mana-mana proses yang perlu dimulakan semula selepas suntingan konfigurasi akan dimulakan semula secara automatik selepas anda keluar daripada editor (Neovim secara lalai — `:wq`, ingat! — tetapi anda boleh menukarnya melalui _Setup > Defaults > Editor_).

Berikut ialah senarai fail-fail utama di dalam `~/.config` dan perkara yang dikawalnya:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Konfigurasi Hyprland utama. Memuatkan tetapan lalai Omarchy serta fail-fail gantian anda di bawah. [Ketahui lebih lanjut tentang konfigurasi Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Ikatan kekunci anda sendiri dan gantian bagi tetapan lalai. |
| `~/.config/hypr/monitors.lua` | Tetapan monitor yang tidak diliputi oleh panel monitor, seperti putaran, mod tambahan, atau memastikan monitor kekal dimatikan. |
| `~/.config/hypr/input.lua` | Mengawal susun atur papan kekunci, tetikus, dan tetapan pad jejak anda. |
| `~/.config/hypr/looknfeel.lua` | Mengawal jurang, sempadan, animasi, dan selebihnya tentang penampilan. |
| `~/.config/hypr/autostart.lua` | Mengawal proses tambahan yang dimulakan bersama sesi. |
| `~/.config/omarchy/shell.json` | Mengawal shell Omarchy: kedudukan bar, susun atur, dan widget, serta penyelamat skrin, kunci, dan pemasaan melahu. |
| `~/.config/foot/foot.ini` | Mengawal terminal anda (foot ialah lalai). |
| `~/.XCompose` | Mentakrifkan emoji capaian pantas anda dan autolengkap nama/e-mel. Pastikan anda menjalankan `omarchy-restart-xcompose` selepas membuat perubahan. |

Jika akhirnya anda membuat banyak perubahan untuk mengubah suai persediaan anda sendiri, adalah idea yang baik untuk membuat sandaran semua dotfiles ini. [Stow ialah cara yang hebat untuk melakukannya](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Memulakan aplikasi anda sendiri bersama sesi

Jika anda mahu sesuatu berjalan setiap kali anda log masuk — daemon penyegerakan, aplikasi sembang, skrip anda sendiri — letakkannya di dalam `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Itu memulakan perintah tersebut sebagai sebahagian daripada sesi, jadi ia dibersihkan dengan betul apabila anda log keluar semula.

### Menjalankan skrip pada peristiwa sistem

Omarchy mencetuskan hook pada beberapa ketika, dan anda boleh menggantungkan skrip anda sendiri padanya. Ia terletak di dalam `~/.config/omarchy/hooks/<event>.d/`, satu direktori bagi setiap peristiwa, dan setiap fail di dalamnya yang tidak berakhir dengan `.sample` berjalan dengan bash apabila peristiwa itu berlaku:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Sejurus selepas desktop telah bermula |
| `post-update` | Menjelang akhir `omarchy update`, selepas pakej, migrasi, dan permulaan semula perkhidmatan, sebelum alatan mise dikemas kini |
| `pre-refresh-pacman` | Selepas `omarchy refresh pacman` menyegerakkan semula konfigurasi pakej, sebelum ia mengemas kini pakej; penukaran saluran menjalankannya semasa langkah penyegaran semula yang sama itu |
| `theme-set` | Selepas perubahan tema (nama tema dalam `$1`) |
| `font-set` | Selepas perubahan fon (nama fon dalam `$1`) |
| `battery-low` | Apabila bateri menjadi rendah (peratusan dalam `$1`) |

Hook `pre-refresh-pacman` ialah tempat repositori tersuai atau baris `IgnorePkg` sepatutnya berada, kerana ia berjalan sebelum transaksi pakej. Kedua-duanya berjalan sebagai pengguna anda. `post-update` berjalan semasa kebenaran sudo `omarchy update` masih baharu, jadi hook yang menggunakan `sudo` tidak akan meminta kata laluan anda lagi; `pre-refresh-pacman` berjalan sejurus selepas `omarchy refresh pacman` sendiri telah menggunakan sudo.

Setiap direktori tersebut sudah mengandungi fail `.sample` yang menunjukkan bentuk sesuatu hook — buang `.sample` daripada namanya untuk menggunakannya. Untuk memasang skrip yang anda tulis di tempat lain, gunakan `omarchy hook install post-boot ~/my-hook`, yang menyalinnya masuk dan menjadikannya boleh dilaksanakan.

### Menambah entri menu anda sendiri

Menu Omarchy (`Super + Space`) boleh dilanjutkan dengan baris anda sendiri dengan menyunting `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Entri dikunci dengan id bertitik, dan id itulah yang meletakkannya di dalam pepohon, jadi `personal` muncul pada menu akar dan `personal.notes` muncul di dalamnya:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Guna semula id sedia ada dan anda menulis ganti baris tersebut dan bukannya menambah baris baharu. Fail itu disertakan dengan semua medan yang tersedia didokumenkan sebagai komen.

### Menambah eksport shell, fungsi, dan alias anda sendiri

Omarchy disertakan dengan sekumpulan alias ergonomik dan fungsi yang berguna, tetapi sangat biasa untuk mahu menambah milik anda sendiri. Anda sepatutnya menambah kedua-dua alias, fungsi, dan eksport di dalam `~/.bashrc`. Fail ini tidak akan ditulis ganti pada kemas kini. Jika anda mahu menukar mana-mana tetapan lalai Omarchy, anda juga boleh menambahnya di sini dengan selamat.

### Menetapkan pemboleh ubah persekitaran untuk desktop

Eksport sesi desktop sepatutnya berada di dalam `~/.config/uwsm/env.d/`. Fail-fail ini berjalan sebelum desktop anda bermula, jadi ralat shell boleh menghantar anda kembali ke skrin log masuk. Biarkan terminal yang berfungsi terbuka semasa menyuntingnya. Untuk melumpuhkan sesuatu gantian, alihkannya keluar daripada `env.d`. Lihat [pemulihan log masuk](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) jika sesuatu perubahan menghalang log masuk.

### Menukar fail dalaman Omarchy

Dengar, ini komputer anda. Anda boleh buat apa sahaja yang anda mahu dengannya, tetapi saya nasihatkan supaya jangan membuat perubahan pada fail-fail di dalam `/usr/share/omarchy` secara langsung. Ia milik pakej pacman Omarchy, jadi perubahan anda hanya akan ditulis ganti pada kemas kini seterusnya. Lebih baik anda hanya menulis ganti mana-mana nilai lalai yang anda tidak suka di dalam folder `~/.config/*` sebaliknya.

Anda boleh menukar hampir semua perkara dengan cara itu, seperti ikatan kekunci lalai. Hanya sunting `~/.config/hypr/bindings.lua` untuk, katakan, menggantikan [Obsidian](https://obsidian.md/) dengan [Joplin](https://joplinapp.org/) (pasang dengan `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` membuang ikatan sedia ada sebelum menambah penggantinya. Ia mengambil argumen yang sama seperti `o.bind`, termasuk pembantu pelancaran dan pilihan ikatan. Gunakan `o.bind` untuk menambah ikatan, atau `hl.unbind` untuk membuang satu ikatan tanpa menggantikannya.

Jika anda berkeras untuk menggodam fail dalaman Omarchy, tukar kepada saluran dev melalui _Update > Channel > Dev_. Itu memautkan Omarchy kepada checkout git kod sumber di dalam `~/omarchy`, yang bebas anda tukar sepuas hati anda. Tiada sesiapa di sini yang boleh memberitahu anda apa yang perlu dibuat!

### Menetapkan semula sebarang perubahan

Jika akhirnya anda mengucar-ngacirkan konfigurasi, anda sentiasa boleh mengembalikannya kepada tetapan lalai melalui _Update > Config_ dalam menu Omarchy. Atau dengan menjalankan `omarchy reinstall configs` untuk menetapkan semula semuanya.
