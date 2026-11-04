# Navigasi

Semua hal di Omarchy terjadi lewat keyboard — _SEMUA!_ Saat sistem pertama kali menyala, kamu benar-benar tidak bisa melakukan apa pun hanya dengan mouse. Tapi kamu bisa menekan `Super + Space` untuk memunculkan Menu Omarchy dan dari sini kamu bisa melakukan hampir segalanya.

Tapi menu Omarchy bahkan tidak dimaksudkan menjadi cara utama mengoperasikan sistem sebagian besar waktu. Kita bisa lebih cepat dari itu! Semua aplikasi terpenting terikat langsung ke hotkey masing-masing. Kamu membuka terminal dengan `Super + Return` dan browser dengan `Super + Shift + Return`. Coba lakukan satu demi satu, dan kamu akan melihat keajaiban tiling Hyprland beraksi:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Kemudian kamu bisa menekan `Super + J` untuk menumpuknya satu di atas yang lain alih-alih berdampingan:

 ![navigation-stacked](images/navigation-stacked.webp)

Tekan `Super + J` lagi untuk mengembalikannya ke posisi berdampingan. Lalu coba `Super + Shift + Arrow Right` saat berada di browser untuk menukar jendela.

Sekarang coba `Super + Shift + T` untuk membuka monitor Activity. Itu akan muncul sebagai jendela melayang. Kamu bisa menjadikannya tiling menggunakan `Super + T` (dan tekan itu lagi untuk menjadikannya melayang lagi). Sekarang tekan `Super + Shift + F` untuk membuka pengelola file. Kamu akan mendapatkan susunan empat arah yang rapi:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Kamu bernavigasi ke jendela yang ingin kamu aktifkan dengan `Super + Arrow`. Ini akan memindahkan fokus dan menggerakkan kursor ke tengah aplikasi baru. Di tepi sebuah layar, ini berlanjut ke monitor di sisi tersebut.

Jika kamu menekan `Super + Shift + 2`, kamu akan memindahkan aplikasi yang sedang difokuskan ke workspace kedua. `Super + Shift + 1` memindahkannya kembali. (Dan `Super + Shift + Alt + 2` akan memindahkan aplikasi yang sedang difokuskan ke workspace kedua tanpa beralih ke sana).

Dengan lebih dari satu monitor, setiap monitor memiliki workspace 1 sampai 10 sendiri. `Super + 2` pergi ke workspace kedua dari monitor tempat kamu berada, dan bilah atas setiap monitor menampilkan workspace-nya sendiri dan workspace yang sedang ditampilkannya. `Super + Tab` berputar melalui workspace di monitor tempat kamu berada. `Super + Shift + Ctrl + Arrows` memindahkan jendela tempat kamu berada ke monitor ke arah tersebut, ke workspace yang sedang ditampilkannya, dan `Super + Shift + Alt + Arrows` memindahkan workspace tempat kamu berada ke monitor ke arah tersebut, di mana workspace itu mengambil nomor yang sama jika kosong. Sebuah monitor mempertahankan workspace-nya saat kamu mencabutnya: workspace-workspace itu bergabung dengan workspace milik layar lain, diberi nomor setelah nomor yang sudah dimilikinya, dan kembali dengan nomor lamanya saat monitor kembali.

Jika kamu menahan `Super` dan menggunakan mouse untuk mengklik sebuah jendela, kamu bisa mengatur ulang posisinya. Jika kamu menahan `Super` dan menggunakan tombol kanan mouse, kamu bisa mengubah ukuran jendela dengan bebas.

Kamu menutup jendela dengan `Super + W` atau `Super + Q` (dan menutup semua jendela dengan `Ctrl + Alt + Delete`).

Kamu juga bisa masuk layar penuh dengan `Super + F` atau bahkan hanya selebar layar penuh (dengan tetap mempertahankan bilah atas) dengan `Super + Alt + F` atau layar penuh di dalam sebuah jendela dengan `Super + Ctrl + F` (bagus untuk YouTube!).

### Dwindle vs tata letak scrolling

Tata letak default Omarchy disebut dwindle. Tata letak ini membuat semua jendela yang kamu buka di satu workspace tetap terlihat setiap saat, bahkan jika harus mengecilkannya.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Tapi kamu juga bisa memilih mengubah sebuah workspace menjadi tata letak scrolling di mana jendela-jendela berjajar berdampingan, melampaui tepi layar yang terlihat. Kamu mengubah satu workspace menjadi tata letak ini melalui `Super + L`.

Menekan `Super + L` lagi mengubah workspace menjadi melayang, di mana jendela-jendela tumpang tindih dengan bebas dan kamu menempatkannya sendiri, dan penekanan ketiga mengembalikannya ke dwindle. `Super + Alt + L` melewatinya ke arah sebaliknya. Sebuah jendela yang memang melayang — jendela yang kamu keluarkan dengan `Super + T`, atau aplikasi yang selalu terbuka melayang — tetap melayang saat workspace kembali ke tiling. Bilah atas menandai workspace tempat kamu berada dengan tata letaknya: persegi untuk dwindle, lingkaran untuk scrolling, dan segitiga untuk melayang. Mengklik tanda itu juga mengganti tata letak secara berurutan.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pilihannya per workspace, dan tetap tersimpan. Jadi kamu bisa mempertahankan workspace 1 di dwindle untuk browsing dan workspace 2 di scrolling untuk coding, dan keduanya akan kembali seperti itu setelah restart.

