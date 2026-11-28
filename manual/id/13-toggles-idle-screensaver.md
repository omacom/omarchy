# Toggle, Idle & Screensaver

Banyak hal yang kamu ubah sehari-hari sebenarnya bukan setting. Itu mode yang kamu nyalakan selama satu jam lalu matikan lagi: cahaya malam saat kamu bekerja sampai larut, jangan ganggu saat kamu presentasi, tetap terjaga saat kamu menonton sesuatu. Omarchy menyebutnya toggle, dan semuanya bekerja dengan cara yang sama — sebuah hotkey, sebuah entri menu, dan sebuah perintah, semuanya menekan sakelar yang sama.

### Menu toggle

`Super + Ctrl + O` membuka _Trigger > Toggle_ secara langsung, atau kamu bisa menuju ke sana dari menu Omarchy (`Super + Space`). Semua yang ada di daftar itu adalah sakelar yang bisa kamu balikkan tanpa perlu memikirkan di mana statusnya disimpan. Sakelar untuk tampilan desktop berada di sebelahnya, di bawah _Appearance_.

Dari terminal, sakelar yang sama adalah `omarchy toggle <thing>`. Jalankan `omarchy toggle` saja untuk melihat seluruh grupnya.

| Toggle | Hotkey | Perintah |
| ------ | ------ | ------- |
| Cahaya malam | — | `omarchy toggle nightlight` |
| Senyapkan notifikasi | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Tetap terjaga (tanpa kunci idle) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Penangkapan crash | — | `omarchy toggle crash-capture` |
| Screensaver | — | `omarchy toggle screensaver` |
| Sinkronisasi tema [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Bar menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Desktop layar penuh (tanpa bar, tanpa celah) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animasi, blur dan bayangan | — | `omarchy toggle animations` |
| Touchpad | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Layar sentuh | — | `omarchy device touchscreen` |
| Suspend | — | `omarchy toggle suspend` |
| GPU hybrid | — | `omarchy device gpu hybrid` |

Sakelar touchpad, layar sentuh, dan GPU hybrid berada di bawah _Trigger > Hardware_ (`Super + Ctrl + H`), bukan di bawah Toggle, karena sakelar tersebut hanya muncul saat kamu benar-benar memiliki perangkat keras itu. Sakelar touchpad dan layar sentuh tetap bertahan setelah Hyprland dimuat ulang — nama perangkat yang dinonaktifkan disimpan ke file status kecil yang dibaca Hyprland saat startup untuk menonaktifkannya lagi.

_Appearance_ berisi bar menu dan animasi, ditambah beberapa hal yang bukan perintah `omarchy toggle` tetapi berperilaku sama: persentase baterai di bar, tata letak workspace default, dan di bawah _Windows_, celah jendela (`Super + Shift + Backspace`) dan aspek persegi 1 jendela (`Super + Ctrl + Backspace`).

Saat Hyprland tidak memiliki GPU untuk menggambar dan sebagai gantinya melakukan render di CPU (llvmpipe), seperti di Mac yang GPU-nya belum didukung, di sebagian besar virtual machine, atau saat driver grafis gagal dimuat, Omarchy mematikan animasi, blur dan bayangan untuk sesi itu dan memberi tahumu sekali melalui notifikasi. _Appearance > Animations On_ mengembalikannya, dan Omarchy juga mengingatnya untuk sesi-sesi berikutnya.

Sebagian besar dari ini hanyalah file flag di bawah `~/.local/state/omarchy/toggles/`. Jika kamu ingin bercabang berdasarkan salah satunya di dalam script, `omarchy-toggle-enabled` memberimu kode exit tanpa membuatmu harus mencarinya sendiri:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Flag tersebut dinamai berdasarkan status mati — `screensaver-off`, `suspend-off`, `bar-off` — jadi keberadaannya berarti fitur tersebut dinonaktifkan.

### Indikator di bar

Saat sebuah mode aktif, kamu mendapatkan glyph kecil di tengah bar atas di sebelah jam. Itulah widget indikator, dan widget itu membawa perekaman layar, pengingat yang tertunda, cahaya malam, jangan ganggu, dan tetap terjaga, ditambah peringatan saat sudo tanpa kata sandi aktif atau seseorang terhubung ke sesi jarak jauh.

Indikator yang tidak aktif disembunyikan. Arahkan kursor ke mana saja di bar dan indikator itu akan muncul memudar dalam keadaan redup, sehingga kamu bisa mengklik salah satunya untuk menyalakannya tanpa mengetahui hotkey-nya. Mengklik indikator yang aktif akan mematikannya kembali. Jika kamu lebih suka melihat semuanya setiap saat, atur `alwaysShow` ke `true` pada entri `omarchy.indicators` di `~/.config/omarchy/shell.json` — lihat [bar atas](05-the-top-bar.md) untuk cara widget bar dikonfigurasi.

### Cahaya malam

Cahaya malam menghangatkan layar ke 4000K, dan membalikkannya lagi akan mengembalikannya ke 6500K. Balikkan dari menu toggle (`Super + Ctrl + O`) atau dengan `omarchy toggle nightlight`. Ini digerakkan oleh hyprsunset, yang akan dimulai oleh toggle untukmu jika belum berjalan.

Secara default, hyprsunset sama sekali tidak melakukan apa pun pada layarmu. `~/.config/hypr/hyprsunset.conf` disertakan dengan profil identitas justru agar tampilan tetap tidak tersentuh sampai kamu meminta kehangatan. Jika kamu lebih suka profil itu beralih berdasarkan jam, ganti dengan profil waktu:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Kemudian mulai hyprsunset saat login dengan menambahkan `o.launch_on_start("hyprsunset")` ke `~/.config/hypr/autostart.lua`. Pasangan 4000K/6500K yang digunakan oleh toggle bersifat tetap, jadi file konfigurasi adalah tempat yang kamu tuju jika kamu menginginkan suhu yang berbeda.

### Jangan ganggu

`Super + Ctrl + Alt + ,` membungkam notifikasi. Tidak ada toast yang muncul saat ini aktif, dan indikator lonceng yang dicoret berada di bar untuk mengingatkanmu mengapa desktop menjadi sunyi.

Namun, tidak ada yang hilang. Notifikasi yang dibungkam ditahan: tampilkan kembali beberapa notifikasi terakhir di layar dengan `Super + Shift + Alt + ,`. Lihat [notifikasi](10-notices.md) untuk sisanya.

Tiga jenis pesan masih bisa lolos: toast konfirmasi Omarchy sendiri untuk sesuatu yang baru saja kamu lakukan ("Theme changed", "Screenshot saved"), peringatan kritis yang dikirim dari command line, dan kode verifikasi. Aplikasi chat yang menandai semuanya sebagai kritis untuk memaksakan diri tampil di depanmu tidak termasuk.

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

Kedua angka tersebut adalah detik yang dihitung sejak saat kamu mulai idle — bukan dihitung dari satu sama lain. Jadi dengan nilai default, screensaver muncul setelah dua setengah menit dan layar kunci mengambil alih pada lima menit, apakah screensaver berjalan atau tidak. Simpan file tersebut dan shell akan mengambil waktu baru itu seketika.

Jika kamu menutup screensaver sebelum batas waktu kunci, itu dihitung sebagai aktivitas dan kunci yang tertunda dibatalkan. Kamu tidak akan terkunci hanya karena melirik mesimu.

Untuk menghentikan penguncian saat idle sepenuhnya, `Super + Ctrl + I` — atau `omarchy toggle idle` — menyalakan mode tetap terjaga, dan indikator cangkir kopi muncul di bar. Itulah yang harus ditekan sebelum presentasi panjang atau build yang ingin kamu tonton. Tekan lagi untuk kembali normal. `omarchy toggle idle status` mencetak status saat ini sebagai JSON jika kamu membutuhkannya dari script.

Ini tentang penguncian dan screensaver, bukan daya. Suspend dan hibernasi memiliki pengaturannya sendiri di [system sleep](36-system-sleep.md).

### Screensaver

Screensaver Omarchy adalah seni ASCII yang berjalan melalui efek teks acak, satu instance per monitor. Tombol apa pun atau gerakan mouse akan keluar darinya.

Kamu bisa memulainya sesuai permintaan dari _System > Screensaver_ (`Super + Esc`), yang memaksanya tampil bahkan jika kamu telah mematikan screensaver idle. Secara default tidak ada hotkey yang terikat padanya.

`omarchy toggle screensaver` adalah yang mematikan screensaver idle, jika kamu lebih suka langsung beralih dari bekerja ke terkunci. Tombol apa pun, klik, scroll atau gerakan mouse akan menutupnya.

Logo yang digambarnya bisa kamu ubah, di bawah _Appearance > Branding > Screensaver_. Unggah png atau svg dan Omarchy akan mengubahnya menjadi ASCII. Lihat [branding](41-branding.md).

### Layar kunci

`Super + Ctrl + L` mengunci mesin. Itu menjalankan layar kunci dari shell Omarchy, mengosongkan tampilan, mengatur ulang tata letak keyboard-mu ke yang pertama agar kamu tidak mengetik kata sandi dalam alfabet yang salah, dan — jika kamu menjalankannya — mengunci 1Password saat keluar.

Layar kunci menerima kata sandi, dan juga akan menerima sidik jari setelah kamu mengaturnya. Itu, dan cara lain untuk melakukan autentikasi, dibahas di [autentikasi perangkat keras](37-hardware-authentication.md).
