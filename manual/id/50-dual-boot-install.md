# Instalasi Dual Boot

Anda dapat menginstal Omarchy ke satu partisi berdampingan dengan Windows atau instalasi lainnya.

Metode instalasi ini tetap dilengkapi dengan enkripsi LUKS untuk partisi secara default sehingga pada dasarnya tidak berbeda dengan drive penuh dan hanya memerlukan ruang kosong yang tersedia di disk.

## Menyediakan Ruang di Windows

Untuk menginstal berdampingan dengan Windows, ketik `disk management` di menu start dan pilih opsi **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Temukan partisi yang sesuai, klik kanan, dan pilih **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Masukkan jumlah seberapa besar Anda ingin mengecilkan volume tersebut. Perhatikan bahwa ini akan menjadi ukuran instalasi Omarchy Anda di masa mendatang termasuk partisi boot.

 ![dual-boot-3](images/dual-boot-3.webp)

Setelah selesai, Anda akan melihat sesuatu seperti ini di mana bagian 50GB adalah tempat kita akan menginstal Omarchy dalam contoh ini.

 ![dual-boot-4](images/dual-boot-4.webp)

## Menginstal Omarchy

Proses instalasi Omarchy pada dasarnya sama seperti biasanya. Setelah Anda memilih disk, Anda akan diberi opsi **Free space install**. Pilih opsi tersebut untuk mencegah penghapusan seluruh disk.

 ![dual-boot-5](images/dual-boot-5.webp)

Konfirmasikan bahwa semuanya terlihat baik dan tunggu instalasi selesai seperti biasanya. Di sinilah Anda juga dapat memilih untuk menginstal tanpa enkripsi (tidak disarankan) sama seperti pada instalasi full-drive.
 ![dual-boot-6](images/dual-boot-6.webp)

## Menambahkan Instalasi Lain ke Bootloader

Setelah instalasi Omarchy Anda selesai, Anda akan menyadari bahwa bootloader Limine kini menjadi default. Dengan ini, Anda juga dapat menambahkan opsi ke Limine untuk instalasi lain Anda seperti Windows.

Untuk menambahkan sistem operasi lain, jalankan `limine-scan` dan ikuti petunjuk untuk menambahkan entri yang Anda inginkan ke config Limine Anda. Menu boot tetap tersembunyi secara default dan memulai Omarchy setelah satu detik. Untuk memilih Windows atau entri lain, tekan tombol apa saja segera setelah Limine dimulai; saat menu muncul, gunakan tombol panah untuk memilih entri dan tekan Enter. Jika Omarchy dimulai sebelum Anda menekan tombol, restart dan coba lagi. Jika Anda mengaktifkan _Setup > Direct Boot_, firmware akan melewati Limine sepenuhnya, jadi pilih Limine dari menu boot BIOS Anda atau jalankan _Setup > Direct Boot_ lagi untuk menghapus entri tersebut.

## Bitlocker

Penting untuk dicatat bahwa metode instalasi ini tidak kompatibel dengan Bitlocker karena ia mengenkripsi seluruh drive, bukan hanya partisinya. Jika Anda menemui error yang menyatakan bahwa Bitlocker diaktifkan, boot ke Windows, buka **Settings -> Privacy & Security -> Device encryption** dan nonaktifkan Bitlocker. Mungkin diperlukan waktu untuk mendekripsi drive.

 ![dual-boot-7](images/dual-boot-7.webp)
