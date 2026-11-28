# GUIs

## Files

Files (Folio) adalah pengelola berkas grafis. `Super + Shift + F` membukanya, dan `Super + Shift + Alt + F` membukanya di direktori tempat terminalmu berada, yang menghemat banyak klik. `Ctrl + L` memungkinkanmu mengetikkan sebuah jalur, dan menekan `Space` pada berkas apa pun mempratinjaunya dalam ukuran penuh tanpa membukanya.

Colokkan stik USB atau kartu SD dan ia terpasang secara otomatis, jadi langsung muncul di bilah sisi. Untuk hal yang lebih rumit — memformat drive, memeriksa kesehatan SMART, membuat partisi — jalankan _Disks_ dari peluncur aplikasi (`Super + Space`).

Drive terenkripsi akan meminta kata sandinya saat dicolokkan. Agar satu drive bisa terbuka sendiri, tambahkan keyfile ke dalamnya dengan `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` dan letakkan keyfile itu di `~/.config/omarchy/drive-keys/<UUID>`, dinamai menurut UUID yang dicetak `lsblk -dno UUID /dev/sdX1` untuk partisi terenkripsi tersebut, dan hanya bisa dibaca olehmu (`chmod 600`). Jika keyfile itu hilang atau ditolak, kamu akan diminta memasukkan kata sandi seperti biasa.

Klik dua kali mengikuti pengaturan bawaan yang masuk akal: gambar, video, dan musik dibuka di Omaview, PDF di Document Viewer, Markdown di Omawrite, dan teks biasa di editormu, Plain kecuali kamu memilih yang lain di _Setup > Defaults > Editor_.

## Disktree

