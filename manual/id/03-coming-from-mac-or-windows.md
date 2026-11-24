# Beralih dari Mac atau Windows

Jika Anda sudah bertahun-tahun menggunakan macOS atau Windows, jari-jari Anda tahu seratus hal yang otak Anda sudah lupa pernah dipelajarinya. Bab ini adalah lapisan penerjemahnya: ke mana insting-insting itu pergi di Omarchy. Fitur-fiturnya sendiri dibahas secara mendalam di tempat lain — ini hanya petanya.

### Super adalah pusat segalanya

Semua memori otot yang telah Anda bangun di sekitar Cmd atau tombol Windows beralih ke satu tombol: Super. Itu adalah tombol Windows pada keyboard PC, dan tombol ini menjadi jangkar untuk hampir setiap hotkey di Omarchy.

Refleks Spotlight atau Raycast atau menu Start Anda menjadi `Super + Space`. Itu membuka menu Omarchy, yang meluncurkan aplikasi, mengubah pengaturan, menginstal perangkat lunak, menangkap layar — hampir semuanya. Mulai mengetik untuk memfilter. `Super + Alt + Space` menampilkan setiap aplikasi dalam satu kisi, seperti cara Launchpad bekerja. Lihat [navigasi](04-navigation.md).

### Tidak ada ikon desktop, dan dock hanya muncul saat Anda mengambang

Tidak ada ikon untuk diatur di desktop, dan tidak ada dock pada workspace tiling — dock hanya muncul pada workspace floating (lihat [navigasi](04-navigation.md)). Aplikasi dimulai dari hotkey (`Super + Return` untuk terminal, `Super + Shift + Return` untuk browser, dan `Super + K` untuk daftar semua yang dipetakan) atau dari menu. Satu-satunya bagian UI yang tetap ada adalah [bilah atas](05-the-top-bar.md), yang mencakup apa yang sebelumnya dilakukan oleh menu bar, system tray, dan Notification Center untuk Anda — dan hampir setiap widget di dalamnya melakukan sesuatu saat diklik kiri, kanan, dan tengah.

### Jendela menempatkan diri sendiri

Pergeseran pola pikir terbesar: Anda tidak menyeret jendela ke sana kemari atau menempelkannya ke separuh layar. Buka satu jendela dan jendela itu memenuhi seluruh layar. Buka yang kedua dan keduanya membagi layar. Anda tidak pernah harus memancing satu jendela keluar dari bawah jendela lain, karena jendela tidak tumpang tindih.

Saat Anda benar-benar membutuhkan jendela floating, `Super + T` mengeluarkan jendela aktif dari tiling (dan mengembalikannya). Tapi beri tiling kesempatan yang sungguh-sungguh terlebih dahulu — itulah jantung dari segalanya. [Navigasi](04-navigation.md) akan memandu Anda melewatinya.

Workspace akan terasa familier: mereka seperti macOS Spaces atau desktop virtual Windows, kecuali Anda benar-benar akan menggunakannya, karena `Super + 1/2/3/4` langsung melompat ke salah satunya dan `Super + Shift + 1/2/3/4` mengirim jendela aktif ke sana. Tidak ada jeda animasi, hanya lompatan instan. Ini berarti Anda mungkin bahkan tidak membutuhkan banyak monitor, jika sebelumnya Anda terbiasa seperti itu.

### Salin dan tempel langsung berfungsi

Di Mac Anda punya Cmd + C di mana-mana. Di Windows Anda punya Ctrl + C di mana-mana — kecuali terminal, di mana tombol itu membunuh program Anda. Omarchy memberi Anda `Super + C`, `Super + X`, dan `Super + V`, dan semuanya berfungsi di mana-mana, termasuk terminal. Tidak ada refleks terpisah yang harus dipelajari untuk shell.

Pengguna Windows: riwayat clipboard Win + V Anda kini ada di `Super + Ctrl + V`, dan riwayat itu menyimpan gambar maupun teks. Lihat [clipboard & riwayat terpadu](08-unified-clipboard-history.md).

### Tabel penerjemahan

| Yang Anda cari | Di Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — menu Omarchy |
| AirDrop | LocalSend, melalui `Super + Ctrl + S` — lihat [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` atau `Print Screen` — lihat [tangkapan layar & perekaman](12-screenshots-recording.md) |
| Notification Center | Riwayat notifikasi di `Super + Shift + Alt + ,` |
| Time Machine (untuk sistem) | [Snapshot sistem](47-system-snapshots.md) otomatis pada setiap pembaruan |
| App Store / mengunduh installer | _Install_ di menu, atau `omarchy pkg add` — lihat [paket lain](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ di menu, yang mengedit file konfigurasi biasa — lihat [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, di `Super + Shift + F` — lihat [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome di `Super + Shift + Return`; pilih yang lain di bawah _Setup > Defaults > Browser_ — lihat [browser](23-browsers.md) |
| Preview / Photos | Omaview untuk gambar, video dan musik, Document Viewer untuk PDF — lihat [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, di `Super + Shift + N`; pilih yang lain di bawah _Setup > Defaults > Editor_ |

### Beberapa hal memang benar-benar berbeda

Banyak pengaturan tinggal di file teks yang Anda edit, bukan panel yang Anda klik-klik. Itu terdengar primitif sampai Anda menyadari bahwa itu berarti setiap penyesuaian dapat dilihat, disalin ke mesin Anda berikutnya, dan dimasukkan ke dalam version control. Menu _Setup_ langsung membawa Anda ke file yang tepat dan memulai ulang apa pun yang perlu dimulai ulang setelah Anda selesai.

Pembaruan datang melalui satu perintah — _Update > Omarchy_ — yang memperbarui Omarchy itu sendiri dan setiap paket pada sistem, dengan mengambil snapshot terlebih dahulu. Tidak ada updater per aplikasi yang mengganggu Anda secara acak. Lihat [pembaruan](30-updates.md).

Perangkat lunak berasal dari package manager, bukan dari installer yang diunduh.

Dan saat Anda menutup sebuah jendela, aplikasinya benar-benar berhenti. Tidak ada limbo macOS di mana program tetap berjalan tanpa jendela. `Super + W` — atau `Super + Q`, jika itu memori jari yang Anda bawa — berarti hilang.

### Pada perangkat keras Mac

Omarchy berjalan dengan baik pada Mac Intel, dan pada Mac M1, M2 dan M3 dengan Omarchy for Apple Silicon. Lihat [dukungan Mac](44-mac-support.md). Dan keyboard bersikap baik kepada Anda: Omarchy tidak memetakan ulang apa pun, dan Linux memperlakukan tombol Command sebagai Super, jadi Super berada tepat di tempat Cmd selalu berada. Ibu jari Anda tidak akan menyadari perpindahan itu.

### Beri waktu dua minggu

Insting-insting itu beralih lebih cepat dari yang Anda kira. Baca sekilas bab [hotkeys](07-hotkeys.md) sekali, dan setiap kali Anda lupa sebuah binding, tekan `Super + K` — tombol itu menampilkan semuanya kepada Anda. Itulah satu-satunya hotkey yang benar-benar harus Anda hafal.
