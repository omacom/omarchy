# Snapshot sistem

Kami membuat snapshot secara otomatis pada setiap pembaruan Omarchy, tetapi jika Anda ingin membuat snapshot sendiri, Anda dapat menggunakan `omarchy-snapshot create`.

Untuk boot dan memulihkan snapshot, Anda memilihnya dari boot loader Limine. (Jika saat ini Anda boot langsung ke layar dekripsi Omarchy, Anda harus memilih Limine sebagai opsi boot melalui BIOS terlebih dahulu).

Dari layar tersebut, pilih snapshot yang ingin Anda gunakan untuk boot berdasarkan tanggal dan versinya. Versi Omarchy pada saat snapshot dibuat dapat dilihat di sudut kiri bawah.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Saat Anda sudah masuk, sebuah notifikasi akan muncul untuk memberi tahu Anda bahwa Anda berada di dalam snapshot yang dapat di-boot dan jika Anda mengkliknya, proses pemulihan akan dimulai. Sebagai alternatif, Anda dapat menggunakan `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Ini akan memulihkan filesystem root Anda, tetapi bukan `/home` Anda. Jadi ini berguna untuk mengembalikan pembaruan sistem yang rusak, tetapi bukan untuk memulihkan file pribadi yang hilang.

Ini juga berarti direktori `~/.config` Anda tetap apa adanya. Jadi jika Anda kembali ke versi library atau aplikasi yang lebih lama yang menyimpan file konfigurasi dalam format baru, Anda harus mengurusnya secara manual.

Hal yang sama berlaku untuk catatan Omarchy sendiri tentang migrasi mana yang sudah dijalankan: catatan itu berada di direktori home Anda, jadi tetap ada setelah pemulihan. Migrasi yang dijalankan setelah snapshot dibuat tetap ditandai sebagai selesai, meskipun perubahan yang dibuatnya pada filesystem root telah dikembalikan, dan `omarchy update` berikutnya tidak akan menjalankannya lagi. Jadi jika Anda memperbarui lagi setelah pemulihan dan sesuatu yang telah disiapkan oleh pembaruan sebelumnya masih hilang, kemungkinan besar itulah penyebabnya.

_Catatan: Fitur ini hanya tersedia pada instalasi yang menggunakan boot loader Limine, yang telah menjadi default sejak Omarchy 2.0. Fitur ini tidak tersedia jika Anda menggunakan GRUB atau systemd-boot._

### Melewati menu boot

Jika Anda tidak pernah menyentuh menu boot dan hanya ingin mesin langsung menuju ke layar dekripsi, jalankan _Setup > Direct Boot_ di menu Omarchy. Itu akan menambahkan entri EFI yang mengarah langsung ke Omarchy, sehingga firmware melakukan boot tanpa berhenti di Limine.

Komprominya adalah yang disebutkan di bagian atas: dengan direct boot aktif, untuk mencapai snapshot berarti memilih Limine dari menu boot BIOS Anda terlebih dahulu. Jalankan _Setup > Direct Boot_ lagi untuk menghapus entri tersebut dan kembali melakukan boot melalui Limine. Beberapa firmware tidak menyukai entri EFI kustom, jadi setup menolak untuk berjalan pada firmware American Megatrends dan Apple.
