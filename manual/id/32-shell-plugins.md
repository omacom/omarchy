# Plugin Shell

Desktop Omarchy berjalan sebagai satu proses Quickshell yang berumur panjang yang disebut `omarchy-shell`, dan hampir semua yang kamu lihat di layar adalah plugin di dalamnya. Bilah adalah plugin. Begitu juga panel yang turun darinya, overlay layar penuh seperti pemilih emoji dan manajer papan klip, menu Omarchy itu sendiri, layar kunci, dialog polkit, dan layanan headless yang mengawasi bateraimu dan menghangatkan layarmu di malam hari.

Itu bukan hanya detail implementasi. Ini berarti kamu dapat mematikan bagian desktop, menukarnya, atau menulis milikmu sendiri tanpa menyentuh satu baris pun kode sumber Omarchy.

Plugin pihak pertama disertakan dengan Omarchy dan berada di `$OMARCHY_PATH/shell/plugins/`. Apa pun yang kamu tambahkan sendiri — eksperimenmu sendiri, atau sesuatu yang kamu temukan di GitHub — berada di `~/.config/omarchy/plugins/`. Keduanya ditemukan dengan cara yang sama saat startup, tetapi built-in menerima antarmuka shell tepercaya sementara plugin pihak ketiga menerima antarmuka terbatas yang dicakup ke layanan dan siklus hidup mereka sendiri. Klon dari built-in hanya mempertahankan konfigurasi spesifik sumber dan panggilan UI yang dibutuhkan untuk perilaku asli.

## Melihat apa yang kamu miliki

```
omarchy plugin list
```

Itu mencetak setiap plugin yang ditemukan dengan id-nya, apakah itu diaktifkan, apakah itu pihak pertama atau pihak ketiga, jenisnya, dan nama tampilannya. Tambahkan `--json` jika kamu memasukkannya ke sesuatu yang lain.

