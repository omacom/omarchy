# Bilah Atas

Strip di sepanjang bagian atas layar Anda adalah bilah Omarchy. Ini bukan bilah status yang ditempelkan, melainkan bagian dari shell Omarchy, proses Quickshell tunggal yang berjalan lama yang juga menggambar menu, notifikasi, popup OSD, dan layar kunci. Itulah mengapa temanya sangat cocok dengan semua hal lain dan mengapa panel terbuka seketika alih-alih memunculkan aplikasi baru.

Ini juga satu-satunya bagian desktop yang selalu ada di layar, jadi penting untuk mengetahui apa yang dilakukan semua glif kecil itu.

## Apa yang ada di atasnya secara bawaan

Bilah memiliki tiga bagian. Di sebelah kiri terdapat logo Omarchy (peluncur menu) dan indikator ruang kerja. Di tengah Anda mendapatkan indikator status, jam, Elsewhen (jam dunia), cuaca, dan lencana pembaruan Omarchy. Di sebelah kanan: tata letak keyboard (ketika lebih dari satu dikonfigurasi), baki sistem, agen, bluetooth, jaringan, audio, tampilan, dan daya.

Beberapa di antaranya hanya muncul ketika mereka memiliki sesuatu untuk dikatakan. Tata letak keyboard hanya muncul jika Anda telah mengkonfigurasi lebih dari satu tata letak. Lencana pembaruan hanya muncul ketika ada pembaruan Omarchy yang menunggu. Dan ikon agen muncul pertama kalinya Omarchy menemukan penggunaan coding AI pada mesin (lihat [AI](17-ai.md)).

## Mengklik ke sana kemari

Hampir setiap widget melakukan sesuatu pada klik kiri, kanan, dan tengah, dan beberapa merespons guliran. Ini adalah bagian yang terlewatkan orang — tombol kanan dan tengah adalah tempat banyak hal bagus bersembunyi.

| Widget | Kiri | Kanan | Tengah / gulir |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Terminal baru | — |
| Ruang Kerja | Fokus ruang kerja itu | — | Gulir: ruang kerja berikutnya/sebelumnya |
| Jam | Popup kalender | Gilir format label | Tengah: pemilih zona waktu |
| Cuaca | Popup prakiraan | Cuaca penuh sebagai notifikasi | Tengah: segarkan |
| Audio | Panel audio | Bisukan | Tengah: panel · gulir: volume |
| Mikrofon | Bisukan mikrofon | — | Tengah: panel audio · gulir: volume masukan |
| Jaringan | Panel jaringan | — | — |
| Bluetooth | Panel Bluetooth | Alihkan radio | — |
| Tampilan | Panel tampilan | — | Gulir: kecerahan |
| Daya | Panel daya | Alihkan persentase baterai | — |
| Media | Putar/jeda | Popup sampul | Tengah: berikutnya · gulir: sebelum/berikutnya |
| Agen | Panel agen | Luncurkan agen Anda | Tengah: langganan berikutnya |
| Baki | Arahkan untuk menampilkan laci | Klik kanan chevron untuk mengelola | — |
| Pembaruan Omarchy | Jalankan pembaruan | — | — |

Tidak semua yang ada dalam tabel itu ada di bilah Anda sejak awal. Widget media (MPRIS yang sedang diputar, dengan trek dan artis bergulir) dan widget mikrofon keduanya bawaan tetapi mati secara bawaan — tambahkan jika Anda menginginkannya, seperti yang dijelaskan di bawah.

## Panel-panelnya

