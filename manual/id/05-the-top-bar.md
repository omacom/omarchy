# Bilah Atas

Jalur di sepanjang bagian atas layar Anda adalah bilah Omarchy. Bilah ini bukan bilah status yang ditempel begitu saja, melainkan bagian dari shell Omarchy, proses Quickshell tunggal yang berjalan lama yang juga menggambar menu, notifikasi, popup OSD, dan layar kunci. Itulah sebabnya temanya menyatu sempurna dengan semua hal lain dan mengapa panel terbuka seketika alih-alih memunculkan aplikasi baru.

Bilah ini juga satu-satunya bagian dari desktop yang selalu tampil di layar, jadi ada baiknya Anda tahu fungsi semua glif kecil itu.

## Apa saja yang ada di dalamnya secara default

Bilah ini memiliki tiga bagian. Di sebelah kiri terdapat logo Omarchy (peluncur menu) dan indikator workspace. Di tengah Anda mendapatkan indikator status, jam, Elsewhen (jam dunia), cuaca, dan lencana pembaruan Omarchy. Di sebelah kanan: system tray, tata letak keyboard (bila lebih dari satu yang dikonfigurasi), agents, bluetooth, network, audio, display, dan power.

Beberapa di antaranya hanya muncul bila mereka memiliki sesuatu untuk disampaikan. Tata letak keyboard hanya muncul jika Anda telah mengonfigurasi lebih dari satu tata letak. Lencana pembaruan hanya muncul bila ada pembaruan Omarchy yang menunggu. Dan ikon agents muncul pertama kali Omarchy menemukan penggunaan AI coding di mesin tersebut (lihat [AI](17-ai.md)).

## Mengklik di sana-sini

Hampir setiap widget melakukan sesuatu saat diklik kiri, kanan, dan tengah, dan beberapa merespons pengguliran. Inilah bagian yang sering terlewatkan orang — tombol kanan dan tengah adalah tempat banyak hal bagus tersembunyi.

| Widget | Kiri | Kanan | Tengah / gulir |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Terminal baru | — |
| Workspaces | Fokuskan workspace tersebut di monitor ini | — | Gulir: workspace berikutnya/sebelumnya |
| Clock | Popup kalender | Putar format label | Tengah: pemilih zona waktu |
| Weather | Popup prakiraan cuaca | Cuaca lengkap sebagai notifikasi | Tengah: segarkan |
| Audio | Panel audio | Bisukan | Tengah: panel · gulir: volume |
| Microphone | Bisukan mikrofon | — | Tengah: panel audio · gulir: volume input |
| Network | Panel network | — | — |
| Bluetooth | Panel Bluetooth | Aktif/nonaktifkan radio | — |
| Display | Panel display | — | Gulir: kecerahan |
| Power | Panel power | Aktif/nonaktifkan persentase baterai | — |
| Media | Putar/jeda | Popup sampul album | Tengah: berikutnya · gulir: sebelumnya/berikutnya |
| Agents | Panel Agents | Luncurkan agent Anda | Tengah: langganan berikutnya |
| Tray | Arahkan kursor untuk membuka laci | Klik kanan pada chevron untuk mengelola | — |
| Omarchy update | Jalankan pembaruan | — | — |

Tidak semua yang ada di tabel itu ada di bilah Anda sejak awal. Widget media (MPRIS now-playing, dengan trek dan artis yang bergulir) dan widget mikrofon keduanya sudah terpasang tetapi nonaktif secara default — tambahkan jika Anda menginginkannya, seperti dijelaskan di bawah ini.

## Panel-panelnya

