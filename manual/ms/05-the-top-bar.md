# Bar Atas

Jalur di sepanjang bahagian atas skrin anda ialah bar Omarchy. Ia bukan bar status yang dipasang kemudian, tetapi sebahagian daripada shell Omarchy, proses Quickshell tunggal yang berjalan lama dan turut melukis menu, pemberitahuan, popup OSD, dan skrin kunci. Sebab itulah ia bertema dengan sempurna bersama semua benda lain dan sebab sesebuah panel terbuka serta-merta dan bukan dengan memulakan aplikasi baharu.

Ia juga satu-satunya bahagian desktop yang sentiasa berada pada skrin, jadi berbaloi untuk mengetahui apa yang dilakukan oleh semua glif kecil itu.

## Apa yang ada padanya secara lalai

Bar ini mempunyai tiga bahagian. Di sebelah kiri terletak logo Omarchy (pelancar menu) dan penunjuk ruang kerja. Di tengah anda mendapat penunjuk status, jam, Elsewhen (jam dunia), cuaca, dan lencana kemas kini Omarchy. Di sebelah kanan: dulang sistem, susun atur papan kekunci (apabila lebih daripada satu susun atur atau kaedah input dikonfigurasikan), agents, bluetooth, rangkaian, audio, paparan, dan kuasa.

Beberapa antaranya hanya muncul apabila mereka mempunyai sesuatu untuk disampaikan. Susun atur papan kekunci hanya muncul jika anda telah mengkonfigurasi lebih daripada satu susun atur atau kaedah input. Lencana kemas kini hanya muncul apabila terdapat kemas kini Omarchy yang sedang menunggu.

## Mengklik di sana sini

Hampir setiap widget melakukan sesuatu apabila diklik kiri, kanan, dan tengah, dan beberapa widget bertindak balas kepada tatalan. Inilah bahagian yang terlepas pandang oleh ramai orang — butang kanan dan tengah ialah tempat banyak benda bagus tersembunyi.

| Widget | Klik kiri | Klik kanan | Klik tengah / tatal |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Terminal baharu | — |
| Ruang kerja | Fokus ruang kerja itu pada monitor ini | — | Tatal: ruang kerja seterusnya/sebelumnya |
| Jam | Popup kalendar | Kitar format label | Klik tengah: pemilih zon masa |
| Jam dunia | Panel jam dunia | Muat semula | Klik tengah: muat semula |
| Cuaca | Popup ramalan | Cuaca penuh sebagai pemberitahuan | Klik tengah: muat semula |
| Audio | Panel audio | Bisukan | Klik tengah: panel · tatal: kelantangan |
| Mikrofon | Bisukan mikrofon | — | Klik tengah: panel audio · tatal: kelantangan input |
| Rangkaian | Panel rangkaian | — | — |
| Bluetooth | Panel Bluetooth | Togol radio | — |
| Paparan | Panel paparan | — | Tatal: kecerahan |
| Kuasa | Panel kuasa | Togol peratusan bateri | — |
| Media | Main/jeda | Popup gambar kulit | Klik tengah: seterusnya · tatal: sebelumnya/seterusnya |
| Agents | Panel Agents | Lancarkan agent anda | Klik tengah: muat semula penggunaan |
| Tray | Hover untuk mendedahkan laci | Klik kanan pada chevron untuk mengurus | — |
| Kemas kini Omarchy | Jalankan kemas kini | — | — |

Tidak semua dalam jadual itu ada pada bar anda terus dari kotak. Widget media (MPRIS yang sedang dimainkan, dengan runut dan artis yang menatal) dan widget mikrofon kedua-duanya terbina dalam tetapi dimatikan secara lalai — tambahkannya jika anda mahukannya, seperti yang diterangkan di bawah.

## Panel-panel

Mengklik ikon bar membuka panel, iaitu popup yang sebenar dengan peluncur, senarai, dan navigasi papan kekunci, bukan petua alat. Setiap panel juga mempunyai hotkey, jadi anda tidak perlu menyasar glif 16 piksel:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Rangkaian |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Paparan |
| `Super + Ctrl + P` | Kuasa |
| `Super + Ctrl + Alt + D` | Kalendar |
| `Super + Ctrl + Alt + E` | Jam dunia |
| `Super + Ctrl + X` | Agents |
| `Super + Ctrl + 1-9` | Togol panel ke-n dalam bahagian kanan |

Panel-panel ini bukan sekadar paparan bacaan. Di sinilah anda benar-benar melakukan sesuatu:

