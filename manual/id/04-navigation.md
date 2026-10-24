# Navigasi

Semua hal di Omarchy terjadi lewat keyboard — _SEMUA!_ Saat sistem pertama kali dimulai, kamu benar-benar tidak bisa melakukan apa pun hanya dengan mouse. Tapi kamu bisa menekan `Super + Space` untuk menampilkan Menu Omarchy dan dari sini kamu bisa melakukan hampir semua hal.

Tapi menu Omarchy bahkan tidak dimaksudkan menjadi cara utama untuk mengoperasikan sistem ini sepanjang waktu. Kita bisa lebih cepat dari itu! Semua aplikasi yang paling penting terikat langsung ke hotkey masing-masing. Kamu memulai terminal dengan `Super + Return` dan browser dengan `Super + Shift + Return`. Coba lakukan satu demi satu, dan kamu akan melihat keajaiban tiling Hyprland beraksi:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Lalu kamu bisa menekan `Super + J` untuk menumpuknya satu di atas yang lain, bukan berdampingan:

 ![navigation-stacked](images/navigation-stacked.webp)

Tekan `Super + J` lagi untuk mengembalikannya ke posisi berdampingan. Lalu coba `Super + Shift + Arrow Right` saat berada di browser untuk menukar jendelanya.

Sekarang coba `Super + Ctrl + T` untuk memulai monitor Activity. Itu akan muncul sebagai jendela mengambang. Kamu bisa men-tiling-nya menggunakan `Super + T` (dan tekannya lagi untuk membuatnya mengambang lagi). Sekarang tekan `Super + Shift + F` untuk membuka pengelola file. Kamu akan memiliki susunan empat arah yang rapi:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Kamu berpindah di antara jendela yang ingin kamu aktifkan dengan `Super + Arrow`. Ini akan mengalihkan fokus dan memindahkan kursor ke tengah aplikasi yang baru.

Jika kamu menekan `Super + Shift + 2`, kamu akan memindahkan aplikasi yang sedang terfokus ke workspace kedua. `Super + Shift + 1` memindahkannya kembali. (Dan `Super + Shift + Alt + 2` akan memindahkan aplikasi yang sedang terfokus ke workspace kedua tanpa ikut berpindah ke sana).

Jika kamu menahan `Super` dan menggunakan mouse untuk mengklik sebuah jendela, kamu bisa mengatur ulang di mana jendela itu berada. Jika kamu menahan `Super` dan menggunakan tombol kanan mouse, kamu bisa mengubah ukuran jendela dengan bebas.

Kamu menutup jendela dengan `Super + W` atau `Super + Q` (dan menutup semua jendela dengan `Ctrl + Alt + Delete`).

Kamu juga bisa masuk ke layar penuh dengan `Super + F` atau bahkan hanya selebar layar penuh (dengan tetap mempertahankan bar atas) dengan `Super + Alt + F` atau layar penuh di dalam sebuah jendela dengan `Super + Ctrl + F` (cocok untuk YouTube!).

### Tata letak dwindle vs scrolling

Tata letak default Omarchy disebut dwindle. Tata letak ini menjaga semua jendela yang kamu buka di satu workspace tetap terlihat setiap saat, meski harus menyusutkannya.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Tapi kamu juga bisa memilih untuk mengubah sebuah workspace menjadi tata letak scrolling, di mana jendela-jendela berjajar berdampingan, melampaui tepi layar yang terlihat. Kamu mengubah satu workspace menjadi tata letak ini lewat `Super + L`.

Menekan `Super + L` lagi membuat workspace itu mengambang, di mana jendela-jendela saling tumpang tindih dengan bebas dan kamu menempatkannya sendiri, dan tekanan ketiga mengembalikannya ke dwindle. `Super + Alt + L` melewatinya ke arah sebaliknya. Jendela yang memang sudah mengambang — yang kamu keluarkan dengan `Super + T`, atau aplikasi yang selalu terbuka mengambang — tetap mengambang saat workspace kembali ke tiling. Bar atas menandai workspace tempatmu berada dengan tata letaknya: persegi untuk dwindle, lingkaran untuk scrolling, dan segitiga untuk mengambang. Mengklik tanda itu juga akan mengganti tata letaknya secara bergantian.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pilihannya berlaku per workspace, dan tetap bertahan. Jadi kamu bisa menjaga workspace 1 tetap di dwindle untuk browsing dan workspace 2 di scrolling untuk kode, dan keduanya akan kembali seperti itu setelah restart.

