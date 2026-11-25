# Tidur sistem

Omarchy mengaktifkan suspend secara default, dan hibernasi setelah disiapkan, tetapi jika Anda mengalami masalah dengan salah satunya di mesin Anda, Anda bisa menonaktifkannya.

Di mesin NVIDIA GB10, seperti DGX Spark dan ASUS Ascent GX10, suspend dan hibernasi dimatikan, sama seperti di DGX OS milik NVIDIA, karena tidur belum terbukti berfungsi di perangkat keras tersebut. Hal yang sama berlaku untuk ASUS Zenbook A16 (UX3607OA), di mana suspend belum membuat chip benar-benar tidur dan bisa hang semalaman. Toggle suspend dan penyiapan hibernasi tidak berlaku di sana. Untuk mengaktifkan tidur kembali, hapus `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` dengan `sudo rm`; Suspend kemudian kembali ke menu, dan hibernasi bisa disiapkan seperti di mesin lain. Menjalankan `sudo omarchy apply hardware --install-user "$USER"` akan mengembalikan file tersebut.

### Profil daya

Di laptop, Omarchy mengingat profil daya Anda secara terpisah untuk saat tercolok dan saat berjalan dengan baterai, dan beralih di antara keduanya saat Anda mencolok dan mencabut. Secara default itu berarti performance saat AC dan balanced saat baterai.

Anda bisa melihat apa yang ditawarkan mesin Anda dengan `omarchy powerprofiles list`, dan mengatur yang Anda inginkan untuk status Anda saat ini dengan `omarchy powerprofiles set autodetect power-saver`. Untuk mengatur status lainnya tanpa mencabut apa pun, sebutkan langsung: `omarchy powerprofiles set battery power-saver`. Apa pun yang Anda pilih adalah yang akan Anda dapatkan kembali saat berikutnya Anda berada dalam status tersebut.

### Toggle suspend

Anda mengaktifkan/menonaktifkan suspend dengan menjalankan `omarchy toggle suspend` dari terminal. Itu hanya menampilkan/menyembunyikan opsi di bawah _System_ (atau `Super + Esc`), lalu Anda bisa melihat apakah itu berfungsi secara konsisten di sistem Anda. Jika tidak, Anda bisa menyembunyikannya lagi dengan perintah yang sama.

### Toggle hibernasi

Anda menyiapkan hibernasi dengan menjalankan `omarchy hibernation setup` dari terminal (ini tidak tersedia di Mac Apple Silicon). Hibernasi membuat subvolume /swap di drive boot Anda sebesar alokasi RAM fisik Anda, jadi pastikan Anda memiliki banyak ruang luang. Di mesin 32GB, Anda akan selalu membutuhkan ruang kosong 32GB+ untuk volume ini. Hibernasi juga memerlukan bootloader Limine default.

Setelah disiapkan, Anda akan melihat opsi hibernate di bawah _System_ (atau `Super + Esc`), lalu Anda bisa melihat apakah itu berfungsi secara konsisten di sistem Anda. Jika tidak, Anda bisa menghapusnya lagi dengan menjalankan `omarchy hibernation remove`.
