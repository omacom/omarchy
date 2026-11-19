# Navigasi

Segala sesuatu di Omarchy terjadi lewat keyboard — _SEMUANYA!_ Saat sistem pertama kali menyala, kamu benar-benar tidak bisa melakukan apa pun hanya dengan mouse. Tapi kamu bisa menekan `Super + Space` untuk menampilkan Menu Omarchy dan dari sini kamu bisa melakukan hampir segala hal.

Tapi Menu Omarchy bahkan tidak dimaksudkan sebagai cara utama untuk mengoperasikan sistem di sebagian besar waktu. Kita bisa lebih cepat dari itu! Semua aplikasi terpenting terikat langsung ke hotkey masing-masing. Kamu membuka terminal dengan `Super + Return` dan browser dengan `Super + Shift + Return`. Coba lakukan satu demi satu, dan kamu akan melihat keajaiban tiling Hyprland beraksi:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Lalu kamu bisa menekan `Super + J` untuk menumpuknya satu di atas yang lain, bukan berdampingan:

 ![navigation-stacked](images/navigation-stacked.webp)

Tekan `Super + J` lagi untuk mengembalikannya ke posisi berdampingan. Lalu coba `Super + Shift + Arrow Right` saat berada di browser untuk menukar jendelanya.

Sekarang coba `Super + Shift + T` untuk membuka Monitor aktivitas. Itu akan muncul sebagai jendela mengambang. Kamu bisa memasangnya sebagai tile menggunakan `Super + T` (dan tekan lagi untuk membuatnya mengambang kembali). Sekarang tekan `Super + Shift + F` untuk membuka manajer file. Kamu akan mendapatkan susunan empat arah yang rapi:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Kamu berpindah di antara jendela yang ingin kamu aktifkan dengan `Super + Arrow`. Ini akan memindahkan fokus dan menggerakkan kursor ke tengah aplikasi baru. Di tepi layar, perpindahan berlanjut ke monitor di sisi tersebut.

Jika kamu menekan `Super + Shift + 2`, kamu akan memindahkan aplikasi yang sedang fokus ke workspace kedua. `Super + Shift + 1` memindahkannya kembali. (Dan `Super + Shift + Alt + 2` akan memindahkan aplikasi yang sedang fokus ke workspace kedua tanpa berpindah ke sana).

Dengan lebih dari satu monitor, setiap monitor memiliki workspace 1 sampai 10 sendiri. `Super + 2` menuju ke workspace kedua di monitor tempatmu berada, dan bilah atas setiap monitor menampilkan workspace-nya sendiri dan workspace yang sedang ditampilkannya. `Super + Tab` berpindah secara bergiliran di antara workspace-workspace di monitor tempatmu berada. `Super + Shift + Ctrl + Arrows` memindahkan jendela tempatmu berada ke monitor ke arah tersebut, ke workspace yang sedang ditampilkannya, dan `Super + Shift + Alt + Arrows` memindahkan workspace tempatmu berada ke monitor ke arah tersebut, di mana workspace itu mengambil nomor yang sama jika nomornya kosong. Sebuah monitor mempertahankan workspace-nya saat kamu mencabutnya: workspace-workspace itu bergabung dengan layar lain, diberi nomor setelah nomor yang sudah ada di sana, dan kembali dengan nomor lamanya saat monitor tersebut kembali.

Jika kamu menekan dan menahan `Super` lalu menggunakan mouse untuk mengeklik sebuah jendela, kamu bisa mengatur ulang posisinya. Jika kamu menahan `Super` dan menggunakan tombol kanan mouse, kamu bisa mengubah ukuran jendela dengan bebas.

Kamu menutup jendela dengan `Super + W` atau `Super + Q` (dan menutup semua jendela dengan `Ctrl + Alt + Delete`).

