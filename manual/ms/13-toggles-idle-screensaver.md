# Togol, Keadaan Terbiar & Penyelamat Skrin

Banyak perkara yang anda ubah dari hari ke hari bukanlah benar-benar satu tetapan. Ia mod yang anda hidupkan selama sejam dan matikan semula: cahaya malam semasa anda bekerja lewat, jangan ganggu semasa anda membuat pembentangan, kekal berjaga semasa anda menonton sesuatu. Omarchy memanggilnya togol, dan semuanya berfungsi dengan cara yang sama — kekunci pintas, entri menu, dan perintah, semuanya mengenai suis yang sama.

### Menu togol

`Super + Ctrl + O` membuka _Trigger > Toggle_ secara langsung, atau anda boleh pergi ke sana melalui menu Omarchy (`Super + Space`). Semua dalam senarai itu ialah suis yang boleh anda togol tanpa memikirkan di mana keadaannya disimpan. Suis untuk rupa desktop terletak bersebelahannya, di bawah _Appearance_.

Dari terminal, suis yang sama ialah `omarchy toggle <thing>`. Jalankan `omarchy toggle` sendiri untuk melihat keseluruhan kumpulan itu.

| Togol | Kekunci Pintas | Perintah |
| ------ | ------ | ------- |
| Cahaya malam | — | `omarchy toggle nightlight` |
| Redamkan pemberitahuan | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Kekal berjaga (tiada kunci terbiar) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Rakaman ranap | — | `omarchy toggle crash-capture` |
| Penyelamat skrin | — | `omarchy toggle screensaver` |
| Penyegerakan tema [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Bar menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Pad sentuh | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Skrin sentuh | — | `omarchy device touchscreen` |
| Tangguh | — | `omarchy toggle suspend` |
| GPU hibrid | — | `omarchy toggle hybrid gpu` |

Suis pad sentuh, skrin sentuh, dan GPU hibrid terletak di bawah _Trigger > Hardware_ (`Super + Ctrl + H`) dan bukannya di bawah Toggle, kerana ia hanya muncul apabila anda benar-benar mempunyai perkakasan itu. Togol pad sentuh dan skrin sentuh kekal selepas Hyprland dimuat semula — nama peranti yang dilumpuhkan disimpan ke fail keadaan kecil yang dibaca oleh Hyprland semasa permulaan untuk melumpuhkannya semula.

_Appearance_ mengandungi bar menu dan animasi, serta beberapa perkara yang bukan perintah `omarchy toggle` tetapi berkelakuan sama: peratusan bateri dalam bar, susun atur ruang kerja lalai, dan di bawah _Windows_, jurang tetingkap (`Super + Shift + Backspace`) dan nisbah aspek segi empat sama 1 tetingkap (`Super + Ctrl + Backspace`).

Apabila Hyprland tiada GPU untuk dilukis dan sebaliknya memaparkan pada CPU (llvmpipe), seperti pada Mac yang GPU-nya belum disokong, dalam kebanyakan mesin maya, atau apabila pemacu grafik gagal dimuatkan, Omarchy mematikan animasi, kabur dan bayang untuk sesi itu dan memberitahu anda sekali melalui pemberitahuan. _Appearance > Animations On_ menghidupkannya semula, dan Omarchy mengingatinya untuk sesi kemudian juga.

Kebanyakan togol ini hanyalah fail bendera di bawah `~/.local/state/omarchy/toggles/`. Jika anda mahu bercabang berdasarkannya dalam skrip, `omarchy-toggle-enabled` memberikan anda kod keluar dan bukannya memaksa anda mencarinya:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Bendera dinamakan untuk keadaan mati — `screensaver-off`, `suspend-off`, `bar-off` — jadi kehadirannya bermakna ciri itu dilumpuhkan.

### Penunjuk dalam bar

Apabila sesuatu mod hidup, anda mendapat glif kecil di tengah bar atas di sebelah jam. Itulah widget penunjuk, dan ia membawa imlak, rakaman skrin, peringatan yang belum selesai, cahaya malam, jangan ganggu, dan kekal berjaga.

Penunjuk tidak aktif disembunyikan. Tuding di mana-mana pada bar dan ia muncul malap, supaya anda boleh mengklik satu untuk menghidupkannya tanpa mengetahui kekunci pintasnya. Mengklik penunjuk aktif mematikannya semula. Jika anda lebih suka melihat kesemuanya sepanjang masa, tetapkan `alwaysShow` kepada `true` pada entri `omarchy.indicators` dalam `~/.config/omarchy/shell.json` — lihat [bar atas](05-the-top-bar.md) untuk cara widget bar dikonfigurasikan.

### Cahaya malam

Cahaya malam menghangatkan skrin kepada 4000K, dan menogolnya semula mengembalikannya kepada 6500K. Togolnya dari menu togol (`Super + Ctrl + O`) atau dengan `omarchy toggle nightlight`. Ia dipacu oleh hyprsunset, yang akan dimulakan oleh togol untuk anda jika ia belum berjalan.

Secara lalai hyprsunset tidak melakukan apa-apa langsung pada skrin anda. `~/.config/hypr/hyprsunset.conf` disertakan dengan profil identiti dengan tepat supaya paparan kekal tidak disentuh sehingga anda meminta kehangatan. Jika anda lebih suka ia bertukar mengikut jam, gantikan itu dengan profil masa:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Kemudian mulakan hyprsunset semasa log masuk dengan menambah `o.launch_on_start("hyprsunset")` pada `~/.config/hypr/autostart.lua`. Pasangan 4000K/6500K yang digunakan oleh togol adalah tetap, jadi fail konfigurasi ialah tempat anda pergi jika anda mahukan suhu yang berbeza.

### Jangan ganggu

`Super + Ctrl + Alt + ,` meredamkan pemberitahuan. Tiada toast muncul semasa ia hidup, dan penunjuk loceng berpalang duduk dalam bar untuk mengingatkan anda mengapa desktop menjadi senyap.

Tiada apa yang hilang, walau bagaimanapun. Pemberitahuan yang diredamkan ditahan: paparkan semula beberapa yang terakhir pada skrin dengan `Super + Shift + Alt + ,`. Lihat [notis](10-notices.md) untuk selebihnya.

Dua jenis mesej masih dapat melepasi: toast pengesahan Omarchy sendiri untuk sesuatu yang baru anda lakukan ("Theme changed", "Screenshot saved"), dan amaran kritikal yang dihantar dari baris perintah. Aplikasi sembang yang menandakan semuanya sebagai kritikal untuk memaksa lalu di hadapan anda tidak layak.

### Keadaan terbiar

Shell Omarchy memiliki tingkah laku terbiar, dan pemasaan ialah blok `idle` peringkat atas dalam `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Kedua-dua nombor ialah saat yang dikira dari saat anda menjadi terbiar — bukan dari satu sama lain. Jadi dengan lalai, penyelamat skrin muncul selepas dua minit setengah dan skrin kunci mengambil alih pada lima minit, sama ada penyelamat skrin berjalan atau tidak. Simpan fail dan shell akan mengambil pemasaan baharu dengan serta-merta.

Jika anda menolak penyelamat skrin sebelum tarikh akhir kunci, itu dikira sebagai aktiviti dan kunci yang belum selesai dibatalkan. Anda tidak dikunci keluar hanya kerana mengerling mesin anda.

Untuk menghentikan penguncian semasa terbiar sepenuhnya, `Super + Ctrl + I` — atau `omarchy toggle idle` — menghidupkan kekal berjaga, dan penunjuk cawan kopi muncul dalam bar. Itulah yang perlu ditekan sebelum pembentangan panjang atau binaan yang anda mahu tonton. Tekan lagi untuk kembali kepada normal. `omarchy toggle idle status` mencetak keadaan semasa sebagai JSON jika anda memerlukannya dari skrip.

Ini tentang penguncian dan penyelamat skrin, bukan kuasa. Tangguh dan hibernasi mempunyai persediaan sendiri dalam [tidur sistem](36-system-sleep.md).

### Penyelamat skrin

Penyelamat skrin Omarchy ialah seni ASCII yang berjalan melalui kesan teks rawak, satu instance bagi setiap monitor. Sebarang kekunci atau pergerakan tetikus keluar daripadanya.

Anda boleh memulakannya atas permintaan dari _System > Screensaver_ (`Super + Esc`), yang memaksanya muncul walaupun anda telah mematikan penyelamat skrin terbiar. Tiada kekunci pintas terikat padanya secara lalai.

`omarchy toggle screensaver` ialah yang mematikan yang terbiar, jika anda lebih suka pergi terus dari bekerja kepada terkunci. Sebarang kekunci, klik, skrol atau pergerakan tetikus menutupnya.

Logo yang dilukisnya boleh anda ubah, di bawah _Appearance > Branding > Screensaver_. Muat naik png atau svg dan Omarchy menukarnya kepada ASCII. Lihat [penjenamaan](41-branding.md).

### Skrin kunci

`Super + Ctrl + L` mengunci mesin. Itu menjalankan skrin kunci dari shell Omarchy, mengosongkan paparan, menetapkan semula susun atur papan kekunci anda kepada yang pertama supaya anda tidak menaip kata laluan anda dalam abjad yang salah, dan — jika anda menjalankannya — mengunci 1Password dalam perjalanan keluar.

Skrin kunci menerima kata laluan, dan ia juga akan menerima cap jari setelah anda menyediakannya. Itu, dan cara lain untuk mengesahkan, diliputi dalam [pengesahan perkakasan](37-hardware-authentication.md).