Mengklik ikon bilah membuka panel, yang merupakan popup yang tepat dengan slider, daftar, dan navigasi keyboard alih-alih tooltip. Masing-masing juga memiliki hotkey, sehingga Anda tidak pernah harus mengincar glif 16 piksel:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + W` | Jaringan |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Tampilan |
| `Super + Ctrl + P` | Daya |
| `Super + Ctrl + Alt + D` | Kalender |
| `Super + Ctrl + Alt + E` | Jam dunia |
| `Super + Ctrl + 1-9` | Alihkan panel ke-n di bagian kanan |

Panel-panelnya bukan bacaan saja. Di sanalah Anda benar-benar melakukan hal itu:

- **Audio** memiliki slider volume master, pemilih perangkat keluaran, dan mixer per aplikasi, sehingga Anda dapat menurunkan satu tab browser itu tanpa menyentuh hal lain.
- **Jaringan** memindai Wi-Fi, menunjukkan kekuatan sinyal, menghubungkan, dan memungkinkan Anda memilih penyedia DNS.
- **Bluetooth** mencantumkan perangkat Anda dengan sambung/putus dan tingkat baterai.
- **Daya** menunjukkan statistik baterai, mengalihkan profil daya (ia mengingat pilihan terpisah untuk baterai dan AC), dan mencetak beberapa info sistem.
- **Tampilan** membawa slider kecerahan, ukuran teks, preset penskalaan monitor, dan — ketika Anda memiliki lebih dari satu layar — kontrol per monitor. Lihat [monitor](33-monitors.md) untuk cerita yang lebih dalam.
- **Jam** membuka kisi bulan dengan nomor minggu ISO dan langkah bulan.

Setiap panel menggunakan keyboard maupun mouse: panah bergerak, Return mengaktifkan, Tab melangkah ke panel tetangga, dan Escape menutup.

`Super + Ctrl + 1-9` menghitung panel dari kiri ke kanan di bagian kanan, melewati baki karena ia tidak memiliki panel sendiri. Jadi angkanya cocok dengan ikon yang akan Anda tunjuk.

### Tailscale dan Dropbox

Dua widget lagi muncul di bilah hanya setelah Anda memasang layanan yang cocok dari **Pasang → Layanan**, dan keduanya layak diketahui karena mereka melakukan lebih dari sekadar melaporkan status.

Panel **Tailscale** menghubungkan dan memutuskan tailnet, beralih antar akun, dan memilih node keluar (mesin Anda sendiri dan wilayah Mullvad keduanya muncul dalam daftar itu). Ia juga menelusuri mesin Anda — dan dengan satu terpilih, `s` mengirim berkas ke sana melalui Taildrop, yang merupakan cara tercepat untuk memindahkan berkas ke ponsel Anda atau laptop lain. `c` menyalin IP mesin, `n` namanya, dan `d` nama DNS lengkapnya. Ada juga tombol kirim pada setiap baris mesin, jika Anda lebih suka mengklik. Hal yang sama dari terminal adalah `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** menangani login, menunjukkan berapa banyak penyimpanan yang telah Anda gunakan, dan mencantumkan berkas yang baru disinkronkan.

Menghapus salah satu layanan akan menghilangkan widgetnya dari bilah.

## Indikator

Gugus kecil di tengah adalah widget indikator. Ini adalah glif status untuk mode yang telah Anda aktifkan: jangan ganggu, lampu malam, [pengingat](09-reminders.md) yang mengantre, perekaman layar aktif, tetap bangun, dan [dikte](11-text-extraction-dictation.md). Mereka menyala ketika mode aktif dan sebaliknya tetap tidak mengganggu — arahkan ke sebelah kiri jam (di atasnya pada bilah vertikal) untuk mengintip yang tidak aktif. Mengklik indikator mengalihkan mode itu. Satu lagi hanya status: sesi jarak jauh menyala merah saat seseorang terhubung ke mesin ini melalui gliff.

Jika Anda lebih suka mereka selalu terlihat, atur `alwaysShow` ke `true` pada widget. Dan jika Anda hanya peduli pada beberapa di antaranya, cantumkan yang Anda inginkan dalam `items`: `["Dnd", "Reminder", "NightLight"]`. Anda dapat memiliki lebih dari satu widget indikator, sehingga bagian yang berbeda dapat menunjukkan subset yang berbeda.

## Mengatur ulang bilah

