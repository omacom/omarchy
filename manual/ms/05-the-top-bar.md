# Bar Atas

Jalur di sepanjang bahagian atas skrin anda ialah bar Omarchy. Ia bukan bar status yang dipasang kemudian tetapi sebahagian daripada shell Omarchy, proses Quickshell tunggal yang berjalan lama yang turut melukis menu, pemberitahuan, popup OSD, dan skrin kunci. Sebab itulah ia bertema dengan sempurna bersama semua yang lain dan sebab itulah panel terbuka serta-merta dan bukannya melancarkan app baharu.

Ia juga satu-satunya bahagian desktop yang sentiasa berada pada skrin, jadi berbaloi untuk mengetahui apa yang dilakukan oleh semua glif kecil itu.

## Apa yang ada padanya secara lalai

Bar ini mempunyai tiga bahagian. Di sebelah kiri terletak logo Omarchy (pelancar menu) dan penunjuk ruang kerja. Di tengah anda mendapat penunjuk status, jam, Elsewhen (jam dunia), cuaca, dan lencana kemas kini Omarchy. Di sebelah kanan: dulang sistem, susun atur papan kekunci (apabila lebih daripada satu dikonfigurasi), ejen, Bluetooth, rangkaian, audio, paparan, dan kuasa.

Beberapa daripadanya hanya muncul apabila mereka mempunyai sesuatu untuk disampaikan. Susun atur papan kekunci hanya muncul jika anda telah mengkonfigurasi lebih daripada satu susun atur. Lencana kemas kini hanya muncul apabila terdapat kemas kini Omarchy yang menunggu. Dan ikon ejen muncul pada kali pertama Omarchy menemui penggunaan pengekodan AI pada mesin itu (lihat [AI](17-ai.md)).

## Mengklik

Hampir setiap widget melakukan sesuatu pada klik kiri, kanan, dan tengah, dan beberapa widget bertindak balas terhadap tatalan. Inilah bahagian yang orang terlepas pandang — butang kanan dan tengah ialah tempat banyak perkara menarik disembunyikan.

| Widget | Kiri | Kanan | Tengah / tatal |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Terminal baharu | — |
| Ruang kerja | Fokuskan ruang kerja itu pada monitor ini | — | Tatal: ruang kerja seterusnya/sebelumnya |
| Jam | Popup kalendar | Kitarkan format label | Tengah: pemilih zon waktu |
| Cuaca | Popup ramalan | Cuaca penuh sebagai pemberitahuan | Tengah: muat semula |
| Audio | Panel audio | Senyap | Tengah: panel · tatal: volum |
| Mikrofon | Senyapkan mikrofon | — | Tengah: panel audio · tatal: volum input |
| Rangkaian | Panel rangkaian | — | — |
| Bluetooth | Panel Bluetooth | Togol radio | — |
| Paparan | Panel paparan | — | Tatal: kecerahan |
| Kuasa | Panel kuasa | Togol peratusan bateri | — |
| Media | Main/jeda | Popup kulit album | Tengah: seterusnya · tatal: sebelumnya/seterusnya |
| Ejen | Panel ejen | Lancarkan ejen anda | Tengah: langganan seterusnya |
| Dulang | Hover untuk mendedahkan laci | Klik kanan pada chevron untuk mengurus | — |
| Kemas kini Omarchy | Jalankan kemas kini | — | — |

Tidak semua dalam jadual itu berada pada bar anda dari awal. Widget media (MPRIS sedang dimainkan, dengan trek dan artis yang menatal) dan widget mikrofon kedua-duanya terbina dalam tetapi dimatikan secara lalai — tambahkannya jika anda mahukannya, seperti yang diterangkan di bawah.

## Panel

Mengklik ikon bar membuka panel, iaitu popup sebenar dengan peluncur, senarai, dan navigasi papan kekunci dan bukannya tooltip. Setiap panel juga mempunyai kekunci pintas, jadi anda tidak perlu menyasar glif 16 piksel:

| Kekunci pintas | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Rangkaian |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Paparan |
| `Super + Ctrl + P` | Kuasa |
| `Super + Ctrl + Alt + D` | Kalendar |
| `Super + Ctrl + Alt + E` | Jam dunia |
| `Super + Ctrl + 1-9` | Togol panel ke-n dalam bahagian kanan |

Panel ini bukan sekadar paparan bacaan. Di sinilah anda benar-benar melakukan perkara itu:

