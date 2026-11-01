# Toggle, Idle & Screensaver

Banyak hal yang kamu ubah sehari-hari sebenarnya bukan pengaturan. Itu adalah mode yang kamu nyalakan selama satu jam lalu matikan lagi: cahaya malam saat kamu bekerja larut, jangan ganggu saat kamu presentasi, tetap terjaga saat kamu menonton sesuatu. Omarchy menyebutnya toggle, dan semuanya bekerja dengan cara yang sama — tombol pintas, entri menu, dan perintah, semuanya mengenai sakelar yang sama.

### Menu toggle

`Super + Ctrl + O` membuka _Trigger > Toggle_ secara langsung, atau kamu bisa berjalan ke sana dari menu Omarchy (`Super + Space`). Semua yang ada di daftar itu adalah sakelar yang bisa kamu alihkan tanpa memikirkan di mana keadaannya disimpan. Sakelar untuk tampilan desktop berada di sebelahnya, di bawah _Appearance_.

Dari terminal, sakelar yang sama adalah `omarchy toggle <thing>`. Jalankan `omarchy toggle` sendiri untuk melihat seluruh grupnya.

| Toggle | Tombol pintas | Perintah |
| ------ | ------ | ------- |
| Cahaya malam | — | `omarchy toggle nightlight` |
| Senyapkan notifikasi | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Tetap terjaga (tanpa kunci idle) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Tangkap crash | — | `omarchy toggle crash-capture` |
| Screensaver | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) sinkronisasi tema | — | `omarchy toggle theme sync` |
| Bilah menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Layar sentuh | — | `omarchy toggle touchscreen` |
| Suspend | — | `omarchy toggle suspend` |
| GPU hybrid | — | `omarchy toggle hybrid gpu` |

Sakelar touchpad, layar sentuh, dan GPU hybrid berada di bawah _Trigger > Hardware_ (`Super + Ctrl + H`) alih-alih di bawah Toggle, karena hanya muncul saat kamu memang punya perangkat keras itu. Sakelar touchpad dan layar sentuh tetap bertahan setelah Hyprland dimuat ulang — nama perangkat yang dinonaktifkan disimpan ke file state kecil yang dibaca Hyprland saat startup untuk menonaktifkannya lagi.

_Appearance_ menampung bilah menu dan animasi, plus beberapa hal yang bukan perintah `omarchy toggle` tetapi berperilaku sama: persentase baterai di bilah, layout workspace default, dan di bawah _Windows_, celah jendela (`Super + Shift + Backspace`) dan aspek persegi 1-jendela (`Super + Ctrl + Backspace`).

Sebagian besar ini hanyalah file flag di bawah `~/.local/state/omarchy/toggles/`. Jika kamu ingin bercabang berdasarkan salah satunya dalam skrip, `omarchy-toggle-enabled` memberimu kode exit alih-alih memaksamu mencarinya:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Flag-flag ini dinamai untuk keadaan mati — `screensaver-off`, `suspend-off`, `bar-off` — jadi keberadaannya berarti fitur tersebut dinonaktifkan.

### Indikator di bilah

Saat sebuah mode aktif, kamu mendapatkan glif kecil di tengah bilah atas di sebelah jam. Itulah widget indikator, dan widget ini membawa dikte, perekaman layar, pengingat yang tertunda, cahaya malam, jangan ganggu, dan tetap terjaga.

Indikator yang tidak aktif disembunyikan. Arahkan kursor ke mana saja di bilah dan indikator-indikator itu akan muncul redup, sehingga kamu bisa mengklik salah satunya untuk menyalakannya tanpa tahu tombol pintasnya. Mengklik indikator yang aktif akan mematikannya kembali. Jika kamu lebih suka melihat semuanya sepanjang waktu, atur `alwaysShow` menjadi `true` pada entri `omarchy.indicators` di `~/.config/omarchy/shell.json` — lihat [bilah atas](05-the-top-bar.md) untuk cara widget bilah dikonfigurasi.

### Cahaya malam

Cahaya malam menghangatkan layar ke 4000K, dan mengalihkannya lagi mengembalikannya ke 6500K. Alihkan dari menu toggle (`Super + Ctrl + O`) atau dengan `omarchy toggle nightlight`. Ini digerakkan oleh hyprsunset, yang akan dijalankan oleh toggle untukmu jika belum berjalan.

