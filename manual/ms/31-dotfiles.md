# Dotfiles

Omarchy kebanyakannya dikonfigurasikan melalui dotfiles yang dipanggil yang berada dalam `~/.config`. Itu dianggap fail anda untuk perubahan anda. Fail yang berada dalam `/usr/share/omarchy` milik Omarchy itu sendiri, dan anda tidak patut mengacaunya. Jika anda perlu mengubah apa-apa dalam `/usr/share/omarchy`, anda patut menindih nilai dalam `~/.config` sebaliknya.

Konfigurasi utama boleh disunting terus daripada menu Omarchy (`Super + Space`), seperti _Persediaan > Monitor_, _Persediaan > Ikatan Kekunci_, _Persediaan > Input_, dan _Persediaan > Konfig > [file]_. Apabila anda melakukannya dengan cara ini, mana-mana proses yang perlu dimulakan semula selepas penyuntingan konfigurasi secara automatik akan dimulakan semula selepas anda keluar daripada penyunting (Neovim secara lalai — `:wq`, ingat! — tetapi anda boleh mengubahnya melalui _Persediaan > Lalai > Penyunting_).

Berikut ialah senarai fail utama dalam `~/.config` dan apa yang ia kawal:

| Fail                  | Tujuan              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Konfigurasi utama Hyprland. Memuatkan lalai Omarchy ditambah fail gantian anda di bawah. [Ketahui lebih lanjut mengenai konfigurasi Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Ikatan kekunci anda sendiri dan gantian lalai. |
| `~/.config/hypr/monitors.lua` | Mengawal monitor, resolusi, dan kedudukan anda. |
| `~/.config/hypr/input.lua` | Mengawal susun atur papan kekunci, tetikus, dan tetapan pad sentuh anda. |
| `~/.config/hypr/looknfeel.lua` | Mengawal jurang, sempadan, animasi, dan penampilan selebihnya. |
| `~/.config/hypr/autostart.lua` | Mengawal proses tambahan yang dimulakan bersama sesi. |
| `~/.config/omarchy/shell.json` | Mengawal shell Omarchy: kedudukan bar, susun atur, dan widget, ditambah masa tabir skrin, kunci, dan tidak aktif. |
| `~/.config/foot/foot.ini` | Mengawal terminal anda (foot ialah lalai). |
| `~/.XCompose` | Mentakrifkan emoji akses pantas anda dan autolengkap nama/e-mel. Pastikan untuk menjalankan `omarchy-restart-xcompose` selepas membuat perubahan. |

Jika anda membuat banyak perubahan untuk menyesuaikan persediaan anda sendiri, adalah idea yang baik untuk membuat sandaran semua dotfiles ini. [Stow ialah cara yang hebat untuk melakukannya](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Memulakan aplikasi anda sendiri bersama sesi

Jika anda mahu sesuatu berjalan setiap kali anda log masuk — daemon segerak, aplikasi sembang, skrip anda sendiri — letakkannya dalam `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Itu memulakan perintah sebagai sebahagian daripada sesi, supaya ia dibersihkan dengan betul apabila anda log keluar semula.

### Menjalankan skrip pada acara sistem

Omarchy melepaskan hook pada beberapa ketika, dan anda boleh menggantung skrip anda sendiri daripadanya. Ia berada dalam `~/.config/omarchy/hooks/<event>.d/`, satu direktori bagi setiap acara, dan setiap fail boleh laksana di dalamnya berjalan apabila acara berlaku:

| Acara | Bila ia berjalan |
| ----- | ------------ |
| `post-boot` | Betul-betul selepas desktop bermula |
| `post-update` | Berhampiran hujung `omarchy update`, selepas pakej, migrasi, dan mula semula perkhidmatan, sebelum alatan mise dikemas kini |
| `pre-refresh-pacman` | Selepas `omarchy refresh pacman` menyegerak semula konfigurasi pakej, sebelum ia mengemas kini pakej; penukaran saluran menjalankannya semasa langkah segar semula yang sama |
| `theme-set` | Selepas pertukaran tema (nama tema dalam `$1`) |
| `font-set` | Selepas pertukaran fon (nama fon dalam `$1`) |
| `battery-low` | Apabila bateri menjadi rendah (peratusan dalam `$1`) |

Hook `pre-refresh-pacman` adalah tempat repositori tersuai atau baris `IgnorePkg` patut berada, kerana ia berjalan sebelum transaksi pakej. Kedua-dua hook berkaitan kemas kini berjalan sebagai pengguna anda selepas Omarchy mengosongkan kebenaran sudo yang dicache-nya, jadi hook yang menggunakan `sudo` memerlukan kebenarannya sendiri dan mungkin meminta kata laluan anda.

Setiap direktori itu sudah mengandungi fail `.sample` yang menunjukkan bentuk hook — buang `.sample` daripada nama untuk menggunakannya. Untuk memasang skrip yang telah anda tulis di tempat lain, gunakan `omarchy hook install post-boot ~/my-hook`, yang menyalinnya dan menjadikannya boleh laksana.

### Menambah entri menu anda sendiri

Menu Omarchy (`Super + Space`) boleh dilanjutkan dengan baris anda sendiri dengan menyunting `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Entri dikunci oleh id bertitik, dan id ialah apa yang meletakkannya dalam pokok, jadi `personal` muncul pada menu akar dan `personal.notes` muncul di dalamnya:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Gunakan semula id sedia ada dan anda mengatasinya untuk baris itu bukannya menambah yang baharu. Fail ini dihantar dengan semua medan tersedia didokumenkan sebagai komen.

### Menambah eksport shell, fungsi, dan alias anda sendiri

Omarchy dilengkapi dengan banyak alias ergonomik dan fungsi yang membantu, tetapi sangat biasa untuk mahu menambah milik anda sendiri. Anda patut menambah alias, fungsi, dan eksport dalam `~/.bashrc`. Fail ini tidak akan ditimpa semasa kemas kini. Jika anda ingin mengubah mana-mana lalai Omarchy, anda juga boleh menambahnya dengan selamat di sini.

### Mengubah fail dalaman Omarchy

Dengar sini, ini komputer anda. Anda boleh melakukan apa sahaja yang anda mahu dengannya, tetapi saya akan menasihatkan agar tidak membuat perubahan pada fail dalam `/usr/share/omarchy` secara langsung. Ia milik pakej pacman Omarchy, jadi perubahan anda hanya akan ditimpa pada kemas kini seterusnya. Anda lebih baik hanya menindih mana-mana nilai lalai yang anda tidak suka dalam folder `~/.config/*` sebaliknya.

Anda boleh mengubah hampir semua perkara dengan cara itu, seperti ikatan kekunci lalai. Sunting sahaja `~/.config/hypr/bindings.lua` untuk, katakan, menggantikan [Obsidian](https://obsidian.md/) dengan [Joplin](https://joplinapp.org/) (pasang dengan `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` membuang ikatan sedia ada sebelum menambah penggantinya. Ia menerima argumen yang sama seperti `o.bind`, termasuk pembantu pelancaran dan pilihan ikatan. Gunakan `o.bind` untuk menambah ikatan, atau `hl.unbind` untuk membuang satu tanpa menggantikannya.

Jika anda berkeras mahu menggodam fail dalaman Omarchy, tukar kepada saluran dev melalui _Kemas Kini > Saluran > Dev_. Itu menghubungkan Omarchy ke checkout git kod sumber di `~/omarchy`, yang bebas anda ubah sepuas hati. Tiada sesiapa di sini untuk memberitahu anda apa yang perlu dilakukan!

### Menetapkan semula sebarang perubahan

Jika anda akhirnya membuat kekacauan pada konfigurasi, anda sentiasa boleh mengembalikannya kepada lalai melalui _Kemas Kini > Konfig_ dalam menu Omarchy. Atau dengan menjalankan `omarchy reinstall configs` untuk menetapkan semula semuanya.
