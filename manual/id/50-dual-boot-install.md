# Instalasi Dual Boot

Anda dapat menginstal Omarchy ke satu partisi di samping Windows atau instalasi lainnya.

Metode instalasi ini tetap dilengkapi enkripsi LUKS untuk partisi secara default, jadi pada dasarnya tidak berbeda dengan instalasi satu drive penuh dan hanya membutuhkan ruang kosong yang tersedia di disk.

## Membuat Ruang di Windows

Untuk menginstal di samping Windows, ketik `disk management` di menu Start dan pilih opsi **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Temukan partisi yang sesuai, klik kanan, dan pilih **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Masukkan jumlah yang ingin Anda kecilkan dari volume tersebut. Perhatikan bahwa ini akan menjadi ukuran instalasi Omarchy Anda di masa mendatang, termasuk partisi boot.

 ![dual-boot-3](images/dual-boot-3.webp)

Setelah selesai, Anda akan melihat sesuatu seperti ini, di mana bagian 50GB adalah tempat kami akan menginstal Omarchy dalam contoh ini.

 ![dual-boot-4](images/dual-boot-4.webp)

## Menginstal Omarchy

Proses instalasi Omarchy pada dasarnya sama seperti biasa. Setelah Anda memilih disk, Anda akan diberikan opsi **Free space install**. Pilih opsi tersebut untuk mencegah penghapusan seluruh disk.

 ![dual-boot-5](images/dual-boot-5.webp)

Konfirmasi bahwa semuanya terlihat baik dan tunggu hingga instalasi selesai seperti biasa. Di sini Anda juga dapat memilih untuk menginstal tanpa enkripsi (tidak disarankan), sama seperti pada instalasi satu drive penuh.
 ![dual-boot-6](images/dual-boot-6.webp)

## Menambahkan Instalasi Lain ke Bootloader

Setelah Anda menyelesaikan instalasi Omarchy, Anda akan melihat bahwa bootloader Limine kini menjadi default. Dengan ini, Anda juga dapat menambahkan opsi ke Limine untuk instalasi lain Anda, seperti Windows.

Untuk menambahkan sistem operasi lain, jalankan `limine-scan` dan ikuti petunjuk untuk menambahkan entri yang Anda inginkan ke konfigurasi Limine Anda. Menu boot tetap tersembunyi secara default dan memulai Omarchy setelah satu detik. Untuk memilih Windows atau entri lain, tekan tombol apa saja segera setelah Limine mulai; saat menu muncul, gunakan tombol panah untuk memilih entri dan tekan Enter. Jika Omarchy mulai sebelum Anda menekan tombol, mulai ulang dan coba lagi.

## Bitlocker

Penting untuk dicatat bahwa metode instalasi ini tidak kompatibel dengan Bitlocker karena Bitlocker mengenkripsi seluruh drive, bukan hanya partisi. Jika Anda menemukan error yang menyatakan bahwa Bitlocker diaktifkan, boot ke Windows, buka **Settings -> Privacy & Security -> Device encryption** dan nonaktifkan Bitlocker. Mungkin perlu waktu untuk mendekripsi drive.

 ![dual-boot-7](images/dual-boot-7.webp)

## Menginstal Ulang Windows

Jika komputer ini dikirim dengan Windows, product key-nya disimpan di firmware. Jalankan `omarchy windows key` untuk mencetaknya, sehingga Anda dapat mengaktifkan Windows lagi jika Anda pernah menginstal ulang Windows di mesin ini.
