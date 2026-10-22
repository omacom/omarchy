# Bar Atas

Jalur di sepanjang bahagian atas skrin anda ialah bar Omarchy. Ia bukan bar status yang ditambah kemudian tetapi sebahagian daripada shell Omarchy, proses Quickshell tunggal yang berjalan lama yang juga melukis menu, pemberitahuan, pop timbul OSD, dan skrin kunci. Itulah sebabnya ia bertema dengan sempurna bersama segala-galanya yang lain dan mengapa panel dibuka serta-merta dan bukannya memulakan aplikasi baharu.

Ia juga satu-satunya bahagian desktop yang sentiasa berada pada skrin, jadi berbaloi untuk mengetahui apa yang dilakukan oleh semua glif kecil itu.

## Apa yang ada padanya secara lalai

Bar mempunyai tiga bahagian. Di sebelah kiri terletak logo Omarchy (pelancar menu) dan penunjuk ruang kerja. Di tengah anda mendapat penunjuk status, jam, Elsewhen (jam dunia), cuaca, dan lencana kemas kini Omarchy. Di sebelah kanan: susun atur papan kekunci (apabila lebih daripada satu dikonfigurasikan), dulang sistem, ejen, bluetooth, rangkaian, audio, paparan, dan kuasa.

Sebahagian daripadanya hanya muncul apabila ia mempunyai sesuatu untuk dikatakan. Susun atur papan kekunci hanya muncul jika anda telah mengkonfigurasikan lebih daripada satu susun atur. Lencana kemas kini hanya muncul apabila terdapat kemas kini Omarchy yang menunggu. Dan ikon ejen muncul pada kali pertama Omarchy menemui penggunaan pengekodan AI pada mesin (lihat [AI](17-ai.md)).

## Mengklik sekeliling

Hampir setiap widget melakukan sesuatu pada klik kiri, kanan, dan tengah, dan beberapa daripadanya bertindak balas kepada penatalan. Ini ialah bahagian yang orang terlepas pandang — butang kanan dan tengah ialah tempat banyak perkara baik bersembunyi.

| Widget | Kiri | Kanan | Tengah / tatal |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Terminal baharu | — |
| Ruang Kerja | Fokus ruang kerja itu | — | Tatal: ruang kerja seterusnya/sebelumnya |
| Jam | Pop timbul kalendar | Kitar format label | Tengah: pemilih zon waktu |
| Cuaca | Pop timbul ramalan | Cuaca penuh sebagai pemberitahuan | Tengah: muat semula |
| Audio | Panel audio | Senyap | Tengah: panel · tatal: kelantangan |
| Mikrofon | Senyapkan mikrofon | — | Tengah: panel audio · tatal: kelantangan input |
| Rangkaian | Panel rangkaian | — | — |
| Bluetooth | Panel Bluetooth | Togol radio | — |
| Paparan | Panel paparan | — | Tatal: kecerahan |
| Kuasa | Panel kuasa | Togol peratus bateri | — |
| Media | Main/jeda | Pop timbul seni muka depan | Tengah: seterusnya · tatal: sebelum/seterusnya |
| Ejen | Panel ejen | Lancarkan ejen anda | Tengah: langganan seterusnya |
| Dulang | Layar untuk mendedahkan laci | Kanan pada chevron untuk mengurus | — |
| Kemas kini Omarchy | Jalankan kemas kini | — | — |

Tidak semua dalam jadual itu berada pada bar anda di luar kotak. Widget media (MPRIS sedang dimainkan, dengan trek dan artis yang menatal) dan widget mikrofon kedua-duanya terbina dalam tetapi dimatikan secara lalai — tambahkannya jika anda mahukannya, seperti yang diterangkan di bawah.

## Panel

Mengklik ikon bar membuka panel, iaitu pop timbul yang betul dengan gelangsar, senarai, dan navigasi papan kekunci dan bukannya petua alat. Setiap satu juga mempunyai kekunci panas, jadi anda tidak pernah perlu menyasar glif 16 piksel:

