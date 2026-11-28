# Dotfiles

Omarchy terutama dikonfigurasi melalui apa yang disebut dotfiles yang berada di `~/.config`. Itu dianggap sebagai file milikmu untuk perubahanmu. File-file yang berada di `/usr/share/omarchy` adalah milik Omarchy itu sendiri, dan kamu tidak seharusnya mengutak-atik file-file tersebut. Jika kamu perlu mengubah apa pun di `/usr/share/omarchy`, kamu sebaiknya menimpa nilainya di `~/.config` sebagai gantinya.

Konfigurasi utama dapat diedit langsung dari menu Omarchy (`Super + Space`), seperti _Setup > Keyboard > Keybindings_, _Setup > Input_, dan _Setup > Config > [file]_. Ketika kamu melakukannya dengan cara ini, proses apa pun yang perlu dimulai ulang setelah pengeditan konfigurasi akan otomatis dimulai ulang setelah kamu keluar dari editor (Neovim secara default — `:wq`, ingat! — tetapi kamu dapat mengubahnya melalui _Setup > Defaults > Editor_).

Berikut daftar file utama di `~/.config` dan apa yang dikontrolnya:

| File                  | Tujuan              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Konfigurasi Hyprland utama. Memuat default Omarchy ditambah file penimpaan milikmu di bawah ini. [Pelajari lebih lanjut tentang konfigurasi Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Keybinding milikmu sendiri dan penimpaan terhadap default. |
| `~/.config/hypr/monitors.lua` | Pengaturan monitor yang tidak dicakup oleh panel monitor, seperti rotasi, mode tambahan, atau membiarkan monitor tetap mati. |
| `~/.config/hypr/input.lua` | Mengontrol tata letak keyboard, mouse, dan pengaturan trackpad-mu. |
| `~/.config/hypr/looknfeel.lua` | Mengontrol celah, batas, animasi, dan tampilan lainnya. |
| `~/.config/hypr/autostart.lua` | Mengontrol proses tambahan yang dimulai bersama sesi. |
| `~/.config/omarchy/shell.json` | Mengontrol shell Omarchy: posisi bar, tata letak, dan widget, ditambah waktu screensaver, penguncian, dan idle. |
| `~/.config/foot/foot.ini` | Mengontrol terminalmu (foot adalah default). |
| `~/.XCompose` | Mendefinisikan emoji akses cepat dan pelengkapan otomatis nama/email milikmu. Pastikan untuk menjalankan `omarchy-restart-xcompose` setelah membuat perubahan. |

Jika akhirnya kamu membuat banyak perubahan untuk menyesuaikan pengaturanmu sendiri, ada baiknya mencadangkan semua dotfiles ini. [Stow adalah cara yang bagus untuk melakukannya](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Memulai aplikasi milikmu sendiri bersama sesi

Jika kamu ingin sesuatu berjalan setiap kali kamu masuk — daemon sinkronisasi, aplikasi obrolan, skrip milikmu sendiri — letakkan di `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Itu memulai perintah tersebut sebagai bagian dari sesi, sehingga dibersihkan dengan benar ketika kamu keluar lagi.

### Menjalankan skrip pada peristiwa sistem

Omarchy memicu hook pada beberapa momen, dan kamu dapat menggantungkan skrip milikmu sendiri padanya. Skrip-skrip itu berada di `~/.config/omarchy/hooks/<event>.d/`, satu direktori per peristiwa, dan setiap file di sana yang tidak berakhiran `.sample` dijalankan dengan bash ketika peristiwa itu terjadi:

| Peristiwa | Kapan dijalankan |
| ----- | ------------ |
| `post-boot` | Tepat setelah desktop dimulai |
| `post-update` | Menjelang akhir `omarchy update`, setelah paket, migrasi, dan mulai ulang layanan, sebelum alat mise diperbarui |
| `pre-refresh-pacman` | Setelah `omarchy refresh pacman` menyinkronkan ulang konfigurasi paket, sebelum memperbarui paket; peralihan kanal menjalankannya selama langkah refresh yang sama itu |
| `theme-set` | Setelah perubahan tema (nama tema di `$1`) |
| `font-set` | Setelah perubahan font (nama font di `$1`) |
| `battery-low` | Ketika baterai hampir habis (persentase di `$1`) |

Hook `pre-refresh-pacman` adalah tempat repositori kustom atau baris `IgnorePkg` seharusnya berada, karena ia berjalan sebelum transaksi paket. Keduanya berjalan sebagai penggunamu. `post-update` berjalan selagi otorisasi sudo dari `omarchy update` masih berlaku, jadi hook yang menggunakan `sudo` tidak akan meminta kata sandimu lagi; `pre-refresh-pacman` berjalan tepat setelah `omarchy refresh pacman` menggunakan sudo itu sendiri.

Masing-masing direktori tersebut sudah berisi file `.sample` yang menunjukkan bentuk sebuah hook — hapus `.sample` dari namanya untuk menggunakannya. Untuk memasang skrip yang telah kamu tulis di tempat lain, gunakan `omarchy hook install post-boot ~/my-hook`, yang menyalinnya masuk dan membuatnya dapat dieksekusi.

### Menambahkan entri menu milikmu sendiri

Menu Omarchy (`Super + Space`) dapat diperluas dengan baris milikmu sendiri dengan mengedit `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Entri-entri dikunci oleh id bertitik, dan id itulah yang menempatkannya di pohon, jadi `personal` muncul di menu akar dan `personal.notes` muncul di dalamnya:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Gunakan kembali id yang sudah ada dan kamu menimpa baris tersebut alih-alih menambahkan yang baru. File ini disertai semua field yang tersedia yang didokumentasikan sebagai komentar.

### Menambahkan ekspor shell, fungsi, dan alias milikmu sendiri

Omarchy disertai sejumlah alias ergonomis dan fungsi yang membantu, tetapi sangat umum untuk ingin menambahkan milikmu sendiri. Kamu sebaiknya menambahkan alias, fungsi, dan ekspor di `~/.bashrc`. File ini tidak akan ditimpa saat pembaruan. Jika kamu ingin mengubah default Omarchy mana pun, kamu juga dapat dengan aman menambahkannya di sini.

### Mengatur variabel lingkungan untuk desktop

Ekspor sesi desktop berada di `~/.config/uwsm/env.d/`. File-file ini dijalankan sebelum desktop-mu dimulai, jadi kesalahan shell dapat mengirimmu kembali ke layar login. Biarkan terminal yang berfungsi tetap terbuka selagi mengeditnya. Untuk menonaktifkan penimpaan, pindahkan keluar dari `env.d`. Lihat [pemulihan login](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) jika perubahan mencegah login.

### Mengubah file internal Omarchy

Dengar, ini komputermu. Kamu dapat melakukan apa pun yang kamu mau dengannya, tetapi aku menyarankan untuk tidak membuat perubahan langsung pada file-file di `/usr/share/omarchy`. File-file itu milik paket pacman Omarchy, jadi perubahanmu hanya akan ditimpa pada pembaruan berikutnya. Lebih baik kamu hanya menimpa nilai default apa pun yang tidak kamu sukai di folder `~/.config/*` sebagai gantinya.

Kamu dapat mengubah hampir semuanya dengan cara itu, seperti keybinding default. Cukup edit `~/.config/hypr/bindings.lua` untuk, misalnya, mengganti [Obsidian](https://obsidian.md/) dengan [Joplin](https://joplinapp.org/) (pasang dengan `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` menghapus binding yang ada sebelum menambahkan penggantinya. Ia menerima argumen yang sama seperti `o.bind`, termasuk helper peluncuran dan opsi binding. Gunakan `o.bind` untuk menambahkan binding, atau `hl.unbind` untuk menghapusnya tanpa menggantinya.

Jika kamu bersikeras mengutak-atik file internal Omarchy, beralihlah ke kanal dev melalui _Update > Channel > Dev_. Itu menautkan Omarchy ke checkout git dari kode sumber di `~/omarchy`, yang bebas kamu ubah sepuas hatimu. Tidak ada siapa pun di sini yang akan melarangmu!

### Mengatur ulang perubahan apa pun

Jika akhirnya kamu membuat konfigurasi menjadi berantakan, kamu selalu dapat mengembalikannya ke default melalui _Update > Config_ di menu Omarchy. Atau dengan menjalankan `omarchy reinstall configs` untuk mengatur ulang semuanya.
