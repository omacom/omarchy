# Navigasi

Semua hal di Omarchy terjadi lewat keyboard — _SEMUA!_ Saat sistem pertama kali menyala, kamu benar-benar tidak bisa melakukan apa pun hanya dengan mouse. Tapi kamu bisa menekan `Super + Space` untuk menampilkan Menu Omarchy dan dari sini kamu bisa melakukan hampir semua hal.

Namun menu Omarchy bahkan tidak dimaksudkan sebagai cara utama untuk mengoperasikan sistem di sebagian besar waktu. Kita bisa lebih cepat dari itu! Semua aplikasi terpenting terikat langsung ke hotkey masing-masing. Kamu membuka terminal dengan `Super + Return` dan browser dengan `Super + Shift + Return`. Coba lakukan yang satu setelah yang lain, dan kamu akan melihat keajaiban tiling Hyprland bekerja:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Kamu lalu bisa menekan `Super + J` untuk menumpuknya satu di atas yang lain, bukan berdampingan:

 ![navigation-stacked](images/navigation-stacked.webp)

Tekan `Super + J` lagi untuk mengembalikannya ke posisi berdampingan. Lalu coba `Super + Shift + Arrow Right` saat berada di browser untuk menukar jendelanya.

Sekarang coba `Super + Shift + T` untuk membuka monitor Activity. Itu akan muncul sebagai jendela floating. Kamu bisa menjadikannya tiling dengan `Super + T` (dan tekan lagi untuk menjadikannya floating kembali). Sekarang tekan `Super + Shift + F` untuk membuka file manager. Kamu akan mendapatkan pengaturan empat arah yang rapi:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Kamu berpindah di antara jendela yang ingin kamu aktifkan dengan `Super + Arrow`. Ini akan memindahkan fokus dan menggerakkan kursor ke tengah aplikasi baru. Di tepi layar, ini berlanjut ke monitor di sisi tersebut.

Jika kamu menekan `Super + Shift + 2`, kamu akan memindahkan aplikasi yang sedang fokus ke workspace kedua. `Super + Shift + 1` memindahkannya kembali. (Dan `Super + Shift + Alt + 2` akan memindahkan aplikasi yang sedang fokus ke workspace kedua tanpa berpindah ke sana).

Dengan lebih dari satu monitor, setiap monitor memiliki workspace 1 sampai 10 sendiri-sendiri. `Super + 2` pergi ke workspace kedua di monitor tempat kamu berada, dan bar atas setiap monitor menampilkan workspace-nya sendiri dan workspace yang sedang ditampilkannya. `Super + Tab` berputar melalui workspace di monitor tempat kamu berada. `Super + Shift + Ctrl + Arrows` memindahkan jendela tempat kamu berada ke monitor di arah tersebut, ke workspace yang sedang ditampilkannya, dan `Super + Shift + Alt + Arrows` memindahkan workspace tempat kamu berada ke monitor di arah tersebut, di mana workspace itu mengambil nomor yang sama jika kosong. Sebuah monitor menyimpan workspace-nya saat kamu mencabutnya: workspace-workspace itu bergabung dengan workspace layar lain, diberi nomor setelah workspace yang sudah ada di sana, dan kembali dengan nomor lamanya saat monitor itu kembali.

Jika kamu menahan `Super` dan menggunakan mouse untuk mengklik sebuah jendela, kamu akan bisa mengatur ulang letaknya. Jika kamu menahan `Super` dan menggunakan tombol kanan mouse, kamu bisa mengubah ukuran jendela dengan bebas.

Kamu menutup jendela dengan `Super + W` atau `Super + Q` (dan menutup semua jendela dengan `Ctrl + Alt + Delete`).

Kamu juga bisa masuk ke layar penuh dengan `Super + F` atau bahkan hanya selebar penuh (dengan bar atas tetap tampil) dengan `Super + Alt + F` atau layar penuh di dalam sebuah jendela dengan `Super + Ctrl + F` (bagus untuk YouTube!).

### Layout dwindle vs scrolling

Layout default Omarchy disebut dwindle. Layout ini membuat semua jendela yang kamu buka di satu workspace tetap terlihat setiap saat, bahkan jika harus mengecilkannya.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Namun kamu juga bisa memilih untuk mengubah sebuah workspace menjadi layout scrolling di mana jendela-jendela berjajar berdampingan, melampaui tepi layar yang terlihat. Kamu mengubah satu workspace menjadi layout ini melalui `Super + L`.

Menekan `Super + L` lagi menjadikan workspace itu floating, di mana jendela-jendela saling tumpang tindih dengan bebas dan kamu meletakkannya sendiri, dan penekanan ketiga mengembalikannya ke dwindle. `Super + Alt + L` melewatinya ke arah sebaliknya. Jendela yang memang floating — jendela yang kamu keluarkan dengan `Super + T`, atau aplikasi yang selalu terbuka dalam keadaan floating — tetap floating saat workspace kembali ke tiling. Bar atas menandai workspace tempat kamu berada dengan layout-nya: persegi untuk dwindle, lingkaran untuk scrolling, dan segitiga untuk floating. Mengklik tanda itu juga mengganti layout secara berputar.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pilihan ini berlaku per workspace, dan tetap tersimpan. Jadi kamu bisa mempertahankan workspace 1 di dwindle untuk browsing dan workspace 2 di scrolling untuk kode, dan keduanya akan kembali seperti itu setelah restart.