- **Audio** mempunyai peluncur volum utama, pemilih peranti output, dan pengadun per apl, jadi anda boleh memperlahankan tab pelayar yang satu itu tanpa menyentuh semua yang lain.
- **Rangkaian** mengimbas Wi-Fi, menunjukkan kekuatan isyarat, menyambung, dan membolehkan anda memilih penyedia DNS.
- **Bluetooth** menyenaraikan peranti anda dengan sambung/putus dan tahap bateri.
- **Kuasa** menunjukkan statistik bateri, menukar profil kuasa (ia mengingati pilihan berasingan untuk bateri dan AC), dan mencetak beberapa maklumat sistem.
- **Paparan** membawa peluncur kecerahan, saiz teks, pratetap penskalaan monitor, dan — apabila anda mempunyai lebih daripada satu skrin — kawalan per monitor. Lihat [monitor](33-monitors.md) untuk kisah yang lebih mendalam.
- **Jam** membuka grid bulan dengan nombor minggu ISO dan langkah bulan.
- **Jam dunia** mengekalkan satu baris bagi setiap bandar, dengan cuacanya dan bagaimana harinya berjalan. Carian menemui pekan serta zon waktu, jadi Fort Lauderdale ialah Fort Lauderdale dan bukan New York. Jika baris di bahagian atas menamakan bandar yang salah, klik baris itu dan nyatakan di mana anda berada; pilih tempat pada zon waktu lain dan jam sistem turut berpindah ke sana, yang berguna apabila anda melancong. Hover pada sebuah bandar dan klik butang orang untuk menyatakan siapa yang tinggal di sana — nama biasa, atau pemegang GitHub `@` untuk membawa wajah mereka bersama.

Setiap panel menerima papan kekunci serta tetikus: anak panah bergerak, Return mengaktifkan, Tab melangkah ke panel berjiran, dan Escape menutup.

`Super + Ctrl + 1-9` mengira panel dari kiri ke kanan dalam bahagian kanan, melangkau dulang kerana ia tidak mempunyai panelnya sendiri. Jadi nombor itu sepadan dengan ikon yang akan anda tuju.

### Tailscale dan Dropbox

Dua lagi widget muncul pada bar hanya sebaik sahaja anda memasang perkhidmatan yang sepadan dari **Pasang → Perkhidmatan**, dan kedua-duanya berbaloi untuk diketahui kerana ia melakukan lebih daripada melaporkan status.

