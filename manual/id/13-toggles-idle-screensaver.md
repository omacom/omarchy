# Pengalihan, Menganggur & Screensaver

Banyak dari apa yang Anda ubah dari hari ke hari sebenarnya bukan pengaturan. Itu adalah mode yang Anda nyalakan selama satu jam dan matikan lagi: lampu malam saat Anda bekerja larut, jangan ganggu saat Anda mempresentasikan, tetap bangun saat Anda menonton sesuatu. Omarchy menyebutnya pengalihan, dan semuanya bekerja dengan cara yang sama — hotkey, entri menu, dan perintah, semuanya mengenai sakelar yang sama.

### Menu pengalihan

`Super + Ctrl + O` membuka _Pemicu > Alihkan_ secara langsung, atau Anda dapat berjalan ke sana dari menu Omarchy (`Super + Space`). Semua dalam daftar itu adalah sakelar yang dapat Anda balik tanpa memikirkan di mana statusnya hidup. Sakelar untuk bagaimana desktop terlihat berada di sebelahnya, di bawah _Pemicu > Tampilan_.

Dari terminal, sakelar yang sama adalah `omarchy toggle <thing>`. Jalankan `omarchy toggle` sendiri untuk melihat seluruh grup.

| Pengalihan | Hotkey | Perintah |
| ------ | ------ | ------- |
| Lampu malam | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Bisukan notifikasi | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Tetap bangun (tanpa kunci menganggur) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Tangkap crash | — | `omarchy toggle crash-capture` |
| Screensaver | — | `omarchy toggle screensaver` |
| Sinkron tema [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Bilah menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Layar sentuh | — | `omarchy toggle touchscreen` |
| Tangguhkan | — | `omarchy toggle suspend` |
| GPU hibrida | — | `omarchy toggle hybrid gpu` |

Sakelar touchpad, layar sentuh, dan GPU hibrida hidup di bawah _Pemicu > Perangkat Keras_ (`Super + Ctrl + H`) alih-alih di bawah Alihkan, karena mereka hanya muncul ketika Anda benar-benar memiliki perangkat keras itu. Yang touchpad dan layar sentuh bertahan dari pemuatan ulang Hyprland — nama perangkat yang dinonaktifkan disimpan ke berkas status kecil yang dibaca Hyprland saat startup untuk menonaktifkannya lagi.

_Pemicu > Tampilan_ menampung bilah menu dan animasi, plus beberapa hal yang bukan perintah `omarchy toggle` tetapi berperilaku sama: persentase baterai di bilah, tata letak ruang kerja bawaan, celah jendela (`Super + Shift + Backspace`), dan aspek kotak 1 jendela (`Super + Ctrl + Backspace`).

Sebagian besar dari ini hanyalah berkas bendera di bawah `~/.local/state/omarchy/toggles/`. Jika Anda ingin bercabang pada satu dalam skrip, `omarchy-toggle-enabled` memberi Anda kode keluar alih-alih membuat Anda mencarinya:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Bendera dinamai untuk status mati — `screensaver-off`, `suspend-off`, `bar-off` — sehingga keberadaannya berarti fitur dinonaktifkan.

### Indikator di bilah

Ketika mode menyala, Anda mendapatkan glif kecil di tengah bilah atas di samping jam. Itu adalah widget indikator, dan ia membawa dikte, perekaman layar, pengingat tertunda, lampu malam, jangan ganggu, dan tetap bangun.

Indikator yang tidak aktif disembunyikan. Arahkan area di sekitar mereka dan mereka memudar dalam keadaan redup, sehingga Anda dapat mengklik satu untuk menyalakannya tanpa mengetahui hotkey-nya. Mengklik yang aktif mematikannya kembali. Jika Anda lebih suka melihat mereka semua sepanjang waktu, atur `alwaysShow` ke `true` pada entri `omarchy.indicators` dalam `~/.config/omarchy/shell.json` — lihat [bilah atas](05-the-top-bar.md) untuk bagaimana widget bilah dikonfigurasi.

### Lampu malam

`Super + Ctrl + N` menghangatkan layar ke 4000K, dan menekannya lagi mengembalikannya ke 6500K. Ia digerakkan oleh hyprsunset, yang dimulai pengalihan untuk Anda jika belum berjalan.

Secara bawaan hyprsunset tidak melakukan apa pun pada layar Anda sama sekali. `~/.config/hypr/hyprsunset.conf` dikirim dengan profil identitas persis sehingga tampilan tetap tidak tersentuh sampai Anda meminta kehangatan. Jika Anda lebih suka ia beralih berdasarkan jam, ganti itu dengan profil waktu:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Lalu mulai hyprsunset saat login dengan menambahkan `o.launch_on_start("hyprsunset")` ke `~/.config/hypr/autostart.lua`. Pasangan 4000K/6500K yang digunakan oleh pengalihan bersifat tetap, sehingga berkas konfigurasi adalah tempat Anda pergi jika Anda menginginkan suhu yang berbeda.

### Jangan ganggu

`Super + Ctrl + ,` membisukan notifikasi. Tidak ada toast yang muncul saat ia menyala, dan indikator lonceng yang dicoret berada di bilah untuk mengingatkan Anda mengapa desktop menjadi sunyi.

Namun tidak ada yang hilang. Notifikasi yang dibisukan ditulis langsung ke riwayat notifikasi Anda, yang persis merupakan catatan yang Anda inginkan ketika Anda kembali dan bertanya-tanya apa yang Anda lewatkan. Buka dengan `Super + Shift + Alt + ,`. Lihat [pemberitahuan](10-notices.md) untuk sisa cerita notifikasi.

Dua jenis pesan masih bisa lolos: toast konfirmasi Omarchy sendiri untuk sesuatu yang baru saja Anda lakukan ("Theme changed", "Screenshot saved"), dan peringatan kritis yang dikirim dari baris perintah. Aplikasi chat yang menandai semuanya kritis untuk memaksa jalan mereka di depan Anda tidak memenuhi syarat.

### Menganggur

Shell Omarchy memiliki perilaku menganggur, dan pengaturannya adalah blok `idle` tingkat atas dalam `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Kedua angka adalah detik yang dihitung dari saat Anda menganggur — bukan dari satu sama lain. Jadi dengan bawaan, screensaver muncul setelah dua setengah menit dan layar kunci mengambil alih pada lima menit, apakah screensaver berjalan atau tidak. Simpan berkas dan shell mengambil pengaturan waktu baru dengan segera.

Jika Anda menutup screensaver sebelum batas waktu kunci, itu terhitung sebagai aktivitas dan kunci tertunda dibatalkan. Anda tidak terkunci hanya karena melirik mesin Anda.

Untuk menghentikan penguncian saat menganggur sepenuhnya, `Super + Ctrl + I` — atau `omarchy toggle idle` — menyalakan tetap bangun, dan indikator cangkir kopi muncul di bilah. Itulah yang harus ditekan sebelum presentasi panjang atau build yang ingin Anda tonton. Tekan lagi untuk kembali normal. `omarchy toggle idle status` mencetak status saat ini sebagai JSON jika Anda membutuhkannya dari skrip.

Ini tentang penguncian dan screensaver, bukan daya. Penangguhan dan hibernasi memiliki penyiapan sendiri dalam [tidur sistem](36-system-sleep.md).

### Screensaver

Screensaver Omarchy adalah seni ASCII yang berjalan melalui efek teks acak, satu instance per monitor. Tombol apa pun atau gerakan mouse keluar darinya.

Anda dapat memulainya sesuai permintaan dari _Sistem > Screensaver_ (`Super + Esc`), yang memaksanya muncul bahkan jika Anda telah mematikan screensaver menganggur. Tidak ada hotkey yang terikat padanya secara bawaan.

`omarchy toggle screensaver` adalah yang mematikan yang menganggur, jika Anda lebih suka langsung pergi dari bekerja ke terkunci. Ia memerlukan terminal yang ia tahu cara mengkonfigurasinya — Alacritty, Foot, Ghostty, atau Kitty — dan akan memberi tahu Anda demikian jika terminal bawaan Anda adalah sesuatu yang lain.

Logo yang digambarnya adalah milik Anda untuk diubah, di bawah _Gaya > Screensaver_. Unggah png atau svg dan Omarchy mengonversinya menjadi ASCII. Lihat [branding](41-branding.md).

### Layar kunci

`Super + Ctrl + L` mengunci mesin. Itu menjalankan layar kunci dari shell Omarchy, mengosongkan tampilan, mengatur ulang tata letak keyboard Anda ke yang pertama sehingga Anda tidak mengetik kata sandi dalam alfabet yang salah, dan — jika Anda menjalankannya — mengunci 1Password saat keluar.

Layar kunci menggunakan kata sandi, dan ia juga akan menggunakan sidik jari begitu Anda telah mengaturnya. Itu, dan cara lain untuk mengautentikasi, dibahas dalam [autentikasi perangkat keras](37-hardware-authentication.md).
