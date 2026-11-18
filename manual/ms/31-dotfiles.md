# Dotfiles

Omarchy dikonfigurasikan terutamanya melalui fail yang dipanggil dotfiles yang berada dalam `~/.config`. Fail tersebut dianggap sebagai fail anda untuk perubahan anda. Fail yang berada dalam `/usr/share/omarchy` kepunyaan Omarchy sendiri, dan anda tidak sepatutnya mengusik fail tersebut. Jika anda perlu menukar apa-apa dalam `/usr/share/omarchy`, anda sepatutnya menulis ganti nilainya dalam `~/.config` sebaliknya.

Konfigurasi utama boleh disunting terus dari menu Omarchy (`Super + Space`), seperti _Persediaan > Papan Kekunci > Pengikatan Kekunci_, _Persediaan > Input_, dan _Persediaan > Konfigurasi > [file]_. Apabila anda melakukannya dengan cara ini, mana-mana proses yang perlu dimulakan semula selepas suntingan konfigurasi akan dimulakan semula secara automatik selepas anda keluar dari editor (Neovim secara lalai — `:wq`, ingat! — tetapi anda boleh menukarnya melalui _Persediaan > Lalai > Editor_).

Berikut ialah senarai fail utama dalam `~/.config` dan perkara yang dikawalnya:

