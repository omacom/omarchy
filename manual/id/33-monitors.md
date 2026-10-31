# Monitor

Omarchy mengasumsikan secara default kamu menjalankan layar kelas retina yang mampu 2x. Ini yang kamu butuhkan untuk mendapatkan font programmer yang bagus dan tajam itu. Ini yang dioptimalkan untuk hampir semua laptop premium baru dengan layar resolusi tinggi. Ini yang ingin kamu jalankan pada 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) atau 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Namun jika kamu tidak menjalankan layar dengan PPI 218 atau lebih, kamu akan ingin mengubah pengaturan monitor. Misalnya, jika kamu memiliki 4K 27" atau 32", kamu bisa memilih skala pecahan untuknya dari panel monitor di bilah atas, atau mengatur default untuk setiap monitor dengan membuka `~/.config/hypr/monitors.lua` dan beralih ke rekomendasi untuk kombinasi tersebut:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Jika kamu menggunakan layar 1080p atau 1440p, kamu mungkin hanya ingin menggunakan penskalaan 1x, dan sama untuk aplikasi GTK dan X11, jadi kamu bisa menggunakan:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Perubahan pada `GDK_SCALE` berlaku untuk aplikasi yang dimulai setelah perubahan (dan GTK hanya menerima bilangan bulat, jadi jaga agar tetap pada bilangan bulat terdekat dari skala monitormu). Jadi pastikan kamu keluar dari jendela yang kamu miliki yang berukuran terlalu besar setelah perubahan (atau tutup semua jendela dengan `Ctrl + Alt + Del`!).

Kamu juga bisa dengan cepat menelusuri rasio penskalaan monitor utama (1x, 1.25x, 1.6x, 2x, 3x, 4x) menggunakan `Super + /` untuk naik dan `Super + Alt + /` untuk turun, atau memilih satu dari panel monitor di bilah atas. Ini hanya mengubah monitor yang sedang kamu fokuskan, sehingga layar laptop dan layar eksternal masing-masing bisa memiliki skalanya sendiri. Panel tersebut juga mengatur resolusi setiap monitor. Pilihanmu disimpan untuk monitor fisik tersebut di `~/.local/state/omarchy/monitors/settings`, jadi tetap bertahan setelah reboot dan mengikuti monitor ke port atau dock mana pun tempat monitor itu dicolokkan berikutnya. Pilihan tersebut diutamakan di atas aturan apa pun untuk monitor yang sama di `~/.config/hypr/monitors.lua`, yang tidak pernah diedit Omarchy. Karena `GDK_SCALE` adalah satu nilai untuk semua layar, skala yang dipilih mengaturnya dari monitor dengan skala terendah, sehingga aplikasi X11 tampil sedikit kecil di layar yang lebih padat, bukan terlalu besar di layar lainnya.

### Membuat teks lebih besar atau lebih kecil

Penskalaan monitor mengubah ukuran semuanya. Jika yang kamu inginkan hanya _teks_ yang lebih besar atau lebih kecil, ada satu kenop tunggal untuk itu:

```
omarchy display text size 14
```

Itu menerima ukuran piksel antara 9 dan 20, dan menggerakkan shell Omarchy, aplikasi GTK, dan terminalmu secara bersamaan, sehingga seluruh desktop tetap proporsional. Jalankan tanpa argumen untuk melihat posisi kamu saat ini, dan `omarchy display text size reset` untuk kembali ke default. Foot adalah satu yang tertinggal: ia tidak punya cara untuk memuat ulang konfigurasinya, jadi terminal yang sedang berjalan tetap mempertahankan ukuran lamanya sampai kamu membuka yang baru.

### Memperluas dan mencerminkan layar laptop

Ketika kamu menghubungkan layar eksternal ke laptopmu, layar secara otomatis diperluas. Namun kamu bisa mengubahnya menjadi pencerminan sebagai gantinya menggunakan _Trigger > Hardware_ di menu Omarchy atau `Super + Ctrl + Alt + Delete`. Ini sangat membantu terutama jika layar eksternal itu adalah proyektor, dan kamu ingin menunjukkan sesuatu sambil bekerja.

