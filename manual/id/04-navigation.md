# Navigasi

Semua hal di Omarchy dilakukan lewat keyboard — _SEMUA!_ Ketika sistem pertama kali menyala, kamu benar-benar tidak bisa melakukan apa pun hanya dengan mouse. Tapi kamu bisa menekan `Super + Space` untuk memunculkan Menu Omarchy dan dari sini kamu bisa melakukan hampir semua hal.

Namun menu Omarchy bahkan tidak dimaksudkan sebagai cara utama mengoperasikan sistem di sebagian besar waktu. Kita bisa lebih cepat dari itu! Semua aplikasi terpenting terikat langsung ke hotkey tersendiri. Kamu membuka terminal dengan `Super + Return` dan browser dengan `Super + Shift + Return`. Coba lakukan satu demi satu, dan kamu akan melihat keajaiban tiling Hyprland bekerja:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Kamu lalu bisa menekan `Super + J` untuk menumpuknya satu di atas yang lain, bukan berdampingan:

 ![navigation-stacked](images/navigation-stacked.webp)

Tekan `Super + J` lagi untuk mengembalikannya ke posisi berdampingan. Lalu coba `Super + Shift + Arrow Right` saat berada di browser untuk menukar jendelanya.

Sekarang coba `Super + Shift + T` untuk membuka monitor Activity. Itu akan muncul sebagai jendela floating, dengan titlebar untuk menyeretnya dan tombol untuk meminimalkan, memaksimalkan, dan menutupnya. Setiap jendela floating mendapatkannya, di mana pun jendela itu berada. Kamu bisa mengubahnya menjadi tiling menggunakan `Super + T` (dan tekan lagi untuk membuatnya floating lagi). Sekarang tekan `Super + Shift + F` untuk membuka file manager. Kamu akan mendapatkan susunan empat arah yang rapi:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Kamu berpindah di antara jendela yang ingin kamu aktifkan dengan `Super + Arrow`. Ini akan memindahkan fokus dan menggerakkan kursor ke tengah aplikasi baru. Di tepi layar, perpindahan berlanjut ke monitor di sisi tersebut.

Jika kamu menekan `Super + Shift + 2`, kamu akan memindahkan aplikasi yang sedang terfokus ke workspace kedua. `Super + Shift + 1` memindahkannya kembali. (Dan `Super + Shift + Alt + 2` akan memindahkan aplikasi yang sedang terfokus ke workspace kedua tanpa berpindah ke sana).

Dengan lebih dari satu monitor, setiap monitor memiliki workspace 1 sampai 10 sendiri-sendiri. `Super + 2` menuju ke workspace kedua pada monitor tempat kamu berada, dan bilah atas setiap monitor menampilkan workspace miliknya sendiri dan workspace yang sedang ditampilkannya. `Super + Tab` berpindah bergiliran di antara workspace pada monitor tempat kamu berada. `Super + Shift + Ctrl + Arrows` memindahkan jendela tempat kamu berada ke monitor ke arah tersebut, ke workspace yang sedang ditampilkannya, dan `Super + Shift + Alt + Arrows` memindahkan workspace tempat kamu berada ke monitor ke arah tersebut, di mana workspace itu mengambil nomor yang sama jika nomor tersebut kosong. Sebuah monitor mempertahankan workspace-nya ketika kamu mencabutnya: workspace-workspace itu bergabung ke layar lain, diberi nomor setelah nomor yang sudah ada di sana, dan kembali menggunakan nomor lamanya ketika monitor tersebut kembali.

Jika kamu menahan `Super` dan menggunakan mouse untuk mengklik sebuah jendela, kamu bisa mengatur ulang letaknya. Jika kamu menahan `Super` dan menggunakan tombol kanan pada mouse, kamu bisa mengubah ukuran jendela dengan bebas.

Kamu menutup jendela dengan `Super + W` atau `Super + Q` (dan menutup semua jendela dengan `Ctrl + Alt + Delete`).

Kamu juga bisa masuk ke layar penuh dengan `Super + F` atau bahkan hanya selebar layar penuh (dengan tetap mempertahankan bilah atas) dengan `Super + Alt + F` atau layar penuh di dalam sebuah jendela dengan `Super + Ctrl + F` (bagus untuk YouTube!).

