# Pemberitahuan

Notifikasi muncul di pojok kanan atas layar yang sedang aktif. Anda juga dapat mengakses tanggal dan waktu, status baterai, dan cuaca saat ini dengan cepat menggunakan pemberitahuan hotkey.

## Notifikasi

Notifikasi dari aplikasi atau situs yang sama menumpuk menjadi satu dek, jadi kanal Slack yang cerewet tidak akan menggeser kegagalan build Anda dari layar. Arahkan kursor ke dek untuk menyebarkannya; tidak ada yang baru meluncur masuk di bawah penunjuk Anda saat Anda sedang membaca. Klik kartu untuk melompat ke asalnya, klik kanan, klik tengah, atau tekan ✕ untuk menutupnya.

Kartu menawarkan apa yang dibawanya: _Salin kode_ untuk kode verifikasi (disimpan di luar [riwayat clipboard](08-unified-clipboard-history.md) dan dihapus setelah satu menit), ditambah tombol apa pun yang disediakan aplikasi. Tautan dalam teks notifikasi terbuka saat diklik.

Untuk menggunakannya tanpa mouse, tekan `Super + Ctrl + ,`. Notifikasi terbaru dipilih dan tombol-tombolnya diberi nomor: tekan nomor untuk menggunakan salah satu tombol, `Enter` untuk mengklik notifikasi, `↑` dan `↓` untuk berpindah antar-notifikasi, `Delete` untuk menutup satu notifikasi, dan `Esc` untuk mengembalikan keyboard. Ia juga lepas dengan sendirinya setelah beberapa detik tidak digunakan.

Mendiamkan notifikasi menahannya, kecuali konfirmasi milik Omarchy sendiri, peringatan darurat, dan kode verifikasi, yang baru saja Anda minta beberapa saat lalu. Tampilkan kembali beberapa notifikasi terakhir di layar, ditahan atau tidak, dengan `Super + Shift + Alt + ,`. Riwayat disimpan selama sehari.

## Pemberitahuan hotkey

### Tanggal & Waktu

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Cuaca

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Lokasi terdeteksi dari alamat IP Anda, yang biasanya cukup dekat, tetapi tidak selalu. Anda dapat menetapkannya dengan `omarchy weather location --set Malibu`, atau bersikap tepat mengenainya dengan menambahkan koordinat: `omarchy weather location --set Malibu 34.0259,-118.7798`. Jalankan `omarchy weather location` sendiri untuk melihat di mana ia mengira Anda berada, dan `--clear` untuk kembali ke deteksi otomatis.

### Baterai

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
