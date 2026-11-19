# Pemasangan Dual Boot

Anda boleh memasang Omarchy pada satu partition sahaja bersama-sama Windows atau pemasangan lain.

Kaedah pemasangan ini masih disertakan dengan penyulitan LUKS untuk partition secara lalai, jadi ia sebenarnya tidak berbeza dengan pemasangan pemacu penuh dan hanya memerlukan ruang kosong tersedia pada cakera.

## Menyediakan Ruang pada Windows

Untuk memasang bersama-sama Windows, taip `disk management` dalam menu mula dan pilih pilihan **Cipta dan format partition cakera keras**.

 ![dual-boot-1](images/dual-boot-1.webp)

Cari partition yang sesuai, klik kanan, dan pilih **Kecilkan Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Masukkan jumlah yang anda ingin kecilkan daripada volume tersebut. Perlu diingat bahawa ini akan menjadi saiz pemasangan Omarchy anda pada masa hadapan termasuk partition but.

 ![dual-boot-3](images/dual-boot-3.webp)

Apabila anda selesai, anda sepatutnya melihat sesuatu seperti ini, dengan bahagian 50GB ialah tempat kami akan memasang Omarchy dalam contoh ini.

 ![dual-boot-4](images/dual-boot-4.webp)

## Memasang Omarchy

Proses pemasangan Omarchy sebenarnya sama seperti biasa. Selepas anda memilih cakera anda, anda akan diberikan pilihan **Pemasangan ruang kosong**. Pilih pilihan itu untuk mengelakkan keseluruhan cakera dipadamkan.

 ![dual-boot-5](images/dual-boot-5.webp)

Sahkan bahawa semuanya kelihatan baik dan tunggu pemasangan selesai seperti biasa. Di sinilah juga anda boleh memilih untuk memasang tanpa penyulitan (tidak disyorkan) sama seperti pada pemasangan pemacu penuh.
 ![dual-boot-6](images/dual-boot-6.webp)

## Menambah Pemasangan Lain pada Bootloader

Apabila anda selesai memasang Omarchy, anda akan perasan bahawa bootloader Limine kini menjadi lalai. Dengan ini, anda juga boleh menambah pilihan pada Limine untuk pemasangan anda yang lain seperti Windows.

Untuk menambah sistem pengendalian lain, jalankan `limine-scan` dan ikut gesaan untuk menambah entri yang anda inginkan pada konfigurasi Limine anda. Menu but kekal tersembunyi secara lalai dan memulakan Omarchy selepas satu saat. Untuk memilih Windows atau entri lain, tekan sebarang kekunci sebaik sahaja Limine bermula; apabila menu muncul, gunakan kekunci anak panah untuk memilih entri dan tekan Enter. Jika Omarchy bermula sebelum anda menekan kekunci, mulakan semula dan cuba lagi.

## Bitlocker

Penting untuk diingat bahawa kaedah pemasangan ini tidak serasi dengan Bitlocker kerana ia menyulitkan keseluruhan pemacu, bukan hanya partition. Jika anda menghadapi ralat yang menyatakan Bitlocker diaktifkan, but ke Windows, pergi ke **Tetapan -> Privasi & Keselamatan -> Penyulitan peranti** dan matikan Bitlocker. Ia mungkin mengambil sedikit masa untuk menyahsulit pemacu.

 ![dual-boot-7](images/dual-boot-7.webp)