| Kekunci panas | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + W` | Rangkaian |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Paparan |
| `Super + Ctrl + P` | Kuasa |
| `Super + Ctrl + Alt + D` | Kalendar |
| `Super + Ctrl + Alt + E` | Jam dunia |
| `Super + Ctrl + 1-9` | Togol panel ke-n dalam bahagian kanan |

Panel bukanlah bacaan sahaja. Di situlah anda benar-benar melakukan perkara tersebut:

- **Audio** mempunyai gelangsar kelantangan utama, pemilih peranti output, dan pengadun bagi setiap aplikasi, jadi anda boleh merendahkan satu tab pelayar itu tanpa menyentuh segala-galanya yang lain.
- **Rangkaian** mengimbas Wi-Fi, memaparkan kekuatan isyarat, menyambung, dan membenarkan anda memilih pembekal DNS.
- **Bluetooth** menyenaraikan peranti anda dengan sambung/putus dan paras bateri.
- **Kuasa** memaparkan statistik bateri, menukar profil kuasa (ia mengingati pilihan berasingan untuk bateri dan AC), dan mencetak beberapa maklumat sistem.
- **Paparan** membawa gelangsar kecerahan, saiz teks, pratetap penskalaan monitor, dan — apabila anda mempunyai lebih daripada satu skrin — kawalan bagi setiap monitor. Lihat [monitor](33-monitors.md) untuk kisah yang lebih mendalam.
- **Jam** membuka grid bulan dengan nombor minggu ISO dan langkah bulan.

Setiap panel menerima papan kekunci serta tetikus: anak panah bergerak, Return mengaktifkan, Tab melangkah ke panel bersebelahan, dan Escape menutup.

`Super + Ctrl + 1-9` mengira panel dari kiri ke kanan dalam bahagian kanan, melangkau dulang kerana ia tidak mempunyai panel sendiri. Jadi nombornya sepadan dengan ikon yang akan anda tuding.

### Tailscale dan Dropbox

Dua lagi widget muncul pada bar hanya sebaik sahaja anda memasang perkhidmatan yang sepadan daripada **Pasang → Perkhidmatan**, dan kedua-duanya berbaloi untuk diketahui kerana ia melakukan lebih daripada melaporkan status.

Panel **Tailscale** menyambung dan memutuskan tailnet, bertukar antara akaun, dan memilih nod keluar (mesin anda sendiri dan rantau Mullvad kedua-duanya muncul dalam senarai itu). Ia juga menyemak imbas mesin anda — dan dengan satu dipilih, `s` menghantar fail kepadanya melalui Taildrop, iaitu cara terpantas untuk memindahkan fail ke telefon anda atau laptop lain. `c` menyalin IP mesin, `n` namanya, dan `d` nama DNS penuhnya. Terdapat juga butang hantar pada setiap baris mesin, jika anda lebih suka mengklik. Perkara yang sama dari terminal ialah `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** mengendalikan log masuk, memaparkan berapa banyak storan yang telah anda gunakan, dan menyenaraikan fail yang disegerakkan baru-baru ini.

Membuang mana-mana perkhidmatan mengeluarkan widgetnya kembali dari bar.

## Penunjuk

Gugusan kecil di tengah ialah widget penunjuk. Ini ialah glif status untuk mod yang telah anda hidupkan: jangan ganggu, cahaya malam, [peringatan](09-reminders.md) yang beratur, rakaman skrin aktif, kekal jaga, dan [pendiktean](11-text-extraction-dictation.md). Ia menyala apabila mod aktif dan sebaliknya kekal tidak menghalang — layangkan ke kiri jam (di atasnya pada bar menegak) untuk mengintai yang tidak aktif. Mengklik penunjuk menogol mod itu. Satu lagi ialah status sahaja: sesi jauh menyala merah semasa seseorang disambungkan ke mesin ini melalui gliff.

Jika anda lebih suka ia sentiasa kelihatan, tetapkan `alwaysShow` kepada `true` pada widget. Dan jika anda hanya mengambil berat tentang sebahagiannya, senaraikan yang anda mahukan dalam `items`: `["Dnd", "Reminder", "NightLight"]`. Anda boleh mempunyai lebih daripada satu widget penunjuk, jadi bahagian yang berbeza boleh memaparkan subset yang berbeza.