Secara default hyprsunset tidak melakukan apa pun pada layarmu sama sekali. `~/.config/hypr/hyprsunset.conf` disertai profil identitas justru agar tampilan tetap tidak tersentuh sampai kamu meminta kehangatan. Jika kamu lebih suka profil ini beralih mengikuti jam, ganti itu dengan profil waktu:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Lalu jalankan hyprsunset saat login dengan menambahkan `o.launch_on_start("hyprsunset")` ke `~/.config/hypr/autostart.lua`. Pasangan 4000K/6500K yang digunakan toggle ini tetap, jadi file konfigurasi adalah tempat yang kamu tuju jika kamu menginginkan suhu yang berbeda.

### Jangan ganggu

`Super + Ctrl + Alt + ,` menyenyapkan notifikasi. Tidak ada toast yang muncul saat ini aktif, dan indikator lonceng yang dicoret berada di bilah untuk mengingatkanmu mengapa desktop menjadi senyap.

Namun, tidak ada yang hilang. Notifikasi yang disenyapkan ditahan: tampilkan kembali beberapa yang terakhir di layar dengan `Super + Shift + Alt + ,`. Lihat [pemberitahuan](10-notices.md) untuk selebihnya.

Dua jenis pesan tetap bisa lolos: toast konfirmasi Omarchy sendiri untuk sesuatu yang baru saja kamu lakukan ("Theme changed", "Screenshot saved"), dan peringatan kritis yang dikirim dari baris perintah. Aplikasi chat yang menandai semuanya sebagai kritis untuk memaksa tampil di depanmu tidak termasuk.

### Idle

Shell Omarchy mengendalikan perilaku idle, dan waktunya adalah blok `idle` tingkat atas di `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Kedua angka adalah detik yang dihitung dari saat kamu mulai idle — bukan dari satu sama lain. Jadi dengan default, screensaver muncul setelah dua setengah menit dan layar kunci mengambil alih pada lima menit, apakah screensaver berjalan atau tidak. Simpan file dan shell akan langsung mengambil waktu baru itu.

Jika kamu menutup screensaver sebelum batas waktu kunci, itu dihitung sebagai aktivitas dan kunci yang tertunda dibatalkan. Kamu tidak akan terkunci hanya karena melirik mesinmu.

Untuk menghentikan penguncian saat idle sepenuhnya, `Super + Ctrl + I` — atau `omarchy toggle idle` — mengaktifkan tetap terjaga, dan indikator cangkir kopi muncul di bilah. Itulah yang harus ditekan sebelum presentasi panjang atau build yang ingin kamu tonton. Tekan lagi untuk kembali normal. `omarchy toggle idle status` mencetak keadaan saat ini sebagai JSON jika kamu membutuhkannya dari skrip.

Ini tentang penguncian dan screensaver, bukan daya. Suspend dan hibernasi memiliki pengaturannya sendiri di [tidur sistem](36-system-sleep.md).

### Screensaver

Screensaver Omarchy adalah seni ASCII yang berjalan melalui efek teks acak, satu instance per monitor. Tombol apa pun atau gerakan mouse akan keluar darinya.

Kamu bisa menjalankannya sesuai permintaan dari _System > Screensaver_ (`Super + Esc`), yang memaksanya tampil bahkan jika kamu telah mematikan screensaver idle. Secara default tidak ada tombol pintas yang terikat padanya.

`omarchy toggle screensaver` adalah yang mematikan yang idle, jika kamu lebih suka langsung dari bekerja ke terkunci. Tombol apa pun, klik, scroll, atau gerakan mouse akan menutupnya.

Logo yang digambarnya bisa kamu ubah, di bawah _Appearance > Branding > Screensaver_. Unggah png atau svg dan Omarchy akan mengonversinya ke ASCII. Lihat [branding](41-branding.md).

### Layar kunci

`Super + Ctrl + L` mengunci mesin. Itu menjalankan layar kunci dari shell Omarchy, mengosongkan tampilan, mengatur ulang layout keyboard-mu ke yang pertama agar kamu tidak mengetik kata sandi dalam alfabet yang salah, dan — jika kamu menjalankannya — mengunci 1Password saat keluar.

Layar kunci menerima kata sandi, dan juga akan menerima sidik jari setelah kamu mengaturnya. Itu, dan cara lain untuk mengautentikasi, dibahas di [autentikasi perangkat keras](37-hardware-authentication.md).
