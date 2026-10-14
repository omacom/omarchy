# Branding

Omarchy memungkinkanmu mengatur logo perusahaan atau gambar pribadimu untuk buka kunci boot, screensaver, dan layar tentang.

### Buka kunci boot

Kamu bisa menggunakan `omarchy plymouth preview` untuk melihat seperti apa tampilan logo dan warna kustommu. Ia membutuhkan warna latar belakang, warna teks, logo png, dan jalur untuk gambar pratinjau:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Lalu terapkan pengaturannya dengan `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, yang juga akan memberi layar login SDDM warna dan logo yang sama. Jika kamu ingin kembali, kamu bisa menggunakan `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Screensaver

Kamu bisa mengubah logo yang digunakan untuk screensaver di _Gaya > Screensaver_. Itu adalah logo ASCII, jadi kamu bisa mengedit teksnya secara langsung, tetapi kamu juga bisa memberinya gambar png atau svg, dan kami akan mengonversinya menjadi ASCII. Tampilannya cukup keren.

 ![branding-screensaver](images/branding-screensaver.webp)

Ada tiga entri di menu itu:

- **Edit Teks** membuka `~/.config/omarchy/branding/screensaver.txt` di editormu. Ketik atau tempel apa pun yang kamu suka — seni ASCII, namamu, kata kasar. Simpan dan keluar, dan screensaver langsung menyala agar kamu bisa melihatnya.
- **Setel dari Gambar** membuka pemilih berkas untuk png atau svg, mengonversinya menjadi ASCII, dan menunjukkan hasilnya kepadamu. Logo dengan siluet yang jelas bekerja jauh lebih baik daripada foto.
- **Pulihkan Bawaan** mengembalikan logo Omarchy.

### Layar tentang

Tiga opsi yang sama ada di _Gaya > Tentang_ untuk layar _Tentang_ yang kamu dapatkan dari menu Omarchy, dan cara kerjanya identik — berkasnya adalah `~/.config/omarchy/branding/about.txt`, dan jendela Tentang muncul setelah setiap perubahan. Seni Tentang dikonversi ke ukuran yang lebih kecil daripada screensaver, karena ia harus muat di jendela alih-alih memenuhi layarmu.

Saat jendela terbuka, kilau hijau melintasi seni tersebut setiap beberapa detik lalu membiarkannya diam lagi. Senimu sendiri juga mendapatkannya, selama setiap karakter di dalamnya selebar satu kolom — apa pun yang dihasilkan _Setel dari Gambar_ memang begitu. Seni yang dibangun dari emoji atau karakter lebar ganda tetap diam, begitu pula layarnya jika kamu menyimpan konfigurasi fastfetch milikmu sendiri: logo yang diam dalam kasus-kasus itu adalah animasi yang menyingkir alih-alih gagal, karena menggeser kilau melintasinya akan membuat sisa baris berada di tempat yang salah.

 ![branding-about](images/branding-about.webp)

### Mengonversi gambar sendiri

Kedua opsi _Setel dari Gambar_ hanya memanggil `omarchy transcode ascii`, yang bisa kamu jalankan langsung jika kamu ingin kendali atas konversinya:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Ia menerima `--width` dan `--height` dalam kolom dan baris terminal, `--mode` berupa `braille` (bawaan, dan jauh lebih halus) atau `block`, persentase `--threshold` untuk memutuskan piksel mana yang dihitung sebagai bagian dari logo, dan `--invert` untuk saat logomu terang di atas latar belakang gelap. Jika konversi menghasilkan gumpalan, ambang batas biasanya adalah kenop yang harus diputar.

### Kata-kata alih-alih logo

`omarchy ascii` menggambar teks dalam Delta Corps Priest 1, font FIGlet yang digunakan untuk menggambar wordmark Omarchy itu sendiri, jadi screensaver bisa mengatakan sesuatu alih-alih menunjukkan gambar:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Ia menerima teks sebagai argumen, atau membacanya dari pipe saat tidak diberi apa pun. Font tersebut hanya memuat huruf dan spasi — ia digambar tanpa angka atau tanda baca — jadi apa pun selain itu dibuang dan disebutkan di stderr alih-alih ditelan secara diam-diam.
