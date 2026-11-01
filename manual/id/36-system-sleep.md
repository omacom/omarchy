# Tidur sistem

Omarchy mengaktifkan suspend dan hibernasi secara default, tetapi jika Anda mengalami masalah dengan salah satunya di mesin Anda, Anda dapat menonaktifkannya.

Di mesin NVIDIA GB10, seperti DGX Spark dan ASUS Ascent GX10, suspend dan hibernasi dimatikan, sama seperti di DGX OS milik NVIDIA, karena mode tidur belum terbukti bekerja di hardware tersebut. Toggle suspend dan pengaturan hibernasi tidak berlaku di sana. Untuk mengaktifkan kembali mode tidur, hapus `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` dengan `sudo rm`; Suspend kemudian akan kembali ke menu, dan hibernasi dapat diatur seperti di mesin lain. Menjalankan `sudo omarchy apply hardware --install-user "$USER"` akan mengembalikan file tersebut.

### Profil daya

Di laptop, Omarchy mengingat profil daya Anda secara terpisah untuk kondisi terhubung ke listrik dan berjalan dengan baterai, dan beralih di antara keduanya saat Anda mencolokkan dan mencabutnya. Secara default, itu berarti performance saat terhubung ke AC dan balanced saat menggunakan baterai.

Anda dapat melihat apa yang ditawarkan mesin Anda dengan `omarchy powerprofiles list`, dan mengatur profil yang Anda inginkan untuk kondisi Anda saat ini dengan `omarchy powerprofiles set autodetect power-saver`. Untuk mengatur kondisi lainnya tanpa mencabut apa pun, sebutkan langsung: `omarchy powerprofiles set battery power-saver`. Apa pun yang Anda pilih akan kembali Anda dapatkan saat berikutnya Anda berada dalam kondisi tersebut.

### Aktif/nonaktifkan suspend

Anda mengaktifkan/menonaktifkan suspend dengan menjalankan `omarchy toggle suspend` dari terminal. Itu hanya menampilkan/menyembunyikan opsi di bawah _System_ (atau `Super + Esc`), lalu Anda dapat melihat apakah opsi itu bekerja secara konsisten di sistem Anda. Jika tidak, Anda dapat menyembunyikannya lagi dengan perintah yang sama.

### Aktif/nonaktifkan hibernasi

Anda mengatur hibernasi dengan menjalankan `omarchy hibernation setup` dari terminal. Hibernasi membuat subvolume /swap di drive boot Anda sebesar alokasi RAM fisik Anda, jadi pastikan Anda memiliki banyak ruang kosong yang tersisa. Di mesin 32GB, Anda akan selalu membutuhkan ruang kosong 32GB+ untuk volume ini. Hibernasi juga memerlukan bootloader Limine default.

Setelah diatur, Anda akan melihat opsi hibernate di bawah _System_ (atau `Super + Esc`), lalu Anda dapat melihat apakah opsi itu bekerja secara konsisten di sistem Anda. Jika tidak, Anda dapat menghapusnya lagi dengan menjalankan `omarchy hibernation remove`.
