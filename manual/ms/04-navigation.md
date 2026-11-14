# Navigasi

Segala-galanya dalam Omarchy berlaku melalui papan kekunci — _SEGALA-GALANYA!_ Apabila sistem mula-mula dimulakan, anda benar-benar tidak boleh melakukan apa-apa dengan tetikus sahaja. Tetapi anda boleh tekan `Super + Space` untuk mendedahkan Omarchy Menu dan dari sini anda boleh lakukan hampir segala-galanya.

Tetapi menu Omarchy bahkan tidak dimaksudkan sebagai cara utama untuk mengendalikan sistem pada kebanyakan masa. Kita boleh lebih pantas daripada itu! Semua aplikasi paling penting terikat terus kepada kekunci pintas individu. Anda memulakan terminal dengan `Super + Return` dan pelayar dengan `Super + Shift + Return`. Cuba lakukan satu demi satu, dan anda akan melihat keajaiban penjubinan Hyprland beraksi:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Anda kemudian boleh tekan `Super + J` untuk menyusunnya di atas satu sama lain bukannya bersebelahan:

 ![navigation-stacked](images/navigation-stacked.webp)

Tekan `Super + J` sekali lagi untuk mengembalikannya ke kedudukan bersebelahan. Kemudian cuba `Super + Shift + Arrow Right` semasa dalam pelayar untuk menukar tetingkap.

Sekarang cuba `Super + Shift + T` untuk memulakan monitor Activity. Itu akan muncul sebagai tetingkap terapung. Anda boleh menjubinkannya menggunakan `Super + T` (dan tekan itu lagi untuk menjadikannya terapung semula). Sekarang tekan `Super + Shift + F` untuk membuka pengurus fail. Anda akan mempunyai susunan empat hala yang kemas:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Anda menavigasi antara tetingkap yang anda mahu aktifkan dengan `Super + Arrow`. Ini akan menukar fokus dan mengalihkan kursor ke tengah aplikasi baharu. Di pinggir skrin, ia berterusan ke monitor di sebelah itu.

Jika anda tekan `Super + Shift + 2`, anda akan mengalihkan aplikasi yang sedang difokuskan ke ruang kerja kedua. `Super + Shift + 1` mengembalikannya. (Dan `Super + Shift + Alt + 2` akan mengalihkan aplikasi yang sedang difokuskan ke ruang kerja kedua tanpa beralih kepadanya).

Dengan lebih daripada satu monitor, setiap monitor mempunyai ruang kerja 1 hingga 10 tersendiri. `Super + 2` pergi ke ruang kerja kedua monitor yang anda berada, dan bar atas setiap monitor menunjukkan ruang kerjanya sendiri dan ruang kerja yang sedang dipaparkannya. `Super + Tab` mengitar melalui ruang kerja pada monitor yang anda berada. `Super + Shift + Ctrl + Arrows` mengalihkan tetingkap yang anda berada ke monitor ke arah itu, ke ruang kerja yang sedang dipaparkannya, dan `Super + Shift + Alt + Arrows` mengalihkan ruang kerja yang anda berada ke monitor ke arah itu, di mana ia mengambil nombor yang sama jika ia kosong. Sesebuah monitor mengekalkan ruang kerjanya apabila anda mencabutnya: ruang kerja itu menyertai skrin lain, dinomborkan selepas ruang kerja yang sudah ada padanya, dan kembali dengan nombor lamanya apabila monitor itu kembali.

Jika anda menahan `Super` dan menggunakan tetikus untuk mengklik tetingkap, anda akan dapat menyusun semula kedudukannya. Jika anda menahan `Super` dan menggunakan butang kanan pada tetikus, anda boleh mengubah saiz tetingkap dengan bebas.

Anda menutup tetingkap dengan `Super + W` atau `Super + Q` (dan menutup semua tetingkap dengan `Ctrl + Alt + Delete`).

