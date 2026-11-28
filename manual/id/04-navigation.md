# Navigasi

Segala sesuatu di Omarchy terjadi lewat keyboard — _SEGALANYA!_ Saat sistem pertama kali menyala, kamu benar-benar tidak bisa melakukan apa pun hanya dengan mouse. Tapi kamu bisa menekan `Super + Space` untuk memunculkan Omarchy Menu dan dari sini kamu bisa melakukan hampir segala sesuatu.

Tapi menu Omarchy bahkan tidak dimaksudkan menjadi cara utama untuk mengoperasikan sistem hampir sepanjang waktu. Kita bisa lebih cepat dari itu! Semua aplikasi terpenting terikat langsung ke hotkey tersendiri. Kamu memulai terminal dengan `Super + Return` dan browser dengan `Super + Shift + Return`. Coba lakukan satu setelah yang lain, dan kamu akan melihat keajaiban tiling Hyprland beraksi:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Lalu kamu bisa menekan `Super + J` untuk menumpuknya satu di atas yang lain, bukan berdampingan:

 ![navigation-stacked](images/navigation-stacked.webp)

Tekan `Super + J` lagi untuk mengembalikannya ke posisi berdampingan. Lalu coba `Super + Shift + Arrow Right` saat berada di browser untuk menukar jendelanya.

Sekarang coba `Super + Shift + T` untuk memulai Activity monitor. Itu akan muncul sebagai jendela floating. Kamu bisa men-tile-nya menggunakan `Super + T` (dan tekan lagi untuk membuatnya floating lagi). Sekarang tekan `Super + Shift + F` untuk membuka file manager. Kamu akan mendapatkan susunan empat arah yang rapi:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Kamu menavigasi antarjendela yang ingin kamu aktifkan dengan `Super + Arrow`. Ini akan memindahkan fokus dan menggerakkan kursor ke tengah aplikasi baru. Di tepi layar, ini berlanjut ke monitor di sisi tersebut.

Jika kamu menekan `Super + Shift + 2`, kamu akan memindahkan aplikasi yang sedang fokus ke workspace kedua. `Super + Shift + 1` memindahkannya kembali. (Dan `Super + Shift + Alt + 2` akan memindahkan aplikasi yang sedang fokus ke workspace kedua tanpa berpindah ke sana).

Dengan lebih dari satu monitor, setiap monitor memiliki workspace 1 sampai 10 sendiri-sendiri. `Super + 2` menuju ke workspace kedua dari monitor tempat kamu berada, dan top bar setiap monitor menampilkan workspace-nya sendiri dan workspace yang sedang ditampilkannya. `Super + Tab` berputar melalui workspace di monitor tempat kamu berada. `Super + Shift + Ctrl + Arrows` memindahkan jendela tempat kamu berada ke monitor ke arah tersebut, ke workspace yang sedang ditampilkannya, dan `Super + Shift + Alt + Arrows` memindahkan workspace tempat kamu berada ke monitor ke arah tersebut, di mana workspace itu mengambil nomor yang sama jika kosong. Sebuah monitor menyimpan workspace-nya saat kamu mencabutnya: workspace-workspace itu bergabung ke layar lain, diberi nomor setelah workspace yang sudah ada di sana, dan kembali dengan nomor lamanya saat monitor kembali.

Jika kamu menahan `Super` dan menggunakan mouse untuk mengklik sebuah jendela, kamu akan bisa mengatur ulang tempatnya. Jika kamu menahan `Super` dan menggunakan tombol kanan mouse, kamu bisa mengubah ukuran jendela dengan bebas.

Kamu menutup jendela dengan `Super + W` atau `Super + Q` (dan menutup semua jendela dengan `Ctrl + Alt + Delete`).

Kamu juga bisa masuk ke layar penuh dengan `Super + F` atau bahkan hanya selebar layar penuh (dengan tetap mempertahankan top bar) dengan `Super + Alt + F` atau layar penuh di dalam sebuah jendela dengan `Super + Ctrl + F` (bagus untuk YouTube!).