Saat drive penuh dan kamu tidak tahu apa yang memakannya, jalankan [Disktree](https://github.com/tobi/disktree) dari peluncur aplikasi (`Super + Space`). Ia menampilkan treemap grafis dari direktori home-mu. Blok yang lebih besar memakan lebih banyak ruang; masuk ke direktori dengan keyboard atau mouse, tandai apa yang harus dibuang, dan tinjau pilihanmu sebelum menghapus apa pun. Jalankan `disktree --disk` untuk memindai seluruh disk.

## Obsidian

[Obsidian](https://obsidian.md/) adalah aplikasi pencatat gratis dan sangat dapat diperluas yang menggunakan berkas Markdown sederhana untuk penyimpanan.

Obsidian gratis untuk semua keperluan, termasuk penggunaan pribadi, komersial, dan nirlaba.

Obsidian juga menawarkan [add-on komersial untuk sinkronisasi](https://obsidian.md/sync) dengan aplikasi seluler di iOS dan Android. (https://obsidian.md/pricing).

Kamu memulai Obsidian dengan `Super + Shift + O`. Untuk menggunakan sinkronisasi tema, kamu harus memilih tema `Omarchy` di pengaturan.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) adalah aplikasi penulisan Markdown Omarchy sendiri yang sangat sederhana. Tanpa vault, tanpa plugin, hanya kamu dan kata-kata.

Kamu memulai Omawrite dengan `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) adalah alat pengedit gambar dasar yang bagus untuk memotong, mengubah ukuran, dan manipulasi dasar lainnya. Jangan harap ini menjadi alternatif Photoshop. Tapi ia tetap punya Magic Wand dan layer!

Kamu memulai Pinta melalui peluncur aplikasi (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) adalah aplikasi tema yang dapat mengekstrak warna dari gambar latar belakang dan mengubahnya menjadi tema yang lengkap dan padu. Ini cara termudah untuk [membuat temamu sendiri](43-making-your-own-theme.md).

Kamu memulai Aether melalui peluncur aplikasi (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) memungkinkanmu mengirim berkas ke perangkat lain di jaringan yang sama yang menjalankan aplikasi ini, seperti AirDrop milik Apple. Namun ia lintas platform, jadi kamu bisa mengirim berkas ke dan dari Windows, macOS, Android, iOS, dan tentu saja Linux.

Kamu dapat membuka menu Share pada `Super + Ctrl + S` atau di _Trigger > Share_ dalam menu Omarchy. Ia memberimu empat pilihan:

- **Clipboard** mengirim apa pun yang telah kamu salin sebagai berkas teks. Bagus untuk memindahkan tautan atau potongan teks ke ponselmu tanpa mengirim email ke diri sendiri.
- **File** membuka pemilih berkas tempat kamu dapat memilih beberapa sekaligus.
- **Folder** mengirim seluruh direktori.
- **Receive** membuka LocalSend yang sesungguhnya agar perangkat lain dapat mengirim sesuatu kepadamu.

Hal yang sama bekerja dari terminal dengan `omarchy share clipboard`, `omarchy share file [path]`, dan `omarchy share folder [path]`. Hilangkan jalurnya dan kamu akan mendapatkan pemilihnya.

Kamu juga dapat mengirim langsung dari pengelola berkas: klik kanan pilihan apa pun di Files dan bagikan dengan LocalSend.

Firewall Omarchy tertutup secara bawaan kecuali untuk port LocalSend, jadi ini langsung bekerja pada instalasi baru. Lihat [keamanan](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) adalah paket perkantoran lengkap dengan pengolah kata, spreadsheet, presentasi, aplikasi menggambar, dan banyak lagi. Ia kompatibel dengan berkas dari Microsoft Office, jadi ini cara yang bagus untuk dapat membuka dokumen Word tersebut.

Kamu memulai LibreOffice melalui peluncur aplikasi (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) adalah aplikasi presentasi Omarchy sendiri yang sangat sederhana. Dekmu adalah satu berkas Markdown dengan gambar dan videonya di sampingnya: tulis setiap slide di bawah pratinjau langsung, seret slide ke urutannya, lalu presentasikan dalam layar penuh atau ekspor ke PDF dan PowerPoint. Ia bahkan mengambil tema Omarchy-mu.

Kamu memulai Hype melalui peluncur aplikasi (`Super + Space`). Tekan `?` di dalamnya untuk melihat setiap pintasan.

## Signed

[Signed](https://github.com/omacom/signed) adalah cara Omarchy sendiri yang sangat sederhana untuk menandatangani PDF dan mengisinya. Letakkan tanda tangan tersimpanmu, teks, dan tanggal hari ini di mana saja pada sebuah halaman, lalu simpan salinan bertanda tangan di samping aslinya. Lihat [Mengisi PDF](27-filling-out-pdfs.md) untuk caranya.

Kamu memulai Signed melalui peluncur aplikasi (`Super + Space`), atau membuka PDF dengannya dari pengelola berkas.

## Game Vibes

Game Vibes, di peluncur aplikasi (`Super + Space`), adalah tempat permainan kecil Omarchy berada: Checkmate, permainan catur 3D melawan teman atau lawan bawaan; Cards, solitaire Klondike; Death Wish, platformer presisi piksel dengan sepuluh ruangan penuh duri dan gergaji; dan Neon Swarm, penembak arkade. Masing-masing adalah satu halaman web yang mengikuti temamu. Pilih satu dengan tombol panah dan `Enter`, dan kembali ke daftar dengan `Esc` dari layar judul permainan atau `Q` saat dijeda. Ia terbuka dalam layar penuh: `Super + F` menjadikannya jendela, dan `Super + W` menutupnya.

Permainan yang kamu buat dengan agen juga muncul di sini: pilih _Make something cool → Game_ di panel agen dan jelaskan satu permainan, atau sebutkan permainan yang sudah ada di Game Vibes untuk terus mengerjakannya. Agen menyalinnya ke `~/Games/vibes`, tempat ia menjadi milikmu untuk diubah, dan membukanya saat selesai. Kamu dapat membuat salinan itu sendiri dengan `omarchy games vibes copy <game>`. Permainan yang dibagikan orang lain dipasang seperti tema: pilih _Install > Gaming > Game Vibes_ dan tempel alamat git-nya, atau jalankan `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ menghapusnya lagi, dan _Update > Game Vibes Games_ mengambil versi baru. Permainan memuat three.js dari web, jadi mereka membutuhkan koneksi untuk memulai.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) adalah kalkulator Omarchy sendiri yang sangat sederhana, yang terbuka dalam jendela mengambang.

Kamu memulai Omacalc dengan `Super + Shift + Q` (atau tombol kalkulator, jika keyboardmu memilikinya).

## Signal

[Signal](https://signal.org/) adalah pelopor pesan terenkripsi E2E, dan pilihan komunikasi yang bagus untuk siapa pun yang lebih suka tidak melalui salah satu konglomerat teknologi besar.

Kamu memulai Signal dengan `Super + Shift + G`. Ia bukan bagian dari instalasi dasar, jadi pertama kali kamu menekan itu, Omarchy akan menawarkan untuk memasangnya untukmu (ia juga ada di _Install > Service_ dalam menu Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) adalah penampil gambar dan pemutar media Omarchy sendiri yang sangat sederhana: satu jendela untuk foto, video, dan musikmu. Buka sebuah foto dan tombol panah melangkah melalui isi foldernya yang lain, `N` dan `P` melakukannya untuk apa pun, dan `Ctrl + M` menampilkan seluruh folder sebagai kisi. Ia juga menampilkan foto HEIC, AVIF, dan JPEG XL, dan melanjutkan dari tempat terakhirmu berhenti pada apa pun yang panjang.

Tekan `F` untuk layar penuh, `E` untuk mengedit gambar di Omasnap atau memangkas video di Omacut, `Ctrl + P` untuk mencetak gambar, dan `Delete` untuk memindahkan berkas ke Trash (`Ctrl + Z` mengembalikannya). Tekan `?` di dalamnya untuk melihat setiap pintasan.

Kamu memulai Omaview sebagai _Media Viewer_ melalui peluncur aplikasi (`Super + Space`), atau cukup klik dua kali gambar, video, atau lagu di pengelola berkas.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) adalah pemangkas video Omarchy sendiri yang sangat sederhana. Saat yang kamu butuhkan hanyalah memotong awal dan akhir sebuah klip, ia mengalahkan membuka editor video lengkap.

Kamu memulai Omacut melalui peluncur aplikasi (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) adalah perekam webcam Omarchy sendiri yang sangat sederhana. Pilih kamera dan mikrofonmu sekali, lalu tekan `Space` untuk merekam, dan lagi untuk menjeda dan melanjutkan pengambilan yang sama. Ia selalu merekam pada resolusi tertinggi kameramu, dengan meter mikrofon langsung agar kamu dapat memeriksa levelmu sebelum mulai.

Hentikan pengambilan dan ia langsung terbuka di editor bawaan. Klik dua kali sebuah klip untuk membaginya, seret pegangannya untuk memangkas setiap bagian, dan hapus bagian yang tidak kamu inginkan. Lalu simpan sebagai MP4. Rekaman aslimu disimpan sampai kamu membuangnya, jadi kamu selalu dapat kembali dan memotongnya dengan cara berbeda.

Kamu memulai Monologue melalui peluncur aplikasi (`Super + Space`).
