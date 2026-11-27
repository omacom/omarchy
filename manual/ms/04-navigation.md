# Navigasi

Segala-galanya dalam Omarchy berlaku melalui papan kekunci — _SEMUA!_ Apabila sistem mula-mula dimulakan, anda memang tidak boleh buat apa-apa hanya dengan tetikus. Tetapi anda boleh tekan `Super + Space` untuk memaparkan Menu Omarchy dan dari sini anda boleh buat hampir segala-galanya.

Tetapi menu Omarchy pun tidak dimaksudkan sebagai cara utama untuk mengendalikan sistem pada kebanyakan masa. Kita boleh buat lebih pantas daripada itu! Semua aplikasi yang paling penting diikat terus kepada kekunci pintas tersendiri. Anda memulakan terminal dengan `Super + Return` dan pelayar dengan `Super + Shift + Return`. Cuba buat satu demi satu, dan anda akan lihat keajaiban penjubinan Hyprland beraksi:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Kemudian anda boleh tekan `Super + J` untuk menyusunnya bertindih di atas satu sama lain dan bukannya bersebelahan:

 ![navigation-stacked](images/navigation-stacked.webp)

Tekan `Super + J` sekali lagi untuk mengembalikannya ke kedudukan bersebelahan. Kemudian cuba `Super + Shift + Arrow Right` semasa berada dalam pelayar untuk menukar tetingkap.

Sekarang cuba `Super + Shift + T` untuk memulakan monitor Activity. Itu akan muncul sebagai tetingkap terapung. Anda boleh menjubinkannya menggunakan `Super + T` (dan tekan itu sekali lagi untuk menjadikannya terapung semula). Sekarang tekan `Super + Shift + F` untuk membuka pengurus fail. Anda akan mendapat persediaan empat hala yang kemas:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Anda menavigasi antara tetingkap yang anda mahu aktifkan dengan `Super + Arrow`. Ini akan menukar fokus dan mengalihkan kursor ke tengah aplikasi baharu. Di tepi skrin, ia diteruskan ke monitor di sebelah itu.

Jika anda tekan `Super + Shift + 2`, anda akan mengalihkan aplikasi yang sedang difokuskan ke ruang kerja kedua. `Super + Shift + 1` mengalihkannya kembali. (Dan `Super + Shift + Alt + 2` akan mengalihkan aplikasi yang sedang difokuskan ke ruang kerja kedua tanpa beralih kepadanya).

Dengan lebih daripada satu monitor, setiap monitor mempunyai ruang kerja 1 hingga 10 tersendiri. `Super + 2` pergi ke ruang kerja kedua pada monitor yang sedang anda gunakan, dan bar atas setiap monitor menunjukkan ruang kerjanya sendiri serta ruang kerja yang sedang dipaparkannya. `Super + Tab` mengitar ruang kerja pada monitor yang sedang anda gunakan. `Super + Shift + Ctrl + Arrows` mengalihkan tetingkap yang sedang anda gunakan ke monitor ke arah itu, ke ruang kerja yang sedang dipaparkannya, dan `Super + Shift + Alt + Arrows` mengalihkan ruang kerja yang sedang anda gunakan ke monitor ke arah itu, di mana ia mengambil nombor yang sama jika nombor itu kosong. Sesuatu monitor mengekalkan ruang kerjanya apabila anda mencabutnya: ruang kerja itu bergabung dengan ruang kerja skrin lain, dinomborkan selepas ruang kerja yang sudah ada padanya, dan kembali dengan nombor lamanya apabila monitor itu kembali.

Jika anda menahan `Super` dan menggunakan tetikus untuk mengklik tetingkap, anda akan dapat menyusun semula kedudukannya. Jika anda menahan `Super` dan menggunakan butang kanan pada tetikus, anda boleh mengubah saiz tetingkap dengan bebas.

Anda menutup tetingkap dengan `Super + W` atau `Super + Q` (dan menutup semua tetingkap dengan `Ctrl + Alt + Delete`).

