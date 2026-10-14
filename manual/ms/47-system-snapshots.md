# Syot sistem

Kami mencipta syot secara automatik pada setiap kemas kini Omarchy, tetapi sekiranya anda mahu mencipta sendiri, anda boleh menggunakan `omarchy-snapshot create`.

Untuk membut dan memulihkan syot, anda memilihnya dari pemuat but Limine. (Jika anda kini membut terus ke skrin penyahsulitan Omarchy, anda perlu memilih Limine sebagai pilihan but melalui BIOS dahulu).

Dari skrin itu, pilih syot yang anda mahu but berdasarkan tarikh dan versi. Versi Omarchy pada masa syot diambil boleh dilihat di sudut kiri bawah.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Apabila anda tiba di dalam, pemberitahuan akan muncul memberitahu anda bahawa anda berada dalam syot boleh but dan jika anda mengkliknya, akan memulakan proses pemulihan. Sebagai alternatif, anda boleh menggunakan `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Ini akan memulihkan sistem fail akar anda, tetapi bukan `/home` anda. Jadi ia berfungsi untuk mengembalikan kemas kini sistem yang rosak, tetapi bukan untuk memulihkan fail peribadi yang hilang.

Ini juga bermakna direktori `~/.config` anda dikekalkan seperti sedia ada. Jadi jika anda kembali kepada versi perpustakaan atau aplikasi terdahulu yang menyimpan fail konfigurasi dalam format baharu, anda perlu menyelesaikannya secara manual.

_Nota: Ciri ini hanya tersedia pada pemasangan yang menggunakan pemuat but Limine, yang telah menjadi lalai sejak Omarchy 2.0. Ia tidak tersedia jika anda menggunakan GRUB atau systemd-boot._

### Melangkau menu but

Jika anda tidak pernah menyentuh menu but dan hanya mahu mesin terus ke skrin penyahsulitan, jalankan _Persediaan > But Langsung_ dalam menu Omarchy. Itu menambah entri EFI yang menunjuk terus kepada Omarchy, jadi perisian tegar membutnya tanpa berhenti di Limine.

Kekurangannya ialah yang disebut di atas: dengan but langsung dihidupkan, untuk ke syot bermakna memilih Limine dari menu but BIOS anda dahulu. Jalankan _Persediaan > But Langsung_ semula untuk membuang entri dan kembali membut melalui Limine. Sesetengah perisian tegar tidak menyukai entri EFI tersuai, jadi persediaan menolak untuk berjalan pada perisian tegar American Megatrends dan Apple.
