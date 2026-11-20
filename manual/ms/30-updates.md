# Kemas Kini

Omarchy dan pakej anda sentiasa dikemas kini melalui _Kemas Kini > Omarchy_ dalam menu Omarchy (`Super + Space`).

Omarchy itu sendiri dipasang sebagai pakej pacman biasa daripada [Repositori Pakej Omarchy](https://github.com/omacom-io/omarchy-pkgs), jadi kemas kini akan memasang [keluaran Omarchy terkini](https://github.com/omacom/omarchy/releases), menjalankan sebarang migrasi yang belum selesai untuk menyelaraskan sistem anda dengan versi terkini, dan mengemas kini semua pakej sistem daripada [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) dan [AUR](https://aur.archlinux.org/) (jika anda telah memasang sebarang pakej AUR).

Apabila keluaran baharu dibuat, ikon anak panah bulatan akan muncul di sebelah kanan jam anda. Klik ikon itu dan proses kemas kini akan bermula.

![update-available](images/update-available.webp)

### Empat saluran

Omarchy dikemas kini melalui empat saluran: stable, RC, edge, dan dev. Pemasangan baharu bermula pada saluran stable, yang mengikuti [keluaran rasmi](https://github.com/omacom/omarchy/releases/), serta [mirror Arch Omarchy stable](https://github.com/omacom-io/omarchy-mirror) yang ketinggalan satu bulan di belakang versi terkini, supaya kami dapat mengesan sebarang ketidakserasian baharu yang memerlukan perubahan konfigurasi sebelum ia menimbulkan masalah kepada orang ramai.

Tetapi jika anda ingin membantu mengesan isu-isu yang berpotensi itu, anda boleh berjalan pada saluran edge. Itu akan memastikan pakej Omarchy anda mengikuti binaan pembangunan terkini, dan membolehkan anda mengemas kini kepada pakej Arch terkini sebaik sahaja ia tersedia. Anda patut melakukan ini hanya jika anda berpengalaman dengan Linux, dan tahu cara memulihkan sistem yang bermasalah.

Sebelum sebarang keluaran utama baharu, kami akan melakukan pengesahan akhir menggunakan saluran RC. Jika anda berminat untuk membantu dengan sentuhan akhir, mari lepak di #omarchy-release-candidates di Discord.

Akhir sekali, terdapat saluran dev, yang menghubungkan Omarchy terus kepada checkout git kod sumber dalam `~/omarchy`, digabungkan dengan pakej edge. Anda patut menggunakan saluran ini hanya jika anda pengguna Linux yang berpengalaman, bekerja secara langsung pada Omarchy, dan sanggup menanggung kerosakan.

Anda boleh bertukar antara saluran menggunakan _Kemas Kini > Saluran_ daripada menu Omarchy (atau `omarchy-channel-set` dalam terminal).

### Menukar kernel

Omarchy but kernel `linux-omarchy` miliknya sendiri, tetapi anda boleh menyimpan kernel lain yang dipasang bersebelahan dengannya, seperti kernel `linux` Arch standard atau binaan eksperimen yang sedang anda uji. Apabila terdapat lebih daripada satu, _Kemas Kini > Kernel_ dalam menu Omarchy menyenaraikannya dengan tanda semak di sebelah kernel yang but secara lalai. Pilih yang lain, masukkan kata laluan anda sekali, dan ia akan but selepas mula semula yang seterusnya. Kernel lain kekal dalam menu but, jadi anda masih boleh memilihnya secara manual jika tetapan lalai baharu memberi anda masalah. Dalam terminal, ia ialah `omarchy-kernel` untuk melihat tetapan lalai semasa, `omarchy-kernel list` untuk apa yang dipasang, dan `omarchy-kernel set <kernel>` untuk menukar.

### Kemas kini firmware

Pakej anda bukan satu-satunya perkara yang menjadi lapuk. Banyak komputer riba dan peranti persisian menghantar firmware BIOS, SSD, dan dok melalui Linux Vendor Firmware Service, dan _Kemas Kini > Firmware_ dalam menu Omarchy akan mengambil dan memasang apa sahaja yang telah menunggu untuk perkakasan anda. Ia memasang `fwupd` pada kali pertama anda menjalankannya. Banyak firmware hanya boleh ditulis semasa but semula, jadi jangan terkejut jika anda diminta untuk melakukannya.

Apabila anda perlu menukar tetapan dalam BIOS itu sendiri, tahan `Alt` dalam menu sistem (`Super + Escape`) dan _Mula Semula_ bertukar menjadi _Mula Semula ke BIOS_, yang memulakan semula terus ke dalam persediaan firmware tanpa perlu menangkap kekunci yang betul semasa but. Daripada terminal, ia ialah `omarchy system firmware`.

### Amaran tentang kemas kini pacman/yay secara langsung

Jika anda sudah biasa dengan Arch, anda mungkin tergoda untuk menjalankan sahaja `pacman -Syu` atau `yay -Syu` sendiri, tetapi jika anda berbuat demikian, anda akan terlepas snapshot, migrasi, dan kemas kini konfigurasi yang Omarchy jalankan bersama-sama dengan pakej baharu. Itulah sebabnya Omarchy sebenarnya akan menghentikan peningkatan sistem secara langsung dan mengarahkan anda kepada `omarchy update` sebaliknya. (Jika anda benar-benar tahu apa yang anda lakukan, pengawal itu akan memberitahu anda cara memintasnya untuk satu transaksi.)

### Mengundur kemas kini yang bermasalah

Jika anda pernah mengalami masalah selepas melakukan kemas kini, anda boleh mengembalikan sistem anda kepada snapshot yang diambil sebelum kemas kini. Mulakan semula sahaja dan pilih snapshot dalam menu pemuatan but dari sebelum anda memulakan kemas kini.

![bootloader](images/bootloader.webp)

Jika entah bagaimana fail konfigurasi anda telah rosak, anda juga boleh melakukan pemasangan semula Omarchy menggunakan `omarchy reinstall` dalam terminal. Ini akan memasang semula semua pakej Omarchy lalai, meletakkan anda pada stable dan menurunkan versi sebarang pakej yang terlalu baharu, dan menetapkan semula semua fail konfigurasi. Ambil perhatian bahawa semua perubahan konfigurasi pengguna anda kepada tetapan lalai Omarchy akan ditulis ganti apabila melakukan ini!