Kamu juga bisa masuk ke layar penuh dengan `Super + F` atau bahkan hanya selebar layar penuh (dengan tetap menampilkan bilah atas) dengan `Super + Alt + F` atau layar penuh di dalam sebuah jendela dengan `Super + Ctrl + F` (bagus untuk YouTube!).

### Tata letak dwindle vs scrolling

Tata letak bawaan Omarchy disebut dwindle. Tata letak ini membuat semua jendela yang kamu buka di satu workspace tetap terlihat setiap saat, bahkan jika harus mengecilkannya.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Tapi kamu juga bisa memilih untuk mengubah sebuah workspace menjadi tata letak scrolling, di mana jendela-jendela berjajar berdampingan, melampaui tepi layar yang terlihat. Kamu mengubah satu workspace menjadi tata letak ini melalui `Super + L`.

Menekan `Super + L` lagi mengubah workspace menjadi mengambang, di mana jendela-jendela saling tumpang tindih dengan bebas dan kamu menempatkannya sendiri, dan penekanan ketiga mengembalikannya ke dwindle. `Super + Alt + L` melewatinya ke arah sebaliknya. Jendela yang memang sudah mengambang — jendela yang kamu keluarkan dengan `Super + T`, atau aplikasi yang selalu terbuka dalam keadaan mengambang — tetap mengambang saat workspace kembali ke tiling. Bilah atas menandai workspace tempatmu berada dengan tata letaknya: persegi untuk dwindle, lingkaran untuk scrolling, dan segitiga untuk mengambang. Mengeklik tanda itu juga mengganti tata letak secara bergiliran.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pilihannya berlaku per workspace, dan tetap tersimpan. Jadi kamu bisa mempertahankan workspace 1 di dwindle untuk browsing dan workspace 2 di scrolling untuk coding, dan keduanya akan kembali seperti itu setelah restart.

