# Penjenamaan

Omarchy membolehkan anda menetapkan logo syarikat atau imej peribadi anda untuk buka kunci but, penyelamat skrin, dan skrin perihal.

### Buka kunci but

Anda boleh menggunakan `omarchy plymouth preview` untuk melihat rupa logo dan warna tersuai anda. Ia mengambil warna latar belakang, warna teks, png logo, dan laluan untuk imej pratonton:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Kemudian terapkan persediaan itu dengan `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, yang juga akan memberikan skrin log masuk SDDM warna dan logo yang sama. Jika anda mahu membalikkannya, anda boleh menggunakan `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Penyelamat skrin

Anda boleh menukar logo yang digunakan untuk penyelamat skrin di bawah _Appearance > Branding > Screensaver_. Ia ialah logo ASCII, jadi anda boleh mengedit teks itu secara terus, tetapi anda juga boleh memberikannya imej png atau svg, dan kami akan menukarnya kepada ASCII. Ia kelihatan agak hebat.

 ![branding-screensaver](images/branding-screensaver.webp)

Terdapat tiga entri dalam menu itu:

- **Edit Text** membuka `~/.config/omarchy/branding/screensaver.txt` dalam editor anda. Taip atau tampal apa sahaja yang anda suka — seni ASCII, nama anda, perkataan kesat. Simpan dan keluar, dan penyelamat skrin akan terus hidup supaya anda boleh melihatnya.
- **Set From Image** membuka pemilih fail untuk png atau svg, menukarnya kepada ASCII, dan menunjukkan hasilnya kepada anda. Logo dengan siluet yang jelas berfungsi jauh lebih baik daripada foto.
- **Restore Default** meletakkan semula logo Omarchy.

### Skrin perihal

Tiga pilihan yang sama terdapat di bawah _Appearance > Branding > About_ untuk skrin _About_ yang anda dapat daripada menu Omarchy, dan ia berfungsi dengan cara yang sama — failnya ialah `~/.config/omarchy/branding/about.txt`, dan tetingkap About akan muncul selepas setiap perubahan. Seni About ditukar kepada saiz yang lebih kecil daripada seni penyelamat skrin, kerana ia perlu muat dalam tetingkap dan bukannya memenuhi paparan anda.

Semasa tetingkap itu terbuka, kilauan hijau melintasi seni itu setiap beberapa saat dan kemudian membiarkannya diam semula. Seni anda sendiri juga mendapatnya, selagi setiap aksara di dalamnya selebar satu lajur — apa sahaja yang dihasilkan oleh _Set From Image_ memang begitu. Seni yang dibina daripada emoji atau aksara lebar berganda sebaliknya kekal diam, dan begitu juga skrin jika anda mengekalkan konfigurasi fastfetch anda sendiri: logo yang diam dalam kes tersebut ialah animasi yang memberi laluan dan bukannya gagal, kerana menggelongsorkan kilauan melintasinya akan meletakkan baki baris di tempat yang salah.

 ![branding-about](images/branding-about.webp)

### Menukar imej sendiri

Kedua-dua pilihan _Set From Image_ hanya memanggil `omarchy transcode ascii`, yang boleh anda jalankan terus jika anda mahu mengawal penukaran itu:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Ia mengambil `--width` dan `--height` dalam lajur dan baris terminal, `--mode` sama ada `braille` (lalai, dan jauh lebih halus) atau `block`, peratusan `--threshold` untuk menentukan piksel mana yang dikira sebagai sebahagian daripada logo, dan `--invert` untuk apabila logo anda cerah pada latar belakang gelap. Jika hasil penukaran keluar sebagai tompok, threshold biasanya tombol yang perlu dipusing.

### Perkataan dan bukannya logo

`omarchy ascii` melukis teks dalam Delta Corps Priest 1, fon FIGlet yang digunakan untuk melukis tanda kata Omarchy itu sendiri, jadi penyelamat skrin boleh menyampaikan sesuatu dan bukannya menunjukkan gambar:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Ia mengambil teks sebagai argumen, atau membacanya daripada paip apabila tiada yang diberikan. Fon itu hanya membawa huruf dan ruang — ia dilukis tanpa digit atau tanda baca — jadi apa-apa selain itu akan digugurkan dan dinamakan pada stderr dan bukannya ditelan secara senyap.