Ketika kamu memperluas, menutup penutup laptop akan secara otomatis mematikan layar internal. Membuka penutup akan menyalakannya kembali. Kamu juga bisa mengontrol ini secara manual menggunakan _Trigger > Hardware_ di menu Omarchy atau `Super + Ctrl + Delete`.

### Mengatur beberapa layar

Hyprland bekerja dengan sangat baik dengan beberapa layar. Panel monitor di bilah atas menggambarnya di tempat mereka berada: seret satu ke sisi yang lain untuk memindahkannya ke sana, dan susunannya disimpan bersama pengaturan lain setiap monitor. Untuk apa pun yang tidak dicakup panel, baca lebih lanjut tentang cara menatanya di [dokumentasi monitor Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Di Omarchy, ini masuk ke `~/.config/hypr/monitors.lua` sebagai entri `hl.monitor` — file tersebut dikirim dengan contoh yang dikomentari untuk menetapkan monitor tertentu ke resolusi, posisi, dan rotasi tertentu.

Setiap monitor memiliki workspace 1 sampai 10 sendiri, jadi `Super + 1` selalu berarti workspace pertama dari monitor tempat kamu berada. Di balik layar, Hyprland tetap memberi nomor workspace di semua monitor: layar laptopmu (atau monitor pertama) mendapat 1–10, monitor berikutnya 11–20, dan seterusnya, dan setiap monitor tetap mempertahankan bloknya setiap kali kamu mencolokkannya. Gunakan nomor-nomor itu jika kamu menulis [aturan workspace](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) atau aturan jendela untuk monitor tertentu, jadi workspace 12 adalah workspace kedua dari monitor keduamu. `~/.local/state/omarchy/monitors/workspaces` mencantumkan blok mana yang dimiliki setiap monitor.

Tombol panah bekerja antarmonitor yang berbagi tepi dalam tataletakmu. Layar yang hanya bersentuhan di sudut, atau yang memiliki celah di antara mereka, bukanlah tetangga, jadi gunakan `Ctrl + Alt + Tab` untuk berpindah di antara mereka.

| Tombol pintas | Antarmonitor |
| --- | --- |
| `Super + Arrow` | Memindahkan fokus ke monitor di sisi tersebut setelah tidak ada jendela lagi ke arah itu |
| `Super + Shift + Arrow` | Bertukar dengan jendela di monitor di sisi tersebut |
| `Super + Alt + Arrow` | Memindahkan jendela ke dalam grup di monitor di sisi tersebut |
| `Super + Shift + Ctrl + Arrow` | Memindahkan jendela ke monitor di sisi tersebut, ke workspace yang sedang ditampilkannya |
| `Super + Shift + Alt + Arrow` | Memindahkan workspace ke monitor di sisi tersebut, mempertahankan nomornya jika kosong |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Memindahkan fokus ke monitor berikutnya atau sebelumnya, apa pun tataletaknya |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Tetap di monitor tempat kamu berada |

Kamu juga bisa melihat [Hyprmon](https://github.com/erans/hyprmon/), jika kamu ingin TUI untuk membantumu dengan penempatan beberapa layar.

### Mengontrol kecerahan

Kecerahan monitor dikontrol oleh tombol fungsi khusus untuk kecerahan naik/turun. Jika kamu menahan shift saat menekan tombol ini, kamu akan pergi ke kecerahan maksimum atau minimum. Tombol-tombol tersebut mengontrol layar yang sedang kamu fokuskan, jadi monitor eksternal yang berbicara DDC/CI disesuaikan dengan cara yang sama seperti layar laptop.

### Layar Apple

Jika kamu menggunakan layar Apple, tombol kecerahan keyboard biasa juga akan otomatis bekerja, jika kamu fokus pada layar Apple. Ini dilakukan melalui perintah `asdcontrol`.

Perhatikan bahwa jika kamu menggunakan layar Apple 6K XDR, kamu mungkin melihat layar hantu dalam daftar `hyprctl monitors` milikmu. Kamu bisa mematikannya dengan sesuatu seperti `hl.monitor({ output = "DP-2", disabled = true })` di `~/.config/hypr/monitors.lua`.

Pada mesin Intel, kamu harus menghubungkan ke layar Apple menggunakan kabel Thunderbolt biasa. Pada mesin lain tanpa Thunderbolt, kamu biasanya harus menggunakan [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) agar bisa bekerja.
