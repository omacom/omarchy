# Bar Atas

Strip di sepanjang bagian atas layar Anda adalah bar Omarchy. Ini bukan bar status yang ditempel begitu saja, melainkan bagian dari shell Omarchy, proses Quickshell tunggal yang berjalan lama dan juga menggambar menu, notifikasi, popup OSD, dan layar kunci. Itulah sebabnya temanya menyatu sempurna dengan semua hal lainnya dan mengapa sebuah panel terbuka seketika, bukan dengan memunculkan aplikasi baru.

Ini juga satu-satunya bagian desktop yang selalu ada di layar, jadi layak untuk mengetahui apa fungsi semua glif kecil itu.

## Yang tampil secara default

Bar ini memiliki tiga bagian. Di kiri ada logo Omarchy (peluncur menu) dan indikator workspace. Di tengah ada indikator status, jam, Elsewhen (jam dunia), cuaca, dan lencana pembaruan Omarchy. Di kanan: system tray, tata letak keyboard (ketika lebih dari satu tata letak atau metode input dikonfigurasi), agen, bluetooth, jaringan, audio, tampilan, dan daya.

Beberapa di antaranya hanya muncul ketika mereka punya sesuatu untuk disampaikan. Tata letak keyboard hanya muncul jika Anda telah mengonfigurasi lebih dari satu tata letak atau metode input. Lencana pembaruan hanya muncul ketika ada pembaruan Omarchy yang menunggu.

## Mengklik di sana-sini

Hampir setiap widget melakukan sesuatu saat diklik kiri, kanan, dan tengah, dan beberapa merespons guliran. Inilah bagian yang sering terlewat — tombol kanan dan tengah adalah tempat banyak hal bagusnya bersembunyi.

| Widget | Kiri | Kanan | Tengah / gulir |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Terminal baru | — |
| Workspaces | Fokuskan workspace itu di monitor ini | — | Gulir: workspace berikutnya/sebelumnya |
| Jam | Popup kalender | Putar format label | Tengah: pemilih zona waktu |
| Jam dunia | Panel jam dunia | Segarkan | Tengah: segarkan |
| Cuaca | Popup prakiraan | Cuaca lengkap sebagai notifikasi | Tengah: segarkan |
| Audio | Panel audio | Bisukan | Tengah: panel · gulir: volume |
| Mikrofon | Bisukan mikrofon | — | Tengah: panel audio · gulir: volume input |
| Jaringan | Panel jaringan | — | — |
| Bluetooth | Panel Bluetooth | Aktif/nonaktifkan radio | — |
| Tampilan | Panel tampilan | — | Gulir: kecerahan |
| Daya | Panel daya | Aktif/nonaktifkan persentase baterai | — |
| Media | Putar/jeda | Popup sampul album | Tengah: berikutnya · gulir: sebelumnya/berikutnya |
| Agen | Panel agen | Luncurkan agen Anda | Tengah: segarkan penggunaan |
| Tray | Arahkan kursor untuk membuka laci | Klik kanan pada chevron untuk mengelola | — |
| Pembaruan Omarchy | Jalankan pembaruan | — | — |

Tidak semua yang ada di tabel itu ada di bar Anda sejak awal. Widget media (MPRIS now-playing, dengan trek dan artis yang bergulir) dan widget mikrofon keduanya sudah terpasang tetapi nonaktif secara default — tambahkan jika Anda menginginkannya, seperti yang dijelaskan di bawah.

## Panel-panelnya

Mengklik ikon bar akan membuka panel, yaitu popup yang sesungguhnya dengan slider, daftar, dan navigasi keyboard, bukan sekadar tooltip. Masing-masing juga punya hotkey, jadi Anda tidak perlu membidik glif 16 piksel:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Jaringan |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Tampilan |
| `Super + Ctrl + P` | Daya |
| `Super + Ctrl + Alt + D` | Kalender |
| `Super + Ctrl + Alt + E` | Jam dunia |
| `Super + Ctrl + X` | Agen |
| `Super + Ctrl + 1-9` | Aktif/nonaktifkan panel ke-n di bagian kanan |

Panel-panel itu bukan sekadar tampilan bacaan. Di sanalah Anda benar-benar melakukan halnya:

