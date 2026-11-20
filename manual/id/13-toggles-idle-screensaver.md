# Toggle, Idle & Screensaver

Banyak hal yang kamu ubah sehari-hari sebenarnya bukan pengaturan. Itu mode yang kamu nyalakan selama satu jam lalu matikan lagi: lampu malam saat kamu bekerja sampai larut, jangan ganggu saat kamu presentasi, tetap terjaga saat kamu menonton sesuatu. Omarchy menyebutnya toggle, dan semuanya bekerja dengan cara yang sama — tombol pintas, entri menu, dan perintah, semuanya mengarah ke sakelar yang sama.

### Menu toggle

`Super + Ctrl + O` membuka _Trigger > Toggle_ secara langsung, atau kamu bisa mencapainya dari menu Omarchy (`Super + Space`). Semua yang ada di daftar itu adalah sakelar yang bisa kamu balik tanpa memikirkan di mana statusnya disimpan. Sakelar untuk tampilan desktop berada di sebelahnya, di bawah _Appearance_.

Dari terminal, sakelar yang sama adalah `omarchy toggle <thing>`. Jalankan `omarchy toggle` saja untuk melihat seluruh grupnya.

| Toggle | Tombol Pintas | Perintah |
| ------ | ------ | ------- |
| Lampu malam | — | `omarchy toggle nightlight` |
| Senyapkan notifikasi | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Tetap terjaga (tanpa kunci idle) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Penangkapan crash | — | `omarchy toggle crash-capture` |
| Screensaver | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) sinkronisasi tema | — | `omarchy toggle theme sync` |
| Bilah menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Layar sentuh | — | `omarchy device touchscreen` |
| Suspend | — | `omarchy toggle suspend` |
| GPU hybrid | — | `omarchy toggle hybrid gpu` |

Sakelar touchpad, layar sentuh, dan GPU hybrid berada di bawah _Trigger > Hardware_ (`Super + Ctrl + H`) bukan di bawah Toggle, karena hanya muncul saat kamu benar-benar memiliki perangkat keras tersebut. Sakelar touchpad dan layar sentuh tetap bertahan setelah Hyprland dimuat ulang — nama perangkat yang dinonaktifkan disimpan ke file status kecil yang dibaca Hyprland saat startup untuk menonaktifkannya lagi.

_Appearance_ menampung bilah menu dan animasi, plus beberapa hal yang bukan perintah `omarchy toggle` tetapi berperilaku sama: persentase baterai di bilah, tata letak workspace default, dan di bawah _Windows_, celah jendela (`Super + Shift + Backspace`) dan aspek persegi 1 jendela (`Super + Ctrl + Backspace`).

Saat Hyprland tidak memiliki GPU untuk menggambar dan merender di CPU sebagai gantinya (llvmpipe), seperti di Mac yang GPU-nya belum didukung, di sebagian besar mesin virtual, atau saat driver grafis gagal dimuat, Omarchy mematikan animasi, blur, dan bayangan untuk sesi itu dan memberi tahumu sekali lewat notifikasi. _Appearance > Animations On_ mengembalikannya, dan Omarchy mengingatnya juga untuk sesi berikutnya.

Sebagian besar ini hanyalah file flag di bawah `~/.local/state/omarchy/toggles/`. Jika kamu ingin bercabang berdasarkan salah satunya di dalam skrip, `omarchy-toggle-enabled` memberimu kode keluar alih-alih membuatmu mencarinya:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

File flag diberi nama berdasarkan status nonaktif — `screensaver-off`, `suspend-off`, `bar-off` — jadi keberadaannya berarti fitur tersebut dinonaktifkan.

### Indikator di bilah

Saat sebuah mode aktif, kamu mendapatkan glif kecil di tengah bilah atas di sebelah jam. Itulah widget indikator, dan widget ini menampung dikte, perekaman layar, pengingat yang tertunda, lampu malam, jangan ganggu, dan tetap terjaga.

Indikator yang tidak aktif disembunyikan. Arahkan kursor ke mana saja di bilah dan indikator itu akan muncul redup, jadi kamu bisa mengklik salah satunya untuk menyalakannya tanpa mengetahui tombol pintasnya. Mengklik indikator yang aktif akan mematikannya kembali. Jika kamu lebih suka melihat semuanya setiap saat, atur `alwaysShow` ke `true` pada entri `omarchy.indicators` di `~/.config/omarchy/shell.json` — lihat [bilah atas](05-the-top-bar.md) untuk cara widget bilah dikonfigurasi.

### Lampu malam