### Layout dwindle vs scrolling

Layout default Omarchy disebut dwindle. Layout ini menjaga semua jendela yang kamu buka di satu workspace tetap terlihat sepanjang waktu, bahkan jika harus mengecilkannya.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Tapi kamu juga bisa memilih untuk mengubah sebuah workspace menjadi layout scrolling di mana jendela-jendela berbaris berdampingan, melampaui tepi layar yang terlihat. Kamu mengubah satu workspace menjadi layout ini lewat `Super + L`.

Menekan `Super + L` lagi mengubah workspace menjadi floating, di mana jendela-jendela saling tumpang tindih dengan bebas dan kamu menempatkannya sendiri, dan tekanan ketiga mengembalikannya ke dwindle. `Super + Alt + L` melewatinya ke arah sebaliknya. Sebuah jendela yang memang sudah floating — jendela yang kamu keluarkan dengan `Super + T`, atau aplikasi yang selalu terbuka sebagai floating — tetap floating saat workspace kembali ke tiling. Top bar menandai workspace tempat kamu berada dengan layout-nya: persegi untuk dwindle, lingkaran untuk scrolling, dan segitiga untuk floating. Mengklik tanda itu juga mengganti layout secara bergilir, begitu juga tombol display pada laptop yang memilikinya.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pilihannya berlaku per workspace, dan tetap dipertahankan. Jadi kamu bisa mempertahankan workspace 1 pada dwindle untuk browsing dan workspace 2 pada scrolling untuk code, dan keduanya akan kembali seperti itu setelah restart.

