# Plugin Shell

Desktop Omarchy berjalan sebagai satu proses Quickshell jangka panjang yang dipanggil `omarchy-shell`, dan hampir semua yang anda lihat pada skrin ialah plugin di dalamnya. Bar ialah plugin. Begitu juga panel yang jatuh daripadanya, tindihan skrin penuh seperti pemilih emoji dan pengurus papan keratan, menu Omarchy itu sendiri, skrin kunci, dialog polkit, dan perkhidmatan tanpa kepala yang memerhatikan bateri anda dan memanaskan skrin anda pada waktu malam.

Itu bukan hanya perincian pelaksanaan. Ia bermakna anda boleh mematikan bahagian desktop, menukarnya, atau menulis sendiri tanpa menyentuh sebaris pun kod sumber Omarchy.

Plugin pihak pertama dihantar bersama Omarchy dan berada dalam `$OMARCHY_PATH/shell/plugins/`. Apa-apa yang anda tambah sendiri — eksperimen anda sendiri, atau sesuatu yang anda jumpa di GitHub — berada dalam `~/.config/omarchy/plugins/`. Kedua-dua ditemui dengan cara yang sama semasa permulaan, tetapi terbina dalam menerima antara muka shell yang dipercayai manakala plugin pihak ketiga menerima antara muka terhad yang discopkan kepada perkhidmatan dan kitaran hayatnya sendiri. Klon terbina dalam hanya menyimpan konfigurasi khusus sumber dan panggilan UI yang diperlukan untuk tingkah laku asal.

## Melihat apa yang anda ada

```
omarchy plugin list
```

Itu mencetak setiap plugin yang ditemui dengan id-nya, sama ada didayakan, sama ada pihak pertama atau pihak ketiga, jenisnya, dan nama paparannya. Tambah `--json` jika anda mahu menyerahkannya kepada sesuatu yang lain.

