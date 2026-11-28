# Notis

Pemberitahuan mendarat di penjuru atas kanan paparan yang difokuskan. Anda juga boleh mengakses tarikh dan masa, status bateri, dan cuaca semasa dengan pantas menggunakan notis kekunci pintas.

## Pemberitahuan

Pemberitahuan daripada aplikasi atau laman yang sama disusun menjadi satu dek, supaya saluran Slack yang banyak berbual tidak menolak kegagalan binaan anda keluar dari skrin. Layangkan kursor pada dek untuk mengembangkannya; tiada yang baharu meluncur masuk di bawah penunjuk anda semasa anda membaca. Klik kad untuk melompat ke tempat asalnya, klik kanan, klik tengah, atau tekan ✕ untuk menolaknya.

Kad menawarkan apa yang dibawanya: _Salin kod_ untuk kod pengesahan (tidak disimpan dalam [sejarah papan klip](08-unified-clipboard-history.md) dan dipadam selepas seminit), serta sebarang butang yang disediakan aplikasi. Pautan dalam teks pemberitahuan dibuka apabila diklik.

`Super + ,` menolak pemberitahuan terbaharu, atau membuka apa yang ditunjuknya apabila ia menawarkan pilihan itu, `Super + Alt + ,` menolak hanya yang terakhir, `Super + Shift + ,` menolak kesemuanya, dan `Super + Shift + Alt + ,` membuka sejarah. Untuk menggunakannya tanpa tetikus, tekan `Super + Ctrl + ,`. Pemberitahuan terbaharu dipilih dan butangnya dinomborkan: tekan nombor untuk menggunakan salah satu, `Enter` untuk mengklik pemberitahuan, `↑` dan `↓` untuk bergerak antara pemberitahuan, `Delete` untuk menolak satu, dan `Esc` untuk mengembalikan papan kekunci. Ia juga dilepaskan sendiri selepas beberapa saat melahu.

Menyenyapkan pemberitahuan menahannya, kecuali pengesahan Omarchy sendiri, amaran kecemasan, dan kod pengesahan, yang anda minta sebentar tadi. Paparkan semula beberapa yang terakhir pada skrin, sama ada ditahan atau tidak, dengan `Super + Shift + Alt + ,`. Sejarah disimpan selama sehari.

## Notis kekunci pintas

### Tarikh & Masa

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Cuaca

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Lokasi dikesan daripada alamat IP anda, yang biasanya cukup dekat, tetapi tidak selalu. Anda boleh menetapkannya dengan `omarchy weather location --set Malibu`, atau menjadi tepat mengenainya dengan menambah koordinat: `omarchy weather location --set Malibu 34.0259,-118.7798`. Jalankan `omarchy weather location` dengan sendirinya untuk melihat di mana ia fikir anda berada, dan `--clear` untuk kembali kepada pengesanan automatik.

### Bateri

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
