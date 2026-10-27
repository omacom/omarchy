# Toggle, Idle & Screensaver

Banyak hal yang kamu ubah sehari-hari sebenarnya bukan sebuah pengaturan. Itu adalah mode yang kamu aktifkan selama satu jam lalu kamu matikan lagi: cahaya malam saat kamu bekerja sampai larut, jangan ganggu saat kamu presentasi, tetap terjaga saat kamu sedang menonton sesuatu. Omarchy menyebutnya toggle, dan semuanya bekerja dengan cara yang sama — sebuah hotkey, sebuah entri menu, dan sebuah perintah, semuanya menyentuh sakelar yang sama.

### Menu toggle

`Super + Ctrl + O` membuka _Trigger > Toggle_ secara langsung, atau kamu bisa berjalan ke sana dari menu Omarchy (`Super + Space`). Semua yang ada di daftar itu adalah sakelar yang bisa kamu balik tanpa memikirkan di mana statusnya tinggal. Sakelar untuk tampilan desktop berada di sampingnya, di bawah _Appearance_.

Dari terminal, sakelar yang sama adalah `omarchy toggle <thing>`. Jalankan `omarchy toggle` sendiri untuk melihat seluruh grupnya.

| Toggle | Hotkey | Perintah |
| ------ | ------ | ------- |
| Cahaya malam | — | `omarchy toggle nightlight` |
| Senyapkan notifikasi | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Tetap terjaga (tanpa kunci idle) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Penangkapan crash | — | `omarchy toggle crash-capture` |
| Screensaver | — | `omarchy toggle screensaver` |
| Sinkronisasi tema [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Bilah menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Layar sentuh | — | `omarchy toggle touchscreen` |
| Suspend | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Sakelar touchpad, layar sentuh, dan hybrid GPU tinggal di bawah _Trigger > Hardware_ (`Super + Ctrl + H`) bukan di bawah Toggle, karena mereka hanya muncul saat kamu benar-benar memiliki perangkat keras tersebut. Sakelar touchpad dan layar sentuh bertahan setelah Hyprland dimuat ulang — nama perangkat yang dinonaktifkan disimpan ke file status kecil yang dibaca Hyprland saat startup untuk menonaktifkannya lagi.

_Appearance_ menampung bilah menu dan animasi, ditambah beberapa hal yang bukan perintah `omarchy toggle` tetapi berperilaku sama: persentase baterai di bilah, tata letak workspace default, dan di bawah _Windows_, celah jendela (`Super + Shift + Backspace`) dan aspek persegi 1-jendela (`Super + Ctrl + Backspace`).

Sebagian besar dari ini hanyalah file flag di bawah `~/.local/state/omarchy/toggles/`. Jika kamu ingin bercabang berdasarkan salah satunya dalam sebuah skrip, `omarchy-toggle-enabled` memberimu kode keluar alih-alih membuatmu mencarinya:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Flag-flag tersebut dinamai untuk status mati — `screensaver-off`, `suspend-off`, `bar-off` — jadi keberadaannya berarti fitur tersebut dinonaktifkan.

### Indikator di bilah

Saat sebuah mode aktif, kamu mendapatkan glyph kecil di tengah bilah atas di samping jam. Itu adalah widget indikator, dan ia membawa dikte, perekaman layar, pengingat yang tertunda, cahaya malam, jangan ganggu, dan tetap terjaga.

Indikator yang tidak aktif disembunyikan. Arahkan kursor ke mana saja di bilah dan mereka memudar masuk dalam keadaan redup, jadi kamu bisa mengklik salah satunya untuk menyalakannya tanpa mengetahui hotkey-nya. Mengklik yang aktif akan mematikannya kembali. Jika kamu lebih suka melihat semuanya setiap saat, atur `alwaysShow` ke `true` pada entri `omarchy.indicators` di `~/.config/omarchy/shell.json` — lihat [bilah atas](05-the-top-bar.md) untuk cara widget bilah dikonfigurasi.

### Cahaya malam

Cahaya malam menghangatkan layar ke 4000K, dan men-toggle-nya lagi mengembalikannya ke 6500K. Balik dari menu toggle (`Super + Ctrl + O`) atau dengan `omarchy toggle nightlight`. Ini digerakkan oleh hyprsunset, yang akan dimulai oleh toggle untukmu jika belum berjalan.

Secara default hyprsunset tidak melakukan apa pun sama sekali pada layarmu. `~/.config/hypr/hyprsunset.conf` disertai dengan profil identitas tepat agar tampilan tetap tidak tersentuh sampai kamu meminta kehangatan. Jika kamu lebih suka ia beralih mengikuti jam, ganti itu dengan profil waktu:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Lalu mulai hyprsunset saat login dengan menambahkan `o.launch_on_start("hyprsunset")` ke `~/.config/hypr/autostart.lua`. Pasangan 4000K/6500K yang digunakan oleh toggle bersifat tetap, jadi file konfigurasi adalah tempat yang kamu tuju jika kamu menginginkan suhu yang berbeda.

### Jangan ganggu

`Super + Ctrl + Alt + ,` membungkam notifikasi. Tidak ada toast yang muncul saat ini aktif, dan indikator bel yang dicoret berada di bilah untuk mengingatkanmu mengapa desktop menjadi sunyi.

Namun tidak ada yang hilang. Notifikasi yang dibungkam ditahan: tampilkan kembali beberapa yang terakhir di layar dengan `Super + Shift + Alt + ,`. Lihat [pemberitahuan](10-notices.md) untuk sisanya.

Dua jenis pesan tetap bisa menembus: toast konfirmasi Omarchy sendiri untuk sesuatu yang baru saja kamu lakukan ("Theme changed", "Screenshot saved"), dan peringatan kritis yang dikirim dari baris perintah. Aplikasi chat yang menandai semuanya kritis untuk memaksakan diri di depanmu tidak memenuhi syarat.

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

Kedua angka adalah detik yang dihitung dari saat kamu menjadi idle — bukan dari satu sama lain. Jadi dengan default, screensaver muncul setelah dua setengah menit dan layar kunci mengambil alih pada lima menit, terlepas dari apakah screensaver berjalan atau tidak. Simpan file dan shell mengambil waktu baru tersebut segera.

Jika kamu menutup screensaver sebelum batas waktu kunci, itu dihitung sebagai aktivitas dan kunci yang tertunda dibatalkan. Kamu tidak terkunci hanya karena melirik mesimu.

Untuk berhenti mengunci saat idle sepenuhnya, `Super + Ctrl + I` — atau `omarchy toggle idle` — membalik tetap terjaga menjadi aktif, dan indikator cangkir kopi muncul di bilah. Itu yang harus ditekan sebelum presentasi panjang atau build yang ingin kamu tonton. Tekan lagi untuk kembali normal. `omarchy toggle idle status` mencetak status saat ini sebagai JSON jika kamu membutuhkannya dari sebuah skrip.

Ini tentang penguncian dan screensaver, bukan daya. Suspend dan hibernasi memiliki pengaturannya sendiri di [tidur sistem](36-system-sleep.md).

### Screensaver

Screensaver Omarchy adalah seni ASCII yang berjalan melalui efek teks acak, satu instans per monitor. Tombol apa pun atau gerakan mouse akan keluar darinya.

Kamu bisa memulainya sesuai permintaan dari _System > Screensaver_ (`Super + Esc`), yang memaksanya muncul bahkan jika kamu telah mematikan screensaver idle. Tidak ada hotkey yang terikat padanya secara default.

`omarchy toggle screensaver` adalah yang mematikan yang idle, jika kamu lebih suka langsung dari bekerja ke terkunci. Ia membutuhkan terminal yang ia tahu cara mengkonfigurasinya — Alacritty, Foot, Ghostty, atau Kitty — dan akan memberitahumu demikian jika terminal default-mu adalah sesuatu yang lain.

Logo yang digambarnya adalah milikmu untuk diubah, di bawah _Appearance > Branding > Screensaver_. Unggah png atau svg dan Omarchy mengubahnya menjadi ASCII. Lihat [branding](41-branding.md).

### Layar kunci

`Super + Ctrl + L` mengunci mesin. Itu menjalankan layar kunci dari shell Omarchy, mengosongkan tampilan, mengatur ulang tata letak keyboard-mu ke yang pertama agar kamu tidak mengetik kata sandimu dalam alfabet yang salah, dan — jika kamu menjalankannya — mengunci 1Password dalam perjalanan keluar.

Layar kunci menerima kata sandi, dan ia juga akan menerima sidik jari setelah kamu mengaturnya. Itu, dan cara lain untuk mengautentikasi, dibahas di [autentikasi perangkat keras](37-hardware-authentication.md).
