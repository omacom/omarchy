# Temalar

Omarchy, yirmi üç güzel temayla birlikte gelir. Bunlar arasında Omarchy Menüsü'ndeki (`Super + Space`) _Görünüm > Tema_ üzerinden seçim yapabilir veya `Super + Ctrl + T` ile doğrudan tema seçicisine atlayabilirsiniz.

Her tema masaüstünü, terminali, neovim'i, etkinlik ekranını (btop), tarayıcınızı (Chrome, Chromium, Edge veya Brave) ve Omarchy kabuğunun tamamını şekillendirir: üst çubuk, menü, bildirimler, OSD ve kilit ekranı. (Obsidian için Omarchy temasını uygulamanın içindeki _Görünüm > Temalar_ üzerinden elle seçmeniz gerekir).

Temaların, `Super + Ctrl + W` ile aralarından seçim yapabileceğiniz bir dizi arka plan görseli vardır.

Daha da fazla temayı [ekstra temalar sayfasında](https://omarchy.org/themes/) bulabilir, hatta [kendi temanızı yapabilirsiniz](43-making-your-own-theme.md).

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

Uygulama başlatıcıdaki ve dock'taki simgeler temanızın renkleriyle çizilir, böylece temayla birlikte değişirler. Bunlar, temadan ayrı olarak _Görünüm > Simgeler_ altında, her setin önizlemelerinden, tema seçtiğiniz gibi seçtiğiniz bir simge setinden gelir:

- _Papercraft_ varsayılandır: kurulu gelen her şey, tek bir stilde çizilmiştir. Chrome, HEY veya YouTube gibi logosuyla tanınan uygulamalar şeklini korur ve temanın renklerini alır.
- _Arcade_ aynı uygulamaları, eski bir oyun konsolunun yapacağı gibi 8-bit piksel sanatı olarak çizer.
- _Original_ her uygulamayı, yapımcısının verdiği simgeyle gösterir.

Bir başkasının yaptığı bir simge setini _Yükle > Stil > Simgeler_ ile (veya `omarchy icons install <git url>` ile) kurabilir ve _Kaldır > Simgeler_ altında tekrar kaldırabilirsiniz. _Güncelle > Ekstra Simgeler_ kurduğunuz setlerin en son sürümünü getirir.

Kendinizinkini yapmak için simgelerinizi `~/.config/omarchy/icons/<name>/` içine, uygulama başına bir dosya olacak şekilde, uygulamanın `.desktop` dosyasının `Icon=` satırına göre adlandırarak koyun. `.svg` ile biten bir dosya olduğu gibi gösterilir. `.svg.tpl` ile biten bir dosya temanın renkleriyle çizilir: bir rengin gideceği yere `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` veya `{{ icon_shadow }}` yazın. `/usr/share/omarchy/icons/papercraft/` içindeki varsayılan set, başlamak için iyi bir yerdir. Setinizi seçicide göstermek için bir `preview.png` ekleyin; onsuz, Omarchy simgelerinizden bir önizleme çizer. Varsayılan setin tek bir simgesini değiştirmek için kendi sürümünüzü `~/.config/omarchy/icons/papercraft/` içine koyun.

### Kilit Açma Ekranları

Temaların, önyükleme şifre çözme işlemi için kullanılan özel bir kilit açma tasarımı da olabilir. Bunlardan birini _Görünüm > Kilit Açma_ altında seçebilirsiniz. Şöyle görünürler:

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

 ![last-horizon](../themes/last-horizon/preview-unlock.png)
_Last Horizon_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![lupine](../themes/lupine/preview-unlock.png)
_Lupine_

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

 ![solitude](../themes/solitude/preview-unlock.png)
_Solitude_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