- **Audio** punya slider volume master, pemilih perangkat output, dan mixer per aplikasi, jadi Anda bisa menurunkan volume satu tab browser itu tanpa menyentuh semua hal lainnya.
- **Jaringan** memindai Wi-Fi, menunjukkan kekuatan sinyal, menghubungkan, dan membiarkan Anda memilih penyedia DNS.
- **Bluetooth** mencantumkan perangkat Anda dengan sambungkan/putuskan dan tingkat baterai.
- **Daya** menunjukkan statistik baterai, mengganti profil daya (ia mengingat pilihan terpisah untuk baterai dan AC), dan mencetak beberapa info sistem.
- **Tampilan** membawa slider kecerahan, ukuran teks, preset penskalaan monitor, dan — ketika Anda punya lebih dari satu layar — kontrol per monitor. Lihat [monitor](33-monitors.md) untuk cerita yang lebih mendalam.
- **Jam** membuka kisi bulan dengan nomor minggu ISO dan perpindahan bulan.
- **Jam dunia** menyimpan satu baris per kota, dengan cuacanya dan bagaimana harinya berjalan. Pencarian menemukan kota-kota kecil maupun zona waktu, jadi Fort Lauderdale adalah Fort Lauderdale dan bukan New York. Jika baris di bagian atas menyebutkan kota yang salah, klik baris itu dan katakan di mana Anda berada; pilih tempat di zona waktu lain dan jam sistem juga ikut pindah ke sana, yang berguna ketika Anda bepergian. Arahkan kursor ke sebuah kota dan klik tombol orang untuk mengatakan siapa yang tinggal di sana — nama biasa, atau handle GitHub `@` untuk membawa serta wajah mereka.

Setiap panel juga menerima keyboard maupun mouse: panah untuk bergerak, Return untuk mengaktifkan, Tab untuk melangkah ke panel sebelahnya, dan Escape untuk menutup.

`Super + Ctrl + 1-9` menghitung panel dari kiri ke kanan di bagian kanan, melewati tray karena tray tidak punya panelnya sendiri. Jadi angkanya cocok dengan ikon yang akan Anda tunjuk.

### Tailscale dan Dropbox

Dua widget lagi muncul di bar hanya setelah Anda memasang layanan yang cocok dari **Install → Service**, dan keduanya layak diketahui karena mereka melakukan lebih dari sekadar melaporkan status.

