# Navigasi

Segala-galanya dalam Omarchy berlaku melalui papan kekunci — _SEGALA-GALANYA!_ Apabila sistem mula-mula dimulakan, anda memang langsung tidak boleh buat apa-apa dengan tetikus sahaja. Tetapi anda boleh tekan `Super + Space` untuk memaparkan Menu Omarchy dan dari sini anda boleh buat hampir segala-galanya.

Tetapi menu Omarchy tidak pun dimaksudkan sebagai cara utama untuk mengendalikan sistem pada kebanyakan masa. Kita boleh jadi lebih pantas daripada itu! Semua aplikasi paling penting diikat terus kepada kekunci pintas individu. Anda mulakan terminal dengan `Super + Return` dan pelayar dengan `Super + Shift + Return`. Cuba buat satu demi satu, dan anda akan lihat keajaiban jubin Hyprland beraksi:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Anda kemudian boleh tekan `Super + J` untuk menyusunnya bertindih antara satu sama lain dan bukannya bersebelahan:

 ![navigation-stacked](images/navigation-stacked.webp)

Tekan `Super + J` sekali lagi untuk mengembalikannya ke kedudukan bersebelahan. Kemudian cuba `Super + Shift + Arrow Right` semasa dalam pelayar untuk menukar kedudukan tetingkap.

Sekarang cuba `Super + Shift + T` untuk memulakan monitor Activity. Itu akan muncul sebagai tetingkap terapung. Anda boleh menjubinkannya menggunakan `Super + T` (dan tekan itu sekali lagi untuk menjadikannya terapung semula). Sekarang tekan `Super + Shift + F` untuk membuka pengurus fail. Anda akan mempunyai susunan empat hala yang kemas:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Anda menavigasi antara tetingkap yang anda mahu aktifkan dengan `Super + Arrow`. Ini akan menukar fokus dan mengalihkan kursor ke tengah aplikasi baharu. Di tepi skrin, ia berterusan ke monitor di sebelah itu.

Jika anda tekan `Super + Shift + 2`, anda akan mengalihkan aplikasi berfokus semasa ke ruang kerja kedua. `Super + Shift + 1` mengalihkannya kembali. (Dan `Super + Shift + Alt + 2` akan mengalihkan aplikasi berfokus semasa ke ruang kerja kedua tanpa beralih kepadanya).

Dengan lebih daripada satu monitor, setiap monitor mempunyai ruang kerja 1 hingga 10 sendiri. `Super + 2` pergi ke ruang kerja kedua monitor yang anda berada padanya, dan bar atas setiap monitor menunjukkan ruang kerjanya sendiri dan yang sedang dipaparkannya. `Super + Tab` berkitar melalui ruang kerja pada monitor yang anda berada padanya. `Super + Shift + Ctrl + Arrows` mengalihkan tetingkap yang anda berada padanya ke monitor dalam arah itu, ke ruang kerja yang sedang dipaparkannya, dan `Super + Shift + Alt + Arrows` mengalihkan ruang kerja yang anda berada padanya ke monitor dalam arah itu, di mana ia mengambil nombor yang sama jika kosong. Monitor mengekalkan ruang kerjanya apabila anda mencabutnya: ruang kerja itu menyertai skrin lain, dinomborkan selepas yang sudah ada padanya, dan kembali kepada nombor lamanya apabila monitor itu kembali.

Jika anda menahan `Super` dan menggunakan tetikus untuk klik pada tetingkap, anda akan dapat menyusun semula kedudukannya. Jika anda menahan `Super` dan menggunakan butang kanan pada tetikus, anda boleh mengubah saiz tetingkap dengan bebas.

Anda menutup tetingkap dengan `Super + W` atau `Super + Q` (dan menutup semua tetingkap dengan `Ctrl + Alt + Delete`).

Anda juga boleh pergi ke skrin penuh dengan `Super + F` atau malah lebar penuh sahaja (mengekalkan bar atas) dengan `Super + Alt + F` atau skrin penuh dalam tetingkap dengan `Super + Ctrl + F` (bagus untuk YouTube!).

