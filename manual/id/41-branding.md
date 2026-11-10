# Branding

Omarchy memungkinkan Anda mengatur logo perusahaan atau gambar pribadi Anda untuk buka kunci boot, screensaver, dan layar tentang.

### Buka kunci boot

Anda dapat menggunakan `omarchy plymouth preview` untuk melihat seperti apa tampilan logo dan warna kustom Anda. Perintah ini membutuhkan warna latar belakang, warna teks, png logo, dan path untuk gambar pratinjau:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Lalu terapkan pengaturannya dengan `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, yang juga akan memberikan warna dan logo yang sama ke layar login SDDM. Jika Anda ingin mengembalikannya, Anda dapat menggunakan `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Screensaver

Anda dapat mengubah logo yang digunakan untuk screensaver di bawah _Tampilan > Branding > Screensaver_. Ini adalah logo ASCII, jadi Anda dapat mengedit teksnya secara langsung, tetapi Anda juga dapat memberikannya gambar png atau svg, dan kami akan mengonversinya menjadi ASCII. Hasilnya terlihat cukup keren.

 ![branding-screensaver](images/branding-screensaver.webp)

Ada tiga entri di menu itu:

- **Edit Teks** membuka `~/.config/omarchy/branding/screensaver.txt` di editor Anda. Ketik atau tempel apa pun yang Anda suka — seni ASCII, nama Anda, kata kasar. Simpan dan keluar, dan screensaver langsung menyala agar Anda dapat melihatnya.
- **Atur Dari Gambar** membuka pemilih file untuk png atau svg, mengonversinya menjadi ASCII, dan menunjukkan hasilnya kepada Anda. Logo dengan siluet yang jelas bekerja jauh lebih baik daripada foto.
- **Pulihkan Default** mengembalikan logo Omarchy.

### Layar tentang

Tiga opsi yang sama ada di bawah _Tampilan > Branding > Tentang_ untuk layar _Tentang_ yang Anda dapatkan dari menu Omarchy, dan cara kerjanya identik — filenya adalah `~/.config/omarchy/branding/about.txt`, dan jendela Tentang muncul setelah setiap perubahan. Seni Tentang dikonversi ke ukuran yang lebih kecil daripada milik screensaver, karena harus muat di dalam jendela alih-alih memenuhi layar Anda.

Selama jendela terbuka, kilau hijau melintas miring melintasi seni itu setiap beberapa detik, lalu membiarkannya diam kembali. Seni Anda sendiri juga mendapatkannya, selama setiap karakter di dalamnya selebar satu kolom — semua yang dihasilkan _Atur Dari Gambar_ memang begitu. Seni yang dibuat dari emoji atau karakter lebar ganda sebaliknya tetap diam, dan begitu juga layarnya jika Anda mempertahankan konfigurasi fastfetch milik Anda sendiri: logo yang diam dalam kasus-kasus itu adalah animasi yang menyingkir agar tidak menghalangi, bukan kegagalan, karena menggeser kilau melintasinya akan membuat sisa baris berakhir di tempat yang salah.

 ![branding-about](images/branding-about.webp)

### Mengonversi gambar sendiri

Kedua opsi _Atur Dari Gambar_ itu sebenarnya hanya memanggil `omarchy transcode ascii`, yang dapat Anda jalankan secara langsung jika Anda ingin mengontrol konversinya:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Perintah ini membutuhkan `--width` dan `--height` dalam kolom dan baris terminal, `--mode` berupa `braille` (default, dan jauh lebih halus) atau `block`, persentase `--threshold` untuk menentukan piksel mana yang dihitung sebagai bagian logo, dan `--invert` untuk saat logo Anda terang di atas latar belakang gelap. Jika hasil konversi menjadi gumpalan, threshold biasanya adalah kenop yang perlu diputar.

### Kata-kata alih-alih logo

`omarchy ascii` menggambar teks dalam Delta Corps Priest 1, font FIGlet yang juga digunakan untuk menggambar wordmark Omarchy itu sendiri, jadi screensaver dapat mengatakan sesuatu alih-alih menampilkan gambar:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Perintah ini mengambil teks sebagai argumen, atau membacanya dari pipe saat tidak diberikan argumen apa pun. Font ini hanya memuat huruf dan spasi — font ini digambar tanpa angka atau tanda baca — jadi apa pun selain itu akan dibuang dan disebutkan namanya di stderr alih-alih ditelan diam-diam.
