# Navigasi

Semuanya di Omarchy terjadi lewat keyboard — _SEMUANYA!_ Saat sistem pertama kali menyala, kamu benar-benar tidak bisa melakukan apa pun hanya dengan mouse. Tapi kamu bisa menekan `Super + Space` untuk memunculkan Omarchy Menu dan dari sini kamu bisa melakukan hampir semuanya.

Tapi Omarchy menu bahkan tidak dimaksudkan sebagai cara utama untuk mengoperasikan sistem di sebagian besar waktu. Kita bisa lebih cepat dari itu! Semua aplikasi terpenting terikat langsung ke hotkey tersendiri. Kamu memulai terminal dengan `Super + Return` dan browser dengan `Super + Shift + Return`. Coba lakukan satu demi satu, dan kamu akan melihat keajaiban tiling Hyprland bekerja:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Kamu kemudian bisa menekan `Super + J` untuk menumpuknya satu di atas yang lain, bukan bersebelahan:

 ![navigation-stacked](images/navigation-stacked.webp)

Tekan `Super + J` lagi untuk mengembalikannya ke posisi bersebelahan. Kemudian coba `Super + Shift + Arrow Right` saat berada di browser untuk menukar jendela.

Sekarang coba `Super + Shift + T` untuk memulai Activity monitor. Itu akan muncul sebagai jendela mengambang. Kamu bisa men-tiling-nya menggunakan `Super + T` (dan tekan lagi untuk membuatnya mengambang kembali). Sekarang tekan `Super + Shift + F` untuk membuka file manager. Kamu akan mendapatkan pengaturan empat arah yang rapi:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Kamu menavigasi di antara jendela yang ingin kamu aktifkan dengan `Super + Arrow`. Ini akan memindahkan fokus dan memindahkan kursor ke tengah aplikasi baru. Di tepi layar, ini berlanjut ke monitor di sisi tersebut.

Jika kamu menekan `Super + Shift + 2`, kamu akan memindahkan aplikasi yang sedang fokus ke workspace kedua. `Super + Shift + 1` memindahkannya kembali. (Dan `Super + Shift + Alt + 2` akan memindahkan aplikasi yang sedang fokus ke workspace kedua tanpa beralih ke sana).

Dengan lebih dari satu monitor, setiap monitor memiliki workspace 1 sampai 10 miliknya sendiri. `Super + 2` pergi ke workspace kedua dari monitor yang sedang kamu gunakan, dan bilah atas setiap monitor menampilkan workspace miliknya sendiri dan yang sedang ditampilkannya. `Super + Tab` berputar melalui workspace di monitor yang sedang kamu gunakan. `Super + Shift + Ctrl + Arrows` memindahkan jendela yang sedang kamu gunakan ke monitor di arah tersebut, ke workspace yang sedang ditampilkannya, dan `Super + Shift + Alt + Arrows` memindahkan workspace yang sedang kamu gunakan ke monitor di arah tersebut, di mana ia mengambil nomor yang sama jika kosong. Sebuah monitor tetap mempertahankan workspace-nya saat kamu mencabutnya: workspace tersebut bergabung dengan milik layar lain, diberi nomor setelah yang sudah ada di sana, dan kembali dengan nomor lamanya saat monitor itu kembali.

Jika kamu menahan `Super` dan menggunakan mouse untuk mengklik sebuah jendela, kamu akan bisa mengatur ulang tempatnya. Jika kamu menahan `Super` dan menggunakan tombol kanan pada mouse, kamu bisa mengubah ukuran jendela dengan bebas.

Kamu menutup jendela dengan `Super + W` atau `Super + Q` (dan menutup semua jendela dengan `Ctrl + Alt + Delete`).

Kamu juga bisa masuk layar penuh dengan `Super + F` atau bahkan hanya selebar penuh (dengan tetap mempertahankan bilah atas) dengan `Super + Alt + F` atau layar penuh di dalam sebuah jendela dengan `Super + Ctrl + F` (bagus untuk YouTube!).

### Tata letak dwindle vs scrolling

Tata letak default Omarchy disebut dwindle. Tata letak ini membuat semua jendela yang kamu buka di satu workspace tetap terlihat sepanjang waktu, bahkan jika harus mengecilkannya.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Tapi kamu juga bisa memilih untuk mengubah sebuah workspace menjadi tata letak scrolling, di mana jendela berbaris bersebelahan, melampaui tepi layar yang terlihat. Kamu mengubah satu workspace menjadi tata letak ini melalui `Super + L`.

Menekan `Super + L` lagi mengubah workspace menjadi mengambang, di mana jendela tumpang tindih dengan bebas dan kamu menempatkannya sendiri, dan tekanan ketiga mengembalikannya ke dwindle. `Super + Alt + L` melewatinya ke arah sebaliknya. Jendela yang memang mengambang — yang kamu keluarkan dengan `Super + T`, atau aplikasi yang selalu terbuka mengambang — tetap mengambang saat workspace kembali ke tiling. Bilah atas menandai workspace yang sedang kamu gunakan dengan tata letaknya: persegi untuk dwindle, lingkaran untuk scrolling, dan segitiga untuk mengambang. Mengklik tanda itu juga mengganti tata letak, dan begitu juga tombol display pada laptop yang memilikinya.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pilihan ini berlaku per workspace, dan menetap. Jadi kamu bisa mempertahankan workspace 1 di dwindle untuk browsing dan workspace 2 di scrolling untuk kode, dan keduanya akan kembali seperti itu setelah restart.