Jika kamu ingin menggunakan layout scrolling sebagai default, kamu bisa mengaturnya di `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Workspace floating

Workspace floating bekerja seperti desktop tradisional: jendela-jendela saling tumpang tindih, dan kamu memindahkan serta mengatur ukurannya sendiri. Setiap jendela mendapatkan titlebar dengan warna tema kamu, lengkap dengan tombol untuk minimize, maximize, dan close. `Super + M` juga me-minimize jendela yang sedang fokus. Jendela yang di-minimize menunggu di dock; klik aplikasinya untuk membawanya kembali. Klik sebuah jendela untuk membawanya ke depan. Ubah ukurannya dari tepi atau sudut mana pun. Klik dua kali sebuah titlebar untuk memaksimalkan jendela sambil tetap menampilkan top bar, dan klik dua kali lagi untuk mendapatkan ukuran lamanya kembali. Chrome dan browser berbasis Chromium lainnya, Disks dan Document Viewer melewati titlebar dan menggunakan header mereka sendiri sebagai gantinya; `Super + Alt + F` memaksimalkannya, dan `Super + M` me-minimize-nya.

Workspace floating juga menampilkan dock, dengan aplikasi yang kamu pin, semua yang sedang berjalan, dan grid berisi setiap aplikasi di balik tombol apps, yang juga dibuka oleh `Super + Alt + Space` dan _Apps_ di menu Omarchy. Klik kanan sebuah aplikasi di grid, atau tekan `Delete`, untuk meng-uninstall-nya. Klik sebuah aplikasi untuk membukanya, atau untuk membawa jendelanya ke depan; klik lagi untuk berputar melalui jendela-jendelanya. Files hanya membawa kembali jendela dari workspace tempat kamu berada dan jika tidak ada akan membuka yang baru, dan Terminal dan Agent selalu memulai yang lain lagi, meskipun jendela yang di-minimize akan kembali lebih dulu. Klik tengah membuka jendela baru. Seret sebuah ikon di sepanjang dock untuk memindahkannya; menyeret aplikasi yang sedang berjalan masuk di antara aplikasi lainnya akan mempertahankannya di sana. Klik kanan untuk mempertahankan aplikasi di dock, mengeluarkannya, atau menutupnya. Dock menyingkir dari jendela fullscreen. Klik kanan tombol apps untuk memindahkan dock ke tepi lain atau membuatnya bersembunyi sampai pointer mencapai tepinya. Posisinya juga ada di bawah _Appearance > Dock > Dock Position_, dan `omarchy dock position left` dan `omarchy dock autohide on` mengatur keduanya dari terminal. Aplikasi yang kamu pertahankan di dock tampak pudar saat tidak sedang berjalan.

Workspace baru, dan workspace mana pun yang belum kamu beri layout sendiri dengan `Super + L`, menggunakan layout default. Mengubah default akan mengatur ulang setiap workspace tanpa jendela ke layout tersebut, sementara workspace yang memiliki jendela tetap mempertahankan layout yang dimilikinya. Jendela yang di-minimize ke dock tetap dihitung sebagai jendela pada workspace yang ditinggalkannya. Pilih di bawah _Appearance > Workspace Layout_: Tiling, Scrolling, atau Floating. `omarchy hyprland workspace layout default scrolling` mengaturnya dari terminal.

### Mengelompokkan jendela

Jendela bisa dikelompokkan menggunakan `Super + G`. Setelah kamu berada dalam sebuah grup, setiap jendela yang kamu mulai saat grup itu aktif akan menjadi bagian dari grup tersebut. Kamu bisa berpindah di antara jendela-jendela yang dikelompokkan ini menggunakan `Super + Ctrl + Arrow Left/Right` atau `Super + Alt + 1/2/3/4` untuk langsung menuju jendela yang dikelompokkan secara berurutan.

Kamu bisa memindahkan jendela keluar dari pengelompokan dengan `Super + Alt + G` atau membongkar seluruh grup dengan menekan `Super + G` lagi. Terakhir, kamu bisa memindahkan jendela di luar grup ke dalamnya dengan `Super + Alt + Arrows`.

### Mengeluarkan jendela

Kamu bisa mengeluarkan sebuah jendela dari alokasi workspace-nya dengan `Super + O`. Itu akan mem-pin-nya sebagai jendela floating yang mengikuti kamu ke workspace mana pun yang kamu tuju. Bagus untuk pemutar video dan semacamnya.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Workspace scratchpad

Ada workspace scratchpad khusus berukuran penuh yang melapisi workspace apa pun yang sedang kamu gunakan. Kamu mengakses apa yang ada di sana menggunakan `Super + S`, dan kamu menempatkan jendela di sana menggunakan `Super + Alt + S`.

Ini bekerja dengan baik untuk kontrol atau terminal yang ingin kamu gunakan dengan cepat tanpa meninggalkan workspace saat ini.

### Konsol Quake

Terakhir, ada konsol Quake setengah tinggi yang turun ke bawah melapisi workspace apa pun yang sedang kamu gunakan. Aktif/nonaktifkan dengan `Super + the key above Tab` (grave pada layout US), dan tempatkan sebuah jendela di sana menggunakan `Super + Shift + the key above Tab`.

Saat pertama kali dibuka, konsol ini memulai agent default kamu, atau meminta kamu memilih satu jika kamu belum memilihnya. Saat konsol hanya berisi satu jendela, konsol ini turun sebagai panel di tengah, bukan membentang selebar layar. Taruh aplikasi kedua di sana dan konsol ini kembali ke lebar penuh, sehingga keduanya punya ruang untuk duduk berdampingan.

Untuk memindahkan jendela keluar dari scratchpad atau konsol, kirim langsung ke workspace lain dengan sesuatu seperti `Super + Shift + 1`.

### Butuh sedikit pembiasaan!

Butuh sedikit waktu untuk terbiasa menavigasi desktop kamu seperti ini, tapi begitu kamu terbiasa, akan sulit untuk kembali ke pengalaman desktop tradisional yang digerakkan oleh mouse!
