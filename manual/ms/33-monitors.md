# Monitor

Omarchy mengandaikan anda berjalan pada paparan kelas retina berupaya 2x secara lalai. Ini adalah apa yang anda perlukan untuk mendapatkan fon pengaturcara yang bagus dan tajam itu. Ia adalah apa yang dioptimumkan oleh hampir semua komputer riba premium baharu dengan skrin resolusi tinggi. Ia adalah apa yang anda mahu jalankan pada 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) atau 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Tetapi jika anda tidak menjalankan paparan dengan PPI 218 atau ke atas, anda akan mahu mengubah tetapan monitor. Contohnya, jika anda ada 27" atau 32" 4K, anda boleh menggunakan penskalaan pecahan dengan membuka `~/.config/hypr/monitors.lua` (melalui _Persediaan > Monitor_ dalam menu Omarchy) dan menukar kepada cadangan untuk gabungan itu:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Jika anda menggunakan paparan 1080p atau 1440p, anda mungkin hanya mahu menggunakan penskalaan 1x, jadi anda boleh menggunakan:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Perubahan pada `GDK_SCALE` berkuat kuasa pada aplikasi yang dimulakan selepas perubahan (dan GTK hanya mematuhi nombor bulat, jadi kekalkannya pada integer terdekat skala monitor anda). Jadi pastikan anda menutup tetingkap yang anda ada yang terlalu besar selepas perubahan (atau tutup semua tetingkap dengan `Ctrl + Alt + Del`!).

Anda juga boleh bergerak dengan cepat melalui nisbah penskalaan monitor utama (1x, 1.25x, 1.6x, 2x, 3x, 4x) menggunakan `Super + /` untuk pergi lebih tinggi dan `Super + Alt + /` untuk pergi lebih rendah. Jika anda mempunyai konfigurasi lalai, perubahan ini juga akan kekal merentasi but semula.

### Menjadikan teks lebih besar atau lebih kecil

Penskalaan monitor mengubah saiz segalanya. Jika anda hanya mahu _teks_ yang lebih besar atau lebih kecil, ada satu tombol untuk itu:

```
omarchy display text size 14
```

Itu menerima saiz piksel antara 9 dan 20, dan menggerakkan shell Omarchy, aplikasi GTK, dan terminal anda bersama, supaya keseluruhan desktop kekal dalam perkadaran. Jalankannya tanpa argumen untuk melihat di mana anda berada, dan `omarchy display text size reset` untuk kembali kepada lalai. Foot ialah satu-satunya yang tertinggal: ia tiada cara untuk memuatkan semula konfigurasinya, jadi terminal yang berjalan menyimpan saiz lama sehingga anda membuka yang baharu.

### Memanjangkan dan mencerminkan paparan komputer riba

Apabila anda menyambungkan skrin luar ke komputer riba anda, paparan dilanjutkan secara automatik. Tetapi anda boleh mengubahnya kepada pencerminan sebaliknya menggunakan _Pencetus > Perkakasan_ dalam menu Omarchy atau `Super + Ctrl + Alt + Delete`. Ini sangat membantu jika skrin luar itu ialah projektor, dan anda mahu menunjukkan sesuatu semasa bekerja.

Apabila anda memanjangkan, menutup tudung komputer riba akan mematikan skrin dalaman secara automatik. Membuka tudung akan menghidupkannya semula. Anda juga boleh mengawalnya secara manual menggunakan _Pencetus > Perkakasan_ dalam menu Omarchy atau `Super + Ctrl + Delete`.

### Menyusun berbilang skrin

Hyprland berfungsi dengan hebat dengan berbilang skrin. Baca lebih lanjut tentang cara menyusunnya dalam [dokumentasi monitor Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Anda juga boleh [mengikat ruang kerja tertentu kepada monitor tertentu](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). Dalam Omarchy, peraturan ini berada dalam `~/.config/hypr/monitors.lua` sebagai entri `hl.monitor` — fail dihantar dengan contoh berkomen untuk menyerakkan monitor tertentu kepada resolusi, kedudukan, dan putaran.

Anda juga boleh menyemak [Hyprmon](https://github.com/erans/hyprmon/), jika anda mahukan TUI untuk membantu anda dengan kedudukan berbilang skrin.

### Mengawal kecerahan

Kecerahan monitor dikawal oleh kekunci fungsi kecerahan naik/turun yang khusus. Jika anda menahan shift semasa menekan ini, anda akan pergi ke kecerahan maksimum atau minimum. Kekunci mengawal paparan yang anda fokus, jadi monitor luar yang bercakap DDC/CI dilaraskan dengan cara yang sama seperti skrin komputer riba.

### Paparan Apple

Jika anda menggunakan paparan Apple, kekunci kecerahan papan kekunci biasa juga akan berfungsi secara automatik, jika anda fokus pada paparan Apple. Ini dilakukan melalui perintah `asdcontrol`.

Perhatikan bahawa jika anda menggunakan paparan Apple 6K XDR, anda mungkin melihat skrin hantu dalam senarai `hyprctl monitors` anda. Anda boleh mematikannya dengan sesuatu seperti `hl.monitor({ output = "DP-2", disabled = true })` melalui _Persediaan > Monitor_.

Pada mesin Intel, anda patut menyambung ke paparan Apple menggunakan kabel Thunderbolt biasa. Pada mesin lain tanpa Thunderbolt, anda biasanya perlu menggunakan [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) untuk menjadikannya berfungsi.