Panel **Tailscale** menghubungkan dan memutuskan tailnet, beralih antar akun, dan memilih exit node (mesin Anda sendiri maupun wilayah Mullvad sama-sama muncul di daftar itu). Panel ini juga menelusuri mesin-mesin Anda — dan dengan satu mesin terpilih, `s` mengirim file ke mesin itu melalui Taildrop, yang merupakan cara tercepat untuk memindahkan file ke ponsel atau laptop lain Anda. `c` menyalin IP mesin itu, `n` namanya, dan `d` nama DNS lengkapnya. Ada juga tombol kirim di setiap baris mesin, jika Anda lebih suka mengklik. Hal yang sama dari terminal adalah `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** menangani login, menunjukkan berapa banyak penyimpanan yang telah Anda gunakan, dan mencantumkan file yang baru-baru ini disinkronkan.

Menghapus salah satu layanan akan menghilangkan widgetnya kembali dari bar.

## Indikator

Gugusan kecil di tengah adalah widget indikator. Ini adalah glif status untuk mode yang telah Anda aktifkan: jangan ganggu, lampu malam, [pengingat](09-reminders.md) yang mengantre, perekaman layar yang aktif, dan tetap terjaga, ditambah peringatan selagi sudo tanpa kata sandi aktif atau seseorang terhubung ke sesi jarak jauh. Mereka menyala ketika modenya aktif dan selain itu tidak menghalangi — arahkan kursor tepat di samping mereka, di tempat yang seharusnya ditempati yang tidak aktif, untuk mengintip yang tidak aktif itu. Mengklik sebuah indikator akan mengaktifkan/menonaktifkan mode itu. Satu lagi hanya status: sesi jarak jauh menyala merah selagi seseorang terhubung ke mesin ini melalui gliff.

Jika Anda lebih suka mereka selalu terlihat, setel `alwaysShow` ke `true` pada widget itu. Dan jika Anda hanya peduli pada beberapa di antaranya, cantumkan yang Anda inginkan di `items`: `["Dnd", "Reminder", "NightLight"]`. Anda bisa memiliki lebih dari satu widget indikator, jadi bagian yang berbeda bisa menampilkan subset yang berbeda.

## Mengatur ulang bar

Bar ini mengonfigurasi dirinya sendiri. Anda tidak harus membuka file konfigurasi untuk memindahkan sesuatu.

Ambil bagian kosong bar di sekitar tengah dan seret ke arah tepi layar lain, dan bar akan pindah ke sana — kiri, kanan, atas, atau bawah semuanya bisa, dan setiap widget menyesuaikan diri (bar vertikal beralih ke bentuk ringkas hanya-ikon). Klik dan tahan memulai seretan yang sama. Klik kiri dua kali pada ruang kosong yang sama itu untuk memutar latar belakang bar dari bening ke kaca ke buram. Dan seret widget apa pun untuk menyusun ulang atau melemparkannya ke bagian lain; widget-widget lainnya akan bergeser membuka ruang di tempat ia akan mendarat.

Bagian tengah bar adalah sebuah kotak: apa pun yang ada di dalamnya tetap terpusat sebagai satu kelompok, dan widget di kedua sisinya menggantung dari tepinya. Selagi Anda menyeret sebuah widget, kotak itu tampil sebagai garis luar, atau garis melintasi bar ketika kosong, dan Anda bisa menjatuhkannya ke dalam kotak itu atau di sampingnya. Ketika jatuhan akan mendarat di dalam kotak, kotak itu membesar untuk menerima widget tersebut.

Widget yang Anda inginkan tetap ada tetapi tidak selalu terlihat bisa masuk ke laci tray: seret ke atas tray, dan laci akan terbuka untuk menerimanya. Ia duduk di sana setelah ikon aplikasi, muncul kapan pun laci muncul, dan menjaga lacinya tetap terbuka selagi panelnya tampil. Seret kembali keluar ke bar untuk mengembalikannya.

Jika Anda lebih suka memilih dari menu, **Appearance → Menu Bar** punya posisinya, dan **Bar Background** memilih bagaimana bar digambar: **Opaque Bar**, **Glassy Bar** (tembus pandang, dengan apa yang ada di belakangnya diburamkan), atau **Clear Bar**.

Hal yang sama punya perintah, yang merupakan yang Anda inginkan untuk penyiapan [dotfiles](31-dotfiles.md):

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

`Super + Shift + Space` mengaktifkan/menonaktifkan bar tanpa mematikan shell — panel dan hotkey tetap bekerja, Anda hanya mendapatkan kembali pikselnya. Ini juga ada di menu di bawah **Appearance → Menu Bar → Hide Bar**.

## File konfigurasi

Semua itu disimpan di `~/.config/omarchy/shell.json`, di bawah kunci `bar`. Berikut versi yang dipangkas:

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

Setiap widget adalah satu entri di salah satu dari lima array layout, dan pengaturannya duduk sebaris pada entri itu — tidak ada file pengaturan terpisah dan tidak ada sub-objek `config`. `format`, `formatAlt` (yang diputar oleh klik kanan), dan `verticalFormat` milik jam semuanya tinggal tepat di sana pada `{ "id": "omarchy.clock" }`.

`center` adalah kotak di tengah bar: semua yang ada di dalamnya terpusat di layar sebagai satu kelompok. `centerBegin` dan `centerEnd` menggantung di kedua sisi kotak, yang merupakan cara jam tetap tepat di tengah bahkan selagi cuaca dan lencana pembaruan datang dan pergi. Taruh lebih dari satu widget di `center` dan mereka akan terpusat bersama; biarkan kosong dan `centerBegin` dan `centerEnd` bertemu di tengah bar.

Satu aturan yang layak diinternalisasi: **begitu Anda punya `shell.json` Anda sendiri, itulah yang kanonis**. Sampai Anda menyesuaikan apa pun, shell membaca file default Omarchy. Begitu Anda menyeret sebuah widget, menjalankan `omarchy bar`, atau mengedit file itu sendiri, Anda memilikinya — tidak ada penggabungan mendalam, jadi widget default baru di rilis Omarchy mendatang tidak akan muncul di bar Anda secara otomatis. `omarchy bar defaults` mengembalikan layout bawaan kapan pun Anda menginginkan awal yang bersih.

File yang sama juga menyimpan pengaturan waktu idle Anda di tingkat atas, di luar kunci `bar`: `idle.screensaver` dan `idle.lock`, keduanya dalam detik sejak Anda mulai idle. Jadi screensaver default mulai bekerja pada 150 detik dan penguncian pada 300 detik.
