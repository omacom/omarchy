# Pemasangan But Dwi

Anda boleh memasang Omarchy ke satu partition di samping Windows atau pemasangan lain.

Kaedah pemasangan ini masih disertakan dengan penyulitan LUKS untuk partition secara lalai jadi ia sebenarnya tidak berbeza daripada pemacu penuh dan hanya memerlukan ruang kosong tersedia pada cakera.

## Membuat Ruang pada Windows

Untuk memasang di samping Windows, taip `disk management` dalam menu mula dan pilih pilihan untuk **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Cari partition yang sesuai, klik kanan, dan pilih **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Masukkan jumlah yang anda mahu kecilkan volume. Ambil perhatian bahawa ini akan menjadi saiz pemasangan Omarchy masa depan anda termasuk partition but.

 ![dual-boot-3](images/dual-boot-3.webp)

Apabila anda selesai, anda sepatutnya melihat sesuatu seperti ini di mana bahagian 50GB ialah tempat kami akan memasang Omarchy dalam contoh ini.

 ![dual-boot-4](images/dual-boot-4.webp)

## Memasang Omarchy

Proses pemasangan untuk Omarchy sebenarnya sama seperti biasa. Selepas anda memilih cakera anda, anda akan diberi pilihan **Free space install**. Pilih pilihan itu untuk mengelakkan pemadaman cakera penuh.

 ![dual-boot-5](images/dual-boot-5.webp)

Sahkan bahawa semuanya kelihatan baik dan tunggu pemasangan selesai seperti biasa. Di sinilah juga anda boleh memilih untuk memasang tanpa sulit (tidak disyorkan) sama seperti pemasangan pemacu penuh.
 ![dual-boot-6](images/dual-boot-6.webp)

## Menambah Pemasangan Lain pada Pemuat But

Apabila anda selesai pemasangan Omarchy anda, anda akan perasan pemuat but Limine ialah lalai sekarang. Dengan ini, anda juga boleh menambah pilihan pada Limine untuk pemasangan lain anda seperti Windows.

Untuk berbuat demikian, jalankan `limine-scan` dan ikuti gesaan untuk menambah item apa sahaja yang anda mahu pada konfigurasi limine anda. Kemudian apabila anda but, anda akan melihat pilihan biasa anda untuk Omarchy, serta Windows Boot Manager atau yang lain.

## Bitlocker

Adalah penting untuk ambil perhatian bahawa kaedah pemasangan ini tidak serasi dengan Bitlocker kerana ia menyulitkan seluruh pemacu, bukan hanya partition. Jika anda menghadapi ralat yang menyatakan Bitlocker dibolehkan, but ke Windows, pergi ke **Settings -> Privacy & Security -> Device encryption** dan togol Bitlocker mati. Ia mungkin mengambil sedikit masa untuk menyahsulit pemacu.

 ![dual-boot-7](images/dual-boot-7.webp)
