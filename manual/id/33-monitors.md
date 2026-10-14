# Monitor

Omarchy mengasumsikan kamu menjalankan layar kelas retina yang mampu 2x secara bawaan. Ini yang kamu butuhkan untuk mendapatkan font programmer yang bagus dan tajam tersebut. Ini adalah apa yang dioptimalkan oleh hampir semua laptop premium baru dengan layar resolusi tinggi. Ini adalah apa yang kamu inginkan untuk dijalankan pada 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) atau 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Tetapi jika kamu tidak menjalankan layar dengan PPI 218 atau di atasnya, kamu akan ingin mengubah pengaturan monitor. Misalnya, jika kamu memiliki 27" atau 32" 4K, kamu dapat menggunakan penskalaan pecahan dengan membuka `~/.config/hypr/monitors.lua` (melalui _Pengaturan > Monitor_ di menu Omarchy) dan beralih ke rekomendasi untuk kombinasi tersebut:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Jika kamu menggunakan layar 1080p atau 1440p, kamu mungkin hanya ingin menggunakan penskalaan 1x, jadi kamu dapat menggunakan:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Perubahan pada `GDK_SCALE` berlaku untuk aplikasi yang dimulai setelah perubahan (dan GTK hanya menghormati bilangan bulat, jadi jaga pada bilangan bulat terdekat dari skala monitormu). Jadi pastikan kamu menutup jendela yang kamu miliki yang terlalu besar setelah perubahan (atau tutup semua jendela dengan `Ctrl + Alt + Del`!).

Kamu juga dapat dengan cepat melangkah melalui rasio penskalaan monitor utama (1x, 1.25x, 1.6x, 2x, 3x, 4x) menggunakan `Super + /` untuk naik lebih tinggi dan `Super + Alt + /` untuk turun lebih rendah. Jika kamu memiliki konfigurasi bawaan, perubahan ini juga akan bertahan melewati reboot.

### Membuat teks lebih besar atau lebih kecil

Penskalaan monitor mengubah ukuran semuanya. Jika yang kamu inginkan hanyalah _teks_ yang lebih besar atau lebih kecil, ada satu tombol untuk itu:

```
omarchy display text size 14
```

Itu mengambil ukuran piksel antara 9 dan 20, dan memindahkan shell Omarchy, aplikasi GTK, dan terminalmu bersama-sama, jadi seluruh desktop tetap proporsional. Jalankan tanpa argumen untuk melihat di mana kamu berada, dan `omarchy display text size reset` untuk kembali ke bawaan. Foot adalah satu-satunya yang tertinggal: tidak ada cara untuk memuat ulang konfigurasinya, jadi terminal yang berjalan mempertahankan ukuran lama sampai kamu membuka yang baru.

### Memperluas dan mencerminkan layar laptop

Saat kamu menghubungkan layar eksternal ke laptopmu, layar secara otomatis diperluas. Tetapi kamu dapat mengubahnya menjadi pencerminan sebagai gantinya menggunakan _Pemicu > Perangkat Keras_ di menu Omarchy atau `Super + Ctrl + Alt + Delete`. Ini terutama membantu jika layar eksternal tersebut adalah proyektor, dan kamu ingin menunjukkan sesuatu sambil bekerja.

Saat kamu memperluas, menutup penutup laptop akan secara otomatis mematikan layar internal. Membuka penutup akan menyalakannya kembali. Kamu juga dapat mengendalikan ini secara manual menggunakan _Pemicu > Perangkat Keras_ di menu Omarchy atau `Super + Ctrl + Delete`.

### Mengatur beberapa layar

Hyprland bekerja bagus dengan beberapa layar. Baca lebih lanjut tentang cara menata mereka di [dokumentasi monitor Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Kamu dapat [mengikat ruang kerja tertentu ke monitor tertentu](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) juga. Di Omarchy, aturan ini masuk ke `~/.config/hypr/monitors.lua` sebagai entri `hl.monitor` — berkas dilengkapi dengan contoh berkomentar untuk menyematkan monitor tertentu ke resolusi, posisi, dan rotasi.

Kamu juga dapat melihat [Hyprmon](https://github.com/erans/hyprmon/), jika kamu menginginkan TUI untuk membantumu dengan pemosisian beberapa layar.

### Mengendalikan kecerahan

Kecerahan monitor dikendalikan oleh tombol fungsi khusus untuk kecerahan naik/turun. Jika kamu menahan shift saat menekan ini, kamu akan pergi ke kecerahan maksimum atau minimum. Tombol mengendalikan layar yang kamu fokuskan, jadi monitor eksternal yang berbicara DDC/CI disesuaikan dengan cara yang sama seperti layar laptop.

### Layar Apple

Jika kamu menggunakan layar Apple, tombol kecerahan keyboard biasa juga akan secara otomatis bekerja, jika kamu fokus pada layar Apple. Ini dilakukan melalui perintah `asdcontrol`.

Perhatikan bahwa jika kamu menggunakan layar Apple 6K XDR, kamu mungkin melihat layar hantu dalam daftar `hyprctl monitors`-mu. Kamu dapat mematikan ini dengan sesuatu seperti `hl.monitor({ output = "DP-2", disabled = true })` melalui _Pengaturan > Monitor_.

Pada mesin Intel, kamu harus terhubung ke layar Apple menggunakan kabel Thunderbolt biasa. Pada mesin lain tanpa Thunderbolt, kamu biasanya harus menggunakan [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) agar bekerja.