Bilah mengkonfigurasi dirinya sendiri. Anda tidak harus membuka berkas konfigurasi untuk memindahkan sesuatu.

Ambil tambalan kosong bilah di sekitar tengah dan seret ke arah tepi layar lain, dan bilah pindah ke sana — kiri, kanan, atas, atau bawah semuanya berfungsi, dan setiap widget beradaptasi (bilah vertikal kembali ke bentuk ikon saja yang kompak). Klik-dan-tahan memulai seretan yang sama. Klik dua kali dengan tombol kiri ruang kosong yang sama untuk menggilir latar belakang bilah dari bening ke kaca ke pekat. Dan seret widget mana pun untuk menyusun ulang atau membuangnya ke bagian lain.

Widget yang ingin Anda sediakan tetapi tidak selalu terlihat dapat masuk ke laci baki: seret ke baki, dan lacinya akan terbuka untuk menerimanya. Ia berada di sana setelah ikon-ikon aplikasi, muncul setiap kali laci muncul, dan menjaga lacinya tetap terbuka selama panelnya terbuka. Seret kembali keluar ke bilah untuk mengembalikannya.

Jika Anda lebih suka memilih dari menu, **Pemicu → Tampilan → Bilah Menu** memiliki posisi, dan **Latar Bilah** memilih bagaimana bilah digambar: **Bilah Pekat**, **Bilah Kaca** (tembus pandang, dengan yang di belakangnya diburamkan), atau **Bilah Bening**.

Hal yang sama memiliki perintah, yang merupakan yang Anda inginkan untuk penyiapan [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Untuk menambah atau menghapus widget sepenuhnya, gunakan perintah plugin. `omarchy plugin list` mencetak setiap widget yang diketahui shell dengan id-nya, dan kemudian:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Menyembunyikan bilah

`Super + Shift + Space` mengalihkan bilah mati dan kembali menyala tanpa mematikan shell — panel dan hotkey tetap berfungsi, Anda hanya mendapatkan kembali pikselnya. Ini juga ada di menu di bawah **Pemicu → Tampilan → Bilah Menu → Sembunyikan Bilah**.

## Berkas konfigurasi

Semua itu disimpan dalam `~/.config/omarchy/shell.json`, di bawah kunci `bar`. Berikut versi yang dipangkas:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Setiap widget adalah satu entri dalam salah satu dari tiga larik tata letak, dan pengaturannya berada sebaris pada entri itu — tidak ada berkas pengaturan terpisah dan tidak ada subobjek `config`. `format`, `formatAlt` (yang digilir oleh klik kanan), dan `verticalFormat` jam semuanya tinggal tepat di sana pada `{ "id": "omarchy.clock" }`.

`centerAnchor` menamai satu widget tengah yang disematkan ke pusat layar yang tepat, dengan yang lainnya mengapitnya. Begitulah jam tetap tepat di tengah bahkan saat cuaca dan lencana pembaruan datang dan pergi. Atur ke string kosong dan daftar tengah hanya dipusatkan sebagai sebuah kelompok sebagai gantinya.

Satu aturan yang layak diingat: **setelah Anda memiliki `shell.json` sendiri, itu adalah kanonis**. Sampai Anda menyesuaikan apa pun, shell membaca berkas bawaan Omarchy. Saat Anda menyeret widget, menjalankan `omarchy bar`, atau mengedit berkas sendiri, Anda memilikinya — tidak ada penggabungan mendalam, sehingga widget bawaan baru dalam rilis Omarchy mendatang tidak akan muncul di bilah Anda secara otomatis. `omarchy bar defaults` mengembalikan tata letak bawaan kapan pun Anda menginginkan lembaran bersih.

Berkas yang sama juga menampung pengaturan waktu menganggur Anda di tingkat atas, di luar kunci `bar`: `idle.screensaver` dan `idle.lock`, keduanya dalam detik sejak Anda menganggur. Jadi screensaver bawaan muncul pada 150 detik dan kunci pada 300.