Anda juga boleh pergi ke skrin penuh dengan `Super + F` atau malah hanya ke lebar penuh (mengekalkan bar atas) dengan `Super + Alt + F` atau skrin penuh dalam tetingkap dengan `Super + Ctrl + F` (bagus untuk YouTube!).

### Susun atur dwindle lwn scrolling

Susun atur lalai Omarchy dipanggil dwindle. Ia memastikan semua tetingkap yang anda buka pada satu ruang kerja kelihatan pada setiap masa, walaupun ia terpaksa mengecilkannya.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Tetapi anda juga boleh memilih untuk menukar ruang kerja kepada susun atur scrolling di mana tetingkap disusun bersebelahan, melangkaui tepi paparan yang kelihatan. Anda menukar satu ruang kerja kepada susun atur ini melalui `Super + L`.

Menekan `Super + L` sekali lagi menukar ruang kerja itu kepada terapung, di mana tetingkap bertindih dengan bebas dan anda meletakkannya sendiri, dan penekanan ketiga mengembalikannya kepada dwindle. `Super + Alt + L` melaluinya ke arah sebaliknya. Tetingkap yang sememangnya terapung — tetingkap yang anda keluarkan dengan `Super + T`, atau aplikasi yang sentiasa dibuka secara terapung — kekal terapung apabila ruang kerja itu kembali kepada penjubinan. Bar atas menandakan ruang kerja yang sedang anda gunakan dengan susun aturnya: segi empat sama untuk dwindle, bulatan untuk scrolling, dan segi tiga untuk terapung. Mengklik tanda itu turut mengitar susun atur, begitu juga kekunci paparan pada komputer riba yang mempunyainya.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pilihan ini mengikut ruang kerja, dan ia kekal. Jadi anda boleh mengekalkan ruang kerja 1 pada dwindle untuk pelayaran dan ruang kerja 2 pada scrolling untuk kod, dan ruang kerja itu akan kembali begitu selepas dimulakan semula.

