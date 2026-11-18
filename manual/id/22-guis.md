# GUIs

## Files

Files (Nautilus) adalah manajer berkas grafis. `Super + Shift + F` membukanya, dan `Super + Shift + Alt + F` membukanya di direktori tempat terminal Anda berada, yang menghemat banyak klik. `Ctrl + L` memungkinkan Anda mengetik path, dan menekan `Space` pada berkas apa pun memberi Anda pratinjau cepat tanpa membuka apa pun.

Colokkan stik USB atau kartu SD dan perangkat itu akan di-mount secara otomatis, jadi langsung muncul di sidebar. Untuk hal yang lebih rumit — memformat drive, memeriksa kesehatan SMART, membuat partisi — jalankan _Disks_ dari peluncur aplikasi (`Super + Space`).

Klik dua kali mengikuti default yang masuk akal: gambar, video, dan musik terbuka di Omaview, PDF di Document Viewer, Markdown di Omawrite, dan teks biasa di editor yang dipilih di _Setup > Default > Editor_.

## Disktree

Saat drive penuh dan Anda tidak tahu apa yang memakannya, jalankan [Disktree](https://github.com/tobi/disktree) dari peluncur aplikasi (`Super + Space`). Aplikasi ini menampilkan treemap grafis dari direktori home Anda. Blok yang lebih besar memakan lebih banyak ruang; masuk ke direktori dengan keyboard atau mouse, tandai yang harus dibuang, dan tinjau pilihan Anda sebelum menghapus apa pun. Jalankan `disktree --disk` untuk memindai seluruh disk.

## Obsidian

[Obsidian](https://obsidian.md/) adalah aplikasi pencatatan gratis dan sangat dapat diperluas yang menggunakan berkas Markdown sederhana untuk penyimpanan.

Obsidian gratis untuk semua tujuan, termasuk penggunaan pribadi, komersial, dan nirlaba.

Obsidian juga menawarkan [add-on komersial untuk sinkronisasi](https://obsidian.md/sync) dengan aplikasi seluler di iOS dan Android. (https://obsidian.md/pricing).

Anda memulai Obsidian dengan `Super + Shift + O`. Untuk menggunakan sinkronisasi tema, Anda harus memilih tema `Omarchy` di pengaturan.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) adalah aplikasi menulis Markdown milik Omarchy sendiri yang sangat sederhana. Tanpa vault, tanpa plugin, hanya Anda dan kata-kata.

Anda memulai Omawrite dengan `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) adalah alat pengeditan gambar dasar yang bagus untuk memotong, mengubah ukuran, dan manipulasi dasar lainnya. Jangan berharap ini menjadi alternatif Photoshop. Tapi tetap ada Magic Wand dan layer!

Anda memulai Pinta melalui peluncur aplikasi (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) adalah aplikasi tema yang dapat mengekstrak warna dari gambar latar dan mengubahnya menjadi tema yang lengkap dan padu. Ini adalah cara termudah untuk [membuat tema Anda sendiri](43-making-your-own-theme.md).

Anda memulai Aether melalui peluncur aplikasi (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) memungkinkan Anda mengirim berkas ke perangkat lain di jaringan yang sama yang menjalankan aplikasi ini, seperti AirDrop dari Apple. Namun ini lintas platform, jadi Anda dapat mengirim berkas ke dan dari Windows, macOS, Android, iOS, dan tentu saja Linux.

Anda dapat membuka menu Share dengan `Super + Ctrl + S` atau di _Trigger > Share_ dalam menu Omarchy. Menu ini memberi Anda empat opsi:

- **Clipboard** mengirim apa pun yang telah Anda salin sebagai berkas teks. Bagus untuk memindahkan tautan atau cuplikan ke ponsel Anda tanpa mengirim email ke diri sendiri.
- **File** membuka pemilih berkas tempat Anda dapat memilih beberapa berkas sekaligus.
- **Folder** mengirim seluruh direktori.
- **Receive** membuka LocalSend yang sebenarnya agar perangkat lain dapat mengirim sesuatu kepada Anda.

Hal yang sama bekerja dari terminal dengan `omarchy share clipboard`, `omarchy share file [path]`, dan `omarchy share folder [path]`. Kosongkan path dan Anda akan mendapatkan pemilihnya.

Anda juga dapat mengirim langsung dari manajer berkas: klik kanan pilihan apa pun di Nautilus dan pilih _Send via LocalSend_.

Firewall Omarchy tertutup secara default kecuali untuk port LocalSend, jadi ini langsung berfungsi pada instalasi baru. Lihat [keamanan](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) adalah paket perkantoran lengkap dengan pengolah kata, spreadsheet, presentasi, aplikasi menggambar, dan banyak lagi. Aplikasi ini kompatibel dengan berkas dari Microsoft Office, jadi ini adalah cara yang bagus untuk dapat membuka dokumen Word tersebut.

Anda memulai LibreOffice melalui peluncur aplikasi (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) adalah aplikasi presentasi milik Omarchy sendiri yang sangat sederhana. Deck Anda adalah satu berkas Markdown dengan gambar dan videonya di sampingnya: tulis setiap slide di bawah pratinjau langsung, seret slide ke urutan yang diinginkan, lalu presentasikan dalam layar penuh atau ekspor ke PDF dan PowerPoint. Aplikasi ini bahkan menyesuaikan tema Omarchy Anda.

Anda memulai Hype melalui peluncur aplikasi (`Super + Space`). Tekan `?` di dalamnya untuk melihat setiap pintasan.

## Signed

[Signed](https://github.com/omacom/signed) adalah cara milik Omarchy sendiri yang sangat sederhana untuk menandatangani PDF dan mengisinya. Letakkan tanda tangan yang telah Anda simpan, teks, dan tanggal hari ini di mana saja pada halaman, lalu simpan salinan yang telah ditandatangani di samping aslinya. Lihat [Mengisi PDF](27-filling-out-pdfs.md) untuk caranya.

Anda memulai Signed melalui peluncur aplikasi (`Super + Space`), atau membuka PDF dengannya dari manajer berkas.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) adalah game catur 3D milik Omarchy sendiri. Mainkan teman di komputer yang sama atau lawan bawaan pada tiga level, pada empat set pahatan yang masing-masing bergerak dengan caranya sendiri: wahana orbital, kayu dan gading ukiran, makhluk hutan, dan permen. Permainan tidak memakai jam dan tersimpan setelah setiap langkah.

Anda memulai Checkmate melalui peluncur aplikasi (`Super + Space`), di mana aplikasi ini terdaftar sebagai Chess. Tekan `?` di dalamnya untuk melihat setiap pintasan.

## Cards

[Cards](https://github.com/omacom/cards) adalah Klondike solitaire milik Omarchy sendiri. Ambil tiga kartu, tanpa batas jumlah putaran, dalam empat seri kartu: satu digambar dengan warna tema Anda, dan tiga dengan tampilannya sendiri. Klik kartu lalu tempat tujuannya, seret kartu itu, atau klik dua kali untuk mengirimnya ke tempat terbaik. Permainan tersimpan setelah setiap langkah.

Anda memulai Cards melalui peluncur aplikasi (`Super + Space`). Klik namanya, atau tekan `?`, untuk melihat setiap pintasan.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) adalah kalkulator milik Omarchy sendiri yang sangat sederhana, yang terbuka di jendela mengambang.

Anda memulai Omacalc dengan `Super + Shift + Q` (atau tombol kalkulator, jika keyboard Anda memilikinya).

## Signal

[Signal](https://signal.org/) adalah pelopor perpesanan terenkripsi E2E, dan pilihan komunikasi yang bagus bagi siapa pun yang lebih memilih tidak melewati salah satu konglomerat teknologi besar.

Anda memulai Signal dengan `Super + Shift + G`. Aplikasi ini bukan bagian dari instalasi dasar, jadi pertama kali Anda menekan itu, Omarchy akan menawarkan untuk menginstalnya untuk Anda (ini juga ada di _Install > Service_ dalam menu Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) adalah penampil gambar dan pemutar media milik Omarchy sendiri yang sangat sederhana: satu jendela untuk foto, video, dan musik Anda. Buka foto dan tombol panah akan melangkah melalui sisa foldernya, `N` dan `P` melakukannya untuk apa pun, dan `Ctrl + M` menampilkan seluruh folder sebagai kisi. Aplikasi ini juga menampilkan foto HEIC, AVIF, dan JPEG XL, dan melanjutkan dari tempat Anda berhenti pada apa pun yang panjang.

Tekan `F` untuk layar penuh, `E` untuk mengedit gambar di Omasnap atau memangkas video di Omacut, `Ctrl + P` untuk mencetak gambar, dan `Delete` untuk memindahkan berkas ke Trash (`Ctrl + Z` mengembalikannya). Tekan `?` di dalamnya untuk melihat setiap pintasan.

Anda memulai Omaview sebagai _Media Viewer_ melalui peluncur aplikasi (`Super + Space`), atau cukup klik dua kali gambar, video, atau lagu di manajer berkas.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) adalah pemangkas video milik Omarchy sendiri yang sangat sederhana. Saat yang Anda butuhkan hanya memotong awal dan akhir klip, ini mengalahkan membuka editor video lengkap.

Anda memulai Omacut melalui peluncur aplikasi (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) adalah perekam webcam milik Omarchy sendiri yang sangat sederhana. Pilih kamera dan mikrofon Anda sekali, lalu tekan `Space` untuk merekam, dan lagi untuk menjeda dan melanjutkan pengambilan yang sama. Aplikasi ini selalu merekam pada resolusi tertinggi kamera Anda, dengan pengukur mikrofon langsung sehingga Anda dapat memeriksa level Anda sebelum mulai.

Hentikan pengambilan dan aplikasi ini langsung terbuka di editor bawaan. Klik dua kali klip untuk membaginya, seret handle untuk memangkas setiap bagian, dan hapus bagian yang tidak Anda inginkan. Lalu simpan sebagai MP4. Rekaman asli Anda disimpan sampai Anda membuangnya, jadi Anda selalu dapat kembali dan memotongnya dengan cara berbeda.

Anda memulai Monologue melalui peluncur aplikasi (`Super + Space`).
