# Tema

Omarchy hadir dengan dua puluh tiga tema yang indah. Kamu bisa memilih di antaranya melalui _Tampilan > Tema_ di Menu Omarchy (`Super + Space`) atau langsung melompat ke pemilih tema menggunakan `Super + Ctrl + T`.

Setiap tema memberi gaya pada desktop, terminal, neovim, layar aktivitas (btop), browser kamu (Chrome, Chromium, Edge atau Brave), dan seluruh shell Omarchy: bar atas, menu, notifikasi, OSD, dan layar kunci. (Untuk Obsidian, kamu harus memilih tema Omarchy secara manual melalui _Tampilan > Tema_ di dalam aplikasi tersebut).

Tema memiliki serangkaian gambar latar belakang yang bisa kamu pilih di antaranya menggunakan `Super + Ctrl + W`.

Kamu bisa menemukan lebih banyak tema lagi di [halaman tema ekstra](https://omarchy.org/themes/) atau bahkan [membuat tema kamu sendiri](43-making-your-own-theme.md).

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

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### Ikon aplikasi

Ikon-ikon di peluncur aplikasi dan dock digambar dengan warna tema kamu, jadi ikon-ikon tersebut berubah mengikuti tema. Ikon-ikon tersebut berasal dari satu set ikon, yang kamu pilih secara terpisah dari tema di bawah _Tampilan > Ikon_, dari pratinjau setiap set, dengan cara yang sama seperti kamu memilih tema:

- _Papercraft_ adalah default-nya: semua yang terpasang, digambar dalam satu gaya. Aplikasi yang dikenal dari logonya, seperti Chrome, HEY, atau YouTube, mempertahankan bentuknya dan mengambil warna tema.
- _Arcade_ menggambar aplikasi yang sama sebagai seni piksel 8-bit, seperti yang akan dilakukan konsol game lama.
- _Original_ menampilkan setiap aplikasi dengan ikon yang diberikan oleh pembuatnya.

Kamu bisa memasang set ikon buatan orang lain dengan _Pasang > Gaya > Ikon_ (atau `omarchy icons install <git url>`), dan menghapusnya lagi di bawah _Hapus > Ikon_. _Perbarui > Ikon Ekstra_ mengambil versi terbaru dari set yang telah kamu pasang.

Untuk membuat set kamu sendiri, letakkan ikon-ikon kamu di `~/.config/omarchy/icons/<name>/`, satu file per aplikasi, diberi nama sesuai baris `Icon=` dari file `.desktop` aplikasi tersebut. File yang berakhiran `.svg` ditampilkan apa adanya. File yang berakhiran `.svg.tpl` digambar dengan warna tema: tulis `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` atau `{{ icon_shadow }}` di tempat warna seharusnya berada. Set default di `/usr/share/omarchy/icons/papercraft/` adalah tempat yang baik untuk memulai. Tambahkan `preview.png` untuk menampilkan set kamu di pemilih; tanpa file tersebut, Omarchy menggambar pratinjau dari ikon-ikon kamu. Untuk mengubah satu ikon dari set default, letakkan versi kamu di `~/.config/omarchy/icons/papercraft/`.

### Boot dan login

Layar yang meminta kata sandi drive kamu saat komputer menyala, dan layar login, juga mengikuti tema. Setiap kali kamu berganti tema, keduanya mengambil latar belakang, teks, aksen, dan warna merahnya, jadi tidak ada desain buka kunci terpisah yang perlu dipilih. Di Mac Apple Silicon, layar kata sandi drive tetap mempertahankan tampilan default Omarchy apa pun temanya.
