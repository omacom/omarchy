# Penjenamaan

Omarchy membolehkan anda menetapkan logo syarikat atau imej peribadi anda untuk buka kunci but, tabir skrin, dan skrin perihal.

### Buka kunci but

Anda boleh menggunakan `omarchy plymouth preview` untuk melihat rupa logo dan warna tersuai anda. Ia menerima warna latar belakang, warna teks, png logo, dan laluan untuk imej pratonton:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Kemudian gunakan persediaan itu dengan `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, yang juga akan memberikan skrin log masuk SDDM warna dan logo yang sama. Jika anda mahu membalikkan, anda boleh menggunakan `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Tabir Skrin

Anda boleh menukar logo yang digunakan untuk tabir skrin di bawah _Gaya > Tabir Skrin_. Ia ialah logo ASCII, jadi anda boleh menyunting teks secara langsung, tetapi anda juga boleh memberikannya imej png atau svg, dan kami akan menukarkannya kepada ASCII. Ia kelihatan agak menarik.

 ![branding-screensaver](images/branding-screensaver.webp)

Terdapat tiga entri dalam menu itu:

- **Sunting Teks** membuka `~/.config/omarchy/branding/screensaver.txt` dalam penyunting anda. Taip atau tampal apa sahaja yang anda suka — seni ASCII, nama anda, perkataan kasar. Simpan dan keluar, dan tabir skrin akan menyala serta-merta supaya anda boleh melihatnya.
- **Tetapkan dari Imej** membuka pemilih fail untuk png atau svg, menukarkannya kepada ASCII, dan menunjukkan hasilnya kepada anda. Logo dengan siluet yang jelas berfungsi jauh lebih baik daripada foto.
- **Pulihkan Lalai** meletakkan semula logo Omarchy.

### Skrin Perihal

Tiga pilihan yang sama berada di bawah _Gaya > Perihal_ untuk skrin _Perihal_ yang anda dapat dari menu Omarchy, dan ia berfungsi secara identik — failnya ialah `~/.config/omarchy/branding/about.txt`, dan tetingkap Perihal muncul selepas setiap perubahan. Seni Perihal ditukar kepada saiz yang lebih kecil berbanding tabir skrin, kerana ia perlu muat dalam tetingkap dan bukannya memenuhi paparan anda.

Semasa tetingkap terbuka, kilauan hijau melintasi seni itu setiap beberapa saat dan kemudian membiarkannya pegun semula. Seni anda sendiri juga mendapatnya, asalkan setiap aksara di dalamnya selebar satu lajur — apa sahaja yang dihasilkan oleh _Tetapkan dari Imej_ memang begitu. Seni yang dibina daripada emoji atau aksara lebar berganda kekal pegun, dan begitu juga skrin jika anda mengekalkan konfigurasi fastfetch anda sendiri: logo pegun dalam kes-kes itu ialah animasi yang menjauhkan diri dan bukannya gagal, kerana meluncurkan kilauan melintasinya akan meletakkan baki baris di tempat yang salah.

 ![branding-about](images/branding-about.webp)

### Menukar imej sendiri

Kedua-dua pilihan _Tetapkan dari Imej_ hanya memanggil `omarchy transcode ascii`, yang boleh anda jalankan secara langsung jika anda mahukan kawalan ke atas penukaran:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Ia menerima `--width` dan `--height` dalam lajur dan baris terminal, `--mode` sama ada `braille` (lalai, dan jauh lebih halus) atau `block`, peratusan `--threshold` untuk memutuskan piksel mana yang dikira sebagai sebahagian daripada logo, dan `--invert` untuk apabila logo anda terang pada latar belakang gelap. Jika penukaran menghasilkan tompok, ambang biasanya tombol yang perlu dipusingkan.

### Perkataan dan bukannya logo

`omarchy ascii` melukis teks dalam Delta Corps Priest 1, fon FIGlet yang digunakan untuk melukis wordmark Omarchy itu sendiri, jadi tabir skrin boleh mengatakan sesuatu dan bukannya menunjukkan gambar:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Ia menerima teks sebagai argumen, atau membacanya dari paip apabila tiada yang diberikan. Fon itu hanya membawa huruf dan ruang — ia dilukis tanpa digit atau tanda baca — jadi apa sahaja selain itu digugurkan dan dinamakan pada stderr dan bukannya ditelan secara senyap.
