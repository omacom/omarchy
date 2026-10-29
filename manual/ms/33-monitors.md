# Monitor

Omarchy menganggap anda menggunakan paparan kelas retina berkemampuan 2x secara lalai. Inilah yang anda perlukan untuk mendapatkan fon pengatur cara yang cantik dan tajam itu. Inilah yang dioptimumkan untuk hampir semua komputer riba premium baharu dengan skrin resolusi tinggi. Inilah yang anda mahu gunakan pada 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) atau 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Tetapi jika anda tidak menggunakan paparan dengan PPI 218 atau lebih, anda mahu mengubah tetapan monitor. Sebagai contoh, jika anda mempunyai 4K 27" atau 32", anda boleh menggunakan penskalaan pecahan dengan membuka `~/.config/hypr/monitors.lua` (melalui _Setup > Monitors_ dalam menu Omarchy) dan beralih kepada cadangan untuk gabungan itu:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Jika anda menggunakan paparan 1080p atau 1440p, anda mungkin hanya mahu menggunakan penskalaan 1x, jadi anda boleh gunakan:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Perubahan pada `GDK_SCALE` terpakai pada aplikasi yang dimulakan selepas perubahan (dan GTK hanya menerima nombor bulat, jadi kekalkannya pada integer terdekat dengan skala monitor anda). Jadi pastikan anda menutup tetingkap yang bersaiz terlalu besar selepas perubahan (atau tutup semua tetingkap dengan `Ctrl + Alt + Del`!).

Anda juga boleh melalui nisbah penskalaan monitor utama (1x, 1.25x, 1.6x, 2x, 3x, 4x) dengan pantas menggunakan `Super + /` untuk naik dan `Super + Alt + /` untuk turun, atau pilih satu daripada panel monitor di bar atas. Ini hanya mengubah monitor yang sedang difokuskan, jadi skrin komputer riba dan paparan luaran masing-masing boleh mempunyai skala sendiri. Pilihan disimpan ke `~/.config/hypr/monitors.lua` sebagai peraturan `hl.monitor` untuk monitor tersebut, jadi ia kekal selepas but semula dan mengambil keutamaan berbanding `omarchy_monitor_scale`, yang kekal sebagai skala untuk setiap monitor tanpa peraturan sendiri. Memandangkan `GDK_SCALE` ialah satu nilai untuk semua skrin, perubahan ini menetapkannya daripada monitor dengan skala terendah, jadi aplikasi X11 kelihatan agak kecil pada skrin yang lebih padat dan bukannya terlalu besar pada skrin yang satu lagi.

### Menjadikan teks lebih besar atau lebih kecil

Penskalaan monitor mengubah saiz segala-galanya. Jika anda hanya mahu _teks_ yang lebih besar atau lebih kecil, ada satu kawalan tunggal untuk itu:

```
omarchy display text size 14
```

Ia mengambil saiz piksel antara 9 dan 20, dan menggerakkan shell Omarchy, aplikasi GTK, dan terminal anda bersama-sama, supaya keseluruhan desktop kekal berkadar. Jalankannya tanpa argumen untuk melihat kedudukan anda sekarang, dan `omarchy display text size reset` untuk kembali kepada lalai. Foot adalah satu-satunya yang tertinggal: ia tiada cara untuk memuat semula konfigurasinya, jadi terminal yang sedang berjalan mengekalkan saiz lama sehingga anda membuka yang baharu.

### Memanjangkan dan mencerminkan paparan komputer riba

Apabila anda menyambungkan skrin luaran ke komputer riba anda, paparan dipanjangkan secara automatik. Tetapi anda boleh mengubahnya kepada pencerminan sebaliknya menggunakan _Trigger > Hardware_ dalam menu Omarchy atau `Super + Ctrl + Alt + Delete`. Ini amat membantu jika skrin luaran itu ialah projektor, dan anda mahu menunjukkan sesuatu semasa bekerja.

Apabila anda memanjangkan paparan, menutup penutup komputer riba akan mematikan skrin dalaman secara automatik. Membuka penutup akan menghidupkannya semula. Anda juga boleh mengawal ini secara manual menggunakan _Trigger > Hardware_ dalam menu Omarchy atau `Super + Ctrl + Delete`.