### Layout dwindle vs scrolling

Layout default Omarchy disebut dwindle. Layout ini membuat semua jendela yang kamu buka pada satu workspace tetap terlihat setiap saat, bahkan jika harus mengecilkan ukurannya.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Namun kamu juga bisa memilih untuk mengubah sebuah workspace ke layout scrolling di mana jendela berjajar berdampingan, melampaui tepi layar yang terlihat. Kamu mengubah satu workspace ke layout ini melalui `Super + L`.

Menekan `Super + L` lagi mengubah workspace tersebut menjadi floating, di mana jendela saling tumpang tindih dengan bebas dan kamu menempatkannya sendiri, dan penekanan ketiga mengembalikannya ke dwindle. `Super + Alt + L` melewatinya ke arah sebaliknya. Jendela yang memang floating — jendela yang kamu keluarkan dengan `Super + T`, atau aplikasi yang selalu terbuka dalam keadaan floating — tetap floating ketika workspace kembali ke tiling. Bilah atas menandai workspace tempat kamu berada dengan layout-nya: persegi untuk dwindle, lingkaran untuk scrolling, dan segitiga untuk floating. Mengklik tanda tersebut juga mengganti layout secara bergiliran, begitu pula tombol display pada laptop yang memilikinya.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pilihan ini berlaku per workspace, dan pilihan itu tetap dipertahankan. Jadi kamu bisa mempertahankan workspace 1 pada dwindle untuk browsing dan workspace 2 pada scrolling untuk kode, dan keduanya akan kembali seperti itu setelah restart.

