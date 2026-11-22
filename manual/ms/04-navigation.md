# Navigasi

Segala-galanya dalam Omarchy berlaku melalui papan kekunci — _SEGALA-GALANYA!_ Apabila sistem mula-mula dimulakan, anda secara literalnya tidak boleh berbuat apa-apa dengan tetikus sahaja. Tetapi anda boleh menekan `Super + Space` untuk memaparkan Menu Omarchy dan dari sini anda boleh melakukan hampir segala-galanya.

Namun menu Omarchy pun tidak dimaksudkan sebagai cara utama untuk mengendalikan sistem pada kebanyakan masa. Kita boleh melakukannya dengan lebih pantas daripada itu! Semua aplikasi yang paling penting diikat terus kepada kekunci pintas individu. Anda memulakan terminal dengan `Super + Return` dan pelayar dengan `Super + Shift + Return`. Cuba lakukan satu demi satu, dan anda akan melihat keajaiban penjubinan Hyprland beraksi:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Anda kemudian boleh menekan `Super + J` untuk menyusunnya bertindih di atas satu sama lain dan bukannya bersebelahan:

 ![navigation-stacked](images/navigation-stacked.webp)

Tekan `Super + J` sekali lagi untuk mengembalikannya ke kedudukan bersebelahan. Kemudian cuba `Super + Shift + Arrow Right` semasa berada dalam pelayar untuk menukar tetingkap.

Sekarang cuba `Super + Shift + T` untuk memulakan monitor Activity. Itu akan muncul sebagai tetingkap terapung. Anda boleh menjubinkannya menggunakan `Super + T` (dan tekan itu sekali lagi untuk menjadikannya terapung semula). Sekarang tekan `Super + Shift + F` untuk membuka pengurus fail. Anda akan mempunyai susunan empat hala yang kemas:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Anda menavigasi antara tetingkap yang anda mahu aktifkan dengan `Super + Arrow`. Ini akan menukar fokus dan mengalihkan kursor ke tengah aplikasi baharu. Di tepi skrin, ia berterusan ke monitor di sebelah itu.

Jika anda menekan `Super + Shift + 2`, anda akan mengalihkan aplikasi yang sedang difokuskan ke ruang kerja kedua. `Super + Shift + 1` mengalihkannya kembali. (Dan `Super + Shift + Alt + 2` akan mengalihkan aplikasi yang sedang difokuskan ke ruang kerja kedua tanpa beralih kepadanya).

Dengan lebih daripada satu monitor, setiap monitor mempunyai ruang kerja 1 hingga 10 tersendiri. `Super + 2` pergi ke ruang kerja kedua monitor yang anda gunakan, dan bar atas setiap monitor menunjukkan ruang kerjanya sendiri dan ruang kerja yang sedang dipaparkannya. `Super + Tab` berkitar melalui ruang kerja pada monitor yang anda gunakan. `Super + Shift + Ctrl + Arrows` mengalihkan tetingkap yang anda gunakan ke monitor dalam arah itu, ke ruang kerja yang sedang dipaparkannya, dan `Super + Shift + Alt + Arrows` mengalihkan ruang kerja yang anda gunakan ke monitor dalam arah itu, di mana ia mengambil nombor yang sama jika nombor itu kosong. Monitor mengekalkan ruang kerjanya apabila anda mencabutnya: ruang kerja itu menyertai ruang kerja skrin lain, dinomborkan selepas ruang kerja yang sudah ada padanya, dan kembali menggunakan nombor lamanya apabila monitor itu kembali.

Jika anda menahan `Super` dan menggunakan tetikus untuk mengklik tetingkap, anda akan dapat menyusun semula kedudukannya. Jika anda menahan `Super` dan menggunakan butang kanan pada tetikus, anda boleh menukar saiz tetingkap dengan bebas.

Anda menutup tetingkap dengan `Super + W` atau `Super + Q` (dan menutup semua tetingkap dengan `Ctrl + Alt + Delete`).

Anda juga boleh pergi ke skrin penuh dengan `Super + F` atau hanya lebar penuh (mengekalkan bar atas) dengan `Super + Alt + F` atau skrin penuh dalam tetingkap dengan `Super + Ctrl + F` (bagus untuk YouTube!).

