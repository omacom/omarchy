# Beralih dari Mac atau Windows

Jika anda telah bertahun-tahun menggunakan macOS atau Windows, jari anda tahu seratus perkara yang otak anda telah lupa pernah dipelajari. Bab ini ialah lapisan terjemahannya: ke mana naluri tersebut pergi dalam Omarchy. Ciri-cirinya sendiri dibincangkan secara mendalam di tempat lain — ini hanyalah petanya.

### Super ialah pusat segala-galanya

Semua ingatan otot yang telah anda bina di sekeliling Cmd atau kekunci Windows beralih kepada satu kekunci: Super. Itulah kekunci Windows pada papan kekunci PC, dan ia ialah tunjang bagi hampir setiap kekunci panas dalam Omarchy.

Refleks Spotlight atau Raycast atau menu Start anda menjadi `Super + Space`. Itu membuka menu Omarchy, yang melancarkan aplikasi, menukar tetapan, memasang perisian, menangkap skrin — hampir segala-galanya. Mula menaip untuk menapis. `Super + Alt + Space` memaparkan setiap aplikasi pada satu grid, seperti yang dilakukan oleh Launchpad. Lihat [navigasi](04-navigation.md).

### Tiada dok dan tiada ikon desktop

Tiada apa-apa untuk diklik bagi melancarkan sesuatu, tiada ikon untuk disusun pada desktop. Aplikasi bermula daripada kekunci panas (`Super + Return` untuk terminal, `Super + Shift + Return` untuk pelayar, dan `Super + K` untuk senarai semua yang dipetakan) atau daripada menu. Satu-satunya bahagian UI yang kekal ialah [bar atas](05-the-top-bar.md), yang meliputi apa yang dilakukan oleh bar menu, dulang sistem, dan Pusat Pemberitahuan untuk anda sebelum ini — dan hampir setiap widget padanya melakukan sesuatu pada klik kiri, kanan, dan tengah.

### Tetingkap meletakkan dirinya sendiri

Peralihan minda yang paling besar: anda tidak menyeret tetingkap ke sana sini atau melekatkannya pada separuh skrin. Buka tetingkap dan ia mengambil keseluruhan skrin. Buka yang kedua dan kedua-duanya membahaginya. Anda tidak pernah perlu mengeluarkan tetingkap dari bawah tetingkap lain, kerana tetingkap tidak bertindih.

Apabila anda benar-benar memerlukan tetingkap terapung, `Super + T` menogol tetingkap aktif keluar daripada jubinan (dan kembali). Tetapi beri jubinan peluang yang sebenar terlebih dahulu — ia ialah nadi keseluruhan perkara ini. [Navigasi](04-navigation.md) membimbing anda melaluinya.

Ruang kerja akan terasa biasa: ia ialah Spaces macOS atau desktop maya Windows, kecuali anda benar-benar akan menggunakannya, kerana `Super + 1/2/3/4` melompat terus kepada satu dan `Super + Shift + 1/2/3/4` menghantar tetingkap aktif ke sana. Tiada kelewatan animasi, hanya lompatan serta-merta. Ini bermakna anda mungkin tidak memerlukan berbilang monitor pun, jika anda sudah biasa dengannya sebelum ini.

### Salin dan tampal berfungsi sahaja

Pada Mac anda mempunyai Cmd + C di mana-mana. Pada Windows anda mempunyai Ctrl + C di mana-mana — kecuali terminal, di mana ia membunuh program anda. Omarchy memberi anda `Super + C`, `Super + X`, dan `Super + V`, dan ia berfungsi di mana-mana, termasuk terminal. Tiada refleks berasingan untuk dipelajari bagi shell.

Kawan-kawan Windows: sejarah papan keratan Win + V anda berada pada `Super + Ctrl + V`, dan ia menyimpan imej serta teks. Lihat [papan keratan bersepadu & sejarah](08-unified-clipboard-history.md).

### Jadual terjemahan

| Anda mencapai | Dalam Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Start | `Super + Space` — menu Omarchy |
| AirDrop | LocalSend, melalui `Super + Ctrl + S` — lihat [GUI](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — lihat [tangkap skrin & rakaman](12-screenshots-recording.md) |
| Pusat Pemberitahuan | Sejarah pemberitahuan pada `Super + Shift + Alt + ,` |
| Time Machine (untuk sistem) | [Syot kilat sistem](47-system-snapshots.md) automatik pada setiap kemas kini |
| App Store / memuat turun pemasang | _Pasang_ dalam menu, atau `omarchy pkg add` — lihat [pakej lain](29-other-packages.md) |
| Tetapan Sistem / Panel Kawalan | _Persediaan_ dalam menu, yang menyunting fail konfigurasi biasa — lihat [dotfiles](31-dotfiles.md) |

### Sesetengah perkara memang berbeza

Banyak tetapan berada dalam fail teks yang anda sunting, bukan panel yang anda klik. Itu kedengaran primitif sehingga anda menyedari ia bermakna setiap pengubahsuaian boleh dilihat, disalin ke mesin anda yang seterusnya, dan diletakkan dalam kawalan versi. Menu _Persediaan_ membawa anda terus ke fail yang betul dan memulakan semula apa sahaja yang perlu dimulakan semula apabila anda selesai.

Kemas kini datang melalui satu arahan — _Kemas Kini > Omarchy_ — yang mengemas kini Omarchy itu sendiri dan setiap pakej pada sistem, dengan mengambil syot kilat terlebih dahulu. Tiada pengemas kini bagi setiap aplikasi yang mengganggu anda secara rawak. Lihat [kemas kini](30-updates.md).

Perisian datang daripada pengurus pakej, bukan daripada pemasang yang dimuat turun.

Dan apabila anda menutup tetingkap, aplikasi benar-benar berhenti. Tiada limbo macOS di mana program terus berjalan tanpa tetingkap. `Super + W` — atau `Super + Q`, jika itu ingatan jari yang anda bawa — bermakna hilang.

### Pada perkakasan Mac

Omarchy berjalan dengan baik pada Mac Intel — lihat [sokongan Mac](44-mac-support.md). Dan papan kekunci mesra dengan anda: Omarchy tidak memetakan semula apa-apa, dan Linux menganggap kekunci Command sebagai Super, jadi Super berada tepat di tempat Cmd selalu berada. Ibu jari anda tidak akan menyedari peralihan tersebut.

### Berikannya dua minggu

Naluri tersebut beralih lebih pantas daripada yang anda sangka. Selak bab [kekunci panas](07-hotkeys.md) sekali, dan apabila anda terlupa ikatan, tekan `Super + K` — ia memaparkan kesemuanya kepada anda. Itulah satu-satunya kekunci panas yang benar-benar perlu anda hafal.
