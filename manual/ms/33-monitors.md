# Monitor

Omarchy menganggap anda menggunakan paparan kelas retina yang mampu 2x secara lalai. Inilah yang anda perlukan untuk mendapatkan fon pengatur cara yang cantik dan tajam itu. Inilah yang hampir semua komputer riba premium baharu dengan skrin resolusi tinggi dioptimumkan untuknya. Inilah yang anda mahu gunakan pada 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) atau 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Tetapi jika anda tidak menggunakan paparan dengan PPI 218 atau ke atas, anda mahu menukar tetapan monitor. Sebagai contoh, jika anda mempunyai 4K 27" atau 32", anda boleh memilih skala pecahan untuknya daripada panel monitor di bar atas, atau menetapkan lalai untuk setiap monitor dengan membuka `~/.config/hypr/monitors.lua` dan bertukar kepada cadangan untuk gabungan itu:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Jika anda menggunakan paparan 1080p atau 1440p, anda mungkin hanya mahu menggunakan penskalaan 1x, dan yang sama untuk aplikasi GTK dan X11, jadi anda boleh menggunakan:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Perubahan pada `GDK_SCALE` terpakai pada aplikasi yang dimulakan selepas perubahan itu (dan GTK hanya menerima nombor bulat, jadi kekalkannya pada integer terdekat dengan skala monitor anda). Jadi pastikan anda menutup tetingkap terlalu besar yang anda miliki selepas perubahan itu (atau tutup semua tetingkap dengan `Ctrl + Alt + Del`!).

Anda juga boleh melalui nisbah penskalaan monitor utama dengan pantas (1x, 1.25x, 1.6x, 2x, 3x, 4x) menggunakan `Super + /` untuk pergi lebih tinggi dan `Super + Alt + /` untuk pergi lebih rendah, atau pilih satu daripada panel monitor di bar atas. Ini hanya mengubah monitor yang anda fokuskan, jadi skrin komputer riba dan paparan luaran masing-masing boleh mempunyai skalanya sendiri. Panel itu juga menetapkan resolusi setiap monitor. Pilihan anda disimpan untuk monitor fizikal itu dalam `~/.local/state/omarchy/monitors/settings`, jadi ia kekal selepas but semula dan mengikut monitor itu ke mana-mana port atau dok yang dipalamkan seterusnya. Ia mengambil keutamaan berbanding sebarang peraturan untuk monitor yang sama dalam `~/.config/hypr/monitors.lua`, yang tidak pernah disunting oleh Omarchy. Jika anda lebih mahu menetapkan monitor anda sepenuhnya dalam fail itu, tambahkan `omarchy_monitor_panel_settings = false` padanya, dan perubahan panel itu hanya akan kekal sehingga Hyprland dimuat semula. Memandangkan `GDK_SCALE` ialah satu nilai untuk semua skrin, skala yang dipilih menetapkannya daripada monitor dengan skala terendah, jadi aplikasi X11 keluar sedikit kecil pada skrin yang lebih padat dan bukannya terlalu besar pada skrin yang satu lagi.

### Menjadikan teks lebih besar atau lebih kecil

Penskalaan monitor mengubah saiz segala-galanya. Jika yang anda mahukan hanyalah _teks_ yang lebih besar atau lebih kecil, ada satu tombol tunggal untuk itu:

```
omarchy display text size 14
```

Itu mengambil saiz piksel antara 9 dan 20, dan menggerakkan shell Omarchy, aplikasi GTK, dan terminal anda bersama-sama, supaya keseluruhan desktop kekal seimbang. Jalankannya tanpa argumen untuk melihat kedudukan semasa anda, dan `omarchy display text size reset` untuk kembali kepada lalai. Foot ialah satu-satunya yang tertinggal: ia tiada cara untuk memuat semula konfigurasinya, jadi terminal yang sedang berjalan akan mengekalkan saiz lamanya sehingga anda membuka terminal baharu.

### Memanjangkan dan mencerminkan paparan komputer riba

Apabila anda menyambungkan skrin luaran ke komputer riba anda, paparan akan dipanjangkan secara automatik. Tetapi anda boleh menukarnya kepada pencerminan sebaliknya menggunakan _Trigger > Hardware_ dalam menu Omarchy atau `Super + Ctrl + Alt + Delete`. Ini amat membantu jika skrin luaran itu ialah projektor, dan anda mahu menunjukkan sesuatu semasa bekerja.

