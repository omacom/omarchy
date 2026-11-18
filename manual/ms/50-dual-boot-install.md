# Pemasangan Dual Boot

Anda boleh memasang Omarchy pada satu partition sahaja bersama Windows atau pemasangan lain.

Kaedah pemasangan ini masih dilengkapi dengan penyulitan LUKS untuk partition tersebut secara lalai, jadi ia sebenarnya tidak berbeza daripada pemasangan pada keseluruhan pemacu dan hanya memerlukan ruang kosong tersedia pada cakera.

## Menyediakan Ruang pada Windows

Untuk memasang bersama Windows, taip `disk management` dalam menu mula dan pilih pilihan **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Cari partition yang sesuai, klik kanan, dan pilih **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Masukkan jumlah yang anda mahu kecilkan daripada volume tersebut. Perlu diingat bahawa ini akan menjadi saiz pemasangan Omarchy anda pada masa hadapan termasuk partition but.

 ![dual-boot-3](images/dual-boot-3.webp)

Apabila anda selesai, anda sepatutnya melihat sesuatu seperti ini di mana bahagian 50GB ialah tempat kami akan memasang Omarchy dalam contoh ini.

 ![dual-boot-4](images/dual-boot-4.webp)

## Memasang Omarchy

Proses pemasangan Omarchy sebenarnya sama seperti biasa. Selepas anda memilih cakera anda, anda akan diberikan pilihan **Free space install**. Pilih pilihan tersebut untuk mengelakkan keseluruhan cakera dipadamkan.

 ![dual-boot-5](images/dual-boot-5.webp)

Sahkan semuanya kelihatan baik dan tunggu pemasangan selesai seperti biasa. Di sinilah juga anda boleh memilih untuk memasang tanpa penyulitan (tidak disyorkan) sama seperti pada pemasangan pada keseluruhan pemacu.
 ![dual-boot-6](images/dual-boot-6.webp)

## Menambah Pemasangan Lain pada Bootloader

Apabila anda selesai memasang Omarchy, anda akan perasan bahawa bootloader Limine kini menjadi lalai. Dengan ini, anda juga boleh menambah pilihan pada Limine untuk pemasangan lain anda seperti Windows.

Untuk menambah sistem pengendalian lain, jalankan `limine-scan` dan ikut gesaan untuk menambah entri yang anda mahu pada konfigurasi Limine anda. Menu but kekal tersembunyi secara lalai dan memulakan Omarchy selepas satu saat. Untuk memilih Windows atau entri lain, tekan sebarang kekunci sebaik sahaja Limine bermula; apabila menu muncul, gunakan kekunci anak panah untuk memilih entri dan tekan Enter. Jika Omarchy bermula sebelum anda menekan kekunci, mulakan semula dan cuba lagi. Jika anda menghidupkan _Setup > Direct Boot_, firmware akan melangkau Limine sepenuhnya, jadi pilih Limine daripada menu but BIOS anda atau jalankan _Setup > Direct Boot_ sekali lagi untuk mengalih keluar entri tersebut.

## Bitlocker

Penting untuk diingat bahawa kaedah pemasangan ini tidak serasi dengan Bitlocker kerana ia menyulitkan keseluruhan pemacu, bukan hanya partition tersebut. Jika anda menghadapi ralat yang menyatakan Bitlocker dihidupkan, but ke Windows, pergi ke **Settings -> Privacy & Security -> Device encryption** dan matikan Bitlocker. Ia mungkin mengambil sedikit masa untuk menyahsulit pemacu.

 ![dual-boot-7](images/dual-boot-7.webp)
