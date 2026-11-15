# Tema

Omarchy dilengkapi dengan dua puluh dua tema yang indah. Anda dapat memilih di antaranya melalui _Tampilan > Tema_ di Menu Omarchy (`Super + Space`) atau langsung membuka pemilih tema menggunakan `Super + Ctrl + T`.

Setiap tema menata desktop, terminal, neovim, layar aktivitas (btop), Chromium, dan seluruh shell Omarchy: bilah atas, menu, notifikasi, OSD, dan layar kunci. (Untuk Obsidian, Anda harus memilih tema Omarchy secara manual melalui _Tampilan > Tema_ di dalam aplikasi).

Tema memiliki serangkaian gambar latar belakang yang dapat Anda pilih di antaranya menggunakan `Super + Ctrl + W`.

Anda dapat menemukan lebih banyak tema di [halaman tema tambahan](https://omarchy.org/themes/) atau bahkan [membuat tema Anda sendiri](43-making-your-own-theme.md).

 ![tokyo-night](../themes/tokyo-night/preview.png)
_Tokyo Night_

 ![catppuccin](../themes/catppuccin/preview.png)
_Catppuccin_

 ![lumon](../themes/lumon/preview.png)
_Lumon_

 ![ethereal](../themes/ethereal/preview.png)
_Ethereal_

 ![everforest](../themes/everforest/preview.png)
_Everforest_

 ![gruvbox](../themes/gruvbox/preview.png)
_Gruvbox_

 ![miasma](../themes/miasma/preview.png)
_Miasma_

 ![hackerman](../themes/hackerman/preview.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview.png)
_Kanagawa_

 ![nord](../themes/nord/preview.png)
_Nord_

 ![matte-black](../themes/matte-black/preview.png)
_Matte Black_

 ![vantablack](../themes/vantablack/preview.png)
_Vantablack_

 ![ristretto](../themes/ristretto/preview.png)
_Ristretto_

 ![retro-82](../themes/retro-82/preview.png)
_Retro 82_

 ![flexoki-light](../themes/flexoki-light/preview.png)
_Flexoki Light_

 ![rose-pine](../themes/rose-pine/preview.png)
_Rose Pine_

 ![catppuccin-latte](../themes/catppuccin-latte/preview.png)
_Catppuccin Latte_

 ![white](../themes/white/preview.png)
_White_

### Ikon aplikasi

Ikon di peluncur aplikasi dan dock digambar dengan warna tema Anda, sehingga ikon-ikon itu ikut berubah bersamanya. Ikon-ikon itu berasal dari satu set ikon, yang Anda pilih secara terpisah dari tema di bawah _Tampilan > Ikon_:

- _Papercraft_ adalah default-nya: semua yang terinstal, digambar dalam satu gaya. Aplikasi yang dikenal dari logonya, seperti Chrome, HEY, atau YouTube, tetap mempertahankan bentuknya dan memakai warna tema.
- _Arcade_ menggambar aplikasi yang sama sebagai seni piksel 8-bit, seperti yang akan dilakukan konsol game lama.
- _Original_ menampilkan setiap aplikasi dengan ikon yang diberikan oleh pembuatnya.

Anda dapat menginstal set ikon buatan orang lain dengan _Install > Style > Icons_ (atau `omarchy icons install <git url>`), dan menghapusnya lagi di bawah _Remove > Icons_. _Update > Extra Icons_ mengambil versi terbaru dari set yang telah Anda instal.

Untuk membuat set ikon Anda sendiri, letakkan ikon-ikon Anda di `~/.config/omarchy/icons/<name>/`, satu file per aplikasi, diberi nama sesuai baris `Icon=` pada file `.desktop` aplikasi tersebut. File yang berakhiran `.svg` ditampilkan apa adanya. File yang berakhiran `.svg.tpl` digambar dengan warna tema: tulis `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` atau `{{ icon_shadow }}` di tempat warna seharusnya berada. Set default di `/usr/share/omarchy/icons/papercraft/` adalah tempat yang baik untuk memulai. Untuk mengubah satu ikon dari set default, letakkan versi Anda di `~/.config/omarchy/icons/papercraft/`.

### Buka kunci

Tema juga dapat memiliki desain buka kunci khusus, yang digunakan untuk proses dekripsi saat boot. Anda dapat memilih salah satunya di bawah _Tampilan > Buka Kunci_. Tampilannya seperti ini:

 ![catppuccin](../themes/catppuccin/preview-unlock.png)
_Catppuccin_

 ![catppuccin-latte](../themes/catppuccin-latte/preview-unlock.png)
_Catppuccin Latte_

 ![ethereal](../themes/ethereal/preview-unlock.png)
_Ethereal_

 ![everforest](../themes/everforest/preview-unlock.png)
_Everforest_

 ![flexoki-light](../themes/flexoki-light/preview-unlock.png)
_Flexoki Light_

 ![gruvbox](../themes/gruvbox/preview-unlock.png)
_Gruvbox_

 ![hackerman](../themes/hackerman/preview-unlock.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview-unlock.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview-unlock.png)
_Kanagawa_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![matte-black](../themes/matte-black/preview-unlock.png)
_Matte Black_

![miasma](../themes/miasma/preview-unlock.png)
_Miasma_

 ![nord](../themes/nord/preview-unlock.png)
_Nord_

 ![retro-82](../themes/retro-82/preview-unlock.png)
_Retro 82_

 ![ristretto](../themes/ristretto/preview-unlock.png)
_Ristretto_

![rose-pine](../themes/rose-pine/preview-unlock.png)
_Rose Pine_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
