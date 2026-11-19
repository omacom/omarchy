# Petikan sistem

Kami mencipta petikan secara automatik pada setiap kemas kini Omarchy, tetapi jika anda mahu mencipta petikan anda sendiri, anda boleh menggunakan `omarchy-snapshot create`.

Untuk but dan memulihkan petikan, anda memilihnya daripada pemuat but Limine. Menu but kekal tersembunyi secara lalai, jadi tekan sebarang kekunci sebaik sahaja Limine bermula untuk memaparkannya.

Daripada skrin itu, pilih petikan yang anda mahu but berdasarkan tarikh dan versi. Versi Omarchy pada masa petikan diambil boleh dilihat di sudut kiri bawah.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Apabila anda masuk ke dalamnya, satu pemberitahuan akan muncul memberitahu anda bahawa anda berada dalam petikan yang boleh dibut dan jika anda mengkliknya, proses pemulihan akan dimulakan. Sebagai alternatif, anda boleh menggunakan `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Ini akan memulihkan sistem fail root anda, tetapi bukan `/home` anda. Jadi ia berfungsi untuk mengembalikan kemas kini sistem yang rosak, tetapi bukan untuk memulihkan fail peribadi yang hilang.

Ini juga bermakna direktori `~/.config` anda dikekalkan seperti sedia ada. Jadi jika anda kembali kepada versi terdahulu bagi perpustakaan atau aplikasi yang menyimpan fail konfigurasi dalam format baharu, anda perlu menyelesaikannya sendiri secara manual.

Begitu juga dengan rekod Omarchy sendiri tentang migrasi mana yang telah dijalankan: ia berada dalam direktori home anda, jadi ia kekal selepas pemulihan. Migrasi yang dijalankan selepas petikan diambil kekal ditandakan sebagai selesai, walaupun perubahan yang dibuatnya pada sistem fail root telah dikembalikan, dan `omarchy update` seterusnya tidak akan menjalankannya lagi. Jadi jika anda mengemas kini semula selepas pemulihan dan sesuatu yang telah disediakan oleh kemas kini terdahulu masih tiada, itulah sebab yang berkemungkinan besar.

_Nota: Ciri ini hanya tersedia pada pemasangan yang menggunakan pemuat but Limine, yang telah menjadi lalai sejak Omarchy 2.0. Ia tidak tersedia jika anda menggunakan GRUB atau systemd-boot._
