# Autentikasi perangkat keras

### Autentikasi sidik jari

Banyak laptop dilengkapi sensor sidik jari untuk melakukan autentikasi. Kamu bisa menggunakannya dengan Omarchy dengan menjalankan _Setup > Security > Fingerprint_ di menu Omarchy (`Super + Space`).

Itu akan memasang paket sidik jari, merekam sidik jarimu, memverifikasinya, dan kamu siap menggunakan sidik jarimu untuk membuka kunci dari layar kunci (yang bisa kamu picu dengan `Super + Ctrl + L`), masuk ke mode sudo, dan mengotorisasi prompt sistem.

Begitu layar kunci telah mematikan layar, sensor beristirahat untuk menghemat daya, jadi bangunkan layar dengan tombol apa saja atau touchpad sebelum menyentuhnya.

Saat penutup laptopmu tertutup, prompt sidik jari otomatis dilewati, jadi kamu langsung menuju prompt kata sandi, bukan menunggu sensor yang tidak bisa kamu jangkau. Jika di lain waktu kamu perlu bekerja menggunakan keyboard eksternal yang tidak punya sensor, cukup tekan `CTRL + C` saat kamu diminta sidik jarimu selama `sudo`.

Kamu bisa menghapus autentikasi sidik jari di _Remove > Security > Fingerprint_ pada menu Omarchy.

### Autentikasi Fido2

Jika kamu menggunakan perangkat Fido2, kamu bisa mengaturnya untuk autentikasi `sudo` menggunakan _Setup > Security > Fido2_ di menu Omarchy (`Super + Space`). Namun, ini mencakup `sudo` dan prompt otorisasi sistem, bukan membuka kunci komputermu.

Kamu bisa menghapus autentikasi fido2 di _Remove > Security > Fido2_ pada menu Omarchy.
