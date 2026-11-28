# Beralih dari Mac atau Windows

Jika kamu sudah bertahun-tahun memakai macOS atau Windows, jari-jarimu tahu ratusan hal yang otakmu sudah lupa pernah dipelajarinya. Bab ini adalah lapisan penerjemahnya: ke mana insting-insting itu pergi di Omarchy. Fitur-fiturnya sendiri dibahas secara mendalam di tempat lain — ini hanya petanya.

### Super adalah pusat dari segalanya

Semua memori otot yang telah kamu bangun di sekitar Cmd atau tombol Windows berpindah ke satu tombol: Super. Itu adalah tombol Windows pada keyboard PC, dan itu adalah jangkar untuk hampir setiap hotkey di Omarchy.

Refleks Spotlight atau Raycast atau menu Start-mu menjadi `Super + Space`. Itu membuka menu Omarchy, yang meluncurkan aplikasi, mengubah pengaturan, menginstal perangkat lunak, menangkap layar — hampir semuanya. Mulai mengetik untuk memfilter. `Super + Alt + Space` menampilkan setiap aplikasi dalam satu grid, seperti cara Launchpad melakukannya. Lihat [navigasi](04-navigation.md).

### Tidak ada ikon desktop, dan dock tetap tidak menghalangi

Tidak ada ikon untuk diatur di desktop, dan dock bersembunyi setelah sebuah workspace memiliki jendela, sampai kamu mendorong pointer ke tepi layarnya, tepi bawah kecuali kamu memindahkannya (lihat [navigasi](04-navigation.md)). Aplikasi dimulai dari sebuah hotkey (`Super + Return` untuk terminal, `Super + Shift + Return` untuk browser, dan `Super + K` untuk daftar semua yang dipetakan) atau dari menu. Satu-satunya bagian UI yang tetap ada adalah [bar atas](05-the-top-bar.md), yang mencakup apa yang sebelumnya dilakukan oleh menu bar, system tray, dan Notification Center untukmu — dan hampir setiap widget di atasnya melakukan sesuatu pada klik kiri, kanan, dan tengah.

### Jendela menempatkan dirinya sendiri

Pergeseran pola pikir terbesar: kamu tidak menyeret jendela ke sana kemari atau menempelkannya ke separuh layar. Buka sebuah jendela dan jendela itu memenuhi seluruh layar. Buka yang kedua dan mereka membaginya. Kamu tidak pernah memancing sebuah jendela keluar dari bawah jendela lain, karena jendela-jendela itu tidak tumpang tindih.

Ketika kamu benar-benar membutuhkan jendela melayang, `Super + T` mengalihkan jendela aktif keluar dari tiling (dan kembali lagi). Tapi beri tiling kesempatan yang sungguh-sungguh terlebih dahulu — itu adalah jantung dari keseluruhan hal ini. [Navigasi](04-navigation.md) memandumu melaluinya.

Workspaces akan terasa familier: mereka adalah Spaces di macOS atau desktop virtual Windows, kecuali kamu akan benar-benar menggunakannya, karena `Super + 1/2/3/4` langsung melompat ke salah satunya dan `Super + Shift + 1/2/3/4` mengirim jendela aktif ke sana. Tanpa jeda animasi, hanya lompatan instan. Ini berarti kamu bahkan mungkin tidak membutuhkan banyak monitor, jika kamu terbiasa dengan itu sebelumnya.

### Salin dan tempel langsung berfungsi

Di Mac kamu punya Cmd + C di mana-mana. Di Windows kamu punya Ctrl + C di mana-mana — kecuali terminal, di mana itu membunuh programmu. Omarchy memberimu `Super + C`, `Super + X`, dan `Super + V`, dan semuanya berfungsi di mana-mana, termasuk terminal. Tidak ada refleks terpisah yang perlu dipelajari untuk shell.

Para pengguna Windows: riwayat clipboard Win + V-mu ada di `Super + Ctrl + V`, dan itu menyimpan gambar maupun teks. Lihat [clipboard terpadu & riwayat](08-unified-clipboard-history.md).

### Tabel penerjemahan

| Yang biasa kamu jangkau | Di Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — menu Omarchy |
| AirDrop | LocalSend, melalui `Super + Ctrl + S` — lihat [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` atau `Print Screen` — lihat [tangkapan layar & perekaman](12-screenshots-recording.md) |
| Notification Center | Riwayat notifikasi pada `Super + Shift + Alt + ,` |
| Time Machine (untuk sistem) | [Snapshot sistem](47-system-snapshots.md) otomatis pada setiap pembaruan |
| App Store / mengunduh sebuah installer | _Install_ di menu, atau `omarchy pkg add` — lihat [paket lain](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ di menu, yang mengedit file konfigurasi biasa — lihat [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, pada `Super + Shift + F` — lihat [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome pada `Super + Shift + Return`; pilih yang lain di _Setup > Defaults > Browser_ — lihat [browser](23-browsers.md) |
| Preview / Photos | Omaview untuk gambar, video dan musik, Document Viewer untuk PDF — lihat [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, pada `Super + Shift + N`; pilih yang lain di _Setup > Defaults > Editor_ |

### Beberapa hal memang benar-benar berbeda

Banyak pengaturan berada di file teks yang kamu edit, bukan panel yang kamu klik satu per satu. Itu terdengar primitif sampai kamu menyadari itu berarti setiap penyesuaian bisa dilihat, disalin ke mesinmu berikutnya, dan dimasukkan ke version control. Menu _Setup_ membawamu langsung ke file yang tepat dan memulai ulang apa pun yang perlu dimulai ulang ketika kamu selesai.

Pembaruan datang melalui satu perintah — _Update > Omarchy_ — yang memperbarui Omarchy itu sendiri dan setiap paket di sistem, dengan mengambil snapshot terlebih dahulu. Tidak ada updater per-aplikasi yang mengganggumu di waktu acak. Lihat [pembaruan](30-updates.md).

Perangkat lunak datang dari sebuah package manager, bukan dari installer yang diunduh.

Dan ketika kamu menutup sebuah jendela, aplikasinya benar-benar keluar. Tidak ada limbo macOS di mana program terus berjalan tanpa jendela. `Super + W` — atau `Super + Q`, jika itu adalah memori jari yang kamu bawa — berarti hilang.

### Di perangkat keras Mac

Omarchy berjalan dengan baik di Mac Intel, dan di Mac M1, M2 dan M3 dengan Omarchy for Apple Silicon. Lihat [dukungan Mac](44-mac-support.md). Dan keyboard bersikap baik padamu: Omarchy tidak memetakan ulang apa pun, dan Linux memperlakukan tombol Command sebagai Super, jadi Super berada tepat di tempat Cmd selalu berada. Jempolmu tidak akan menyadari perpindahannya.

### Beri waktu dua minggu

Insting-insting itu berpindah lebih cepat dari yang kamu kira. Baca sekilas bab [hotkeys](07-hotkeys.md) sekali, dan setiap kali kamu lupa sebuah binding, tekan `Super + K` — itu menampilkan semuanya kepadamu. Itulah satu-satunya hotkey yang benar-benar harus kamu hafalkan.