- **Audio** mempunyai peluncur kelantangan utama, pemilih peranti output, dan pengadun per aplikasi, jadi anda boleh memperlahankan satu tab pelayar itu tanpa menyentuh semua benda lain.
- **Rangkaian** mengimbas Wi-Fi, menunjukkan kekuatan isyarat, menyambung, dan membolehkan anda memilih penyedia DNS.
- **Bluetooth** menyenaraikan peranti anda dengan sambung/putus dan paras bateri.
- **Kuasa** menunjukkan statistik bateri, menukar profil kuasa (ia mengingati pilihan berasingan untuk bateri dan AC), dan mencetak beberapa maklumat sistem.
- **Paparan** membawa peluncur kecerahan, saiz teks, pratetap penskalaan monitor, dan — apabila anda mempunyai lebih daripada satu skrin — kawalan per monitor. Lihat [monitor](33-monitors.md) untuk kisah yang lebih mendalam.
- **Jam** membuka grid bulan dengan nombor minggu ISO dan langkah bulan.
- **Jam dunia** menyimpan satu baris bagi setiap bandar, dengan cuacanya dan bagaimana perjalanan harinya. Carian mencari pekan dan juga zon masa, jadi Fort Lauderdale kekal Fort Lauderdale dan bukan New York. Jika baris di bahagian atas menamakan bandar yang salah, klik baris itu dan nyatakan di mana anda berada; pilih tempat di zon masa lain dan jam sistem turut berpindah ke sana, yang amat berguna apabila anda dalam perjalanan. Hover pada sesebuah bandar dan klik butang orang untuk menyatakan siapa yang tinggal di sana — nama biasa, atau pemegang GitHub `@` untuk membawa wajah mereka bersama.

Setiap panel menerima papan kekunci dan juga tetikus: anak panah bergerak, Return mengaktifkan, Tab melangkah ke panel berjiran, dan Escape menutup.

`Super + Ctrl + 1-9` mengira panel dari kiri ke kanan dalam bahagian kanan, melangkau tray kerana ia tiada panel sendiri. Jadi nombor itu sepadan dengan ikon yang akan anda tuju.

### Tailscale dan Dropbox

Dua lagi widget muncul pada bar hanya apabila anda memasang perkhidmatan yang sepadan daripada **Install → Service**, dan kedua-duanya berbaloi untuk diketahui kerana mereka melakukan lebih daripada sekadar melaporkan status.

