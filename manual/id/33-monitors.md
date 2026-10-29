# Monitor

Omarchy mengasumsikan kamu secara default menggunakan layar kelas retina yang mampu 2x. Inilah yang kamu butuhkan untuk mendapatkan font programmer yang bagus dan tajam itu. Inilah yang hampir semua laptop premium baru dengan layar resolusi tinggi dioptimalkan untuknya. Inilah yang ingin kamu gunakan pada layar 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) atau 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Tetapi jika kamu tidak menggunakan layar dengan PPI 218 atau di atasnya, kamu perlu mengubah pengaturan monitor. Misalnya, jika kamu memiliki 4K 27" atau 32", kamu bisa menggunakan penskalaan pecahan dengan membuka `~/.config/hypr/monitors.lua` (melalui _Setup > Monitors_ di menu Omarchy) dan beralih ke rekomendasi untuk kombinasi tersebut:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Jika kamu menggunakan layar 1080p atau 1440p, kamu mungkin hanya ingin menggunakan penskalaan 1x, jadi kamu bisa menggunakan:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Perubahan pada `GDK_SCALE` berlaku untuk aplikasi yang dimulai setelah perubahan (dan GTK hanya menerima bilangan bulat, jadi jaga agar tetap pada bilangan bulat terdekat dari skala monitormu). Jadi pastikan kamu menutup jendela yang kamu miliki yang ukurannya terlalu besar setelah perubahan (atau tutup semua jendela dengan `Ctrl + Alt + Del`!).

Kamu juga bisa dengan cepat menelusuri rasio penskalaan monitor utama (1x, 1.25x, 1.6x, 2x, 3x, 4x) menggunakan `Super + /` untuk naik dan `Super + Alt + /` untuk turun, atau memilih salah satu dari panel monitor di bar atas. Ini hanya mengubah monitor yang sedang kamu fokuskan, jadi layar laptop dan layar eksternal masing-masing bisa memiliki skalanya sendiri. Pilihan tersebut disimpan ke `~/.config/hypr/monitors.lua` sebagai aturan `hl.monitor` untuk monitor tersebut, jadi pilihan itu tetap ada setelah reboot dan lebih diutamakan daripada `omarchy_monitor_scale`, yang tetap menjadi skala untuk setiap monitor yang tidak memiliki aturannya sendiri. Karena `GDK_SCALE` adalah satu nilai untuk semua layar, perubahan ini menetapkannya dari monitor dengan skala terendah, jadi aplikasi X11 tampil sedikit kecil di layar yang lebih padat daripada terlalu besar di layar lainnya.

### Membuat teks lebih besar atau lebih kecil

Penskalaan monitor mengubah ukuran semuanya. Jika yang kamu inginkan hanyalah _teks_ yang lebih besar atau lebih kecil, ada satu kenop tunggal untuk itu:

```
omarchy display text size 14
```

Itu menerima ukuran piksel antara 9 dan 20, dan menggerakkan shell Omarchy, aplikasi GTK, dan terminalmu bersama-sama, jadi seluruh desktop tetap proporsional. Jalankan tanpa argumen untuk melihat posisi kamu saat ini, dan `omarchy display text size reset` untuk kembali ke default. Foot adalah satu-satunya yang tertinggal: ia tidak memiliki cara untuk memuat ulang konfigurasinya, jadi terminal yang sedang berjalan tetap mempertahankan ukuran lamanya sampai kamu membuka yang baru.

### Memperluas dan mencerminkan layar laptop

Saat kamu menghubungkan layar eksternal ke laptopmu, layar secara otomatis diperluas. Tetapi kamu bisa mengubahnya menjadi pencerminan sebagai gantinya menggunakan _Trigger > Hardware_ di menu Omarchy atau `Super + Ctrl + Alt + Delete`. Ini sangat membantu terutama jika layar eksternal tersebut adalah proyektor, dan kamu ingin menampilkan sesuatu sambil bekerja.

