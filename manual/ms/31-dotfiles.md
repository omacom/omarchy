# Dotfiles

Omarchy dikonfigurasikan terutamanya melalui fail yang dipanggil dotfiles yang berada dalam `~/.config`. Fail tersebut dianggap sebagai fail anda untuk perubahan anda. Fail yang berada dalam `/usr/share/omarchy` adalah milik Omarchy sendiri, dan anda tidak sepatutnya mengusik fail tersebut. Jika anda perlu mengubah apa-apa dalam `/usr/share/omarchy`, anda sebaliknya patut menulis ganti nilainya dalam `~/.config`.

Konfigurasi utama boleh disunting terus daripada menu Omarchy (`Super + Space`), seperti _Setup > Keybindings_, _Setup > Input_, dan _Setup > Config > [file]_. Apabila anda melakukannya dengan cara ini, mana-mana proses yang perlu dimulakan semula selepas suntingan konfigurasi akan dimulakan semula secara automatik selepas anda keluar daripada editor (Neovim secara lalai — `:wq`, ingat! — tetapi anda boleh mengubahnya melalui _Setup > Defaults > Editor_).

Berikut ialah senarai fail utama dalam `~/.config` dan perkara yang dikawalnya:

| Fail                  | Tujuan              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Konfigurasi utama Hyprland. Memuatkan lalai Omarchy serta fail gantian anda di bawah. [Ketahui lebih lanjut tentang konfigurasi Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Ikatan kekunci anda sendiri dan gantian kepada lalai. |
| `~/.config/hypr/monitors.lua` | Tetapan monitor yang tidak diliputi oleh panel monitor, seperti putaran, mod tambahan, atau memastikan monitor kekal dimatikan. |
| `~/.config/hypr/input.lua` | Mengawal susun atur papan kekunci, tetikus dan tetapan pad jejak anda. |
| `~/.config/hypr/looknfeel.lua` | Mengawal jurang, sempadan, animasi dan selebihnya dari segi penampilan. |
| `~/.config/hypr/autostart.lua` | Mengawal proses tambahan yang dimulakan bersama sesi. |
| `~/.config/omarchy/shell.json` | Mengawal shell Omarchy: kedudukan bar, susun atur dan widget, serta pemasaan penyelamat skrin, kunci dan melahu. |
| `~/.config/foot/foot.ini` | Mengawal terminal anda (foot ialah lalai). |
| `~/.XCompose` | Menentukan emoji capaian pantas dan pelengkapan automatik nama/e-mel anda. Pastikan anda menjalankan `omarchy-restart-xcompose` selepas membuat perubahan. |

Jika akhirnya anda membuat banyak perubahan untuk mengubah suai persediaan anda sendiri, ada baiknya anda menyandarkan semua dotfiles ini. [Stow ialah cara yang baik untuk melakukannya](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Memulakan aplikasi anda sendiri bersama sesi

Jika anda mahu sesuatu dijalankan setiap kali anda log masuk — daemon penyegerakan, aplikasi sembang, skrip anda sendiri — letakkannya dalam `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Itu memulakan arahan tersebut sebagai sebahagian daripada sesi, jadi ia dibersihkan dengan betul apabila anda log keluar semula.

### Menjalankan skrip pada peristiwa sistem

Omarchy mencetuskan hook pada beberapa ketika, dan anda boleh menyambungkan skrip anda sendiri padanya. Ia berada dalam `~/.config/omarchy/hooks/<event>.d/`, satu direktori untuk setiap peristiwa, dan setiap fail boleh laksana di dalamnya akan dijalankan apabila peristiwa itu berlaku:

| Peristiwa | Bila ia dijalankan |
| ----- | ------------ |
| `post-boot` | Sejurus selepas desktop dimulakan |
| `post-update` | Hampir di penghujung `omarchy update`, selepas pakej, migrasi dan permulaan semula perkhidmatan, sebelum alat mise dikemas kini |
| `pre-refresh-pacman` | Selepas `omarchy refresh pacman` menyegerakkan semula konfigurasi pakej, sebelum ia mengemas kini pakej; penukaran saluran menjalankannya semasa langkah penyegaran yang sama itu |
| `theme-set` | Selepas perubahan tema (nama tema dalam `$1`) |
| `font-set` | Selepas perubahan fon (nama fon dalam `$1`) |
| `battery-low` | Apabila bateri semakin lemah (peratusan dalam `$1`) |

Hook `pre-refresh-pacman` ialah tempat repositori tersuai atau baris `IgnorePkg` sepatutnya diletakkan, kerana ia dijalankan sebelum transaksi pakej. Kedua-dua hook berkaitan kemas kini dijalankan sebagai pengguna anda selepas Omarchy mengosongkan kebenaran sudo yang dicache-nya, jadi hook yang menggunakan `sudo` memerlukan kebenarannya sendiri dan mungkin meminta kata laluan anda.

Setiap direktori tersebut sudah mengandungi fail `.sample` yang menunjukkan bentuk hook — buang `.sample` daripada nama untuk menggunakannya. Untuk memasang skrip yang anda tulis di tempat lain, gunakan `omarchy hook install post-boot ~/my-hook`, yang menyalinnya masuk dan menjadikannya boleh dilaksanakan.

### Menambah entri menu anda sendiri

Menu Omarchy (`Super + Space`) boleh diperluaskan dengan baris anda sendiri dengan menyunting `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Entri dikunci mengikut id bertitik, dan id itulah yang menempatkannya dalam pepohon, jadi `personal` muncul pada menu akar dan `personal.notes` muncul di dalamnya:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Guna semula id sedia ada dan anda akan menulis ganti baris tersebut dan bukannya menambah baris baharu. Fail ini dihantar dengan semua medan tersedia yang didokumenkan sebagai komen.

### Menambah eksport shell, fungsi dan alias anda sendiri

Omarchy dihantar dengan sekumpulan alias ergonomik dan fungsi yang membantu, tetapi sangat biasa untuk anda mahu menambah milik anda sendiri. Anda patut menambah alias, fungsi dan eksport dalam `~/.bashrc`. Fail ini tidak akan ditulis ganti semasa kemas kini. Jika anda mahu mengubah mana-mana lalai Omarchy, anda juga boleh menambahnya di sini dengan selamat.

### Mengubah fail dalaman Omarchy

Dengar, ini komputer anda. Anda boleh buat apa sahaja yang anda mahu dengannya, tetapi saya menasihatkan anda supaya tidak membuat perubahan pada fail dalam `/usr/share/omarchy` secara langsung. Fail tersebut adalah milik pakej pacman Omarchy, jadi perubahan anda hanya akan ditulis ganti pada kemas kini seterusnya. Lebih baik anda menulis ganti sahaja mana-mana nilai lalai yang anda tidak suka dalam folder `~/.config/*`.

Anda boleh mengubah hampir segala-galanya dengan cara itu, seperti ikatan kekunci lalai. Sunting sahaja `~/.config/hypr/bindings.lua` untuk, katakan, menggantikan [Obsidian](https://obsidian.md/) dengan [Joplin](https://joplinapp.org/) (pasang dengan `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` membuang ikatan sedia ada sebelum menambah penggantinya. Ia mengambil argumen yang sama seperti `o.bind`, termasuk pembantu pelancaran dan pilihan ikatan. Gunakan `o.bind` untuk menambah ikatan, atau `hl.unbind` untuk membuang ikatan tanpa menggantikannya.

Jika anda berkeras mahu menggodam fail dalaman Omarchy, tukar kepada saluran dev melalui _Update > Channel > Dev_. Itu memautkan Omarchy kepada checkout git kod sumber dalam `~/omarchy`, yang bebas anda ubah sepuas hati anda. Tiada sesiapa di sini yang boleh menentukan apa yang anda perlu buat!

### Menetapkan semula sebarang perubahan

Jika akhirnya anda mengucar-ngacirkan konfigurasi, anda sentiasa boleh mengembalikannya kepada lalai melalui _Update > Config_ dalam menu Omarchy. Atau dengan menjalankan `omarchy reinstall configs` untuk menetapkan semula semuanya.
