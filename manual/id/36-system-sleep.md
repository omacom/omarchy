# Tidur sistem

Omarchy mengaktifkan suspend secara bawaan, dan hibernasi setelah diatur, tetapi jika kamu mengalami masalah dengan salah satunya di mesinkamu, kamu bisa mematikannya.

Pada mesin NVIDIA GB10, seperti DGX Spark dan ASUS Ascent GX10, suspend dan hibernasi dimatikan, sama seperti di DGX OS milik NVIDIA, karena mode tidur belum terbukti bekerja pada perangkat keras tersebut. Toggle suspend dan pengaturan hibernasi tidak berlaku di sana. Untuk mengaktifkan kembali mode tidur, hapus `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` dengan `sudo rm`; Suspend kemudian kembali ke menu, dan hibernasi bisa diatur seperti pada mesin lain. Menjalankan `sudo omarchy apply hardware --install-user "$USER"` mengembalikan file tersebut.

### Profil daya

Di laptop, Omarchy mengingat profil dayamu secara terpisah untuk kondisi terhubung ke listrik dan berjalan dengan baterai, dan beralih di antara keduanya saat kamu mencolokkan dan mencabut. Secara bawaan itu berarti performance pada AC dan balanced pada baterai.

Kamu bisa melihat apa yang ditawarkan mesinkamu dengan `omarchy powerprofiles list`, dan mengatur yang kamu inginkan untuk kondisi kamu saat ini dengan `omarchy powerprofiles set autodetect power-saver`. Untuk mengatur kondisi lainnya tanpa mencabut apa pun, sebutkan langsung: `omarchy powerprofiles set battery power-saver`. Apa pun yang kamu pilih adalah yang akan kamu dapatkan kembali saat berikutnya kamu berada dalam kondisi tersebut.

### Nyala/matikan suspend

Kamu menyala/matikan suspend dengan menjalankan `omarchy toggle suspend` dari terminal. Itu hanya menampilkan/menyembunyikan opsi di bawah _System_ (atau `Super + Esc`), lalu kamu bisa melihat apakah itu bekerja secara konsisten di sistemmu. Jika tidak, kamu bisa menyembunyikannya lagi dengan perintah yang sama.

### Nyala/matikan hibernasi

Kamu mengatur hibernasi dengan menjalankan `omarchy hibernation setup` dari terminal (ini tidak tersedia di Mac Apple Silicon). Hibernasi membuat subvolume /swap di drive boot kamu sebesar alokasi RAM fisik kamu, jadi pastikan kamu punya banyak ruang kosong. Pada mesin 32GB, kamu akan selalu membutuhkan 32GB+ kosong untuk volume ini. Hibernasi juga membutuhkan bootloader Limine bawaan.

Setelah diatur, kamu akan melihat opsi hibernate di bawah _System_ (atau `Super + Esc`), lalu kamu bisa melihat apakah itu bekerja secara konsisten di sistemmu. Jika tidak, kamu bisa menghapusnya lagi dengan menjalankan `omarchy hibernation remove`.
