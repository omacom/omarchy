# Navigasi

Semua perkara dalam Omarchy berlaku melalui papan kekunci — _SEMUANYA!_ Apabila sistem mula-mula dimulakan, anda memang langsung tidak boleh buat apa-apa dengan tetikus sahaja. Tetapi anda boleh tekan `Super + Space` untuk memaparkan Menu Omarchy dan dari sini anda boleh buat hampir semua perkara.

Tetapi menu Omarchy pun sebenarnya bukan bertujuan untuk menjadi cara utama mengendalikan sistem pada kebanyakan masa. Kita boleh buat lebih pantas daripada itu! Semua aplikasi paling penting diikat terus kepada kekunci pintas individu. Anda mulakan terminal dengan `Super + Return` dan pelayar dengan `Super + Shift + Return`. Cuba buat satu demi satu, dan anda akan lihat keajaiban penyusunan jubin Hyprland beraksi:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Anda kemudian boleh tekan `Super + J` untuk menyusunnya bertindih antara satu sama lain dan bukannya bersebelahan:

 ![navigation-stacked](images/navigation-stacked.webp)

Tekan `Super + J` sekali lagi untuk mengembalikannya ke kedudukan bersebelahan. Kemudian cuba `Super + Shift + Arrow Right` semasa berada dalam pelayar untuk menukar tetingkap.

Sekarang cuba `Super + Shift + T` untuk memulakan monitor Activity. Itu akan muncul sebagai tetingkap terapung, dengan bar tajuk untuk menyeretnya dan butang untuk meminimumkan, memaksimumkan, dan menutupnya. Setiap tetingkap terapung akan mendapat satu, di mana-mana sahaja ia berada. Anda boleh menyusunnya secara jubin menggunakan `Super + T` (dan tekan itu sekali lagi untuk menjadikannya terapung semula). Sekarang tekan `Super + Shift + F` untuk membuka pengurus fail. Anda akan mempunyai susunan empat hala yang kemas:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Anda menavigasi antara tetingkap yang anda mahu aktifkan dengan `Super + Arrow`. Ini akan menukar fokus dan mengalihkan kursor ke tengah aplikasi baharu. Di tepi skrin, ia akan diteruskan ke monitor di sebelah itu.

Jika anda tekan `Super + Shift + 2`, anda akan mengalihkan aplikasi yang sedang difokuskan ke ruang kerja kedua. `Super + Shift + 1` mengalihkannya kembali. (Dan `Super + Shift + Alt + 2` akan mengalihkan aplikasi yang sedang difokuskan ke ruang kerja kedua tanpa beralih kepadanya).

Dengan lebih daripada satu monitor, setiap monitor mempunyai ruang kerja 1 hingga 10 tersendiri. `Super + 2` pergi ke ruang kerja kedua pada monitor yang anda berada, dan bar atas setiap monitor menunjukkan ruang kerjanya sendiri dan ruang kerja yang sedang dipaparkannya. `Super + Tab` berkitar melalui ruang kerja pada monitor yang anda berada. `Super + Shift + Ctrl + Arrows` mengalihkan tetingkap yang anda berada ke monitor dalam arah itu, ke ruang kerja yang sedang dipaparkannya, dan `Super + Shift + Alt + Arrows` mengalihkan ruang kerja yang anda berada ke monitor dalam arah itu, di mana ia mengambil nombor yang sama jika kosong. Monitor mengekalkan ruang kerjanya apabila anda mencabutnya: ruang kerja itu menyertai ruang kerja skrin lain, dinomborkan selepas ruang kerja yang sudah ada padanya, dan kembali dengan nombor lamanya apabila monitor itu kembali.

Jika anda menahan `Super` dan menggunakan tetikus untuk mengklik tetingkap, anda akan dapat menyusun semula kedudukannya. Jika anda menahan `Super` dan menggunakan butang kanan pada tetikus, anda boleh mengubah saiz tetingkap dengan bebas.

Anda menutup tetingkap dengan `Super + W` atau `Super + Q` (dan menutup semua tetingkap dengan `Ctrl + Alt + Delete`).

Anda juga boleh pergi ke skrin penuh dengan `Super + F` atau hanya lebar penuh (mengekalkan bar atas) dengan `Super + Alt + F` atau skrin penuh dalam tetingkap dengan `Super + Ctrl + F` (bagus untuk YouTube!).

### Susun atur dwindle lwn scrolling

