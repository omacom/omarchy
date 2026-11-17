# Tidur sistem

Omarchy mengaktifkan suspend dan hibernasi secara default, tetapi jika Anda mengalami masalah dengan salah satunya di mesin Anda, Anda dapat menonaktifkannya.

Pada mesin NVIDIA GB10, seperti DGX Spark dan ASUS Ascent GX10, suspend dan hibernasi dimatikan, sama seperti di DGX OS milik NVIDIA, karena tidur belum terbukti bekerja pada perangkat keras tersebut. Hal yang sama berlaku untuk ASUS Zenbook A16 (UX3607OA), di mana suspend belum membuat chip benar-benar tidur dan dapat macet semalaman. Toggle suspend dan pengaturan hibernasi tidak berlaku di sana. Untuk mengaktifkan kembali tidur, hapus `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` dengan `sudo rm`; Suspend kemudian kembali ke menu, dan hibernasi dapat diatur seperti pada mesin lain. Menjalankan `sudo omarchy apply hardware --install-user "$USER"` akan mengembalikan file tersebut.

### Profil daya

Di laptop, Omarchy mengingat profil daya Anda secara terpisah untuk saat terhubung ke listrik dan saat menggunakan baterai, dan beralih di antara keduanya saat Anda mencolokkan dan mencabut. Secara bawaan, itu berarti performance saat menggunakan AC dan balanced saat menggunakan baterai.

Anda dapat melihat apa yang ditawarkan mesin Anda dengan `omarchy powerprofiles list`, dan mengatur yang Anda inginkan untuk keadaan Anda saat ini dengan `omarchy powerprofiles set autodetect power-saver`. Untuk mengatur keadaan lainnya tanpa mencabut apa pun, sebutkan secara langsung: `omarchy powerprofiles set battery power-saver`. Apa pun yang Anda pilih adalah yang akan Anda dapatkan kembali saat berikutnya Anda berada dalam keadaan tersebut.

### Mengaktifkan/menonaktifkan suspend

Anda mengaktifkan/menonaktifkan suspend dengan menjalankan `omarchy toggle suspend` dari terminal. Itu hanya menampilkan/menyembunyikan opsi di bawah _System_ (atau `Super + Esc`), dan kemudian Anda dapat melihat apakah itu bekerja secara konsisten di sistem Anda. Jika tidak, Anda dapat menyembunyikannya lagi dengan perintah yang sama.

### Mengaktifkan/menonaktifkan hibernasi

Anda mengatur hibernasi dengan menjalankan `omarchy hibernation setup` dari terminal. Hibernasi membuat subvolume /swap pada drive boot Anda sebesar alokasi RAM fisik Anda, jadi pastikan Anda memiliki banyak ruang kosong. Pada mesin 32GB, Anda akan selalu membutuhkan ruang kosong 32GB+ untuk volume ini. Hibernasi juga memerlukan bootloader Limine default.

Setelah diatur, Anda akan melihat opsi hibernate di bawah _System_ (atau `Super + Esc`), dan kemudian Anda dapat melihat apakah itu bekerja secara konsisten di sistem Anda. Jika tidak, Anda dapat menghapusnya lagi dengan menjalankan `omarchy hibernation remove`.
