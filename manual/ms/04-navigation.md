# Navigasi

Segala-galanya dalam Omarchy berlaku melalui papan kekunci — _SEGALANYA!_ Apabila sistem mula-mula dimulakan, anda benar-benar tidak boleh buat apa-apa dengan tetikus sahaja. Tetapi anda boleh tekan `Super + Space` untuk memaparkan Menu Omarchy dan dari sini anda boleh buat hampir segala-galanya.

Tetapi menu Omarchy pun tidak dimaksudkan sebagai cara utama untuk mengendalikan sistem pada kebanyakan masa. Kita boleh buat lebih pantas daripada itu! Semua aplikasi paling penting diikat terus kepada kekunci pintas individu. Anda mulakan terminal dengan `Super + Return` dan pelayar dengan `Super + Shift + Return`. Cuba buat satu demi satu, dan anda akan lihat keajaiban jubin Hyprland beraksi:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Anda kemudian boleh tekan `Super + J` untuk menyusunnya bertindih antara satu sama lain dan bukannya bersebelahan:

 ![navigation-stacked](images/navigation-stacked.webp)

Tekan `Super + J` sekali lagi untuk mengembalikannya ke kedudukan bersebelahan. Kemudian cuba `Super + Shift + Arrow Right` semasa dalam pelayar untuk menukar tetingkap.

Sekarang cuba `Super + Shift + T` untuk memulakan monitor Activity. Itu akan muncul sebagai tetingkap terapung, dengan bar tajuk untuk menyeretnya dan butang untuk meminimumkan, memaksimumkan, dan menutupnya. Setiap tetingkap terapung mendapat satu, di mana-mana sahaja ia berada. Anda boleh menjubinkannya menggunakan `Super + T` (dan tekan itu sekali lagi untuk menjadikannya terapung semula). Sekarang tekan `Super + Shift + F` untuk membuka pengurus fail. Anda akan mempunyai susunan empat hala yang kemas:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Anda menavigasi antara tetingkap yang anda mahu aktifkan dengan `Super + Arrow`. Ini akan menukar fokus dan menggerakkan kursor ke tengah aplikasi baharu. Di tepi skrin, ia diteruskan ke monitor di sebelah itu.

Jika anda tekan `Super + Shift + 2`, anda akan mengalihkan aplikasi berfokus semasa ke ruang kerja kedua. `Super + Shift + 1` mengalihkannya kembali. (Dan `Super + Shift + Alt + 2` akan mengalihkan aplikasi berfokus semasa ke ruang kerja kedua tanpa beralih kepadanya).

Dengan lebih daripada satu monitor, setiap monitor mempunyai ruang kerja 1 hingga 10 tersendiri. `Super + 2` pergi ke ruang kerja kedua monitor yang anda gunakan, dan bar atas setiap monitor menunjukkan ruang kerjanya sendiri dan ruang kerja yang sedang dipaparkannya. `Super + Tab` berkitar melalui ruang kerja pada monitor yang anda gunakan. `Super + Shift + Ctrl + Arrows` mengalihkan tetingkap yang anda gunakan ke monitor dalam arah itu, ke ruang kerja yang sedang dipaparkannya, dan `Super + Shift + Alt + Arrows` mengalihkan ruang kerja yang anda gunakan ke monitor dalam arah itu, di mana ia mengambil nombor yang sama jika kosong. Sesebuah monitor mengekalkan ruang kerjanya apabila anda mencabutnya: ruang kerja itu menyertai skrin lain, dinomborkan selepas ruang kerja yang sudah ada padanya, dan kembali dengan nombor lamanya apabila monitor itu kembali.

Jika anda tahan `Super` dan gunakan tetikus untuk mengklik pada tetingkap, anda akan dapat menyusun semula kedudukannya. Jika anda tahan `Super` dan gunakan butang kanan pada tetikus, anda boleh mengubah saiz tetingkap dengan bebas.

Anda menutup tetingkap dengan `Super + W` atau `Super + Q` (dan menutup semua tetingkap dengan `Ctrl + Alt + Delete`).

Anda juga boleh pergi ke skrin penuh dengan `Super + F` atau hanya lebar penuh (mengekalkan bar atas) dengan `Super + Alt + F` atau skrin penuh dalam tetingkap dengan `Super + Ctrl + F` (bagus untuk YouTube!).

