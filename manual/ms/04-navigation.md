# Navigasi

Segala-galanya dalam Omarchy berlaku melalui papan kekunci — _SEGALA-GALANYA!_ Apabila sistem mula-mula dimulakan, anda benar-benar tidak boleh berbuat apa-apa dengan tetikus sahaja. Tetapi anda boleh tekan `Super + Space` untuk memaparkan Menu Omarchy dan dari sini anda boleh melakukan hampir segala-galanya.

Tetapi menu Omarchy pun sebenarnya bukan bertujuan menjadi cara utama untuk mengendalikan sistem pada kebanyakan masa. Kita boleh melakukannya dengan lebih pantas daripada itu! Semua aplikasi terpenting diikat terus kepada kekunci pintas individu. Anda memulakan terminal dengan `Super + Return` dan pelayar dengan `Super + Shift + Return`. Cuba lakukan satu demi satu, dan anda akan melihat keajaiban penyusunan berjubin Hyprland beraksi:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Kemudian anda boleh tekan `Super + J` untuk menyusunnya bertindan di atas satu sama lain dan bukannya bersebelahan:

 ![navigation-stacked](images/navigation-stacked.webp)

Tekan `Super + J` sekali lagi untuk mengembalikannya ke kedudukan bersebelahan. Kemudian cuba `Super + Shift + Arrow Right` semasa berada pada pelayar untuk menukar tetingkap.

Sekarang cuba `Super + Shift + T` untuk memulakan monitor Aktiviti. Ia akan muncul sebagai tetingkap terapung. Anda boleh menyusunnya secara berjubin menggunakan `Super + T` (dan tekan itu sekali lagi untuk menjadikannya terapung semula). Sekarang tekan `Super + Shift + F` untuk membuka pengurus fail. Anda akan mendapat susunan empat hala yang kemas:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Anda bernavigasi antara tetingkap yang anda mahu aktifkan dengan `Super + Arrow`. Ini akan menukar fokus dan menggerakkan kursor ke tengah aplikasi baharu. Di tepi skrin, ia diteruskan ke monitor di sebelah itu.

Jika anda tekan `Super + Shift + 2`, anda akan mengalihkan aplikasi yang sedang difokuskan ke ruang kerja kedua. `Super + Shift + 1` mengalihkannya kembali. (Dan `Super + Shift + Alt + 2` akan mengalihkan aplikasi yang sedang difokuskan ke ruang kerja kedua tanpa beralih kepadanya).

Dengan lebih daripada satu monitor, setiap monitor mempunyai ruang kerja 1 hingga 10 tersendiri. `Super + 2` pergi ke ruang kerja kedua monitor yang sedang anda gunakan, dan bar atas setiap monitor menunjukkan ruang kerjanya sendiri dan yang sedang dipaparkannya. `Super + Tab` berkitar melalui ruang kerja pada monitor yang sedang anda gunakan. `Super + Shift + Ctrl + Arrows` mengalihkan tetingkap yang sedang anda gunakan ke monitor ke arah itu, ke ruang kerja yang sedang dipaparkannya, dan `Super + Shift + Alt + Arrows` mengalihkan ruang kerja yang sedang anda gunakan ke monitor ke arah itu, di mana ia mengambil nombor yang sama jika kosong. Sesebuah monitor mengekalkan ruang kerjanya apabila anda mencabutnya: ruang kerja itu menyertai skrin lain, dinomborkan selepas yang sudah ada padanya, dan kembali kepada nombor lamanya apabila monitor itu kembali.

Jika anda menahan `Super` dan menggunakan tetikus untuk mengklik tetingkap, anda boleh menyusun semula kedudukannya. Jika anda menahan `Super` dan menggunakan butang kanan pada tetikus, anda boleh mengubah saiz tetingkap dengan bebas.

Anda menutup tetingkap dengan `Super + W` atau `Super + Q` (dan menutup semua tetingkap dengan `Ctrl + Alt + Delete`).

