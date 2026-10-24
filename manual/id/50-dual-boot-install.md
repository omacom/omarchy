# Pemasangan Dual Boot

Kamu bisa memasang Omarchy ke satu partisi di samping Windows atau pemasangan lainnya.

Metode pemasangan ini tetap dilengkapi enkripsi LUKS untuk partisi secara bawaan jadi secara efektif tidak berbeda dari drive penuh dan hanya membutuhkan ruang kosong yang tersedia pada disk.

## Membuat Ruang di Windows

Untuk memasang di samping Windows, ketik `disk management` di menu start dan pilih opsi untuk **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Temukan partisi yang tepat, klik kanan, dan pilih **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Masukkan jumlah yang ingin kamu kecilkan dari volume. Perhatikan bahwa ini akan menjadi ukuran pemasangan Omarchy kamu di masa depan termasuk partisi boot.

 ![dual-boot-3](images/dual-boot-3.webp)

Saat kamu selesai, kamu seharusnya melihat sesuatu seperti ini di mana bagian 50GB adalah tempat kami akan memasang Omarchy dalam contoh ini.

 ![dual-boot-4](images/dual-boot-4.webp)

## Memasang Omarchy

Proses pemasangan untuk Omarchy secara efektif sama seperti biasa. Setelah kamu memilih disk kamu, kamu akan diberi opsi **Free space install**. Pilih opsi itu untuk mencegah menghapus seluruh disk.

 ![dual-boot-5](images/dual-boot-5.webp)

Konfirmasikan bahwa semuanya terlihat baik dan tunggu pemasangan selesai seperti biasa. Di sini juga kamu bisa memilih untuk memasang tanpa enkripsi (tidak disarankan) sama seperti pada pemasangan drive penuh.
 ![dual-boot-6](images/dual-boot-6.webp)

## Menambahkan Pemasangan Lain ke Bootloader

Saat kamu menyelesaikan pemasangan Omarchy, kamu akan melihat bahwa bootloader Limine sekarang menjadi bawaan. Dengan ini, kamu juga bisa menambahkan opsi ke Limine untuk pemasanganmu yang lain seperti Windows.

Untuk melakukannya, jalankan `limine-scan` dan ikuti prompt untuk menambahkan item apa pun yang kamu inginkan ke konfigurasi limine kamu. Lalu saat kamu boot, kamu akan melihat opsi normalmu untuk Omarchy, serta Windows Boot Manager atau lainnya.

## Bitlocker

Penting untuk dicatat bahwa metode pemasangan ini tidak kompatibel dengan Bitlocker karena ia mengenkripsi seluruh drive, bukan hanya partisi. Jika kamu menemui kesalahan yang menyatakan Bitlocker diaktifkan, boot ke Windows, pergi ke **Settings -> Privacy & Security -> Device encryption** dan matikan Bitlocker. Mungkin perlu beberapa waktu untuk mendekripsi drive.

 ![dual-boot-7](images/dual-boot-7.webp)