### Susun atur dwindle lwn scrolling

Susun atur lalai Omarchy dipanggil dwindle. Ia mengekalkan semua tetingkap yang anda buka pada satu ruang kerja kelihatan pada setiap masa, walaupun ia terpaksa mengecilkannya.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Tetapi anda juga boleh memilih untuk menukar ruang kerja kepada susun atur scrolling di mana tetingkap disusun bersebelahan, melangkaui tepi paparan yang kelihatan. Anda menukar satu ruang kerja kepada susun atur ini melalui `Super + L`.

Menekan `Super + L` sekali lagi menukar ruang kerja kepada terapung, di mana tetingkap bertindih dengan bebas dan anda meletakkannya sendiri, dan tekanan ketiga mengembalikannya kepada dwindle. `Super + Alt + L` melaluinya dalam arah sebaliknya. Tetingkap yang memang terapung — tetingkap yang anda keluarkan dengan `Super + T`, atau aplikasi yang sentiasa dibuka secara terapung — kekal terapung apabila ruang kerja kembali kepada jubin. Bar atas menandakan ruang kerja yang anda gunakan dengan susun aturnya: segi empat sama untuk dwindle, bulatan untuk scrolling, dan segi tiga untuk terapung. Mengklik tanda itu juga berkitar melalui susun atur, begitu juga kekunci paparan pada komputer riba yang mempunyainya.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pilihan adalah mengikut ruang kerja, dan ia kekal. Jadi anda boleh mengekalkan ruang kerja 1 pada dwindle untuk pelayaran dan ruang kerja 2 pada scrolling untuk kod, dan kedua-duanya akan kembali seperti itu selepas dimulakan semula.

