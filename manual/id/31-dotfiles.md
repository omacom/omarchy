# Dotfiles

Omarchy terutama dikonfigurasi melalui apa yang disebut dotfiles yang berada di `~/.config`. Itu dianggap sebagai berkas milikmu untuk perubahanmu. Berkas yang berada di `/usr/share/omarchy` adalah milik Omarchy itu sendiri, dan kamu tidak seharusnya mengutak-atiknya. Jika kamu perlu mengubah apa pun di `/usr/share/omarchy`, kamu seharusnya menimpa nilainya di `~/.config` sebagai gantinya.

Konfigurasi utama dapat diedit langsung dari menu Omarchy (`Super + Space`), seperti _Setup > Keybindings_, _Setup > Input_, dan _Setup > Config > [file]_. Jika kamu melakukannya dengan cara ini, setiap proses yang perlu dimulai ulang setelah pengeditan konfigurasi akan otomatis dimulai ulang setelah kamu keluar dari editor (Neovim secara bawaan — `:wq`, ingat ya! — tetapi kamu dapat mengubahnya melalui _Setup > Defaults > Editor_).

Berikut daftar berkas utama di `~/.config` dan apa yang dikendalikannya:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Konfigurasi Hyprland utama. Memuat bawaan Omarchy ditambah berkas penimpaan milikmu di bawah ini. [Pelajari lebih lanjut tentang konfigurasi Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Keybinding milikmu sendiri dan penimpaan terhadap bawaannya. |
| `~/.config/hypr/monitors.lua` | Pengaturan monitor yang tidak dicakup panel monitor, seperti rotasi, mode tambahan, atau membiarkan monitor mati. |
| `~/.config/hypr/input.lua` | Mengendalikan tata letak keyboard, mouse, dan pengaturan trackpad kamu. |
| `~/.config/hypr/looknfeel.lua` | Mengendalikan celah, batas, animasi, dan tampilan lainnya. |
| `~/.config/hypr/autostart.lua` | Mengendalikan proses tambahan yang dimulai bersama sesi. |
| `~/.config/omarchy/shell.json` | Mengendalikan shell Omarchy: posisi bar, tata letak, dan widget, ditambah screensaver, kunci, dan waktu idle. |
| `~/.config/foot/foot.ini` | Mengendalikan terminal kamu (foot adalah bawaannya). |
| `~/.XCompose` | Mendefinisikan emoji akses cepat dan pelengkapan otomatis nama/email kamu. Pastikan untuk menjalankan `omarchy-restart-xcompose` setelah membuat perubahan. |

Jika akhirnya kamu membuat banyak perubahan untuk menyesuaikan pengaturanmu sendiri, ada baiknya mencadangkan semua dotfiles ini. [Stow adalah cara yang bagus untuk melakukannya](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Memulai aplikasi milikmu sendiri bersama sesi

Jika kamu ingin sesuatu berjalan setiap kali kamu masuk — daemon sinkronisasi, aplikasi obrolan, skrip milikmu sendiri — letakkan di `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Itu memulai perintah sebagai bagian dari sesi, sehingga dibersihkan dengan benar saat kamu keluar lagi.

### Menjalankan skrip pada peristiwa sistem

Omarchy memicu hook pada beberapa momen, dan kamu dapat menggantungkan skrip milikmu sendiri padanya. Skrip tersebut berada di `~/.config/omarchy/hooks/<event>.d/`, satu direktori per peristiwa, dan setiap berkas yang dapat dieksekusi di dalamnya berjalan saat peristiwa itu terjadi:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Tepat setelah desktop dimulai |
| `post-update` | Menjelang akhir `omarchy update`, setelah paket, migrasi, dan mulai ulang layanan, sebelum perangkat mise diperbarui |
| `pre-refresh-pacman` | Setelah `omarchy refresh pacman` menyinkronkan ulang konfigurasi paket, sebelum memperbarui paket; pergantian saluran menjalankannya selama langkah refresh yang sama itu |
| `theme-set` | Setelah perubahan tema (nama tema di `$1`) |
| `font-set` | Setelah perubahan font (nama font di `$1`) |
| `battery-low` | Saat baterai lemah (persentase di `$1`) |

Hook `pre-refresh-pacman` adalah tempat repositori kustom atau baris `IgnorePkg` seharusnya berada, karena hook ini berjalan sebelum transaksi paket. Kedua hook yang terkait pembaruan berjalan sebagai penggunamu setelah Omarchy menghapus otorisasi sudo yang tersimpan di cache-nya, jadi hook yang menggunakan `sudo` memerlukan otorisasinya sendiri dan mungkin akan meminta kata sandimu.

Masing-masing direktori tersebut sudah berisi berkas `.sample` yang menunjukkan bentuk hook — hapus `.sample` dari namanya untuk mulai menggunakannya. Untuk memasang skrip yang telah kamu tulis di tempat lain, gunakan `omarchy hook install post-boot ~/my-hook`, yang menyalinnya masuk dan membuatnya dapat dieksekusi.

### Menambahkan entri menu milikmu sendiri

Menu Omarchy (`Super + Space`) dapat diperluas dengan baris milikmu sendiri dengan mengedit `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Entri dikunci oleh id bertitik, dan id itulah yang menempatkannya di pohon, jadi `personal` muncul di menu akar dan `personal.notes` muncul di dalamnya:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Gunakan kembali id yang sudah ada dan kamu akan menimpa baris tersebut alih-alih menambahkan yang baru. Berkas ini disertai dengan semua bidang yang tersedia yang didokumentasikan sebagai komentar.

### Menambahkan ekspor shell, fungsi, dan alias milikmu sendiri

Omarchy disertai dengan banyak alias ergonomis dan fungsi yang membantu, tetapi sangat umum jika kamu ingin menambahkan milikmu sendiri. Kamu harus menambahkan alias, fungsi, dan ekspor di `~/.bashrc`. Berkas ini tidak akan ditimpa pada pembaruan. Jika kamu ingin mengubah bawaan Omarchy mana pun, kamu juga dapat menambahkannya dengan aman di sini.

### Mengatur variabel lingkungan untuk desktop

Ekspor sesi desktop berada di `~/.config/uwsm/env.d/`. Berkas-berkas ini berjalan sebelum desktop kamu dimulai, jadi kesalahan shell dapat mengirimmu kembali ke layar masuk. Biarkan terminal yang berfungsi tetap terbuka saat mengeditnya. Untuk menonaktifkan penimpaan, pindahkan keluar dari `env.d`. Lihat [pemulihan login](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) jika perubahan mencegahmu masuk.

### Mengubah berkas internal Omarchy

Dengar, ini komputermu. Kamu dapat melakukan apa pun yang kamu mau dengannya, tetapi aku menyarankan untuk tidak membuat perubahan langsung pada berkas di `/usr/share/omarchy`. Berkas tersebut milik paket pacman Omarchy, jadi perubahanmu hanya akan ditimpa pada pembaruan berikutnya. Lebih baik kamu menimpa saja nilai bawaan apa pun yang tidak kamu sukai di folder `~/.config/*` sebagai gantinya.

Kamu dapat mengubah hampir semuanya dengan cara itu, seperti keybinding bawaan. Cukup edit `~/.config/hypr/bindings.lua` untuk, misalnya, mengganti [Obsidian](https://obsidian.md/) dengan [Joplin](https://joplinapp.org/) (pasang dengan `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` menghapus binding yang ada sebelum menambahkan penggantinya. Ia mengambil argumen yang sama seperti `o.bind`, termasuk pembantu peluncuran dan opsi binding. Gunakan `o.bind` untuk menambahkan binding, atau `hl.unbind` untuk menghapusnya tanpa menggantinya.

Jika kamu bersikeras mengutak-atik berkas internal Omarchy, beralihlah ke saluran dev melalui _Update > Channel > Dev_. Itu menghubungkan Omarchy ke checkout git dari kode sumber di `~/omarchy`, yang bebas kamu ubah sesuka hati. Tidak ada siapa pun di sini yang bisa melarangmu!

### Mengatur ulang perubahan apa pun

Jika akhirnya kamu membuat konfigurasi berantakan, kamu selalu dapat mengembalikannya ke bawaan melalui _Update > Config_ di menu Omarchy. Atau dengan menjalankan `omarchy reinstall configs` untuk mengatur ulang semuanya.
