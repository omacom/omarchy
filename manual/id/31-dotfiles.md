# Dotfiles

Omarchy terutama dikonfigurasi melalui apa yang disebut dotfiles yang berada di `~/.config`. File-file itu dianggap sebagai file milikmu untuk perubahanmu. File-file yang berada di `/usr/share/omarchy` adalah milik Omarchy itu sendiri, dan kamu sebaiknya tidak mengutak-atik file-file itu. Jika kamu perlu mengubah apa pun di `/usr/share/omarchy`, kamu sebaiknya menimpa nilainya di `~/.config` sebagai gantinya.

Konfigurasi utama dapat diedit langsung dari menu Omarchy (`Super + Space`), seperti _Setup > Keybindings_, _Setup > Input_, dan _Setup > Config > [file]_. Jika kamu melakukannya dengan cara ini, setiap proses yang perlu dimulai ulang setelah pengeditan konfigurasi akan otomatis dimulai ulang setelah kamu keluar dari editor (Neovim secara default — `:wq`, ingat! — tetapi kamu dapat mengubahnya melalui _Setup > Defaults > Editor_).

Berikut adalah daftar file utama di `~/.config` dan apa yang dikontrol oleh masing-masing file:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Konfigurasi utama Hyprland. Memuat default Omarchy ditambah file override milikmu di bawah ini. [Pelajari lebih lanjut tentang konfigurasi Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Keybinding milikmu sendiri dan override terhadap default. |
| `~/.config/hypr/monitors.lua` | Pengaturan monitor yang tidak dicakup oleh panel monitor, seperti rotasi, mode tambahan, atau membiarkan monitor tetap mati. |
| `~/.config/hypr/input.lua` | Mengontrol tata letak keyboard, mouse, dan pengaturan trackpad milikmu. |
| `~/.config/hypr/looknfeel.lua` | Mengontrol gap, border, animasi, dan tampilan lainnya. |
| `~/.config/hypr/autostart.lua` | Mengontrol proses tambahan yang dimulai bersama sesi. |
| `~/.config/omarchy/shell.json` | Mengontrol shell Omarchy: posisi bar, tata letak, dan widget, ditambah screensaver, lock, dan timing idle. |
| `~/.config/foot/foot.ini` | Mengontrol terminal milikmu (foot adalah default-nya). |
| `~/.XCompose` | Menentukan emoji akses cepat dan autocomplete nama/email milikmu. Pastikan untuk menjalankan `omarchy-restart-xcompose` setelah membuat perubahan. |

Jika akhirnya kamu membuat banyak perubahan untuk menyesuaikan setup milikmu sendiri, sebaiknya backup semua dotfiles ini. [Stow adalah cara yang bagus untuk melakukannya](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Memulai aplikasi milikmu sendiri bersama sesi

Jika kamu ingin sesuatu berjalan setiap kali kamu login — daemon sinkronisasi, aplikasi chat, script milikmu sendiri — taruh di `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Itu memulai perintah sebagai bagian dari sesi, sehingga dibersihkan dengan benar saat kamu logout lagi.

### Menjalankan script pada event sistem

Omarchy memicu hook pada beberapa momen, dan kamu dapat menggantungkan script milikmu sendiri padanya. Hook-hook itu berada di `~/.config/omarchy/hooks/<event>.d/`, satu direktori per event, dan setiap file yang dapat dieksekusi di dalamnya berjalan saat event itu terjadi:

| Event | Kapan dijalankan |
| ----- | ------------ |
| `post-boot` | Tepat setelah desktop dimulai |
| `post-update` | Menjelang akhir `omarchy update`, setelah paket, migrasi, dan restart service, sebelum tool mise diperbarui |
| `pre-refresh-pacman` | Setelah `omarchy refresh pacman` menyinkronkan ulang konfigurasi paket, sebelum memperbarui paket; pergantian channel menjalankannya selama langkah refresh yang sama itu |
| `theme-set` | Setelah perubahan tema (nama tema di `$1`) |
| `font-set` | Setelah perubahan font (nama font di `$1`) |
| `battery-low` | Saat baterai hampir habis (persentase di `$1`) |

Hook `pre-refresh-pacman` adalah tempat seharusnya repository kustom atau baris `IgnorePkg` berada, karena hook ini berjalan sebelum transaksi paket. Kedua hook terkait update berjalan sebagai user milikmu setelah Omarchy menghapus otorisasi sudo yang di-cache, jadi hook yang menggunakan `sudo` memerlukan otorisasinya sendiri dan mungkin akan meminta password milikmu.

Masing-masing direktori itu sudah berisi file `.sample` yang menunjukkan bentuk sebuah hook — hapus `.sample` dari namanya untuk mulai menggunakannya. Untuk menginstal script yang telah kamu tulis di tempat lain, gunakan `omarchy hook install post-boot ~/my-hook`, yang akan menyalinnya masuk dan membuatnya dapat dieksekusi.

### Menambahkan entri menu milikmu sendiri

Menu Omarchy (`Super + Space`) dapat diperluas dengan baris milikmu sendiri dengan mengedit `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Entri-entri di-key berdasarkan id bertitik, dan id itulah yang menempatkannya di dalam tree, jadi `personal` muncul di menu root dan `personal.notes` muncul di dalamnya:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Gunakan kembali id yang sudah ada dan kamu akan menimpa baris itu alih-alih menambahkan baris baru. File itu disertai semua field yang tersedia yang didokumentasikan sebagai komentar.

### Menambahkan export, function, dan alias shell milikmu sendiri

Omarchy disertai banyak alias ergonomis dan function yang membantu, tetapi sangat umum untuk ingin menambahkan milikmu sendiri. Kamu sebaiknya menambahkan alias, function, dan export di `~/.bashrc`. File ini tidak akan ditimpa saat update. Jika kamu ingin mengubah default Omarchy mana pun, kamu juga dapat menambahkannya dengan aman di sini.

### Mengubah file internal Omarchy

Dengar, ini komputer milikmu. Kamu dapat melakukan apa pun yang kamu mau dengannya, tetapi aku menyarankan untuk tidak membuat perubahan langsung pada file-file di `/usr/share/omarchy`. File-file itu milik paket pacman Omarchy, jadi perubahanmu hanya akan ditimpa pada update berikutnya. Lebih baik kamu menimpa saja nilai default apa pun yang tidak kamu sukai di folder `~/.config/*` sebagai gantinya.

Kamu dapat mengubah hampir segala hal dengan cara itu, seperti keybinding default. Cukup edit `~/.config/hypr/bindings.lua` untuk, misalnya, mengganti [Obsidian](https://obsidian.md/) dengan [Joplin](https://joplinapp.org/) (instal dengan `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` menghapus binding yang sudah ada sebelum menambahkan penggantinya. Ia menerima argumen yang sama seperti `o.bind`, termasuk helper peluncuran dan opsi binding. Gunakan `o.bind` untuk menambahkan binding, atau `hl.unbind` untuk menghapus binding tanpa menggantinya.

Jika kamu bersikeras mengutak-atik file internal Omarchy, beralihlah ke channel dev melalui _Update > Channel > Dev_. Itu menautkan Omarchy ke checkout git dari source code di `~/omarchy`, yang bebas kamu ubah sepuas hatimu. Tidak ada seorang pun di sini yang akan melarangmu!

### Mengatur ulang perubahan apa pun

Jika akhirnya kamu mengacaukan konfigurasi, kamu selalu dapat mengembalikannya ke default melalui _Update > Config_ di menu Omarchy. Atau dengan menjalankan `omarchy reinstall configs` untuk mengatur ulang semuanya.
