# Dotfiles

Omarchy terutama dikonfigurasi lewat yang namanya dotfiles yang tinggal di `~/.config`. Itu dianggap berkas-berkasmu untuk perubahan-perubahanmu. Berkas-berkas yang tinggal di `/usr/share/omarchy` milik Omarchy sendiri, dan kamu jangan mengutak-atiknya. Jika kamu perlu mengubah apa pun di `/usr/share/omarchy`, kamu sebaiknya menimpa nilainya di `~/.config` saja.

Konfigurasi-konfigurasi kunci bisa diedit langsung dari menu Omarchy (`Super + Space`), seperti _Setup > Keyboard > Keybindings_, _Setup > Input_, dan _Setup > Config > [file]_. Jika kamu melakukannya dengan cara ini, proses apa pun yang perlu dimulai ulang setelah edit konfigurasi akan otomatis dimulai ulang setelah kamu keluar dari editor (Neovim secara default — `:wq`, ingat! — tapi kamu bisa mengubahnya lewat _Setup > Defaults > Editor_).

Berikut daftar berkas-berkas kunci di `~/.config` dan apa yang dikendalikannya:

| Berkas                  | Kegunaan              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Konfigurasi Hyprland utama. Memuat default Omarchy plus berkas-berkas override-mu di bawah ini. [Pelajari lebih lanjut tentang konfigurasi Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Keybindings milikmu sendiri dan override terhadap default. |
| `~/.config/hypr/monitors.lua` | Pengaturan monitor yang tidak dicakup panel monitor, seperti rotasi, mode tambahan, atau membiarkan monitor tetap mati. |
| `~/.config/hypr/input.lua` | Mengendalikan tata letak keyboard, mouse, dan pengaturan trackpad-mu. |
| `~/.config/hypr/looknfeel.lua` | Mengendalikan celah, border, animasi, dan tampilan lainnya. |
| `~/.config/hypr/autostart.lua` | Mengendalikan proses tambahan yang dimulai bersama sesi. |
| `~/.config/omarchy/shell.json` | Mengendalikan shell Omarchy: posisi bar, tata letak, dan widget, plus waktu screensaver, kunci, dan idle. |
| `~/.config/foot/foot.ini` | Mengendalikan terminalmu (foot adalah default-nya). |
| `~/.XCompose` | Mendefinisikan emoji akses cepat dan autocomplete nama/email-mu. Pastikan untuk menjalankan `omarchy-restart-xcompose` setelah membuat perubahan. |

Jika akhirnya kamu membuat banyak perubahan untuk mengutak-atik setup-mu sendiri, ada baiknya membackup semua dotfiles ini. [Stow adalah cara yang bagus untuk melakukannya](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Memulai aplikasi milikmu sendiri bersama sesi

Jika kamu ingin sesuatu berjalan setiap kali kamu login — daemon sinkronisasi, aplikasi chat, script milikmu sendiri — taruh di `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Itu memulai perintah sebagai bagian dari sesi, jadi akan dibersihkan dengan benar saat kamu logout lagi.

### Menjalankan script pada event sistem

Omarchy memicu hooks pada beberapa momen, dan kamu bisa menggantungkan script milikmu sendiri padanya. Hooks tinggal di `~/.config/omarchy/hooks/<event>.d/`, satu direktori per event, dan setiap berkas executable di dalamnya berjalan saat event terjadi:

| Event | Kapan dijalankan |
| ----- | ------------ |
| `post-boot` | Tepat setelah desktop dimulai |
| `post-update` | Menjelang akhir `omarchy update`, setelah paket, migrasi, dan restart service, sebelum tool mise diperbarui |
| `pre-refresh-pacman` | Setelah `omarchy refresh pacman` menyinkronkan ulang konfigurasi paket, sebelum memperbarui paket; pergantian channel menjalankannya selama langkah refresh yang sama itu |
| `theme-set` | Setelah perubahan tema (nama tema di `$1`) |
| `font-set` | Setelah perubahan font (nama font di `$1`) |
| `battery-low` | Saat baterai mulai habis (persentase di `$1`) |

Hook `pre-refresh-pacman` adalah tempat repository kustom atau baris `IgnorePkg` seharusnya berada, karena hook ini berjalan sebelum transaksi paket. Kedua hook terkait update berjalan sebagai penggunamu setelah Omarchy menghapus otorisasi sudo yang di-cache-nya, jadi hook yang menggunakan `sudo` membutuhkan otorisasinya sendiri dan mungkin meminta password-mu.

Masing-masing direktori itu sudah berisi berkas `.sample` yang menunjukkan bentuk sebuah hook — buang `.sample` dari namanya untuk mulai menggunakannya. Untuk menginstal script yang sudah kamu tulis di tempat lain, gunakan `omarchy hook install post-boot ~/my-hook`, yang menyalinnya masuk dan membuatnya executable.

### Menambahkan entri menu milikmu sendiri

Menu Omarchy (`Super + Space`) bisa diperluas dengan baris-baris milikmu sendiri dengan mengedit `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Entri di-key berdasarkan id bertitik, dan id itulah yang menempatkannya di dalam tree, jadi `personal` muncul di menu root dan `personal.notes` muncul di dalamnya:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Gunakan ulang id yang sudah ada dan kamu akan menimpa baris itu alih-alih menambahkan yang baru. Berkas ini disertai semua field yang tersedia yang didokumentasikan sebagai komentar.

### Menambahkan shell exports, functions, dan aliases milikmu sendiri

Omarchy disertai sekumpulan aliases ergonomis dan functions yang membantu, tapi sangat umum orang ingin menambahkan miliknya sendiri. Kamu sebaiknya menambahkan aliases, functions, dan exports di `~/.bashrc`. Berkas ini tidak akan ditimpa pada update. Jika kamu ingin mengubah default Omarchy mana pun, kamu juga bisa dengan aman menambahkannya di sini.

### Mengatur environment variables untuk desktop

Exports sesi desktop seharusnya berada di `~/.config/uwsm/env.d/`. Berkas-berkas ini berjalan sebelum desktop-mu dimulai, jadi error shell bisa mengirimmu kembali ke layar login. Biarkan terminal yang masih berfungsi tetap terbuka saat mengeditnya. Untuk menonaktifkan sebuah override, pindahkan keluar dari `env.d`. Lihat [pemulihan login](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) jika sebuah perubahan membuatmu tidak bisa login.

### Mengubah berkas internal Omarchy

Dengar, ini komputermu. Kamu bisa melakukan apa pun yang kamu mau dengannya, tapi saya sarankan jangan mengubah berkas-berkas di `/usr/share/omarchy` secara langsung. Berkas-berkas itu milik paket pacman Omarchy, jadi perubahanmu hanya akan ditimpa pada update berikutnya. Kamu lebih baik menimpa saja nilai default mana pun yang tidak kamu sukai di folder `~/.config/*`.

Kamu bisa mengubah hampir semuanya dengan cara itu, seperti keybindings default. Cukup edit `~/.config/hypr/bindings.lua` untuk, misalnya, mengganti [Obsidian](https://obsidian.md/) dengan [Joplin](https://joplinapp.org/) (instal dengan `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` menghapus binding yang ada sebelum menambahkan penggantinya. Ia menerima argumen yang sama seperti `o.bind`, termasuk launch helpers dan opsi binding. Gunakan `o.bind` untuk menambahkan binding, atau `hl.unbind` untuk menghapusnya tanpa menggantinya.

Jika kamu bersikeras mengutak-atik berkas internal Omarchy, beralihlah ke channel dev lewat _Update > Channel > Dev_. Itu menautkan Omarchy ke checkout git dari source code di `~/omarchy`, yang bebas kamu ubah sepuas hatimu. Tidak ada siapa pun di sini yang akan menyuruh-nyuruhmu!

### Mengatur ulang semua perubahan

Jika akhirnya kamu mengacaukan konfigurasi, kamu selalu bisa mengembalikannya ke default lewat _Update > Config_ di menu Omarchy. Atau dengan menjalankan `omarchy reinstall configs` untuk mengatur ulang semuanya.
