# Pelarasan lazim

Ini ialah koleksi pelarasan lazim untuk persediaan Omarchy. Perlu diketahui bahawa kadangkala kemas kini sistem mungkin perlu memulihkan sesetengah konfigurasi kepada keadaan asalnya. Jika ini berlaku, perubahan anda tidak akan hilang, tetapi akan disimpan dalam fail `.bak.<timestamp>` di sebelah fail asal.

Kalau anda merosakkan sesuatu, anda boleh memulihkan konfigurasi individu kepada persediaan asalnya melalui _Update > Config_ dalam menu Omarchy. Kalau anda *betul-betul* merosakkan semuanya, anda boleh menetapkan semula semua konfigurasi melalui `omarchy reinstall configs`, atau memasang semula setiap pakej dan konfigurasi lalai dengan `omarchy reinstall`.

### Tunjukkan semua ikon dulang sepanjang masa

Secara lalai, ikon dulang, seperti Dropbox, 1password, atau Steam, tersembunyi di sebalik anak panah pengembang dulang, yang menunjukkannya apabila anda menghover di atasnya. Jika anda mahu ikon tersebut sentiasa terdedah, klik kanan anak panah pengembang untuk membuka pengurus ikon dulang, kemudian pin ikon yang anda mahu kekalkan kelihatan (anda juga boleh menyembunyikan ikon yang tidak mahu dilihat langsung).

### Sudut tetingkap bulat

Reka bentuk lalai Omarchy menggunakan sudut segi empat sama, tetapi jika anda mahu melembutkannya sedikit, pilih _Appearance > Windows > Window Corners > Rounded Corners_ dalam menu Omarchy, atau jalankan `omarchy hyprland corners rounded`. _Theme Corners_ kembali kepada apa sahaja yang digunakan oleh tema. Untuk memilih radius anda sendiri, kekal pada _Theme Corners_ (`omarchy hyprland corners theme`), kerana Rounded dan Sharp dimuatkan selepas konfigurasi anda dan akan mengatasinya, dan nyahkomen pembulatan dalam `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Buang jurang tetingkap

Pada paparan komputer riba, sesetengah orang lebih suka tidak membazirkan sebarang piksel pada jurang tetingkap (atau malah bar atas, yang boleh anda togol matikan dengan `Super + Shift + Space`). Anda boleh menogol semua jurang dan sempadan mati dengan `Super + Shift + Backspace`, atau membuangnya secara kekal dengan membuang komen dalam bahagian ini dalam `~/.config/hypr/looknfeel.lua`:

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
