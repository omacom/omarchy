# Bar Atas

Jalur di sepanjang bahagian atas skrin anda ialah bar Omarchy. Ia bukan bar status yang ditampal kemudian tetapi sebahagian daripada shell Omarchy, proses Quickshell tunggal yang berjalan lama yang turut melukis menu, pemberitahuan, popup OSD, dan skrin kunci. Sebab itulah ia bertema dengan sempurna bersama semua yang lain dan sebab sesuatu panel dibuka serta-merta dan bukannya melancarkan aplikasi baharu.

Ia juga satu-satunya bahagian desktop yang sentiasa berada di skrin, jadi berbaloi untuk mengetahui fungsi semua glif kecil itu.

## Apa yang ada padanya secara lalai

Bar ini mempunyai tiga bahagian. Di sebelah kiri terletak logo Omarchy (pelancar menu) dan penunjuk ruang kerja. Di tengah anda mendapat penunjuk status, jam, Elsewhen (jam dunia), cuaca, dan lencana kemas kini Omarchy. Di sebelah kanan: dulang sistem, susun atur papan kekunci (apabila lebih daripada satu dikonfigurasikan), ejen, bluetooth, rangkaian, audio, paparan, dan kuasa.

Beberapa daripadanya hanya muncul apabila mereka mempunyai sesuatu untuk disampaikan. Susun atur papan kekunci hanya muncul jika anda telah mengkonfigurasikan lebih daripada satu susun atur. Lencana kemas kini hanya muncul apabila ada kemas kini Omarchy yang menunggu. Dan ikon ejen muncul pada kali pertama Omarchy menemui penggunaan pengekodan AI pada mesin (lihat [AI](17-ai.md)).

## Mengklik di sana sini

Hampir setiap widget melakukan sesuatu pada klik kiri, kanan, dan tengah, dan beberapa bertindak balas terhadap skrol. Ini bahagian yang orang terlepas — butang kanan dan tengah ialah tempat banyak perkara baik tersembunyi.

| Widget | Kiri | Kanan | Tengah / skrol |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Terminal baharu | — |
| Ruang kerja | Fokus ruang kerja itu pada monitor ini | — | Skrol: ruang kerja seterusnya/sebelumnya |
| Jam | Popup kalendar | Kitar format label | Tengah: pemilih zon waktu |
| Cuaca | Popup ramalan | Cuaca penuh sebagai pemberitahuan | Tengah: muat semula |
| Audio | Panel audio | Redam | Tengah: panel · skrol: volum |
| Mikrofon | Redam mikrofon | — | Tengah: panel audio · skrol: volum input |
| Rangkaian | Panel rangkaian | — | — |
| Bluetooth | Panel bluetooth | Togol radio | — |
| Paparan | Panel paparan | — | Skrol: kecerahan |
| Kuasa | Panel kuasa | Togol peratusan bateri | — |
| Media | Main/jeda | Popup seni kulit | Tengah: seterusnya · skrol: sebelumnya/seterusnya |
| Ejen | Panel ejen | Lancarkan ejen anda | Tengah: langganan seterusnya |
| Dulang | Layangkan untuk mendedahkan laci | Klik kanan pada chevron untuk mengurus | — |
| Kemas kini Omarchy | Jalankan kemas kini | — | — |

Tidak semua dalam jadual itu ada pada bar anda dari kotak. Widget media (MPRIS sedang dimainkan, dengan trek dan artis yang menatal) dan widget mikrofon kedua-duanya terbina dalam tetapi dimatikan secara lalai — tambahkannya jika anda mahukannya, seperti yang diterangkan di bawah.

## Panel-panel

