# GUIs

## Files

Files (Nautilus) adalah manajer file grafis. `Super + Shift + F` membukanya, dan `Super + Shift + Alt + F` membukanya di direktori tempat terminal Anda saat ini berada, yang menghemat banyak klik. `Ctrl + L` memungkinkan Anda mengetik sebuah path, dan menekan `Space` pada file apa pun memberi Anda pratinjau cepat tanpa membuka apa pun.

Colokkan stik USB atau kartu SD dan perangkat itu akan di-mount secara otomatis, jadi langsung muncul di sidebar. Untuk hal yang lebih rumit — memformat drive, memeriksa kesehatan SMART, membuat partisi — jalankan _Disks_ dari peluncur aplikasi (`Super + Space`).

Klik dua kali mengikuti default yang masuk akal: gambar, video, dan musik dibuka di Omaview, PDF di Document Viewer, Markdown di Omawrite, dan teks biasa di editor yang dipilih di _Setup > Default > Editor_.

## Disktree

Saat drive penuh dan Anda tidak tahu apa yang memakannya, jalankan [Disktree](https://github.com/tobi/disktree) dari peluncur aplikasi (`Super + Space`). Aplikasi ini menampilkan treemap grafis dari direktori home Anda. Blok yang lebih besar memakan lebih banyak ruang; masuk ke direktori dengan keyboard atau mouse, tandai apa yang harus dibuang, dan tinjau pilihan Anda sebelum menghapus apa pun. Jalankan `disktree --disk` untuk memindai seluruh disk.

## Obsidian

[Obsidian](https://obsidian.md/) adalah aplikasi pencatatan gratis dan sangat dapat diperluas yang menggunakan file Markdown sederhana untuk penyimpanan.

Obsidian gratis untuk semua tujuan, termasuk penggunaan pribadi, komersial, dan nirlaba.

Obsidian juga menawarkan [add-on komersial untuk sinkronisasi](https://obsidian.md/sync) dengan aplikasi seluler di iOS dan Android. (https://obsidian.md/pricing).

Anda memulai Obsidian dengan `Super + Shift + O`. Untuk menggunakan sinkronisasi tema, Anda harus memilih tema `Omarchy` di pengaturan.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) adalah aplikasi penulisan Markdown Omarchy sendiri yang sangat sederhana. Tanpa vault, tanpa plugin, hanya Anda dan kata-kata.

Anda memulai Omawrite dengan `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) adalah alat pengeditan gambar dasar yang bagus untuk memotong, mengubah ukuran, dan manipulasi dasar lainnya. Jangan harap ini jadi alternatif Photoshop. Tapi tetap ada Magic Wand dan lapisan!

Anda memulai Pinta melalui peluncur aplikasi (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) adalah aplikasi tema yang dapat mengekstrak warna dari gambar latar belakang dan mengubahnya menjadi tema yang lengkap dan kohesif. Ini cara termudah untuk [membuat tema Anda sendiri](43-making-your-own-theme.md).

Anda memulai Aether melalui peluncur aplikasi (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) memungkinkan Anda mengirim file ke perangkat lain di jaringan yang sama yang menjalankan aplikasi ini, seperti AirDrop dari Apple. Namun aplikasi ini lintas platform, jadi Anda dapat mengirim file ke dan dari Windows, macOS, Android, iOS, dan tentu saja Linux.

Anda dapat membuka menu Share dengan `Super + Ctrl + S` atau di _Trigger > Share_ di menu Omarchy. Menu itu memberi Anda empat opsi:

- **Clipboard** mengirim apa pun yang telah Anda salin sebagai file teks. Bagus untuk mengirim tautan atau cuplikan ke ponsel Anda tanpa harus mengirim email ke diri sendiri.
- **File** membuka pemilih file tempat Anda dapat memilih beberapa sekaligus.
- **Folder** mengirim seluruh direktori.
- **Receive** membuka LocalSend yang sebenarnya agar perangkat lain dapat mengirim sesuatu kepada Anda.

Hal yang sama bekerja dari terminal dengan `omarchy share clipboard`, `omarchy share file [path]`, dan `omarchy share folder [path]`. Hilangkan path-nya dan Anda akan mendapatkan pemilihnya.

Anda juga dapat mengirim langsung dari manajer file: klik kanan pilihan apa pun di Nautilus dan pilih _Send via LocalSend_.

Firewall Omarchy tertutup secara default kecuali untuk port LocalSend, jadi ini bekerja langsung pada instalasi baru. Lihat [keamanan](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) adalah paket perkantoran lengkap dengan pengolah kata, spreadsheet, presentasi, aplikasi menggambar, dan banyak lagi. Aplikasi ini kompatibel dengan file dari Microsoft Office, jadi ini cara yang bagus untuk dapat membuka dokumen Word tersebut.

Anda memulai LibreOffice melalui peluncur aplikasi (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) adalah aplikasi presentasi Omarchy sendiri yang sangat sederhana. Deck Anda adalah satu file Markdown dengan gambar dan videonya di sampingnya: tulis setiap slide di bawah pratinjau langsung, seret slide ke urutan yang diinginkan, lalu presentasikan dalam layar penuh atau ekspor ke PDF dan PowerPoint. Aplikasi ini bahkan menyesuaikan tema Omarchy Anda.

Anda memulai Hype melalui peluncur aplikasi (`Super + Space`). Tekan `?` di dalamnya untuk melihat setiap pintasan.

## Signed

[Signed](https://github.com/omacom/signed) adalah cara Omarchy sendiri yang sangat sederhana untuk menandatangani PDF dan mengisinya. Letakkan tanda tangan tersimpan Anda, teks, dan tanggal hari ini di mana saja pada halaman, lalu simpan salinan yang telah ditandatangani di samping aslinya. Lihat [Mengisi PDF](27-filling-out-pdfs.md) untuk caranya.

Anda memulai Signed melalui peluncur aplikasi (`Super + Space`), atau membuka PDF dengannya dari manajer file.

## Game Vibes

Game Vibes, di peluncur aplikasi (`Super + Space`), adalah tempat permainan kecil Omarchy berada: Checkmate, permainan catur 3D melawan teman atau lawan bawaan; Cards, solitaire Klondike; dan Neon Swarm, game tembak-menembak arcade. Masing-masing adalah satu halaman web yang mengikuti tema Anda. Pilih satu dengan panah dan `Enter`, dan kembali ke daftar dengan `Esc` dari layar judul permainan atau `Q` saat dijeda. Aplikasi ini terbuka dalam layar penuh: `Super + F` menjadikannya jendela, dan `Super + W` menutupnya.

Permainan yang Anda buat dengan agen juga muncul di sini: pilih _Make something cool → Game_ di panel agen dan jelaskan satu permainan, atau sebutkan permainan yang sudah ada di Game Vibes untuk terus mengerjakannya. Agen menyalinnya ke `~/Games/vibes`, tempat permainan itu menjadi milik Anda untuk diubah, dan membukanya saat selesai. Anda dapat membuat salinan itu sendiri dengan `omarchy games vibes copy <game>`. Permainan yang dibagikan orang lain terinstal seperti tema: pilih _Install > Gaming > Game Vibes_ dan tempel alamat git-nya, atau jalankan `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ menghapusnya lagi, dan _Update > Game Vibes Games_ mengambil versi baru. Permainan memuat three.js dari web, jadi mereka membutuhkan koneksi untuk memulai.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) adalah kalkulator Omarchy sendiri yang sangat sederhana, yang terbuka dalam jendela mengambang.

Anda memulai Omacalc dengan `Super + Shift + Q` (atau tombol kalkulator, jika keyboard Anda memilikinya).

## Signal

[Signal](https://signal.org/) adalah pelopor pesan terenkripsi E2E, dan pilihan komunikasi yang bagus bagi siapa pun yang lebih suka tidak melalui salah satu konglomerat teknologi besar.

Anda memulai Signal dengan `Super + Shift + G`. Aplikasi ini bukan bagian dari instalasi dasar, jadi pertama kali Anda menekan itu, Omarchy akan menawarkan untuk menginstalnya untuk Anda (ini juga ada di _Install > Service_ di menu Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) adalah penampil gambar dan pemutar media Omarchy sendiri yang sangat sederhana: satu jendela untuk foto, video, dan musik Anda. Buka foto dan tombol panah akan melangkah melalui sisa foldernya, `N` dan `P` melakukannya untuk apa pun, dan `Ctrl + M` menampilkan seluruh folder sebagai grid. Aplikasi ini juga menampilkan foto HEIC, AVIF, dan JPEG XL, dan melanjutkan dari tempat Anda berhenti pada apa pun yang panjang.

Tekan `F` untuk layar penuh, `E` untuk mengedit gambar di Omasnap atau memotong video di Omacut, `Ctrl + P` untuk mencetak gambar, dan `Delete` untuk memindahkan file ke Trash (`Ctrl + Z` mengembalikannya). Tekan `?` di dalamnya untuk melihat setiap pintasan.

Anda memulai Omaview sebagai _Media Viewer_ melalui peluncur aplikasi (`Super + Space`), atau cukup klik dua kali gambar, video, atau lagu di manajer file.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) adalah pemangkas video Omarchy sendiri yang sangat sederhana. Ketika yang Anda butuhkan hanya memotong bagian awal dan akhir klip, ini jauh lebih praktis daripada membuka editor video lengkap.

Anda memulai Omacut melalui peluncur aplikasi (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) adalah perekam webcam Omarchy sendiri yang sangat sederhana. Pilih kamera dan mikrofon Anda sekali, lalu tekan `Space` untuk merekam, dan lagi untuk menjeda dan melanjutkan pengambilan yang sama. Aplikasi ini selalu merekam pada resolusi tertinggi kamera Anda, dengan meter mikrofon langsung agar Anda dapat memeriksa level Anda sebelum memulai.

Hentikan pengambilan dan itu akan terbuka langsung di editor bawaan. Klik dua kali klip untuk membaginya, seret pegangan untuk memangkas setiap bagian, dan hapus bagian yang tidak Anda inginkan. Lalu simpan sebagai MP4. Rekaman asli Anda disimpan sampai Anda membuangnya, jadi Anda selalu dapat kembali dan memotongnya secara berbeda.

Anda memulai Monologue melalui peluncur aplikasi (`Super + Space`).
