# Navigasi

Semua hal di Omarchy terjadi melalui keyboard — _SEMUA!_ Saat sistem pertama kali menyala, Anda benar-benar tidak bisa melakukan apa pun hanya dengan mouse. Tetapi Anda bisa menekan `Super + Space` untuk menampilkan Menu Omarchy dan dari sini Anda bisa melakukan hampir semua hal.

Namun menu Omarchy bahkan tidak dimaksudkan menjadi cara utama untuk mengoperasikan sistem hampir sepanjang waktu. Kita bisa lebih cepat dari itu! Semua aplikasi terpenting terikat langsung ke hotkey tersendiri. Anda memulai terminal dengan `Super + Return` dan browser dengan `Super + Shift + Return`. Coba lakukan satu demi satu, dan Anda akan melihat keajaiban tiling Hyprland bekerja:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Anda kemudian bisa menekan `Super + J` untuk menumpuknya satu di atas yang lain, bukan berdampingan:

 ![navigation-stacked](images/navigation-stacked.webp)

Tekan `Super + J` lagi untuk mengembalikannya ke posisi berdampingan. Lalu coba `Super + Shift + Arrow Right` saat berada di browser untuk menukar jendelanya.

Sekarang coba `Super + Shift + T` untuk memulai monitor Activity. Itu akan muncul sebagai jendela floating. Anda bisa me-tile-nya menggunakan `Super + T` (dan tekan lagi untuk membuatnya floating lagi). Sekarang tekan `Super + Shift + F` untuk membuka manajer files. Anda akan memiliki pengaturan empat arah yang rapi:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Anda bernavigasi di antara jendela yang ingin Anda aktifkan dengan `Super + Arrow`. Ini akan mengalihkan fokus dan memindahkan kursor ke tengah aplikasi baru. Di tepi layar, ini berlanjut ke monitor di sisi tersebut.

Jika Anda menekan `Super + Shift + 2`, Anda akan memindahkan aplikasi yang sedang fokus ke workspace kedua. `Super + Shift + 1` memindahkannya kembali. (Dan `Super + Shift + Alt + 2` akan memindahkan aplikasi yang sedang fokus ke workspace kedua tanpa beralih ke sana).

Dengan lebih dari satu monitor, setiap monitor memiliki workspace 1 sampai 10 sendiri. `Super + 2` pergi ke workspace kedua dari monitor tempat Anda berada, dan top bar setiap monitor menunjukkan workspace-nya sendiri dan workspace yang sedang ditampilkannya. `Super + Tab` bergilir melalui workspace di monitor tempat Anda berada. `Super + Shift + Ctrl + Arrows` memindahkan jendela tempat Anda berada ke monitor ke arah tersebut, ke workspace yang sedang ditampilkannya, dan `Super + Shift + Alt + Arrows` memindahkan workspace tempat Anda berada ke monitor ke arah tersebut, di mana ia mengambil nomor yang sama jika kosong. Sebuah monitor mempertahankan workspace-nya saat Anda mencabutnya: workspace-workspace itu bergabung ke layar lain, diberi nomor setelah workspace yang sudah dimilikinya, dan kembali ke nomor lamanya saat monitor kembali.

Jika Anda menahan `Super` dan menggunakan mouse untuk mengklik sebuah jendela, Anda akan bisa mengatur ulang tempatnya berada. Jika Anda menahan `Super` dan menggunakan tombol kanan mouse, Anda bisa mengubah ukuran jendela dengan bebas.

Anda menutup jendela dengan `Super + W` atau `Super + Q` (dan menutup semua jendela dengan `Ctrl + Alt + Delete`).

Anda juga bisa masuk layar penuh dengan `Super + F` atau bahkan hanya selebar layar penuh (dengan top bar tetap terlihat) dengan `Super + Alt + F` atau layar penuh di dalam sebuah jendela dengan `Super + Ctrl + F` (bagus untuk YouTube!).

### Tata letak dwindle vs scrolling

Tata letak default Omarchy disebut dwindle. Ia membuat semua jendela yang Anda buka di satu workspace tetap terlihat setiap saat, bahkan jika harus mengecilkannya.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Tetapi Anda juga bisa memilih mengubah workspace menjadi tata letak scrolling di mana jendela-jendela berbaris berdampingan, melampaui tepi layar yang terlihat. Anda mengubah satu workspace menjadi tata letak ini melalui `Super + L`.

Menekan `Super + L` lagi mengubah workspace menjadi floating, di mana jendela tumpang tindih dengan bebas dan Anda menempatkannya sendiri, dan tekanan ketiga mengembalikannya ke dwindle. `Super + Alt + L` melewatinya ke arah sebaliknya. Jendela yang memang floating — jendela yang Anda keluarkan dengan `Super + T`, atau aplikasi yang selalu terbuka floating — tetap floating saat workspace kembali ke tiling. Top bar menandai workspace tempat Anda berada dengan tata letaknya: persegi untuk dwindle, lingkaran untuk scrolling, dan segitiga untuk floating. Mengklik tanda itu juga menggilir tata letaknya.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pilihannya per workspace, dan tetap bertahan. Jadi Anda bisa mempertahankan workspace 1 di dwindle untuk browsing dan workspace 2 di scrolling untuk code, dan keduanya akan kembali seperti itu setelah restart.

