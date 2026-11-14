# GUI

## Fail

Files (Nautilus) ialah pengurus fail grafik. `Super + Shift + F` membukanya, dan `Super + Shift + Alt + F` membukanya dalam direktori tempat terminal anda berada, jadi anda jimat banyak klik. `Ctrl + L` membolehkan anda menaip laluan, dan menekan `Space` pada mana-mana fail memberi anda pratonton pantas tanpa membuka apa-apa.

Pasang pemacu USB atau kad SD dan ia dilekapkan secara automatik, jadi ia terus muncul di bar sisi. Untuk apa-apa yang lebih rumit — memformat pemacu, menyemak kesihatan SMART, mencipta partition — lancarkan _Disks_ daripada pelancar aplikasi (`Super + Space`).

Klik dua kali mengikut lalai yang munasabah: imej dibuka dalam imv, video dalam mpv, PDF dalam Document Viewer, dan teks biasa dalam Neovim.

## Disktree

Apabila pemacu penuh dan anda tidak tahu apa yang memakannya, lancarkan [Disktree](https://github.com/tobi/disktree) daripada pelancar aplikasi (`Super + Space`). Ia menunjukkan peta pokok grafik bagi direktori rumah anda. Blok yang lebih besar mengambil lebih banyak ruang; masuk ke direktori dengan papan kekunci atau tetikus, tandakan apa yang patut dibuang, dan semak pilihan anda sebelum membuang apa-apa. Jalankan `disktree --disk` untuk mengimbas keseluruhan cakera.

## Obsidian

[Obsidian](https://obsidian.md/) ialah aplikasi catatan percuma dan sangat boleh diperluas yang menggunakan fail Markdown ringkas untuk storan.

Obsidian adalah percuma untuk semua tujuan, termasuk kegunaan peribadi, komersial, dan bukan keuntungan.

Obsidian juga menawarkan [tambahan komersial untuk penyegerakan](https://obsidian.md/sync) dengan aplikasi mudah alih pada iOS dan Android. (https://obsidian.md/pricing).

Anda memulakan Obsidian dengan `Super + Shift + O`. Untuk menggunakan penyegerakan tema, anda mesti memilih tema `Omarchy` di bawah tetapan.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ialah aplikasi penulisan Markdown Omarchy sendiri yang sangat ringkas. Tiada vault, tiada plugin, hanya anda dan kata-kata.

Anda memulakan Omawrite dengan `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ialah alat penyuntingan imej asas yang hebat untuk memangkas, mengubah saiz, dan manipulasi asas yang lain. Jangan pula mengharapkan alternatif kepada Photoshop. Tetapi ia masih mempunyai Magic Wand dan lapisan!

Anda memulakan Pinta melalui pelancar aplikasi (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ialah aplikasi tema yang boleh mengekstrak warna daripada imej latar dan mengubahnya menjadi tema yang lengkap dan padu. Ini ialah cara paling mudah untuk [membuat tema anda sendiri](43-making-your-own-theme.md).

Anda memulakan Aether melalui pelancar aplikasi (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) membolehkan anda menghantar fail ke peranti lain pada rangkaian yang sama yang menjalankan aplikasi tersebut, seperti AirDrop daripada Apple. Namun ia merentas platform, jadi anda boleh menghantar fail ke dan dari Windows, macOS, Android, iOS, dan sudah tentu Linux.

Anda boleh membuka menu Share pada `Super + Ctrl + S` atau di bawah _Trigger > Share_ dalam menu Omarchy. Ia memberi anda empat pilihan:

- **Clipboard** menghantar apa sahaja yang telah anda salin sebagai fail teks. Hebat untuk mendapatkan pautan atau coretan ke telefon anda tanpa menghantar e-mel kepada diri sendiri.
- **File** membuka pemilih fail yang membolehkan anda memilih beberapa fail sekali gus.
- **Folder** menghantar keseluruhan direktori.
- **Receive** membuka LocalSend sebenar supaya peranti lain boleh menghantar sesuatu kepada anda.

Perkara yang sama berfungsi dari terminal dengan `omarchy share clipboard`, `omarchy share file [path]`, dan `omarchy share folder [path]`. Biarkan laluan kosong dan anda akan mendapat pemilih.

Anda juga boleh menghantar terus dari pengurus fail: klik kanan pada mana-mana pilihan dalam Nautilus dan pilih _Send via LocalSend_.

Firewall Omarchy ditutup secara lalai kecuali untuk port LocalSend, jadi ini berfungsi terus pada pemasangan baru. Lihat [keselamatan](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ialah pakej pejabat lengkap dengan pemproses kata, hamparan, pembentangan, aplikasi lukisan, dan banyak lagi. Ia serasi dengan fail daripada Microsoft Office, jadi ini ialah cara hebat untuk dapat membuka dokumen Word tersebut.

Anda memulakan LibreOffice melalui pelancar aplikasi (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ialah aplikasi pembentangan Omarchy sendiri yang sangat ringkas. Dek anda ialah satu fail Markdown dengan imej dan videonya di sebelah: tulis setiap slaid di bawah pratonton langsung, seret slaid mengikut susunan, kemudian bentangkan secara skrin penuh atau eksport ke PDF dan PowerPoint. Ia juga mengambil tema Omarchy anda.

Anda memulakan Hype melalui pelancar aplikasi (`Super + Space`). Tekan `?` di dalamnya untuk melihat setiap pintasan.

## Signed

[Signed](https://github.com/omacom/signed) ialah cara Omarchy sendiri yang sangat ringkas untuk menandatangani PDF dan mengisinya. Letakkan tandatangan anda yang disimpan, teks, dan tarikh hari ini di mana-mana pada halaman, kemudian simpan salinan yang ditandatangani di sebelah fail asal. Lihat [Mengisi PDF](27-filling-out-pdfs.md) untuk caranya.

Anda memulakan Signed melalui pelancar aplikasi (`Super + Space`), atau buka PDF dengannya dari pengurus fail.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ialah kalkulator Omarchy sendiri yang sangat ringkas, yang dibuka dalam tetingkap terapung.

Anda memulakan Omacalc dengan `Super + Shift + Q` (atau kekunci kalkulator, jika papan kekunci anda mempunyai satu).

## Signal

[Signal](https://signal.org/) ialah pelopor pemesejan disulitkan E2E, dan pilihan komunikasi hebat untuk sesiapa yang lebih suka tidak melalui salah satu konglomerat teknologi besar.

Anda memulakan Signal dengan `Super + Shift + G`. Ia bukan sebahagian daripada pemasangan asas, jadi kali pertama anda menekannya, Omarchy akan menawarkan untuk memasangnya untuk anda (ia juga berada di bawah _Install > Service_ dalam menu Omarchy).

## mpv

[mpv](https://mpv.io/) ialah pemain media yang ringkas dan pantas yang akan memainkan hampir apa sahaja daripada mana-mana sumber. Hebat untuk menonton video.

Anda memulakan mpv melalui pelancar aplikasi (`Super + Space`) atau hanya klik dua kali pada video dalam pengurus fail.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ialah pemangkas video Omarchy sendiri yang sangat ringkas. Apabila anda hanya perlu memotong permulaan dan penghujung klip, ia lebih baik daripada memulakan penyunting video penuh.

Anda memulakan Omacut melalui pelancar aplikasi (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ialah perakam kamera web Omarchy sendiri yang sangat ringkas. Pilih kamera dan mikrofon anda sekali, kemudian tekan `Space` untuk merakam, dan sekali lagi untuk menjeda dan menyambung semula rakaman yang sama. Ia sentiasa merakam pada resolusi tertinggi kamera anda, dengan meter mikrofon langsung supaya anda boleh menyemak tahap anda sebelum bermula.

Hentikan rakaman dan ia terus dibuka dalam penyunting terbina dalam. Klik dua kali pada klip untuk membahagikannya, seret pemegang untuk memangkas setiap bahagian, dan buang bahagian yang anda tidak mahu. Kemudian simpannya sebagai MP4. Rakaman asal anda disimpan sehingga anda membuangnya, jadi anda sentiasa boleh kembali dan memotongnya secara berbeza.

Anda memulakan Monologue melalui pelancar aplikasi (`Super + Space`).
