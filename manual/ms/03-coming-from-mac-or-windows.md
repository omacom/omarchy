# Datang dari Mac atau Windows

Jika anda telah bertahun-tahun menggunakan macOS atau Windows, jari anda tahu seratus perkara yang otak anda telah lupa pernah dipelajarinya. Bab ini ialah lapisan terjemahannya: ke mana naluri itu pergi dalam Omarchy. Ciri-cirinya sendiri dibincangkan secara mendalam di tempat lain — ini cuma petanya.

### Super adalah pusat segala-galanya

Semua ingatan otot yang anda bina di sekeliling Cmd atau kekunci Windows berpindah kepada satu kekunci: Super. Itu ialah kekunci Windows pada papan kekunci PC, dan ia menjadi sauh untuk hampir setiap kekunci pintas dalam Omarchy.

Refleks Spotlight atau Raycast atau menu Start anda menjadi `Super + Space`. Itu membuka menu Omarchy, yang melancarkan aplikasi, menukar tetapan, memasang perisian, menangkap skrin — hampir segala-galanya. Mula menaip untuk menapis. `Super + Alt + Space` menunjukkan setiap aplikasi pada satu grid, seperti yang Launchpad lakukan. Lihat [navigasi](04-navigation.md).

### Tiada dock dan tiada ikon desktop

Tiada apa untuk diklik untuk melancarkan sesuatu, tiada ikon untuk disusun pada desktop. Aplikasi bermula daripada kekunci pintas (`Super + Return` untuk terminal, `Super + Shift + Return` untuk pelayar, dan `Super + K` untuk senarai semua yang dipetakan) atau daripada menu. Satu-satunya bahagian UI yang kekal ialah [bar atas](05-the-top-bar.md), yang meliputi apa yang bar menu, dulang sistem, dan Notification Center lakukan untuk anda sebelum ini — dan hampir setiap widget padanya melakukan sesuatu apabila diklik kiri, kanan, dan tengah.

### Tetingkap menempatkan dirinya sendiri

Perubahan mindset terbesar: anda tidak menyeret tetingkap ke sana sini atau melekatkannya pada separuh skrin. Buka satu tetingkap dan ia memenuhi seluruh skrin. Buka yang kedua dan mereka membahagikannya. Anda tidak pernah perlu memancing tetingkap keluar dari bawah tetingkap lain, kerana tetingkap tidak bertindih.

Apabila anda benar-benar memerlukan tetingkap terapung, `Super + T` menogol tetingkap aktif keluar daripada susunan jubin (dan kembali). Tetapi beri peluang sebenar kepada susunan jubin terlebih dahulu — itulah nadi keseluruhan perkara ini. [Navigasi](04-navigation.md) membimbing anda melaluinya.

Ruang kerja akan terasa biasa: ia seperti Spaces pada macOS atau desktop maya Windows, cuma anda benar-benar akan menggunakannya, kerana `Super + 1/2/3/4` melompat terus ke satu ruang kerja dan `Super + Shift + 1/2/3/4` menghantar tetingkap aktif ke sana. Tiada kelewatan animasi, hanya lompatan serta-merta. Ini bermakna anda mungkin tidak memerlukan berbilang monitor pun, jika anda biasa dengannya sebelum ini.

### Salin dan tampal terus berfungsi

Pada Mac anda ada Cmd + C di mana-mana. Pada Windows anda ada Ctrl + C di mana-mana — kecuali terminal, di mana ia membunuh program anda. Omarchy memberi anda `Super + C`, `Super + X`, dan `Super + V`, dan semuanya berfungsi di mana-mana, termasuk terminal. Tiada refleks berasingan untuk dipelajari bagi shell.

Untuk pengguna Windows: sejarah papan keratan Win + V anda berada pada `Super + Ctrl + V`, dan ia menyimpan imej serta teks. Lihat [papan keratan & sejarah bersepadu](08-unified-clipboard-history.md).

### Jadual terjemahan

| Anda cari | Dalam Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Start | `Super + Space` — menu Omarchy |
| AirDrop | LocalSend, melalui `Super + Ctrl + S` — lihat [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` atau `Print Screen` — lihat [tangkapan skrin & rakaman](12-screenshots-recording.md) |
| Notification Center | Sejarah pemberitahuan pada `Super + Shift + Alt + ,` |
| Time Machine (untuk sistem) | [Snapshot sistem](47-system-snapshots.md) automatik pada setiap kemas kini |
| App Store / memuat turun pemasang | _Install_ dalam menu, atau `omarchy pkg add` — lihat [pakej lain](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ dalam menu, yang menyunting fail konfigurasi biasa — lihat [dotfiles](31-dotfiles.md) |

### Sesetengah perkara memang berbeza

Banyak tetapan berada dalam fail teks yang anda sunting, bukan panel yang anda klik. Itu kedengaran primitif sehingga anda sedar ia bermakna setiap ubah suai boleh dilihat, disalin ke mesin anda yang seterusnya, dan diletakkan dalam kawalan versi. Menu _Setup_ menghantar anda terus ke fail yang betul dan memulakan semula apa sahaja yang perlu dimulakan semula apabila anda selesai.

Kemas kini datang melalui satu arahan — _Update > Omarchy_ — yang mengemas kini Omarchy itu sendiri dan setiap pakej pada sistem, dengan mengambil snapshot terlebih dahulu. Tiada pengemas kini bagi setiap aplikasi yang mengganggu anda secara rawak. Lihat [kemas kini](30-updates.md).

Perisian datang daripada pengurus pakej, bukan daripada pemasang yang dimuat turun.

Dan apabila anda menutup tetingkap, aplikasi itu benar-benar berhenti. Tiada limbo macOS di mana program terus berjalan tanpa tetingkap. `Super + W` — atau `Super + Q`, jika itulah ingatan jari yang anda bawa — bermakna hilang.

### Pada perkakasan Mac

Omarchy berjalan dengan baik pada Mac Intel — lihat [sokongan Mac](44-mac-support.md). Dan papan kekunci berbaik hati dengan anda: Omarchy tidak memetakan semula apa-apa, dan Linux melayan kekunci Command sebagai Super, jadi Super berada tepat di tempat Cmd selalu berada. Ibu jari anda tidak akan perasan perpindahan itu.

### Beri masa dua minggu

Naluri itu berpindah lebih pantas daripada yang anda sangka. Baca sepintas lalu bab [kekunci pintas](07-hotkeys.md) sekali, dan setiap kali anda terlupa sesuatu ikatan, tekan `Super + K` — ia menunjukkan semuanya kepada anda. Itulah satu-satunya kekunci pintas yang benar-benar perlu anda hafal.