### Susun atur dwindle vs scrolling

Susun atur lalai Omarchy dipanggil dwindle. Ia mengekalkan semua tetingkap yang anda buka pada satu ruang kerja kelihatan pada setiap masa, walaupun ia terpaksa mengecilkannya.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Tetapi anda juga boleh memilih untuk menukar ruang kerja menjadi susun atur scrolling di mana tetingkap disusun bersebelahan, melampaui tepi paparan yang kelihatan. Anda menukar satu ruang kerja kepada susun atur ini melalui `Super + L`.

Tekan `Super + L` sekali lagi menukar ruang kerja kepada terapung, di mana tetingkap bertindih dengan bebas dan anda meletakkannya sendiri, dan tekanan ketiga mengembalikannya kepada dwindle. `Super + Alt + L` melaluinya ke arah sebaliknya. Tetingkap yang memang terapung — yang anda keluarkan dengan `Super + T`, atau aplikasi yang sentiasa dibuka terapung — kekal terapung apabila ruang kerja kembali kepada jubin. Bar atas menandakan ruang kerja yang anda berada padanya dengan susun aturnya: segi empat sama untuk dwindle, bulatan untuk scrolling, dan segi tiga untuk terapung. Klik pada tanda itu juga berkitar melalui susun atur.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pilihan adalah mengikut ruang kerja, dan ia kekal. Jadi anda boleh mengekalkan ruang kerja 1 pada dwindle untuk pelayaran dan ruang kerja 2 pada scrolling untuk kod, dan ia akan kembali seperti itu selepas dimulakan semula.

