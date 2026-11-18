# Penyesuaian umum

Ini adalah kumpulan penyesuaian umum untuk pengaturan Omarchy. Ketahuilah bahwa terkadang pembaruan sistem mungkin perlu memulihkan konfigurasi tertentu ke kondisi aslinya. Jika ini terjadi, perubahanmu tidak akan hilang, tetapi dimasukkan ke berkas `.bak` di direktori yang sama.

Jika kamu mengacaukan sesuatu, kamu bisa memulihkan konfigurasi individual ke pengaturan aslinya melalui _Perbarui > Config_ di menu Omarchy. Jika kamu _benar-benar_ mengacaukan segalanya, kamu bisa mengatur ulang semua konfigurasi melalui `omarchy-reinstall`.

### Perlihatkan semua ikon baki sepanjang waktu

Secara bawaan, ikon baki, seperti Dropbox, 1password, atau Steam, tersembunyi di balik panah pembesar baki, yang memperlihatkannya saat kamu mengarahkan kursor ke sana. Jika kamu ingin mereka selalu terlihat, klik kanan panah pembesar untuk membuka pengelola ikon baki, lalu sematkan ikon yang ingin kamu tetap terlihat (kamu juga bisa menyembunyikan yang tidak pernah ingin kamu lihat).

### Sudut jendela melengkung

Desain bawaan Omarchy adalah sudut persegi, tetapi jika kamu suka melunakkannya sedikit, kamu bisa mengubah `~/.config/hypr/looknfeel.lua` sehingga pembulatan tidak lagi dikomentari:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Hapus celah jendela

Di layar laptop, sebagian orang lebih suka tidak membuang piksel apa pun untuk celah jendela (atau bahkan bilah atas, yang bisa kamu matikan dengan `Super + Shift + Space`). Kamu bisa mematikan semua celah dan batas dengan `Super + Shift + Backspace`, atau menghapusnya secara permanen dengan menghapus komentar di bagian `~/.config/hypr/looknfeel.lua` ini:

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