Susun atur lalai Omarchy dipanggil dwindle. Ia mengekalkan semua tetingkap yang anda buka pada satu ruang kerja sentiasa kelihatan, walaupun ia terpaksa mengecilkannya.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Tetapi anda juga boleh memilih untuk menukar ruang kerja kepada susun atur scrolling di mana tetingkap disusun bersebelahan, melepasi tepi paparan yang kelihatan. Anda menukar satu ruang kerja kepada susun atur ini melalui `Super + L`.

Menekan `Super + L` sekali lagi menukar ruang kerja kepada terapung, di mana tetingkap bertindih dengan bebas dan anda meletakkannya sendiri, dan tekanan ketiga mengembalikannya kepada dwindle. `Super + Alt + L` melaluinya ke arah sebaliknya. Tetingkap yang memang terapung — tetingkap yang anda keluarkan dengan `Super + T`, atau aplikasi yang sentiasa dibuka secara terapung — kekal terapung apabila ruang kerja kembali kepada penyusunan jubin. Bar atas menandakan ruang kerja yang anda berada dengan susun aturnya: segi empat sama untuk dwindle, bulatan untuk scrolling, dan segi tiga untuk terapung. Mengklik tanda itu turut berkitar melalui susun atur, begitu juga kekunci paparan pada komputer riba yang mempunyainya.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pilihan ini adalah mengikut ruang kerja, dan ia kekal. Jadi anda boleh mengekalkan ruang kerja 1 pada dwindle untuk pelayaran dan ruang kerja 2 pada scrolling untuk kod, dan ruang kerja itu akan kembali seperti itu selepas dimulakan semula.

