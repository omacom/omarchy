# Autentikasi perangkat keras

### Autentikasi sidik jari

Banyak laptop dilengkapi sensor sidik jari untuk melakukan autentikasi. Anda bisa menggunakannya dengan Omarchy dengan menjalankan _Setup > Security > Fingerprint_ di menu Omarchy (`Super + Space`).

Itu akan membuka sidik jari layar penuh yang terisi saat Anda menyentuh sensor. Di baliknya, Omarchy akan menginstal paket sidik jari, mengumpulkan sidik jari Anda, memverifikasinya, dan Anda siap menggunakan sidik jari untuk membuka kunci dari layar kunci (yang bisa Anda picu dengan `Super + Ctrl + L`), masuk ke mode sudo, dan mengotorisasi prompt sistem.

Setelah layar kunci mematikan layar, sensor beristirahat untuk menghemat daya, jadi bangunkan layar dengan tombol apa pun atau touchpad sebelum menyentuhnya.

Saat penutup laptop Anda tertutup, prompt sidik jari otomatis dilewati, jadi Anda langsung masuk ke prompt kata sandi alih-alih menunggu sensor yang tidak bisa Anda jangkau. Jika Anda perlu bekerja dengan keyboard eksternal yang tidak memiliki sensor, cukup tekan `CTRL + C`, saat Anda diminta sidik jari selama `sudo`.

Anda bisa menghapus autentikasi sidik jari di _Remove > Security > Fingerprint_ di menu Omarchy.

### Autentikasi Fido2

Jika Anda menggunakan perangkat Fido2, Anda bisa mengaturnya untuk autentikasi `sudo` menggunakan _Setup > Security > Fido2_ di menu Omarchy (`Super + Space`). Namun, ini mencakup prompt `sudo` dan otorisasi sistem, bukan membuka kunci komputer Anda.

Anda bisa menghapus autentikasi fido2 di _Remove > Security > Fido2_ di menu Omarchy.