### Susun atur dwindle lwn penatalan

Susun atur lalai Omarchy dipanggil dwindle. Ia memastikan semua tetingkap yang anda buka pada satu ruang kerja kelihatan pada setiap masa, walaupun ia terpaksa mengecilkannya.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Tetapi anda juga boleh memilih untuk menukar ruang kerja menjadi susun atur penatalan di mana tetingkap disusun bersebelahan, melepasi tepi paparan yang kelihatan. Anda menukar satu ruang kerja menjadi susun atur ini melalui `Super + L`.

Menekan `Super + L` sekali lagi menukar ruang kerja itu menjadi terapung, di mana tetingkap bertindih dengan bebas dan anda meletakkannya sendiri, dan tekanan ketiga mengembalikannya kepada dwindle. `Super + Alt + L` melaluinya dalam arah sebaliknya. Tetingkap yang sememangnya terapung — tetingkap yang anda keluarkan dengan `Super + T`, atau aplikasi yang sentiasa dibuka sebagai terapung — kekal terapung apabila ruang kerja kembali kepada penjubinan. Bar atas menandakan ruang kerja yang anda gunakan dengan susun aturnya: segi empat sama untuk dwindle, bulatan untuk penatalan, dan segi tiga untuk terapung. Mengklik tanda itu juga berkitar melalui susun atur, begitu juga kekunci paparan pada komputer riba yang mempunyainya.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pilihan ini adalah mengikut ruang kerja, dan ia kekal. Jadi anda boleh mengekalkan ruang kerja 1 pada dwindle untuk pelayaran dan ruang kerja 2 pada penatalan untuk kod, dan ruang kerja itu akan kembali seperti itu selepas dimulakan semula.

