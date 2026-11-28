# Témata

Omarchy přichází s dvaceti třemi krásnými tématy. Můžete mezi nimi vybírat přes _Vzhled > Téma_ v nabídce Omarchy Menu (`Super + Space`), nebo skočit rovnou do výběru témat pomocí `Super + Ctrl + T`.

Každé téma upravuje vzhled plochy, terminálu, neovim, obrazovky aktivity (btop), vašeho prohlížeče (Chrome, Chromium, Edge nebo Brave) a celého shellu Omarchy: horní lišty, nabídky, oznámení, OSD a zamykací obrazovky. (U Obsidianu musíte téma Omarchy vybrat ručně přes _Vzhled > Témata_ přímo v aplikaci).

Témata mají sadu obrázků na pozadí, mezi kterými můžete vybírat pomocí `Super + Ctrl + W`.

Další témata najdete na [stránce s dalšími tématy](https://omarchy.org/themes/), nebo si dokonce můžete [vytvořit vlastní téma](43-making-your-own-theme.md).

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

### Ikony aplikací

Ikony ve spouštěči aplikací a v doku jsou vykreslené v barvách vašeho tématu, takže se mění spolu s ním. Pocházejí ze sady ikon, kterou vybíráte nezávisle na tématu pod _Vzhled > Ikony_ z náhledů jednotlivých sad, stejně jako vybíráte téma:

- _Papercraft_ je výchozí: vše, co je nainstalované, nakreslené v jednom stylu. Aplikace známé svým logem, jako Chrome, HEY nebo YouTube, si zachovávají svůj tvar a přebírají barvy tématu.
- _Arcade_ kreslí tytéž aplikace jako 8bitový pixel art, jako by je kreslila stará herní konzole.
- _Original_ zobrazuje každou aplikaci s ikonou, kterou jí dal její tvůrce.

Sadu ikon, kterou vytvořil někdo jiný, můžete nainstalovat přes _Instalace > Styl > Ikony_ (nebo příkazem `omarchy icons install <git url>`) a opět ji odebrat pod _Odebrat > Ikony_. _Aktualizace > Další ikony_ stáhne nejnovější verzi sad, které máte nainstalované.

Chcete-li vytvořit vlastní, umístěte své ikony do `~/.config/omarchy/icons/<name>/`, jeden soubor pro každou aplikaci, pojmenovaný podle řádku `Icon=` v souboru `.desktop` dané aplikace. Soubor končící na `.svg` se zobrazí tak, jak je. Soubor končící na `.svg.tpl` se vykreslí v barvách tématu: tam, kam patří barva, napište `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` nebo `{{ icon_shadow }}`. Výchozí sada v `/usr/share/omarchy/icons/papercraft/` je dobrým výchozím místem. Přidejte `preview.png`, aby se vaše sada zobrazovala ve výběru; bez něj Omarchy nakreslí náhled z vašich ikon. Chcete-li změnit jedinou ikonu výchozí sady, umístěte svou verzi do `~/.config/omarchy/icons/papercraft/`.

### Spouštění a přihlašování

Obrazovka, která při spuštění počítače žádá heslo k disku, i přihlašovací obrazovka se rovněž řídí tématem. Pokaždé, když téma přepnete, převezmou jeho barvy pozadí, textu, zvýraznění i červenou, takže není třeba vybírat samostatný vzhled odemykání. Na počítačích Mac s Apple Silicon si obrazovka pro heslo k disku zachovává výchozí vzhled Omarchy bez ohledu na téma.
