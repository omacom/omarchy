# Motivy

Omarchy přichází s dvaadvaceti krásnými motivy. Vybírat mezi nimi můžete přes _Vzhled > Motiv_ v nabídce Omarchy (`Super + Space`) nebo přejít rovnou na výběr motivu pomocí `Super + Ctrl + T`.

Každý motiv upravuje vzhled plochy, terminálu, neovim, obrazovky aktivity (btop), Chromium a celého shellu Omarchy: horní lišty, nabídky, oznámení, OSD a zamykací obrazovky. (U Obsidianu musíte motiv Omarchy vybrat ručně přes _Appearance > Themes_ uvnitř aplikace).

Motivy mají sadu obrázků na pozadí, mezi kterými můžete vybírat pomocí `Super + Ctrl + W`.

Ještě více motivů najdete na [stránce s dalšími motivy](https://omarchy.org/themes/) nebo si dokonce můžete [vytvořit vlastní motiv](43-making-your-own-theme.md).

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

Ikony ve spouštěči aplikací a v docku se kreslí v barvách vašeho motivu, takže se mění spolu s ním. Pocházejí ze sady ikon, kterou vybíráte odděleně od motivu pod _Vzhled > Ikony_, z náhledů jednotlivých sad, stejně jako motiv:

- _Papercraft_ je výchozí: všechno, co je nainstalované, nakreslené v jednom stylu. Aplikace, které znáte podle loga, jako Chrome, HEY nebo YouTube, si zachovají jeho tvar a převezmou barvy motivu.
- _Arcade_ kreslí stejné aplikace jako 8bitový pixel art, jako by to dělala stará herní konzole.
- _Original_ ukazuje každou aplikaci s ikonou, kterou jí dal její tvůrce.

Sadu ikon od někoho jiného nainstalujete přes _Instalovat > Vzhled > Ikony_ (nebo `omarchy icons install <git url>`) a odeberete ji pod _Odebrat > Ikony_. _Aktualizovat > Další ikony_ stáhne nejnovější verzi nainstalovaných sad.

Chcete-li vytvořit vlastní, uložte své ikony do `~/.config/omarchy/icons/<name>/`, jeden soubor na aplikaci, pojmenovaný podle řádku `Icon=` v souboru `.desktop` dané aplikace. Soubor s koncovkou `.svg` se zobrazí tak, jak je. Soubor s koncovkou `.svg.tpl` se kreslí v barvách motivu: tam, kam patří barva, napište `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` nebo `{{ icon_shadow }}`. Dobrým začátkem je výchozí sada v `/usr/share/omarchy/icons/papercraft/`. Přidejte `preview.png`, aby se vaše sada ukázala ve výběru; bez něj Omarchy nakreslí náhled z vašich ikon. Chcete-li změnit jedinou ikonu výchozí sady, uložte svou verzi do `~/.config/omarchy/icons/papercraft/`.

### Obrazovky odemykání

Motivy mohou mít také vlastní vzhled obrazovky odemykání, který se používá pro proces dešifrování při spouštění. Jeden z nich si můžete vybrat pod _Vzhled > Obrazovka odemykání_. Vypadají takto:

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
