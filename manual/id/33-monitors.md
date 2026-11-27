# Monitor

Omarchy berasumsi secara default kamu menggunakan layar kelas retina yang mampu 2x. Inilah yang kamu perlukan untuk mendapatkan font pemrograman yang bagus dan tajam itu. Inilah yang hampir semua laptop premium baru dengan layar beresolusi tinggi dioptimalkan. Inilah yang kamu inginkan untuk dijalankan di 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) atau 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Namun jika kamu tidak menggunakan layar dengan PPI 218 atau lebih, kamu akan ingin mengubah pengaturan monitor. Misalnya, jika kamu memiliki 4K 27" atau 32", kamu dapat memilih skala pecahan untuknya dari panel monitor di bilah atas, atau mengatur default untuk setiap monitor dengan membuka `~/.config/hypr/monitors.lua` dan beralih ke rekomendasi untuk kombinasi tersebut:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Jika kamu menggunakan layar 1080p atau 1440p, kamu mungkin hanya ingin menggunakan penskalaan 1x, dan hal yang sama untuk aplikasi GTK dan X11, jadi kamu dapat menggunakan:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Perubahan pada `GDK_SCALE` berlaku untuk aplikasi yang dimulai setelah perubahan (dan GTK hanya menerima bilangan bulat, jadi tetapkan pada bilangan bulat terdekat dari skala monitor kamu). Jadi pastikan kamu menutup jendela yang kamu miliki yang berukuran terlalu besar setelah perubahan (atau tutup semua jendela dengan `Ctrl + Alt + Del`!).

Kamu juga dapat dengan cepat menelusuri rasio penskalaan monitor utama (1x, 1.25x, 1.6x, 2x, 3x, 4x) menggunakan `Super + /` untuk naik dan `Super + Alt + /` untuk turun, atau memilih salah satu dari panel monitor di bilah atas. Ini hanya mengubah monitor yang sedang kamu fokuskan, jadi layar laptop dan layar eksternal masing-masing dapat memiliki skalanya sendiri. Panel juga mengatur resolusi, refresh rate, dan rotasi setiap monitor. Pilihan kamu disimpan untuk monitor fisik tersebut di `~/.local/state/omarchy/monitors/settings`, jadi pilihan tersebut tetap ada setelah reboot dan mengikuti monitor ke port atau dock mana pun monitor itu dicolokkan berikutnya. Pilihan tersebut diutamakan daripada aturan apa pun untuk monitor yang sama di `~/.config/hypr/monitors.lua`, yang tidak pernah diedit oleh Omarchy. Jika kamu lebih suka mengatur monitor kamu sepenuhnya di file tersebut, tambahkan `omarchy_monitor_panel_settings = false` ke dalamnya, dan perubahan panel hanya akan bertahan sampai Hyprland dimuat ulang. Karena `GDK_SCALE` adalah satu nilai untuk semua layar, skala yang dipilih menetapkannya dari monitor dengan skala terendah, jadi aplikasi X11 tampil sedikit kecil di layar yang lebih padat daripada terlalu besar di layar lainnya.

### Membesarkan atau mengecilkan teks

Penskalaan monitor mengubah ukuran semuanya. Jika yang kamu inginkan hanya _teks_ yang lebih besar atau lebih kecil, ada satu pengaturan untuk itu:

```
omarchy display text size 14
```

Itu menerima ukuran piksel antara 9 dan 20, dan menggerakkan shell Omarchy, aplikasi GTK, dan terminal kamu bersamaan, jadi seluruh desktop tetap proporsional. Jalankan tanpa argumen untuk melihat posisi kamu saat ini, dan `omarchy display text size reset` untuk kembali ke default. Foot adalah satu-satunya yang tertinggal: ia tidak memiliki cara untuk memuat ulang konfigurasinya, jadi terminal yang sedang berjalan tetap menggunakan ukuran lama sampai kamu membuka yang baru.

### Memperluas dan mencerminkan tampilan laptop

Saat kamu menghubungkan layar eksternal ke laptop kamu, tampilan secara otomatis diperluas. Namun kamu dapat mengubahnya menjadi pencerminan sebagai gantinya dengan _Extend_ | _Mirror_ di panel monitor di bilah atas, _Trigger > Hardware_ di menu Omarchy, atau `Super + Ctrl + Alt + Delete`. Ini sangat membantu terutama jika layar eksternal tersebut adalah proyektor, dan kamu ingin menampilkan sesuatu saat bekerja.

Saat kamu memperluas, menutup tutup laptop akan secara otomatis mematikan layar internal. Membuka tutupnya akan menyalakannya kembali. Kamu juga dapat mengontrol ini secara manual menggunakan _Trigger > Hardware_ di menu Omarchy atau `Super + Ctrl + Delete`.