Jika kamu ingin menggunakan tata letak scrolling sebagai bawaan, kamu bisa mengaturnya di `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Workspace mengambang

Sebuah workspace mengambang bekerja seperti desktop tradisional: jendela-jendela saling tumpang tindih, dan kamu memindahkan serta mengatur ukurannya sendiri. Setiap jendela mendapatkan bilah judul dengan warna temamu, lengkap dengan tombol untuk meminimalkan, memaksimalkan, dan menutup. `Super + M` juga meminimalkan jendela yang sedang fokus. Jendela yang diminimalkan menunggu di dock; klik aplikasinya untuk membawanya kembali. Klik sebuah jendela untuk membawanya ke depan. Ubah ukurannya dari tepi atau sudut mana pun. Klik dua kali bilah judul untuk memaksimalkan jendela sambil tetap menampilkan bilah atas, dan klik dua kali lagi untuk mengembalikan ukuran lamanya. Chrome dan browser berbasis Chromium lainnya, Disks dan Document Viewer melewati bilah judul dan menggunakan header mereka sendiri sebagai gantinya; `Super + Alt + F` memaksimalkannya, dan `Super + M` meminimalkannya.

Sebuah workspace mengambang juga menampilkan dock, dengan aplikasi-aplikasi yang kamu sematkan, semua yang sedang berjalan, dan grid berisi setiap aplikasi di balik tombol aplikasi, yang juga dibuka oleh `Super + Alt + Space` dan _Aplikasi_ di menu Omarchy. Klik kanan sebuah aplikasi di grid, atau tekan `Delete`, untuk menghapus instalasinya. Klik sebuah aplikasi untuk membukanya, atau untuk membawa jendelanya ke depan; klik lagi untuk berpindah secara bergiliran di antara jendela-jendelanya. Files hanya membawa kembali jendela dari workspace tempatmu berada dan selain itu membuka jendela baru, dan Terminal dan Agent selalu membuka yang lain lagi, meskipun jendela yang diminimalkan akan kembali lebih dulu. Klik tengah membuka jendela baru. Seret sebuah ikon di sepanjang dock untuk memindahkannya; menyeret aplikasi yang sedang berjalan ke antara aplikasi-aplikasi lain akan mempertahankannya di sana. Klik kanan untuk mempertahankan sebuah aplikasi di dock, mengeluarkannya, atau menutupnya. Dock akan menyingkir dari jendela layar penuh. Klik kanan tombol aplikasi untuk memindahkan dock ke tepi lain atau membuatnya bersembunyi sampai pointer mencapai tepinya. Posisinya juga ada di _Tampilan > Dock > Posisi Dock_, dan `omarchy dock position left` serta `omarchy dock autohide on` mengatur keduanya dari terminal. Aplikasi yang kamu pertahankan di dock tampak pudar saat tidak sedang berjalan.

Workspace baru, dan workspace mana pun yang belum kamu beri tata letaknya sendiri dengan `Super + L`, menggunakan tata letak bawaan. Mengubah bawaan akan mengatur ulang setiap workspace tanpa jendela ke tata letak tersebut, sementara workspace yang memiliki jendela di dalamnya mempertahankan tata letak yang dimilikinya. Jendela yang diminimalkan ke dock tetap dihitung sebagai jendela di workspace yang ditinggalkannya. Pilih tata letaknya di _Tampilan > Tata Letak Workspace_: Tiling, Scrolling, atau Floating. `omarchy-hyprland-workspace-layout-default scrolling` mengaturnya dari terminal.

### Mengelompokkan jendela

Jendela bisa dikelompokkan menggunakan `Super + G`. Setelah kamu berada di dalam sebuah grup, setiap jendela yang kamu buka saat grup itu aktif akan menjadi bagian dari grup tersebut. Kamu bisa berpindah di antara jendela-jendela yang dikelompokkan ini menggunakan `Super + Ctrl + Arrow Left/Right` atau `Super + Alt + 1/2/3/4` untuk langsung menuju jendela-jendela yang dikelompokkan secara berurutan.

Kamu bisa mengeluarkan sebuah jendela dari grup dengan `Super + Alt + G` atau membubarkan seluruh grup dengan menekan `Super + G` lagi. Terakhir, kamu bisa memindahkan jendela di luar grup ke dalamnya dengan `Super + Alt + Arrows`.

### Mengeluarkan jendela

Kamu bisa mengeluarkan sebuah jendela dari alokasi workspace-nya dengan `Super + O`. Itu akan menyematkannya sebagai jendela mengambang yang mengikutimu ke workspace mana pun yang kamu tuju. Bagus untuk pemutar video dan semacamnya.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Workspace scratchpad

Ada workspace scratchpad khusus berukuran penuh yang menimpa workspace mana pun yang sedang kamu gunakan. Kamu mengakses apa yang ada di sana menggunakan `Super + S`, dan kamu menempatkan jendela di sana menggunakan `Super + Alt + S`.

Ini cocok untuk kontrol atau terminal yang ingin kamu gunakan dengan cepat tanpa meninggalkan workspace saat ini.

### Konsol Quake

Terakhir, ada konsol Quake setengah tinggi yang turun menimpa workspace mana pun yang sedang kamu gunakan. Aktif/nonaktifkan dengan `Super + Grave`, dan tempatkan sebuah jendela di sana menggunakan `Super + Shift + Grave`.

Konsol ini terbuka dengan agent bawaanmu siap digunakan. Selama konsol hanya berisi satu jendela, konsol turun sebagai panel di tengah, bukan membentang selebar layar. Tempatkan aplikasi kedua di sana dan konsol akan kembali selebar penuh, sehingga keduanya punya ruang untuk berdampingan.

Untuk memindahkan sebuah jendela keluar dari scratchpad atau konsol, kirim langsung ke workspace lain dengan sesuatu seperti `Super + Shift + 1`.

### Memang butuh sedikit pembiasaan!

Butuh sedikit waktu untuk terbiasa menavigasi desktopmu seperti ini, tapi setelah kamu terbiasa, akan sulit untuk kembali ke pengalaman desktop tradisional yang digerakkan mouse!
