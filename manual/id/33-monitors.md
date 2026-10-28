# Monitor

Omarchy mengasumsikan secara default kamu menggunakan layar kelas retina yang mendukung 2x. Inilah yang kamu butuhkan untuk mendapatkan font programmer yang bagus dan tajam itu. Inilah yang menjadi target optimasi hampir semua laptop premium baru dengan layar resolusi tinggi. Inilah yang sebaiknya kamu gunakan pada [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 27" 5K atau [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 32" 6K.

Namun jika kamu tidak menggunakan layar dengan PPI 218 atau lebih, kamu perlu mengubah pengaturan monitor. Misalnya, jika kamu punya 4K 27" atau 32", kamu bisa menggunakan penskalaan pecahan dengan membuka `~/.config/hypr/monitors.lua` (melalui _Setup > Monitors_ di menu Omarchy) dan beralih ke rekomendasi untuk kombinasi tersebut:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Jika kamu menggunakan layar 1080p atau 1440p, kamu mungkin cukup menggunakan penskalaan 1x, jadi kamu bisa menggunakan:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Perubahan pada `GDK_SCALE` berlaku untuk aplikasi yang dimulai setelah perubahan (dan GTK hanya menerima bilangan bulat, jadi tetapkan pada bilangan bulat terdekat dari skala monitor kamu). Jadi pastikan kamu menutup jendela-jendela yang ukurannya menjadi terlalu besar setelah perubahan (atau tutup semua jendela dengan `Ctrl + Alt + Del`!).

Kamu juga bisa dengan cepat beralih melalui rasio penskalaan monitor utama (1x, 1.25x, 1.6x, 2x, 3x, 4x) menggunakan `Super + /` untuk naik dan `Super + Alt + /` untuk turun, atau memilih salah satunya dari panel monitor di bilah atas. Ini hanya mengubah monitor yang sedang kamu fokuskan, jadi layar laptop dan layar eksternal masing-masing bisa punya skalanya sendiri. Pilihan tersebut disimpan ke `~/.config/hypr/monitors.lua` sebagai aturan `hl.monitor` untuk monitor tersebut, jadi tetap berlaku setelah reboot dan diutamakan di atas `omarchy_monitor_scale`, yang tetap menjadi skala untuk setiap monitor yang tidak punya aturannya sendiri.

### Membuat teks lebih besar atau lebih kecil

Penskalaan monitor mengubah ukuran semuanya. Jika yang kamu inginkan hanya _teks_ yang lebih besar atau lebih kecil, ada satu pengaturan untuk itu:

```
omarchy display text size 14
```

Perintah itu menerima ukuran piksel antara 9 dan 20, dan mengubah shell Omarchy, aplikasi GTK, dan terminal kamu secara bersamaan, jadi seluruh desktop tetap proporsional. Jalankan tanpa argumen untuk melihat posisi kamu saat ini, dan `omarchy display text size reset` untuk kembali ke default. Foot adalah satu-satunya yang tertinggal: ia tidak punya cara untuk memuat ulang konfigurasinya, jadi terminal yang sedang berjalan tetap memakai ukuran lama sampai kamu membuka yang baru.

### Memperluas dan mencerminkan layar laptop

Saat kamu menghubungkan layar eksternal ke laptop, layar secara otomatis diperluas. Namun kamu bisa mengubahnya menjadi pencerminan sebagai gantinya menggunakan _Trigger > Hardware_ di menu Omarchy atau `Super + Ctrl + Alt + Delete`. Ini sangat membantu terutama jika layar eksternal tersebut adalah proyektor, dan kamu ingin menampilkan sesuatu sambil bekerja.

Saat kamu memperluas layar, menutup tutup laptop akan secara otomatis mematikan layar internal. Membuka tutupnya akan menyalakannya kembali. Kamu juga bisa mengontrol ini secara manual menggunakan _Trigger > Hardware_ di menu Omarchy atau `Super + Ctrl + Delete`.

### Mengatur beberapa layar

Hyprland bekerja dengan sangat baik dengan beberapa layar. Baca selengkapnya tentang cara menatanya di [dokumentasi monitor Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Di Omarchy, pengaturan ini ditempatkan di `~/.config/hypr/monitors.lua` sebagai entri `hl.monitor` — file tersebut disertai contoh yang diberi komentar untuk menetapkan monitor tertentu ke resolusi, posisi, dan rotasi tertentu.

Setiap monitor punya workspace 1 sampai 10 sendiri, jadi `Super + 1` selalu berarti workspace pertama dari monitor tempat kamu berada. Di balik layar, Hyprland tetap memberi nomor workspace di semua monitor: layar laptop kamu (atau monitor pertama) mendapat 1–10, monitor berikutnya 11–20, dan seterusnya, dan setiap monitor mempertahankan bloknya setiap kali kamu menghubungkannya. Gunakan nomor-nomor tersebut jika kamu menulis [aturan workspace](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) atau aturan jendela untuk monitor tertentu, jadi workspace 12 adalah workspace kedua dari monitor kedua kamu. `~/.local/state/omarchy/monitor-workspaces` mencantumkan blok yang dimiliki setiap monitor.

Tombol panah bekerja antarmonitor yang berbagi tepi dalam tata letak kamu. Layar yang hanya bersentuhan di sudut, atau yang memiliki celah di antaranya, bukanlah tetangga, jadi gunakan `Ctrl + Alt + Tab` untuk berpindah di antaranya.

| Tombol pintas | Antarmonitor |
| --- | --- |
| `Super + Arrow` | Memindahkan fokus ke monitor di sisi tersebut setelah tidak ada lagi jendela ke arah itu |
| `Super + Shift + Arrow` | Bertukar dengan jendela di monitor di sisi tersebut |
| `Super + Alt + Arrow` | Memindahkan jendela ke grup di monitor di sisi tersebut |
| `Super + Shift + Ctrl + Arrow` | Memindahkan jendela ke monitor di sisi tersebut, ke workspace yang sedang ditampilkannya |
| `Super + Shift + Alt + Arrow` | Memindahkan workspace ke monitor di sisi tersebut, mempertahankan nomornya jika kosong |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Memindahkan fokus ke monitor berikutnya atau sebelumnya, apa pun tata letaknya |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Tetap di monitor tempat kamu berada |

Kamu juga bisa melihat [Hyprmon](https://github.com/erans/hyprmon/), jika kamu ingin TUI untuk membantumu mengatur posisi beberapa layar.

### Mengontrol kecerahan

Kecerahan monitor dikontrol oleh tombol fungsi khusus untuk menaikkan/menurunkan kecerahan. Jika kamu menahan shift saat menekan tombol ini, kamu akan langsung ke kecerahan maksimum atau minimum. Tombol-tombol tersebut mengontrol layar yang sedang kamu fokuskan, jadi monitor eksternal yang mendukung DDC/CI disesuaikan dengan cara yang sama seperti layar laptop.

### Layar Apple

Jika kamu menggunakan layar Apple, tombol kecerahan keyboard biasa juga akan otomatis berfungsi, jika kamu sedang fokus pada layar Apple tersebut. Ini dilakukan melalui perintah `asdcontrol`.

Perlu dicatat bahwa jika kamu menggunakan layar Apple 6K XDR, kamu mungkin melihat layar hantu di daftar `hyprctl monitors` kamu. Kamu bisa mematikannya dengan sesuatu seperti `hl.monitor({ output = "DP-2", disabled = true })` melalui _Setup > Monitors_.

Pada mesin Intel, kamu sebaiknya menghubungkan ke layar Apple menggunakan kabel Thunderbolt biasa. Pada mesin lain tanpa Thunderbolt, kamu biasanya harus menggunakan [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) agar bisa berfungsi.
