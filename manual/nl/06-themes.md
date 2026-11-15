# Thema's

Omarchy wordt geleverd met tweeëntwintig prachtige thema's. Je kunt ertussen kiezen via _Uiterlijk > Thema_ in het Omarchy Menu (`Super + Space`) of direct naar de themakiezer springen met `Super + Ctrl + T`.

Elk thema bepaalt de stijl van het bureaublad, de terminal, neovim, het activiteitenscherm (btop), Chromium en de volledige Omarchy-shell: bovenbalk, menu, meldingen, OSD en het vergrendelscherm. (Voor Obsidian moet je het Omarchy-thema handmatig selecteren via _Uiterlijk > Thema's_ in de app).

Thema's hebben een set achtergrondafbeeldingen waaruit je kunt kiezen met `Super + Ctrl + W`.

Je vindt nog meer thema's op [de pagina met extra thema's](https://omarchy.org/themes/) of kunt zelfs [je eigen thema maken](43-making-your-own-theme.md).

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

### App-iconen

De iconen in de appstarter en het dock worden getekend in de kleuren van je thema, dus ze veranderen mee. Ze komen uit een iconenset, die je los van het thema kiest onder _Uiterlijk > Iconen_, via voorbeelden van elke set, op dezelfde manier als je een thema kiest:

- _Papercraft_ is de standaard: alles wat meegeleverd wordt geïnstalleerd, getekend in één stijl. Apps die bekendstaan om hun logo, zoals Chrome, HEY of YouTube, behouden hun vorm en nemen de kleuren van het thema over.
- _Arcade_ tekent dezelfde apps als 8-bit pixelart, zoals een oude gameconsole dat zou doen.
- _Original_ toont elke app met het icoon dat de maker eraan heeft gegeven.

Je kunt een iconenset die iemand anders heeft gemaakt installeren met _Installeren > Stijl > Iconen_ (of `omarchy icons install <git url>`), en deze weer verwijderen onder _Verwijderen > Iconen_. _Bijwerken > Extra iconen_ haalt de nieuwste versie op van de sets die je hebt geïnstalleerd.

Om je eigen set te maken, plaats je je iconen in `~/.config/omarchy/icons/<name>/`, één bestand per app, genoemd naar de `Icon=`-regel van het `.desktop`-bestand van de app. Een bestand dat eindigt op `.svg` wordt getoond zoals het is. Een bestand dat eindigt op `.svg.tpl` wordt getekend in de kleuren van het thema: schrijf `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` of `{{ icon_shadow }}` waar een kleur moet komen. De standaardset in `/usr/share/omarchy/icons/papercraft/` is een goede plek om vanuit te vertrekken. Voeg een `preview.png` toe om je set in de kiezer te tonen; zonder zo'n bestand tekent Omarchy een voorbeeld op basis van je iconen. Om één enkel icoon van de standaardset te wijzigen, plaats je jouw versie in `~/.config/omarchy/icons/papercraft/`.

### Ontgrendelontwerpen

Thema's kunnen ook een aangepast ontgrendelontwerp hebben, dat wordt gebruikt voor het ontsleutelingsproces tijdens het opstarten. Je kunt er een selecteren onder _Uiterlijk > Ontgrendeling_. Ze zien er zo uit:

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
