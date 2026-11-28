# Snapshot sistem

Kami membuat snapshot secara otomatis setiap kali Omarchy diperbarui, tetapi kalau Anda ingin membuat snapshot sendiri, Anda bisa menggunakan `omarchy-snapshot create`.

Cara Anda melakukan boot dan memulihkan snapshot bergantung pada boot loader yang dipakai mesin Anda untuk memulai. Instalasi UEFI baru menggunakan systemd-boot; instalasi yang lebih lama dan mesin BIOS menggunakan Limine. `omarchy-boot-backend` memberi tahu Anda boot loader mana yang Anda miliki.

## Dengan systemd-boot

Pilih _Sistem > Snapshot_ di menu Omarchy dan pilih snapshot yang ingin Anda gunakan untuk boot. Mesin akan memulai ulang ke snapshot itu satu kali. Atau tahan Space saat mesin memulai untuk melihat menu boot, di mana setiap snapshot dicantumkan dari yang terbaru dengan versi Omarchy dan tanggalnya.

Snapshot melakukan boot dengan lapisan sementara di atasnya, jadi Anda bisa menggunakannya seperti biasa, tetapi apa pun yang Anda ubah akan hilang pada reboot berikutnya. Untuk mempertahankannya, jadikan itu sistem Anda: klik notifikasi yang muncul saat Anda masuk, pilih _Sistem > Snapshot > Pulihkan Snapshot Ini_, atau jalankan `omarchy-snapshot restore`. Pemulihan terjadi saat mesin memulai ulang. Sistem seperti sebelum pemulihan tetap ada di menu boot sebagai _Sebelum pemulihan_, dan `omarchy-snapshot restore backup` mengembalikannya.

Dari terminal:

- `omarchy-snapshot list` mencantumkan snapshot yang bisa Anda gunakan untuk boot;
- `omarchy-snapshot boot 12` memulai ulang ke snapshot 12 satu kali;
- `omarchy-snapshot restore 12` menjadikan snapshot 12 sebagai sistem pada restart berikutnya, dan `omarchy-snapshot restore --cancel` membatalkan keputusan itu sebelum restart tersebut.

## Dengan Limine

Untuk melakukan boot dan memulihkan snapshot, Anda memilihnya dari boot loader Limine. Menu boot tetap tersembunyi secara default, jadi tekan sembarang tombol segera setelah Limine mulai untuk menampilkannya.

Dari layar itu, pilih snapshot yang ingin Anda gunakan untuk boot berdasarkan tanggal dan versinya. Versi Omarchy pada saat snapshot dibuat dapat dilihat di sudut kiri bawah.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Saat Anda tiba di dalamnya, sebuah notifikasi akan muncul untuk memberi tahu Anda bahwa Anda berada di snapshot yang dapat di-boot dan jika Anda mengkliknya, proses pemulihan akan dimulai. Sebagai alternatif, Anda dapat menggunakan `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## Apa saja yang dicakup oleh pemulihan

Pemulihan mengembalikan filesystem root Anda, tetapi bukan `/home` Anda. Jadi cara ini berfungsi untuk mengembalikan pembaruan sistem yang rusak, tetapi bukan untuk memulihkan file pribadi yang hilang.

Ini juga berarti direktori `~/.config` Anda tetap apa adanya. Jadi jika Anda kembali ke versi library atau aplikasi yang lebih lama yang menyimpan file konfigurasi dalam format baru, Anda harus membereskannya sendiri secara manual.

Hal yang sama berlaku untuk catatan Omarchy sendiri tentang migrasi mana yang sudah dijalankan: catatan itu berada di direktori home Anda, jadi tetap bertahan setelah pemulihan. Migrasi yang dijalankan setelah snapshot dibuat tetap ditandai sebagai selesai, meskipun perubahan yang dibuatnya pada filesystem root telah dikembalikan, dan `omarchy update` berikutnya tidak akan menjalankannya lagi. Jadi jika Anda memperbarui lagi setelah pemulihan dan sesuatu yang telah disiapkan oleh pembaruan sebelumnya masih hilang, itulah kemungkinan penyebabnya.
