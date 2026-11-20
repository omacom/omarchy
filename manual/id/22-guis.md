# GUIs

## Files

Files (Folio) adalah pengelola berkas grafis. `Super + Shift + F` membukanya, dan `Super + Shift + Alt + F` membukanya di direktori tempat terminal Anda berada, yang menghemat banyak klik. `Ctrl + L` memungkinkan Anda mengetik sebuah jalur, dan menekan `Space` pada berkas apa pun akan mempratinjaunya dalam ukuran penuh tanpa membukanya.

Colokkan stik USB atau kartu SD dan perangkat itu akan terpasang secara otomatis, jadi langsung muncul di sidebar. Untuk hal yang lebih rumit — memformat drive, memeriksa kesehatan SMART, membuat partisi — jalankan _Disks_ dari peluncur aplikasi (`Super + Space`).

Klik dua kali mengikuti default yang masuk akal: gambar, video, dan musik terbuka di Omaview, PDF di Document Viewer, Markdown di Omawrite, dan teks biasa di editor yang dipilih di _Setup > Default > Editor_.

## Disktree

Ketika drive penuh dan Anda tidak tahu apa yang memakannya, jalankan [Disktree](https://github.com/tobi/disktree) dari peluncur aplikasi (`Super + Space`). Aplikasi ini menampilkan treemap grafis dari direktori home Anda. Blok yang lebih besar memakan ruang lebih banyak; jelajahi direktori dengan keyboard atau mouse, tandai yang harus dibuang, dan tinjau pilihan Anda sebelum menghapus apa pun. Jalankan `disktree --disk` untuk memindai seluruh disk.

## Obsidian

[Obsidian](https://obsidian.md/) adalah aplikasi pencatat gratis dan sangat dapat diperluas yang menggunakan berkas Markdown sederhana untuk penyimpanan.

Obsidian gratis untuk semua tujuan, termasuk penggunaan pribadi, komersial, dan nirlaba.

Obsidian juga menawarkan [add-on komersial untuk sinkronisasi](https://obsidian.md/sync) dengan aplikasi seluler di iOS dan Android. (https://obsidian.md/pricing).

Anda memulai Obsidian dengan `Super + Shift + O`. Untuk menggunakan sinkronisasi tema, Anda harus memilih tema `Omarchy` di pengaturan.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) adalah aplikasi penulisan Markdown milik Omarchy yang sangat sederhana. Tanpa vault, tanpa plugin, hanya Anda dan kata-kata.

Anda memulai Omawrite dengan `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) adalah alat pengedit gambar dasar yang bagus untuk memotong, mengubah ukuran, dan manipulasi dasar lainnya. Jangan mengharapkan alternatif Photoshop. Tapi aplikasi ini tetap punya Magic Wand dan layers!

Anda memulai Pinta lewat peluncur aplikasi (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) adalah aplikasi tema yang dapat mengekstrak warna dari gambar latar dan mengubahnya menjadi tema yang lengkap dan padu. Ini cara termudah untuk [membuat tema Anda sendiri](43-making-your-own-theme.md).

Anda memulai Aether lewat peluncur aplikasi (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) memungkinkan Anda mengirim berkas ke perangkat lain di jaringan yang sama yang menjalankan aplikasi ini, seperti AirDrop dari Apple. Namun aplikasi ini lintas platform, jadi Anda dapat mengirim berkas ke dan dari Windows, macOS, Android, iOS, dan tentu saja Linux.

Anda dapat membuka menu Share dengan `Super + Ctrl + S` atau di _Trigger > Share_ dalam menu Omarchy. Menu ini memberi Anda empat pilihan:

- **Clipboard** mengirim apa pun yang telah Anda salin sebagai berkas teks. Bagus untuk memindahkan tautan atau cuplikan ke ponsel Anda tanpa mengirim email ke diri sendiri.
- **File** membuka pemilih berkas tempat Anda dapat memilih beberapa sekaligus.
- **Folder** mengirim seluruh direktori.
- **Receive** membuka LocalSend yang sesungguhnya agar perangkat lain dapat mengirim sesuatu kepada Anda.

Hal yang sama bekerja dari terminal dengan `omarchy share clipboard`, `omarchy share file [path]`, dan `omarchy share folder [path]`. Hilangkan jalurnya dan Anda akan mendapatkan pemilihnya.

Anda juga dapat mengirim langsung dari pengelola berkas: klik kanan pilihan apa pun di Files dan bagikan dengan LocalSend.

Firewall Omarchy tertutup secara default kecuali untuk port LocalSend, jadi ini langsung bekerja pada instalasi baru. Lihat [keamanan](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) adalah paket perkantoran lengkap dengan pengolah kata, spreadsheet, presentasi, aplikasi menggambar, dan banyak lagi. Aplikasi ini kompatibel dengan berkas dari Microsoft Office, jadi ini cara yang bagus untuk dapat membuka dokumen Word tersebut.

Anda memulai LibreOffice lewat peluncur aplikasi (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) adalah aplikasi presentasi milik Omarchy yang sangat sederhana. Deck Anda adalah satu berkas Markdown dengan gambar dan videonya di sampingnya: tulis setiap slide di bawah pratinjau langsung, seret slide ke urutan yang diinginkan, lalu presentasikan dalam layar penuh atau ekspor ke PDF dan PowerPoint. Aplikasi ini bahkan mengikuti tema Omarchy Anda.

Anda memulai Hype lewat peluncur aplikasi (`Super + Space`). Tekan `?` di dalamnya untuk melihat setiap pintasan.

## Signed

[Signed](https://github.com/omacom/signed) adalah cara milik Omarchy yang sangat sederhana untuk menandatangani PDF dan mengisinya. Letakkan tanda tangan tersimpan, teks, dan tanggal hari ini di mana saja pada sebuah halaman, lalu simpan salinan yang telah ditandatangani di samping aslinya. Lihat [Mengisi PDF](27-filling-out-pdfs.md) untuk caranya.

Anda memulai Signed lewat peluncur aplikasi (`Super + Space`), atau buka PDF dengannya dari pengelola berkas.

## Game Vibes

Game Vibes, di peluncur aplikasi (`Super + Space`), adalah tempat tinggal game-game kecil Omarchy: Checkmate, permainan catur 3D melawan teman atau lawan bawaan; Cards, solitaire Klondike; dan Neon Swarm, penembak arcade. Masing-masing adalah satu halaman web yang mengikuti tema Anda. Pilih satu dengan tombol panah dan `Enter`, dan kembali ke daftar dengan `Esc` dari layar judul game atau `Q` saat dijeda. Ini terbuka dalam layar penuh: `Super + F` menjadikannya jendela, dan `Super + W` menutupnya.

Game yang Anda buat dengan agen juga muncul di sini: pilih _Make something cool → Game_ di panel agen dan jelaskan satu, atau sebutkan game yang sudah ada di Game Vibes untuk terus mengerjakannya. Agen menyalinnya ke `~/Games/vibes`, tempat game itu menjadi milik Anda untuk diubah, dan membukanya saat selesai. Anda dapat membuat salinan itu sendiri dengan `omarchy games vibes copy <game>`. Game yang dibagikan orang lain terinstal seperti tema: pilih _Install > Gaming > Game Vibes_ dan tempel alamat git-nya, atau jalankan `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ menghapusnya lagi, dan _Update > Game Vibes Games_ mengambil versi baru. Game memuat three.js dari web, jadi mereka membutuhkan koneksi untuk memulai.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) adalah kalkulator milik Omarchy yang sangat sederhana, yang terbuka di jendela mengambang.

Anda memulai Omacalc dengan `Super + Shift + Q` (atau tombol kalkulator, jika keyboard Anda memilikinya).

## Signal

[Signal](https://signal.org/) adalah pelopor perpesanan terenkripsi E2E, dan pilihan komunikasi yang bagus untuk siapa pun yang lebih memilih tidak melalui salah satu konglomerat teknologi besar.

Anda memulai Signal dengan `Super + Shift + G`. Aplikasi ini bukan bagian dari instalasi dasar, jadi pertama kali Anda menekan itu, Omarchy akan menawarkan untuk menginstalnya untuk Anda (ini juga ada di _Install > Service_ dalam menu Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) adalah penampil gambar dan pemutar media milik Omarchy yang sangat sederhana: satu jendela untuk foto, video, dan musik Anda. Buka sebuah foto dan tombol panah akan melangkah melalui sisa foldernya, `N` dan `P` melakukannya untuk apa pun, dan `Ctrl + M` menampilkan seluruh folder sebagai kisi. Aplikasi ini juga menampilkan foto HEIC, AVIF, dan JPEG XL, dan melanjutkan dari tempat Anda berhenti pada apa pun yang panjang.

Tekan `F` untuk layar penuh, `E` untuk mengedit gambar di Omasnap atau memangkas video di Omacut, `Ctrl + P` untuk mencetak gambar, dan `Delete` untuk memindahkan berkas ke Trash (`Ctrl + Z` mengembalikannya). Tekan `?` di dalamnya untuk melihat setiap pintasan.

Anda memulai Omaview sebagai _Media Viewer_ lewat peluncur aplikasi (`Super + Space`), atau cukup klik dua kali gambar, video, atau lagu di pengelola berkas.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) adalah pemangkas video milik Omarchy yang sangat sederhana. Ketika yang Anda butuhkan hanya memotong awal dan akhir sebuah klip, aplikasi ini lebih baik daripada menyalakan editor video lengkap.

Anda memulai Omacut lewat peluncur aplikasi (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) adalah perekam webcam milik Omarchy yang sangat sederhana. Pilih kamera dan mikrofon Anda sekali, lalu tekan `Space` untuk merekam, dan lagi untuk menjeda dan melanjutkan pengambilan yang sama. Aplikasi ini selalu merekam pada resolusi tertinggi kamera Anda, dengan meter mikrofon langsung agar Anda dapat memeriksa level Anda sebelum memulai.

Hentikan pengambilan dan aplikasi ini langsung terbuka di editor bawaan. Klik dua kali sebuah klip untuk membaginya, seret pegangannya untuk memangkas setiap potongan, dan hapus bagian yang tidak Anda inginkan. Kemudian simpan sebagai MP4. Rekaman asli Anda disimpan sampai Anda membuangnya, jadi Anda selalu dapat kembali dan memotongnya dengan cara berbeda.

Anda memulai Monologue lewat peluncur aplikasi (`Super + Space`).