Jika kamu ingin menggunakan layout scrolling sebagai default, kamu bisa mengaturnya di `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Workspace floating

Workspace floating bekerja seperti desktop tradisional: jendela saling tumpang tindih, dan kamu memindahkan serta mengatur ukurannya sendiri. Setiap jendela mendapatkan titlebar dengan warna tema kamu, dengan tombol untuk meminimalkan, memaksimalkan, dan menutup. `Super + M` juga meminimalkan jendela yang terfokus. Jendela yang diminimalkan menunggu di dock; klik aplikasinya untuk membawanya kembali. Klik sebuah jendela untuk membawanya ke depan. Ubah ukurannya dari tepi atau sudut mana pun. Klik dua kali titlebar untuk memaksimalkan jendela sambil tetap mempertahankan bilah atas tetap terlihat, dan klik dua kali lagi untuk mendapatkan kembali ukuran lamanya. Chrome dan browser berbasis Chromium lainnya, Disks dan Document Viewer melewati titlebar dan menggunakan header mereka sendiri sebagai gantinya; `Super + Alt + F` memaksimalkannya, dan `Super + M` meminimalkannya.

Setiap workspace memiliki dock, dengan aplikasi yang kamu sematkan, semua yang sedang berjalan, dan grid semua aplikasi di balik tombol apps, yang juga dibuka oleh `Super + Alt + Space` dan _Apps_ di menu Omarchy. Klik kanan sebuah aplikasi pada grid, atau tekan `Delete`, untuk menghapus instalasinya. Klik sebuah aplikasi untuk membukanya, atau untuk membawa jendelanya ke depan; klik lagi untuk berpindah bergiliran di antara jendelanya. Files hanya membawa kembali jendela dari workspace tempat kamu berada dan jika tidak ada akan membuka jendela baru, dan Terminal dan Agent selalu memulai yang lain, meskipun jendela yang diminimalkan akan kembali lebih dulu. Klik tengah membuka jendela baru. Seret ikon di sepanjang dock untuk memindahkannya; menyeret aplikasi yang sedang berjalan ke antara yang lain akan mempertahankannya di sana. Klik kanan untuk mempertahankan aplikasi di dock, mengeluarkannya, atau menutupnya. Dock tetap terlihat selama workspace kosong, dan begitu workspace memiliki jendela, dock bersembunyi sampai penunjuk mencapai tepinya. Jendela layar penuh menyembunyikannya sepenuhnya. Seret tombol apps ke arah tepi layar lain untuk memindahkan dock ke sana. Klik kanan tombol itu untuk _Position_, untuk memilih tepi, _Layout_, untuk mengatur layout default sebagaimana dilakukan _Appearance > Workspace Layout_, dan _Visibility_, untuk membuat dock selalu aktif, membuat aplikasi pertama menyembunyikannya, atau membuatnya selalu tersembunyi. `omarchy dock visibility always` mengatur itu dari terminal. Posisi juga berada di bawah _Appearance > Dock > Dock Position_, dan `omarchy dock position left` mengaturnya dari terminal. Aplikasi yang kamu pertahankan di dock memudar selama tidak berjalan. Untuk membatasi dock hanya pada workspace floating, gunakan _Appearance > Dock > Dock Only on Floating_ atau `omarchy dock tiling off`.

Workspace baru, dan workspace mana pun yang belum kamu beri layout sendiri dengan `Super + L`, menggunakan layout default. Mengubah default mengatur ulang setiap workspace tanpa jendela ke layout tersebut, sementara workspace yang memiliki jendela tetap mempertahankan layout yang dimilikinya. Jendela yang diminimalkan ke dock tetap dihitung sebagai jendela pada workspace yang ditinggalkannya. Pilih layout itu di bawah _Appearance > Workspace Layout_: Tiling, Scrolling, atau Floating. `omarchy hyprland workspace layout default scrolling` mengaturnya dari terminal.

### Mengelompokkan jendela

Jendela bisa dikelompokkan menggunakan `Super + G`. Begitu kamu berada dalam sebuah grup, setiap jendela yang kamu buka selama grup itu aktif akan menjadi bagian dari grup tersebut. Kamu bisa berpindah di antara jendela-jendela yang dikelompokkan ini menggunakan `Super + Ctrl + Arrow Left/Right` atau `Super + Alt + 1/2/3/4` untuk langsung menuju jendela yang dikelompokkan secara berurutan.

Kamu bisa memindahkan jendela keluar dari grup dengan `Super + Alt + G` atau membongkar seluruh grup dengan menekan `Super + G` lagi. Terakhir, kamu bisa memindahkan jendela di luar grup ke dalamnya dengan `Super + Alt + Arrows`.

### Mengeluarkan jendela

Kamu bisa mengeluarkan jendela dari alokasi workspace-nya dengan `Super + O`. Itu akan menyematkannya sebagai jendela floating yang mengikuti kamu ke workspace mana pun kamu pergi. Hebat untuk pemutar video dan sejenisnya.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Workspace scratchpad

Ada workspace scratchpad khusus berukuran penuh yang melapisi workspace apa pun yang sedang kamu gunakan. Kamu mengakses apa yang ada di dalamnya menggunakan `Super + S`, dan kamu menempatkan jendela di sana menggunakan `Super + Alt + S`.

Ini bekerja dengan baik untuk kontrol atau terminal yang ingin kamu gunakan dengan cepat tanpa meninggalkan workspace saat ini.

### Konsol Quake

Terakhir, ada konsol Quake setengah tinggi yang muncul turun melapisi workspace apa pun yang sedang kamu gunakan. Aktif/nonaktifkan dengan `Super + the key above Tab` (grave pada layout US), dan tempatkan jendela di sana menggunakan `Super + Shift + the key above Tab`.

Pertama kali dibuka, konsol ini memulai agent default kamu, atau meminta kamu memilih satu jika kamu belum memilihnya. Selama konsol hanya berisi satu jendela, konsol ini muncul turun sebagai panel di tengah, bukan membentang di seluruh layar. Taruh aplikasi kedua di sana dan konsol ini kembali ke lebar penuh, sehingga keduanya memiliki ruang untuk duduk berdampingan.

Untuk memindahkan jendela dari scratchpad atau konsol, kirim langsung ke workspace lain dengan sesuatu seperti `Super + Shift + 1`.

### Butuh sedikit pembiasaan!

Butuh sedikit waktu untuk terbiasa menavigasi desktop kamu seperti ini, tetapi begitu kamu terbiasa, akan sulit untuk kembali ke pengalaman desktop tradisional yang digerakkan mouse!
