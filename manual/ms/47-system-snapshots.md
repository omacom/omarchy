# Snapshot sistem

Kami mencipta snapshot secara automatik pada setiap kemas kini Omarchy, tetapi jika anda mahu mencipta snapshot anda sendiri, anda boleh menggunakan `omarchy-snapshot create`.

Untuk but dan memulihkan snapshot, anda memilihnya daripada pemuat but Limine. (Jika anda sedang but terus ke skrin penyahsulitan Omarchy, anda perlu memilih Limine sebagai pilihan but melalui BIOS terlebih dahulu).

Daripada skrin itu, pilih snapshot yang anda mahu but berdasarkan tarikh dan versi. Versi Omarchy pada masa snapshot itu diambil boleh dilihat di sudut kiri bawah.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Apabila anda tiba di dalam, satu pemberitahuan akan muncul memberitahu anda bahawa anda berada dalam snapshot yang boleh dibut dan jika anda mengkliknya, proses pemulihan akan dimulakan. Sebagai alternatif, anda boleh menggunakan `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Ini akan memulihkan sistem fail root anda, tetapi bukan `/home` anda. Jadi ia berfungsi untuk mengembalikan kemas kini sistem yang rosak, tetapi bukan untuk memulihkan fail peribadi yang hilang.

Ini juga bermakna direktori `~/.config` anda dikekalkan seperti sedia ada. Jadi jika anda kembali kepada versi terdahulu bagi sesebuah pustaka atau aplikasi yang menyimpan fail konfigurasi dalam format baharu, anda perlu menyelesaikannya sendiri secara manual.

Perkara yang sama berlaku pada rekod Omarchy sendiri tentang migrasi mana yang telah dijalankan: ia berada dalam direktori home anda, jadi ia kekal selepas pemulihan. Migrasi yang dijalankan selepas snapshot diambil kekal ditandakan sebagai selesai, walaupun perubahan yang dibuatnya pada sistem fail root telah dikembalikan, dan `omarchy update` yang seterusnya tidak akan menjalankannya lagi. Jadi jika anda mengemas kini semula selepas pemulihan dan sesuatu yang telah disediakan oleh kemas kini terdahulu masih tiada, itulah sebab yang berkemungkinan besar.

_Nota: Ciri ini hanya tersedia pada pemasangan yang menggunakan pemuat but Limine, yang telah menjadi lalai sejak Omarchy 2.0. Ia tidak tersedia jika anda menggunakan GRUB atau systemd-boot._

### Melangkau menu but

Jika anda tidak pernah menyentuh menu but dan hanya mahu mesin terus pergi ke skrin penyahsulitan, jalankan _Setup > Direct Boot_ dalam menu Omarchy. Itu menambah entri EFI yang menghala terus kepada Omarchy, jadi perisian tegar membutnya tanpa berhenti di Limine.

Pertukarannya ialah yang disebut di bahagian atas: dengan but terus dihidupkan, untuk pergi ke snapshot bermakna anda perlu memilih Limine daripada menu but BIOS anda terlebih dahulu. Jalankan _Setup > Direct Boot_ sekali lagi untuk mengalih keluar entri itu dan kembali kepada but melalui Limine. Sesetengah perisian tegar tidak menerima entri EFI tersuai dengan baik, jadi persediaan itu enggan dijalankan pada perisian tegar American Megatrends dan Apple.