Saat kamu memperluas, menutup tutup laptop akan secara otomatis mematikan layar internal. Membuka tutupnya akan menyalakannya kembali. Kamu juga bisa mengontrol ini secara manual menggunakan _Trigger > Hardware_ di menu Omarchy atau `Super + Ctrl + Delete`.

### Mengatur beberapa layar

Hyprland bekerja dengan sangat baik dengan beberapa layar. Baca lebih lanjut tentang cara menatanya di [dokumentasi monitor Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Di Omarchy, ini ditempatkan di `~/.config/hypr/monitors.lua` sebagai entri `hl.monitor` — file ini disertai contoh yang dikomentari untuk menetapkan monitor tertentu ke resolusi, posisi, dan rotasi tertentu.

Setiap monitor memiliki workspace 1 sampai 10 sendiri, jadi `Super + 1` selalu berarti workspace pertama dari monitor tempat kamu berada. Di balik layar, Hyprland tetap menomori workspace di semua monitor: layar laptopmu (atau monitor pertama) mendapatkan 1–10, monitor berikutnya 11–20, dan seterusnya, dan setiap monitor mempertahankan bloknya setiap kali kamu menghubungkannya. Gunakan nomor-nomor tersebut jika kamu menulis [aturan workspace](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) atau aturan jendela untuk monitor tertentu, jadi workspace 12 adalah workspace kedua dari monitor keduamu. `~/.local/state/omarchy/monitor-workspaces` mencantumkan blok mana yang dimiliki setiap monitor.

Tombol panah bekerja lintas monitor yang berbagi tepi dalam tata letakmu. Layar yang hanya bersentuhan di sudut, atau yang memiliki celah di antaranya, bukanlah tetangga, jadi gunakan `Ctrl + Alt + Tab` untuk berpindah di antaranya.

| Tombol pintas | Lintas monitor |
| --- | --- |
| `Super + Arrow` | Memindahkan fokus ke monitor di sisi tersebut setelah tidak ada lagi jendela ke arah itu |
| `Super + Shift + Arrow` | Bertukar dengan jendela di monitor di sisi tersebut |
| `Super + Alt + Arrow` | Memindahkan jendela ke dalam grup di monitor di sisi tersebut |
| `Super + Shift + Ctrl + Arrow` | Memindahkan jendela ke monitor di sisi tersebut, ke workspace yang sedang ditampilkannya |
| `Super + Shift + Alt + Arrow` | Memindahkan workspace ke monitor di sisi tersebut, mempertahankan nomornya jika kosong |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Memindahkan fokus ke monitor berikutnya atau sebelumnya, apa pun tata letaknya |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Tetap di monitor tempat kamu berada |

Kamu juga bisa melihat [Hyprmon](https://github.com/erans/hyprmon/), jika kamu ingin sebuah TUI untuk membantumu mengatur posisi beberapa layar.

### Mengontrol kecerahan

Kecerahan monitor dikontrol oleh tombol fungsi khusus untuk kecerahan naik/turun. Jika kamu menahan shift saat menekannya, kamu akan langsung ke kecerahan maksimum atau minimum. Tombol-tombol tersebut mengontrol layar yang sedang kamu fokuskan, jadi monitor eksternal yang mendukung DDC/CI disesuaikan dengan cara yang sama seperti layar laptop.

### Layar Apple

Jika kamu menggunakan layar Apple, tombol kecerahan keyboard biasa juga akan otomatis berfungsi, jika kamu sedang fokus pada layar Apple tersebut. Ini dilakukan melalui perintah `asdcontrol`.

Perhatikan bahwa jika kamu menggunakan layar Apple 6K XDR, kamu mungkin melihat layar hantu di daftar `hyprctl monitors` milikmu. Kamu bisa mematikannya dengan sesuatu seperti `hl.monitor({ output = "DP-2", disabled = true })` melalui _Setup > Monitors_.

Di mesin Intel, kamu sebaiknya menghubungkan ke layar Apple menggunakan kabel Thunderbolt biasa. Di mesin lain tanpa Thunderbolt, kamu biasanya harus menggunakan [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) agar bisa bekerja.
