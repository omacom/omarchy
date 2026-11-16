# GUIs

## Files

Files (Nautilus) adalah pengelola berkas grafis. `Super + Shift + F` membukanya, dan `Super + Shift + Alt + F` membukanya di direktori tempat terminalmu berada, yang menghemat banyak klik. `Ctrl + L` memungkinkanmu mengetik sebuah jalur, dan menekan `Space` pada berkas apa pun memberimu pratinjau cepat tanpa membuka apa pun.

Colokkan stik USB atau kartu SD dan itu akan dipasang secara otomatis, jadi langsung muncul di bilah sisi. Untuk hal yang lebih rumit — memformat drive, memeriksa kesehatan SMART, membuat partisi — luncurkan _Disks_ dari peluncur aplikasi (`Super + Space`).

Klik ganda mengikuti default yang masuk akal: gambar, video, dan musik terbuka di Omaview, PDF di Document Viewer, Markdown di Omawrite, dan teks biasa di editor yang dipilih di bawah _Setup > Default > Editor_.

## Disktree

Ketika drive penuh dan kamu tidak tahu apa yang memakannya, luncurkan [Disktree](https://github.com/tobi/disktree) dari peluncur aplikasi (`Super + Space`). Ini menampilkan treemap grafis dari direktori home-mu. Blok yang lebih besar memakan lebih banyak ruang; masuklah ke direktori dengan keyboard atau mouse, tandai apa yang harus dibuang, dan tinjau pilihanmu sebelum menghapus apa pun. Jalankan `disktree --disk` untuk memindai seluruh disk.

## Obsidian

[Obsidian](https://obsidian.md/) adalah aplikasi pencatatan gratis dan sangat dapat diperluas yang menggunakan berkas Markdown sederhana untuk penyimpanan.

Obsidian gratis untuk semua keperluan, termasuk penggunaan pribadi, komersial, dan nirlaba.

Obsidian juga menawarkan [add-on komersial untuk sinkronisasi](https://obsidian.md/sync) dengan aplikasi seluler di iOS dan Android. (https://obsidian.md/pricing).

Kamu memulai Obsidian dengan `Super + Shift + O`. Untuk menggunakan sinkronisasi tema, kamu harus memilih tema `Omarchy` di bawah pengaturan.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) adalah aplikasi menulis Markdown Omarchy sendiri yang sangat sederhana. Tanpa vault, tanpa plugin, hanya kamu dan kata-katamu.

Kamu memulai Omawrite dengan `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) adalah alat pengeditan gambar dasar yang hebat untuk memotong, mengubah ukuran, dan manipulasi dasar lainnya. Jangan berharap ini jadi alternatif Photoshop. Tapi tetap ada Magic Wand dan layer!

Kamu memulai Pinta melalui peluncur aplikasi (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) adalah aplikasi pembuatan tema yang dapat mengekstrak warna dari gambar latar belakang dan mengubahnya menjadi tema yang lengkap dan kohesif. Ini cara termudah untuk [membuat temamu sendiri](43-making-your-own-theme.md).

Kamu memulai Aether melalui peluncur aplikasi (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) memungkinkanmu mengirim berkas ke perangkat lain di jaringan yang sama yang menjalankan aplikasi ini, seperti AirDrop dari Apple. Tapi ini lintas platform, jadi kamu bisa mengirim berkas ke dan dari Windows, macOS, Android, iOS, dan tentu saja Linux.

Kamu bisa membuka menu Share di `Super + Ctrl + S` atau di bawah _Trigger > Share_ di menu Omarchy. Ini memberimu empat pilihan:

- **Clipboard** mengirim apa pun yang telah kamu salin sebagai berkas teks. Bagus untuk memasukkan tautan atau potongan teks ke ponselmu tanpa mengirim email ke diri sendiri.
- **File** membuka pemilih berkas tempat kamu bisa memilih beberapa sekaligus.
- **Folder** mengirim seluruh direktori.
- **Receive** membuka LocalSend yang sesungguhnya agar perangkat lain bisa mengirim sesuatu kepadamu.

Hal yang sama bekerja dari terminal dengan `omarchy share clipboard`, `omarchy share file [path]`, dan `omarchy share folder [path]`. Hilangkan jalurnya dan kamu mendapatkan pemilihnya.

Kamu juga bisa mengirim langsung dari pengelola berkas: klik kanan pilihan apa pun di Nautilus dan pilih _Send via LocalSend_.

Firewall Omarchy tertutup secara default kecuali untuk port LocalSend, jadi ini bekerja langsung sejak awal pada instalasi baru. Lihat [security](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) adalah paket perkantoran lengkap dengan pengolah kata, spreadsheet, presentasi, aplikasi menggambar, dan banyak lagi. Ini kompatibel dengan berkas dari Microsoft Office, jadi ini cara yang bagus untuk bisa membuka dokumen Word tersebut.

Kamu memulai LibreOffice melalui peluncur aplikasi (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) adalah aplikasi presentasi Omarchy sendiri yang sangat sederhana. Deck-mu adalah satu berkas Markdown tunggal dengan gambar dan videonya di sampingnya: tulis setiap slide di bawah pratinjau langsung, seret slide ke urutannya, lalu presentasikan dalam layar penuh atau ekspor ke PDF dan PowerPoint. Ini bahkan mengambil tema Omarchy-mu.

Kamu memulai Hype melalui peluncur aplikasi (`Super + Space`). Tekan `?` di dalamnya untuk melihat setiap pintasan.

## Signed

[Signed](https://github.com/omacom/signed) adalah cara Omarchy sendiri yang sangat sederhana untuk menandatangani PDF dan mengisinya. Letakkan tanda tangan tersimpanmu, teks, dan tanggal hari ini di mana saja pada halaman, lalu simpan salinan yang ditandatangani di samping aslinya. Lihat [Filling out PDFs](27-filling-out-pdfs.md) untuk caranya.

Kamu memulai Signed melalui peluncur aplikasi (`Super + Space`), atau membuka PDF dengannya dari pengelola berkas.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) adalah permainan catur 3D Omarchy sendiri. Mainkan teman di komputer yang sama atau lawan bawaan pada tiga level, pada empat set pahatan yang masing-masing bergerak dengan caranya sendiri: wahana orbital, kayu dan gading ukiran, makhluk hutan, dan permen. Permainan tidak memiliki jam dan tersimpan setelah setiap langkah.

Kamu memulai Checkmate melalui peluncur aplikasi (`Super + Space`), tempat ini terdaftar sebagai Chess. Tekan `?` di dalamnya untuk melihat setiap pintasan.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) adalah kalkulator Omarchy sendiri yang sangat sederhana, yang terbuka di jendela mengambang.

Kamu memulai Omacalc dengan `Super + Shift + Q` (atau tombol kalkulator, jika keyboardmu memilikinya).

## Signal

[Signal](https://signal.org/) adalah pelopor perpesanan terenkripsi E2E, dan pilihan komunikasi yang bagus bagi siapa pun yang lebih suka tidak melalui salah satu konglomerat teknologi besar.

Kamu memulai Signal dengan `Super + Shift + G`. Ini bukan bagian dari instalasi dasar, jadi pertama kali kamu menekannya, Omarchy akan menawarkan untuk memasangnya untukmu (ini juga ada di bawah _Install > Service_ di menu Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) adalah penampil gambar dan pemutar media Omarchy sendiri yang sangat sederhana: satu jendela untuk foto, video, dan musikmu. Buka foto dan tombol panah melangkah melalui sisa foldernya, `N` dan `P` melakukannya untuk apa pun, dan `Ctrl + M` menampilkan seluruh folder sebagai kisi. Ini juga menampilkan foto HEIC, AVIF, dan JPEG XL, dan melanjutkan dari tempat terakhir kamu berhenti pada apa pun yang panjang.

Tekan `F` untuk layar penuh, `E` untuk mengedit gambar di Omasnap atau memangkas video di Omacut, `Ctrl + P` untuk mencetak gambar, dan `Delete` untuk memindahkan berkas ke Trash (`Ctrl + Z` mengembalikannya). Tekan `?` di dalamnya untuk melihat setiap pintasan.

Kamu memulai Omaview sebagai _Media Viewer_ melalui peluncur aplikasi (`Super + Space`), atau cukup klik ganda gambar, video, atau lagu di pengelola berkas.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) adalah pemangkas video Omarchy sendiri yang sangat sederhana. Ketika yang kamu butuhkan hanyalah memotong awal dan akhir klip, ini lebih baik daripada menyalakan editor video lengkap.

Kamu memulai Omacut melalui peluncur aplikasi (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) adalah perekam webcam Omarchy sendiri yang sangat sederhana. Pilih kamera dan mikrofonmu sekali, lalu tekan `Space` untuk merekam, dan lagi untuk menjeda dan melanjutkan take yang sama. Ini selalu merekam pada resolusi tertinggi kameramu, dengan meter mikrofon langsung agar kamu bisa memeriksa levelmu sebelum mulai.

Hentikan take dan itu langsung terbuka di editor bawaan. Klik ganda klip untuk membaginya, seret handle untuk memangkas setiap bagian, dan hapus bagian yang tidak kamu inginkan. Lalu simpan sebagai MP4. Rekaman aslimu disimpan sampai kamu membuangnya, jadi kamu selalu bisa kembali dan memotongnya secara berbeda.

Kamu memulai Monologue melalui peluncur aplikasi (`Super + Space`).
