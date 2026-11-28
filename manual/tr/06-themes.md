# Temalar

Omarchy yirmi üç güzel temayla birlikte gelir. Bunlar arasında Omarchy Menüsü'ndeki (`Super + Space`) _Görünüm > Tema_ üzerinden seçim yapabilir veya `Super + Ctrl + T` kullanarak doğrudan tema seçiciye atlayabilirsiniz.

Her tema masaüstünü, terminali, neovim'i, etkinlik ekranını (btop), tarayıcınızı (Chrome, Chromium, Edge veya Brave) ve tüm Omarchy kabuğunu biçimlendirir: üst çubuk, menü, bildirimler, OSD ve kilit ekranı. (Obsidian için, Omarchy temasını uygulama içindeki _Görünüm > Temalar_ üzerinden elle seçmeniz gerekir).

Temaların `Super + Ctrl + W` kullanarak aralarında seçim yapabileceğiniz bir dizi arka plan görseli vardır.

Daha da fazla temayı [ek temalar sayfasında](https://omarchy.org/themes/) bulabilir, hatta [kendi temanızı yapabilirsiniz](43-making-your-own-theme.md).

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

### Uygulama simgeleri

Uygulama başlatıcısındaki ve dock'taki simgeler temanızın renkleriyle çizilir, yani temayla birlikte değişir. Bunlar, temadan ayrı olarak _Görünüm > Simgeler_ altında, bir temayı seçtiğiniz gibi her setin önizlemeleri arasından seçtiğiniz bir simge setinden gelir:

- _Papercraft_ varsayılandır: yüklü gelen her şey tek bir tarzda çizilir. Chrome, HEY veya YouTube gibi logosuyla bilinen uygulamalar şeklini korur ve temanın renklerini alır.
- _Arcade_ aynı uygulamaları, eski bir oyun konsolunun yapacağı gibi 8-bit piksel sanatı olarak çizer.
- _Original_ her uygulamayı, üreticisinin ona verdiği simgeyle gösterir.

Bir başkasının yaptığı bir simge setini _Kur > Tarz > Simgeler_ ile (veya `omarchy icons install <git url>`) kurabilir ve _Kaldır > Simgeler_ altında tekrar kaldırabilirsiniz. _Güncelle > Ekstra Simgeler_, kurduğunuz setlerin en son sürümünü getirir.

Kendi setinizi yapmak için simgelerinizi `~/.config/omarchy/icons/<name>/` içine, uygulama başına bir dosya olacak şekilde, uygulamanın `.desktop` dosyasının `Icon=` satırına göre adlandırarak koyun. `.svg` ile biten bir dosya olduğu gibi gösterilir. `.svg.tpl` ile biten bir dosya temanın renkleriyle çizilir: bir rengin geleceği yere `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` veya `{{ icon_shadow }}` yazın. `/usr/share/omarchy/icons/papercraft/` içindeki varsayılan set, başlamak için iyi bir yerdir. Setinizi seçicide göstermek için bir `preview.png` ekleyin; o olmadan Omarchy, simgelerinizden bir önizleme çizer. Varsayılan setin tek bir simgesini değiştirmek için kendi sürümünüzü `~/.config/omarchy/icons/papercraft/` içine koyun.

### Açılış ve giriş

Bilgisayar başlarken sürücü parolanızı soran ekran ve giriş ekranı da temayı takip eder. Her tema değiştirdiğinizde, temanın arka plan, metin, vurgu ve kırmızı renklerini alırlar, yani ayrıca seçilecek ayrı bir kilit açma tasarımı yoktur. Apple Silicon Mac'lerde sürücü parolası ekranı, tema ne olursa olsun Omarchy'nin varsayılan görünümünü korur.
