# Notis

Pemberitahuan tiba di sudut kanan atas pada paparan yang sedang difokuskan. Anda juga boleh mengakses tarikh dan masa, status bateri, serta cuaca semasa dengan pantas menggunakan notis kekunci pintas.

## Pemberitahuan

Pemberitahuan daripada aplikasi atau laman yang sama disusun bertindan menjadi satu dek, jadi saluran Slack yang bising tidak akan menolak kegagalan binaan anda keluar dari skrin. Layangkan kursor di atas dek untuk mengembangkannya; tiada yang baharu akan meluncur masuk di bawah penuding anda semasa anda sedang membaca. Klik kad untuk melompat ke tempat asalnya, klik kanan, klik tengah, atau tekan ✕ untuk menyingkirkannya.

Kad menawarkan apa yang dibawanya: _Salin kod_ untuk kod pengesahan (tidak disimpan dalam [sejarah papan klip](08-unified-clipboard-history.md) dan dipadamkan selepas seminit), serta sebarang butang yang disediakan oleh aplikasi. Pautan dalam teks pemberitahuan akan dibuka apabila diklik.

Untuk menggunakannya tanpa tetikus, tekan `Super + Ctrl + ,`. Pemberitahuan terbaharu dipilih dan butang-butangnya dinomborkan: tekan nombor untuk menggunakan salah satu, `Enter` untuk mengklik pemberitahuan, `↑` dan `↓` untuk bergerak antara pemberitahuan, `Delete` untuk menyingkirkan satu, dan `Esc` untuk memulangkan papan kekunci. Ia juga akan melepaskannya sendiri selepas beberapa saat terbiar.

Menyenyapkan pemberitahuan akan menahannya, kecuali pengesahan Omarchy sendiri, amaran kecemasan, dan kod pengesahan, yang anda minta sebentar tadi. Paparkan semula beberapa yang terakhir pada skrin, sama ada ditahan atau tidak, dengan `Super + Shift + Alt + ,`. Sejarah disimpan selama sehari.

## Notis kekunci pintas

### Tarikh & Masa

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Cuaca

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Lokasi dikesan daripada alamat IP anda, yang biasanya cukup hampir, tetapi tidak selalunya. Anda boleh menetapkannya dengan `omarchy weather location --set Malibu`, atau lebih tepat dengan menambah koordinat: `omarchy weather location --set Malibu 34.0259,-118.7798`. Jalankan `omarchy weather location` secara bersendirian untuk melihat lokasi yang difikirkannya anda berada, dan `--clear` untuk kembali kepada pengesanan automatik.

### Bateri

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