Jika anda ingin menggunakan susun atur scrolling sebagai lalai, anda boleh menetapkannya dalam `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Ruang kerja terapung

Ruang kerja terapung berfungsi seperti desktop tradisional: tetingkap bertindih, dan anda mengalih dan mengubah saiznya sendiri. Setiap tetingkap mendapat bar tajuk dalam warna tema anda, dengan butang untuk meminimumkan, memaksimumkan, dan menutup. `Super + M` turut meminimumkan tetingkap berfokus. Tetingkap yang diminimumkan menunggu dalam dok; klik aplikasinya untuk membawanya kembali. Klik tetingkap untuk membawanya ke hadapan. Ubah saiznya dari mana-mana tepi atau sudut. Klik dua kali bar tajuk untuk memaksimumkan tetingkap sambil mengekalkan bar atas kelihatan, dan sekali lagi untuk mendapatkan saiz lamanya kembali. Chrome dan pelayar berasaskan Chromium lain, Disks dan Document Viewer melangkau bar tajuk dan sebaliknya menggunakan pengepala mereka sendiri; `Super + Alt + F` memaksimumkannya, dan `Super + M` meminimumkannya.

Setiap ruang kerja mempunyai dok, dengan aplikasi anda yang disemat, semua yang sedang berjalan, dan grid setiap aplikasi di sebalik butang aplikasi, yang turut dibuka oleh `Super + Alt + Space` dan _Apps_ dalam menu Omarchy. Klik kanan aplikasi pada grid, atau tekan `Delete`, untuk menyahpasangnya. Klik aplikasi untuk membukanya, atau untuk membawa tetingkapnya ke hadapan; klik sekali lagi untuk berkitar melalui tetingkapnya. Files hanya membawa kembali tetingkap daripada ruang kerja yang anda gunakan dan sebaliknya membuka tetingkap baharu, dan Terminal dan Agent sentiasa memulakan yang lain, walaupun tetingkap yang diminimumkan akan kembali terlebih dahulu. Klik tengah membuka tetingkap baharu. Seret ikon sepanjang dok untuk mengalihkannya; menyeret aplikasi yang sedang berjalan masuk antara aplikasi lain akan mengekalkannya di situ. Klik kanan untuk mengekalkan aplikasi dalam dok, mengeluarkannya, atau menutupnya. Dok kekal kelihatan semasa ruang kerja kosong, dan sebaik sahaja ruang kerja mempunyai tetingkap, ia bersembunyi sehingga penuding mencapai tepinya. Tetingkap skrin penuh menyembunyikannya sepenuhnya. Seret butang aplikasi ke arah tepi skrin yang lain untuk mengalihkan dok ke situ. Klik kanan padanya untuk _Position_, untuk memilih tepi, dan _Layout_, untuk menetapkan susun atur lalai seperti yang dilakukan oleh _Appearance > Workspace Layout_. Kedudukan itu juga berada di bawah _Appearance > Dock > Dock Position_, dan `omarchy dock position left` menetapkannya dari terminal. Aplikasi yang anda kekalkan dalam dok menjadi pudar semasa ia tidak berjalan. Untuk mengekalkan dok hanya pada ruang kerja terapung, gunakan _Appearance > Dock > Dock Only on Floating_ atau `omarchy dock tiling off`.

Ruang kerja baharu, dan mana-mana ruang kerja yang belum anda berikan susun atur tersendiri dengan `Super + L`, menggunakan susun atur lalai. Menukar lalai menetapkan semula setiap ruang kerja tanpa tetingkap kepadanya, manakala ruang kerja yang mempunyai tetingkap mengekalkan susun atur yang dimilikinya. Tetingkap yang diminimumkan ke dok masih dikira sebagai tetingkap pada ruang kerja yang ditinggalkannya. Pilihnya di bawah _Appearance > Workspace Layout_: Tiling, Scrolling, atau Floating. `omarchy hyprland workspace layout default scrolling` menetapkannya dari terminal.

### Mengumpulkan tetingkap

Tetingkap boleh dikumpulkan menggunakan `Super + G`. Sebaik sahaja anda berada dalam kumpulan, setiap tetingkap yang anda mulakan semasa kumpulan itu aktif akan menjadi sebahagian daripada kumpulan itu. Anda boleh bergerak antara tetingkap terkumpul ini menggunakan `Super + Ctrl + Arrow Left/Right` atau `Super + Alt + 1/2/3/4` untuk pergi terus kepada tetingkap terkumpul mengikut turutan.

Anda boleh mengalihkan tetingkap keluar daripada kumpulan dengan `Super + Alt + G` atau membubarkan keseluruhan kumpulan dengan menekan `Super + G` sekali lagi. Akhir sekali, anda boleh mengalihkan tetingkap di luar kumpulan masuk ke dalamnya dengan `Super + Alt + Arrows`.

### Mengeluarkan tetingkap

Anda boleh mengeluarkan tetingkap daripada peruntukan ruang kerjanya dengan `Super + O`. Itu akan menyematkannya sebagai tetingkap terapung yang mengikuti anda pada mana-mana ruang kerja yang anda pergi. Bagus untuk pemain video dan seumpamanya.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Ruang kerja scratchpad

Terdapat ruang kerja scratchpad bersaiz penuh khas yang menindih mana-mana ruang kerja yang sedang anda gunakan. Anda mengakses apa yang ada padanya menggunakan `Super + S`, dan anda meletakkan tetingkap di situ menggunakan `Super + Alt + S`.

Ia berfungsi dengan baik untuk kawalan atau terminal yang anda mahu gunakan dengan cepat tanpa meninggalkan ruang kerja semasa.

### Konsol Quake

Akhir sekali, terdapat konsol Quake setengah ketinggian yang jatuh ke bawah menindih mana-mana ruang kerja yang sedang anda gunakan. Togolnya dengan `Super + the key above Tab` (grave pada susun atur US), dan letakkan tetingkap di situ menggunakan `Super + Shift + the key above Tab`.

Kali pertama ia dibuka, ia memulakan ejen lalai anda, atau meminta anda memilih satu jika anda belum memilihnya lagi. Semasa konsol hanya memegang satu tetingkap, ia jatuh ke bawah sebagai panel berpusat dan bukannya merentangi skrin. Letakkan aplikasi kedua padanya dan ia kembali kepada lebar penuh, supaya kedua-duanya mempunyai ruang untuk duduk bersebelahan.

Untuk mengalihkan tetingkap keluar daripada scratchpad atau konsol, hantarkannya terus ke ruang kerja lain dengan sesuatu seperti `Super + Shift + 1`.

### Memang ambil masa untuk membiasakan diri!

Memang ambil sedikit masa untuk membiasakan diri menavigasi desktop anda seperti ini, tetapi sebaik sahaja anda biasa, sukar untuk kembali kepada pengalaman desktop tradisional yang dipacu tetikus!