### Menyusun berbilang skrin

Hyprland berfungsi dengan baik dengan berbilang skrin. Baca lebih lanjut tentang cara menyusunnya dalam [dokumentasi monitor Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Dalam Omarchy, ini diletakkan dalam `~/.config/hypr/monitors.lua` sebagai entri `hl.monitor` — fail ini disertakan dengan contoh berkomen untuk menetapkan monitor tertentu kepada resolusi, kedudukan, dan putaran.

Setiap monitor mempunyai ruang kerja 1 hingga 10 sendiri, jadi `Super + 1` sentiasa bermaksud ruang kerja pertama monitor yang anda gunakan. Di sebalik tabir, Hyprland masih menomborkan ruang kerja merentasi semua monitor: skrin komputer riba anda (atau monitor pertama) mendapat 1–10, monitor seterusnya 11–20, dan seterusnya, dan setiap monitor mengekalkan bloknya setiap kali anda menyambungkannya. Gunakan nombor tersebut jika anda menulis [peraturan ruang kerja](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) atau peraturan tetingkap untuk monitor tertentu, jadi ruang kerja 12 ialah ruang kerja kedua monitor kedua anda. `~/.local/state/omarchy/monitor-workspaces` menyenaraikan blok yang dimiliki setiap monitor.

Kekunci anak panah berfungsi merentasi monitor yang berkongsi tepi dalam susun atur anda. Skrin yang hanya bersentuhan di sudut, atau yang mempunyai jurang di antaranya, bukanlah jiran, jadi gunakan `Ctrl + Alt + Tab` untuk bergerak di antaranya.

| Kekunci pintas | Merentasi monitor |
| --- | --- |
| `Super + Arrow` | Memindahkan fokus ke monitor di sisi tersebut apabila tiada lagi tetingkap dalam arah itu |
| `Super + Shift + Arrow` | Bertukar dengan tetingkap pada monitor di sisi tersebut |
| `Super + Alt + Arrow` | Memindahkan tetingkap ke dalam kumpulan pada monitor di sisi tersebut |
| `Super + Shift + Ctrl + Arrow` | Memindahkan tetingkap ke monitor di sisi tersebut, ke ruang kerja yang dipaparkannya |
| `Super + Shift + Alt + Arrow` | Memindahkan ruang kerja ke monitor di sisi tersebut, mengekalkan nombornya jika kosong |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Memindahkan fokus ke monitor seterusnya atau sebelumnya, walau apa pun susun aturnya |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Kekal pada monitor yang anda gunakan |

Anda juga boleh mencuba [Hyprmon](https://github.com/erans/hyprmon/), jika anda mahukan TUI untuk membantu anda menentukan kedudukan berbilang skrin.

### Mengawal kecerahan

Kecerahan monitor dikawal oleh kekunci fungsi khusus untuk menaikkan/menurunkan kecerahan. Jika anda menahan shift semasa menekan kekunci ini, anda akan pergi ke kecerahan maksimum atau minimum. Kekunci mengawal paparan yang sedang difokuskan, jadi monitor luaran yang menyokong DDC/CI dilaraskan dengan cara yang sama seperti skrin komputer riba.

### Paparan Apple

Jika anda menggunakan paparan Apple, kekunci kecerahan papan kekunci biasa juga akan berfungsi secara automatik, jika anda memfokuskan pada paparan Apple. Ini dilakukan melalui arahan `asdcontrol`.

Ambil perhatian bahawa jika anda menggunakan paparan Apple 6K XDR, anda mungkin melihat skrin hantu dalam penyenaraian `hyprctl monitors` anda. Anda boleh mematikannya dengan sesuatu seperti `hl.monitor({ output = "DP-2", disabled = true })` melalui _Setup > Monitors_.

Pada mesin Intel, anda sepatutnya menyambung ke paparan Apple menggunakan kabel Thunderbolt biasa. Pada mesin lain tanpa Thunderbolt, anda biasanya perlu menggunakan [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) untuk menjadikannya berfungsi.