Mengklik ikon bar membuka panel, iaitu popup sebenar dengan peluncur, senarai, dan navigasi papan kekunci dan bukannya tooltip. Setiap satu juga mempunyai kekunci pintas, jadi anda tidak perlu menyasar glif 16 piksel:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + 1-9` | Toggle the nth panel in the right section |

Panel bukan sekadar paparan bacaan. Di situlah anda benar-benar melakukan perkara itu:

- **Audio** mempunyai peluncur volum utama, pemilih peranti output, dan pengadun per aplikasi, jadi anda boleh memperlahankan satu tab pelayar itu tanpa menyentuh semua yang lain.
- **Network** mengimbas Wi-Fi, menunjukkan kekuatan isyarat, menyambung, dan membenarkan anda memilih penyedia DNS.
- **Bluetooth** menyenaraikan peranti anda dengan sambung/putus dan paras bateri.
- **Power** menunjukkan statistik bateri, menukar profil kuasa (ia mengingati pilihan berasingan untuk bateri dan AC), dan mencetak sedikit maklumat sistem.
- **Display** membawa peluncur kecerahan, saiz teks, pratetap penskalaan monitor, dan — apabila anda mempunyai lebih daripada satu skrin — kawalan per monitor. Lihat [monitor](33-monitors.md) untuk cerita yang lebih mendalam.
- **Clock** membuka grid bulan dengan nombor minggu ISO dan langkah bulan.
- **World clock** mengekalkan satu baris per bandar, dengan cuacanya dan bagaimana perjalanan harinya. Carian menemui pekan serta zon waktu, jadi Fort Lauderdale ialah Fort Lauderdale dan bukan New York. Jika baris di bahagian atas menamakan bandar yang salah, klik padanya dan beritahu di mana anda berada; pilih tempat di zon waktu lain dan jam sistem turut berpindah ke sana, yang berguna apabila anda melancong. Layangkan pada bandar dan klik butang orang untuk memberitahu siapa yang tinggal di sana — nama biasa, atau pemegang GitHub `@` untuk membawa wajah mereka bersama.

Setiap panel menerima papan kekunci serta tetikus: anak panah bergerak, Return mengaktifkan, Tab melangkah ke panel berjiran, dan Escape menutup.

`Super + Ctrl + 1-9` mengira panel dari kiri ke kanan dalam bahagian kanan, melangkau dulang kerana ia tiada panel sendiri. Jadi nombor itu sepadan dengan ikon yang anda akan halakan.

### Tailscale dan Dropbox

Dua lagi widget muncul pada bar hanya sebaik anda memasang perkhidmatan yang sepadan daripada **Install → Service**, dan kedua-duanya berbaloi diketahui kerana ia melakukan lebih daripada melaporkan status.

Panel **Tailscale** menyambung dan memutuskan tailnet, bertukar antara akaun, dan memilih nod keluar (mesin anda sendiri dan wilayah Mullvad kedua-duanya muncul dalam senarai itu). Ia juga melayari mesin anda — dan dengan satu dipilih, `s` menghantar fail kepadanya melalui Taildrop, iaitu cara terpantas untuk memindahkan fail ke telefon atau laptop lain anda. `c` menyalin IP mesin, `n` namanya, dan `d` nama DNS penuhnya. Ada juga butang hantar pada setiap baris mesin, jika anda lebih suka mengklik. Perkara yang sama dari terminal ialah `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** mengendalikan log masuk, menunjukkan berapa banyak storan yang telah anda gunakan, dan menyenaraikan fail yang baru disegerakkan.

Mengalih keluar mana-mana perkhidmatan akan mengeluarkan widgetnya semula dari bar.

## Penunjuk

Kluster kecil di tengah ialah widget penunjuk. Ini ialah glif status untuk mod yang telah anda hidupkan: jangan ganggu, lampu malam, [peringatan](09-reminders.md) yang beratur, rakaman skrin aktif, kekal terjaga, dan [imlak](11-text-extraction-dictation.md). Ia menyala apabila mod aktif dan selain itu tidak mengganggu — layangkan di mana-mana pada bar untuk mengintip yang tidak aktif. Mengklik penunjuk menogol mod itu. Satu lagi hanya status: sesi jauh menyala merah semasa seseorang disambungkan ke mesin ini melalui gliff.

Jika anda lebih suka ia sentiasa kelihatan, tetapkan `alwaysShow` kepada `true` pada widget. Dan jika anda hanya mengambil berat tentang sebahagian daripadanya, senaraikan yang anda mahu dalam `items`: `["Dnd", "Reminder", "NightLight"]`. Anda boleh mempunyai lebih daripada satu widget penunjuk, jadi bahagian berbeza boleh menunjukkan subset berbeza.

## Menyusun semula bar

Bar mengkonfigurasikan dirinya sendiri. Anda tidak perlu membuka fail konfigurasi untuk mengalihkan sesuatu.

