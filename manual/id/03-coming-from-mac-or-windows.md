# Berpindah dari Mac atau Windows

Jika Anda telah bertahun-tahun menggunakan macOS atau Windows, jari-jari Anda mengetahui ratusan hal yang otak Anda telah lupa pernah mempelajarinya. Bab ini adalah lapisan terjemahannya: ke mana insting-insting itu pergi di Omarchy. Fitur-fiturnya sendiri dibahas secara mendalam di tempat lain — ini hanya petanya.

### Super adalah pusat dari segalanya

Semua memori otot yang telah Anda bangun di sekitar Cmd atau tombol Windows beralih ke satu tombol: Super. Itu adalah tombol Windows pada keyboard PC, dan itu adalah jangkar untuk hampir setiap hotkey di Omarchy.

Refleks Spotlight atau Raycast atau menu Start Anda menjadi `Super + Space`. Itu membuka menu Omarchy, yang meluncurkan aplikasi, mengubah pengaturan, menginstal perangkat lunak, menangkap layar — hampir segalanya. Mulai mengetik untuk memfilter. `Super + Alt + Space` menampilkan setiap aplikasi dalam satu kisi, seperti yang dilakukan Launchpad. Lihat [navigasi](04-navigation.md).

### Tidak ada dock dan tidak ada ikon desktop

Tidak ada yang bisa diklik untuk meluncurkan sesuatu, tidak ada ikon untuk diatur di desktop. Aplikasi dimulai dari hotkey (`Super + Return` untuk terminal, `Super + Shift + Return` untuk browser, dan `Super + K` untuk daftar semua yang dipetakan) atau dari menu. Satu-satunya bagian UI yang persisten adalah [bilah atas](05-the-top-bar.md), yang mencakup apa yang sebelumnya dilakukan oleh bilah menu, system tray, dan Notification Center untuk Anda — dan hampir setiap widget di dalamnya melakukan sesuatu saat diklik kiri, kanan, dan tengah.

### Jendela menempatkan dirinya sendiri

Pergeseran pola pikir terbesar: Anda tidak menyeret jendela ke sana kemari atau menempelkannya ke separuh layar. Buka satu jendela dan jendela itu memenuhi seluruh layar. Buka yang kedua dan mereka membaginya. Anda tidak pernah memancing jendela keluar dari bawah jendela lain, karena jendela tidak tumpang tindih.

Ketika Anda benar-benar membutuhkan jendela mengambang, `Super + T` mengeluarkan jendela aktif dari tiling (dan mengembalikannya). Tapi berikan tiling kesempatan yang sungguh-sungguh terlebih dahulu — itulah jantung dari segalanya. [Navigasi](04-navigation.md) memandu Anda melaluinya.

Workspace akan terasa akrab: mereka adalah Spaces di macOS atau desktop virtual di Windows, kecuali Anda akan benar-benar menggunakannya, karena `Super + 1/2/3/4` melompat langsung ke salah satunya dan `Super + Shift + 1/2/3/4` mengirim jendela aktif ke sana. Tanpa jeda animasi, hanya lompatan instan. Ini berarti Anda bahkan mungkin tidak memerlukan banyak monitor, jika Anda terbiasa dengan itu sebelumnya.

### Salin dan tempel langsung berfungsi

Di Mac Anda memiliki Cmd + C di mana-mana. Di Windows Anda memiliki Ctrl + C di mana-mana — kecuali terminal, di mana itu membunuh program Anda. Omarchy memberi Anda `Super + C`, `Super + X`, dan `Super + V`, dan mereka berfungsi di mana-mana, termasuk terminal. Tidak ada refleks terpisah untuk dipelajari untuk shell.

Pengguna Windows: riwayat clipboard Win + V Anda ada di `Super + Ctrl + V`, dan itu menyimpan gambar maupun teks. Lihat [clipboard & riwayat terpadu](08-unified-clipboard-history.md).

### Tabel terjemahan

| Yang biasa Anda cari | Di Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Start | `Super + Space` — menu Omarchy |
| AirDrop | LocalSend, melalui `Super + Ctrl + S` — lihat [GUI](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` atau `Print Screen` — lihat [tangkapan layar & perekaman](12-screenshots-recording.md) |
| Notification Center | Riwayat notifikasi di `Super + Shift + Alt + ,` |
| Time Machine (untuk sistem) | [Snapshot sistem](47-system-snapshots.md) otomatis pada setiap pembaruan |
| App Store / mengunduh installer | _Install_ di menu, atau `omarchy pkg add` — lihat [paket lain](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ di menu, yang mengedit file konfigurasi biasa — lihat [dotfiles](31-dotfiles.md) |

### Beberapa hal memang benar-benar berbeda

Banyak pengaturan berada di file teks yang Anda edit, bukan panel yang Anda klik. Itu terdengar primitif sampai Anda menyadari itu berarti setiap penyesuaian dapat dilihat, disalin ke mesin Anda berikutnya, dan dimasukkan ke version control. Menu _Setup_ menjatuhkan Anda langsung ke file yang tepat dan memulai ulang apa pun yang perlu dimulai ulang ketika Anda selesai.

Pembaruan datang melalui satu perintah — _Update > Omarchy_ — yang memperbarui Omarchy itu sendiri dan setiap paket di sistem, mengambil snapshot terlebih dahulu. Tidak ada updater per aplikasi yang mengganggu Anda secara acak. Lihat [pembaruan](30-updates.md).

Perangkat lunak berasal dari package manager, bukan dari installer yang diunduh.

Dan ketika Anda menutup jendela, aplikasi benar-benar berhenti. Tidak ada limbo macOS di mana program terus berjalan tanpa jendela. `Super + W` — atau `Super + Q`, jika itu memori jari yang Anda bawa — berarti hilang.

### Di perangkat keras Mac

Omarchy berjalan dengan baik di Mac Intel — lihat [dukungan Mac](44-mac-support.md). Dan keyboard bersikap baik kepada Anda: Omarchy tidak memetakan ulang apa pun, dan Linux memperlakukan tombol Command sebagai Super, jadi Super berada tepat di tempat Cmd selalu berada. Jempol Anda tidak akan menyadari perpindahannya.

### Berikan waktu dua minggu

Insting-insting itu berpindah lebih cepat dari yang Anda kira. Baca sekilas bab [hotkeys](07-hotkeys.md) sekali, dan kapan pun Anda lupa akan suatu binding, tekan `Super + K` — itu menunjukkan semuanya kepada Anda. Itulah satu-satunya hotkey yang benar-benar harus Anda hafalkan.
