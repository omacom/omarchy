# Dotfile

Omarchy terutama dikonfigurasi melalui apa yang disebut dotfile yang berada di `~/.config`. Itu dianggap berkasmu untuk perubahanmu. Berkas yang berada di `/usr/share/omarchy` milik Omarchy itu sendiri, dan kamu tidak boleh mengutak-atik itu. Jika kamu perlu mengubah apa pun di `/usr/share/omarchy`, kamu harus menimpa nilainya di `~/.config` sebagai gantinya.

Konfigurasi kunci dapat diedit langsung dari menu Omarchy (`Super + Space`), seperti _Pengaturan > Monitor_, _Pengaturan > Pintasan Tombol_, _Pengaturan > Masukan_, dan _Pengaturan > Config > [file]_. Saat kamu melakukannya dengan cara ini, proses apa pun yang perlu dimulai ulang setelah pengeditan konfigurasi secara otomatis akan setelah kamu keluar dari editor (Neovim secara bawaan — `:wq`, ingat! — tetapi kamu dapat mengubahnya melalui _Pengaturan > Defaults > Editor_).

Berikut daftar berkas kunci di `~/.config` dan apa yang mereka kendalikan:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Konfigurasi utama Hyprland. Memuat bawaan Omarchy ditambah berkas timpaanmu di bawah ini. [Pelajari lebih lanjut tentang konfigurasi Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Pintasan tombolmu sendiri dan timpaan dari bawaan. |
| `~/.config/hypr/monitors.lua` | Mengendalikan monitor, resolusi, dan posisimu. |
| `~/.config/hypr/input.lua` | Mengendalikan tata letak keyboard, mouse, dan pengaturan trackpad-mu. |
| `~/.config/hypr/looknfeel.lua` | Mengendalikan celah, batas, animasi, dan tampilan lainnya. |
| `~/.config/hypr/autostart.lua` | Mengendalikan proses ekstra yang dimulai dengan sesi. |
| `~/.config/omarchy/shell.json` | Mengendalikan shell Omarchy: posisi bilah, tata letak, dan widget, ditambah screensaver, kunci, dan waktu diam. |
| `~/.config/foot/foot.ini` | Mengendalikan terminalmu (foot adalah bawaan). |
| `~/.XCompose` | Mendefinisikan emoji akses cepat dan pelengkapan nama/email-mu. Pastikan menjalankan `omarchy-restart-xcompose` setelah membuat perubahan. |

Jika kamu akhirnya membuat banyak perubahan untuk menyesuaikan penyiapanmu sendiri, itu ide yang bagus untuk mencadangkan semua dotfile ini. [Stow adalah cara yang bagus untuk melakukannya](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Memulai aplikasi sendiri dengan sesi

Jika kamu menginginkan sesuatu berjalan setiap kali kamu masuk — daemon sinkronisasi, aplikasi obrolan, skripmu sendiri — taruh di `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Itu memulai perintah sebagai bagian dari sesi, jadi dibersihkan dengan baik saat kamu keluar lagi.

### Menjalankan skrip pada acara sistem

Omarchy menembakkan hook pada segelintir momen, dan kamu dapat menggantungkan skripmu sendiri padanya. Mereka berada di `~/.config/omarchy/hooks/<event>.d/`, satu direktori per acara, dan setiap berkas yang dapat dieksekusi di sana berjalan saat acara terjadi:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Tepat setelah desktop dimulai |
| `post-update` | Mendekati akhir `omarchy update`, setelah paket, migrasi, dan mulai ulang layanan, sebelum alat mise diperbarui |
| `pre-refresh-pacman` | Setelah `omarchy refresh pacman` menyinkronkan ulang konfigurasi paket, sebelum memperbarui paket; pergantian saluran menjalankannya selama langkah refresh yang sama tersebut |
| `theme-set` | Setelah perubahan tema (nama tema di `$1`) |
| `font-set` | Setelah perubahan font (nama font di `$1`) |
| `battery-low` | Saat baterai mulai rendah (persentase di `$1`) |

Hook `pre-refresh-pacman` adalah tempat repositori kustom atau baris `IgnorePkg` berada, karena berjalan sebelum transaksi paket. Kedua hook terkait pembaruan berjalan sebagai penggunamu setelah Omarchy menghapus otorisasi sudo yang di-cache-nya, jadi hook yang menggunakan `sudo` membutuhkan otorisasinya sendiri dan mungkin meminta kata sandimu.

Masing-masing direktori tersebut sudah menyimpan berkas `.sample` yang menunjukkan bentuk hook — hilangkan `.sample` dari nama untuk mempekerjakannya. Untuk memasang skrip yang telah kamu tulis di tempat lain, gunakan `omarchy hook install post-boot ~/my-hook`, yang menyalinnya masuk dan membuatnya dapat dieksekusi.

### Menambahkan entri menumu sendiri

Menu Omarchy (`Super + Space`) dapat diperluas dengan barismu sendiri dengan mengedit `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Entri dikunci dengan id bertitik, dan id adalah yang menempatkannya di pohon, jadi `personal` muncul di menu akar dan `personal.notes` muncul di dalamnya:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Gunakan kembali id yang ada dan kamu menimpa baris tersebut alih-alih menambahkan yang baru. Berkas dilengkapi dengan semua bidang yang tersedia didokumentasikan sebagai komentar.

### Menambahkan ekspor shell, fungsi, dan aliasmu sendiri

Omarchy dilengkapi dengan berbagai alias ergonomis dan fungsi yang membantu, tetapi sangat umum ingin menambahkan milikmu sendiri. Kamu harus menambahkan alias, fungsi, dan ekspor di `~/.bashrc`. Berkas ini tidak akan ditimpa pada pembaruan. Jika kamu ingin mengubah bawaan Omarchy apa pun, kamu juga dapat dengan aman menambahkannya di sini.

### Mengubah berkas internal Omarchy

Dengar, ini komputermu. Kamu dapat melakukan apa pun yang kamu inginkan dengannya, tetapi saya akan menyarankan untuk tidak membuat perubahan pada berkas di `/usr/share/omarchy` secara langsung. Mereka milik paket pacman Omarchy, jadi perubahanmu hanya akan ditimpa pada pembaruan berikutnya. Kamu lebih baik hanya menimpa nilai bawaan apa pun yang tidak kamu sukai di folder `~/.config/*` sebagai gantinya.

Kamu dapat mengubah hampir semuanya dengan cara itu, seperti pintasan tombol bawaan. Cukup edit `~/.config/hypr/bindings.lua` untuk, misalnya, mengganti [Obsidian](https://obsidian.md/) dengan [Joplin](https://joplinapp.org/) (pasang dengan `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` menghapus ikatan yang ada sebelum menambahkan penggantinya. Ini mengambil argumen yang sama seperti `o.bind`, termasuk helper peluncuran dan pilihan ikatan. Gunakan `o.bind` untuk menambahkan ikatan, atau `hl.unbind` untuk menghapus satu tanpa menggantinya.

Jika kamu bersikeras mengutak-atik berkas internal Omarchy, beralihlah ke saluran dev melalui _Perbarui > Channel > Dev_. Itu menghubungkan Omarchy ke checkout git dari kode sumber di `~/omarchy`, yang bebas kamu ubah sepuas hatimu. Tidak ada siapa pun di sini yang memberitahumu apa yang harus dilakukan!

### Mengatur ulang perubahan apa pun

Jika kamu akhirnya membuat kekacauan pada konfigurasi, kamu selalu dapat mengembalikannya ke bawaan melalui _Perbarui > Config_ di menu Omarchy. Atau dengan menjalankan `omarchy reinstall configs` untuk mengatur ulang semuanya.
