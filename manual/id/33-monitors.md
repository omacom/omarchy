# Monitor

Omarchy mengasumsikan secara default Anda menggunakan layar kelas retina yang mampu 2x. Inilah yang Anda butuhkan untuk mendapatkan font pemrograman yang bagus dan tajam itu. Inilah yang dioptimalkan oleh hampir semua laptop premium baru dengan layar beresolusi tinggi. Inilah yang ingin Anda gunakan pada [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 27" 5K atau [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 32" 6K.

Namun jika Anda tidak menggunakan layar dengan PPI sebesar 218 atau lebih, Anda perlu mengubah pengaturan monitor. Misalnya, jika Anda memiliki layar 4K 27" atau 32", Anda dapat menggunakan penskalaan fraksional dengan membuka `~/.config/hypr/monitors.lua` (melalui _Setup > Monitors_ di menu Omarchy) dan beralih ke rekomendasi untuk kombinasi tersebut:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Jika Anda menggunakan layar 1080p atau 1440p, Anda mungkin hanya ingin menggunakan penskalaan 1x, jadi Anda dapat menggunakan:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Perubahan pada `GDK_SCALE` berlaku untuk aplikasi yang dimulai setelah perubahan (dan GTK hanya menerima bilangan bulat, jadi tetapkan pada bilangan bulat terdekat dari skala monitor Anda). Jadi pastikan Anda menutup jendela yang ukurannya terlalu besar setelah perubahan (atau tutup semua jendela dengan `Ctrl + Alt + Del`!).

Anda juga dapat dengan cepat menelusuri rasio penskalaan monitor utama (1x, 1.25x, 1.6x, 2x, 3x, 4x) menggunakan `Super + /` untuk naik dan `Super + Alt + /` untuk turun. Jika Anda memiliki konfigurasi default, perubahan ini juga akan bertahan setelah reboot.

### Membuat teks lebih besar atau lebih kecil

Penskalaan monitor mengubah ukuran semuanya. Jika yang Anda inginkan hanyalah _teks_ yang lebih besar atau lebih kecil, ada satu kenop untuk itu:

```
omarchy display text size 14
```

Perintah itu menerima ukuran piksel antara 9 dan 20, dan mengubah shell Omarchy, aplikasi GTK, dan terminal Anda secara bersamaan, sehingga seluruh desktop tetap proporsional. Jalankan tanpa argumen untuk melihat posisi Anda saat ini, dan `omarchy display text size reset` untuk kembali ke default. Foot adalah satu-satunya yang tertinggal: ia tidak memiliki cara untuk memuat ulang konfigurasinya, jadi terminal yang sedang berjalan tetap mempertahankan ukuran lamanya sampai Anda membuka yang baru.

### Memperluas dan mencerminkan layar laptop

Saat Anda menghubungkan layar eksternal ke laptop Anda, layar secara otomatis diperluas. Namun Anda dapat mengubahnya menjadi pencerminan menggunakan _Trigger > Hardware_ di menu Omarchy atau `Super + Ctrl + Alt + Delete`. Ini sangat membantu terutama jika layar eksternal tersebut adalah proyektor, dan Anda ingin menampilkan sesuatu saat bekerja.

Saat Anda memperluas, menutup tutup laptop akan secara otomatis mematikan layar internal. Membuka tutupnya akan menyalakannya kembali. Anda juga dapat mengontrol ini secara manual menggunakan _Trigger > Hardware_ di menu Omarchy atau `Super + Ctrl + Delete`.

### Mengatur beberapa layar

Hyprland bekerja dengan sangat baik dengan beberapa layar. Baca lebih lanjut tentang cara menatanya di [dokumentasi monitor Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Di Omarchy, ini ditempatkan di `~/.config/hypr/monitors.lua` sebagai entri `hl.monitor` — file tersebut dilengkapi dengan contoh yang dikomentari untuk menetapkan monitor tertentu ke resolusi, posisi, dan rotasi tertentu.

Setiap monitor memiliki workspace 1 sampai 10 sendiri, jadi `Super + 1` selalu berarti workspace pertama dari monitor tempat Anda berada. Di balik layar, Hyprland tetap menomori workspace di semua monitor: layar laptop Anda (atau monitor pertama) mendapatkan 1–10, monitor berikutnya 11–20, dan seterusnya, dan setiap monitor mempertahankan bloknya setiap kali Anda menghubungkannya. Gunakan nomor-nomor tersebut jika Anda menulis [aturan workspace](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) atau aturan jendela untuk monitor tertentu, jadi workspace 12 adalah workspace kedua dari monitor kedua Anda. `~/.local/state/omarchy/monitor-workspaces` mencantumkan blok mana yang dimiliki setiap monitor.

Tombol panah bekerja antar monitor yang berbagi tepi dalam tata letak Anda. Layar yang hanya bersentuhan di sudut, atau yang memiliki celah di antaranya, bukanlah tetangga, jadi gunakan `Ctrl + Alt + Tab` untuk berpindah di antaranya.

| Hotkey | Antar monitor |
| --- | --- |
| `Super + Arrow` | Memindahkan fokus ke monitor di sisi tersebut setelah tidak ada lagi jendela ke arah itu |
| `Super + Shift + Arrow` | Bertukar dengan jendela di monitor di sisi tersebut |
| `Super + Alt + Arrow` | Memindahkan jendela ke dalam grup di monitor di sisi tersebut |
| `Super + Shift + Ctrl + Arrow` | Memindahkan jendela ke monitor di sisi tersebut, ke workspace yang sedang ditampilkannya |
| `Super + Shift + Alt + Arrow` | Memindahkan workspace ke monitor di sisi tersebut, mempertahankan nomornya jika kosong |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Memindahkan fokus ke monitor berikutnya atau sebelumnya, apa pun tata letaknya |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Tetap di monitor tempat Anda berada |

Anda juga bisa mencoba [Hyprmon](https://github.com/erans/hyprmon/), jika Anda ingin TUI untuk membantu Anda memposisikan beberapa layar.

### Mengontrol kecerahan

Kecerahan monitor dikontrol oleh tombol fungsi khusus untuk kecerahan naik/turun. Jika Anda menahan shift sambil menekan tombol ini, Anda akan langsung ke kecerahan maksimum atau minimum. Tombol-tombol tersebut mengontrol layar yang sedang Anda fokuskan, jadi monitor eksternal yang mendukung DDC/CI disesuaikan dengan cara yang sama seperti layar laptop.

### Layar Apple

Jika Anda menggunakan layar Apple, tombol kecerahan keyboard biasa juga akan secara otomatis bekerja, jika Anda sedang fokus pada layar Apple. Ini dilakukan melalui perintah `asdcontrol`.

Perhatikan bahwa jika Anda menggunakan layar Apple 6K XDR, Anda mungkin melihat layar hantu dalam daftar `hyprctl monitors` Anda. Anda dapat mematikannya dengan sesuatu seperti `hl.monitor({ output = "DP-2", disabled = true })` melalui _Setup > Monitors_.

Pada mesin Intel, Anda sebaiknya menghubungkan ke layar Apple menggunakan kabel Thunderbolt biasa. Pada mesin lain tanpa Thunderbolt, Anda biasanya harus menggunakan [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) agar dapat bekerja.