Jika kamu ingin menggunakan layout scrolling sebagai default, kamu bisa mengaturnya di `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Workspace floating

Sebuah workspace floating bekerja seperti desktop tradisional: jendela-jendela saling tumpang tindih, dan kamu memindahkan serta mengubah ukurannya sendiri. Setiap jendela mendapatkan titlebar dengan warna tema kamu, dengan tombol untuk minimize, maximize, dan menutup. `Super + M` juga me-minimize jendela yang sedang fokus. Jendela yang di-minimize menunggu di dock; klik aplikasinya untuk membawanya kembali. Klik sebuah jendela untuk membawanya ke depan. Ubah ukurannya dari tepi atau sudut mana pun. Klik dua kali titlebar untuk me-maximize jendela sambil tetap menampilkan bar atas, dan klik dua kali lagi untuk mendapatkan ukuran lamanya kembali. Chrome dan browser berbasis Chromium lainnya, Disks dan Document Viewer melewatkan titlebar dan menggunakan header-nya sendiri sebagai gantinya; `Super + Alt + F` me-maximize-nya, dan `Super + M` me-minimize-nya.

Sebuah workspace floating juga menampilkan dock, dengan aplikasi yang kamu sematkan, semua yang sedang berjalan, dan grid semua aplikasi di balik tombol aplikasi, yang juga dibuka oleh `Super + Alt + Space` dan _Apps_ di menu Omarchy. Klik kanan aplikasi di grid, atau tekan `Delete`, untuk menghapus instalasinya. Klik sebuah aplikasi untuk membukanya, atau untuk membawa jendelanya ke depan; klik lagi untuk berputar melalui jendela-jendelanya. Klik tengah membuka jendela baru. Seret ikon di sepanjang dock untuk memindahkannya; menyeret aplikasi yang sedang berjalan masuk ke antara aplikasi lain akan mempertahankannya di sana. Klik kanan untuk mempertahankan aplikasi di dock, mengeluarkannya, atau menutupnya. Dock menyingkir dari jendela layar penuh. Klik kanan tombol aplikasi untuk memindahkan dock ke tepi lain atau membuatnya bersembunyi sampai pointer mencapai tepinya. Posisi ini juga ada di bawah _Penampilan > Dock > Posisi Dock_, dan `omarchy dock position left` serta `omarchy dock autohide on` mengatur keduanya dari terminal. Aplikasi yang kamu pertahankan di dock tampak pudar saat tidak berjalan.

Workspace baru, dan workspace mana pun yang belum kamu beri layout sendiri dengan `Super + L`, menggunakan layout default. Mengubah default akan mengatur ulang setiap workspace tanpa jendela ke layout itu, sementara workspace yang memiliki jendela di dalamnya tetap mempertahankan layout yang dimilikinya. Jendela yang di-minimize ke dock tetap dihitung sebagai jendela di workspace yang ditinggalkannya. Pilih layout itu di bawah _Penampilan > Layout Workspace_: Tiling, Scrolling, atau Floating. `omarchy-hyprland-workspace-layout-default scrolling` mengaturnya dari terminal.

### Mengelompokkan jendela

Jendela bisa dikelompokkan menggunakan `Super + G`. Setelah kamu berada di dalam sebuah grup, setiap jendela yang kamu buka saat grup itu aktif akan menjadi bagian dari grup tersebut. Kamu bisa berpindah di antara jendela-jendela yang dikelompokkan ini menggunakan `Super + Ctrl + Arrow Left/Right` atau `Super + Alt + 1/2/3/4` untuk pergi langsung ke jendela yang dikelompokkan secara berurutan.

Kamu bisa memindahkan jendela keluar dari pengelompokan dengan `Super + Alt + G` atau membongkar seluruh grup dengan menekan `Super + G` lagi. Terakhir, kamu bisa memindahkan jendela di luar grup ke dalamnya dengan `Super + Alt + Arrows`.

### Mengeluarkan jendela

Kamu bisa mengeluarkan jendela dari alokasi workspace-nya dengan `Super + O`. Itu akan menyematkannya sebagai jendela floating yang mengikutimu ke workspace mana pun yang kamu tuju. Bagus untuk pemutar video dan semacamnya.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Workspace scratchpad

Ada workspace scratchpad khusus berukuran penuh yang melapisi workspace apa pun yang sedang kamu gunakan. Kamu mengakses apa yang ada di sana menggunakan `Super + S`, dan kamu meletakkan jendela di sana menggunakan `Super + Alt + S`.

Ini bekerja dengan baik untuk kontrol atau terminal yang ingin kamu gunakan dengan cepat tanpa meninggalkan workspace saat ini.

### Konsol Quake

Terakhir, ada konsol Quake setengah tinggi yang turun menutupi workspace apa pun yang sedang kamu gunakan. Alihkan dengan `Super + Grave`, dan letakkan jendela di sana menggunakan `Super + Shift + Grave`.

Ini terbuka dengan agent default kamu siap digunakan. Saat konsol hanya berisi satu jendela, konsol itu turun sebagai panel di tengah, bukan membentang selebar layar. Letakkan aplikasi kedua di sana dan konsol itu kembali ke lebar penuh, sehingga keduanya memiliki ruang untuk berdampingan.

Untuk memindahkan jendela dari scratchpad atau konsol, kirim jendela itu langsung ke workspace lain dengan sesuatu seperti `Super + Shift + 1`.

### Perlu waktu untuk membiasakan diri!

Perlu sedikit waktu untuk membiasakan diri menavigasi desktop kamu seperti ini, tapi setelah terbiasa, akan sulit untuk kembali ke pengalaman desktop tradisional yang digerakkan mouse!