Jika anda ingin menggunakan susun atur scrolling sebagai lalai, anda boleh menetapkannya dalam `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Ruang kerja terapung

Ruang kerja terapung berfungsi seperti desktop tradisional: tetingkap bertindih, dan anda mengalihkan serta mengubah saiznya sendiri. Setiap tetingkap mendapat bar tajuk dalam warna tema anda, dengan butang untuk meminimumkan, memaksimumkan, dan menutup. `Super + M` turut meminimumkan tetingkap yang difokuskan. Tetingkap yang diminimumkan menunggu dalam dok; klik aplikasinya untuk membawanya kembali. Klik tetingkap untuk membawanya ke hadapan. Ubah saiznya dari mana-mana tepi atau sudut. Klik dua kali bar tajuk untuk memaksimumkan tetingkap sambil mengekalkan bar atas dalam pandangan, dan sekali lagi untuk mendapatkan kembali saiz lamanya. Chrome dan pelayar berasaskan Chromium yang lain, Disks dan Document Viewer melangkau bar tajuk dan menggunakan pengepalanya sendiri sebaliknya; `Super + Alt + F` memaksimumkannya, dan `Super + M` meminimumkannya.

Setiap ruang kerja mempunyai dok, dengan aplikasi anda yang disematkan, semua yang sedang berjalan, dan grid setiap aplikasi di sebalik butang aplikasi, yang `Super + Alt + Space` dan _Apps_ dalam menu Omarchy turut buka. Klik kanan aplikasi pada grid, atau tekan `Delete`, untuk menyahpasangnya. Klik aplikasi untuk membukanya, atau untuk membawa tetingkapnya ke hadapan; klik lagi untuk berkitar melalui tetingkapnya. Files hanya membawa kembali tetingkap dari ruang kerja yang anda berada dan sebaliknya membuka tetingkap baharu, dan Terminal dan Agent sentiasa memulakan yang lain, walaupun tetingkap yang diminimumkan akan kembali dahulu. Klik tengah membuka tetingkap baharu. Seret ikon di sepanjang dok untuk mengalihkannya; menyeret aplikasi yang sedang berjalan masuk ke antara aplikasi lain akan mengekalkannya di situ. Klik kanan untuk mengekalkan aplikasi dalam dok, mengeluarkannya, atau menutupnya. Dok kekal terdedah semasa ruang kerja kosong, dan sebaik sahaja ruang kerja mempunyai tetingkap ia akan bersembunyi sehingga penuding mencapai tepinya. Tetingkap skrin penuh menyembunyikannya sepenuhnya. Seret butang aplikasi ke arah tepi lain skrin untuk mengalihkan dok ke situ. Klik kanan padanya untuk _Position_, bagi memilih tepi, _Layout_, bagi menetapkan susun atur lalai sebagaimana yang dilakukan oleh _Appearance > Workspace Layout_, dan _Visibility_, bagi memastikan dok sentiasa aktif, membiarkan aplikasi pertama menyembunyikannya, atau memastikannya sentiasa tersembunyi. `omarchy dock visibility always` menetapkan perkara itu dari terminal. Kedudukan itu juga berada di bawah _Appearance > Dock > Dock Position_, dan `omarchy dock position left` menetapkannya dari terminal. Aplikasi yang anda kekalkan dalam dok menjadi pudar semasa ia tidak berjalan. Untuk mengekalkan dok hanya pada ruang kerja terapung, gunakan _Appearance > Dock > Dock Only on Floating_ atau `omarchy dock tiling off`.

Ruang kerja baharu, dan mana-mana ruang kerja yang belum anda berikan susun aturnya sendiri dengan `Super + L`, menggunakan susun atur lalai. Mengubah lalai akan menetapkan semula setiap ruang kerja tanpa tetingkap kepadanya, manakala ruang kerja yang mempunyai tetingkap akan mengekalkan susun atur yang dimilikinya. Tetingkap yang diminimumkan ke dok masih dikira sebagai tetingkap pada ruang kerja yang ditinggalkannya. Pilihnya di bawah _Appearance > Workspace Layout_: Tiling, Scrolling, atau Floating. `omarchy hyprland workspace layout default scrolling` menetapkannya dari terminal.

### Mengumpulkan tetingkap

Tetingkap boleh dikumpulkan menggunakan `Super + G`. Sebaik sahaja anda berada dalam kumpulan, setiap tetingkap yang anda mulakan semasa kumpulan itu aktif akan tergolong dalam kumpulan itu. Anda boleh bergerak antara tetingkap terkumpul ini menggunakan `Super + Ctrl + Arrow Left/Right` atau `Super + Alt + 1/2/3/4` untuk pergi terus kepada tetingkap terkumpul mengikut urutan.

Anda boleh mengalihkan tetingkap keluar daripada kumpulan dengan `Super + Alt + G` atau membubarkan keseluruhan kumpulan dengan menekan `Super + G` sekali lagi. Akhir sekali, anda boleh mengalihkan tetingkap di luar kumpulan masuk ke dalamnya dengan `Super + Alt + Arrows`.

### Mengeluarkan tetingkap

Anda boleh mengeluarkan tetingkap daripada peruntukan ruang kerjanya dengan `Super + O`. Itu akan menyematkannya sebagai tetingkap terapung yang mengikuti anda ke mana-mana ruang kerja yang anda pergi. Hebat untuk pemain video dan sebagainya.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Ruang kerja scratchpad

Terdapat ruang kerja scratchpad khas bersaiz penuh yang menindih apa-apa ruang kerja yang anda berada sekarang. Anda mencapai apa yang ada padanya menggunakan `Super + S`, dan anda meletakkan tetingkap di situ menggunakan `Super + Alt + S`.

Ia berfungsi dengan baik untuk kawalan atau terminal yang anda mahu gunakan dengan cepat tanpa meninggalkan ruang kerja semasa.

### Konsol Quake

Akhir sekali, terdapat konsol Quake setengah ketinggian yang menjunam ke bawah menindih apa-apa ruang kerja yang anda berada sekarang. Togolnya dengan `Super + the key above Tab` (grave pada susun atur US), dan letakkan tetingkap di situ menggunakan `Super + Shift + the key above Tab`.

Kali pertama ia dibuka, ia memulakan ejen lalai anda, atau meminta anda memilih satu jika anda belum memilihnya lagi. Semasa konsol hanya memegang satu tetingkap, ia menjunam sebagai panel berpusat dan bukannya merentangi skrin. Letakkan aplikasi kedua padanya dan ia akan kembali kepada lebar penuh, supaya kedua-duanya mempunyai ruang untuk duduk bersebelahan.

Untuk mengalihkan tetingkap keluar daripada sama ada scratchpad atau konsol, hantarnya terus ke ruang kerja lain dengan sesuatu seperti `Super + Shift + 1`.

### Memang ambil masa untuk membiasakannya!

Memang ambil sedikit masa untuk membiasakan diri menavigasi desktop anda seperti ini, tetapi sebaik sahaja anda biasa, sukar untuk kembali kepada pengalaman desktop tradisional yang dipacu tetikus!
