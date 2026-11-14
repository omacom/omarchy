# Monitor

Omarchy mengasumsikan secara default kamu menggunakan layar kelas retina yang mampu 2x. Inilah yang kamu butuhkan untuk mendapatkan font pemrogram yang bagus dan tajam itu. Inilah yang dioptimalkan untuk hampir semua laptop premium baru dengan layar beresolusi tinggi. Inilah yang ingin kamu jalankan pada [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 27" 5K atau [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 32" 6K.

Namun jika kamu tidak menggunakan layar dengan PPI 218 atau lebih, kamu perlu mengubah pengaturan monitor. Misalnya, jika kamu memiliki 4K 27" atau 32", kamu bisa memilih skala pecahan untuknya dari panel monitor di bilah atas, atau mengatur default untuk setiap monitor dengan membuka `~/.config/hypr/monitors.lua` dan beralih ke rekomendasi untuk kombinasi tersebut:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Jika kamu menggunakan layar 1080p atau 1440p, kamu mungkin hanya ingin menggunakan penskalaan 1x, dan hal yang sama untuk aplikasi GTK dan X11, jadi kamu bisa menggunakan:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Perubahan pada `GDK_SCALE` berlaku untuk aplikasi yang dimulai setelah perubahan (dan GTK hanya menerima bilangan bulat, jadi pertahankan pada bilangan bulat terdekat dari skala monitormu). Jadi pastikan kamu keluar dari jendela yang kamu miliki yang terlalu besar setelah perubahan (atau tutup semua jendela dengan `Ctrl + Alt + Del`!).

Kamu juga bisa dengan cepat menelusuri rasio penskalaan monitor utama (1x, 1.25x, 1.6x, 2x, 3x, 4x) menggunakan `Super + /` untuk naik dan `Super + Alt + /` untuk turun, atau memilih satu dari panel monitor di bilah atas. Ini hanya mengubah monitor yang sedang kamu fokuskan, sehingga layar laptop dan layar eksternal masing-masing bisa memiliki skalanya sendiri. Panel ini juga mengatur resolusi, refresh rate, dan rotasi setiap monitor. Pilihanmu disimpan untuk monitor fisik tersebut di `~/.local/state/omarchy/monitors/settings`, jadi pilihan itu tetap ada setelah reboot dan mengikuti monitor ke port atau dock mana pun monitor itu dicolokkan berikutnya. Pilihan itu diutamakan di atas aturan apa pun untuk monitor yang sama di `~/.config/hypr/monitors.lua`, yang tidak pernah diedit Omarchy. Jika kamu lebih suka mengatur monitormu sepenuhnya di file itu, tambahkan `omarchy_monitor_panel_settings = false` ke dalamnya, dan perubahan panel hanya akan bertahan sampai Hyprland dimuat ulang. Karena `GDK_SCALE` adalah satu nilai untuk semua layar, skala yang dipilih menetapkannya dari monitor dengan skala terendah, sehingga aplikasi X11 tampil sedikit kecil di layar yang lebih padat daripada terlalu besar di layar lainnya.

### Membuat teks lebih besar atau lebih kecil

Penskalaan monitor mengubah ukuran segalanya. Jika yang kamu inginkan hanya _teks_ yang lebih besar atau lebih kecil, ada satu kenop untuk itu:

```
omarchy display text size 14
```

Itu menerima ukuran piksel antara 9 dan 20, dan menggerakkan shell Omarchy, aplikasi GTK, dan terminalmu bersama-sama, sehingga seluruh desktop tetap proporsional. Jalankan tanpa argumen untuk melihat posisimu saat ini, dan `omarchy display text size reset` untuk kembali ke default. Foot adalah satu-satunya yang tertinggal: ia tidak memiliki cara untuk memuat ulang konfigurasinya, jadi terminal yang sedang berjalan tetap mempertahankan ukuran lamanya sampai kamu membuka yang baru.

### Memperluas dan mencerminkan layar laptop

Ketika kamu menghubungkan layar eksternal ke laptopmu, layar secara otomatis diperluas. Namun kamu bisa mengubah itu menjadi pencerminan sebagai gantinya menggunakan _Trigger > Hardware_ di menu Omarchy atau `Super + Ctrl + Alt + Delete`. Ini sangat membantu terutama jika layar eksternal itu adalah proyektor, dan kamu ingin menampilkan sesuatu sambil bekerja.

Ketika kamu sedang memperluas, menutup tutup laptop akan secara otomatis mematikan layar internal. Membuka tutup akan menyalakannya kembali. Kamu juga bisa mengontrol ini secara manual menggunakan _Trigger > Hardware_ di menu Omarchy atau `Super + Ctrl + Delete`.

### Mengatur beberapa layar

Hyprland bekerja dengan sangat baik dengan beberapa layar. Panel monitor di bilah atas menggambarnya di tempat mereka berada: seret satu ke sisi layar lain untuk memindahkannya ke sana, dan susunannya disimpan bersama pengaturan lain setiap monitor. Untuk apa pun yang tidak dicakup panel, baca lebih lanjut tentang cara menatanya di [dokumentasi monitor Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Di Omarchy, ini masuk ke `~/.config/hypr/monitors.lua` sebagai entri `hl.monitor` — file ini disertai dengan contoh yang dikomentari untuk menjaga monitor tetap mati, mode yang tidak ditawarkan panel, warna 10-bit, dan variable refresh rate.

Setiap monitor memiliki workspace 1 sampai 10 miliknya sendiri, jadi `Super + 1` selalu berarti workspace pertama dari monitor tempat kamu berada. Di balik layar, Hyprland tetap memberi nomor workspace di semua monitor: layar laptopmu (atau monitor pertama) mendapatkan 1–10, monitor berikutnya 11–20, dan seterusnya, dan setiap monitor mempertahankan bloknya setiap kali kamu mencolokkannya. Gunakan nomor-nomor itu jika kamu menulis [aturan workspace](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) atau aturan jendela untuk monitor tertentu, jadi workspace 12 adalah workspace kedua dari monitor keduamu. `~/.local/state/omarchy/monitors/workspaces` mencantumkan blok mana yang dimiliki setiap monitor.

Tombol panah bekerja di antara monitor yang berbagi tepi dalam tata letakmu. Layar yang hanya bersentuhan di sudut, atau yang memiliki celah di antaranya, bukanlah tetangga, jadi gunakan `Ctrl + Alt + Tab` untuk berpindah di antaranya.

| Tombol Pintas | Antarmonitor |
| --- | --- |
| `Super + Arrow` | Memindahkan fokus ke monitor di sisi tersebut setelah tidak ada lagi jendela ke arah itu |
| `Super + Shift + Arrow` | Bertukar dengan jendela di monitor di sisi tersebut |
| `Super + Alt + Arrow` | Memindahkan jendela ke dalam grup di monitor di sisi tersebut |
| `Super + Shift + Ctrl + Arrow` | Memindahkan jendela ke monitor di sisi tersebut, ke workspace yang sedang ditampilkannya |
| `Super + Shift + Alt + Arrow` | Memindahkan workspace ke monitor di sisi tersebut, mempertahankan nomornya jika kosong |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Memindahkan fokus ke monitor berikutnya atau sebelumnya, apa pun tata letaknya |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Tetap di monitor tempat kamu berada |

Kamu juga bisa mencoba [Hyprmon](https://github.com/erans/hyprmon/), jika kamu menginginkan TUI untuk membantumu memposisikan beberapa layar.

### Mengontrol kecerahan

Kecerahan monitor dikontrol oleh tombol fungsi khusus untuk kecerahan naik/turun. Jika kamu menahan shift sambil menekan tombol ini, kamu akan langsung ke kecerahan maksimum atau minimum. Tombol-tombol itu mengontrol layar yang sedang kamu fokuskan, jadi monitor eksternal yang berbicara DDC/CI disesuaikan dengan cara yang sama seperti layar laptop.

### Layar Apple

Jika kamu menggunakan layar Apple, tombol kecerahan keyboard biasa juga akan otomatis bekerja, jika kamu fokus pada layar Apple. Ini dilakukan melalui perintah `asdcontrol`.

Perhatikan bahwa jika kamu menggunakan layar Apple 6K XDR, kamu mungkin melihat layar hantu di daftar `hyprctl monitors` milikmu. Kamu bisa mematikannya dengan sesuatu seperti `hl.monitor({ output = "DP-2", disabled = true })` di `~/.config/hypr/monitors.lua`.

Pada mesin Intel, kamu harus menghubungkan ke layar Apple menggunakan kabel Thunderbolt biasa. Pada mesin lain tanpa Thunderbolt, kamu biasanya harus menggunakan [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) agar bisa bekerja.