Saat laptop dicolokkan, menutup tutupnya tidak pernah membuatnya tidur, jadi laptop yang terhubung ke dock tetap terjaga bahkan jika layar eksternal terputus sebentar. Tanpa layar eksternal terpasang, menutup tutup saat menggunakan daya hanya menguncinya. Saat menggunakan baterai, menutup tutupnya akan suspend seperti biasa.

### Mengatur beberapa layar

Hyprland bekerja dengan sangat baik dengan beberapa layar. Panel monitor di bilah atas menggambarnya di tempat mereka berada: seret satu ke sisi layar lain untuk memindahkannya ke sana, dan susunannya disimpan bersama pengaturan lain setiap monitor. Untuk apa pun yang tidak dicakup panel, baca lebih lanjut tentang cara menatanya di [dokumentasi monitor Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Di Omarchy, ini masuk ke `~/.config/hypr/monitors.lua` sebagai entri `hl.monitor` — file ini disertai contoh yang dikomentari untuk menonaktifkan monitor, mode yang tidak ditawarkan panel, warna 10-bit, dan variable refresh rate.

Setiap monitor memiliki workspace 1 sampai 10 sendiri, jadi `Super + 1` selalu berarti workspace pertama dari monitor yang kamu gunakan. Di balik layar, Hyprland masih menomori workspace di semua monitor: layar laptop kamu (atau monitor pertama) mendapat 1–10, monitor berikutnya 11–20, dan seterusnya, dan setiap monitor mempertahankan bloknya setiap kali kamu mencolokkannya. Gunakan nomor-nomor tersebut jika kamu menulis [aturan workspace](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) atau aturan jendela untuk monitor tertentu, jadi workspace 12 adalah workspace kedua dari monitor kedua kamu. `~/.local/state/omarchy/monitors/workspaces` mencantumkan blok mana yang dimiliki setiap monitor.

Tombol panah bekerja di antara monitor yang berbagi tepi dalam tata letak kamu. Layar yang hanya bersentuhan di sudut, atau yang memiliki celah di antaranya, bukanlah tetangga, jadi gunakan `Ctrl + Alt + Tab` untuk berpindah di antaranya.

| Tombol pintas | Antar monitor |
| --- | --- |
| `Super + Arrow` | Memindahkan fokus ke monitor di sisi tersebut setelah tidak ada jendela tersisa ke arah tersebut |
| `Super + Shift + Arrow` | Bertukar dengan jendela di monitor di sisi tersebut |
| `Super + Alt + Arrow` | Memindahkan jendela ke dalam grup di monitor di sisi tersebut |
| `Super + Shift + Ctrl + Arrow` | Memindahkan jendela ke monitor di sisi tersebut, ke workspace yang sedang ditampilkannya |
| `Super + Shift + Alt + Arrow` | Memindahkan workspace ke monitor di sisi tersebut, mempertahankan nomornya jika kosong |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Memindahkan fokus ke monitor berikutnya atau sebelumnya, apa pun tata letaknya |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Tetap di monitor yang kamu gunakan |

Kamu juga dapat melihat [Hyprmon](https://github.com/erans/hyprmon/), jika kamu ingin TUI untuk membantu kamu memposisikan beberapa layar.

### Mengontrol kecerahan

Kecerahan monitor dikontrol oleh tombol fungsi khusus untuk menaikkan/menurunkan kecerahan. Jika kamu menahan shift saat menekan tombol ini, kamu akan mencapai kecerahan maksimum atau minimum. Tombol-tombol tersebut mengontrol tampilan yang sedang kamu fokuskan, jadi monitor eksternal yang mendukung DDC/CI disesuaikan dengan cara yang sama seperti layar laptop.

### Layar Apple

Jika kamu menggunakan layar Apple, tombol kecerahan keyboard biasa juga akan otomatis berfungsi, jika kamu fokus pada layar Apple. Ini dilakukan melalui perintah `asdcontrol`.

Perhatikan bahwa jika kamu menggunakan layar Apple 6K XDR, kamu mungkin melihat layar hantu di daftar `hyprctl monitors` kamu. Kamu dapat mematikannya dengan sesuatu seperti `hl.monitor({ output = "DP-2", disabled = true })` di `~/.config/hypr/monitors.lua`.

Di mesin Intel, kamu harus menghubungkan ke layar Apple menggunakan kabel Thunderbolt biasa. Di mesin lain tanpa Thunderbolt, kamu biasanya harus menggunakan [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) agar dapat berfungsi.
