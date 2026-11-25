# Snapshot sistem

Kami membuat snapshot secara otomatis pada setiap pembaruan Omarchy, tetapi jika Anda ingin membuat snapshot sendiri, Anda dapat menggunakan `omarchy-snapshot create`.

Untuk melakukan boot dan memulihkan snapshot, Anda memilihnya dari boot loader Limine. Menu boot tetap tersembunyi secara default, jadi tekan tombol apa saja segera setelah Limine dimulai untuk memunculkannya.

Dari layar tersebut, pilih snapshot yang ingin Anda boot berdasarkan tanggal dan versinya. Versi Omarchy pada saat snapshot dibuat dapat dilihat di sudut kiri bawah.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Saat Anda masuk ke dalamnya, sebuah notifikasi akan muncul untuk memberitahu Anda bahwa Anda berada di snapshot yang dapat di-boot, dan jika Anda mengkliknya, proses pemulihan akan dimulai. Sebagai alternatif, Anda dapat menggunakan `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Ini akan memulihkan filesystem root Anda, tetapi bukan `/home` Anda. Jadi ini berfungsi untuk mengembalikan pembaruan sistem yang rusak, tetapi bukan untuk memulihkan file pribadi yang hilang.

Ini juga berarti direktori `~/.config` Anda tetap dipertahankan apa adanya. Jadi jika Anda kembali ke versi library atau aplikasi yang lebih lama yang menyimpan file konfigurasi dalam format baru, Anda harus membereskannya secara manual.

Hal yang sama berlaku untuk catatan Omarchy sendiri tentang migrasi mana yang sudah dijalankan: catatan itu berada di direktori home Anda, jadi catatan itu tetap bertahan setelah pemulihan. Migrasi yang dijalankan setelah snapshot dibuat tetap ditandai sebagai selesai, meskipun perubahan yang dibuatnya pada filesystem root telah dikembalikan, dan `omarchy update` berikutnya tidak akan menjalankannya lagi. Jadi jika Anda memperbarui lagi setelah pemulihan dan sesuatu yang telah disiapkan oleh pembaruan sebelumnya masih hilang, kemungkinan besar itulah penyebabnya.

_Catatan: Fitur ini hanya tersedia pada instalasi yang menggunakan boot loader Limine, yang telah menjadi default sejak Omarchy 2.0. Fitur ini tidak tersedia jika Anda menggunakan GRUB atau systemd-boot._
