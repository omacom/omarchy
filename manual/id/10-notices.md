# Pemberitahuan

Notifikasi muncul di sudut kanan atas layar yang sedang difokuskan. Kamu juga bisa mengakses tanggal dan waktu, status baterai, dan cuaca saat ini dengan cepat menggunakan pemberitahuan hotkey.

## Notifikasi

Notifikasi dari aplikasi atau situs yang sama ditumpuk menjadi satu dek, jadi channel Slack yang cerewet tidak akan mendorong kegagalan build-mu keluar layar. Arahkan kursor ke sebuah dek untuk mengembangkannya; tidak ada yang baru meluncur masuk di bawah pointer-mu saat kamu sedang membaca. Klik sebuah kartu untuk melompat ke asal notifikasi itu, klik kanan, klik tengah, atau tekan ✕ untuk menutupnya.

Kartu menawarkan apa yang dibawanya: _Salin kode_ untuk kode verifikasi (disimpan di luar [riwayat clipboard](08-unified-clipboard-history.md) dan dihapus setelah satu menit), plus tombol apa pun yang disediakan aplikasi. Tautan di dalam teks notifikasi akan terbuka saat diklik.

`Super + ,` menutup notifikasi terbaru, atau membuka apa yang ditunjuknya bila menawarkan hal itu, `Super + Alt + ,` hanya menutup notifikasi terakhir, `Super + Shift + ,` menutup semuanya, dan `Super + Shift + Alt + ,` membuka riwayat. Untuk menggunakannya tanpa mouse, tekan `Super + Ctrl + ,`. Notifikasi terbaru akan terpilih dan tombol-tombolnya diberi nomor: tekan sebuah nomor untuk menggunakan salah satunya, `Enter` untuk mengklik notifikasi, `↑` dan `↓` untuk berpindah antar notifikasi, `Delete` untuk menutup salah satu, dan `Esc` untuk mengembalikan keyboard. Fitur ini juga akan lepas dengan sendirinya setelah beberapa detik tidak digunakan.

Membisukan notifikasi akan menahannya, kecuali konfirmasi milik Omarchy sendiri, peringatan darurat, dan kode verifikasi, yang baru saja kamu minta beberapa saat lalu. Tampilkan kembali beberapa notifikasi terakhir di layar, baik yang ditahan maupun tidak, dengan `Super + Shift + Alt + ,`. Riwayat disimpan selama satu hari.

## Pemberitahuan hotkey

### Tanggal & Waktu

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Cuaca

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Lokasi terdeteksi dari alamat IP kamu, yang biasanya cukup akurat, tapi tidak selalu. Kamu bisa menetapkannya dengan `omarchy weather location --set Malibu`, atau lebih presisi dengan menambahkan koordinat: `omarchy weather location --set Malibu 34.0259,-118.7798`. Jalankan `omarchy weather location` saja untuk melihat di mana lokasimu menurutnya, dan `--clear` untuk kembali ke deteksi otomatis.

### Baterai

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