Panel **Tailscale** menyambung dan memutuskan tailnet, bertukar antara akaun, dan memilih nod keluar (mesin anda sendiri dan wilayah Mullvad kedua-duanya muncul dalam senarai itu). Ia juga menyemak imbas mesin anda — dan apabila satu mesin dipilih, `s` menghantar fail kepadanya melalui Taildrop, iaitu cara terpantas untuk memindahkan fail ke telefon atau laptop lain anda. `c` menyalin IP mesin itu, `n` namanya, dan `d` nama DNS penuhnya. Terdapat juga butang hantar pada setiap baris mesin, jika anda lebih suka mengklik. Benda yang sama daripada terminal ialah `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** mengendalikan log masuk, menunjukkan berapa banyak storan yang telah anda gunakan, dan menyenaraikan fail yang baru disegerakkan.

Mengalih keluar mana-mana perkhidmatan akan mengeluarkan widgetnya semula daripada bar.

## Penunjuk

Kelompok kecil di tengah ialah widget penunjuk. Ini ialah glif status untuk mod yang telah anda hidupkan: jangan ganggu, lampu malam, [peringatan](09-reminders.md) yang beratur, rakaman skrin yang aktif, dan kekal terjaga, serta amaran semasa sudo tanpa kata laluan dihidupkan atau seseorang disambungkan ke sesi jauh. Glif ini menyala apabila mod itu aktif dan selain itu tidak mengganggu — hover betul-betul di sebelahnya, di tempat glif tidak aktif itu akan berada, untuk mengintip glif tersebut. Mengklik penunjuk menogol mod itu. Satu lagi hanya status: sesi jauh menyala merah semasa seseorang disambungkan ke mesin ini melalui gliff.

Jika anda lebih suka glif ini sentiasa kelihatan, tetapkan `alwaysShow` kepada `true` pada widget. Dan jika anda hanya mengambil berat tentang beberapa antaranya, senaraikan yang anda mahu dalam `items`: `["Dnd", "Reminder", "NightLight"]`. Anda boleh mempunyai lebih daripada satu widget penunjuk, jadi bahagian yang berbeza boleh menunjukkan subset yang berbeza.

## Menyusun semula bar

Bar ini mengkonfigurasi dirinya sendiri. Anda tidak perlu membuka fail konfigurasi untuk mengalihkan benda.

Pegang tompok kosong bar di sekitar bahagian tengah dan seretnya ke arah tepi skrin lain, dan bar akan berpindah ke sana — kiri, kanan, atas, atau bawah semuanya berfungsi, dan setiap widget menyesuaikan diri (bar menegak kembali kepada bentuk ikon sahaja yang padat). Klik-dan-tahan memulakan seretan yang sama. Klik dua kali dengan butang kiri pada ruang kosong yang sama untuk mengitar latar belakang bar daripada jernih kepada berkaca kepada legap. Dan seret mana-mana widget untuk menyusunnya semula atau mencampakkannya ke bahagian lain; widget lain akan menggelongsor berjauhan untuk memberi ruang di tempat ia akan mendarat.

Bahagian tengah bar ialah sebuah kotak: apa sahaja di dalamnya kekal berpusat sebagai satu kumpulan, dan widget di kedua-dua belahnya tergantung pada tepinya. Semasa anda menyeret widget, kotak itu muncul sebagai garis luar, atau garisan merentasi bar apabila ia kosong, dan anda boleh menjatuhkan widget ke dalamnya atau di sebelahnya. Apabila jatuhan akan mendarat di dalam kotak, kotak itu membesar untuk menerima widget tersebut.

Widget yang anda mahu ada di sekitar tetapi tidak sentiasa dalam pandangan boleh masuk ke laci tray: seretnya ke tray, dan laci akan terbuka untuk menerimanya. Ia duduk di sana selepas ikon aplikasi, muncul setiap kali laci muncul, dan mengekalkan lacinya terbuka semasa panelnya dibuka. Seretnya semula keluar ke bar untuk meletakkannya kembali.

Jika anda lebih suka memilih daripada menu, **Appearance → Menu Bar** mempunyai kedudukannya, dan **Bar Background** memilih cara bar dilukis: **Opaque Bar**, **Glassy Bar** (lut sinar, dengan apa yang di belakangnya dikaburkan), atau **Clear Bar**.

Perkara yang sama mempunyai perintah, iaitu apa yang anda mahu untuk persediaan [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Untuk menambah atau membuang widget sepenuhnya, gunakan perintah plugin. `omarchy plugin list` mencetak setiap widget yang diketahui oleh shell berserta id-nya, dan kemudian:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Menyembunyikan bar

`Super + Shift + Space` menogol bar menjadi mati dan hidup semula tanpa membunuh shell — panel dan hotkey terus berfungsi, anda hanya mendapat kembali piksel tersebut. Ia juga ada dalam menu di bawah **Appearance → Menu Bar → Hide Bar**.

## Fail konfigurasi

Kesemuanya disimpan dalam `~/.config/omarchy/shell.json`, di bawah kunci `bar`. Berikut ialah versi yang dipangkas:

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

Setiap widget ialah satu entri dalam salah satu daripada lima tatasusunan susun atur, dan tetapannya terletak sebaris pada entri itu — tiada fail tetapan berasingan dan tiada sub-objek `config`. `format`, `formatAlt` (yang dikitar oleh klik kanan), dan `verticalFormat` pada jam semuanya berada betul-betul di sana pada `{ "id": "omarchy.clock" }`.

`center` ialah kotak di tengah bar: semua di dalamnya dipusatkan pada skrin sebagai satu kumpulan. `centerBegin` dan `centerEnd` tergantung pada kedua-dua belah kotak, begitulah jam kekal betul-betul di tengah walaupun cuaca dan lencana kemas kini datang dan pergi. Letakkan lebih daripada satu widget dalam `center` dan mereka akan dipusatkan bersama; biarkan ia kosong dan `centerBegin` serta `centerEnd` bertemu di tengah bar.

Satu peraturan yang berbaloi untuk dihayati: **setelah anda mempunyai `shell.json` anda sendiri, ia menjadi kanonikal**. Sehingga anda menyesuaikan apa-apa, shell membaca fail lalai Omarchy. Sebaik sahaja anda menyeret widget, menjalankan `omarchy bar`, atau mengedit fail itu sendiri, anda memilikinya — tiada cantuman mendalam, jadi widget lalai baharu dalam keluaran Omarchy akan datang tidak akan muncul pada bar anda secara automatik. `omarchy bar defaults` meletakkan semula susun atur yang disertakan setiap kali anda mahukan permulaan yang bersih.

Fail yang sama juga menyimpan pemasaan melahu anda pada aras atas, di luar kunci `bar`: `idle.screensaver` dan `idle.lock`, kedua-duanya dalam saat sejak anda menjadi melahu. Jadi penyelamat skrin lalai bermula pada 150 saat dan kunci pada 300.
