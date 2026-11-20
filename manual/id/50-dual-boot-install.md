# Instalasi Dual Boot

Anda dapat menginstal Omarchy ke satu partisi di samping Windows atau instalasi lain.

Metode instalasi ini tetap dilengkapi enkripsi LUKS untuk partisinya secara default, jadi pada dasarnya tidak berbeda dengan instalasi satu drive penuh dan hanya memerlukan ruang kosong yang tersedia di disk.

## Membuat Ruang di Windows

Untuk menginstal di samping Windows, ketik `disk management` di menu Start dan pilih opsi **Buat dan format partisi hard disk**.

 ![dual-boot-1](images/dual-boot-1.webp)

Temukan partisi yang sesuai, klik kanan, dan pilih **Kecilkan Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Masukkan jumlah yang ingin Anda gunakan untuk mengecilkan volume. Perhatikan bahwa ini akan menjadi ukuran instalasi Omarchy Anda di masa mendatang, termasuk partisi boot.

 ![dual-boot-3](images/dual-boot-3.webp)

Setelah selesai, Anda akan melihat sesuatu seperti ini, dengan bagian 50GB sebagai tempat kami akan menginstal Omarchy dalam contoh ini.

 ![dual-boot-4](images/dual-boot-4.webp)

## Menginstal Omarchy

Proses instalasi Omarchy pada dasarnya sama seperti biasanya. Setelah Anda memilih disk, Anda akan diberi opsi **Instalasi ruang kosong**. Pilih opsi tersebut untuk mencegah seluruh disk terhapus.

 ![dual-boot-5](images/dual-boot-5.webp)

Konfirmasikan bahwa semuanya sudah benar dan tunggu hingga instalasi selesai seperti biasa. Di sini Anda juga dapat memilih untuk menginstal tanpa enkripsi (tidak disarankan), sama seperti pada instalasi satu drive penuh.
 ![dual-boot-6](images/dual-boot-6.webp)

## Menambahkan Instalasi Lain ke Bootloader

Setelah instalasi Omarchy selesai, Anda akan menyadari bahwa bootloader Limine kini menjadi default. Dengan ini, Anda juga dapat menambahkan opsi ke Limine untuk instalasi lain Anda, seperti Windows.

Untuk menambahkan sistem operasi lain, jalankan `limine-scan` dan ikuti petunjuk untuk menambahkan entri yang Anda inginkan ke konfigurasi Limine Anda. Menu boot tetap tersembunyi secara default dan memulai Omarchy setelah satu detik. Untuk memilih Windows atau entri lain, tekan tombol apa saja segera setelah Limine mulai; saat menu muncul, gunakan tombol panah untuk memilih entri dan tekan Enter. Jika Omarchy mulai sebelum Anda menekan tombol, mulai ulang dan coba lagi.

## Bitlocker

Penting untuk diperhatikan bahwa metode instalasi ini tidak kompatibel dengan Bitlocker karena Bitlocker mengenkripsi seluruh drive, bukan hanya partisinya. Jika Anda menemui kesalahan yang menyatakan bahwa Bitlocker diaktifkan, boot ke Windows, buka **Pengaturan -> Privasi & Keamanan -> Enkripsi perangkat**, lalu nonaktifkan Bitlocker. Mungkin perlu waktu untuk mendekripsi drive.

 ![dual-boot-7](images/dual-boot-7.webp)
