# Penjenamaan

Omarchy membolehkan anda menetapkan logo syarikat atau imej peribadi anda untuk kedua-dua penyelamat skrin dan skrin perihal.

### Penyelamat skrin

Anda boleh menukar logo yang digunakan untuk penyelamat skrin di bawah _Penampilan > Penjenamaan > Penyelamat Skrin_. Ia ialah logo ASCII, jadi anda boleh mengedit teks secara langsung, tetapi anda juga boleh memberikannya imej png atau svg, dan kami akan menukarnya kepada ASCII. Ia kelihatan agak hebat.

 ![branding-screensaver](images/branding-screensaver.webp)

Terdapat tiga entri dalam menu tersebut:

- **Edit Teks** membuka `~/.config/omarchy/branding/screensaver.txt` dalam editor anda. Taip atau tampal apa sahaja yang anda suka — seni ASCII, nama anda, kata kesat. Simpan dan keluar, dan penyelamat skrin akan dimulakan serta-merta supaya anda dapat melihatnya.
- **Tetapkan Dari Imej** membuka pemilih fail untuk png atau svg, menukarnya kepada ASCII, dan menunjukkan hasilnya kepada anda. Logo dengan siluet yang jelas berfungsi jauh lebih baik daripada foto.
- **Pulihkan Lalai** mengembalikan logo Omarchy.

### Skrin perihal

Tiga pilihan yang sama terdapat di bawah _Penampilan > Penjenamaan > Perihal_ untuk skrin _Perihal_ yang anda peroleh daripada menu Omarchy, dan ia berfungsi secara identik — failnya ialah `~/.config/omarchy/branding/about.txt`, dan tetingkap Perihal muncul selepas setiap perubahan. Seni Perihal ditukar kepada saiz yang lebih kecil daripada penyelamat skrin, kerana ia perlu muat dalam tetingkap dan bukannya memenuhi paparan anda.

Semasa tetingkap dibuka, jalur cahaya putih terang melintang merentasi seni tersebut setiap beberapa saat dan kemudian membiarkannya diam semula. Seni anda sendiri juga mendapatnya, selagi setiap aksara di dalamnya selebar satu lajur — apa sahaja yang dihasilkan oleh _Tetapkan Dari Imej_ memang begitu. Seni yang dibina daripada emoji atau aksara lebar berganda kekal diam sebaliknya, begitu juga skrin jika anda mengekalkan konfigurasi fastfetch anda sendiri: logo yang diam dalam kes tersebut ialah animasi yang memberi laluan dan bukannya gagal, kerana menggelongsorkan kilauan merentasinya akan meletakkan baki baris di tempat yang salah.

 ![branding-about](images/branding-about.webp)

### Menukar imej sendiri

Kedua-dua pilihan _Tetapkan Dari Imej_ hanya memanggil `omarchy transcode ascii`, yang boleh anda jalankan secara langsung jika anda mahukan kawalan ke atas penukaran tersebut:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Ia mengambil `--width` dan `--height` dalam lajur dan baris terminal, `--mode` sama ada `braille` (lalai, dan jauh lebih halus) atau `block`, peratusan `--threshold` untuk memutuskan piksel mana yang dikira sebagai sebahagian daripada logo, dan `--invert` untuk apabila logo anda cerah pada latar belakang yang gelap. Jika penukaran menghasilkan gumpalan, threshold biasanya tombol yang perlu dipusingkan.

### Perkataan sebagai ganti logo

`omarchy ascii` melukis teks dalam Delta Corps Priest 1, fon FIGlet yang digunakan untuk melukis tanda kata Omarchy itu sendiri, jadi penyelamat skrin boleh menyampaikan sesuatu dan bukannya menunjukkan gambar:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Ia mengambil teks sebagai argumen, atau membacanya daripada paip apabila tiada yang diberikan. Fon itu hanya mengandungi huruf dan ruang — ia dilukis tanpa digit atau tanda baca — jadi apa-apa yang lain akan digugurkan dan dinamakan pada stderr dan bukannya ditelan secara senyap.