Apabila anda memanjangkan, menutup penutup komputer riba akan mematikan skrin dalaman secara automatik. Membuka penutup akan menghidupkannya semula. Anda juga boleh mengawal ini secara manual menggunakan _Trigger > Hardware_ dalam menu Omarchy atau `Super + Ctrl + Delete`.

### Menyusun berbilang skrin

Hyprland berfungsi dengan baik dengan berbilang skrin. Panel monitor di bar atas melukisnya di tempat ia berada: seret satu ke sisi yang lain untuk memindahkannya ke sana, dan susunan itu disimpan bersama tetapan lain setiap monitor. Untuk apa-apa yang tidak diliputi oleh panel itu, baca lebih lanjut tentang cara menyusunnya dalam [dokumentasi monitor Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Dalam Omarchy, ini diletakkan dalam `~/.config/hypr/monitors.lua` sebagai entri `hl.monitor` — fail itu disertakan dengan contoh berkomen untuk menetapkan monitor tertentu kepada resolusi, kedudukan, dan putaran.

Setiap monitor mempunyai ruang kerja 1 hingga 10 sendiri, jadi `Super + 1` sentiasa bermaksud ruang kerja pertama monitor yang anda sedang berada. Di sebalik tabir, Hyprland masih menomborkan ruang kerja merentasi semua monitor: skrin komputer riba anda (atau monitor pertama) mendapat 1–10, monitor seterusnya 11–20, dan seterusnya, dan setiap monitor mengekalkan bloknya setiap kali anda memalamkannya. Gunakan nombor tersebut jika anda menulis [peraturan ruang kerja](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) atau peraturan tetingkap untuk monitor tertentu, jadi ruang kerja 12 ialah ruang kerja kedua monitor kedua anda. `~/.local/state/omarchy/monitors/workspaces` menyenaraikan blok yang dimiliki oleh setiap monitor.

Kekunci anak panah berfungsi merentasi monitor yang berkongsi tepi dalam susun atur anda. Skrin yang hanya bersentuh di sudut, atau yang mempunyai jurang di antaranya, bukanlah jiran, jadi gunakan `Ctrl + Alt + Tab` untuk bergerak di antaranya.

| Kekunci pintas | Merentasi monitor |
| --- | --- |
| `Super + Arrow` | Memindahkan fokus ke monitor di sisi itu sebaik sahaja tiada tetingkap lagi ke arah itu |
| `Super + Shift + Arrow` | Bertukar dengan tetingkap pada monitor di sisi itu |
| `Super + Alt + Arrow` | Memindahkan tetingkap ke dalam kumpulan pada monitor di sisi itu |
| `Super + Shift + Ctrl + Arrow` | Memindahkan tetingkap ke monitor di sisi itu, ke ruang kerja yang ditunjukkannya |
| `Super + Shift + Alt + Arrow` | Memindahkan ruang kerja ke monitor di sisi itu, mengekalkan nombornya jika ia bebas |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Memindahkan fokus ke monitor seterusnya atau sebelumnya, apa pun susun aturnya |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Kekal pada monitor yang anda sedang berada |

Anda juga boleh mencuba [Hyprmon](https://github.com/erans/hyprmon/), jika anda mahukan TUI untuk membantu anda dengan kedudukan berbilang skrin.

### Mengawal kecerahan

Kecerahan monitor dikawal oleh kekunci fungsi khusus untuk kecerahan naik/turun. Jika anda menahan shift sambil menekan kekunci ini, anda akan pergi ke kecerahan maksimum atau minimum. Kekunci ini mengawal paparan yang anda fokuskan, jadi monitor luaran yang bercakap DDC/CI dilaraskan dengan cara yang sama seperti skrin komputer riba.

### Paparan Apple

Jika anda menggunakan paparan Apple, kekunci kecerahan papan kekunci yang biasa juga akan berfungsi secara automatik, jika anda fokus pada paparan Apple itu. Ini dilakukan melalui arahan `asdcontrol`.

Ambil perhatian bahawa jika anda menggunakan paparan Apple 6K XDR, anda mungkin melihat skrin hantu dalam penyenaraian `hyprctl monitors` anda. Anda boleh mematikan ini dengan sesuatu seperti `hl.monitor({ output = "DP-2", disabled = true })` dalam `~/.config/hypr/monitors.lua`.

Pada mesin Intel, anda patut menyambung ke paparan Apple menggunakan kabel Thunderbolt yang biasa. Pada mesin lain tanpa Thunderbolt, anda biasanya perlu menggunakan [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) untuk menjadikannya berfungsi.
