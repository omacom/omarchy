# Beralih dari Mac atau Windows

Jika anda telah bertahun-tahun menggunakan macOS atau Windows, jari anda tahu seratus perkara yang otak anda sudah lupa pernah dipelajarinya. Bab ini ialah lapisan terjemahannya: ke mana naluri itu pergi dalam Omarchy. Ciri-cirinya sendiri dibincangkan secara mendalam di tempat lain — ini cuma petanya.

### Super ialah pusat segala-galanya

Semua ingatan otot yang anda bina di sekitar Cmd atau kekunci Windows berpindah kepada satu kekunci: Super. Itulah kekunci Windows pada papan kekunci PC, dan ia menjadi sauh bagi hampir setiap kekunci pintas dalam Omarchy.

Refleks Spotlight atau Raycast atau menu Start anda menjadi `Super + Space`. Itu membuka menu Omarchy, yang melancarkan aplikasi, menukar tetapan, memasang perisian, menangkap skrin — hampir segala-galanya. Mula menaip untuk menapis. `Super + Alt + Space` menunjukkan setiap aplikasi pada satu grid, seperti yang dilakukan Launchpad. Lihat [navigasi](04-navigation.md).

### Tiada ikon desktop, dan dok hanya muncul apabila anda terapung

Tiada ikon untuk disusun di desktop, dan tiada dok pada ruang kerja berjubin — dok hanya muncul pada ruang kerja terapung (lihat [navigasi](04-navigation.md)). Aplikasi bermula daripada kekunci pintas (`Super + Return` untuk terminal, `Super + Shift + Return` untuk pelayar, dan `Super + K` untuk senarai segala yang dipetakan) atau daripada menu. Satu-satunya bahagian UI yang kekal ialah [bar atas](05-the-top-bar.md), yang merangkumi apa yang dahulu dilakukan oleh bar menu, dulang sistem, dan Notification Center untuk anda — dan hampir setiap widget padanya melakukan sesuatu apabila diklik kiri, kanan, dan tengah.

### Tetingkap meletakkan dirinya sendiri

Perubahan cara fikir yang paling besar: anda tidak menyeret tetingkap ke sana sini atau melekatkannya pada separuh skrin. Buka satu tetingkap dan ia memenuhi seluruh skrin. Buka tetingkap kedua dan kedua-duanya membelah skrin itu. Anda tidak perlu mencari tetingkap dari bawah tetingkap lain, kerana tetingkap tidak bertindih.

Apabila anda benar-benar memerlukan tetingkap terapung, `Super + T` menogol tetingkap aktif keluar daripada susunan berjubin (dan kembali semula). Tetapi beri susunan berjubin peluang yang sebenar dahulu — itulah nadi kepada segala-galanya. [Navigasi](04-navigation.md) akan memandu anda melaluinya.

Ruang kerja akan terasa biasa: ia seperti macOS Spaces atau desktop maya Windows, cuma anda benar-benar akan menggunakannya, kerana `Super + 1/2/3/4` melompat terus ke satu ruang kerja dan `Super + Shift + 1/2/3/4` menghantar tetingkap aktif ke sana. Tiada kelewatan animasi, hanya lompatan serta-merta. Ini bermakna anda mungkin tidak memerlukan berbilang monitor pun, jika anda sudah biasa begitu sebelum ini.

### Salin dan tampal memang berfungsi

Pada Mac anda menggunakan Cmd + C di mana-mana. Pada Windows anda menggunakan Ctrl + C di mana-mana — kecuali terminal, di mana ia membunuh program anda. Omarchy memberi anda `Super + C`, `Super + X`, dan `Super + V`, dan semuanya berfungsi di mana-mana, termasuk terminal. Tiada refleks berasingan untuk dipelajari bagi shell.

Pengguna Windows: sejarah papan klip Win + V anda berada pada `Super + Ctrl + V`, dan ia menyimpan imej serta teks. Lihat [papan klip & sejarah bersepadu](08-unified-clipboard-history.md).

### Jadual terjemahan

| Yang biasa anda gunakan | Dalam Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — menu Omarchy |
| AirDrop | LocalSend, melalui `Super + Ctrl + S` — lihat [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` atau `Print Screen` — lihat [tangkapan skrin & rakaman](12-screenshots-recording.md) |
| Notification Center | Sejarah pemberitahuan pada `Super + Shift + Alt + ,` |
| Time Machine (untuk sistem) | [syot kilat sistem](47-system-snapshots.md) automatik pada setiap kemas kini |
| App Store / memuat turun pemasang | _Install_ dalam menu, atau `omarchy pkg add` — lihat [pakej lain](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ dalam menu, yang menyunting fail konfigurasi biasa — lihat [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, pada `Super + Shift + F` — lihat [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome pada `Super + Shift + Return`; pilih yang lain di bawah _Setup > Defaults > Browser_ — lihat [pelayar](23-browsers.md) |
| Preview / Photos | Omaview untuk gambar, video dan muzik, Document Viewer untuk PDF — lihat [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, pada `Super + Shift + N`; pilih yang lain di bawah _Setup > Defaults > Editor_ |

### Sesetengah perkara memang berbeza

Banyak tetapan berada dalam fail teks yang anda sunting, bukan panel yang anda klik satu demi satu. Kedengarannya primitif sehinggalah anda sedar ia bermakna setiap ubah suai boleh dilihat, disalin ke mesin anda yang seterusnya, dan dimasukkan ke dalam kawalan versi. Menu _Setup_ membawa anda terus ke fail yang betul dan memulakan semula apa sahaja yang perlu dimulakan semula apabila anda selesai.

Kemas kini datang melalui satu arahan — _Update > Omarchy_ — yang mengemas kini Omarchy itu sendiri dan setiap pakej pada sistem, dengan mengambil syot kilat terlebih dahulu. Tiada pengemas kini bagi setiap aplikasi yang mengganggu anda pada masa rawak. Lihat [kemas kini](30-updates.md).

Perisian datang daripada pengurus pakej, bukan daripada pemasang yang dimuat turun.

Dan apabila anda menutup tetingkap, aplikasi itu benar-benar berhenti. Tiada keadaan tergantung ala macOS di mana program terus berjalan tanpa tetingkap. `Super + W` — atau `Super + Q`, jika itulah ingatan jari yang anda bawa — bermakna hilang terus.

### Pada perkakasan Mac

Omarchy berjalan dengan baik pada Mac Intel — lihat [sokongan Mac](44-mac-support.md). Dan papan kekuncinya mesra dengan anda: Omarchy tidak memetakan semula apa-apa, dan Linux menganggap kekunci Command sebagai Super, jadi Super berada tepat di tempat Cmd sentiasa berada. Ibu jari anda tidak akan perasan peralihan itu.

### Beri masa dua minggu

Naluri itu berpindah lebih pantas daripada yang anda sangka. Imbas bab [kekunci pintas](07-hotkeys.md) sekali, dan setiap kali anda terlupa sesuatu ikatan kekunci, tekan `Super + K` — ia menunjukkan kesemuanya kepada anda. Itulah satu-satunya kekunci pintas yang benar-benar perlu anda hafal.
