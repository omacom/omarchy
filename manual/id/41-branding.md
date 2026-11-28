# Branding

Omarchy memungkinkan Anda mengatur logo perusahaan atau gambar pribadi Anda untuk buka kunci boot, screensaver, dan layar tentang.

### Buka kunci boot

Anda bisa menggunakan `omarchy plymouth preview` untuk melihat tampilan logo dan warna kustom Anda. Perintah ini menerima warna latar belakang, warna teks, sebuah png logo, dan sebuah path untuk gambar pratinjau:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Lalu terapkan pengaturannya dengan `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, yang juga akan memberikan warna dan logo yang sama kepada layar login SDDM. Jika Anda ingin mengembalikannya, Anda bisa menggunakan `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Screensaver

Anda bisa mengganti logo yang digunakan untuk screensaver di _Tampilan > Branding > Screensaver_. Logonya berupa logo ASCII, jadi Anda bisa mengedit teksnya langsung, tetapi Anda juga bisa memberinya gambar png atau svg, dan kami akan mengubahnya menjadi ASCII. Hasilnya cukup keren.

 ![branding-screensaver](images/branding-screensaver.webp)

Ada tiga entri di menu itu:

- **Edit Teks** membuka `~/.config/omarchy/branding/screensaver.txt` di editor Anda. Ketik atau tempel apa pun yang Anda suka — seni ASCII, nama Anda, kata kasar. Simpan dan keluar, dan screensaver langsung menyala agar Anda bisa melihatnya.
- **Atur Dari Gambar** membuka pemilih file untuk png atau svg, mengubahnya menjadi ASCII, dan menunjukkan hasilnya kepada Anda. Logo dengan siluet yang jelas bekerja jauh lebih baik daripada foto.
- **Pulihkan Default** mengembalikan logo Omarchy.

### Layar tentang

Tiga opsi yang sama ada di _Tampilan > Branding > Tentang_ untuk layar _Tentang_ yang Anda dapatkan dari menu Omarchy, dan cara kerjanya identik — filenya adalah `~/.config/omarchy/branding/about.txt`, dan jendela Tentang muncul setelah setiap perubahan. Seni Tentang diubah ke ukuran yang lebih kecil daripada screensaver, karena harus muat di dalam jendela alih-alih memenuhi layar Anda.

Selama jendela terbuka, seberkas cahaya putih terang melintas miring melewati seni itu setiap beberapa detik lalu membiarkannya diam lagi. Seni Anda sendiri juga mendapatkannya, selama setiap karakter di dalamnya lebarnya satu kolom — semua yang dihasilkan _Atur Dari Gambar_ memang begitu. Seni yang dibangun dari emoji atau karakter lebar ganda tetap diam, dan begitu juga layarnya jika Anda mempertahankan config fastfetch Anda sendiri: logo yang diam dalam kasus-kasus itu adalah animasinya yang menyingkir agar tidak mengganggu alih-alih gagal, karena menggeser kilauan melewatinya akan membuat sisa barisnya mendarat di tempat yang salah.

 ![branding-about](images/branding-about.webp)

### Mengonversi gambar sendiri

Kedua opsi _Atur Dari Gambar_ itu sebenarnya hanya memanggil `omarchy transcode ascii`, yang bisa Anda jalankan langsung jika Anda ingin mengontrol konversinya:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Perintah ini menerima `--width` dan `--height` dalam kolom dan baris terminal, `--mode` berupa `braille` (default, dan jauh lebih halus) atau `block`, persentase `--threshold` untuk menentukan piksel mana yang dihitung sebagai bagian dari logo, dan `--invert` untuk saat logo Anda terang di atas latar belakang gelap. Jika hasil konversi keluar sebagai gumpalan, threshold biasanya adalah kenop yang perlu diputar.

### Kata-kata sebagai pengganti logo

`omarchy ascii` menggambar teks dalam Delta Corps Priest 1, font FIGlet yang dipakai untuk menggambar wordmark Omarchy itu sendiri, jadi screensaver bisa mengatakan sesuatu alih-alih menampilkan gambar:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Perintah ini menerima teks sebagai argumen, atau membacanya dari pipe bila tidak diberikan argumen. Font itu hanya memuat huruf dan spasi — font itu digambar tanpa angka atau tanda baca — jadi apa pun selain itu dibuang dan disebutkan namanya di stderr alih-alih ditelan diam-diam.