## Menyusun semula bar

Bar mengkonfigurasi dirinya sendiri. Anda tidak perlu membuka fail konfigurasi untuk memindahkan sesuatu.

Pegang tompok kosong bar di sekeliling tengah dan seretnya ke arah tepi skrin lain, dan bar berpindah ke sana — kiri, kanan, atas, atau bawah semuanya berfungsi, dan setiap widget menyesuaikan diri (bar menegak kembali kepada bentuk ikon sahaja yang padat). Klik dan tahan memulakan seretan yang sama. Klik kiri dua kali pada ruang kosong yang sama untuk mengitar latar belakang bar dari jernih kepada kaca kepada legap. Dan seret mana-mana widget untuk menyusunnya semula atau membuangnya ke bahagian lain.

Widget yang anda mahu kekalkan tetapi tidak perlu sentiasa kelihatan boleh masuk ke dalam laci dulang: seretnya ke atas dulang, dan laci akan terbuka untuk menerimanya. Ia terletak di sana selepas ikon aplikasi, muncul setiap kali laci dipaparkan, dan memastikan laci kekal terbuka semasa panelnya sedang dibuka. Seretnya kembali keluar ke bar untuk meletakkannya semula.

Jika anda lebih suka memilih daripada menu, **Pencetus → Penampilan → Bar Menu** mempunyai kedudukan, dan **Latar Bar** memilih cara bar dilukis: **Bar Legap**, **Bar Kaca** (lut sinar, dengan apa yang berada di belakangnya dikaburkan), atau **Bar Jernih**.

Perkara yang sama mempunyai arahan, iaitu apa yang anda mahukan untuk persediaan [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Untuk menambah atau membuang widget sepenuhnya, gunakan arahan plugin. `omarchy plugin list` mencetak setiap widget yang diketahui oleh shell dengan id-nya, dan kemudian:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Menyembunyikan bar

`Super + Shift + Space` menogol bar mati dan hidup semula tanpa membunuh shell — panel dan kekunci panas terus berfungsi, anda hanya mendapat piksel kembali. Ia juga berada dalam menu di bawah **Pencetus → Penampilan → Bar Menu → Sembunyi Bar**.

## Fail konfigurasi

Kesemuanya disimpan dalam `~/.config/omarchy/shell.json`, di bawah kekunci `bar`. Berikut ialah versi yang dipangkas:

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

Setiap widget ialah satu entri dalam salah satu daripada tiga tatasusunan susun atur, dan tetapannya berada sebaris pada entri itu — tiada fail tetapan berasingan dan tiada sub-objek `config`. `format` jam, `formatAlt` (apa yang dikitar oleh klik kanan), dan `verticalFormat` semuanya berada betul-betul di sana pada `{ "id": "omarchy.clock" }`.

`centerAnchor` menamakan satu widget tengah yang disematkan ke pusat tepat skrin, dengan yang lain mengapitnya. Begitulah cara jam kekal betul-betul di tengah walaupun cuaca dan lencana kemas kini datang dan pergi. Tetapkannya kepada rentetan kosong dan senarai tengah hanya dipusatkan sebagai kumpulan sebagai gantinya.

Satu peraturan yang berbaloi untuk dihayati: **sebaik sahaja anda mempunyai `shell.json` anda sendiri, ia adalah berkanun**. Sehingga anda menyesuaikan apa-apa, shell membaca fail lalai Omarchy. Sebaik sahaja anda menyeret widget, menjalankan `omarchy bar`, atau menyunting fail itu sendiri, anda memilikinya — tiada gabungan mendalam, jadi widget lalai baharu dalam keluaran Omarchy masa hadapan tidak akan muncul pada bar anda secara automatik. `omarchy bar defaults` mengembalikan susun atur yang dihantar pada bila-bila masa anda mahukan permulaan yang bersih.

Fail yang sama juga menyimpan pemasaan terbiar anda pada peringkat atas, di luar kekunci `bar`: `idle.screensaver` dan `idle.lock`, kedua-duanya dalam saat sejak anda menjadi terbiar. Jadi tabir skrin lalai bermula pada 150 saat dan kunci pada 300.
