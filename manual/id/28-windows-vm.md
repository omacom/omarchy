# Windows VM

Omarchy menawarkan cara mudah untuk menjalankan Windows melalui Docker VM di mesin x86_64. Kamu bisa memasangnya menggunakan _Instal > Windows_ dari menu Omarchy (`Super + Space`).

Mesinmu membutuhkan virtualisasi KVM untuk ini, yang memang dimiliki kebanyakan mesin — tetapi fitur ini kadang dimatikan di BIOS, dan pemasang akan memberitahumu jika memang begitu. Kamu juga akan membutuhkan ruang disk: berapa pun yang kamu berikan untuk Windows, ditambah sekitar 10GB untuk image itu sendiri.

Pemasang akan menanyakan berapa banyak RAM, berapa banyak core CPU, dan berapa banyak disk yang akan diserahkan (64GB atau lebih adalah batas bawah yang masuk akal), lalu nama pengguna dan kata sandi Windows. Biarkan keduanya kosong dan kamu akan mendapatkan `docker` / `admin`. Pengunduhannya memakan waktu lama — 10-15 menit adalah waktu yang normal — dan kamu bisa mengikuti kemajuannya di browser di `http://127.0.0.1:8006`. Browser akan meminta nama pengguna dan kata sandi yang sama sebelum membuka konsol.

 ![windows-vm](images/windows-vm.webp)

## Menggunakannya

Setelah terpasang, luncurkan _Windows_ dari peluncur aplikasi. Itu akan memulai VM jika belum berjalan dan menghubungkanmu melalui RDP, dalam layar penuh. Beri waktu 15-30 detik saat memulainya dari keadaan mati.

Sesi RDP membawa suara, mikrofonmu, dan clipboard bersama, jadi menyalin teks antara Linux dan Windows langsung berfungsi. Resolusinya mengikuti jendelamu, dan Omarchy meneruskan penskalaan layar yang kamu gunakan, jadi tampilannya tidak buram berantakan di layar HiDPI.

Saat kamu menutup jendela RDP, VM akan mati secara otomatis. Jika kamu lebih suka membiarkannya tetap berjalan — misalnya ada sesuatu yang sedang bekerja di dalamnya — luncurkan saja dengan `omarchy windows vm launch --keep-alive`.

Kontrol selebihnya ada pada perintah yang sama:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Berbagi file

Direktori `~/Windows` di direktori home milikmu dibagikan secara otomatis dengan VM. Letakkan file di sana jika kamu ingin file tersebut dapat diakses oleh Windows. VM tidak memiliki akses ke bagian lain mana pun dari sistem file milikmu, jadi kamu aman dari apa pun yang berbahaya di sisi Windows. Disk virtual miliknya sendiri tersedia di `~/.windows`.

Path home yang sudah familiar itu tetap berada di sistem file mereka sendiri. Path tersebut juga dapat berupa symlink ke direktori milikmu, yang berguna saat disk virtual berada di drive yang lebih besar. Pemasang mengukur ruang kosong pada sistem file yang benar-benar berisi `~/.windows`, belum tentu sistem file yang berisi direktori home milikmu.

Jaga agar path disk dan path bersama tetap menjadi direktori yang terpisah dan tidak tumpang tindih. Penghapusan secara sengaja mengosongkan direktori disk tetapi mempertahankan direktori bersama. Tepat sebelum penghapusan, Omarchy melakukan pemeriksaan containment terbatas dan menolak menghapus apa pun jika pemeriksaan tersebut kehabisan waktu atau tidak dapat membuktikan bahwa kedua pohon tersebut terpisah.

Sebelum VM dimulai, Omarchy membuka dan menyematkan kedua direktori tersebut, lalu melakukan bind-mount inode direktori yang persis sama ke anchor privat per pengguna di bawah `/var/lib/omarchy/windows/mounts`. Docker hanya melihat anchor yang dilindungi root tersebut. Cara ini mempertahankan lokasi disk kustom sekaligus mencegah proses lain yang berjalan sebagai kamu menukar path yang sudah diperiksa sebelum container berhak istimewa tersebut menggunakannya. Direktori disk dan direktori bersama yang sudah ada diperketat ke mode `0700` selama migrasi agar akun lokal lain tidak dapat menelusuri isinya.

Port VM hanya terikat ke localhost, jadi tidak ada apa pun di jaringanmu yang dapat menjangkau mesin Windows tersebut. Konsol web juga memerlukan nama pengguna dan kata sandi Windows yang telah dikonfigurasi, sehingga akun lokal lain tidak dapat mengendalikan VM melalui port 8006.

## Batasan dan lisensi

Tidak ada GPU passthrough pada pengaturan ini, jadi pengaturan ini tidak cocok untuk gaming atau pengeditan video. Ini adalah cara yang bagus untuk menjalankan Microsoft Office atau apa pun lainnya yang benar-benar harus kamu miliki.

Versi yang dipasang adalah Windows 11 Pro, belum diaktifkan. Kamu akan memerlukan kunci lisensi milikmu sendiri untuk menggunakan fitur-fitur yang terkunci.

Jika komputer ini dikirim bersama Windows, kunci OEM masih tersimpan di firmware bahkan setelah Omarchy dipasang. Tampilkan kunci tersebut dengan `omarchy windows key`. Kunci itu terikat ke mesin ini — kunci itu akan mengaktifkan Windows yang dipasang ulang pada perangkat keras ini, tetapi biasanya tidak akan mengaktifkan VM.

Kamu dapat mengubah alokasi sumber daya nanti dengan menjalankan `omarchy windows vm install` di terminal, yang akan menulis ulang konfigurasi VM berdasarkan jawabanmu. File compose itu sendiri sekarang berada di `/var/lib/omarchy/windows/docker-compose.yml` dan dimiliki oleh root — hal itu disengaja, agar proses yang berjalan sebagai kamu tidak dapat menulis ulang file tersebut lalu membuat proses bring-up berhak istimewa memasang seluruh disk milikmu ke dalam container. Jika kamu perlu mengeditnya secara manual (misalnya untuk memasang perangkat USB), editlah dengan `sudo` dan lihat semua opsinya di [proyek Dockur Windows](https://github.com/dockur/windows).

Untuk menyingkirkan semuanya, gunakan _Hapus > Windows_ dari menu Omarchy. Itu akan menghapus disk VM di `~/.windows` dan semua yang terpasang di dalam Windows, jadi salin terlebih dahulu apa pun yang kamu butuhkan keluar dari VM. Folder bersama milikmu, `~/Windows`, akan dibiarkan apa adanya.
