# Pelarasan biasa

Ini ialah koleksi penyesuaian biasa kepada persediaan Omarchy. Ketahuilah bahawa kadangkala kemas kini sistem mungkin perlu memulihkan konfigurasi tertentu kepada keadaan asalnya. Jika ini berlaku, perubahan anda tidak akan hilang, tetapi diletakkan dalam fail `.bak` dalam direktori yang sama.

Jika anda merosakkan sesuatu, anda boleh memulihkan konfigurasi individu kepada persediaan asalnya melalui _Kemas Kini > Konfigurasi_ dalam menu Omarchy. Jika anda _benar-benar_ merosakkan semuanya, anda boleh menetapkan semula semua konfigurasi melalui `omarchy-reinstall`.

### Dedahkan semua ikon dulang sepanjang masa

Secara lalai, ikon dulang, seperti Dropbox, 1password, atau Steam, disembunyikan di sebalik anak panah pengembang dulang, yang mendedahkannya apabila anda menghovernya. Jika anda mahu ia terdedah sepanjang masa, klik kanan anak panah pengembang untuk membuka pengurus ikon dulang, kemudian paku ikon yang anda mahu kekalkan kelihatan (anda juga boleh menyembunyikan yang tidak pernah anda mahu lihat).

### Sudut tetingkap bulat

Reka bentuk lalai Omarchy ialah sudut segi empat, tetapi jika anda suka melembutkannya sedikit, anda boleh menukar `~/.config/hypr/looknfeel.lua` supaya pembundaran tidak lagi dikomenkan:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Buang jurang tetingkap

Pada paparan laptop, sesetengah orang lebih suka tidak membazir piksel pada jurang tetingkap (atau bar atas sekalipun, yang boleh anda togol mati dengan `Super + Shift + Space`). Anda boleh menogol semua jurang dan sempadan mati dengan `Super + Shift + Backspace`, atau membuangnya secara kekal dengan membuang komen dalam bahagian `~/.config/hypr/looknfeel.lua` ini:

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