Anda juga boleh pergi ke skrin penuh dengan `Super + F` atau bahkan hanya lebar penuh (mengekalkan bar atas) dengan `Super + Alt + F` atau skrin penuh dalam tetingkap dengan `Super + Ctrl + F` (bagus untuk YouTube!).

### Susun atur dwindle lwn scrolling

Susun atur lalai Omarchy dipanggil dwindle. Ia mengekalkan semua tetingkap yang anda buka pada satu ruang kerja kelihatan pada setiap masa, walaupun ia terpaksa mengecilkannya.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Tetapi anda juga boleh memilih untuk menukar ruang kerja menjadi susun atur scrolling di mana tetingkap disusun bersebelahan, melangkaui pinggir paparan yang kelihatan. Anda menukar satu ruang kerja menjadi susun atur ini melalui `Super + L`.

Menekan `Super + L` sekali lagi menukar ruang kerja menjadi terapung, di mana tetingkap bertindih dengan bebas dan anda meletakkannya sendiri, dan tekanan ketiga mengembalikannya kepada dwindle. `Super + Alt + L` melaluinya ke arah sebaliknya. Tetingkap yang memang terapung — yang anda keluarkan dengan `Super + T`, atau aplikasi yang sentiasa dibuka secara terapung — kekal terapung apabila ruang kerja kembali kepada penjubinan. Bar atas menandakan ruang kerja yang anda berada dengan susun aturnya: segi empat sama untuk dwindle, bulatan untuk scrolling, dan segi tiga untuk terapung. Mengklik tanda itu juga mengitar susun atur.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pilihan adalah mengikut ruang kerja, dan ia kekal. Jadi anda boleh mengekalkan ruang kerja 1 pada dwindle untuk pelayaran dan ruang kerja 2 pada scrolling untuk kod, dan ia akan kembali seperti itu selepas dimulakan semula.

