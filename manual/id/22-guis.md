# GUI

## Files

Files (Nautilus) adalah manajer berkas grafis. `Super + Shift + F` membukanya, dan `Super + Shift + Alt + F` membukanya di direktori tempat terminalmu berada, yang menghemat banyak klik. `Ctrl + L` memungkinkan kamu mengetik jalur, dan menekan `Space` pada berkas apa pun memberimu pratinjau cepat tanpa membuka apa pun.

Colokkan stik USB atau kartu SD dan itu ter-mount secara otomatis, jadi langsung muncul di bilah sisi. Untuk hal yang lebih rumit — memformat drive, memeriksa kesehatan SMART, membuat partisi — luncurkan _Disks_ dari peluncur aplikasi (`Super + Space`).

Klik dua kali mengikuti bawaan yang masuk akal: gambar terbuka di imv, video di mpv, PDF di Document Viewer, dan teks biasa di Neovim.

## Disktree

Saat drive penuh dan kamu tidak tahu apa yang memakannya, luncurkan [Disktree](https://github.com/tobi/disktree) dari peluncur aplikasi (`Super + Space`). Ini menunjukkan treemap grafis dari direktori rumahmu. Blok yang lebih besar memakan lebih banyak ruang; telusuri direktori dengan keyboard atau mouse, tandai apa yang harus pergi, dan tinjau pilihanmu sebelum menghapus apa pun. Jalankan `disktree --disk` untuk memindai seluruh disk.

## Obsidian

[Obsidian](https://obsidian.md/) adalah aplikasi pencatat gratis dan sangat dapat diperluas yang menggunakan berkas Markdown sederhana untuk penyimpanan.

Obsidian gratis untuk semua keperluan, termasuk penggunaan pribadi, komersial, dan nirlaba.

Obsidian juga menawarkan [add-on komersial untuk sinkronisasi](https://obsidian.md/sync) dengan aplikasi seluler di iOS dan Android. (https://obsidian.md/pricing).

Kamu memulai Obsidian dengan `Super + Shift + O`. Untuk menggunakan sinkronisasi tema, kamu harus memilih tema `Omarchy` di bawah pengaturan.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) adalah aplikasi penulisan Markdown Omarchy sendiri yang sangat sederhana. Tanpa vault, tanpa plugin, hanya kamu dan kata-kata.

Kamu memulai Omawrite dengan `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) adalah alat pengedit gambar dasar yang bagus untuk memotong, mengubah ukuran, dan manipulasi dasar lainnya. Jangan berharap alternatif Photoshop. Tetapi ini tetap punya Magic Wand dan layer!

Kamu memulai Pinta melalui peluncur aplikasi (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) adalah aplikasi tema yang dapat mengekstrak warna dari gambar latar belakang dan mengubahnya menjadi tema yang lengkap dan kohesif. Ini adalah cara termudah untuk [membuat tema sendiri](43-making-your-own-theme.md).

Kamu memulai Aether melalui peluncur aplikasi (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) memungkinkan kamu mengirim berkas ke perangkat lain di jaringan yang sama yang menjalankan aplikasi tersebut, seperti AirDrop dari Apple. Namun ini lintas platform, jadi kamu dapat mengirim berkas ke dan dari Windows, macOS, Android, iOS, dan tentu saja Linux.

Kamu dapat membuka menu Bagikan pada `Super + Ctrl + S` atau di bawah _Pemicu > Bagikan_ di menu Omarchy. Ini memberimu empat pilihan:

- **Papan Klip** mengirim apa pun yang telah kamu salin sebagai berkas teks. Bagus untuk memindahkan tautan atau cuplikan ke ponselmu tanpa mengirim email ke diri sendiri.
- **Berkas** membuka pemilih berkas di mana kamu dapat memilih beberapa sekaligus.
- **Folder** mengirim seluruh direktori.
- **Terima** membuka LocalSend yang sebenarnya agar perangkat lain dapat mengirim sesuatu kepadamu.

Hal yang sama bekerja dari terminal dengan `omarchy share clipboard`, `omarchy share file [path]`, dan `omarchy share folder [path]`. Hilangkan jalurnya dan kamu mendapatkan pemilih.

Kamu juga dapat mengirim langsung dari manajer berkas: klik kanan pilihan apa pun di Nautilus dan pilih _Send via LocalSend_.

Firewall Omarchy tertutup secara bawaan kecuali untuk port LocalSend, jadi ini bekerja langsung pada pemasangan baru. Lihat [keamanan](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) adalah paket perkantoran lengkap dengan pengolah kata, spreadsheet, presentasi, aplikasi gambar, dan lainnya. Ini kompatibel dengan berkas dari Microsoft Office, jadi ini adalah cara bagus untuk dapat membuka dokumen Word tersebut.

Kamu memulai LibreOffice melalui peluncur aplikasi (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) adalah aplikasi presentasi Omarchy sendiri yang sangat sederhana. Dek-mu adalah satu berkas Markdown dengan gambar dan videonya di sampingnya: tulis setiap slide di bawah pratinjau langsung, seret slide ke urutan, kemudian presentasikan layar penuh atau ekspor ke PDF dan PowerPoint. Ini bahkan mengikuti tema Omarchy-mu.

Kamu memulai Hype melalui peluncur aplikasi (`Super + Space`). Tekan `?` di dalamnya untuk melihat setiap pintasan.

## Signed

[Signed](https://github.com/omacom/signed) adalah cara Omarchy sendiri yang sangat sederhana untuk menandatangani PDF dan mengisinya. Letakkan tanda tangan tersimpan, teks, dan tanggal hari ini di mana saja pada halaman, kemudian simpan salinan yang ditandatangani di samping aslinya. Lihat [Mengisi PDF](27-filling-out-pdfs.md) untuk caranya.

Kamu memulai Signed melalui peluncur aplikasi (`Super + Space`), atau membuka PDF dengannya dari manajer berkas.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) adalah kalkulator Omarchy sendiri yang sangat sederhana, yang terbuka dalam jendela melayang.

Kamu memulai Omacalc dengan `Super + Ctrl + Q` (atau tombol kalkulator, jika keyboard-mu memilikinya).

## Signal

[Signal](https://signal.org/) adalah pelopor perpesanan terenkripsi E2E, dan pilihan komunikasi yang bagus bagi siapa pun yang lebih suka tidak melalui salah satu konglomerat teknologi besar.

Kamu memulai Signal dengan `Super + Shift + G`. Ini bukan bagian dari pemasangan dasar, jadi pertama kali kamu menekan itu, Omarchy akan menawarkan untuk memasangnya untukmu (ini juga ada di bawah _Pasang > Service_ di menu Omarchy).

## mpv

[mpv](https://mpv.io/) adalah pemutar media sederhana dan cepat yang akan memutar hampir apa saja dari sumber mana pun. Bagus untuk menonton video.

Kamu memulai mpv melalui peluncur aplikasi (`Super + Space`) atau cukup klik dua kali pada video di manajer berkas.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) adalah pemangkas video Omarchy sendiri yang sangat sederhana. Saat yang kamu butuhkan hanyalah memotong awal dan akhir klip, ini mengalahkan menyalakan editor video penuh.

Kamu memulai Omacut melalui peluncur aplikasi (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) adalah perekam webcam Omarchy sendiri yang sangat sederhana. Pilih kamera dan mikrofonmu sekali, kemudian tekan `Space` untuk merekam, dan lagi untuk menjeda dan melanjutkan pengambilan yang sama. Ini selalu merekam pada resolusi tertinggi kameramu, dengan meter mikrofon langsung sehingga kamu dapat memeriksa levelmu sebelum memulai.

Hentikan pengambilan dan itu langsung terbuka di editor bawaan. Klik dua kali klip untuk membaginya, seret pegangan untuk memangkas setiap bagian, dan hapus bagian yang tidak kamu inginkan. Kemudian simpan sebagai MP4. Rekaman aslimu disimpan sampai kamu membuangnya, jadi kamu selalu dapat kembali dan memotongnya secara berbeda.

Kamu memulai Monologue melalui peluncur aplikasi (`Super + Space`).
