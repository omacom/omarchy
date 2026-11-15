# GUIs

## Files

Files (Nautilus) adalah pengelola file grafis. `Super + Shift + F` membukanya, dan `Super + Shift + Alt + F` membukanya di direktori tempat terminal Anda berada, yang menghemat banyak klik. `Ctrl + L` memungkinkan Anda mengetikkan sebuah path, dan menekan `Space` pada file apa pun memberi Anda pratinjau cepat tanpa membuka apa pun.

Colokkan stik USB atau kartu SD dan itu akan ter-mount secara otomatis, jadi langsung muncul di sidebar. Untuk hal yang lebih rumit — memformat drive, memeriksa kesehatan SMART, membuat partisi — jalankan _Disks_ dari peluncur aplikasi (`Super + Space`).

Klik ganda mengikuti default yang masuk akal: gambar, video, dan musik terbuka di Omaview, PDF di Document Viewer, dan teks biasa di Neovim.

## Disktree

Ketika drive terisi penuh dan Anda tidak tahu apa yang memakannya, jalankan [Disktree](https://github.com/tobi/disktree) dari peluncur aplikasi (`Super + Space`). Ini menampilkan treemap grafis dari direktori home Anda. Blok yang lebih besar memakan lebih banyak ruang; masuk ke direktori dengan keyboard atau mouse, tandai apa yang harus dibuang, dan tinjau pilihan Anda sebelum menghapus apa pun. Jalankan `disktree --disk` untuk memindai seluruh disk.

## Obsidian

[Obsidian](https://obsidian.md/) adalah aplikasi pencatatan gratis dan sangat dapat diperluas yang menggunakan file Markdown sederhana untuk penyimpanan.

Obsidian gratis untuk semua tujuan, termasuk penggunaan pribadi, komersial, dan nirlaba.

Obsidian juga menawarkan [add-on komersial untuk sinkronisasi](https://obsidian.md/sync) dengan aplikasi seluler di iOS dan Android. (https://obsidian.md/pricing).

Anda memulai Obsidian dengan `Super + Shift + O`. Untuk menggunakan sinkronisasi tema, Anda harus memilih tema `Omarchy` di bawah pengaturan.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) adalah aplikasi menulis Markdown Omarchy sendiri yang sangat sederhana. Tidak ada vault, tidak ada plugin, hanya Anda dan kata-kata.

Anda memulai Omawrite dengan `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) adalah alat pengeditan gambar dasar yang bagus untuk memotong, mengubah ukuran, dan manipulasi dasar lainnya. Hanya saja jangan berharap ini menjadi alternatif Photoshop. Tapi tetap ada Magic Wand dan layer!

Anda memulai Pinta melalui peluncur aplikasi (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) adalah aplikasi tema yang dapat mengekstrak warna dari gambar latar belakang dan mengubahnya menjadi tema yang lengkap dan kohesif. Ini adalah cara termudah untuk [membuat tema Anda sendiri](43-making-your-own-theme.md).

Anda memulai Aether melalui peluncur aplikasi (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) memungkinkan Anda mengirim file ke perangkat lain di jaringan yang sama yang menjalankan aplikasi ini, seperti AirDrop dari Apple. Namun ini lintas platform, jadi Anda dapat mengirim file ke dan dari Windows, macOS, Android, iOS, dan tentu saja Linux.

Anda dapat membuka menu Share pada `Super + Ctrl + S` atau di bawah _Trigger > Share_ di menu Omarchy. Ini memberi Anda empat opsi:

- **Clipboard** mengirim apa pun yang telah Anda salin sebagai file teks. Bagus untuk mengirim tautan atau cuplikan ke ponsel Anda tanpa harus mengirim email ke diri sendiri.
- **File** membuka pemilih file tempat Anda dapat memilih beberapa sekaligus.
- **Folder** mengirim seluruh direktori.
- **Receive** membuka LocalSend yang sebenarnya agar perangkat lain dapat mengirim sesuatu kepada Anda.

Hal yang sama bekerja dari terminal dengan `omarchy share clipboard`, `omarchy share file [path]`, dan `omarchy share folder [path]`. Hilangkan path-nya dan Anda akan mendapatkan pemilihnya.

Anda juga dapat mengirim langsung dari pengelola file: klik kanan pilihan apa pun di Nautilus dan pilih _Send via LocalSend_.

Firewall Omarchy tertutup secara default kecuali untuk port LocalSend, jadi ini bekerja langsung pada instalasi baru. Lihat [keamanan](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) adalah paket perkantoran lengkap dengan pengolah kata, spreadsheet, presentasi, aplikasi menggambar, dan banyak lagi. Ini kompatibel dengan file dari Microsoft Office, jadi ini adalah cara yang bagus untuk dapat membuka dokumen Word tersebut.

Anda memulai LibreOffice melalui peluncur aplikasi (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) adalah aplikasi presentasi Omarchy sendiri yang sangat sederhana. Deck Anda adalah satu file Markdown dengan gambar dan videonya di sampingnya: tulis setiap slide di bawah pratinjau langsung, seret slide untuk mengurutkannya, lalu presentasikan dalam layar penuh atau ekspor ke PDF dan PowerPoint. Ia bahkan mengikuti tema Omarchy Anda.

Anda memulai Hype melalui peluncur aplikasi (`Super + Space`). Tekan `?` di dalamnya untuk melihat setiap pintasan.

## Signed

[Signed](https://github.com/omacom/signed) adalah cara Omarchy sendiri yang sangat sederhana untuk menandatangani PDF dan mengisinya. Letakkan tanda tangan tersimpan Anda, teks, dan tanggal hari ini di mana saja pada sebuah halaman, lalu simpan salinan yang telah ditandatangani di samping aslinya. Lihat [Mengisi PDF](27-filling-out-pdfs.md) untuk caranya.

Anda memulai Signed melalui peluncur aplikasi (`Super + Space`), atau membuka PDF dengannya dari pengelola file.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) adalah kalkulator Omarchy sendiri yang sangat sederhana, yang terbuka dalam jendela melayang.

Anda memulai Omacalc dengan `Super + Shift + Q` (atau tombol kalkulator, jika keyboard Anda memilikinya).

## Signal

[Signal](https://signal.org/) adalah pelopor perpesanan terenkripsi E2E, dan opsi komunikasi yang bagus bagi siapa pun yang lebih memilih untuk tidak melalui salah satu konglomerat teknologi besar.

Anda memulai Signal dengan `Super + Shift + G`. Ini bukan bagian dari instalasi dasar, jadi pertama kali Anda menekannya, Omarchy akan menawarkan untuk menginstalnya untuk Anda (ini juga tersedia di bawah _Install > Service_ di menu Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) adalah penampil gambar dan pemutar media Omarchy sendiri yang sangat sederhana: satu jendela untuk foto, video, dan musik Anda. Buka sebuah foto dan tombol panah melangkah melalui sisa foldernya, `N` dan `P` melakukannya untuk apa pun, dan `Ctrl + M` menampilkan seluruh folder sebagai grid. Ini juga menampilkan foto HEIC, AVIF, dan JPEG XL, dan melanjutkan dari tempat Anda berhenti pada apa pun yang panjang.

Tekan `F` untuk layar penuh, `E` untuk mengedit gambar di Omasnap atau memotong video di Omacut, `Ctrl + P` untuk mencetak gambar, dan `Delete` untuk memindahkan file ke Trash (`Ctrl + Z` mengembalikannya). Tekan `?` di dalamnya untuk melihat setiap pintasan.

Anda memulai Omaview sebagai _Media Viewer_ melalui peluncur aplikasi (`Super + Space`), atau cukup klik ganda gambar, video, atau lagu di pengelola file.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) adalah pemotong video Omarchy sendiri yang sangat sederhana. Ketika yang Anda butuhkan hanyalah memotong bagian awal dan akhir sebuah klip, ini lebih baik daripada repot-repot membuka editor video lengkap.

Anda memulai Omacut melalui peluncur aplikasi (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) adalah perekam webcam Omarchy sendiri yang sangat sederhana. Pilih kamera dan mikrofon Anda sekali, lalu tekan `Space` untuk merekam, dan lagi untuk menjeda dan melanjutkan pengambilan yang sama. Ini selalu merekam pada resolusi tertinggi kamera Anda, dengan meteran mikrofon langsung agar Anda dapat memeriksa level Anda sebelum memulai.

Hentikan pengambilan dan itu akan langsung terbuka di editor bawaan. Klik ganda sebuah klip untuk membaginya, seret handle untuk memotong setiap bagian, dan hapus bagian yang tidak Anda inginkan. Lalu simpan sebagai MP4. Rekaman asli Anda disimpan sampai Anda membuangnya, jadi Anda selalu dapat kembali dan memotongnya dengan cara yang berbeda.

Anda memulai Monologue melalui peluncur aplikasi (`Super + Space`).