Panel **Tailscale** menyambung dan memutuskan tailnet, bertukar antara akaun, dan memilih nod keluar (mesin anda sendiri dan wilayah Mullvad kedua-duanya muncul dalam senarai itu). Ia juga melayari mesin anda — dan dengan satu mesin dipilih, `s` menghantar fail kepadanya melalui Taildrop, yang merupakan cara terpantas untuk memindahkan fail ke telefon anda atau komputer riba lain. `c` menyalin IP mesin itu, `n` namanya, dan `d` nama DNS penuhnya. Terdapat juga butang hantar pada setiap baris mesin, jika anda lebih suka mengklik. Perkara yang sama dari terminal ialah `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** mengendalikan log masuk, menunjukkan berapa banyak storan yang telah anda gunakan, dan menyenaraikan fail yang disegerakkan baru-baru ini.

Mengalih keluar mana-mana perkhidmatan akan mengeluarkan widgetnya semula dari bar.

## Penunjuk

Kumpulan kecil di tengah ialah widget penunjuk. Ini ialah glif status untuk mod yang telah anda hidupkan: jangan ganggu, cahaya malam, [peringatan](09-reminders.md) yang beratur, rakaman skrin aktif, kekal terjaga, dan [imlak](11-text-extraction-dictation.md). Ia menyala apabila mod aktif dan sebaliknya tidak mengganggu — hover betul-betul di sebelahnya, di tempat penunjuk yang tidak aktif itu akan berada, untuk mengintipnya. Mengklik penunjuk menogol mod itu. Satu lagi hanya untuk status: sesi jauh menyala merah semasa seseorang disambungkan ke mesin ini melalui gliff.

Jika anda lebih suka ia sentiasa kelihatan, tetapkan `alwaysShow` kepada `true` pada widget itu. Dan jika anda hanya mengambil berat tentang sebahagian daripadanya, senaraikan yang anda mahu dalam `items`: `["Dnd", "Reminder", "NightLight"]`. Anda boleh mempunyai lebih daripada satu widget penunjuk, jadi bahagian yang berbeza boleh menunjukkan subset yang berbeza.

## Menyusun semula bar

Bar ini mengkonfigurasi dirinya sendiri. Anda tidak perlu membuka fail konfigurasi untuk mengalihkan sesuatu.

Ambil kawasan kosong bar di sekitar tengah dan seretnya ke arah tepi skrin lain, dan bar akan berpindah ke sana — kiri, kanan, atas, atau bawah semuanya berfungsi, dan setiap widget menyesuaikan diri (bar menegak kembali kepada bentuk padat yang hanya mempunyai ikon). Klik dan tahan memulakan seretan yang sama. Klik kiri dua kali pada ruang kosong yang sama itu untuk mengitarkan latar belakang bar dari jernih kepada berkaca kepada legap. Dan seret mana-mana widget untuk menyusunnya semula atau mencampakkannya ke bahagian lain; widget lain akan menggelongsor berjauhan untuk memberi ruang di tempat ia akan diletakkan.

Bahagian tengah bar ialah sebuah kotak: apa sahaja yang berada di dalamnya kekal di tengah sebagai satu kumpulan, dan widget di kedua-dua sisinya tergantung pada tepinya. Semasa anda menyeret widget, kotak itu ditunjukkan sebagai garis luar, atau garisan merentasi bar apabila ia kosong, dan anda boleh menjatuhkannya ke dalam kotak itu atau di sebelahnya. Apabila jatuhan akan mendarat di dalam kotak, kotak itu membesar untuk menerima widget itu.

Widget yang anda mahu berada berdekatan tetapi tidak sentiasa dalam pandangan boleh masuk ke dalam laci dulang: seretnya ke atas dulang, dan laci akan terbuka untuk menerimanya. Ia berada di sana selepas ikon app, muncul setiap kali laci muncul, dan memastikan lacinya terbuka semasa panelnya dibuka. Seretnya kembali keluar ke atas bar untuk meletakkannya kembali.

Jika anda lebih suka memilih dari menu, **Penampilan → Bar Menu** mempunyai kedudukan, dan **Latar Belakang Bar** memilih cara bar dilukis: **Bar Legap**, **Bar Berkaca** (lut cahaya, dengan apa yang berada di belakangnya dikaburkan), atau **Bar Jernih**.

Perkara yang sama mempunyai perintah, yang merupakan apa yang anda mahu untuk persediaan [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Untuk menambah atau mengalih keluar widget sepenuhnya, gunakan perintah plugin. `omarchy plugin list` mencetak setiap widget yang diketahui oleh shell dengan idnya, dan kemudian:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Menyembunyikan bar

`Super + Shift + Space` menogol bar supaya dimatikan dan dihidupkan semula tanpa membunuh shell — panel dan kekunci pintas terus berfungsi, anda hanya mendapat semula piksel itu. Ia juga berada dalam menu di bawah **Penampilan → Bar Menu → Sembunyikan Bar**.

## Fail konfigurasi

Semua itu disimpan dalam `~/.config/omarchy/shell.json`, di bawah kekunci `bar`. Berikut ialah versi yang dipangkas:

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

Setiap widget ialah satu entri dalam salah satu daripada lima tatasusunan susun atur, dan tetapannya berada sebaris pada entri itu — tiada fail tetapan berasingan dan tiada sub-objek `config`. `format`, `formatAlt` (apa yang dikitarkan oleh klik kanan), dan `verticalFormat` jam semuanya berada betul-betul di sana pada `{ "id": "omarchy.clock" }`.

`center` ialah kotak di tengah bar: semua yang berada di dalamnya dipusatkan pada skrin sebagai satu kumpulan. `centerBegin` dan `centerEnd` tergantung pada kedua-dua sisi kotak, yang merupakan cara jam kekal betul-betul di tengah walaupun cuaca dan lencana kemas kini datang dan pergi. Letakkan lebih daripada satu widget dalam `center` dan mereka dipusatkan bersama; biarkannya kosong dan `centerBegin` dan `centerEnd` bertemu di tengah bar.

Satu peraturan yang berbaloi untuk dihayati: **sebaik sahaja anda mempunyai `shell.json` anda sendiri, ia adalah kanonik**. Sehingga anda menyesuaikan apa-apa, shell membaca fail lalai Omarchy. Sebaik sahaja anda menyeret widget, menjalankan `omarchy bar`, atau mengedit fail itu sendiri, anda memilikinya — tiada gabungan mendalam, jadi widget lalai baharu dalam keluaran Omarchy akan datang tidak akan muncul pada bar anda secara automatik. `omarchy bar defaults` meletakkan semula susun atur yang dihantar apabila anda mahukan permulaan yang bersih.

Fail yang sama itu juga menyimpan masa melahu anda pada peringkat atas, di luar kekunci `bar`: `idle.screensaver` dan `idle.lock`, kedua-duanya dalam saat sejak anda menjadi melahu. Jadi penyelamat skrin lalai bermula pada 150 saat dan kunci pada 300.
