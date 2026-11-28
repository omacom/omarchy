# Branding

Omarchy memungkinkan Anda menetapkan logo perusahaan atau gambar pribadi Anda untuk screensaver maupun layar about.

### Screensaver

Anda dapat mengubah logo yang digunakan untuk screensaver di _Appearance > Branding > Screensaver_. Ini adalah logo ASCII, jadi Anda dapat mengedit teksnya secara langsung, tetapi Anda juga dapat memberinya gambar png atau svg, dan kami akan mengonversinya menjadi ASCII. Hasilnya terlihat cukup keren.

 ![branding-screensaver](images/branding-screensaver.webp)

Ada tiga entri di menu tersebut:

- **Edit Text** membuka `~/.config/omarchy/branding/screensaver.txt` di editor Anda. Ketik atau tempel apa pun yang Anda suka — seni ASCII, nama Anda, kata kasar. Simpan dan keluar, dan screensaver akan langsung menyala agar Anda dapat melihatnya.
- **Set From Image** membuka pemilih file untuk png atau svg, mengonversinya menjadi ASCII, dan menunjukkan hasilnya kepada Anda. Logo dengan siluet yang jelas bekerja jauh lebih baik daripada foto.
- **Restore Default** mengembalikan logo Omarchy.

### Layar About

Tiga opsi yang sama ada di _Appearance > Branding > About_ untuk layar _About_ yang Anda dapatkan dari menu Omarchy, dan cara kerjanya identik — filenya adalah `~/.config/omarchy/branding/about.txt`, dan jendela About akan muncul setelah setiap perubahan. Gambar About dikonversi ke ukuran yang lebih kecil daripada gambar screensaver, karena gambar tersebut harus muat di dalam jendela, bukan memenuhi layar Anda.

Saat jendela terbuka, seberkas cahaya putih terang melintas miring melintasi gambar setiap beberapa detik lalu membiarkannya diam kembali. Gambar Anda sendiri juga mendapatkannya, selama setiap karakter di dalamnya selebar satu kolom — semua yang dihasilkan _Set From Image_ memang begitu. Gambar yang dibuat dari emoji atau karakter lebar ganda tetap diam, begitu juga layarnya jika Anda mempertahankan config fastfetch Anda sendiri: logo yang diam dalam kasus-kasus tersebut adalah animasinya yang menyingkir, bukan gagal, karena menggeser kilauan melintasinya akan membuat sisa baris berada di tempat yang salah.

 ![branding-about](images/branding-about.webp)

### Mengonversi gambar sendiri

Kedua opsi _Set From Image_ tersebut hanyalah memanggil `omarchy transcode ascii`, yang dapat Anda jalankan secara langsung jika Anda ingin mengontrol konversinya:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Perintah ini menerima `--width` dan `--height` dalam kolom dan baris terminal, `--mode` berupa `braille` (default, dan jauh lebih halus) atau `block`, `--threshold` berupa persentase untuk menentukan piksel mana yang dihitung sebagai bagian dari logo, dan `--invert` untuk saat logo Anda terang dengan latar belakang gelap. Jika hasil konversi menjadi gumpalan, threshold biasanya adalah kenop yang perlu diputar.

### Kata-kata sebagai pengganti logo

`omarchy ascii` menggambar teks dalam Delta Corps Priest 1, font FIGlet yang digunakan untuk menggambar wordmark Omarchy itu sendiri, jadi screensaver dapat mengatakan sesuatu, bukan menampilkan gambar:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Perintah ini menerima teks sebagai argumen, atau membacanya dari pipe jika tidak diberikan argumen. Font ini hanya memuat huruf dan spasi — font ini digambar tanpa angka atau tanda baca — jadi apa pun selain itu akan dibuang dan disebutkan di stderr, bukan ditelan diam-diam.
