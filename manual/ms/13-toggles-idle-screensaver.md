# Togol, Melahu & Penyelamat Skrin

Banyak perkara yang anda ubah setiap hari sebenarnya bukanlah tetapan. Ia mod yang anda hidupkan selama sejam dan matikan semula: cahaya malam semasa anda bekerja lewat, jangan ganggu semasa anda membuat pembentangan, kekal terjaga semasa anda menonton sesuatu. Omarchy memanggilnya togol, dan semuanya berfungsi dengan cara yang sama — kekunci pintas, entri menu, dan perintah, semuanya memetik suis yang sama.

### Menu togol

`Super + Ctrl + O` membuka _Trigger > Toggle_ secara terus, atau anda boleh ke sana melalui menu Omarchy (`Super + Space`). Semua dalam senarai itu ialah suis yang boleh anda petik tanpa memikirkan di mana keadaannya disimpan. Suis untuk rupa desktop terletak bersebelahannya, di bawah _Appearance_.

Dari terminal, suis yang sama ialah `omarchy toggle <thing>`. Jalankan `omarchy toggle` sendiri untuk melihat keseluruhan kumpulan itu.

| Togol | Kekunci Pintas | Perintah |
| ------ | ------ | ------- |
| Cahaya malam | — | `omarchy toggle nightlight` |
| Senyapkan pemberitahuan | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Kekal terjaga (tiada kunci melahu) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Rakaman ranap | — | `omarchy toggle crash-capture` |
| Penyelamat skrin | — | `omarchy toggle screensaver` |
| Penyegerakan tema [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Bar menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Pad sentuh | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Skrin sentuh | — | `omarchy toggle touchscreen` |
| Gantung | — | `omarchy toggle suspend` |
| GPU hibrid | — | `omarchy toggle hybrid gpu` |

Suis pad sentuh, skrin sentuh, dan GPU hibrid terletak di bawah _Trigger > Hardware_ (`Super + Ctrl + H`) dan bukannya di bawah Toggle, kerana ia hanya muncul apabila anda benar-benar mempunyai perkakasan itu. Togol pad sentuh dan skrin sentuh kekal selepas Hyprland dimuat semula — nama peranti yang dilumpuhkan disimpan ke fail keadaan kecil yang dibaca Hyprland semasa permulaan untuk melumpuhkannya semula.

_Appearance_ menempatkan bar menu dan animasi, serta beberapa perkara yang bukan perintah `omarchy toggle` tetapi berfungsi sama: peratusan bateri dalam bar, susun atur ruang kerja lalai, dan di bawah _Windows_, jurang tetingkap (`Super + Shift + Backspace`) dan aspek segi empat sama 1 tetingkap (`Super + Ctrl + Backspace`).

Kebanyakan ini hanyalah fail bendera di bawah `~/.local/state/omarchy/toggles/`. Jika anda mahu bercabang berdasarkannya dalam skrip, `omarchy-toggle-enabled` memberikan kod keluar kepada anda dan bukannya memaksa anda mencarinya:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Bendera dinamakan mengikut keadaan mati — `screensaver-off`, `suspend-off`, `bar-off` — jadi kehadirannya bermaksud ciri itu dilumpuhkan.

### Penunjuk dalam bar

Apabila sesuatu mod hidup, anda mendapat glif kecil di tengah bar atas di sebelah jam. Itu widget penunjuk, dan ia membawa imlak, rakaman skrin, peringatan belum selesai, cahaya malam, jangan ganggu, dan kekal terjaga.

Penunjuk tidak aktif disembunyikan. Layangkan kursor di mana-mana pada bar dan ia akan muncul malap, jadi anda boleh klik satu untuk menghidupkannya tanpa mengetahui kekunci pintasnya. Mengklik yang aktif akan mematikannya semula. Jika anda lebih suka melihat kesemuanya sepanjang masa, tetapkan `alwaysShow` kepada `true` pada entri `omarchy.indicators` dalam `~/.config/omarchy/shell.json` — lihat [bar atas](05-the-top-bar.md) untuk cara widget bar dikonfigurasikan.

### Cahaya malam

Cahaya malam menghangatkan skrin kepada 4000K, dan menogolnya semula mengembalikannya kepada 6500K. Petiknya dari menu togol (`Super + Ctrl + O`) atau dengan `omarchy toggle nightlight`. Ia dipacu oleh hyprsunset, yang akan dimulakan oleh togol untuk anda jika ia belum berjalan.

Secara lalai hyprsunset tidak melakukan apa-apa langsung pada skrin anda. `~/.config/hypr/hyprsunset.conf` disertakan dengan profil identiti tepat supaya paparan kekal tidak disentuh sehingga anda meminta kehangatan. Jika anda lebih suka ia bertukar mengikut jam, gantikan itu dengan profil masa:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Kemudian mulakan hyprsunset semasa log masuk dengan menambah `o.launch_on_start("hyprsunset")` pada `~/.config/hypr/autostart.lua`. Pasangan 4000K/6500K yang digunakan oleh togol adalah tetap, jadi fail konfigurasi ialah tempatnya jika anda mahu suhu yang berbeza.

### Jangan ganggu

`Super + Ctrl + Alt + ,` menyenyapkan pemberitahuan. Tiada toast muncul semasa ia hidup, dan penunjuk loceng berpalang duduk dalam bar untuk mengingatkan anda mengapa desktop menjadi senyap.

Tiada apa yang hilang, walau bagaimanapun. Pemberitahuan yang disenyapkan ditahan: paparkan beberapa yang terakhir semula pada skrin dengan `Super + Shift + Alt + ,`. Lihat [notis](10-notices.md) untuk selebihnya.

Dua jenis mesej masih boleh menembusinya: toast pengesahan Omarchy sendiri untuk sesuatu yang baru anda lakukan ("Theme changed", "Screenshot saved"), dan amaran kritikal yang dihantar dari baris perintah. Aplikasi sembang yang menandakan semuanya sebagai kritikal untuk memaksa lalu di hadapan anda tidak layak.

### Melahu

Shell Omarchy memiliki tingkah laku melahu, dan pemasaan ialah blok `idle` peringkat atas dalam `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Kedua-dua nombor ialah saat yang dikira dari saat anda mula melahu — bukan antara satu sama lain. Jadi dengan lalai, penyelamat skrin muncul selepas dua minit setengah dan skrin kunci mengambil alih pada lima minit, sama ada penyelamat skrin berjalan atau tidak. Simpan fail dan shell akan mengambil pemasaan baharu dengan serta-merta.

Jika anda menutup penyelamat skrin sebelum tarikh akhir kunci, itu dikira sebagai aktiviti dan kunci yang belum selesai dibatalkan. Anda tidak akan terkunci hanya kerana menjenguk mesin anda.

Untuk berhenti mengunci semasa melahu sepenuhnya, `Super + Ctrl + I` — atau `omarchy toggle idle` — menghidupkan kekal terjaga, dan penunjuk cawan kopi muncul dalam bar. Itulah yang perlu dipetik sebelum pembentangan panjang atau binaan yang mahu anda tonton. Petik semula untuk kembali normal. `omarchy toggle idle status` mencetak keadaan semasa sebagai JSON jika anda memerlukannya dari skrip.

Ini tentang penguncian dan penyelamat skrin, bukan kuasa. Gantung dan hibernasi mempunyai persediaan sendiri dalam [tidur sistem](36-system-sleep.md).

### Penyelamat skrin

Penyelamat skrin Omarchy ialah seni ASCII yang berjalan melalui kesan teks rawak, satu instance bagi setiap monitor. Sebarang kekunci atau pergerakan tetikus akan menamatkannya.

Anda boleh memulakannya atas permintaan dari _System > Screensaver_ (`Super + Esc`), yang memaksanya muncul walaupun anda telah mematikan penyelamat skrin melahu. Tiada kekunci pintas terikat padanya secara lalai.

`omarchy toggle screensaver` ialah yang mematikan yang melahu itu, jika anda lebih suka terus dari bekerja kepada terkunci. Ia memerlukan terminal yang ia tahu cara mengkonfigurasinya — Alacritty, Foot, Ghostty, atau Kitty — dan akan memberitahu anda jika terminal lalai anda ialah yang lain.

Logo yang dilukisnya boleh anda ubah, di bawah _Appearance > Branding > Screensaver_. Muat naik png atau svg dan Omarchy menukarnya kepada ASCII. Lihat [penjenamaan](41-branding.md).

### Skrin kunci

`Super + Ctrl + L` mengunci mesin. Itu menjalankan skrin kunci dari shell Omarchy, mengosongkan paparan, menetapkan semula susun atur papan kekunci anda kepada yang pertama supaya anda tidak menaip kata laluan dalam abjad yang salah, dan — jika anda menjalankannya — mengunci 1Password semasa keluar.

Skrin kunci menerima kata laluan, dan ia juga akan menerima cap jari setelah anda menyediakannya. Itu, dan cara lain untuk mengesahkan, diliputi dalam [pengesahan perkakasan](37-hardware-authentication.md).