Id plugin diberi namespace. Built-in semuanya dimulai dengan `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — dan namespace tersebut dicadangkan, jadi plugin pihak ketiga tidak pernah dapat mengklaimnya.

## Menghidupkan dan mematikan mereka

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Atau gunakan menu: _Pengaturan > Plugins_ memiliki Enable, Disable, Add, Clone, dan Remove, masing-masing dengan pemilih yang hanya menawarkan plugin yang masuk akal untuk tindakan tersebut.

Keadaan yang diaktifkan disimpan di `~/.config/omarchy/shell.json`, dan aturannya sedikit berbeda untuk dua jenis plugin. Plugin pihak ketiga diaktifkan tepat ketika id-nya muncul di suatu tempat dalam berkas tersebut — sebagai entri tata letak bilah, sebagai entri di `plugins[]`, atau sebagai `bar.id`. Plugin pihak pertama yang bukan widget bilah sebaliknya: mereka hidup secara bawaan dan hanya mati dengan dicantumkan di `disabledPlugins[]`.

Plugin bilah penuh tidak memiliki keadaan mati sama sekali. Selalu ada tepat satu bilah, jadi kamu menggantinya dengan mengaktifkan yang lain. Penempatan widget bilah dibahas di [bilah atas](05-the-top-bar.md).

## Menambahkan plugin dari git

Plugin pihak ketiga hanyalah repo git dengan `manifest.json` di akarnya.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Sebelum melakukan apa pun, itu memberitahumu dengan jelas bahwa plugin berjalan sebagai kode arbitrer tanpa sandbox di dalam proses shell-mu yang berumur panjang, menunjukkan URL kepadamu, dan memintamu mengonfirmasi. Anggap serius. Antarmuka plugin pihak ketiga tidak secara langsung mengekspos layanan autentikasi, dan bilah pengganti hanya menerima kemampuan terbatas untuk UI non-autentikasi yang dikonfigurasi. Plugin visual tetap berbagi adegan QML shell dan dapat menelusuri objek induk biasa, sementara semua kode plugin berjalan dengan semua yang dapat dijangkau akun penggunamu. Keadaan autentikasi dilindungi secara terpisah dengan menjaga layanan tersebut di luar grafik objek host yang dapat dijangkau. Hanya tambahkan repo yang bersedia kamu jalankan, dan baca sebelum kamu mengaktifkannya.

Bilah pengganti dapat merender widget yang terpasang, tetapi widget pihak ketiga yang didukung layanan mungkin memiliki fungsionalitas berkurang di sana karena bilah tidak diizinkan meminta objek layanan langsung plugin lain. Kembali ke `omarchy.bar` bawaan jika widget semacam itu membutuhkan layanan pendampingnya.

Kemudian itu mengklon repo ke direktori staging, memvalidasi manifest, menolak pemasangan jika plugin lain sudah mengklaim id tersebut, dan memindahkannya ke `~/.config/omarchy/plugins/<id>/`. Tanpa `--enable` itu menanyakan apakah kamu menginginkannya hidup sekarang, dan kamu dapat mengatakan tidak dan membaca kodenya terlebih dahulu. Itu tidak pernah menjalankan apa pun dari plugin, tidak pernah mengeksekusi hook pemasangan, dan tidak pernah meminta sudo — itu mengklon berkas, memeriksa manifest, dan membalik bit melalui IPC.

Pembaruan adalah tarikan fast-forward dari checkout yang sama tersebut:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Tanpa id itu memperbarui setiap plugin yang dikelola git yang kamu miliki. Itu menunjukkan diff kepadamu sebelum menerapkannya, menolak memperbarui jika kamu punya perubahan lokal yang tidak dapat di-fast-forward melewatinya, dan mengembalikan jika revisi baru gagal validasi.

```
omarchy plugin remove acme.weather
```

Penghapusan menonaktifkan plugin terlebih dahulu, kemudian menghapusnya jika itu adalah checkout git (repo masih di hulu) atau membatalkan tautannya jika itu adalah symlink. Folder plugin buatan tangan tanpa repo git dipindahkan ke cadangan berstempel waktu di dalam direktori plugin alih-alih dihapus langsung.

## Mengklon built-in untuk memodifikasinya

Ini adalah bagian favorit saya. Jika kamu ingin mengubah cara widget bawaan berperilaku, jangan edit berkas di bawah `$OMARCHY_PATH` — itu milik paket dan pembaruan berikutnya akan menimpanya. Klon itu sebagai gantinya:

```
omarchy plugin clone omarchy.clock
```

Itu menyalin seluruh plugin ke `~/.config/omarchy/plugins/dhh.clock` (nama penggunamu, bukan milikku), mengganti namanya menjadi "My Clock", mengaktifkannya, dan mengalihkan shell dari bawaan ke salinanmu — mempertahankan posisi dan pengaturan widget bilah yang ada. Tambahkan `--edit` untuk membuka direktori baru di `$EDITOR`-mu segera, yang merupakan apa yang dilakukan _Pengaturan > Plugins > Clone Plugin_ pada menu untukmu.

Awalan nama pengguna membuat id klonmu tetap milikmu, jadi membagikannya tidak bertabrakan dengan siapa pun. Panggilan yang dilakukan ke id bawaan asli diarahkan ke klonmu, jadi tidak ada yang merujuk ke `omarchy.clock` perlu diperbarui. Dan jika kamu membuat kekacauan, `omarchy plugin remove dhh.clock` mengembalikan bawaan.

Menyimpan berkas di mana pun di bawah `~/.config/omarchy/plugins/` memuat ulang kode plugin secara otomatis, jadi kamu dapat membiarkan editor terbuka dan melihat perubahanmu mendarat.

## Menulis milikmu sendiri

Plugin adalah direktori dengan `manifest.json` dan beberapa QML. Manifest mendeklarasikan `schemaVersion: 1`, `id`, `name`, `version`, satu atau lebih `kinds`, dan objek `entryPoints` yang menunjuk ke berkas QML untuk setiap jenis:

| Kind | What it is |
|------|------------|
| `bar-widget` | Komponen yang dapat dimasukkan bilah aktif ke dalam suatu bagian |
| `panel` | Jendela melayang yang persisten atau dipanggil |
| `overlay` | Overlay layar penuh |
| `menu` | Permukaan menu yang dipanggil |
| `service` | Singleton headless tanpa UI |
| `bar` | Bilah penuh yang menggantikan yang bawaan |

Plugin dapat mendeklarasikan beberapa jenis sekaligus — plugin media adalah `service` dan `bar-widget`. Widget bilah mendapatkan blok `barWidget` ekstra dengan nama tampilan, kategori, `defaultSection` opsional, dan `allowMultiple`, yang mengatakan apakah masuk akal untuk memiliki lebih dari satu di bilah. Sebagian besar widget mengaturnya ke `false`; spacer dan indikator mengaturnya ke `true`.

Sebelum kamu menerbitkan apa pun, periksa itu:

```
omarchy plugin validate ./my-plugin
```

Itu menjalankan pemeriksaan yang sama yang dilakukan shell saat pemuatan: versi skema, bidang yang diperlukan, id yang tidak dicadangkan, titik masuk yang merupakan jalur relatif aman dan benar-benar ada, titik masuk untuk setiap jenis yang kamu klaim, dan tidak ada symlink di mana pun di dalam folder.

Untuk pengembangan plugin, lihat [referensi shell](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) dan [katalog plugin pihak pertama](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Membagikan milikmu dengan dunia

Setelah kamu membuat sesuatu yang kamu sukai, taruh di repo git publik. Itulah seluruh mekanisme distribusi — siapa pun kemudian dapat menjalankan `omarchy plugin add` terhadap URL-mu dan menjalankannya dalam hitungan detik.

Untuk membantu orang benar-benar menemukannya, daftarkan di [plugins.omarchy.org](https://plugins.omarchy.org). Itulah pasar untuk plugin shell Omarchy, dan itu adalah tempat pertama untuk melihat saat kamu bertanya-tanya apakah seseorang telah membuat widget yang akan kamu tulis. Telusuri sebelum kamu memulai!