Jika anda ingin menggunakan susun atur scrolling sebagai lalai, anda boleh tetapkan itu dalam `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Ruang kerja terapung

Ruang kerja terapung berfungsi seperti desktop tradisional: tetingkap bertindih, dan anda mengalih serta mengubah saiznya sendiri. Setiap tetingkap mendapat bar tajuk dalam warna tema anda, dengan butang untuk meminimumkan, memaksimumkan, dan menutup. `Super + M` juga meminimumkan tetingkap berfokus. Tetingkap yang diminimumkan menunggu dalam dok; klik aplikasinya untuk membawanya kembali. Klik tetingkap untuk membawanya ke hadapan. Ubah saiznya dari mana-mana tepi atau sudut. Klik dua kali bar tajuk untuk memaksimumkan tetingkap sambil mengekalkan bar atas kelihatan, dan sekali lagi untuk mendapatkan kembali saiz lamanya. Chrome dan pelayar berasaskan Chromium yang lain, Disks dan Document Viewer melangkau bar tajuk dan menggunakan pengepala mereka sendiri sebaliknya; `Super + Alt + F` memaksimumkannya, dan `Super + M` meminimumkannya.

Ruang kerja terapung juga menunjukkan dok, dengan aplikasi yang anda pin, semua yang sedang berjalan, dan grid setiap aplikasi di sebalik butang aplikasi, yang `Super + Alt + Space` dan _Aplikasi_ dalam menu Omarchy juga buka. Klik kanan aplikasi pada grid, atau tekan `Delete`, untuk menyahpasangnya. Klik aplikasi untuk membukanya, atau untuk membawa tetingkapnya ke hadapan; klik sekali lagi untuk berkitar melalui tetingkapnya. Files hanya membawa kembali tetingkap dari ruang kerja yang anda berada padanya dan jika tidak membuka yang baharu, dan Terminal dan Agent sentiasa memulakan yang lain, walaupun tetingkap yang diminimumkan kembali dahulu. Klik tengah membuka tetingkap baharu. Seret ikon sepanjang dok untuk mengalihkannya; menyeret aplikasi yang sedang berjalan masuk antara yang lain mengekalkan ia di situ. Klik kanan untuk mengekalkan aplikasi dalam dok, mengeluarkannya, atau menamatkannya. Dok mengelak daripada tetingkap skrin penuh. Klik kanan butang aplikasi untuk mengalihkan dok ke tepi lain atau menyuruhnya sembunyi sehingga penunjuk mencapai tepinya. Kedudukan itu juga berada di bawah _Penampilan > Dock > Kedudukan Dock_, dan `omarchy dock position left` dan `omarchy dock autohide on` menetapkan kedua-duanya dari terminal. Aplikasi yang anda kekalkan dalam dok dipudarkan semasa ia tidak berjalan.

Ruang kerja baharu, dan mana-mana yang belum anda berikan susun atur sendiri dengan `Super + L`, menggunakan susun atur lalai. Menukar lalai menetapkan semula setiap ruang kerja tanpa tetingkap kepadanya, manakala yang mempunyai tetingkap padanya mengekalkan susun atur yang dimilikinya. Tetingkap yang diminimumkan ke dok masih dikira sebagai tetingkap pada ruang kerja yang ditinggalkannya. Pilihnya di bawah _Penampilan > Susun Atur Ruang Kerja_: Tiling, Scrolling, atau Floating. `omarchy-hyprland-workspace-layout-default scrolling` menetapkannya dari terminal.

### Mengumpulkan tetingkap

Tetingkap boleh dikumpulkan menggunakan `Super + G`. Sebaik sahaja anda berada dalam kumpulan, setiap tetingkap yang anda mulakan semasa itu aktif akan tergolong dalam kumpulan itu. Anda boleh bergerak antara tetingkap berkumpulan ini menggunakan `Super + Ctrl + Arrow Left/Right` atau `Super + Alt + 1/2/3/4` untuk pergi terus kepada tetingkap berkumpulan mengikut urutan.

Anda boleh mengalihkan tetingkap keluar daripada kumpulan dengan `Super + Alt + G` atau membubarkan keseluruhan kumpulan dengan menekan `Super + G` sekali lagi. Akhir sekali, anda boleh mengalihkan tetingkap di luar kumpulan masuk ke dalamnya dengan `Super + Alt + Arrows`.

### Mengeluarkan tetingkap

Anda boleh mengeluarkan tetingkap daripada peruntukan ruang kerjanya dengan `Super + O`. Itu akan meminnya sebagai tetingkap terapung yang mengikuti anda ke mana-mana ruang kerja yang anda pergi. Bagus untuk pemain video dan seumpamanya.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Ruang kerja scratchpad

Terdapat ruang kerja scratchpad bersaiz penuh khas yang menindih apa-apa ruang kerja yang anda berada padanya sekarang. Anda mengakses apa yang ada padanya menggunakan `Super + S`, dan anda meletakkan tetingkap di situ menggunakan `Super + Alt + S`.

Ia berfungsi dengan baik untuk kawalan atau terminal yang anda mahu berinteraksi dengannya dengan cepat tanpa meninggalkan ruang kerja semasa.

### Konsol Quake

Akhir sekali, terdapat konsol Quake separuh tinggi yang jatuh ke bawah menindih apa-apa ruang kerja yang anda berada padanya sekarang. Togolnya dengan `Super + Grave`, dan letakkan tetingkap di situ menggunakan `Super + Shift + Grave`.

Ia dibuka dengan ejen lalai anda sedia untuk digunakan. Semasa konsol memegang satu tetingkap sahaja, ia jatuh sebagai panel berpusat dan bukannya merentangi skrin. Letakkan aplikasi kedua padanya dan ia kembali kepada lebar penuh, supaya kedua-duanya mempunyai ruang untuk duduk bersebelahan.

Untuk mengalihkan tetingkap keluar sama ada daripada scratchpad atau konsol, hantarnya terus ke ruang kerja lain dengan sesuatu seperti `Super + Shift + 1`.

### Ia mengambil masa untuk membiasakan diri!

Ia mengambil sedikit masa untuk membiasakan diri menavigasi desktop anda seperti ini, tetapi sebaik sahaja anda biasa, sukar untuk kembali kepada pengalaman desktop tradisional yang dipacu tetikus!