Jika kamu ingin menggunakan tata letak scrolling sebagai default, kamu bisa mengaturnya di `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Workspace mengambang

Workspace mengambang bekerja seperti desktop tradisional: jendela tumpang tindih, dan kamu memindahkan serta mengubah ukurannya sendiri. Setiap jendela mendapatkan titlebar dengan warna tema kamu, dengan tombol untuk meminimalkan, memaksimalkan, dan menutup. `Super + M` juga meminimalkan jendela yang sedang fokus. Jendela yang diminimalkan menunggu di dock; klik aplikasinya untuk membawanya kembali. Klik sebuah jendela untuk membawanya ke depan. Ubah ukurannya dari tepi atau sudut mana pun. Klik dua kali titlebar untuk memaksimalkan jendela sambil tetap mempertahankan bilah atas terlihat, dan sekali lagi untuk mendapatkan ukuran lamanya kembali. Chrome dan browser berbasis Chromium lainnya, Disks dan Document Viewer melewati titlebar dan menggunakan header mereka sendiri sebagai gantinya; `Super + Alt + F` memaksimalkannya, dan `Super + M` meminimalkannya.

Workspace mengambang juga menampilkan dock, dengan aplikasi yang kamu sematkan, semua yang sedang berjalan, dan grid semua aplikasi di balik tombol apps, yang juga dibuka oleh `Super + Alt + Space` dan _Apps_ di Omarchy menu. Klik kanan aplikasi di grid, atau tekan `Delete`, untuk menghapus instalasinya. Klik aplikasi untuk membukanya, atau untuk membawa jendelanya ke depan; klik lagi untuk berputar melalui jendelanya. Files hanya membawa kembali jendela dari workspace yang sedang kamu gunakan dan selain itu membuka yang baru, dan Terminal dan Agent selalu memulai yang lain, meskipun jendela yang diminimalkan kembali lebih dulu. Klik tengah membuka jendela baru. Seret ikon di sepanjang dock untuk memindahkannya; menyeret aplikasi yang sedang berjalan masuk di antara yang lain membuatnya tetap di sana. Klik kanan untuk mempertahankan aplikasi di dock, mengeluarkannya, atau menutupnya. Dock menyingkir dari jendela layar penuh. Klik kanan tombol apps untuk memindahkan dock ke tepi lain atau membuatnya bersembunyi sampai pointer mencapai tepinya. Posisinya juga berada di bawah _Appearance > Dock > Dock Position_, dan `omarchy dock position left` dan `omarchy dock autohide on` mengatur keduanya dari terminal. Aplikasi yang kamu pertahankan di dock memudar saat tidak sedang berjalan.

Workspace baru, dan yang mana pun yang belum kamu beri tata letaknya sendiri dengan `Super + L`, menggunakan tata letak default. Mengubah default mengatur ulang setiap workspace tanpa jendela ke tata letak tersebut, sementara yang memiliki jendela di dalamnya tetap mempertahankan tata letak yang dimilikinya. Jendela yang diminimalkan ke dock tetap dihitung sebagai jendela di workspace yang ditinggalkannya. Pilih di bawah _Appearance > Workspace Layout_: Tiling, Scrolling, atau Floating. `omarchy hyprland workspace layout default scrolling` mengaturnya dari terminal.

### Mengelompokkan jendela

Jendela bisa dikelompokkan menggunakan `Super + G`. Setelah kamu berada di dalam sebuah grup, setiap jendela yang kamu mulai saat grup itu aktif akan menjadi bagian dari grup tersebut. Kamu bisa berpindah di antara jendela-jendela yang dikelompokkan ini menggunakan `Super + Ctrl + Arrow Left/Right` atau `Super + Alt + 1/2/3/4` untuk langsung pergi ke jendela yang dikelompokkan secara berurutan.

Kamu bisa memindahkan jendela keluar dari pengelompokan dengan `Super + Alt + G` atau membongkar seluruh grup dengan menekan `Super + G` lagi. Terakhir, kamu bisa memindahkan jendela di luar grup ke dalamnya dengan `Super + Alt + Arrows`.

### Mengeluarkan jendela

Kamu bisa mengeluarkan jendela dari alokasi workspace-nya dengan `Super + O`. Itu akan menyematkannya sebagai jendela mengambang yang mengikutimu ke workspace mana pun yang kamu tuju. Hebat untuk pemutar video dan sejenisnya.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Workspace scratchpad

Ada workspace scratchpad khusus berukuran penuh yang melapisi workspace apa pun yang sedang kamu gunakan. Kamu mengakses apa yang ada di sana menggunakan `Super + S`, dan kamu menempatkan jendela di sana menggunakan `Super + Alt + S`.

Ini bekerja dengan baik untuk kontrol atau terminal yang ingin kamu gunakan dengan cepat tanpa meninggalkan workspace saat ini.

### Konsol Quake

Terakhir, ada konsol Quake setengah tinggi yang turun menutupi workspace apa pun yang sedang kamu gunakan. Alihkan dengan `Super + Grave`, dan tempatkan jendela di sana menggunakan `Super + Shift + Grave`.

Saat pertama kali terbuka, ia memulai agent default kamu, atau memintamu memilih salah satu jika kamu belum memilihnya. Saat konsol hanya menampung satu jendela, ia turun sebagai panel di tengah, bukan membentang di layar. Taruh aplikasi kedua di sana dan ia kembali ke lebar penuh, jadi keduanya punya ruang untuk duduk bersebelahan.

Untuk memindahkan jendela keluar dari scratchpad atau konsol, kirim langsung ke workspace lain dengan sesuatu seperti `Super + Shift + 1`.

### Butuh waktu untuk terbiasa!

Butuh sedikit waktu untuk terbiasa menavigasi desktop kamu seperti ini, tapi setelah kamu terbiasa, akan sulit untuk kembali ke pengalaman desktop tradisional yang digerakkan mouse!