Jika Anda ingin menggunakan tata letak scrolling sebagai default, Anda bisa mengaturnya di `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Workspace floating

Workspace floating bekerja seperti desktop tradisional: jendela-jendela tumpang tindih, dan Anda memindahkan dan mengubah ukurannya sendiri. Setiap jendela mendapatkan titlebar dengan warna tema Anda, dengan tombol untuk minimize, maximize, dan close. `Super + M` juga me-minimize jendela yang fokus. Jendela yang di-minimize menunggu di dock; klik aplikasinya untuk membawanya kembali. Klik sebuah jendela untuk membawanya ke depan. Ubah ukurannya dari tepi atau sudut mana pun. Klik dua kali titlebar untuk memaksimalkan jendela sambil tetap menampilkan top bar, dan klik dua kali lagi untuk mendapatkan kembali ukuran lamanya.

Workspace floating juga menampilkan dock, dengan aplikasi yang Anda sematkan, semua yang sedang berjalan, dan grid berisi setiap aplikasi di balik tombol apps, yang juga dibuka oleh `Super + Alt + Space` dan _Apps_ di menu Omarchy. Klik kanan aplikasi di grid, atau tekan `Delete`, untuk menghapus instalasinya. Klik aplikasi untuk membukanya, atau membawa jendelanya ke depan; klik lagi untuk bergilir melalui jendela-jendelanya. Klik tengah membuka jendela baru. Seret ikon di sepanjang dock untuk memindahkannya; menyeret aplikasi yang sedang berjalan di antara aplikasi lain akan mempertahankannya di sana. Klik kanan untuk menyimpan aplikasi di dock, mengeluarkannya, atau menutupnya. Dock menyingkir dari jendela fullscreen. Klik kanan tombol apps untuk memindahkan dock ke tepi lain atau membuatnya bersembunyi sampai pointer mencapai tepinya. Posisinya juga ada di bawah _Appearance > Dock > Dock Position_, dan `omarchy dock position left` dan `omarchy dock autohide on` mengatur keduanya dari terminal. Aplikasi yang Anda simpan di dock tampak pudar saat tidak berjalan.

Workspace baru, dan workspace mana pun yang belum Anda beri tata letak sendiri dengan `Super + L`, menggunakan tata letak default. Mengubah default mengatur ulang setiap workspace tanpa jendela ke tata letak itu, sementara workspace dengan jendela di dalamnya tetap mempertahankan tata letak yang dimilikinya. Jendela yang di-minimize ke dock tetap dihitung sebagai jendela di workspace yang ditinggalkannya. Pilih di bawah _Appearance > Workspace Layout_: Tiling, Scrolling, atau Floating. `omarchy-hyprland-workspace-layout-default scrolling` mengaturnya dari terminal.

### Mengelompokkan jendela

Jendela bisa dikelompokkan menggunakan `Super + G`. Setelah Anda berada di dalam grup, setiap jendela yang Anda mulai saat grup itu aktif akan menjadi bagian dari grup. Anda bisa berpindah di antara jendela-jendela yang dikelompokkan ini menggunakan `Super + Ctrl + Arrow Left/Right` atau `Super + Alt + 1/2/3/4` untuk pergi langsung ke jendela yang dikelompokkan sesuai urutan.

Anda bisa memindahkan jendela keluar dari grup dengan `Super + Alt + G` atau membongkar seluruh grup dengan menekan `Super + G` lagi. Terakhir, Anda bisa memindahkan jendela di luar grup ke dalamnya dengan `Super + Alt + Arrows`.

### Mengeluarkan jendela

Anda bisa mengeluarkan jendela dari alokasi workspace-nya dengan `Super + O`. Itu akan menyematkannya sebagai jendela floating yang mengikuti Anda ke workspace mana pun yang Anda tuju. Bagus untuk pemutar video dan sejenisnya.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Workspace scratchpad

Ada workspace scratchpad berukuran penuh khusus yang melapisi workspace mana pun yang sedang Anda gunakan. Anda mengakses apa yang ada di sana menggunakan `Super + S`, dan Anda menempatkan jendela di sana menggunakan `Super + Alt + S`.

Ini bekerja dengan baik untuk kontrol atau terminal yang ingin Anda gunakan dengan cepat tanpa meninggalkan workspace saat ini.

### Konsol Quake

Terakhir, ada konsol Quake setengah tinggi yang turun di atas workspace mana pun yang sedang Anda gunakan. Aktif/nonaktifkan dengan `Super + Grave`, dan tempatkan jendela di sana menggunakan `Super + Shift + Grave`.

Konsol ini terbuka dengan agent default Anda siap digunakan. Saat konsol menampung satu jendela, ia turun sebagai panel di tengah, bukan membentang selebar layar. Tempatkan aplikasi kedua di sana dan ia kembali ke lebar penuh, sehingga keduanya memiliki ruang untuk duduk berdampingan.

Untuk memindahkan jendela keluar dari scratchpad atau konsol, kirim langsung ke workspace lain dengan sesuatu seperti `Super + Shift + 1`.

### Butuh waktu untuk terbiasa!

Butuh sedikit waktu untuk terbiasa menavigasi desktop Anda seperti ini, tetapi begitu Anda terbiasa, akan sulit untuk kembali ke pengalaman desktop tradisional yang digerakkan mouse!
