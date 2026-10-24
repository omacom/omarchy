# Berasal Dari Mac atau Windows

Jika Anda telah menghabiskan bertahun-tahun di macOS atau Windows, jari-jari Anda tahu ratusan hal yang telah dilupakan otak Anda pernah pelajari. Bab ini adalah lapisan penerjemahannya: ke mana insting-insting itu pergi di Omarchy. Fitur-fiturnya sendiri dibahas secara mendalam di tempat lain — ini hanyalah petanya.

### Super adalah pusat dari segalanya

Semua memori otot yang telah Anda bangun di sekitar Cmd atau tombol Windows beralih ke satu tombol: Super. Itu adalah tombol Windows pada keyboard PC, dan itu adalah jangkar untuk hampir setiap hotkey di Omarchy.

Refleks Spotlight atau Raycast atau menu Start Anda menjadi `Super + Space`. Itu membuka menu Omarchy, yang meluncurkan aplikasi, mengubah pengaturan, memasang perangkat lunak, menangkap layar — hampir semuanya. Mulai mengetik untuk menyaring. `Super + Alt + Space` menunjukkan setiap aplikasi dalam satu kisi, seperti yang dilakukan Launchpad. Lihat [navigasi](04-navigation.md).

### Tidak ada dock dan tidak ada ikon desktop

Tidak ada yang bisa diklik untuk meluncurkan sesuatu, tidak ada ikon untuk diatur di desktop. Aplikasi dimulai dari hotkey (`Super + Return` untuk terminal, `Super + Shift + Return` untuk browser, dan `Super + K` untuk daftar semua yang dipetakan) atau dari menu. Satu-satunya bagian UI yang persisten adalah [bilah atas](05-the-top-bar.md), yang mencakup apa yang dilakukan bilah menu, baki sistem, dan Pusat Notifikasi untuk Anda sebelumnya — dan hampir setiap widget di atasnya melakukan sesuatu pada klik kiri, kanan, dan tengah.

### Jendela menempatkan diri sendiri

Pergeseran pola pikir terbesar: Anda tidak menyeret jendela ke sana kemari atau menempelkannya ke separuh layar. Buka sebuah jendela dan ia mengambil seluruh layar. Buka yang kedua dan keduanya membaginya. Anda tidak pernah memancing jendela dari bawah jendela lain, karena jendela tidak tumpang tindih.

Ketika Anda benar-benar membutuhkan jendela melayang, `Super + T` mengalihkan jendela aktif keluar dari tiling (dan kembali). Namun berikan tiling kesempatan yang nyata terlebih dahulu — itulah inti dari keseluruhan ini. [Navigasi](04-navigation.md) memandu Anda melaluinya.

Ruang kerja akan terasa familier: mereka adalah macOS Spaces atau desktop virtual Windows, kecuali Anda benar-benar akan menggunakannya, karena `Super + 1/2/3/4` langsung melompat ke salah satunya dan `Super + Shift + 1/2/3/4` mengirim jendela aktif ke sana. Tanpa jeda animasi, hanya lompatan instan. Ini berarti Anda bahkan mungkin tidak memerlukan banyak monitor, jika Anda terbiasa dengan itu sebelumnya.

### Salin dan tempel langsung berfungsi

Di Mac Anda memiliki Cmd + C di mana-mana. Di Windows Anda memiliki Ctrl + C di mana-mana — kecuali terminal, di mana itu mematikan program Anda. Omarchy memberi Anda `Super + C`, `Super + X`, dan `Super + V`, dan ketiganya berfungsi di mana-mana, termasuk terminal. Tidak ada refleks terpisah yang perlu dipelajari untuk shell.

Teman-teman Windows: riwayat papan klip Win + V Anda ada di `Super + Ctrl + V`, dan ia menampung gambar maupun teks. Lihat [papan klip & riwayat terpadu](08-unified-clipboard-history.md).

### Tabel penerjemahan

| Yang Anda cari | Di Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Start | `Super + Space` — menu Omarchy |
| AirDrop | LocalSend, via `Super + Ctrl + S` — lihat [GUI](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — lihat [tangkapan layar & perekaman](12-screenshots-recording.md) |
| Pusat Notifikasi | Riwayat notifikasi di `Super + Shift + Alt + ,` |
| Time Machine (untuk sistem) | [Snapshot sistem](47-system-snapshots.md) otomatis pada setiap pembaruan |
| App Store / mengunduh pemasang | _Pasang_ di menu, atau `omarchy pkg add` — lihat [paket lain](29-other-packages.md) |
| Pengaturan Sistem / Control Panel | _Pengaturan_ di menu, yang mengedit berkas konfigurasi biasa — lihat [dotfiles](31-dotfiles.md) |

### Beberapa hal memang benar-benar berbeda

Banyak pengaturan hidup dalam berkas teks yang Anda edit, bukan panel yang Anda klik. Itu terdengar primitif sampai Anda menyadari itu berarti setiap penyesuaian dapat dilihat, disalin ke mesin Anda berikutnya, dan dimasukkan ke kontrol versi. Menu _Pengaturan_ langsung membawa Anda ke berkas yang tepat dan memulai ulang apa pun yang perlu dimulai ulang ketika Anda selesai.

Pembaruan datang melalui satu perintah — _Perbarui > Omarchy_ — yang memperbarui Omarchy itu sendiri dan setiap paket pada sistem, dengan mengambil snapshot terlebih dahulu. Tidak ada pembaru per aplikasi yang mengganggu Anda secara acak. Lihat [pembaruan](30-updates.md).

Perangkat lunak berasal dari manajer paket, bukan dari pemasang yang diunduh.

Dan ketika Anda menutup sebuah jendela, aplikasi benar-benar keluar. Tidak ada limbo macOS di mana program terus berjalan tanpa jendela. `Super + W` — atau `Super + Q`, jika itu adalah memori jari yang Anda bawa — berarti hilang.

### Di perangkat keras Mac

Omarchy berjalan dengan baik di Intel Mac — lihat [dukungan Mac](44-mac-support.md). Dan keyboardnya ramah terhadap Anda: Omarchy tidak memetakan ulang apa pun, dan Linux memperlakukan tombol Command sebagai Super, sehingga Super berada tepat di tempat Cmd selalu berada. Ibu jari Anda tidak akan menyadari perpindahan itu.

### Beri waktu dua minggu

Insting-insting itu beralih lebih cepat dari yang Anda kira. Baca sekilas bab [hotkey](07-hotkeys.md) sekali, dan setiap kali Anda lupa sebuah binding, tekan `Super + K` — itu menunjukkan semuanya. Itulah satu-satunya hotkey yang benar-benar harus Anda hafalkan.
