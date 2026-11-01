# Windows VM

Omarchy menawarkan cara mudah untuk menjalankan Windows melalui VM Docker. Kamu dapat memasangnya menggunakan _Pasang > Windows_ dari menu Omarchy (`Super + Space`).

Mesinmu membutuhkan virtualisasi KVM untuk ini, yang sebagian besar memilikinya — tetapi kadang-kadang dimatikan di BIOS, dan pemasang akan memberitahumu jika itu masalahnya. Kamu juga akan menginginkan ruang disk: apa pun yang kamu berikan ke Windows, ditambah sekitar 10GB untuk image itu sendiri.

Pemasang menanyakan berapa banyak RAM, berapa banyak core CPU, dan berapa banyak disk yang akan diserahkan (64GB atau lebih adalah lantai yang masuk akal), kemudian untuk nama pengguna dan kata sandi Windows. Biarkan itu kosong dan kamu mendapatkan `docker` / `admin`. Unduhan memakan waktu cukup lama — 10-15 menit adalah normal — dan kamu dapat mengikuti kemajuannya di browser pada `http://127.0.0.1:8006`. Browser meminta nama pengguna dan kata sandi yang sama sebelum membuka konsol.

 ![windows-vm](images/windows-vm.webp)

## Menggunakannya

Setelah terpasang, luncurkan _Windows_ dari peluncur aplikasi. Itu memulai VM jika belum berjalan dan menghubungkan kamu melalui RDP, layar penuh. Beri waktu 15-30 detik pada cold start.

Sesi RDP membawa suara, mikrofonmu, dan papan klip bersama, jadi menyalin teks antara Linux dan Windows langsung bekerja. Resolusi mengikuti jendelamu, dan Omarchy meneruskan penskalaan tampilanmu, jadi itu bukan kekacauan buram di layar HiDPI.

Saat kamu menutup jendela RDP, VM mati secara otomatis. Jika kamu lebih suka membiarkannya berjalan — misalnya kamu punya sesuatu yang sedang bekerja di sana — luncurkan dengan `omarchy windows vm launch --keep-alive` sebagai gantinya.

Kontrol sisanya ada pada perintah yang sama:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Berbagi berkas

Direktori `~/Windows` di direktori rumahmu secara otomatis dibagikan dengan VM. Taruh berkas di sana jika kamu menginginkannya dapat diakses oleh Windows. VM tidak memiliki akses ke bagian lain dari sistem berkasmu, jadi kamu aman dari apa pun yang jahat di sisi Windows. Disk virtualnya sendiri tersedia di `~/.windows`.

Jalur rumah yang familier tersebut tetap berada di sistem berkasnya sendiri. Itu juga dapat berupa symlink ke direktori yang kamu miliki, yang berguna saat disk virtual berada di drive yang lebih besar. Pemasang mengukur ruang kosong pada sistem berkas yang benar-benar berisi `~/.windows`, belum tentu sistem berkas yang berisi direktori rumahmu.

Jaga jalur disk dan jalur bersama sebagai direktori terpisah yang tidak tumpang tindih. Penghapusan dengan sengaja mengosongkan direktori disk tetapi mempertahankan direktori bersama. Segera sebelum penghapusan, Omarchy melakukan pemeriksaan penahanan terbatas dan menolak menghapus apa pun jika pemeriksaan tersebut kehabisan waktu atau tidak dapat membuktikan kedua pohon terpisah.

Sebelum VM dimulai, Omarchy membuka dan menyematkan kedua direktori tersebut, kemudian bind-mount inode direktori yang tepat ke jangkar privat per pengguna di bawah `/var/lib/omarchy/windows/mounts`. Docker hanya melihat jangkar yang dilindungi root tersebut. Ini mempertahankan lokasi disk kustom sambil mencegah proses lain yang berjalan sebagai dirimu menukar jalur yang diperiksa sebelum kontainer yang memiliki hak istimewa menggunakannya. Direktori disk dan bersama yang ada diperketat ke mode `0700` selama migrasi sehingga akun lokal lain tidak dapat menelusuri isinya.

Port VM terikat ke localhost saja, jadi tidak ada apa pun di jaringanmu yang dapat mencapai mesin Windows. Konsol web juga memerlukan nama pengguna dan kata sandi Windows yang dikonfigurasi, mencegah akun lokal lain mengendalikan VM melalui port 8006.

## Batas dan lisensi

Tidak ada GPU passthrough dengan penyiapan ini, jadi tidak cocok untuk gaming atau pengeditan video. Ini adalah cara bagus untuk menjalankan Microsoft Office atau apa pun yang benar-benar harus kamu miliki.

Versi yang dipasang adalah Windows 11 Pro, belum diaktifkan. Kamu akan memerlukan kunci lisensimu sendiri untuk menggunakan fitur yang dibatasi.

Jika komputer ini dikirim dengan Windows, kunci OEM masih ada di firmware bahkan setelah memasang Omarchy. Cetak dengan `omarchy windows key`. Kunci tersebut terikat ke mesin ini — itu akan mengaktifkan Windows yang dipasang ulang di perangkat keras ini, tetapi biasanya tidak akan mengaktifkan VM.

Kamu dapat mengubah alokasi sumber daya nanti dengan menjalankan ulang `omarchy-windows-vm install`, yang menulis ulang konfigurasi VM dari jawabanmu. Berkas compose itu sendiri sekarang berada di `/var/lib/omarchy/windows/docker-compose.yml` dan dimiliki oleh root — itu disengaja, jadi proses yang berjalan sebagai dirimu tidak dapat menulis ulangnya dan membuat bring-up yang memiliki hak istimewa me-mount seluruh diskmu ke dalam kontainer. Jika kamu perlu mengeditnya secara manual (misalnya untuk me-mount perangkat USB), edit dengan `sudo` dan lihat semua pilihan di [proyek Dockur Windows](https://github.com/dockur/windows).

Untuk membuang semuanya, gunakan _Hapus > Windows_ dari menu Omarchy. Itu menghapus disk VM dan semua datanya, jadi pastikan apa pun yang kamu pedulikan sudah keluar dari `~/Windows` terlebih dahulu.