Id plugin ber-ruang nama. Terbina dalam semuanya bermula dengan `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — dan ruang nama itu dikhaskan, jadi plugin pihak ketiga tidak boleh menuntutnya.

## Mendayakan dan melumpuhkannya

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Atau gunakan menu: _Persediaan > Plugin_ ada Dayakan, Lumpuhkan, Tambah, Klon, dan Buang, masing-masing dengan pemilih yang hanya menawarkan plugin yang masuk akal untuk tindakan itu.

Keadaan didayakan disimpan dalam `~/.config/omarchy/shell.json`, dan peraturannya berbeza sedikit untuk kedua-dua jenis plugin. Plugin pihak ketiga didayakan tepat apabila id-nya muncul di suatu tempat dalam fail itu — sebagai entri susun atur bar, sebagai entri dalam `plugins[]`, atau sebagai `bar.id`. Plugin pihak pertama yang bukan widget bar adalah sebaliknya: ia didayakan secara lalai dan hanya dimatikan dengan disenaraikan dalam `disabledPlugins[]`.

Plugin bar penuh langsung tiada keadaan mati. Sentiasa ada tepat satu bar, jadi anda menggantikannya dengan mendayakan yang lain. Penempatan widget bar diliputi dalam [bar atas](05-the-top-bar.md).

## Menambah plugin daripada git

Plugin pihak ketiga hanyalah repo git dengan `manifest.json` pada akarnya.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Sebelum ia melakukan apa-apa, ia memberitahu anda secara terang bahawa plugin berjalan sebagai kod arbitari tanpa kotak pasir di dalam proses shell jangka panjang anda, menunjukkan URL kepada anda, dan meminta anda mengesahkan. Ambil ini dengan serius. Antara muka plugin pihak ketiga tidak mendedahkan perkhidmatan pengesahan secara langsung, dan bar pengganti hanya menerima keupayaan terhad untuk UI bukan pengesahan yang dikonfigurasikan. Plugin visual masih berkongsi scene QML shell dan boleh berjalan merentasi objek induk biasa, manakala semua kod plugin berjalan dengan semua yang boleh dicapai oleh akaun pengguna anda. Keadaan pengesahan dilindungi secara berasingan dengan mengekalkan perkhidmatan itu di luar graf objek hos yang boleh dicapai. Tambah hanya repo yang anda sanggup jalankan, dan bacanya sebelum anda mendayakannya.

Bar pengganti boleh memaparkan widget yang dipasang, tetapi widget pihak ketiga yang disandarkan perkhidmatan mungkin mempunyai fungsi yang dikurangkan di sana kerana bar tidak dibenarkan meminta objek perkhidmatan sebenar plugin lain. Tukar semula kepada `omarchy.bar` terbina dalam jika widget sedemikian memerlukan perkhidmatan pasangannya.

Kemudian ia mengklon repo ke dalam direktori staging, mengesahkan manifes, menolak pemasangan jika plugin lain sudah menuntut id itu, dan mengalihkannya ke dalam `~/.config/omarchy/plugins/<id>/`. Tanpa `--enable` ia bertanya sama ada anda mahukannya dihidupkan sekarang, dan anda boleh berkata tidak dan pergi membaca kod dahulu. Ia tidak pernah menjalankan apa-apa daripada plugin, tidak pernah melaksanakan hook pasang, dan tidak pernah meminta sudo — ia mengklon fail, menyemak manifes, dan menogol satu bit melalui IPC.

Kemas kini ialah tarikan fast-forward checkout yang sama:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Tanpa id ia mengemas kini setiap plugin yang diurus git yang anda ada. Ia menunjukkan diff kepada anda sebelum menerapkannya, menolak untuk mengemas kini jika anda ada perubahan tempatan yang tidak dapat di-fast-forward melampauinya, dan menggulung semula jika semakan baharu gagal pengesahan.

```
omarchy plugin remove acme.weather
```

Pembuangan melumpuhkan plugin dahulu, kemudian memadamnya jika ia checkout git (repo masih di upstream) atau menyahpautnya jika ia symlink. Folder plugin buatan tangan tanpa repo git dialihkan ke sandaran bercop masa di dalam direktori plugin dan bukannya dipadam terus.

## Mengklon terbina dalam untuk diubah suai

Ini bahagian kegemaran saya. Jika anda mahu mengubah cara widget terbina dalam berfungsi, jangan sunting fail di bawah `$OMARCHY_PATH` — itu milik pakej dan kemas kini seterusnya akan menimpanya. Klonkannya sebaliknya:

```
omarchy plugin clone omarchy.clock
```

Itu menyalin keseluruhan plugin ke dalam `~/.config/omarchy/plugins/dhh.clock` (nama pengguna anda, bukan saya), menamakannya semula kepada "My Clock", mendayakannya, dan menukar shell daripada terbina dalam kepada salinan anda — mengekalkan kedudukan dan tetapan widget bar sedia ada. Tambah `--edit` untuk membuka direktori baharu dalam `$EDITOR` anda serta-merta, yang dilakukan oleh menu _Persediaan > Plugin > Klon Plugin_ untuk anda.

Awalan nama pengguna memastikan id klon anda menjadi milik anda, jadi perkongsiannya tidak bertembung dengan orang lain. Panggilan yang dibuat kepada id terbina dalam asal dihalakan ke klon anda, jadi apa-apa yang merujuk `omarchy.clock` tidak perlu dikemas kini. Dan jika anda membuat kekacauan, `omarchy plugin remove dhh.clock` meletakkan semula terbina dalam.

Menyimpan fail di mana-mana di bawah `~/.config/omarchy/plugins/` memuat semula kod plugin secara automatik, jadi anda boleh membiarkan penyunting terbuka dan menyaksikan perubahan anda dilaksanakan.

## Menulis sendiri

Plugin ialah direktori dengan `manifest.json` dan beberapa QML. Manifes mengisytiharkan `schemaVersion: 1`, `id`, `name`, `version`, satu atau lebih `kinds`, dan objek `entryPoints` yang menunjuk pada fail QML untuk setiap jenis:

| Jenis | Apakah ia |
|------|------------|
| `bar-widget` | Komponen yang boleh dimasukkan oleh bar aktif ke dalam seksyen |
| `panel` | Tetingkap terapung berterusan atau diseru |
| `overlay` | Tindihan skrin penuh |
| `menu` | Permukaan menu yang diseru |
| `service` | Singleton tanpa kepala dengan tiada UI |
| `bar` | Bar penuh yang menggantikan terbina dalam |

Plugin boleh mengisytiharkan beberapa jenis sekaligus — plugin media adalah kedua-dua `service` dan `bar-widget`. Widget bar mendapat blok tambahan `barWidget` dengan nama paparan, kategori, `defaultSection` pilihan, dan `allowMultiple`, yang menyatakan sama ada masuk akal untuk mempunyai lebih daripada satu pada bar. Kebanyakan widget menetapkannya kepada `false`; spacer dan penunjuk menetapkannya kepada `true`.

Sebelum anda menerbitkan apa-apa, semaknya:

```
omarchy plugin validate ./my-plugin
```

Itu menjalankan semakan yang sama yang dilakukan oleh shell semasa muat: versi skema, medan yang diperlukan, id yang tidak dikhaskan, titik masuk yang merupakan laluan relatif selamat dan sebenarnya wujud, titik masuk untuk setiap jenis yang anda tuntut, dan tiada symlink di mana-mana dalam folder.

Untuk pembangunan plugin, lihat [rujukan shell](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) dan [katalog plugin pihak pertama](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Berkongsi milik anda dengan dunia

Setelah anda membuat sesuatu yang anda suka, letakkannya dalam repo git awam. Itulah keseluruhan mekanisme pengedaran — sesiapa sahaja boleh menjalankan `omarchy plugin add` terhadap URL anda dan menjalankannya dalam beberapa saat.

Untuk membantu orang benar-benar mencarinya, senaraikannya di [plugins.omarchy.org](https://plugins.omarchy.org). Itulah pasaran untuk plugin shell Omarchy, dan ia adalah tempat pertama untuk dilihat apabila anda tertanya-tanya sama ada seseorang telah membina widget yang hendak anda tulis. Semaknya sebelum anda bermula!
