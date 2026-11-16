# GUI

## Files

Files (Nautilus) adalah manajer berkas grafis. `Super + Shift + F` membukanya, dan `Super + Shift + Alt + F` membukanya di direktori tempat terminalmu berada saat ini, yang menghemat banyak klik. `Ctrl + L` memungkinkanmu mengetik sebuah path, dan menekan `Space` pada berkas apa pun memberimu pratinjau cepat tanpa membuka apa pun.

Colokkan stik USB atau kartu SD dan media itu akan terpasang secara otomatis, jadi langsung muncul di bilah sisi. Untuk hal yang lebih rumit — memformat drive, memeriksa kesehatan SMART, membuat partisi — jalankan _Disks_ dari peluncur aplikasi (`Super + Space`).

Klik dua kali mengikuti default yang masuk akal: gambar, video, dan musik terbuka di Omaview, PDF di Document Viewer, Markdown di Omawrite, dan teks biasa di editor yang dipilih di bawah _Setup > Default > Editor_.

## Disktree

Ketika drive penuh dan kamu tidak tahu apa yang memakannya, jalankan [Disktree](https://github.com/tobi/disktree) dari peluncur aplikasi (`Super + Space`). Aplikasi ini menampilkan treemap grafis dari direktori home-mu. Blok yang lebih besar memakan lebih banyak ruang; masuk ke direktori dengan keyboard atau mouse, tandai apa yang harus dibuang, dan tinjau pilihanmu sebelum menghapus apa pun. Jalankan `disktree --disk` untuk memindai seluruh disk.

## Obsidian

[Obsidian](https://obsidian.md/) adalah aplikasi pencatatan gratis dan sangat dapat diperluas yang menggunakan berkas Markdown sederhana untuk penyimpanan.

Obsidian gratis untuk semua tujuan, termasuk penggunaan pribadi, komersial, dan nirlaba.

Obsidian juga menawarkan [add-on komersial untuk sinkronisasi](https://obsidian.md/sync) dengan aplikasi seluler di iOS dan Android. (https://obsidian.md/pricing).

Kamu memulai Obsidian dengan `Super + Shift + O`. Untuk menggunakan sinkronisasi tema, kamu harus memilih tema `Omarchy` di bawah pengaturan.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) adalah aplikasi penulisan Markdown milik Omarchy sendiri yang sangat sederhana. Tanpa vault, tanpa plugin, hanya kamu dan kata-kata.

Kamu memulai Omawrite dengan `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) adalah alat pengeditan gambar dasar yang hebat untuk memotong, mengubah ukuran, dan manipulasi dasar lainnya. Jangan berharap ini menjadi alternatif Photoshop. Tapi aplikasi ini tetap punya Magic Wand dan layers!

Kamu memulai Pinta melalui peluncur aplikasi (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) adalah aplikasi tema yang dapat mengekstrak warna dari gambar latar belakang dan mengubahnya menjadi tema yang lengkap dan kohesif. Ini cara termudah untuk [membuat temamu sendiri](43-making-your-own-theme.md).

Kamu memulai Aether melalui peluncur aplikasi (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) memungkinkanmu mengirim berkas ke perangkat lain di jaringan yang sama yang menjalankan aplikasi tersebut, seperti AirDrop dari Apple. Namun aplikasi ini lintas platform, jadi kamu dapat mengirim berkas ke dan dari Windows, macOS, Android, iOS, dan tentu saja Linux.

Kamu dapat membuka menu Share dengan `Super + Ctrl + S` atau di bawah _Trigger > Share_ di menu Omarchy. Menu ini memberimu empat opsi:

- **Clipboard** mengirim apa pun yang telah kamu salin sebagai berkas teks. Hebat untuk memasukkan tautan atau cuplikan ke ponselmu tanpa mengirim email kepada dirimu sendiri.
- **File** membuka pemilih berkas tempat kamu dapat memilih beberapa sekaligus.
- **Folder** mengirim seluruh direktori.
- **Receive** membuka LocalSend yang sebenarnya agar perangkat lain dapat mengirim sesuatu kepadamu.

Hal yang sama juga bekerja dari terminal dengan `omarchy share clipboard`, `omarchy share file [path]`, dan `omarchy share folder [path]`. Hilangkan path-nya dan kamu akan mendapatkan pemilihnya.

Kamu juga dapat mengirim langsung dari manajer berkas: klik kanan pilihan apa pun di Nautilus dan pilih _Send via LocalSend_.

Firewall Omarchy tertutup secara default kecuali untuk port LocalSend, jadi ini bekerja langsung pada instalasi baru. Lihat [keamanan](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) adalah paket office lengkap dengan pengolah kata, spreadsheet, presentasi, aplikasi menggambar, dan banyak lagi. Aplikasi ini kompatibel dengan berkas dari Microsoft Office, jadi ini cara yang hebat untuk dapat membuka dokumen Word tersebut.

Kamu memulai LibreOffice melalui peluncur aplikasi (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) adalah aplikasi presentasi milik Omarchy sendiri yang sangat sederhana. Deck-mu adalah satu berkas Markdown dengan gambar dan videonya di sampingnya: tulis setiap slide di bawah pratinjau langsung, seret slide ke dalam urutan, lalu presentasikan dalam layar penuh atau ekspor ke PDF dan PowerPoint. Aplikasi ini bahkan mengikuti tema Omarchy-mu.

Kamu memulai Hype melalui peluncur aplikasi (`Super + Space`). Tekan `?` di dalamnya untuk melihat setiap pintasan.

## Signed

[Signed](https://github.com/omacom/signed) adalah cara milik Omarchy sendiri yang sangat sederhana untuk menandatangani PDF dan mengisinya. Letakkan tanda tangan tersimpanmu, teks, dan tanggal hari ini di mana pun pada sebuah halaman, lalu simpan salinan yang ditandatangani di samping aslinya. Lihat [Mengisi PDF](27-filling-out-pdfs.md) untuk caranya.

Kamu memulai Signed melalui peluncur aplikasi (`Super + Space`), atau membuka PDF dengannya dari manajer berkas.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) adalah game catur 3D milik Omarchy sendiri. Mainkan seorang teman di komputer yang sama atau lawan bawaan pada tiga level, pada empat set pahatan yang masing-masing bergerak dengan caranya sendiri: wahana orbital, kayu dan gading ukiran, makhluk hutan, dan permen. Permainan tidak memiliki jam dan menyimpan setelah setiap langkah.

Kamu memulai Checkmate melalui peluncur aplikasi (`Super + Space`). Tekan `?` di dalamnya untuk melihat setiap pintasan.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) adalah kalkulator milik Omarchy sendiri yang sangat sederhana, yang terbuka di jendela mengambang.

Kamu memulai Omacalc dengan `Super + Shift + Q` (atau tombol kalkulator, jika keyboard-mu memilikinya).

## Signal

[Signal](https://signal.org/) adalah pelopor perpesanan terenkripsi E2E, dan opsi komunikasi yang hebat bagi siapa pun yang lebih memilih untuk tidak melalui salah satu konglomerat teknologi besar.

Kamu memulai Signal dengan `Super + Shift + G`. Aplikasi ini bukan bagian dari instalasi dasar, jadi pertama kali kamu menekan tombol itu, Omarchy akan menawarkan untuk menginstalnya untukmu (ini juga ada di bawah _Install > Service_ di menu Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) adalah penampil gambar dan pemutar media milik Omarchy sendiri yang sangat sederhana: satu jendela untuk foto, video, dan musikmu. Buka sebuah foto dan tombol panah melangkah melalui sisa isi foldernya, `N` dan `P` melakukannya untuk apa pun, dan `Ctrl + M` menampilkan seluruh folder sebagai grid. Aplikasi ini juga menampilkan foto HEIC, AVIF, dan JPEG XL, dan melanjutkan dari tempat terakhirmu pada apa pun yang panjang.

Tekan `F` untuk layar penuh, `E` untuk mengedit gambar di Omasnap atau memangkas video di Omacut, `Ctrl + P` untuk mencetak gambar, dan `Delete` untuk memindahkan berkas ke Trash (`Ctrl + Z` mengembalikannya). Tekan `?` di dalamnya untuk melihat setiap pintasan.

Kamu memulai Omaview sebagai _Media Viewer_ melalui peluncur aplikasi (`Super + Space`), atau cukup klik dua kali gambar, video, atau lagu di manajer berkas.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) adalah pemangkas video milik Omarchy sendiri yang sangat sederhana. Ketika yang kamu butuhkan hanyalah memotong awal dan akhir sebuah klip, aplikasi ini mengalahkan membuka editor video lengkap.

Kamu memulai Omacut melalui peluncur aplikasi (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) adalah perekam webcam milik Omarchy sendiri yang sangat sederhana. Pilih kamera dan mikrofonmu sekali, lalu tekan `Space` untuk merekam, dan lagi untuk menjeda dan melanjutkan rekaman yang sama. Aplikasi ini selalu merekam pada resolusi tertinggi kameramu, dengan meter mikrofon langsung agar kamu dapat memeriksa levelmu sebelum mulai.

Hentikan rekaman dan rekaman itu langsung terbuka di editor bawaan. Klik dua kali sebuah klip untuk membaginya, seret handelnya untuk memangkas setiap bagian, dan hapus bagian yang tidak kamu inginkan. Lalu simpan sebagai MP4. Rekaman aslimu disimpan sampai kamu membuangnya, jadi kamu selalu dapat kembali dan memotongnya dengan cara berbeda.

Kamu memulai Monologue melalui peluncur aplikasi (`Super + Space`).