Jika anda ingin menggunakan susun atur scrolling sebagai lalai, anda boleh tetapkannya dalam `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Ruang kerja terapung

Ruang kerja terapung berfungsi seperti desktop tradisional: tetingkap bertindih, dan anda mengalih dan mengubah saiznya sendiri. Setiap tetingkap mendapat bar tajuk dalam warna tema anda, dengan butang untuk meminimumkan, memaksimumkan, dan menutup. `Super + M` meminimumkan tetingkap yang difokuskan juga. Tetingkap yang diminimumkan menunggu dalam dock; klik aplikasinya untuk membawanya kembali. Klik tetingkap untuk membawanya ke hadapan. Ubah saiznya dari mana-mana pinggir atau sudut. Dwiklik bar tajuk untuk memaksimumkan tetingkap sambil mengekalkan bar atas kelihatan, dan sekali lagi untuk mendapatkan saiz lamanya kembali. Chrome dan pelayar berasaskan Chromium lain, Disks dan Document Viewer melangkau bar tajuk dan menggunakan pengepala mereka sendiri sebaliknya; `Super + Alt + F` memaksimumkannya, dan `Super + M` meminimumkannya.

Ruang kerja terapung juga menunjukkan dock, dengan aplikasi yang anda pin, segala-galanya yang sedang berjalan, dan grid setiap aplikasi di sebalik butang aplikasi, yang `Super + Alt + Space` dan _Apps_ dalam menu Omarchy turut buka. Klik kanan aplikasi pada grid, atau tekan `Delete`, untuk menyahpasangnya. Klik aplikasi untuk membukanya, atau untuk membawa tetingkapnya ke hadapan; klik sekali lagi untuk mengitar melalui tetingkapnya. Klik tengah membuka tetingkap baharu. Seret ikon sepanjang dock untuk mengalihkannya; menyeret aplikasi yang sedang berjalan masuk antara aplikasi lain mengekalkannya di situ. Klik kanan untuk mengekalkan aplikasi dalam dock, mengeluarkannya, atau menutupnya. Dock mengelak daripada tetingkap skrin penuh. Klik kanan butang aplikasi untuk mengalihkan dock ke pinggir lain atau menyembunyikannya sehingga penunjuk mencapai pinggirnya. Kedudukan itu juga berada di bawah _Appearance > Dock > Dock Position_, dan `omarchy dock position left` dan `omarchy dock autohide on` menetapkan kedua-duanya dari terminal. Aplikasi yang anda kekalkan dalam dock dipudarkan semasa ia tidak berjalan.

Ruang kerja baharu, dan mana-mana yang anda belum berikan susun aturnya sendiri dengan `Super + L`, menggunakan susun atur lalai. Mengubah lalai menetapkan semula setiap ruang kerja tanpa tetingkap kepadanya, manakala ruang kerja yang mempunyai tetingkap di atasnya mengekalkan susun atur yang dimilikinya. Tetingkap yang diminimumkan ke dock masih dikira sebagai tetingkap pada ruang kerja yang ditinggalkannya. Pilihnya di bawah _Appearance > Workspace Layout_: Tiling, Scrolling, atau Floating. `omarchy-hyprland-workspace-layout-default scrolling` menetapkannya dari terminal.

### Mengumpulkan tetingkap

Tetingkap boleh dikumpulkan menggunakan `Super + G`. Sebaik sahaja anda berada dalam kumpulan, setiap tetingkap yang anda mulakan semasa itu aktif akan tergolong dalam kumpulan itu. Anda boleh bergerak antara tetingkap berkumpulan ini menggunakan `Super + Ctrl + Arrow Left/Right` atau `Super + Alt + 1/2/3/4` untuk pergi terus ke tetingkap berkumpulan mengikut urutan.

Anda boleh mengalihkan tetingkap keluar daripada kumpulan dengan `Super + Alt + G` atau membongkar keseluruhan kumpulan dengan menekan `Super + G` sekali lagi. Akhir sekali, anda boleh mengalihkan tetingkap di luar kumpulan masuk ke dalamnya dengan `Super + Alt + Arrows`.

### Mengeluarkan tetingkap

Anda boleh mengeluarkan tetingkap daripada peruntukan ruang kerjanya dengan `Super + O`. Itu akan meminnya sebagai tetingkap terapung yang mengikuti anda ke mana-mana ruang kerja yang anda pergi. Hebat untuk pemain video dan seumpamanya.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Ruang kerja scratchpad

Terdapat ruang kerja scratchpad bersaiz penuh khas yang menindih mana-mana ruang kerja yang anda sedang berada. Anda mengakses apa yang ada padanya menggunakan `Super + S`, dan anda meletakkan tetingkap di situ menggunakan `Super + Alt + S`.

Ia berfungsi dengan baik untuk kawalan atau terminal yang anda mahu berinteraksi dengan cepat tanpa meninggalkan ruang kerja semasa.

### Konsol Quake

Akhir sekali, terdapat konsol Quake separuh ketinggian yang jatuh ke bawah menindih mana-mana ruang kerja yang anda sedang berada. Togolnya dengan `Super + Grave`, dan letakkan tetingkap di situ menggunakan `Super + Shift + Grave`.

Ia dibuka dengan agent lalai anda sedia untuk digunakan. Semasa konsol menampung satu tetingkap, ia jatuh sebagai panel berpusat bukannya merentangi skrin. Letakkan aplikasi kedua padanya dan ia kembali kepada lebar penuh, supaya kedua-duanya mempunyai ruang untuk berada bersebelahan.

Untuk mengalihkan tetingkap keluar dari scratchpad atau konsol, hantarkannya terus ke ruang kerja lain dengan sesuatu seperti `Super + Shift + 1`.

### Ia memerlukan sedikit masa untuk membiasakan diri!

Ia mengambil sedikit masa untuk membiasakan diri menavigasi desktop anda seperti ini, tetapi sebaik sahaja anda melakukannya, ia akan sukar untuk kembali kepada pengalaman desktop berasaskan tetikus tradisional!