Jika anda mahu menggunakan susun atur scrolling sebagai lalai, anda boleh tetapkannya dalam `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Ruang kerja terapung

Ruang kerja terapung berfungsi seperti desktop tradisional: tetingkap bertindih, dan anda mengalih serta mengubah saiznya sendiri. Setiap tetingkap mendapat bar tajuk dalam warna tema anda, dengan butang untuk meminimumkan, memaksimumkan, dan menutup. `Super + M` turut meminimumkan tetingkap yang difokuskan. Tetingkap yang diminimumkan menunggu dalam dok; klik aplikasinya untuk membawanya kembali. Klik tetingkap untuk membawanya ke hadapan. Ubah saiznya dari mana-mana tepi atau sudut. Klik dua kali bar tajuk untuk memaksimumkan tetingkap sambil mengekalkan bar atas dalam pandangan, dan klik dua kali lagi untuk mendapatkan kembali saiz lamanya. Chrome dan pelayar berasaskan Chromium lain, Disks dan Document Viewer melangkau bar tajuk dan menggunakan pengepala mereka sendiri; `Super + Alt + F` memaksimumkannya, dan `Super + M` meminimumkannya.

Ruang kerja terapung juga menunjukkan dok, dengan aplikasi yang anda pin, semua yang sedang berjalan, dan grid setiap aplikasi di sebalik butang aplikasi, yang `Super + Alt + Space` dan _Apps_ dalam menu Omarchy turut buka. Klik kanan aplikasi pada grid, atau tekan `Delete`, untuk menyahpasangnya. Klik aplikasi untuk membukanya, atau untuk membawa tetingkapnya ke hadapan; klik sekali lagi untuk mengitar tetingkapnya. Files hanya membawa kembali tetingkap dari ruang kerja yang sedang anda gunakan dan sebaliknya membuka tetingkap baharu, dan Terminal dan Agent sentiasa memulakan yang lain, walaupun tetingkap yang diminimumkan akan kembali dahulu. Klik tengah membuka tetingkap baharu. Seret ikon di sepanjang dok untuk mengalihkannya; menyeret aplikasi yang sedang berjalan masuk di antara aplikasi lain akan mengekalkannya di situ. Klik kanan untuk mengekalkan aplikasi dalam dok, mengeluarkannya, atau menutupnya. Dok menyingkir daripada laluan tetingkap skrin penuh. Klik kanan butang aplikasi untuk mengalihkan dok ke tepi lain atau menyuruhnya bersembunyi sehingga penuding mencapai tepinya. Kedudukan itu juga berada di bawah _Appearance > Dock > Dock Position_, dan `omarchy dock position left` dan `omarchy dock autohide on` menetapkan kedua-duanya dari terminal. Aplikasi yang anda kekalkan dalam dok menjadi pudar semasa ia tidak berjalan.

Ruang kerja baharu, dan mana-mana ruang kerja yang belum anda berikan susun aturnya sendiri dengan `Super + L`, menggunakan susun atur lalai. Menukar lalai menetapkan semula setiap ruang kerja tanpa tetingkap kepadanya, manakala ruang kerja yang mempunyai tetingkap mengekalkan susun atur yang dimilikinya. Tetingkap yang diminimumkan ke dok masih dikira sebagai tetingkap pada ruang kerja yang ditinggalkannya. Pilihnya di bawah _Appearance > Workspace Layout_: Tiling, Scrolling, atau Floating. `omarchy hyprland workspace layout default scrolling` menetapkannya dari terminal.

### Mengumpulkan tetingkap

Tetingkap boleh dikumpulkan menggunakan `Super + G`. Sebaik sahaja anda berada dalam kumpulan, setiap tetingkap yang anda mulakan semasa kumpulan itu aktif akan menjadi sebahagian daripada kumpulan itu. Anda boleh bergerak antara tetingkap terkumpul ini menggunakan `Super + Ctrl + Arrow Left/Right` atau `Super + Alt + 1/2/3/4` untuk pergi terus ke tetingkap terkumpul mengikut susunan.

Anda boleh mengalihkan tetingkap keluar daripada kumpulan dengan `Super + Alt + G` atau membongkar seluruh kumpulan dengan menekan `Super + G` sekali lagi. Akhir sekali, anda boleh mengalihkan tetingkap di luar kumpulan masuk ke dalamnya dengan `Super + Alt + Arrows`.

### Mengeluarkan tetingkap

Anda boleh mengeluarkan tetingkap daripada peruntukan ruang kerjanya dengan `Super + O`. Itu akan meminnya sebagai tetingkap terapung yang mengikuti anda ke mana-mana ruang kerja yang anda pergi. Hebat untuk pemain video dan seumpamanya.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Ruang kerja scratchpad

Terdapat ruang kerja scratchpad khas bersaiz penuh yang menindih mana-mana ruang kerja yang sedang anda gunakan. Anda mengakses apa yang ada padanya menggunakan `Super + S`, dan anda meletakkan tetingkap di sana menggunakan `Super + Alt + S`.

Ia bagus untuk kawalan atau terminal yang anda mahu gunakan dengan cepat tanpa meninggalkan ruang kerja semasa.

### Konsol Quake

Akhir sekali, terdapat konsol Quake setinggi separuh yang jatuh ke bawah menindih mana-mana ruang kerja yang sedang anda gunakan. Togolnya dengan `Super + the key above Tab` (grave pada susun atur AS), dan letakkan tetingkap di sana menggunakan `Super + Shift + the key above Tab`.

Kali pertama ia dibuka, ia memulakan agent lalai anda, atau meminta anda memilih satu jika anda belum memilihnya. Semasa konsol itu memegang satu tetingkap, ia jatuh sebagai panel berpusat dan bukannya merentangi skrin. Letakkan aplikasi kedua padanya dan ia kembali kepada lebar penuh, supaya kedua-duanya mempunyai ruang untuk duduk bersebelahan.

Untuk mengalihkan tetingkap keluar sama ada daripada scratchpad atau konsol, hantarkannya terus ke ruang kerja lain dengan sesuatu seperti `Super + Shift + 1`.

### Memang ambil masa untuk membiasakan diri!

Memang ambil sedikit masa untuk membiasakan diri menavigasi desktop anda seperti ini, tetapi sebaik sahaja anda biasa, sukar untuk kembali kepada pengalaman desktop tradisional yang dipacu tetikus!
