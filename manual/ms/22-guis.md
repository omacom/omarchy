# GUI

## Fail

Files (Nautilus) ialah pengurus fail grafik. `Super + Shift + F` membukanya, dan `Super + Shift + Alt + F` membukanya dalam direktori tempat terminal anda berada, yang menjimatkan banyak klik. `Ctrl + L` membolehkan anda menaip laluan, dan menekan `Space` pada mana-mana fail memberikan anda pratonton pantas tanpa membuka apa-apa.

Pasangkan batang USB atau kad SD dan ia akan dilekap secara automatik, jadi ia muncul begitu sahaja di bar sisi. Untuk apa-apa yang lebih terlibat — memformat pemacu, menyemak kesihatan SMART, mencipta partition — lancarkan _Disks_ daripada pelancar aplikasi (`Super + Space`).

Double-click mengikut lalai yang munasabah: imej dibuka dalam imv, video dalam mpv, PDF dalam Document Viewer, dan teks biasa dalam Neovim.

## Disktree

Apabila pemacu penuh dan anda tidak tahu apa yang memakannya, lancarkan [Disktree](https://github.com/tobi/disktree) daripada pelancar aplikasi (`Super + Space`). Ia menunjukkan treemap grafik direktori rumah anda. Blok yang lebih besar mengambil lebih banyak ruang; masuk ke direktori dengan papan kekunci atau tetikus, tandakan apa yang perlu dibuang, dan semak pilihan anda sebelum membuang apa-apa. Jalankan `disktree --disk` untuk mengimbas keseluruhan cakera.

## Obsidian

[Obsidian](https://obsidian.md/) ialah aplikasi mencatat nota percuma dan sangat boleh dilanjutkan yang menggunakan fail Markdown mudah untuk storan.

Obsidian adalah percuma untuk semua tujuan, termasuk kegunaan peribadi, komersial, dan bukan untuk keuntungan.

Obsidian juga menawarkan [tambahan komersial untuk penyegerakan](https://obsidian.md/sync) dengan aplikasi mudah alih pada iOS dan Android. (https://obsidian.md/pricing).

Anda memulakan Obsidian dengan `Super + Shift + O`. Untuk menggunakan penyegerakan tema, anda mesti memilih tema `Omarchy` di bawah tetapan.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ialah aplikasi menulis Markdown milik Omarchy yang sangat mudah. Tiada vault, tiada plugin, hanya anda dan kata-kata.

Anda memulakan Omawrite dengan `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ialah alat penyuntingan imej asas yang hebat untuk crop, saiz semula, dan manipulasi asas lain. Jangan mengharapkannya sebagai alternatif Photoshop. Tetapi ia masih ada Magic Wand dan lapisan!

Anda memulakan Pinta melalui pelancar aplikasi (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ialah aplikasi penemaan yang boleh mengekstrak warna daripada imej latar belakang dan menukarkannya kepada tema yang lengkap dan padu. Ia ialah cara termudah untuk [membuat tema sendiri](43-making-your-own-theme.md).

Anda memulakan Aether melalui pelancar aplikasi (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) membolehkan anda menghantar fail ke peranti lain pada rangkaian yang sama yang menjalankan apl itu, seperti AirDrop Apple. Walaupun begitu, ia merentas platform, jadi anda boleh menghantar fail ke dan dari Windows, macOS, Android, iOS, dan sudah tentu Linux.

Anda boleh membuka menu Share pada `Super + Ctrl + S` atau di bawah _Pencetus > Kongsi_ dalam menu Omarchy. Ia memberikan anda empat pilihan:

- **Clipboard** menghantar apa-apa yang telah anda salin sebagai fail teks. Hebat untuk memindahkan pautan atau snippet ke telefon anda tanpa menghantar e-mel kepada diri sendiri.
- **File** membuka pemilih fail di mana anda boleh memilih beberapa sekali gus.
- **Folder** menghantar keseluruhan direktori.
- **Receive** membuka LocalSend sebenar supaya peranti lain boleh menghantar sesuatu kepada anda.

Perkara yang sama berfungsi daripada terminal dengan `omarchy share clipboard`, `omarchy share file [path]`, dan `omarchy share folder [path]`. Tinggalkan laluan dan anda akan mendapat pemilih.

Anda juga boleh menghantar terus daripada pengurus fail: klik kanan mana-mana pilihan dalam Nautilus dan pilih _Send via LocalSend_.

Firewall Omarchy ditutup secara lalai kecuali untuk port LocalSend, jadi ini berfungsi terus tanpa persediaan pada pemasangan baharu. Lihat [keselamatan](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ialah pakej pejabat lengkap dengan pemproses perkataan, hamparan kerja, persembahan, aplikasi lukisan, dan banyak lagi. Ia serasi dengan fail daripada Microsoft Office, jadi ini cara yang hebat untuk dapat membuka dokumen Word itu.

Anda memulakan LibreOffice melalui pelancar aplikasi (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ialah aplikasi persembahan milik Omarchy yang sangat mudah. Dek anda ialah satu fail Markdown dengan imej dan videonya bersebelahan: tulis setiap slaid di bawah pratonton langsung, seret slaid mengikut urutan, kemudian bentangkan skrin penuh atau eksport ke PDF dan PowerPoint. Ia juga mengambil tema Omarchy anda.

Anda memulakan Hype melalui pelancar aplikasi (`Super + Space`). Tekan `?` di dalamnya untuk melihat setiap pintasan.

## Signed

[Signed](https://github.com/omacom/signed) ialah cara mudah milik Omarchy untuk menandatangani PDF dan mengisikannya. Letakkan tandatangan yang disimpan, teks, dan tarikh hari ini di mana-mana halaman, kemudian simpan salinan bertandatangan bersebelahan yang asal. Lihat [Mengisi PDF](27-filling-out-pdfs.md) untuk caranya.

Anda memulakan Signed melalui pelancar aplikasi (`Super + Space`), atau membuka PDF dengannya daripada pengurus fail.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ialah kalkulator milik Omarchy yang sangat mudah, yang dibuka dalam tetingkap terapung.

Anda memulakan Omacalc dengan `Super + Ctrl + Q` (atau kekunci kalkulator, jika papan kekunci anda ada).

## Signal

[Signal](https://signal.org/) ialah perintis pemesejan terenkripsi E2E, dan pilihan komunikasi yang hebat untuk sesiapa yang lebih suka tidak melalui salah satu konglomerat teknologi besar.

Anda memulakan Signal dengan `Super + Shift + G`. Ia bukan sebahagian daripada pemasangan asas, jadi kali pertama anda menekannya, Omarchy akan menawarkan untuk memasangnya untuk anda (ia juga berada di bawah _Pasang > Perkhidmatan_ dalam menu Omarchy).

## mpv

[mpv](https://mpv.io/) ialah pemain media yang mudah dan pantas yang akan memainkan hampir apa sahaja daripada mana-mana sumber. Hebat untuk menonton video.

Anda memulakan mpv melalui pelancar aplikasi (`Super + Space`) atau double-click sahaja pada video dalam pengurus fail.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ialah pemangkas video milik Omarchy yang sangat mudah. Apabila anda hanya perlu memotong permulaan dan pengakhiran klip, ia lebih baik daripada memulakan penyunting video penuh.

Anda memulakan Omacut melalui pelancar aplikasi (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ialah perakam webcam milik Omarchy yang sangat mudah. Pilih kamera dan mikrofon anda sekali, kemudian tekan `Space` untuk merakam, dan sekali lagi untuk menjeda dan menyambung semula rakaman yang sama. Ia sentiasa merakam pada resolusi tertinggi kamera anda, dengan meter mikrofon langsung supaya anda boleh menyemak tahap anda sebelum bermula.

Hentikan rakaman dan ia dibuka serta-merta dalam penyunting terbina. Double-click klip untuk membahagikannya, seret pemegang untuk memangkas setiap bahagian, dan buang bahagian yang anda tidak mahu. Kemudian simpannya sebagai MP4. Rakaman asal anda disimpan sehingga anda membuangnya, jadi anda boleh kembali dan memotongnya secara berbeza.

Anda memulakan Monologue melalui pelancar aplikasi (`Super + Space`).