Anda juga boleh pergi ke skrin penuh dengan `Super + F` atau hanya lebar penuh (mengekalkan bar atas) dengan `Super + Alt + F` atau skrin penuh dalam tetingkap dengan `Super + Ctrl + F` (sesuai untuk YouTube!).

### Dwindle lwn susun atur menatal

Susun atur lalai Omarchy dipanggil dwindle. Ia mengekalkan semua tetingkap yang anda buka pada satu ruang kerja kelihatan sepanjang masa, walaupun ia terpaksa mengecilkannya.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Tetapi anda juga boleh memilih untuk menukar ruang kerja kepada susun atur menatal di mana tetingkap disusun bersebelahan, melampaui tepi paparan yang kelihatan. Anda menukar satu ruang kerja kepada susun atur ini melalui `Super + L`.

Menekan `Super + L` sekali lagi menukar ruang kerja kepada terapung, di mana tetingkap bertindan dengan bebas dan anda meletakkannya sendiri, dan tekanan ketiga mengembalikannya kepada dwindle. `Super + Alt + L` melaluinya mengikut arah sebaliknya. Tetingkap yang memang terapung — yang anda keluarkan dengan `Super + T`, atau aplikasi yang sentiasa dibuka secara terapung — kekal terapung apabila ruang kerja kembali kepada penyusunan berjubin. Bar atas menandai ruang kerja yang sedang anda gunakan dengan susun aturnya: segi empat sama untuk dwindle, bulatan untuk menatal, dan segi tiga untuk terapung. Mengklik tanda itu juga berkitar melalui susun atur.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pilihan ini adalah bagi setiap ruang kerja, dan ia kekal. Jadi anda boleh mengekalkan ruang kerja 1 pada dwindle untuk pelayaran dan ruang kerja 2 pada menatal untuk kod, dan ia akan kembali seperti itu selepas dimulakan semula.

