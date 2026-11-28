# Navigasi

Segala sesuatu di Omarchy terjadi lewat keyboard — _SEMUANYA!_ Saat sistem pertama kali menyala, kamu benar-benar tidak bisa melakukan apa pun hanya dengan mouse. Tapi kamu bisa menekan `Super + Space` untuk memunculkan Omarchy Menu, dan dari sini kamu bisa melakukan hampir segala hal.

Tapi Omarchy menu bahkan tidak dimaksudkan menjadi cara utama untuk mengoperasikan sistem di sebagian besar waktu. Kita bisa lebih cepat dari itu! Semua aplikasi terpenting terikat langsung ke hotkey tersendiri. Kamu membuka terminal dengan `Super + Return` dan browser dengan `Super + Shift + Return`. Coba lakukan satu demi satu, dan kamu akan melihat keajaiban tiling Hyprland bekerja:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Lalu kamu bisa menekan `Super + J` untuk menumpuknya satu di atas yang lain, bukan berdampingan:

 ![navigation-stacked](images/navigation-stacked.webp)

Tekan `Super + J` lagi untuk mengembalikannya ke posisi berdampingan. Lalu coba `Super + Shift + Arrow Right` saat berada di browser untuk menukar jendelanya.

Sekarang coba `Super + Shift + T` untuk membuka monitor Activity. Itu akan muncul sebagai jendela mengambang, dengan titlebar untuk menyeretnya dan tombol untuk meminimalkan, memaksimalkan, dan menutupnya. Setiap jendela mengambang mendapatkannya, di mana pun ia berada. Kamu bisa men-tiling-nya menggunakan `Super + T` (dan tekan itu lagi untuk membuatnya mengambang lagi). Sekarang tekan `Super + Shift + F` untuk membuka file manager. Kamu akan mendapatkan susunan empat arah yang rapi:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Kamu berpindah di antara jendela yang ingin kamu aktifkan dengan `Super + Arrow`. Ini akan memindahkan fokus dan menggerakkan kursor ke tengah aplikasi baru. Di tepi layar, ini berlanjut ke monitor di sisi tersebut.

Jika kamu menekan `Super + Shift + 2`, kamu akan memindahkan aplikasi yang sedang terfokus ke workspace kedua. `Super + Shift + 1` memindahkannya kembali. (Dan `Super + Shift + Alt + 2` akan memindahkan aplikasi yang sedang terfokus ke workspace kedua tanpa berpindah ke sana).

Dengan lebih dari satu monitor, setiap monitor memiliki workspace 1 sampai 10 sendiri. `Super + 2` menuju ke workspace kedua dari monitor tempatmu berada, dan top bar setiap monitor menampilkan workspace miliknya sendiri dan workspace yang sedang ditampilkannya. `Super + Tab` berputar melalui workspace di monitor tempatmu berada. `Super + Shift + Ctrl + Arrows` memindahkan jendela tempatmu berada ke monitor ke arah tersebut, ke workspace yang sedang ditampilkannya, dan `Super + Shift + Alt + Arrows` memindahkan workspace tempatmu berada ke monitor ke arah tersebut, di mana ia mengambil nomor yang sama jika nomor itu kosong. Sebuah monitor mempertahankan workspace-nya saat kamu mencabutnya: workspace-workspace itu bergabung dengan workspace layar lain, diberi nomor setelah workspace yang sudah dimilikinya, dan kembali dengan nomor lamanya saat monitor itu kembali.

Jika kamu menahan `Super` dan menggunakan mouse untuk mengklik sebuah jendela, kamu akan bisa mengatur ulang tempatnya. Jika kamu menahan `Super` dan menggunakan tombol kanan pada mouse, kamu bisa mengubah ukuran jendela dengan bebas.

Kamu menutup jendela dengan `Super + W` atau `Super + Q` (dan menutup semua jendela dengan `Ctrl + Alt + Delete`).

Kamu juga bisa masuk ke layar penuh dengan `Super + F` atau bahkan hanya selebar layar penuh (dengan tetap mempertahankan top bar) dengan `Super + Alt + F` atau layar penuh di dalam sebuah jendela dengan `Super + Ctrl + F` (bagus untuk YouTube!).

