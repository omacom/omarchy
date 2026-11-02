# Monitor

Omarchy mengandaikan anda menggunakan paparan kelas retina berkeupayaan 2x secara lalai. Inilah yang anda perlukan untuk mendapatkan fon pengatur cara yang cantik dan tajam itu. Inilah yang dioptimumkan untuk hampir semua komputer riba premium baharu dengan skrin resolusi tinggi. Inilah yang anda mahu gunakan pada [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 27" 5K atau [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) 32" 6K.

Tetapi jika anda tidak menggunakan paparan dengan PPI 218 atau lebih tinggi, anda perlu menukar tetapan monitor. Contohnya, jika anda mempunyai 4K 27" atau 32", anda boleh memilih skala pecahan untuknya daripada panel monitor di bar atas, atau menetapkan lalai untuk setiap monitor dengan membuka `~/.config/hypr/monitors.lua` dan beralih kepada cadangan untuk gabungan itu:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Jika anda menggunakan paparan 1080p atau 1440p, anda mungkin hanya mahu menggunakan penskalaan 1x, dan begitu juga untuk aplikasi GTK dan X11, jadi anda boleh menggunakan:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Perubahan pada `GDK_SCALE` berkuat kuasa untuk aplikasi yang dimulakan selepas perubahan itu (dan GTK hanya menerima nombor bulat, jadi kekalkannya pada integer terdekat dengan skala monitor anda). Jadi pastikan anda menutup tetingkap yang terlalu besar yang anda miliki selepas perubahan itu (atau tutup semua tetingkap dengan `Ctrl + Alt + Del`!).

Anda juga boleh melangkah dengan pantas melalui nisbah penskalaan monitor utama (1x, 1.25x, 1.6x, 2x, 3x, 4x) menggunakan `Super + /` untuk menaikkan dan `Super + Alt + /` untuk menurunkan, atau memilih satu daripada panel monitor di bar atas. Perubahan ini hanya menjejaskan monitor yang sedang anda fokuskan, jadi skrin komputer riba dan paparan luaran masing-masing boleh mempunyai skalanya sendiri. Panel itu juga menetapkan resolusi, kadar segar semula dan putaran setiap monitor. Pilihan anda disimpan untuk monitor fizikal itu dalam `~/.local/state/omarchy/monitors/settings`, jadi pilihan itu kekal selepas but semula dan mengikut monitor itu ke mana-mana port atau dok yang dipasangkannya selepas ini. Pilihan itu diutamakan berbanding sebarang peraturan untuk monitor yang sama dalam `~/.config/hypr/monitors.lua`, yang tidak pernah disunting oleh Omarchy. Jika anda lebih suka menetapkan monitor anda sepenuhnya dalam fail itu, tambahkan `omarchy_monitor_panel_settings = false` padanya, dan perubahan panel itu hanya akan bertahan sehingga Hyprland dimuat semula. Memandangkan `GDK_SCALE` ialah satu nilai untuk semua skrin, skala yang dipilih menetapkannya berdasarkan monitor dengan skala terendah, jadi aplikasi X11 menjadi sedikit kecil pada skrin yang lebih padat dan bukannya terlalu besar pada skrin yang satu lagi.

### Menjadikan teks lebih besar atau lebih kecil

Penskalaan monitor mengubah saiz segala-galanya. Jika anda hanya mahukan _teks_ yang lebih besar atau lebih kecil, ada satu tombol tunggal untuk itu:

```
omarchy display text size 14
```

Perintah itu menerima saiz piksel antara 9 dan 20, dan menggerakkan shell Omarchy, aplikasi GTK dan terminal anda bersama-sama, supaya keseluruhan desktop kekal seimbang. Jalankannya tanpa argumen untuk melihat kedudukan anda sekarang, dan `omarchy display text size reset` untuk kembali kepada lalai. Foot ialah satu-satunya yang ketinggalan: ia tidak mempunyai cara untuk memuat semula konfigurasinya, jadi terminal yang sedang berjalan mengekalkan saiz lamanya sehingga anda membuka terminal baharu.

### Memanjangkan dan mencerminkan paparan komputer riba

Apabila anda menyambungkan skrin luaran ke komputer riba anda, paparan dipanjangkan secara automatik. Tetapi anda boleh menukarnya kepada pencerminan sebaliknya menggunakan _Trigger > Hardware_ dalam menu Omarchy atau `Super + Ctrl + Alt + Delete`. Ini amat membantu jika skrin luaran itu ialah projektor, dan anda mahu menunjukkan sesuatu semasa bekerja.

Apabila anda memanjangkan paparan, menutup penutup komputer riba akan mematikan skrin dalaman secara automatik. Membuka penutup akan menghidupkannya semula. Anda juga boleh mengawal ini secara manual menggunakan _Trigger > Hardware_ dalam menu Omarchy atau `Super + Ctrl + Delete`.

### Menyusun berbilang skrin

Hyprland berfungsi dengan hebat bersama berbilang skrin. Panel monitor di bar atas melukisnya di kedudukan tempatnya berada: seret satu skrin ke sisi skrin lain untuk mengalihkannya ke sana, dan susunan itu disimpan bersama tetapan lain setiap monitor. Untuk apa-apa yang tidak diliputi oleh panel itu, baca lebih lanjut tentang cara menyusunnya dalam [dokumentasi monitor Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Dalam Omarchy, tetapan ini diletakkan dalam `~/.config/hypr/monitors.lua` sebagai entri `hl.monitor` — fail itu disertakan dengan contoh berkomen untuk memastikan monitor dimatikan, mod yang tidak ditawarkan oleh panel, warna 10-bit dan kadar segar semula boleh ubah.

Setiap monitor mempunyai ruang kerja 1 hingga 10 sendiri, jadi `Super + 1` sentiasa bermaksud ruang kerja pertama monitor yang sedang anda gunakan. Di sebalik tabir, Hyprland masih menomborkan ruang kerja merentas semua monitor: skrin komputer riba anda (atau monitor pertama) mendapat 1–10, monitor seterusnya 11–20, dan seterusnya, dan setiap monitor mengekalkan bloknya setiap kali anda memasangkannya. Gunakan nombor tersebut jika anda menulis [peraturan ruang kerja](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) atau peraturan tetingkap untuk monitor tertentu, supaya ruang kerja 12 ialah ruang kerja kedua monitor kedua anda. `~/.local/state/omarchy/monitors/workspaces` menyenaraikan blok yang dimiliki oleh setiap monitor.

Kekunci anak panah berfungsi merentas monitor yang berkongsi tepi dalam susun atur anda. Skrin yang hanya bersentuhan di sudut, atau yang mempunyai jurang antaranya, bukanlah jiran, jadi gunakan `Ctrl + Alt + Tab` untuk bergerak antaranya.

| Hotkey | Across monitors |
| --- | --- |
| `Super + Arrow` | Memindahkan fokus ke monitor di sebelah itu apabila tiada lagi tetingkap ke arah itu |
| `Super + Shift + Arrow` | Bertukar dengan tetingkap pada monitor di sebelah itu |
| `Super + Alt + Arrow` | Memindahkan tetingkap ke dalam kumpulan pada monitor di sebelah itu |
| `Super + Shift + Ctrl + Arrow` | Memindahkan tetingkap ke monitor di sebelah itu, ke ruang kerja yang sedang dipaparkannya |
| `Super + Shift + Alt + Arrow` | Memindahkan ruang kerja ke monitor di sebelah itu, mengekalkan nombornya jika nombor itu kosong |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Memindahkan fokus ke monitor seterusnya atau sebelumnya, walau apa pun susun aturnya |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Kekal pada monitor yang sedang anda gunakan |

Anda juga boleh mencuba [Hyprmon](https://github.com/erans/hyprmon/), jika anda mahukan TUI untuk membantu anda menentukan kedudukan berbilang skrin.

### Mengawal kecerahan

Kecerahan monitor dikawal oleh kekunci fungsi khusus untuk menaikkan/menurunkan kecerahan. Jika anda menahan Shift semasa menekan kekunci ini, anda akan pergi ke kecerahan maksimum atau minimum. Kekunci itu mengawal paparan yang sedang anda fokuskan, jadi monitor luaran yang menggunakan DDC/CI dilaraskan dengan cara yang sama seperti skrin komputer riba.

### Paparan Apple

Jika anda menggunakan paparan Apple, kekunci kecerahan papan kekunci biasa juga akan berfungsi secara automatik, jika anda sedang memfokuskan paparan Apple itu. Ini dilakukan melalui perintah `asdcontrol`.

Ambil perhatian bahawa jika anda menggunakan paparan Apple 6K XDR, anda mungkin melihat skrin hantu dalam penyenaraian `hyprctl monitors` anda. Anda boleh mematikan ini dengan sesuatu seperti `hl.monitor({ output = "DP-2", disabled = true })` dalam `~/.config/hypr/monitors.lua`.

Pada mesin Intel, anda harus menyambung ke paparan Apple menggunakan kabel Thunderbolt biasa. Pada mesin lain tanpa Thunderbolt, anda biasanya perlu menggunakan [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) untuk menjadikannya berfungsi.
