# Snapshot sistem

Kami membuat snapshot secara otomatis pada setiap pembaruan Omarchy, tetapi jika kamu ingin membuat milikmu sendiri, kamu bisa menggunakan `omarchy-snapshot create`.

Untuk boot dan memulihkan snapshot, kamu memilihnya dari boot loader Limine. (Jika kamu saat ini boot langsung ke layar dekripsi Omarchy, kamu perlu memilih Limine sebagai opsi boot melalui BIOS terlebih dahulu).

Dari layar itu, pilih snapshot yang ingin kamu boot berdasarkan tanggal dan versi. Versi Omarchy pada saat snapshot dapat dilihat di sudut kiri bawah.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Saat kamu tiba di dalam, notifikasi akan muncul memberitahumu bahwa kamu berada dalam snapshot yang bisa di-boot dan jika kamu mengkliknya, akan memulai proses pemulihan. Sebagai alternatif, kamu bisa menggunakan `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Ini akan memulihkan sistem berkas root kamu, tetapi bukan `/home` kamu. Jadi ini berfungsi untuk mengembalikan pembaruan sistem yang rusak, tetapi bukan untuk memulihkan berkas pribadi yang hilang.

Ini juga berarti direktori `~/.config` kamu dipertahankan apa adanya. Jadi jika kamu kembali ke versi lebih awal dari pustaka atau aplikasi yang menyimpan berkas konfigurasi dalam format baru, kamu harus membereskan itu secara manual.

_Catatan: Fitur ini hanya tersedia pada pemasangan yang menggunakan boot loader Limine, yang telah menjadi bawaan sejak Omarchy 2.0. Ini tidak tersedia jika kamu menggunakan GRUB atau systemd-boot._

### Melewati menu boot

Jika kamu tidak pernah menyentuh menu boot dan hanya ingin mesin langsung menuju layar dekripsi, jalankan _Pengaturan > Direct Boot_ di menu Omarchy. Itu menambahkan entri EFI yang menunjuk langsung ke Omarchy, jadi firmware melakukan boot tanpa berhenti di Limine.

Komprominya adalah yang disebutkan di atas: dengan boot langsung aktif, mencapai snapshot berarti memilih Limine dari menu boot BIOS kamu terlebih dahulu. Jalankan _Pengaturan > Direct Boot_ lagi untuk menghapus entri dan kembali boot melalui Limine. Beberapa firmware tidak menyukai entri EFI kustom, jadi pengaturan menolak berjalan pada firmware American Megatrends dan Apple.
