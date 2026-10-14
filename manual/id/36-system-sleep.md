# Tidur sistem

Omarchy mengaktifkan penangguhan dan hibernasi secara bawaan, tetapi jika kamu mengalami masalah dengan salah satunya di mesinmu, kamu bisa mematikannya.

### Profil daya

Di laptop, Omarchy mengingat profil dayamu secara terpisah untuk saat terhubung ke listrik dan saat menggunakan baterai, dan beralih di antara keduanya saat kamu mencolokkan dan mencabut. Secara bawaan itu berarti performa saat AC dan seimbang saat baterai.

Kamu bisa melihat apa yang ditawarkan mesinmu dengan `omarchy powerprofiles list`, dan mengatur yang kamu inginkan untuk keadaanmu saat ini dengan `omarchy powerprofiles set autodetect power-saver`. Untuk mengatur keadaan yang lain tanpa mencabut apa pun, sebutkan langsung: `omarchy powerprofiles set battery power-saver`. Apa pun yang kamu pilih adalah apa yang akan kamu dapatkan kembali saat berikutnya kamu berada dalam keadaan itu.

### Alihkan penangguhan

Kamu mengalihkan penangguhan dengan menjalankan `omarchy toggle suspend` dari terminal. Itu hanya memperlihatkan/menyembunyikan opsi di bawah _Sistem_ (atau `Super + Esc`), lalu kamu bisa melihat apakah itu berfungsi secara konsisten di sistemmu. Jika tidak, kamu bisa menyembunyikannya lagi dengan perintah yang sama.

### Alihkan hibernasi

Kamu mengatur hibernasi dengan menjalankan `omarchy hibernation setup` dari terminal. Hibernasi membuat subvolume /swap di drive boot kamu sebesar alokasi RAM fisikmu, jadi pastikan kamu punya banyak ruang luang. Di mesin 32GB, kamu akan selalu membutuhkan ruang kosong 32GB+ untuk volume ini. Hibernasi juga membutuhkan bootloader Limine bawaan.

Saat sudah diatur, kamu akan melihat opsi hibernasi di bawah _Sistem_ (atau `Super + Esc`), lalu kamu bisa melihat apakah itu berfungsi secara konsisten di sistemmu. Jika tidak, kamu bisa menghapusnya lagi dengan menjalankan `omarchy hibernation remove`.