### Dwindle vs tata letak scrolling

Tata letak default Omarchy disebut dwindle. Tata letak ini menjaga semua jendela yang kamu buka di satu workspace tetap terlihat setiap saat, bahkan jika ia harus mengecilkannya.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Tapi kamu juga bisa memilih untuk mengubah sebuah workspace menjadi tata letak scrolling, di mana jendela-jendela berjajar berdampingan, melampaui tepi layar yang terlihat. Kamu mengubah satu workspace menjadi tata letak ini melalui `Super + L`.

Menekan `Super + L` lagi mengubah workspace menjadi mengambang, di mana jendela-jendela saling tumpang tindih dengan bebas dan kamu menempatkannya sendiri, dan tekanan ketiga mengembalikannya ke dwindle. `Super + Alt + L` melewatinya ke arah sebaliknya. Jendela yang memang mengambang — yang kamu lepaskan dengan `Super + T`, atau aplikasi yang selalu terbuka mengambang — tetap mengambang saat workspace kembali ke tiling. Top bar menandai workspace tempatmu berada dengan tata letaknya: persegi untuk dwindle, lingkaran untuk scrolling, dan segitiga untuk mengambang. Mengklik tanda itu juga memutar tata letaknya, begitu pula tombol display pada laptop yang memilikinya.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pilihannya berlaku per workspace, dan tetap bertahan. Jadi kamu bisa mempertahankan workspace 1 pada dwindle untuk browsing dan workspace 2 pada scrolling untuk kode, dan keduanya akan kembali seperti itu setelah restart.