Jika anda ingin menggunakan susun atur menatal sebagai lalai, anda boleh menetapkannya dalam `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Ruang kerja terapung

Ruang kerja terapung berfungsi seperti desktop tradisional: tetingkap bertindan, dan anda mengalih serta mengubah saiznya sendiri. Setiap tetingkap mendapat bar tajuk dalam warna tema anda, dengan butang untuk meminimumkan, memaksimumkan, dan menutup. `Super + M` juga meminimumkan tetingkap yang difokuskan. Tetingkap yang diminimumkan menunggu di dok; klik aplikasinya untuk membawanya kembali. Klik tetingkap untuk membawanya ke hadapan. Ubah saiznya dari mana-mana tepi atau sudut. Klik dua kali bar tajuk untuk memaksimumkan tetingkap sambil mengekalkan bar atas kelihatan, dan sekali lagi untuk mendapatkan kembali saiz lamanya.

Ruang kerja terapung juga menunjukkan dok, dengan aplikasi yang anda sematkan, segala yang sedang berjalan, dan grid setiap aplikasi di sebalik butang aplikasi, yang turut dibuka oleh `Super + Alt + Space` dan _Apps_ dalam menu Omarchy. Klik kanan aplikasi pada grid, atau tekan `Delete`, untuk menyahpasangnya. Klik aplikasi untuk membukanya, atau untuk membawa tetingkapnya ke hadapan; klik sekali lagi untuk berkitar melalui tetingkapnya. Klik tengah membuka tetingkap baharu. Seret ikon sepanjang dok untuk mengalihkannya; menyeret aplikasi yang sedang berjalan masuk ke antara yang lain akan mengekalkannya di situ. Klik kanan untuk mengekalkan aplikasi dalam dok, mengeluarkannya, atau menutupnya. Dok menyingkir daripada laluan tetingkap skrin penuh. Klik kanan butang aplikasi untuk mengalihkan dok ke tepi lain atau menyuruhnya bersembunyi sehingga penunjuk mencapai tepinya. Kedudukan itu juga berada di bawah _Appearance > Dock > Dock Position_, dan `omarchy dock position left` serta `omarchy dock autohide on` menetapkan kedua-duanya dari terminal. Aplikasi yang anda kekalkan dalam dok menjadi pudar semasa ia tidak berjalan.

Ruang kerja baharu, dan mana-mana yang belum anda berikan susun atur tersendiri dengan `Super + L`, menggunakan susun atur lalai. Menukar lalai menetapkan semula setiap ruang kerja tanpa tetingkap kepadanya, manakala ruang kerja yang mempunyai tetingkap padanya mengekalkan susun atur yang dimilikinya. Tetingkap yang diminimumkan ke dok masih dikira sebagai tetingkap pada ruang kerja yang ditinggalkannya. Pilihnya di bawah _Appearance > Workspace Layout_: Tiling, Scrolling, atau Floating. `omarchy-hyprland-workspace-layout-default scrolling` menetapkannya dari terminal.

### Mengumpulkan tetingkap

Tetingkap boleh dikumpulkan menggunakan `Super + G`. Sebaik sahaja anda berada dalam kumpulan, setiap tetingkap yang anda mulakan semasa ia aktif akan menjadi milik kumpulan itu. Anda boleh bergerak antara tetingkap yang dikumpulkan ini menggunakan `Super + Ctrl + Arrow Left/Right` atau `Super + Alt + 1/2/3/4` untuk pergi terus ke tetingkap terkumpul mengikut urutan.

Anda boleh mengalihkan tetingkap keluar daripada kumpulan dengan `Super + Alt + G` atau membongkar seluruh kumpulan dengan menekan `Super + G` sekali lagi. Akhir sekali, anda boleh mengalihkan tetingkap di luar kumpulan masuk ke dalamnya dengan `Super + Alt + Arrows`.

### Mengeluarkan tetingkap

Anda boleh mengeluarkan tetingkap daripada peruntukan ruang kerjanya dengan `Super + O`. Itu akan menyematkannya sebagai tetingkap terapung yang mengikuti anda ke mana-mana ruang kerja yang anda pergi. Sesuai untuk pemain video dan seumpamanya.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Ruang kerja scratchpad

Terdapat ruang kerja scratchpad bersaiz penuh khas yang menindih mana-mana ruang kerja yang sedang anda gunakan. Anda mengakses apa yang ada padanya menggunakan `Super + S`, dan anda meletakkan tetingkap di sana menggunakan `Super + Alt + S`.

Ia berfungsi dengan baik untuk kawalan atau terminal yang anda mahu gunakan dengan pantas tanpa meninggalkan ruang kerja semasa.

### Konsol Quake

Akhir sekali, terdapat konsol Quake separuh ketinggian yang jatuh ke bawah menindih mana-mana ruang kerja yang sedang anda gunakan. Togolnya dengan `Super + Grave`, dan letakkan tetingkap di sana menggunakan `Super + Shift + Grave`.

Ia dibuka dengan ejen lalai anda sedia untuk digunakan. Semasa konsol itu memegang satu tetingkap, ia jatuh sebagai panel berpusat dan bukannya merentangi skrin. Letakkan aplikasi kedua padanya dan ia kembali kepada lebar penuh, supaya kedua-duanya mempunyai ruang untuk duduk bersebelahan.

Untuk mengalihkan tetingkap keluar daripada scratchpad atau konsol, hantarkannya terus ke ruang kerja lain dengan sesuatu seperti `Super + Shift + 1`.

### Ia mengambil masa untuk membiasakan diri!

Ia mengambil sedikit masa untuk membiasakan diri bernavigasi di desktop anda seperti ini, tetapi sebaik sahaja anda biasa, sukar untuk kembali kepada pengalaman desktop tradisional yang dipacu tetikus!
