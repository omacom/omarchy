# Penyesuaian umum

Ini adalah kumpulan penyesuaian yang umum untuk setup Omarchy. Perlu diketahui bahwa terkadang pembaruan sistem mungkin perlu mengembalikan config tertentu ke kondisi aslinya. Jika ini terjadi, perubahanmu tidak akan hilang, tetapi disimpan dalam file `.bak.<timestamp>` di samping file aslinya.

Jika kamu mengacaukan sesuatu, kamu bisa mengembalikan config individual ke setup aslinya melalui _Update > Config_ di menu Omarchy. Jika kamu _benar-benar_ mengacaukan semuanya, kamu bisa mereset semua config melalui `omarchy reinstall configs`, atau menginstal ulang setiap package dan config default dengan `omarchy reinstall`.

### Tampilkan semua ikon tray setiap saat

Secara default, ikon tray, seperti Dropbox, 1password, atau Steam, disembunyikan di balik panah tray expander, yang menampilkannya saat kamu mengarahkan kursor ke atasnya. Jika kamu ingin ikon-ikon itu selalu terlihat, klik kanan panah expander untuk membuka tray icon manager, lalu pin ikon yang ingin kamu tetap tampilkan (kamu juga bisa menyembunyikan ikon yang tidak pernah ingin kamu lihat).

### Sudut jendela membulat

Desain default Omarchy adalah sudut persegi, tetapi jika kamu ingin membuatnya sedikit lebih lembut, pilih _Appearance > Windows > Window Corners > Rounded Corners_ di menu Omarchy, atau jalankan `omarchy hyprland corners rounded`. _Theme Corners_ kembali ke apa pun yang digunakan tema. Untuk memilih radiusmu sendiri, tetap di _Theme Corners_ (`omarchy hyprland corners theme`), karena Rounded dan Sharp dimuat setelah config-mu dan menimpanya, dan hilangkan komentar pada rounding di `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Hilangkan celah jendela

Di layar laptop, sebagian orang lebih suka tidak membuang satu piksel pun untuk celah jendela (atau bahkan top bar, yang bisa kamu aktifkan dan nonaktifkan dengan `Super + Shift + Space`). Kamu bisa mengaktifkan dan menonaktifkan semua celah dan border dengan `Super + Shift + Backspace`, atau menghilangkannya secara permanen dengan menghapus komentar di bagian ini dari `~/.config/hypr/looknfeel.lua`:

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