Jika kamu ingin menggunakan tata letak scrolling sebagai default, kamu bisa mengaturnya di `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Workspace melayang

Workspace melayang bekerja seperti desktop tradisional: jendela-jendela tumpang tindih, dan kamu memindahkan serta mengatur ukurannya sendiri. Setiap jendela mendapatkan titlebar dengan warna tema kamu, dengan tombol untuk meminimalkan, memaksimalkan, dan menutup. `Super + M` juga meminimalkan jendela yang difokuskan. Jendela yang diminimalkan menunggu di dock; klik aplikasinya untuk membawanya kembali. Klik sebuah jendela untuk membawanya ke depan. Ubah ukurannya dari tepi atau sudut mana pun. Klik dua kali titlebar untuk memaksimalkan jendela sambil tetap menampilkan bilah atas, dan klik dua kali lagi untuk mendapatkan kembali ukuran lamanya.

Workspace melayang juga menampilkan dock, dengan aplikasi yang kamu sematkan, semua yang sedang berjalan, dan grid semua aplikasi di balik tombol aplikasi, yang juga dibuka oleh `Super + Alt + Space` dan _Apps_ di menu Omarchy. Klik kanan sebuah aplikasi di grid, atau tekan `Delete`, untuk mencopot pemasangannya. Klik sebuah aplikasi untuk membukanya, atau untuk membawa jendelanya ke depan; klik lagi untuk berputar melalui jendela-jendelanya. Klik tengah membuka jendela baru. Seret ikon di sepanjang dock untuk memindahkannya; menyeret aplikasi yang sedang berjalan ke antara yang lain akan mempertahankannya di sana. Klik kanan untuk mempertahankan aplikasi di dock, mengeluarkannya, atau menutupnya. Dock menyingkir dari jendela layar penuh. Klik kanan tombol aplikasi untuk memindahkan dock ke tepi lain atau membuatnya bersembunyi sampai pointer mencapai tepinya. Posisinya juga ada di bawah _Appearance > Dock > Dock Position_, dan `omarchy dock position left` serta `omarchy dock autohide on` mengatur keduanya dari terminal. Aplikasi yang kamu pertahankan di dock tampil pudar saat tidak berjalan.

Workspace baru, dan workspace mana pun yang belum kamu beri tata letak sendiri dengan `Super + L`, menggunakan tata letak default. Mengubah default akan mengatur ulang setiap workspace tanpa jendela ke tata letak tersebut, sementara workspace yang memiliki jendela tetap mempertahankan tata letak yang dimilikinya. Jendela yang diminimalkan ke dock tetap dihitung sebagai jendela di workspace yang ditinggalkannya. Pilih di bawah _Appearance > Workspace Layout_: Tiling, Scrolling, atau Floating. `omarchy-hyprland-workspace-layout-default scrolling` mengaturnya dari terminal.

### Mengelompokkan jendela

Jendela bisa dikelompokkan menggunakan `Super + G`. Begitu kamu berada dalam sebuah grup, setiap jendela yang kamu buka saat grup itu aktif akan menjadi milik grup tersebut. Kamu bisa berpindah di antara jendela-jendela yang dikelompokkan ini menggunakan `Super + Ctrl + Arrow Left/Right` atau `Super + Alt + 1/2/3/4` untuk pergi langsung ke jendela yang dikelompokkan secara berurutan.

Kamu bisa memindahkan jendela keluar dari pengelompokan dengan `Super + Alt + G` atau membongkar seluruh grup dengan menekan `Super + G` lagi. Terakhir, kamu bisa memindahkan jendela di luar grup ke dalamnya dengan `Super + Alt + Arrows`.

### Mengeluarkan jendela

Kamu bisa mengeluarkan sebuah jendela dari alokasi workspace-nya dengan `Super + O`. Itu akan menyematkannya sebagai jendela melayang yang mengikutimu ke workspace mana pun yang kamu tuju. Bagus untuk pemutar video dan sejenisnya.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Workspace scratchpad

Ada workspace scratchpad khusus berukuran penuh yang menutupi workspace apa pun yang sedang kamu gunakan. Kamu mengakses apa yang ada di sana menggunakan `Super + S`, dan kamu menempatkan jendela di sana menggunakan `Super + Alt + S`.

Ini bekerja dengan baik untuk kontrol atau terminal yang ingin kamu gunakan dengan cepat tanpa meninggalkan workspace saat ini.

### Konsol Quake

Terakhir, ada konsol Quake setengah tinggi yang muncul turun menutupi workspace apa pun yang sedang kamu gunakan. Aktif/nonaktifkan dengan `Super + Grave`, dan tempatkan jendela di sana menggunakan `Super + Shift + Grave`.

Konsol ini terbuka dengan agent default kamu siap digunakan. Saat konsol hanya berisi satu jendela, konsol muncul turun sebagai panel di tengah alih-alih membentang selebar layar. Taruh aplikasi kedua di sana dan konsol kembali selebar penuh, sehingga keduanya punya ruang untuk berdampingan.

Untuk memindahkan jendela keluar dari scratchpad atau konsol, kirim langsung ke workspace lain dengan sesuatu seperti `Super + Shift + 1`.

### Perlu sedikit membiasakan diri!

Butuh sedikit waktu untuk terbiasa menavigasi desktop kamu seperti ini, tapi begitu terbiasa, akan sulit untuk kembali ke pengalaman desktop tradisional yang digerakkan mouse!