| Fail                  | Tujuan              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Konfigurasi utama Hyprland. Memuatkan tetapan lalai Omarchy serta fail gantian anda di bawah. [Ketahui lebih lanjut tentang konfigurasi Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Pengikatan kekunci anda sendiri dan gantian kepada tetapan lalai. |
| `~/.config/hypr/monitors.lua` | Tetapan monitor yang tidak diliputi oleh panel monitor, seperti putaran, mod tambahan, atau memastikan monitor kekal dimatikan. |
| `~/.config/hypr/input.lua` | Mengawal susun atur papan kekunci, tetikus, dan tetapan pad jejak anda. |
| `~/.config/hypr/looknfeel.lua` | Mengawal jurang, sempadan, animasi, dan selebihnya tentang rupa. |
| `~/.config/hypr/autostart.lua` | Mengawal proses tambahan yang dimulakan bersama sesi. |
| `~/.config/omarchy/shell.json` | Mengawal cangkerang Omarchy: kedudukan bar, susun atur, dan widget, serta masa penyelamat skrin, kunci, dan leka. |
| `~/.config/foot/foot.ini` | Mengawal terminal anda (foot ialah lalai). |
| `~/.XCompose` | Mentakrifkan emoji capaian pantas dan pelengkapan automatik nama/e-mel anda. Pastikan anda menjalankan `omarchy-restart-xcompose` selepas membuat perubahan. |

Jika anda akhirnya membuat banyak perubahan untuk mengubah suai persediaan anda sendiri, adalah idea yang baik untuk menyandarkan semua dotfiles ini. [Stow ialah cara yang hebat untuk melakukannya](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Memulakan aplikasi anda sendiri bersama sesi

Jika anda mahu sesuatu berjalan setiap kali anda log masuk — daemon penyegerakan, aplikasi sembang, skrip anda sendiri — letakkannya dalam `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Itu memulakan perintah tersebut sebagai sebahagian daripada sesi, jadi ia dibersihkan dengan betul apabila anda log keluar semula.

### Menjalankan skrip pada peristiwa sistem

Omarchy mencetuskan hook pada beberapa ketika, dan anda boleh menggantungkan skrip anda sendiri padanya. Skrip tersebut berada dalam `~/.config/omarchy/hooks/<event>.d/`, satu direktori bagi setiap peristiwa, dan setiap fail boleh laksana di dalamnya berjalan apabila peristiwa itu berlaku:

| Peristiwa | Bila ia berjalan |
| ----- | ------------ |
| `post-boot` | Sejurus selepas desktop dimulakan |
| `post-update` | Hampir di penghujung `omarchy update`, selepas pakej, migrasi, dan permulaan semula perkhidmatan, sebelum alatan mise dikemas kini |
| `pre-refresh-pacman` | Selepas `omarchy refresh pacman` menyegerakkan semula konfigurasi pakej, sebelum ia mengemas kini pakej; pertukaran saluran menjalankannya semasa langkah penyegaran yang sama itu |
| `theme-set` | Selepas perubahan tema (nama tema dalam `$1`) |
| `font-set` | Selepas perubahan fon (nama fon dalam `$1`) |
| `battery-low` | Apabila bateri menjadi rendah (peratusan dalam `$1`) |

Hook `pre-refresh-pacman` ialah tempat repositori tersuai atau baris `IgnorePkg` patut diletakkan, kerana ia berjalan sebelum transaksi pakej. Kedua-dua hook berkaitan kemas kini berjalan sebagai pengguna anda selepas Omarchy mengosongkan kebenaran sudo yang tersimpan dalam cachenya, jadi hook yang menggunakan `sudo` memerlukan kebenarannya sendiri dan mungkin meminta kata laluan anda.

Setiap direktori tersebut sudah mempunyai fail `.sample` yang menunjukkan bentuk hook — buang `.sample` daripada namanya untuk menggunakannya. Untuk memasang skrip yang anda tulis di tempat lain, gunakan `omarchy hook install post-boot ~/my-hook`, yang menyalinnya masuk dan menjadikannya boleh dilaksanakan.

### Menambah entri menu anda sendiri

Menu Omarchy (`Super + Space`) boleh diperluaskan dengan baris anda sendiri dengan menyunting `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Entri dikunci oleh id bertitik, dan id itulah yang meletakkannya dalam pepohon, jadi `personal` muncul pada menu akar dan `personal.notes` muncul di dalamnya:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Gunakan semula id yang sedia ada dan anda menulis ganti baris tersebut dan bukannya menambah baris baharu. Fail ini disertakan dengan semua medan yang tersedia didokumenkan sebagai komen.

### Menambah export, fungsi, dan alias cangkerang anda sendiri

Omarchy disertakan dengan sekumpulan alias ergonomik dan fungsi yang membantu, tetapi sangat biasa untuk mahu menambah milik anda sendiri. Anda patut menambah alias, fungsi, dan export dalam `~/.bashrc`. Fail ini tidak akan ditulis ganti semasa kemas kini. Jika anda mahu menukar mana-mana tetapan lalai Omarchy, anda juga boleh menambahkannya dengan selamat di sini.

### Menetapkan pemboleh ubah persekitaran untuk desktop

Export sesi desktop tergolong dalam `~/.config/uwsm/env.d/`. Fail ini berjalan sebelum desktop anda bermula, jadi ralat cangkerang boleh menghantar anda kembali ke skrin log masuk. Biarkan terminal yang berfungsi terbuka semasa menyuntingnya. Untuk melumpuhkan gantian, alihkannya keluar dari `env.d`. Lihat [pemulihan log masuk](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) jika perubahan menghalang log masuk.

### Menukar fail dalaman Omarchy

Dengar, ini komputer anda. Anda boleh buat apa sahaja yang anda mahu dengannya, tetapi saya nasihatkan agar tidak membuat perubahan pada fail dalam `/usr/share/omarchy` secara langsung. Fail tersebut kepunyaan pakej pacman Omarchy, jadi perubahan anda hanya akan ditulis ganti pada kemas kini seterusnya. Lebih baik anda hanya menulis ganti mana-mana nilai lalai yang anda tidak suka dalam folder `~/.config/*` sebaliknya.

Anda boleh menukar hampir semua perkara dengan cara itu, seperti pengikatan kekunci lalai. Hanya sunting `~/.config/hypr/bindings.lua` untuk, katakan, menggantikan [Obsidian](https://obsidian.md/) dengan [Joplin](https://joplinapp.org/) (pasang dengan `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` mengalih keluar pengikatan sedia ada sebelum menambah penggantinya. Ia mengambil argumen yang sama seperti `o.bind`, termasuk pembantu pelancaran dan pilihan pengikatan. Gunakan `o.bind` untuk menambah pengikatan, atau `hl.unbind` untuk mengalih keluar satu pengikatan tanpa menggantikannya.

Jika anda berkeras mahu menggodam fail dalaman Omarchy, tukar kepada saluran dev melalui _Kemas Kini > Saluran > Dev_. Itu memautkan Omarchy kepada checkout git kod sumber dalam `~/omarchy`, yang bebas anda ubah sesuka hati anda. Tiada sesiapa di sini untuk memberitahu anda apa yang patut dibuat!

### Menetapkan semula sebarang perubahan

Jika anda akhirnya mengucar-ngacirkan konfigurasi, anda sentiasa boleh mengembalikannya kepada tetapan lalai melalui _Kemas Kini > Konfigurasi_ dalam menu Omarchy. Atau dengan menjalankan `omarchy reinstall configs` untuk menetapkan semula semuanya.
