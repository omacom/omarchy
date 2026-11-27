# Pemasangan Dwi But

Anda boleh memasang Omarchy pada satu partition sahaja di samping Windows atau pemasangan lain.

Kaedah pemasangan ini masih disertakan dengan penyulitan LUKS untuk partition tersebut secara lalai, jadi pada dasarnya ia tidak berbeza daripada pemasangan pada keseluruhan pemacu dan hanya memerlukan ruang kosong yang tersedia pada cakera.

## Menyediakan Ruang pada Windows

Untuk memasang di samping Windows, taip `disk management` dalam menu mula dan pilih pilihan **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Cari partition yang sesuai, klik kanan, dan pilih **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Masukkan jumlah yang anda mahu kecilkan daripada volume tersebut. Ambil perhatian bahawa jumlah ini akan menjadi saiz pemasangan Omarchy anda pada masa hadapan, termasuk partition but.

 ![dual-boot-3](images/dual-boot-3.webp)

Apabila anda selesai, anda sepatutnya melihat sesuatu seperti ini, dengan bahagian 50GB ialah tempat kami akan memasang Omarchy dalam contoh ini.

 ![dual-boot-4](images/dual-boot-4.webp)

## Memasang Omarchy

Proses pemasangan Omarchy pada dasarnya sama seperti biasa. Selepas anda memilih cakera anda, anda akan diberikan pilihan **Free space install**. Pilih pilihan tersebut untuk mengelakkan keseluruhan cakera dipadamkan.

 ![dual-boot-5](images/dual-boot-5.webp)

Sahkan bahawa semuanya kelihatan baik dan tunggu pemasangan selesai seperti biasa. Di sinilah juga anda boleh memilih untuk memasang tanpa penyulitan (tidak disyorkan), sama seperti pada pemasangan keseluruhan pemacu.
 ![dual-boot-6](images/dual-boot-6.webp)

## Menambah Pemasangan Lain pada Bootloader

Apabila anda selesai memasang Omarchy, anda akan mendapati bahawa bootloader Limine kini menjadi lalai. Dengan ini, anda juga boleh menambah pilihan pada Limine untuk pemasangan anda yang lain seperti Windows.

Untuk menambah sistem pengendalian lain, jalankan `limine-scan` dan ikut gesaan untuk menambah entri yang anda mahu pada konfigurasi Limine anda. Menu but kekal tersembunyi secara lalai dan memulakan Omarchy selepas satu saat. Untuk memilih Windows atau entri lain, tekan sebarang kekunci sebaik sahaja Limine bermula; apabila menu muncul, gunakan kekunci anak panah untuk memilih entri dan tekan Enter. Jika Omarchy bermula sebelum anda sempat menekan kekunci, mulakan semula dan cuba lagi.

## Bitlocker

Penting untuk diambil perhatian bahawa kaedah pemasangan ini tidak serasi dengan Bitlocker kerana ia menyulitkan keseluruhan pemacu, bukan hanya partition tersebut. Jika anda menemui ralat yang menyatakan bahawa Bitlocker didayakan, but ke Windows, pergi ke **Settings -> Privacy & Security -> Device encryption** dan matikan Bitlocker. Ia mungkin mengambil sedikit masa untuk menyahsulit pemacu.

 ![dual-boot-7](images/dual-boot-7.webp)

## Memasang Semula Windows

Jika komputer ini didatangkan dengan Windows, kunci produknya disimpan dalam firmware. Jalankan `omarchy windows key` untuk mencetaknya, supaya anda boleh mengaktifkan Windows semula jika anda memasangnya semula pada mesin ini pada bila-bila masa.
