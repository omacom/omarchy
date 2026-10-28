# Monitor

Omarchy menganggap secara lalai anda menggunakan paparan kelas retina yang mampu 2x. Inilah yang anda perlukan untuk mendapatkan fon pengaturcara yang cantik dan tajam itu. Inilah tetapan yang dioptimumkan untuk hampir semua laptop premium baharu dengan skrin beresolusi tinggi. Inilah yang anda mahu gunakan pada [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 27" 5K atau [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 32" 6K.

Tetapi jika anda tidak menggunakan paparan dengan PPI 218 atau ke atas, anda perlu menukar tetapan monitor. Sebagai contoh, jika anda mempunyai 4K 27" atau 32", anda boleh menggunakan penskalaan pecahan dengan membuka `~/.config/hypr/monitors.lua` (melalui _Setup > Monitors_ dalam menu Omarchy) dan beralih kepada cadangan untuk kombinasi tersebut:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Jika anda menggunakan paparan 1080p atau 1440p, anda mungkin hanya mahu menggunakan penskalaan 1x, jadi anda boleh menggunakan:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Perubahan pada `GDK_SCALE` terpakai pada aplikasi yang dimulakan selepas perubahan itu (dan GTK hanya menerima nombor bulat, jadi kekalkannya pada integer terdekat dengan skala monitor anda). Jadi pastikan anda menutup tetingkap yang anda miliki yang bersaiz terlalu besar selepas perubahan itu (atau tutup semua tetingkap dengan `Ctrl + Alt + Del`!).

Anda juga boleh melangkah dengan cepat melalui nisbah penskalaan monitor utama (1x, 1.25x, 1.6x, 2x, 3x, 4x) menggunakan `Super + /` untuk pergi lebih tinggi dan `Super + Alt + /` untuk pergi lebih rendah, atau pilih satu daripada panel monitor di bar atas. Ini hanya menukar monitor yang anda fokuskan, jadi skrin laptop dan paparan luaran masing-masing boleh mempunyai skalanya sendiri. Pilihan itu disimpan ke `~/.config/hypr/monitors.lua` sebagai peraturan `hl.monitor` untuk monitor tersebut, jadi ia kekal selepas but semula dan diutamakan berbanding `omarchy_monitor_scale`, yang kekal sebagai skala untuk setiap monitor yang tiada peraturannya sendiri.

### Menjadikan teks lebih besar atau lebih kecil

Penskalaan monitor menukar saiz segala-galanya. Jika yang anda mahukan hanyalah _teks_ yang lebih besar atau lebih kecil, ada satu tombol tunggal untuk itu:

```
omarchy display text size 14
```

Itu mengambil saiz piksel antara 9 dan 20, dan menggerakkan shell Omarchy, aplikasi GTK, dan terminal anda bersama-sama, jadi seluruh desktop kekal seimbang. Jalankannya tanpa argumen untuk melihat kedudukan anda sekarang, dan `omarchy display text size reset` untuk kembali kepada lalai. Foot ialah satu-satunya yang tertinggal: ia tiada cara untuk memuat semula konfigurasinya, jadi terminal yang sedang berjalan mengekalkan saiz lamanya sehingga anda membuka terminal baharu.

### Memanjangkan dan mencerminkan paparan laptop

Apabila anda menyambungkan skrin luaran ke laptop anda, paparan dipanjangkan secara automatik. Tetapi anda boleh menukarnya kepada pencerminan sebaliknya menggunakan _Trigger > Hardware_ dalam menu Omarchy atau `Super + Ctrl + Alt + Delete`. Ini amat membantu jika skrin luaran itu ialah projektor, dan anda mahu menunjukkan sesuatu semasa bekerja.

Apabila anda memanjangkan paparan, menutup penutup laptop akan mematikan skrin dalaman secara automatik. Membuka penutup akan menghidupkannya semula. Anda juga boleh mengawal ini secara manual menggunakan _Trigger > Hardware_ dalam menu Omarchy atau `Super + Ctrl + Delete`.

### Menyusun berbilang skrin

Hyprland berfungsi dengan hebat dengan berbilang skrin. Baca lebih lanjut tentang cara menyusunnya dalam [dokumentasi monitor Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Dalam Omarchy, ini diletakkan dalam `~/.config/hypr/monitors.lua` sebagai entri `hl.monitor` — fail itu disertakan dengan contoh berkomen untuk menetapkan monitor tertentu kepada resolusi, kedudukan, dan putaran.

Setiap monitor mempunyai ruang kerja 1 hingga 10 sendiri, jadi `Super + 1` sentiasa bermaksud ruang kerja pertama pada monitor yang anda gunakan. Di sebalik tabir, Hyprland masih menomborkan ruang kerja merentasi semua monitor: skrin laptop anda (atau monitor pertama) mendapat 1–10, monitor seterusnya 11–20, dan seterusnya, dan setiap monitor mengekalkan bloknya setiap kali anda menyambungkannya. Gunakan nombor tersebut jika anda menulis [peraturan ruang kerja](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) atau peraturan tetingkap untuk monitor tertentu, jadi ruang kerja 12 ialah ruang kerja kedua pada monitor kedua anda. `~/.local/state/omarchy/monitor-workspaces` menyenaraikan blok yang dimiliki setiap monitor.

Kekunci anak panah berfungsi merentasi monitor yang berkongsi tepi dalam susun atur anda. Skrin yang hanya bersentuhan di penjuru, atau yang mempunyai jurang di antaranya, bukanlah jiran, jadi gunakan `Ctrl + Alt + Tab` untuk bergerak antaranya.

| Kekunci pintas | Merentasi monitor |
| --- | --- |
| `Super + Arrow` | Menggerakkan fokus ke monitor di sebelah itu apabila tiada lagi tetingkap ke arah itu |
| `Super + Shift + Arrow` | Bertukar dengan tetingkap pada monitor di sebelah itu |
| `Super + Alt + Arrow` | Menggerakkan tetingkap ke dalam kumpulan pada monitor di sebelah itu |
| `Super + Shift + Ctrl + Arrow` | Menggerakkan tetingkap ke monitor di sebelah itu, ke ruang kerja yang ditunjukkannya |
| `Super + Shift + Alt + Arrow` | Menggerakkan ruang kerja ke monitor di sebelah itu, mengekalkan nombornya jika nombor itu kosong |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Menggerakkan fokus ke monitor seterusnya atau sebelumnya, walau apa pun susun aturnya |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Kekal pada monitor yang anda gunakan |

Anda juga boleh mencuba [Hyprmon](https://github.com/erans/hyprmon/), jika anda mahukan TUI untuk membantu anda menentukan kedudukan berbilang skrin.

### Mengawal kecerahan

Kecerahan monitor dikawal oleh kekunci fungsi khusus untuk kecerahan naik/turun. Jika anda menahan Shift semasa menekan kekunci ini, anda akan pergi ke kecerahan maksimum atau minimum. Kekunci ini mengawal paparan yang anda fokuskan, jadi monitor luaran yang menggunakan DDC/CI dilaraskan dengan cara yang sama seperti skrin laptop.

### Paparan Apple

Jika anda menggunakan paparan Apple, kekunci kecerahan papan kekunci biasa juga akan berfungsi secara automatik, jika anda fokus pada paparan Apple itu. Ini dilakukan melalui perintah `asdcontrol`.

Ambil perhatian bahawa jika anda menggunakan paparan Apple 6K XDR, anda mungkin melihat skrin hantu dalam penyenaraian `hyprctl monitors` anda. Anda boleh mematikan ini dengan sesuatu seperti `hl.monitor({ output = "DP-2", disabled = true })` melalui _Setup > Monitors_.

Pada mesin Intel, anda patut menyambung ke paparan Apple menggunakan kabel Thunderbolt biasa. Pada mesin lain tanpa Thunderbolt, anda biasanya perlu menggunakan [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) untuk menjadikannya berfungsi.
