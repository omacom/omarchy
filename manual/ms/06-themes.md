# Tema

Omarchy didatangkan dengan dua puluh tiga tema yang cantik. Anda boleh memilih antaranya melalui _Penampilan > Tema_ dalam Menu Omarchy (`Super + Space`) atau terus lompat ke pemilih tema menggunakan `Super + Ctrl + T`.

Setiap tema menggayakan desktop, terminal, neovim, skrin aktiviti (btop), pelayar anda (Chrome, Chromium, Edge atau Brave), dan keseluruhan shell Omarchy: bar atas, menu, pemberitahuan, OSD, dan skrin kunci. (Untuk Obsidian, anda mesti memilih tema Omarchy secara manual melalui _Penampilan > Tema_ di dalam aplikasi tersebut).

Tema mempunyai satu set imej latar belakang yang boleh anda pilih antaranya menggunakan `Super + Ctrl + W`.

Anda boleh menemui lebih banyak tema di [halaman tema tambahan](https://omarchy.org/themes/) atau [buat tema anda sendiri](43-making-your-own-theme.md).

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

Ikon dalam pelancar aplikasi dan dock dilukis dalam warna tema anda, jadi ia berubah mengikut tema. Ia datang daripada satu set ikon, yang anda pilih secara berasingan daripada tema di bawah _Penampilan > Ikon_, daripada pratonton setiap set, dengan cara yang sama seperti anda memilih tema:

- _Papercraft_ ialah lalai: semua yang datang terpasang, dilukis dalam satu gaya. Aplikasi yang dikenali melalui logonya, seperti Chrome, HEY, atau YouTube, mengekalkan bentuknya dan mengambil warna tema.
- _Arcade_ melukis aplikasi yang sama sebagai seni piksel 8-bit, seperti yang akan dilakukan oleh konsol permainan lama.
- _Original_ menunjukkan setiap aplikasi dengan ikon yang diberikan oleh pembuatnya.

Anda boleh memasang set ikon yang dibuat oleh orang lain dengan _Pasang > Gaya > Ikon_ (atau `omarchy icons install <git url>`), dan membuangnya semula di bawah _Buang > Ikon_. _Kemas Kini > Ikon Tambahan_ mengambil versi terkini bagi set yang telah anda pasang.

Untuk membuat set anda sendiri, letakkan ikon anda di `~/.config/omarchy/icons/<name>/`, satu fail untuk setiap aplikasi, dinamakan sempena baris `Icon=` dalam fail `.desktop` aplikasi tersebut. Fail yang berakhir dengan `.svg` ditunjukkan seperti sedia ada. Fail yang berakhir dengan `.svg.tpl` dilukis dalam warna tema: tulis `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` atau `{{ icon_shadow }}` di tempat warna sepatutnya diletakkan. Set lalai di `/usr/share/omarchy/icons/papercraft/` ialah tempat yang baik untuk bermula. Tambah `preview.png` untuk menunjukkan set anda dalam pemilih; tanpanya, Omarchy melukis pratonton daripada ikon anda. Untuk menukar satu ikon tunggal daripada set lalai, letakkan versi anda di `~/.config/omarchy/icons/papercraft/`.

### But dan log masuk

Skrin yang meminta kata laluan pemacu anda apabila komputer dimulakan, dan skrin log masuk, turut mengikut tema. Setiap kali anda menukar tema, ia mengambil latar belakang, teks, warna aksen, dan warna merahnya, jadi tiada reka bentuk buka kunci berasingan untuk dipilih. Pada Mac Apple Silicon, skrin kata laluan pemacu mengekalkan rupa lalai Omarchy walau apa pun temanya.