Jika kamu ingin menggunakan tata letak scrolling sebagai default, kamu bisa mengaturnya di `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Workspace mengambang

Workspace mengambang bekerja seperti desktop tradisional: jendela-jendela saling tumpang tindih, dan kamu memindahkan serta mengatur ukurannya sendiri. Setiap jendela mendapatkan titlebar dalam warna temamu, dengan tombol untuk meminimalkan, memaksimalkan, dan menutup. `Super + M` juga meminimalkan jendela yang terfokus. Jendela yang diminimalkan menunggu di dock; klik aplikasinya untuk membawanya kembali. Klik sebuah jendela untuk membawanya ke depan. Ubah ukurannya dari tepi atau sudut mana pun. Klik dua kali titlebar untuk memaksimalkan jendela sambil tetap menjaga bar atas terlihat, dan lakukan lagi untuk mendapatkan kembali ukuran lamanya.

Workspace mengambang juga menampilkan dock, dengan aplikasi yang kamu sematkan, semua yang sedang berjalan, dan grid berisi setiap aplikasi di balik tombol aplikasi, yang juga bisa dibuka dengan `Super + Alt + Space` dan _Apps_ di menu Omarchy. Klik kanan sebuah aplikasi di grid, atau tekan `Delete`, untuk menghapus instalasinya. Klik sebuah aplikasi untuk membukanya, atau untuk membawa jendelanya ke depan; klik lagi untuk beralih di antara jendela-jendelanya. Klik tengah membuka jendela baru. Seret ikon di sepanjang dock untuk memindahkannya; menyeret aplikasi yang sedang berjalan ke antara aplikasi-aplikasi lain akan menyimpannya di sana. Klik kanan untuk menyimpan aplikasi di dock, mengeluarkannya, atau menutupnya. Dock akan menyingkir dari jendela layar penuh. Klik kanan tombol aplikasi untuk memindahkan dock ke tepi lain atau membuatnya bersembunyi sampai pointer mencapai tepinya. Posisinya juga ada di bawah _Trigger > Appearance > Dock > Dock Position_, dan `omarchy dock position left` serta `omarchy dock autohide on` mengatur keduanya dari terminal. Aplikasi yang kamu simpan di dock akan tampak pudar saat tidak berjalan.

Workspace baru, dan workspace apa pun yang belum kamu beri tata letaknya sendiri dengan `Super + L`, menggunakan tata letak default. Mengubah default akan mengatur ulang setiap workspace tanpa jendela ke tata letak tersebut, sementara workspace yang memiliki jendela tetap mempertahankan tata letak yang dimilikinya. Jendela yang diminimalkan ke dock tetap dihitung sebagai jendela di workspace yang ditinggalkannya. Pilih tata letaknya di bawah _Trigger > Appearance > Workspace Layout_: Tiling, Scrolling, atau Floating. `omarchy-hyprland-workspace-layout-default scrolling` mengaturnya dari terminal.

### Mengelompokkan jendela

Jendela bisa dikelompokkan menggunakan `Super + G`. Setelah kamu masuk ke sebuah grup, setiap jendela yang kamu mulai saat grup itu aktif akan menjadi bagian dari grup tersebut. Kamu bisa berpindah di antara jendela-jendela yang dikelompokkan ini menggunakan `Super + Ctrl + Arrow Left/Right` atau `Super + Alt + 1/2/3/4` untuk langsung menuju jendela dalam grup sesuai urutan.

Kamu bisa memindahkan jendela keluar dari pengelompokan dengan `Super + Alt + G` atau membubarkan seluruh grup dengan menekan `Super + G` lagi. Terakhir, kamu bisa memindahkan jendela di luar grup masuk ke dalamnya dengan `Super + Alt + Arrows`.

### Melepas jendela

Kamu bisa melepas jendela dari alokasi workspace-nya dengan `Super + O`. Itu akan menyematkannya sebagai jendela mengambang yang mengikutimu ke workspace mana pun kamu pergi. Cocok untuk pemutar video dan sejenisnya.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Workspace scratchpad

Terakhir, ada workspace scratchpad khusus yang turun di atas workspace tempatmu berada saat ini, mirip seperti konsol Quake. Alihkan dengan `Super + Grave` atau `Super + S`, dan tempatkan jendela di sana menggunakan `Super + Shift + Grave` atau `Super + Alt + S`.

Ini sangat cocok untuk terminal yang menjalankan agent, atau untuk kontrol yang ingin kamu gunakan dengan cepat tanpa meninggalkan workspace saat ini. Untuk memindahkan jendela dari scratchpad, kirim langsung ke workspace lain dengan sesuatu seperti `Super + Shift + 1`.

Selagi scratchpad hanya menampung satu jendela, ia turun sebagai panel terpusat, bukan membentang memenuhi layar. Letakkan aplikasi kedua di sana dan ia kembali selebar penuh, sehingga keduanya punya ruang untuk duduk berdampingan.

### Perlu waktu untuk terbiasa!

Perlu sedikit waktu untuk terbiasa menavigasi desktopmu seperti ini, tapi begitu kamu terbiasa, akan sulit untuk kembali ke pengalaman desktop tradisional yang mengandalkan mouse!
