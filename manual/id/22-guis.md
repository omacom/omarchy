# GUIs

## Files

Files (Folio) adalah pengelola berkas grafis. `Super + Shift + F` membukanya, dan `Super + Shift + Alt + F` membukanya di direktori tempat terminalmu berada, yang menghemat banyak klik. `Ctrl + L` memungkinkanmu mengetik jalur, dan menekan `Space` pada berkas apa pun mempratinjaunya dalam ukuran penuh tanpa membukanya.

Colokkan stik USB atau kartu SD dan itu akan terpasang secara otomatis, jadi langsung muncul di bilah sisi. Untuk hal yang lebih rumit — memformat drive, memeriksa kesehatan SMART, membuat partisi — luncurkan _Disks_ dari peluncur aplikasi (`Super + Space`).

Klik dua kali mengikuti default yang masuk akal: gambar, video, dan musik terbuka di Omaview, PDF di Document Viewer, Markdown di Omawrite, dan teks biasa di editormu, Plain kecuali kamu memilih yang lain di _Setup > Defaults > Editor_.

## Disktree

Ketika drive penuh dan kamu tidak tahu apa yang memakannya, luncurkan [Disktree](https://github.com/tobi/disktree) dari peluncur aplikasi (`Super + Space`). Ini menampilkan treemap grafis dari direktori home-mu. Blok yang lebih besar memakan lebih banyak ruang; masuk ke direktori dengan keyboard atau mouse, tandai apa yang harus dibuang, dan tinjau pilihanmu sebelum menghapus apa pun. Jalankan `disktree --disk` untuk memindai seluruh disk.

## Obsidian

[Obsidian](https://obsidian.md/) adalah aplikasi pencatat gratis dan sangat dapat diperluas yang menggunakan berkas Markdown sederhana untuk penyimpanan.

Obsidian gratis untuk semua keperluan, termasuk penggunaan pribadi, komersial, dan nirlaba.

Obsidian juga menawarkan [add-on komersial untuk sinkronisasi](https://obsidian.md/sync) dengan aplikasi seluler di iOS dan Android. (https://obsidian.md/pricing).

Kamu memulai Obsidian dengan `Super + Shift + O`. Untuk menggunakan sinkronisasi tema, kamu harus memilih tema `Omarchy` di pengaturan.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) adalah aplikasi penulisan Markdown Omarchy sendiri yang sangat sederhana. Tanpa vault, tanpa plugin, hanya kamu dan kata-kata.

Kamu memulai Omawrite dengan `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) adalah alat pengeditan gambar dasar yang bagus untuk memotong, mengubah ukuran, dan manipulasi dasar lainnya. Jangan berharap ini alternatif Photoshop. Tapi tetap ada Magic Wand dan layer!

Kamu memulai Pinta melalui peluncur aplikasi (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) adalah aplikasi tema yang dapat mengekstrak warna dari gambar latar dan mengubahnya menjadi tema yang lengkap dan kohesif. Ini cara termudah untuk [membuat temamu sendiri](43-making-your-own-theme.md).

Kamu memulai Aether melalui peluncur aplikasi (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) memungkinkanmu mengirim berkas ke perangkat lain di jaringan yang sama yang menjalankan aplikasi tersebut, seperti AirDrop dari Apple. Namun ini lintas platform, jadi kamu dapat mengirim berkas ke dan dari Windows, macOS, Android, iOS, dan tentu saja Linux.

Kamu dapat membuka menu Share pada `Super + Ctrl + S` atau di _Trigger > Share_ di menu Omarchy. Ini memberimu empat pilihan:

- **Clipboard** mengirim apa pun yang telah kamu salin sebagai berkas teks. Bagus untuk memindahkan tautan atau potongan ke ponselmu tanpa mengirim email ke diri sendiri.
- **File** membuka pemilih berkas tempat kamu dapat memilih beberapa sekaligus.
- **Folder** mengirim seluruh direktori.
- **Receive** membuka LocalSend yang sesungguhnya agar perangkat lain dapat mengirim sesuatu kepadamu.

Hal yang sama bekerja dari terminal dengan `omarchy share clipboard`, `omarchy share file [path]`, dan `omarchy share folder [path]`. Hilangkan jalurnya dan kamu mendapatkan pemilih.

Kamu juga dapat mengirim langsung dari pengelola berkas: klik kanan pilihan apa pun di Files dan bagikan dengan LocalSend.

Firewall Omarchy tertutup secara default kecuali untuk port LocalSend, jadi ini bekerja langsung pada instalasi baru. Lihat [keamanan](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) adalah paket perkantoran lengkap dengan pengolah kata, spreadsheet, presentasi, aplikasi menggambar, dan banyak lagi. Ini kompatibel dengan berkas dari Microsoft Office, jadi ini cara yang bagus untuk dapat membuka dokumen Word tersebut.

Kamu memulai LibreOffice melalui peluncur aplikasi (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) adalah aplikasi presentasi Omarchy sendiri yang sangat sederhana. Dekmu adalah satu berkas Markdown dengan gambar dan videonya di sampingnya: tulis setiap slide di bawah pratinjau langsung, seret slide ke urutan, lalu presentasikan layar penuh atau ekspor ke PDF dan PowerPoint. Bahkan ia mengambil tema Omarchy-mu.

Kamu memulai Hype melalui peluncur aplikasi (`Super + Space`). Tekan `?` di dalamnya untuk melihat setiap pintasan.

## Signed

[Signed](https://github.com/omacom/signed) adalah cara Omarchy sendiri yang sangat sederhana untuk menandatangani PDF dan mengisinya. Letakkan tanda tangan tersimpanmu, teks, dan tanggal hari ini di mana saja pada halaman, lalu simpan salinan yang ditandatangani di samping aslinya. Lihat [Mengisi PDF](27-filling-out-pdfs.md) untuk caranya.

Kamu memulai Signed melalui peluncur aplikasi (`Super + Space`), atau membuka PDF dengannya dari pengelola berkas.

## Game Vibes

Game Vibes, di peluncur aplikasi (`Super + Space`), adalah tempat permainan kecil Omarchy berada: Checkmate, permainan catur 3D melawan teman atau lawan bawaan; Cards, solitaire Klondike; Death Wish, platformer presisi piksel berisi sepuluh ruangan penuh duri dan gergaji; dan Neon Swarm, penembak arcade. Masing-masing adalah satu halaman web yang mengikuti temamu. Pilih satu dengan panah dan `Enter`, dan kembali ke daftar dengan `Esc` dari layar judul permainan atau `Q` saat dijeda. Ini terbuka layar penuh: `Super + F` menjadikannya jendela, dan `Super + W` menutupnya.

Permainan yang kamu buat dengan agent juga muncul di sini: pilih _Make something cool → Game_ di panel agent dan jelaskan satu, atau sebutkan permainan yang sudah ada di Game Vibes untuk terus mengerjakannya. Agent menyalinnya ke `~/Games/vibes`, tempat itu milikmu untuk diubah, dan membukanya ketika selesai. Kamu dapat membuat salinan itu sendiri dengan `omarchy games vibes copy <game>`. Permainan yang dibagikan orang lain terinstal seperti tema: pilih _Install > Gaming > Game Vibes_ dan tempel alamat git-nya, atau jalankan `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ menghapusnya lagi, dan _Update > Game Vibes Games_ mengambil versi baru. Permainan memuat three.js dari web, jadi mereka membutuhkan koneksi untuk memulai.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) adalah kalkulator Omarchy sendiri yang sangat sederhana, yang terbuka dalam jendela mengambang.

Kamu memulai Omacalc dengan `Super + Shift + Q` (atau tombol kalkulator, jika keyboardmu memilikinya).

## Signal

[Signal](https://signal.org/) adalah pelopor perpesanan terenkripsi E2E, dan pilihan komunikasi yang bagus untuk siapa pun yang lebih suka tidak melalui salah satu konglomerat teknologi besar.

Kamu memulai Signal dengan `Super + Shift + G`. Ini bukan bagian dari instalasi dasar, jadi pertama kali kamu menekan itu, Omarchy akan menawarkan untuk menginstalnya untukmu (ini juga ada di _Install > Service_ di menu Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) adalah penampil gambar dan pemutar media Omarchy sendiri yang sangat sederhana: satu jendela untuk foto, video, dan musikmu. Buka foto dan tombol panah melangkah melalui sisa foldernya, `N` dan `P` melakukannya untuk apa pun, dan `Ctrl + M` menampilkan seluruh folder sebagai grid. Ini juga menampilkan foto HEIC, AVIF, dan JPEG XL, dan melanjutkan dari tempat terakhir kamu berhenti pada apa pun yang panjang.

Tekan `F` untuk layar penuh, `E` untuk mengedit gambar di Omasnap atau memangkas video di Omacut, `Ctrl + P` untuk mencetak gambar, dan `Delete` untuk memindahkan berkas ke Trash (`Ctrl + Z` mengembalikannya). Tekan `?` di dalamnya untuk melihat setiap pintasan.

Kamu memulai Omaview sebagai _Media Viewer_ melalui peluncur aplikasi (`Super + Space`), atau cukup klik dua kali gambar, video, atau lagu di pengelola berkas.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) adalah pemangkas video Omarchy sendiri yang sangat sederhana. Ketika yang kamu butuhkan hanyalah memotong awal dan akhir klip, ini mengalahkan menyalakan editor video lengkap.

Kamu memulai Omacut melalui peluncur aplikasi (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) adalah perekam webcam Omarchy sendiri yang sangat sederhana. Pilih kamera dan mikrofonmu sekali, lalu tekan `Space` untuk merekam, dan lagi untuk menjeda dan melanjutkan pengambilan yang sama. Ini selalu merekam pada resolusi tertinggi kameramu, dengan meter mikrofon langsung agar kamu dapat memeriksa levelmu sebelum memulai.

Hentikan pengambilan dan itu terbuka langsung dalam editor bawaan. Klik dua kali klip untuk membaginya, seret gagangnya untuk memangkas setiap potongan, dan hapus bagian yang tidak kamu inginkan. Lalu simpan sebagai MP4. Rekaman aslimu disimpan sampai kamu membuangnya, jadi kamu selalu dapat kembali dan memotongnya secara berbeda.

Kamu memulai Monologue melalui peluncur aplikasi (`Super + Space`).