Mengklik ikon bilah akan membuka panel, yaitu popup yang sesungguhnya dengan slider, daftar, dan navigasi keyboard, bukan tooltip. Masing-masing juga memiliki hotkey, jadi Anda tidak perlu membidik glif berukuran 16 piksel:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + 1-9` | Aktif/nonaktifkan panel ke-n di bagian kanan |

Panel-panel itu bukan sekadar tampilan informasi. Di situlah Anda benar-benar melakukan sesuatu:

- **Audio** memiliki slider volume utama, pemilih perangkat output, dan mixer per aplikasi, jadi Anda dapat mengecilkan satu tab browser itu tanpa menyentuh yang lainnya.
- **Network** memindai Wi-Fi, menunjukkan kekuatan sinyal, menghubungkan, dan memungkinkan Anda memilih penyedia DNS.
- **Bluetooth** mencantumkan perangkat Anda dengan sambungkan/putuskan dan tingkat baterai.
- **Power** menunjukkan statistik baterai, mengganti profil daya (ia mengingat pilihan terpisah untuk baterai dan AC), dan mencetak beberapa info sistem.
- **Display** menyediakan slider kecerahan, ukuran teks, preset penskalaan monitor, dan — bila Anda memiliki lebih dari satu layar — kontrol per monitor. Lihat [monitors](33-monitors.md) untuk cerita yang lebih mendalam.
- **Clock** membuka kisi bulan dengan nomor minggu ISO dan perpindahan bulan.
- **World clock** menyimpan satu baris per kota, dengan cuacanya dan bagaimana harinya berjalan. Pencarian menemukan kota kecil maupun zona waktu, jadi Fort Lauderdale adalah Fort Lauderdale dan bukan New York. Jika baris di bagian atas menyebutkan kota yang salah, klik baris itu dan katakan di mana Anda berada; pilih tempat di zona waktu lain dan jam sistem juga ikut berpindah ke sana, yang berguna saat Anda bepergian. Arahkan kursor ke sebuah kota dan klik tombol orang untuk mengatakan siapa yang tinggal di sana — nama biasa, atau handle GitHub `@` untuk membawa serta wajah mereka.

Setiap panel menerima keyboard maupun mouse: panah untuk bergerak, Return untuk mengaktifkan, Tab untuk melangkah ke panel di sebelahnya, dan Escape untuk menutup.

`Super + Ctrl + 1-9` menghitung panel dari kiri ke kanan di bagian kanan, melewatkan tray karena tray tidak memiliki panelnya sendiri. Jadi angkanya sesuai dengan ikon yang akan Anda tuju.

### Tailscale dan Dropbox

Dua widget lagi muncul di bilah hanya setelah Anda memasang layanan yang sesuai dari **Install → Service**, dan keduanya patut diketahui karena fungsinya lebih dari sekadar melaporkan status.

Panel **Tailscale** menghubungkan dan memutuskan tailnet, beralih antar akun, dan memilih exit node (mesin Anda sendiri dan wilayah Mullvad sama-sama muncul dalam daftar itu). Panel ini juga menelusuri mesin Anda — dan dengan satu mesin terpilih, `s` mengirim file ke mesin itu melalui Taildrop, yang merupakan cara tercepat untuk memindahkan file ke ponsel atau laptop lain Anda. `c` menyalin IP mesin tersebut, `n` namanya, dan `d` nama DNS lengkapnya. Ada juga tombol kirim di setiap baris mesin, jika Anda lebih suka mengklik. Hal yang sama dari terminal adalah `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** menangani login, menunjukkan berapa banyak penyimpanan yang telah Anda gunakan, dan mencantumkan file yang baru-baru ini disinkronkan.

Menghapus salah satu layanan akan menghilangkan widgetnya dari bilah.

## Indikator

Kelompok kecil di tengah adalah widget indikator. Ini adalah glif status untuk mode yang telah Anda aktifkan: do not disturb, night light, [pengingat](09-reminders.md) yang mengantre, perekaman layar yang aktif, stay awake, dan [dikte](11-text-extraction-dictation.md). Mereka menyala saat modenya aktif dan selain itu tidak mengganggu — arahkan kursor ke mana saja di bilah untuk mengintip yang tidak aktif. Mengklik indikator akan mengaktifkan/menonaktifkan mode tersebut. Satu lagi hanya berstatus saja: sesi jarak jauh menyala merah saat seseorang terhubung ke mesin ini melalui gliff.

Jika Anda lebih suka mereka selalu terlihat, atur `alwaysShow` ke `true` pada widget tersebut. Dan jika Anda hanya peduli pada beberapa di antaranya, cantumkan yang Anda inginkan di `items`: `["Dnd", "Reminder", "NightLight"]`. Anda dapat memiliki lebih dari satu widget indikator, jadi bagian yang berbeda dapat menampilkan subset yang berbeda.

## Menyusun ulang bilah

Bilah ini mengonfigurasi dirinya sendiri. Anda tidak harus membuka file konfigurasi untuk memindahkan sesuatu.

