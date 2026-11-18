# Bar Atas

Jalur di sepanjang bagian atas layar Anda adalah bar Omarchy. Ini bukan status bar yang ditempel seadanya, melainkan bagian dari shell Omarchy, satu proses Quickshell yang berjalan lama dan juga menggambar menu, notifikasi, popup OSD, dan layar kunci. Itulah sebabnya temanya selaras sempurna dengan semua hal lain dan mengapa panel terbuka seketika alih-alih memunculkan aplikasi baru.

Ini juga satu-satunya bagian desktop yang selalu ada di layar, jadi ada baiknya Anda mengetahui fungsi semua glif kecil itu.

## Apa saja yang ada di dalamnya secara default

Bar ini memiliki tiga bagian. Di sebelah kiri ada logo Omarchy (peluncur menu) dan indikator workspace. Di tengah Anda mendapatkan indikator status, jam, Elsewhen (jam dunia), cuaca, dan lencana pembaruan Omarchy. Di sebelah kanan: system tray, layout keyboard (ketika lebih dari satu yang dikonfigurasi), agents, bluetooth, network, audio, display, dan power.

Beberapa di antaranya hanya muncul ketika mereka memiliki sesuatu untuk disampaikan. Layout keyboard hanya muncul jika Anda telah mengonfigurasi lebih dari satu layout. Lencana pembaruan hanya muncul ketika ada pembaruan Omarchy yang menunggu. Dan ikon agents muncul saat pertama kali Omarchy menemukan penggunaan AI coding di mesin tersebut (lihat [AI](17-ai.md)).

## Mengklik sana-sini

Hampir setiap widget melakukan sesuatu saat diklik kiri, kanan, dan tengah, dan beberapa merespons pengguliran. Ini bagian yang sering terlewatkan — tombol kanan dan tengah adalah tempat banyak hal bagus bersembunyi.

| Widget | Kiri | Kanan | Tengah / gulir |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Terminal baru | — |
| Workspaces | Fokuskan workspace itu di monitor ini | — | Gulir: workspace berikutnya/sebelumnya |
| Clock | Popup kalender | Ganti format label secara bergilir | Tengah: pemilih zona waktu |
| Weather | Popup prakiraan | Cuaca lengkap sebagai notifikasi | Tengah: segarkan |
| Audio | Panel audio | Bisukan | Tengah: panel · gulir: volume |
| Microphone | Bisukan mic | — | Tengah: panel audio · gulir: volume input |
| Network | Panel network | — | — |
| Bluetooth | Panel Bluetooth | Aktif/nonaktifkan radio | — |
| Display | Panel display | — | Gulir: kecerahan |
| Power | Panel power | Aktif/nonaktifkan persentase baterai | — |
| Media | Putar/jeda | Popup sampul | Tengah: berikutnya · gulir: sebelum/berikutnya |
| Agents | Panel agents | Luncurkan agent Anda | Tengah: langganan berikutnya |
| Tray | Arahkan kursor untuk menampilkan laci | Klik kanan pada chevron untuk mengelola | — |
| Pembaruan Omarchy | Jalankan pembaruan | — | — |

Tidak semua yang ada di tabel itu ada di bar Anda sejak awal. Widget media (MPRIS now-playing, dengan track dan artis yang bergulir) dan widget microphone keduanya sudah terpasang tetapi nonaktif secara default — tambahkan jika Anda menginginkannya, seperti yang dijelaskan di bawah.

## Panel-panelnya

Mengklik ikon bar membuka sebuah panel, yaitu popup yang sesungguhnya dengan slider, daftar, dan navigasi keyboard, bukan sekadar tooltip. Masing-masing juga memiliki hotkey, jadi Anda tidak perlu membidik glif berukuran 16 piksel:

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

Panel-panel itu bukan sekadar laporan. Di sanalah Anda benar-benar melakukan halnya:

