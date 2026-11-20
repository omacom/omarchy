# GUI

## Fail

Files (Folio) ialah pengurus fail grafik. `Super + Shift + F` membukanya, dan `Super + Shift + Alt + F` membukanya dalam direktori tempat terminal anda berada, yang menjimatkan banyak klik. `Ctrl + L` membolehkan anda menaip laluan, dan menekan `Space` pada mana-mana fail mempratontonnya pada saiz penuh tanpa membukanya.

Cucuk batang USB atau kad SD dan ia dilekapkan secara automatik, jadi ia terus muncul dalam bar sisi. Untuk apa-apa yang lebih rumit — memformat pemacu, menyemak kesihatan SMART, mencipta partition — lancarkan _Disks_ daripada pelancar aplikasi (`Super + Space`).

Klik dua kali mengikut tetapan lalai yang munasabah: gambar, video, dan muzik dibuka dalam Omaview, PDF dalam Document Viewer, Markdown dalam Omawrite, dan teks biasa dalam editor yang dipilih di bawah _Setup > Default > Editor_.

## Disktree

Apabila pemacu penuh dan anda tiada idea apa yang memakannya, lancarkan [Disktree](https://github.com/tobi/disktree) daripada pelancar aplikasi (`Super + Space`). Ia menunjukkan treemap grafik bagi direktori rumah anda. Blok yang lebih besar mengambil lebih banyak ruang; masuk ke dalam direktori dengan papan kekunci atau tetikus, tandakan apa yang patut dibuang, dan semak pilihan anda sebelum mengalih keluar apa-apa. Jalankan `disktree --disk` untuk mengimbas seluruh cakera.

## Obsidian

[Obsidian](https://obsidian.md/) ialah aplikasi catatan percuma dan sangat boleh diperluas yang menggunakan fail Markdown ringkas untuk storan.

Obsidian percuma untuk semua tujuan, termasuk penggunaan peribadi, komersial, dan bukan keuntungan.

Obsidian juga menawarkan [tambahan komersial untuk penyegerakan](https://obsidian.md/sync) dengan aplikasi mudah alih pada iOS dan Android. (https://obsidian.md/pricing).

Anda memulakan Obsidian dengan `Super + Shift + O`. Untuk menggunakan penyegerakan tema, anda mesti memilih tema `Omarchy` di bawah tetapan.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ialah aplikasi penulisan Markdown Omarchy sendiri yang sangat ringkas. Tiada vault, tiada plugin, hanya anda dan kata-kata.

Anda memulakan Omawrite dengan `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ialah alat penyuntingan imej asas yang bagus untuk memotong, mengubah saiz, dan manipulasi asas lain. Cuma jangan mengharapkan alternatif Photoshop. Tetapi ia masih ada Magic Wand dan lapisan!

Anda memulakan Pinta melalui pelancar aplikasi (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ialah aplikasi tema yang boleh mengekstrak warna daripada imej latar belakang dan menukarkannya menjadi tema yang lengkap dan padu. Ia cara paling mudah untuk [membuat tema anda sendiri](43-making-your-own-theme.md).

Anda memulakan Aether melalui pelancar aplikasi (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) membolehkan anda menghantar fail ke peranti lain pada rangkaian yang sama yang menjalankan aplikasi itu, seperti AirDrop Apple. Ia merentas platform, jadi anda boleh menghantar fail ke dan daripada Windows, macOS, Android, iOS, dan sudah tentu Linux.

Anda boleh membuka menu Share pada `Super + Ctrl + S` atau di bawah _Trigger > Share_ dalam menu Omarchy. Ia memberi anda empat pilihan:

- **Clipboard** menghantar apa sahaja yang telah anda salin sebagai fail teks. Bagus untuk mendapatkan pautan atau snippet ke telefon anda tanpa menghantar e-mel kepada diri sendiri.
- **File** membuka pemilih fail yang membolehkan anda memilih beberapa fail sekali gus.
- **Folder** menghantar seluruh direktori.
- **Receive** membuka LocalSend sebenar supaya peranti lain boleh menghantar sesuatu kepada anda.

Perkara yang sama berfungsi daripada terminal dengan `omarchy share clipboard`, `omarchy share file [path]`, dan `omarchy share folder [path]`. Tinggalkan laluan dan anda mendapat pemilih.

Anda juga boleh menghantar terus daripada pengurus fail: klik kanan pada mana-mana pilihan dalam Files dan kongsi dengan LocalSend.

Firewall Omarchy ditutup secara lalai kecuali port LocalSend, jadi ini berfungsi terus pada pemasangan baharu. Lihat [keselamatan](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ialah pakej pejabat lengkap dengan pemproses kata, hamparan, pembentangan, aplikasi lukisan, dan banyak lagi. Ia serasi dengan fail daripada Microsoft Office, jadi ini cara yang bagus untuk dapat membuka dokumen Word tersebut.

Anda memulakan LibreOffice melalui pelancar aplikasi (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ialah aplikasi pembentangan Omarchy sendiri yang sangat ringkas. Deck anda ialah satu fail Markdown dengan imej dan videonya di sebelahnya: tulis setiap slaid di bawah pratonton langsung, seret slaid ke dalam susunan, kemudian bentangkan secara skrin penuh atau eksport ke PDF dan PowerPoint. Ia juga mengambil tema Omarchy anda.

Anda memulakan Hype melalui pelancar aplikasi (`Super + Space`). Tekan `?` di dalamnya untuk melihat setiap pintasan.

## Signed

[Signed](https://github.com/omacom/signed) ialah cara Omarchy sendiri yang sangat ringkas untuk menandatangani PDF dan mengisinya. Letakkan tandatangan anda yang disimpan, teks, dan tarikh hari ini di mana-mana pada halaman, kemudian simpan salinan yang ditandatangani di sebelah yang asal. Lihat [Mengisi PDF](27-filling-out-pdfs.md) untuk caranya.

Anda memulakan Signed melalui pelancar aplikasi (`Super + Space`), atau buka PDF dengannya daripada pengurus fail.

## Game Vibes

Game Vibes, dalam pelancar aplikasi (`Super + Space`), ialah tempat tinggal permainan kecil Omarchy: Checkmate, permainan catur 3D melawan rakan atau lawan terbina dalam; Cards, Klondike solitaire; dan Neon Swarm, permainan tembak-menembak arked. Setiap satu ialah satu halaman web yang mengikut tema anda. Pilih satu dengan anak panah dan `Enter`, dan kembali ke senarai dengan `Esc` daripada skrin tajuk permainan atau `Q` semasa ia dijeda. Ia dibuka dalam skrin penuh: `Super + F` menjadikannya tetingkap, dan `Super + W` menutupnya.

Permainan yang anda buat dengan ejen juga muncul di sini: pilih _Make something cool → Game_ dalam panel ejen dan gambarkan satu permainan, atau namakan permainan yang sudah ada dalam Game Vibes untuk terus mengerjakannya. Ejen menyalinnya ke dalam `~/Games/vibes`, tempat ia menjadi milik anda untuk diubah, dan membukanya apabila selesai. Anda boleh membuat salinan itu sendiri dengan `omarchy games vibes copy <game>`. Permainan yang dikongsi orang lain dipasang seperti tema: pilih _Install > Gaming > Game Vibes_ dan tampal alamat gitnya, atau jalankan `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ mengalih keluar satu permainan semula, dan _Update > Game Vibes Games_ mengambil versi baharu. Permainan memuatkan three.js daripada web, jadi ia memerlukan sambungan untuk bermula.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ialah kalkulator Omarchy sendiri yang sangat ringkas, yang dibuka dalam tetingkap terapung.

Anda memulakan Omacalc dengan `Super + Shift + Q` (atau kekunci kalkulator, jika papan kekunci anda mempunyainya).

## Signal

[Signal](https://signal.org/) ialah perintis pemesejan disulitkan E2E, dan pilihan komunikasi yang bagus untuk sesiapa yang lebih suka tidak melalui salah satu konglomerat teknologi besar.

Anda memulakan Signal dengan `Super + Shift + G`. Ia bukan sebahagian daripada pemasangan asas, jadi kali pertama anda menekannya, Omarchy akan menawarkan untuk memasangnya untuk anda (ia juga ada di bawah _Install > Service_ dalam menu Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) ialah pemapar gambar dan pemain media Omarchy sendiri yang sangat ringkas: satu tetingkap untuk foto, video, dan muzik anda. Buka foto dan kekunci anak panah melangkah melalui foldernya yang lain, `N` dan `P` melakukannya untuk apa-apa, dan `Ctrl + M` menunjukkan seluruh folder sebagai grid. Ia juga menunjukkan foto HEIC, AVIF, dan JPEG XL, dan menyambung tempat anda berhenti dalam apa-apa yang panjang.

Tekan `F` untuk skrin penuh, `E` untuk menyunting gambar dalam Omasnap atau memotong video dalam Omacut, `Ctrl + P` untuk mencetak gambar, dan `Delete` untuk mengalihkan fail ke Trash (`Ctrl + Z` membawanya kembali). Tekan `?` di dalamnya untuk melihat setiap pintasan.

Anda memulakan Omaview sebagai _Media Viewer_ melalui pelancar aplikasi (`Super + Space`), atau hanya klik dua kali pada gambar, video, atau lagu dalam pengurus fail.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ialah pemotong video Omarchy sendiri yang sangat ringkas. Apabila anda hanya perlu memotong permulaan dan pengakhiran klip, ia lebih baik daripada membuka penyunting video penuh.

Anda memulakan Omacut melalui pelancar aplikasi (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ialah perakam kamera web Omarchy sendiri yang sangat ringkas. Pilih kamera dan mikrofon anda sekali, kemudian tekan `Space` untuk merakam, dan sekali lagi untuk menjeda dan menyambung rakaman yang sama. Ia sentiasa merakam pada resolusi tertinggi kamera anda, dengan meter mikrofon langsung supaya anda boleh menyemak tahap anda sebelum bermula.

Hentikan rakaman dan ia dibuka terus dalam penyunting terbina dalam. Klik dua kali pada klip untuk membahagikannya, seret pemegang untuk memotong setiap bahagian, dan alih keluar bahagian yang anda tidak mahu. Kemudian simpan sebagai MP4. Rakaman asal anda disimpan sehingga anda membuangnya, jadi anda sentiasa boleh kembali dan memotongnya secara berbeza.

Anda memulakan Monologue melalui pelancar aplikasi (`Super + Space`).