Jika kamu ingin menggunakan tata letak scrolling sebagai default, kamu bisa mengaturnya di `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Workspace mengambang

Workspace mengambang bekerja seperti desktop tradisional: jendela-jendela saling tumpang tindih, dan kamu memindahkan serta mengatur ukurannya sendiri. Setiap jendela mendapatkan titlebar dengan warna tema milikmu, dengan tombol untuk meminimalkan, memaksimalkan, dan menutup. `Super + M` juga meminimalkan jendela yang terfokus. Jendela yang diminimalkan menunggu di dock; klik aplikasinya untuk membawanya kembali. Klik sebuah jendela untuk membawanya ke depan. Ubah ukurannya dari tepi atau sudut mana pun. Klik dua kali titlebar untuk memaksimalkan jendela sambil tetap menampilkan top bar, dan klik dua kali lagi untuk mendapatkan kembali ukuran lamanya. Chrome dan browser berbasis Chromium lainnya, Disks, dan Document Viewer melewatkan titlebar dan menggunakan header mereka sendiri sebagai gantinya; `Super + Alt + F` memaksimalkannya, dan `Super + M` meminimalkannya.

Setiap workspace memiliki dock, dengan aplikasi yang kamu sematkan, semua yang sedang berjalan, dan grid semua aplikasi di balik tombol apps, yang juga dibuka oleh `Super + Alt + Space` dan _Apps_ di Omarchy menu. Klik kanan aplikasi di grid, atau tekan `Delete`, untuk meng-uninstall-nya. Klik aplikasi untuk membukanya, atau untuk membawa jendelanya ke depan; klik lagi untuk berputar melalui jendela-jendelanya. Files hanya membawa kembali jendela dari workspace tempatmu berada dan selebihnya membuka jendela baru, dan Terminal dan Agent selalu membuka yang lain, meskipun jendela yang diminimalkan akan kembali lebih dulu. Klik tengah membuka jendela baru. Seret ikon di sepanjang dock untuk memindahkannya; menyeret aplikasi yang sedang berjalan ke antara aplikasi lain akan mempertahankannya di sana. Klik kanan untuk mempertahankan aplikasi di dock, mengeluarkannya, atau menutupnya. Dock tetap terlihat selama workspace kosong, dan setelah workspace memiliki jendela, dock bersembunyi hingga pointer mencapai tepinya. Jendela layar penuh menyembunyikannya sepenuhnya. Seret tombol apps ke arah tepi layar lain untuk memindahkan dock ke sana. Klik kanan tombol itu untuk _Position_, untuk memilih tepi, dan _Layout_, untuk mengatur tata letak default sebagaimana yang dilakukan _Appearance > Workspace Layout_. Posisinya juga berada di bawah _Appearance > Dock > Dock Position_, dan `omarchy dock position left` mengaturnya dari terminal. Aplikasi yang kamu pertahankan di dock tampak memudar selama aplikasi itu tidak berjalan. Untuk membatasi dock hanya pada workspace mengambang, gunakan _Appearance > Dock > Dock Only on Floating_ atau `omarchy dock tiling off`.

Workspace baru, dan workspace mana pun yang belum kamu beri tata letaknya sendiri dengan `Super + L`, menggunakan tata letak default. Mengubah default akan mengatur ulang setiap workspace tanpa jendela ke tata letak itu, sementara workspace yang memiliki jendela di dalamnya mempertahankan tata letak yang dimilikinya. Jendela yang diminimalkan ke dock tetap dihitung sebagai jendela di workspace yang ditinggalkannya. Pilih tata letak itu di bawah _Appearance > Workspace Layout_: Tiling, Scrolling, atau Floating. `omarchy hyprland workspace layout default scrolling` mengaturnya dari terminal.

### Mengelompokkan jendela

Jendela bisa dikelompokkan menggunakan `Super + G`. Setelah kamu berada dalam sebuah grup, setiap jendela yang kamu buka selama grup itu aktif akan menjadi bagian dari grup tersebut. Kamu bisa berpindah di antara jendela-jendela yang dikelompokkan ini menggunakan `Super + Ctrl + Arrow Left/Right` atau `Super + Alt + 1/2/3/4` untuk langsung menuju jendela yang dikelompokkan secara berurutan.

Kamu bisa memindahkan jendela keluar dari pengelompokan dengan `Super + Alt + G` atau membongkar seluruh grup dengan menekan `Super + G` lagi. Terakhir, kamu bisa memindahkan jendela di luar grup ke dalamnya dengan `Super + Alt + Arrows`.

### Melepaskan jendela

Kamu bisa melepaskan jendela dari alokasi workspace-nya dengan `Super + O`. Itu akan menyematkannya sebagai jendela mengambang yang mengikutimu ke workspace mana pun yang kamu tuju. Bagus untuk pemutar video dan sejenisnya.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Workspace scratchpad

Ada workspace scratchpad khusus berukuran penuh yang melapisi workspace mana pun yang sedang kamu gunakan. Kamu mengakses apa yang ada di dalamnya menggunakan `Super + S`, dan kamu menempatkan jendela di sana menggunakan `Super + Alt + S`.

Ini bekerja dengan baik untuk kontrol atau terminal yang ingin kamu gunakan dengan cepat tanpa meninggalkan workspace saat ini.

### Konsol Quake

Terakhir, ada konsol Quake setengah tinggi yang turun menutupi workspace mana pun yang sedang kamu gunakan. Aktif/nonaktifkan dengan `Super + the key above Tab` (grave pada layout US), dan tempatkan jendela di sana menggunakan `Super + Shift + the key above Tab`.

Pertama kali dibuka, konsol ini membuka agent default milikmu, atau memintamu memilihnya jika kamu belum memilihnya. Selama konsol menampung satu jendela, ia turun sebagai panel di tengah, bukan membentang selebar layar. Taruh aplikasi kedua di dalamnya dan ia kembali ke lebar penuh, sehingga keduanya memiliki ruang untuk duduk berdampingan.

Untuk memindahkan jendela dari scratchpad atau konsol, kirimkan langsung ke workspace lain dengan sesuatu seperti `Super + Shift + 1`.

### Perlu sedikit membiasakan diri!

Butuh sedikit waktu untuk membiasakan diri menavigasi desktop seperti ini, tetapi setelah kamu terbiasa, akan sulit untuk kembali ke pengalaman desktop tradisional yang digerakkan mouse!