- **Audio** memiliki slider volume utama, pemilih perangkat output, dan mixer per aplikasi, jadi Anda dapat mengecilkan satu tab browser itu tanpa menyentuh semua hal lainnya.
- **Network** memindai Wi-Fi, menunjukkan kekuatan sinyal, menghubungkan, dan memungkinkan Anda memilih penyedia DNS.
- **Bluetooth** mencantumkan perangkat Anda dengan sambung/putuskan dan tingkat baterai.
- **Power** menunjukkan statistik baterai, mengganti profil daya (ia mengingat pilihan terpisah untuk baterai dan AC), dan mencetak beberapa info sistem.
- **Display** membawa slider kecerahan, ukuran teks, preset penskalaan monitor, dan — ketika Anda memiliki lebih dari satu layar — kontrol per monitor. Lihat [monitor](33-monitors.md) untuk cerita yang lebih mendalam.
- **Clock** membuka kisi bulan dengan nomor minggu ISO dan perpindahan bulan.
- **World clock** menyimpan satu baris per kota, dengan cuacanya dan bagaimana harinya berjalan. Pencarian menemukan kota kecil maupun zona waktu, jadi Fort Lauderdale adalah Fort Lauderdale dan bukan New York. Jika baris di bagian atas menyebutkan kota yang salah, klik baris itu dan katakan di mana Anda berada; pilih tempat di zona waktu lain dan jam sistem juga ikut pindah ke sana, yang berguna ketika Anda bepergian. Arahkan kursor ke sebuah kota dan klik tombol orang untuk mengatakan siapa yang tinggal di sana — nama biasa, atau handle GitHub `@` untuk membawa serta wajah mereka.

Setiap panel menerima keyboard maupun mouse: tombol panah berpindah, Return mengaktifkan, Tab melangkah ke panel di sebelahnya, dan Escape menutup.

`Super + Ctrl + 1-9` menghitung panel dari kiri ke kanan di bagian kanan, melewati tray karena tray tidak memiliki panelnya sendiri. Jadi angkanya cocok dengan ikon yang akan Anda tuju.

### Tailscale dan Dropbox

Dua widget lagi muncul di bar hanya setelah Anda menginstal layanan yang cocok dari **Install → Service**, dan keduanya layak diketahui karena mereka melakukan lebih dari sekadar melaporkan status.