Lampu malam menghangatkan layar ke 4000K, dan mengaktifkannya lagi mengembalikannya ke 6500K. Balik dari menu toggle (`Super + Ctrl + O`) atau dengan `omarchy toggle nightlight`. Ini digerakkan oleh hyprsunset, yang akan dijalankan oleh toggle untukmu jika belum berjalan.

Secara default hyprsunset tidak melakukan apa pun sama sekali pada layarmu. `~/.config/hypr/hyprsunset.conf` disertakan dengan profil identitas justru agar tampilan tetap tidak tersentuh sampai kamu meminta kehangatan. Jika kamu lebih suka lampu ini beralih berdasarkan jam, ganti itu dengan profil waktu:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Lalu jalankan hyprsunset saat login dengan menambahkan `o.launch_on_start("hyprsunset")` ke `~/.config/hypr/autostart.lua`. Pasangan 4000K/6500K yang digunakan oleh toggle bersifat tetap, jadi file konfigurasi adalah tempatmu jika kamu menginginkan suhu yang berbeda.

### Jangan ganggu

`Super + Ctrl + Alt + ,` menyenyapkan notifikasi. Tidak ada toast yang muncul saat ini aktif, dan indikator lonceng yang dicoret berada di bilah untuk mengingatkanmu mengapa desktop menjadi senyap.

Tidak ada yang hilang, kok. Notifikasi yang disenyapkan ditahan: tampilkan kembali beberapa yang terakhir di layar dengan `Super + Shift + Alt + ,`. Lihat [pemberitahuan](10-notices.md) untuk selebihnya.

Dua jenis pesan tetap bisa masuk: toast konfirmasi Omarchy sendiri untuk sesuatu yang baru saja kamu lakukan ("Theme changed", "Screenshot saved"), dan peringatan kritis yang dikirim dari baris perintah. Aplikasi chat yang menandai semuanya sebagai kritis untuk memaksa masuk ke hadapanmu tidak memenuhi syarat.

### Idle

Shell Omarchy memiliki perilaku idle, dan waktunya adalah blok `idle` tingkat atas di `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Kedua angka itu adalah detik yang dihitung dari saat kamu mulai idle — bukan dari satu sama lain. Jadi dengan default, screensaver muncul setelah dua setengah menit dan layar kunci mengambil alih pada lima menit, terlepas dari apakah screensaver berjalan atau tidak. Simpan file dan shell akan mengambil waktu baru itu segera.

Jika kamu menutup screensaver sebelum batas waktu kunci, itu dihitung sebagai aktivitas dan kunci yang tertunda dibatalkan. Kamu tidak akan terkunci hanya karena melirik mesinmu.

Untuk menghentikan penguncian saat idle sepenuhnya, `Super + Ctrl + I` — atau `omarchy toggle idle` — mengaktifkan tetap terjaga, dan indikator cangkir kopi muncul di bilah. Itulah yang harus ditekan sebelum presentasi panjang atau build yang ingin kamu tonton. Tekan lagi untuk kembali normal. `omarchy toggle idle status` mencetak status saat ini sebagai JSON jika kamu membutuhkannya dari skrip.

Ini tentang penguncian dan screensaver, bukan daya. Suspend dan hibernasi memiliki pengaturannya sendiri di [tidur sistem](36-system-sleep.md).

### Screensaver

Screensaver Omarchy adalah seni ASCII yang berjalan melalui efek teks acak, satu instans per monitor. Tombol apa saja atau gerakan mouse akan keluar darinya.

Kamu bisa menjalankannya sesuai permintaan dari _System > Screensaver_ (`Super + Esc`), yang memaksanya muncul bahkan jika kamu telah mematikan screensaver idle. Tidak ada tombol pintas yang terikat padanya secara default.

`omarchy toggle screensaver` adalah yang mematikan yang idle, jika kamu lebih suka langsung dari bekerja ke terkunci. Tombol apa saja, klik, scroll, atau gerakan mouse menutupnya.

Logo yang digambarnya bisa kamu ubah, di bawah _Appearance > Branding > Screensaver_. Unggah png atau svg dan Omarchy mengubahnya menjadi ASCII. Lihat [branding](41-branding.md).

### Layar kunci

`Super + Ctrl + L` mengunci mesin. Itu menjalankan layar kunci dari shell Omarchy, mengosongkan tampilan, mengatur ulang tata letak keyboard-mu ke yang pertama agar kamu tidak mengetik kata sandimu dalam alfabet yang salah, dan — jika kamu menjalankannya — mengunci 1Password saat keluar.

Layar kunci menerima kata sandi, dan juga akan menerima sidik jari setelah kamu mengaturnya. Itu, dan cara lain untuk autentikasi, dibahas di [autentikasi perangkat keras](37-hardware-authentication.md).