Ambil bagian kosong dari bilah di sekitar tengah dan seret ke arah tepi layar lain, dan bilah akan berpindah ke sana — kiri, kanan, atas, atau bawah semuanya bisa, dan setiap widget menyesuaikan diri (bilah vertikal beralih ke bentuk ringkas hanya-ikon). Klik-dan-tahan memulai seretan yang sama. Klik kiri dua kali pada ruang kosong yang sama itu untuk memutar latar belakang bilah dari bening ke seperti kaca ke buram. Dan seret widget apa pun untuk menyusun ulangnya atau melemparkannya ke bagian lain; widget lainnya akan bergeser untuk memberi ruang di tempat ia akan mendarat.

Bagian tengah bilah adalah sebuah kotak: apa pun yang ada di dalamnya tetap berada di tengah sebagai satu kelompok, dan widget di kedua sisinya menggantung dari tepinya. Saat Anda menyeret sebuah widget, kotak tersebut tampil sebagai garis luar, atau garis melintasi bilah saat kosong, dan Anda dapat menjatuhkannya ke dalamnya atau di sampingnya. Saat pelepasan akan mendarat di dalam kotak, kotak itu membesar untuk menerima widget tersebut.

Widget yang Anda inginkan ada di sekitar tetapi tidak selalu terlihat dapat masuk ke laci tray: seret widget itu ke tray, dan laci akan terbuka untuk menerimanya. Widget itu berada di sana setelah ikon aplikasi, muncul kapan pun laci muncul, dan membuat lacinya tetap terbuka saat panelnya tampil. Seret kembali ke bilah untuk mengembalikannya.

Jika Anda lebih suka memilih dari menu, **Appearance → Menu Bar** memiliki posisinya, dan **Bar Background** memilih bagaimana bilah digambar: **Opaque Bar**, **Glassy Bar** (tembus pandang, dengan yang ada di belakangnya diburamkan), atau **Clear Bar**.

Hal yang sama memiliki perintah, yang merupakan yang Anda inginkan untuk pengaturan [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Untuk menambah atau menghapus widget sepenuhnya, gunakan perintah plugin. `omarchy plugin list` mencetak setiap widget yang diketahui shell beserta id-nya, lalu:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Menyembunyikan bilah

`Super + Shift + Space` mengaktifkan/menonaktifkan bilah tanpa mematikan shell — panel dan hotkey tetap berfungsi, Anda hanya mendapatkan kembali pikselnya. Ini juga ada di menu di bawah **Appearance → Menu Bar → Hide Bar**.

## File konfigurasinya

Semuanya disimpan di `~/.config/omarchy/shell.json`, di bawah kunci `bar`. Berikut versi yang dipangkas:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Setiap widget adalah satu entri di salah satu dari lima larik layout, dan pengaturannya berada sebaris pada entri tersebut — tidak ada file pengaturan terpisah dan tidak ada sub-objek `config`. `format`, `formatAlt` (yang dirotasi oleh klik kanan), dan `verticalFormat` milik jam semuanya berada tepat di sana pada `{ "id": "omarchy.clock" }`.

`center` adalah kotak di tengah bilah: semua yang ada di dalamnya dipusatkan di layar sebagai satu kelompok. `centerBegin` dan `centerEnd` menggantung di kedua sisi kotak, yang merupakan cara jam tetap berada tepat di tengah bahkan saat cuaca dan lencana pembaruan datang dan pergi. Taruh lebih dari satu widget di `center` dan mereka akan dipusatkan bersama; biarkan kosong dan `centerBegin` dan `centerEnd` akan bertemu di tengah bilah.

Satu aturan yang patut diinternalisasi: **setelah Anda memiliki `shell.json` sendiri, file itu yang berlaku**. Sampai Anda menyesuaikan apa pun, shell membaca file default Omarchy. Begitu Anda menyeret widget, menjalankan `omarchy bar`, atau mengedit file itu sendiri, Anda yang memilikinya — tidak ada penggabungan mendalam, jadi widget default baru di rilis Omarchy mendatang tidak akan muncul di bilah Anda secara otomatis. `omarchy bar defaults` mengembalikan layout bawaan kapan pun Anda menginginkan awal yang bersih.

File yang sama juga menyimpan pengaturan waktu idle Anda di tingkat atas, di luar kunci `bar`: `idle.screensaver` dan `idle.lock`, keduanya dalam detik sejak Anda idle. Jadi screensaver default aktif pada 150 detik dan kunci pada 300.
