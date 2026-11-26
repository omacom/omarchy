# Penjenamaan

Omarchy membolehkan anda menetapkan logo syarikat atau imej peribadi anda untuk kedua-dua buka kunci but, pelindung skrin, dan skrin tentang.

### Buka kunci but

Anda boleh menggunakan `omarchy plymouth preview` untuk melihat rupa logo dan warna tersuai anda. Ia mengambil warna latar belakang, warna teks, png logo, dan laluan untuk imej pratonton:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Kemudian gunakan persediaan itu dengan `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, yang juga akan memberikan skrin log masuk SDDM warna dan logo yang sama. Jika anda mahu mengembalikannya, anda boleh menggunakan `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Pelindung skrin

Anda boleh menukar logo yang digunakan untuk pelindung skrin di bawah _Appearance > Branding > Screensaver_. Ia ialah logo ASCII, jadi anda boleh menyunting teks secara langsung, tetapi anda juga boleh memberikannya imej png atau svg, dan kami akan menukarnya kepada ASCII. Ia kelihatan agak menarik.

 ![branding-screensaver](images/branding-screensaver.webp)

Terdapat tiga entri dalam menu itu:

- **Sunting Teks** membuka `~/.config/omarchy/branding/screensaver.txt` dalam editor anda. Taip atau tampal apa sahaja yang anda suka — seni ASCII, nama anda, perkataan kesat. Simpan dan keluar, dan pelindung skrin akan menyala serta-merta supaya anda dapat melihatnya.
- **Tetapkan Daripada Imej** membuka pemilih fail untuk png atau svg, menukarnya kepada ASCII, dan menunjukkan hasilnya kepada anda. Logo dengan siluet yang jelas berfungsi jauh lebih baik daripada foto.
- **Pulihkan Lalai** mengembalikan logo Omarchy.

### Skrin tentang

Tiga pilihan yang sama terdapat di bawah _Appearance > Branding > About_ untuk skrin _About_ yang anda dapat daripada menu Omarchy, dan ia berfungsi dengan cara yang sama — failnya ialah `~/.config/omarchy/branding/about.txt`, dan tetingkap About akan muncul selepas setiap perubahan. Seni About ditukar kepada saiz yang lebih kecil daripada seni pelindung skrin, kerana ia perlu muat dalam tetingkap dan bukannya memenuhi paparan anda.

Semasa tetingkap itu terbuka, jalur cahaya putih terang melintasi seni itu setiap beberapa saat dan kemudian membiarkannya diam semula. Seni anda sendiri juga mendapatnya, selagi setiap aksara di dalamnya selebar satu lajur — apa sahaja yang dihasilkan oleh _Tetapkan Daripada Imej_ memang begitu. Seni yang dibina daripada emoji atau aksara dwi-lebar kekal diam sebaliknya, dan begitu juga skrin jika anda mengekalkan konfigurasi fastfetch anda sendiri: logo yang diam dalam kes-kes tersebut ialah animasi yang mengelak daripada mengganggu dan bukannya gagal, kerana meluncurkan kilauan melintasinya akan meletakkan baki baris di tempat yang salah.

 ![branding-about](images/branding-about.webp)

### Menukar imej sendiri

Kedua-dua pilihan _Tetapkan Daripada Imej_ hanya memanggil `omarchy transcode ascii`, yang boleh anda jalankan secara langsung jika anda mahukan kawalan ke atas penukaran itu:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Ia mengambil `--width` dan `--height` dalam lajur dan baris terminal, `--mode` sama ada `braille` (lalai, dan jauh lebih halus) atau `block`, peratusan `--threshold` untuk menentukan piksel mana yang dikira sebagai sebahagian daripada logo, dan `--invert` untuk apabila logo anda terang pada latar belakang gelap. Jika hasil penukaran keluar sebagai gumpalan, ambang biasanya tombol yang perlu diputar.

### Perkataan sebagai ganti logo

`omarchy ascii` melukis teks dalam Delta Corps Priest 1, fon FIGlet yang digunakan untuk melukis tanda kata Omarchy itu sendiri, jadi pelindung skrin boleh mengatakan sesuatu dan bukannya menunjukkan gambar:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Ia mengambil teks sebagai argumen, atau membacanya daripada paip apabila tiada yang diberikan. Fon itu hanya membawa huruf dan ruang — ia dilukis tanpa digit atau tanda baca — jadi apa-apa selain itu digugurkan dan dinamakan pada stderr dan bukannya ditelan secara senyap.
