# Motivy

Omarchy obsahuje dvacet dva krásných motivů. Vybrat si mezi nimi můžete přes _Vzhled > Motiv_ v Omarchy Menu (`Super + Space`), nebo skočit rovnou do výběru motivu pomocí `Super + Ctrl + T`.

Každý motiv nastyluje plochu, terminál, neovim, obrazovku aktivity (btop), Chromium a celé prostředí Omarchy: horní lištu, menu, oznámení, OSD a zamykací obrazovku. (U Obsidian musíte motiv Omarchy vybrat ručně přes _Vzhled > Motivy_ přímo v aplikaci).

Motivy mají sadu obrázků na pozadí, mezi kterými můžete vybírat pomocí `Super + Ctrl + W`.

Ještě více motivů najdete na [stránce s dalšími motivy](https://omarchy.org/themes/), nebo si dokonce můžete [vytvořit vlastní motiv](43-making-your-own-theme.md).

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

### Ikony aplikací

Ikony ve spouštěči aplikací a v docku jsou vykreslené v barvách vašeho motivu, takže se mění spolu s ním. Pocházejí ze sady ikon, kterou si vybíráte odděleně od motivu pod _Vzhled > Ikony_:

- _Papercraft_ je výchozí: všechno, co je nainstalované, nakreslené v jednom stylu. Aplikace známé svým logem, jako Chrome, HEY nebo YouTube, si zachovávají svůj tvar a přebírají barvy motivu.
- _Arcade_ vykresluje stejné aplikace jako 8bitový pixel art, jako by to dělala stará herní konzole.
- _Original_ zobrazuje každou aplikaci s ikonou, kterou jí dal její tvůrce.

Sadu ikon, kterou vytvořil někdo jiný, můžete nainstalovat přes _Instalovat > Styl > Ikony_ (nebo `omarchy icons install <git url>`) a znovu ji odebrat pod _Odebrat > Ikony_. _Aktualizovat > Další ikony_ stáhne nejnovější verzi sad, které máte nainstalované.

Chcete-li si vytvořit vlastní, umístěte své ikony do `~/.config/omarchy/icons/<name>/`, jeden soubor pro každou aplikaci, pojmenovaný podle řádku `Icon=` v souboru `.desktop` dané aplikace. Soubor končící na `.svg` se zobrazí tak, jak je. Soubor končící na `.svg.tpl` se vykreslí v barvách motivu: tam, kam patří barva, napište `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` nebo `{{ icon_shadow }}`. Dobrým výchozím bodem je výchozí sada v `/usr/share/omarchy/icons/papercraft/`. Chcete-li změnit jednu ikonu z výchozí sady, umístěte svou verzi do `~/.config/omarchy/icons/papercraft/`.

### Odemykání

Motivy mohou mít také vlastní design odemykání, který se používá při dešifrování při spouštění. Vybrat si ho můžete pod _Vzhled > Odemykání_. Vypadají takto:

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