Panel **Tailscale** menghubungkan dan memutuskan tailnet, berpindah antar akun, dan memilih exit node (mesin Anda sendiri dan wilayah Mullvad keduanya muncul dalam daftar itu). Panel ini juga menelusuri mesin Anda — dan dengan satu mesin terpilih, `s` mengirim file ke mesin itu melalui Taildrop, yang merupakan cara tercepat untuk memindahkan file ke ponsel atau laptop lain Anda. `c` menyalin IP mesin, `n` namanya, dan `d` nama DNS lengkapnya. Ada juga tombol kirim pada setiap baris mesin, jika Anda lebih suka mengklik. Hal yang sama dari terminal adalah `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** menangani login, menunjukkan berapa banyak penyimpanan yang telah Anda gunakan, dan mencantumkan file yang baru saja disinkronkan.

Menghapus salah satu layanan akan menghilangkan widgetnya dari bar.

## Indikator

Kluster kecil di tengah adalah widget indicators. Ini adalah glif status untuk mode yang telah Anda aktifkan: do not disturb, night light, [pengingat](09-reminders.md) yang mengantre, perekaman layar yang aktif, stay awake, dan [diktasi](11-text-extraction-dictation.md). Mereka menyala ketika mode tersebut aktif dan sebaliknya tidak mengganggu — arahkan kursor tepat di sampingnya, di tempat yang tidak aktif seharusnya berada, untuk mengintipnya. Mengklik sebuah indikator akan mengaktifkan/menonaktifkan mode itu. Satu lagi hanya untuk status: sesi remote menyala merah selama seseorang terhubung ke mesin ini melalui gliff.

Jika Anda lebih suka mereka selalu terlihat, tetapkan `alwaysShow` ke `true` pada widget tersebut. Dan jika Anda hanya peduli pada beberapa di antaranya, cantumkan yang Anda inginkan dalam `items`: `["Dnd", "Reminder", "NightLight"]`. Anda dapat memiliki lebih dari satu widget indicators, jadi bagian yang berbeda dapat menampilkan subset yang berbeda.

## Menata ulang bar

Bar ini mengonfigurasi dirinya sendiri. Anda tidak perlu membuka file konfigurasi untuk memindahkan sesuatu.

Ambil bagian kosong dari bar di sekitar tengah dan seret ke arah tepi layar lain, dan bar akan pindah ke sana — kiri, kanan, atas, atau bawah semuanya berfungsi, dan setiap widget menyesuaikan diri (bar vertikal kembali ke bentuk ringkas hanya-ikon). Klik dan tahan memulai penyeretan yang sama. Klik kiri dua kali pada ruang kosong yang sama itu untuk mengganti latar belakang bar secara bergilir dari clear ke glassy ke opaque. Dan seret widget apa pun untuk menata ulangnya atau melemparkannya ke bagian lain; widget lainnya bergeser menyebar untuk memberi ruang di tempat ia akan mendarat.

Bagian tengah bar adalah sebuah kotak: apa pun yang ada di dalamnya tetap berada di tengah sebagai satu grup, dan widget di kedua sisinya menggantung dari tepinya. Saat Anda menyeret sebuah widget, kotak itu tampil sebagai garis luar, atau garis melintasi bar ketika kosong, dan Anda dapat menjatuhkannya ke dalamnya atau di sampingnya. Ketika pelepasan akan mendarat di dalam kotak, kotak itu membesar untuk menampung widget tersebut.

Widget yang Anda inginkan ada di sekitar tetapi tidak selalu terlihat dapat masuk ke laci tray: seret ke tray, dan laci akan terbuka untuk menerimanya. Ia berada di sana setelah ikon aplikasi, muncul setiap kali laci muncul, dan menjaga lacinya tetap terbuka selama panelnya terbuka. Seret kembali keluar ke bar untuk mengembalikannya.

Jika Anda lebih suka memilih dari menu, **Appearance → Menu Bar** memiliki posisinya, dan **Bar Background** memilih bagaimana bar digambar: **Opaque Bar**, **Glassy Bar** (tembus pandang, dengan apa yang ada di belakangnya dikaburkan), atau **Clear Bar**.

Hal yang sama memiliki perintah, yang merupakan hal yang Anda inginkan untuk pengaturan [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Untuk menambah atau menghapus widget sepenuhnya, gunakan perintah plugin. `omarchy plugin list` mencetak setiap widget yang diketahui shell beserta id-nya, dan kemudian:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Menyembunyikan bar

`Super + Shift + Space` mengaktifkan/menonaktifkan bar tanpa mematikan shell — panel dan hotkey tetap berfungsi, Anda hanya mendapatkan kembali pikselnya. Ini juga ada di menu di bawah **Appearance → Menu Bar → Hide Bar**.

## File konfigurasi

Semua itu disimpan dalam `~/.config/omarchy/shell.json`, di bawah kunci `bar`. Ini versi yang dipangkas:

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

Setiap widget adalah satu entri dalam salah satu dari lima array layout, dan pengaturannya berada sebaris pada entri itu — tidak ada file pengaturan terpisah dan tidak ada sub-objek `config`. `format`, `formatAlt` (yang diganti secara bergilir oleh klik kanan), dan `verticalFormat` milik clock semuanya berada tepat di sana pada `{ "id": "omarchy.clock" }`.

`center` adalah kotak di tengah bar: semua yang ada di dalamnya berada di tengah layar sebagai satu grup. `centerBegin` dan `centerEnd` menggantung di kedua sisi kotak, dan begitulah cara clock tetap tepat di tengah bahkan saat cuaca dan lencana pembaruan datang dan pergi. Masukkan lebih dari satu widget ke dalam `center` dan mereka akan berada di tengah bersama-sama; kosongkan dan `centerBegin` dan `centerEnd` bertemu di tengah bar.

Satu aturan yang layak dihafalkan: **setelah Anda memiliki `shell.json` Anda sendiri, file itu yang menjadi acuan resmi**. Sampai Anda menyesuaikan apa pun, shell membaca file default Omarchy. Begitu Anda menyeret sebuah widget, menjalankan `omarchy bar`, atau mengedit file itu sendiri, Anda yang memilikinya — tidak ada deep merge, jadi widget default baru dalam rilis Omarchy mendatang tidak akan muncul di bar Anda secara otomatis. `omarchy bar defaults` mengembalikan layout bawaan kapan pun Anda menginginkan lembaran bersih.

File yang sama juga menyimpan pengaturan waktu idle Anda di tingkat atas, di luar kunci `bar`: `idle.screensaver` dan `idle.lock`, keduanya dalam detik sejak Anda menjadi idle. Jadi screensaver default aktif pada 150 detik dan kunci pada 300.