Jika anda ingin menggunakan susun atur penatalan sebagai lalai, anda boleh menetapkannya dalam `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Ruang kerja terapung

Ruang kerja terapung berfungsi seperti desktop tradisional: tetingkap bertindih, dan anda mengalih serta menukar saiznya sendiri. Setiap tetingkap mendapat bar tajuk dalam warna tema anda, dengan butang untuk meminimumkan, memaksimumkan, dan menutup. `Super + M` juga meminimumkan tetingkap yang difokuskan. Tetingkap yang diminimumkan menunggu dalam dok; klik aplikasinya untuk membawanya kembali. Klik tetingkap untuk membawanya ke hadapan. Tukar saiznya dari mana-mana tepi atau sudut. Klik dua kali bar tajuk untuk memaksimumkan tetingkap sambil mengekalkan bar atas dalam pandangan, dan sekali lagi untuk mendapatkan kembali saiz lamanya. Chrome dan pelayar berasaskan Chromium lain, Disks dan Document Viewer melangkau bar tajuk dan menggunakan pengepala mereka sendiri; `Super + Alt + F` memaksimumkannya, dan `Super + M` meminimumkannya.

Ruang kerja terapung juga menunjukkan dok, dengan aplikasi yang anda sematkan, semua yang sedang berjalan, dan grid setiap aplikasi di sebalik butang aplikasi, yang `Super + Alt + Space` dan _Aplikasi_ dalam menu Omarchy juga buka. Klik kanan aplikasi pada grid, atau tekan `Delete`, untuk menyahpasangnya. Klik aplikasi untuk membukanya, atau untuk membawa tetingkapnya ke hadapan; klik sekali lagi untuk berkitar melalui tetingkapnya. Files hanya membawa kembali tetingkap dari ruang kerja yang anda gunakan dan sebaliknya membuka tetingkap baharu, dan Terminal dan Agent sentiasa memulakan satu lagi, walaupun tetingkap yang diminimumkan kembali dahulu. Klik tengah membuka tetingkap baharu. Seret ikon di sepanjang dok untuk mengalihkannya; menyeret aplikasi yang sedang berjalan masuk ke antara aplikasi lain mengekalkannya di situ. Klik kanan untuk mengekalkan aplikasi dalam dok, mengeluarkannya, atau menutupnya. Dok menyingkir dari laluan tetingkap skrin penuh. Klik kanan butang aplikasi untuk mengalihkan dok ke tepi lain atau menyuruhnya sembunyi sehingga penuding mencapai tepinya. Kedudukan itu juga berada di bawah _Penampilan > Dok > Kedudukan Dok_, dan `omarchy dock position left` dan `omarchy dock autohide on` menetapkan kedua-duanya dari terminal. Aplikasi yang anda kekalkan dalam dok menjadi pudar semasa aplikasi itu tidak berjalan.

Ruang kerja baharu, dan mana-mana ruang kerja yang anda belum berikan susun aturnya sendiri dengan `Super + L`, menggunakan susun atur lalai. Menukar lalai menetapkan semula setiap ruang kerja tanpa tetingkap kepadanya, manakala ruang kerja dengan tetingkap padanya mengekalkan susun atur yang dimilikinya. Tetingkap yang diminimumkan ke dok masih dikira sebagai tetingkap pada ruang kerja yang ditinggalkannya. Pilihnya di bawah _Penampilan > Susun Atur Ruang Kerja_: Penjubinan, Penatalan, atau Terapung. `omarchy hyprland workspace layout default scrolling` menetapkannya dari terminal.

### Mengumpulkan tetingkap

Tetingkap boleh dikumpulkan menggunakan `Super + G`. Sebaik sahaja anda berada dalam kumpulan, setiap tetingkap yang anda mulakan semasa kumpulan itu aktif akan tergolong dalam kumpulan itu. Anda boleh bergerak antara tetingkap berkumpulan ini menggunakan `Super + Ctrl + Arrow Left/Right` atau `Super + Alt + 1/2/3/4` untuk pergi terus kepada tetingkap berkumpulan mengikut urutan.

Anda boleh mengalihkan tetingkap keluar dari kumpulan dengan `Super + Alt + G` atau membongkar keseluruhan kumpulan dengan menekan `Super + G` sekali lagi. Akhir sekali, anda boleh mengalihkan tetingkap di luar kumpulan masuk ke dalamnya dengan `Super + Alt + Arrows`.

### Mengeluarkan tetingkap

Anda boleh mengeluarkan tetingkap daripada peruntukan ruang kerjanya dengan `Super + O`. Itu akan menyematkannya sebagai tetingkap terapung yang mengikuti anda ke mana-mana ruang kerja yang anda pergi. Bagus untuk pemain video dan seumpamanya.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Ruang kerja scratchpad

Terdapat ruang kerja scratchpad bersaiz penuh khas yang menindih ruang kerja yang sedang anda gunakan. Anda mengakses apa yang ada padanya menggunakan `Super + S`, dan anda meletakkan tetingkap di situ menggunakan `Super + Alt + S`.

Ia berfungsi dengan baik untuk kawalan atau terminal yang anda mahu gunakan dengan cepat tanpa meninggalkan ruang kerja semasa.

### Konsol Quake

Akhir sekali, terdapat konsol Quake setengah ketinggian yang jatuh ke bawah menindih ruang kerja yang sedang anda gunakan. Togolnya dengan `Super + Grave`, dan letakkan tetingkap di situ menggunakan `Super + Shift + Grave`.

Kali pertama ia dibuka, ia memulakan ejen lalai anda, atau meminta anda memilih satu jika anda belum memilihnya. Semasa konsol itu memegang satu tetingkap, ia jatuh ke bawah sebagai panel berpusat dan bukannya merentangi skrin. Letakkan aplikasi kedua padanya dan ia kembali kepada lebar penuh, supaya kedua-duanya mempunyai ruang untuk duduk bersebelahan.

Untuk mengalihkan tetingkap keluar sama ada dari scratchpad atau konsol, hantarnya terus ke ruang kerja lain dengan sesuatu seperti `Super + Shift + 1`.

### Ia memerlukan sedikit masa untuk membiasakan diri!

Ia memerlukan sedikit masa untuk membiasakan diri menavigasi desktop anda seperti ini, tetapi sebaik sahaja anda berjaya, ia akan menjadi sukar untuk kembali kepada pengalaman desktop tradisional yang dipacu tetikus!