Ambil tompok kosong bar di sekitar tengah dan seret ke arah tepi skrin lain, dan bar berpindah ke sana — kiri, kanan, atas, atau bawah semuanya berfungsi, dan setiap widget menyesuaikan diri (bar menegak kembali kepada bentuk padat ikon sahaja). Klik dan tahan memulakan seretan yang sama. Dwiklik kiri ruang kosong yang sama untuk mengitar latar belakang bar daripada jernih kepada berkaca kepada legap. Dan seret mana-mana widget untuk menyusunnya semula atau campakkannya ke bahagian lain; widget lain meluncur berjauhan untuk memberi ruang di tempat ia akan mendarat.

Bahagian tengah bar ialah sebuah kotak: apa sahaja di dalamnya kekal berpusat sebagai satu kumpulan, dan widget di kedua-dua sisinya tergantung pada tepinya. Semasa anda menyeret widget kotak itu kelihatan sebagai garis luar, atau garisan merentasi bar apabila ia kosong, dan anda boleh menjatuhkan ke dalamnya atau di sisinya. Apabila jatuhan akan mendarat dalam kotak, kotak membesar untuk mengambil widget itu masuk.

Widget yang anda mahu ada berdekatan tetapi tidak sentiasa kelihatan boleh masuk ke laci dulang: seret ke atas dulang, dan laci terbuka untuk mengambilnya. Ia duduk di sana selepas ikon aplikasi, muncul setiap kali laci muncul, dan memastikan lacinya terbuka semasa panelnya naik. Seret kembali keluar ke bar untuk meletakkannya semula.

Jika anda lebih suka memilih daripada menu, **Appearance → Menu Bar** mempunyai kedudukan, dan **Bar Background** memilih cara bar dilukis: **Opaque Bar**, **Glassy Bar** (lut sinar, dengan apa di belakangnya dikaburkan), atau **Clear Bar**.

Perkara yang sama mempunyai arahan, iaitu apa yang anda mahu untuk persediaan [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Untuk menambah atau mengalih keluar widget sepenuhnya, gunakan arahan plugin. `omarchy plugin list` mencetak setiap widget yang diketahui shell dengan idnya, dan kemudian:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Menyembunyikan bar

`Super + Shift + Space` menogol bar mati dan hidup semula tanpa membunuh shell — panel dan kekunci pintas terus berfungsi, anda hanya mendapat kembali piksel. Ia juga ada dalam menu di bawah **Appearance → Menu Bar → Hide Bar**.

## Fail konfigurasi

Semuanya disimpan dalam `~/.config/omarchy/shell.json`, di bawah kunci `bar`. Berikut versi yang dipangkas:

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

Setiap widget ialah satu entri dalam salah satu daripada lima tatasusunan susun atur, dan tetapannya duduk sebaris pada entri itu — tiada fail tetapan berasingan dan tiada sub-objek `config`. `format`, `formatAlt` (apa yang klik kanan kitar kepadanya), dan `verticalFormat` jam semuanya tinggal di sana pada `{ "id": "omarchy.clock" }`.

`center` ialah kotak di tengah bar: semua di dalamnya berpusat pada skrin sebagai satu kumpulan. `centerBegin` dan `centerEnd` tergantung pada kedua-dua sisi kotak, iaitu cara jam kekal betul-betul di tengah walaupun cuaca dan lencana kemas kini datang dan pergi. Letak lebih daripada satu widget dalam `center` dan ia berpusat bersama; biarkan kosong dan `centerBegin` dan `centerEnd` bertemu di tengah bar.

Satu peraturan yang berbaloi dihayati: **sebaik sahaja anda mempunyai `shell.json` anda sendiri, ia kanonik**. Sehingga anda menyesuaikan apa-apa, shell membaca fail lalai Omarchy. Sebaik sahaja anda menyeret widget, menjalankan `omarchy bar`, atau mengedit fail sendiri, anda memilikinya — tiada gabungan mendalam, jadi widget lalai baharu dalam keluaran Omarchy akan datang tidak akan muncul pada bar anda secara automatik. `omarchy bar defaults` meletakkan semula susun atur yang dihantar bila-bila masa anda mahukan permulaan bersih.

Fail yang sama juga menyimpan pemasaan melahu anda di peringkat atas, di luar kunci `bar`: `idle.screensaver` dan `idle.lock`, kedua-duanya dalam saat sejak anda melahu. Jadi penyelamat skrin lalai bermula pada 150 saat dan kunci pada 300.
