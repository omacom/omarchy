# Thema's

Omarchy wordt geleverd met drieëntwintig prachtige thema's. Je kunt ertussen kiezen via _Uiterlijk > Thema_ in het Omarchy Menu (`Super + Space`) of rechtstreeks naar de themakiezer springen met `Super + Ctrl + T`.

Elk thema stijlt de desktop, terminal, neovim, het activiteitenscherm (btop), je browser (Chrome, Chromium, Edge of Brave) en de volledige Omarchy-shell: bovenbalk, menu, meldingen, OSD en het vergrendelscherm. (Voor Obsidian moet je het Omarchy-thema handmatig selecteren via _Uiterlijk > Thema's_ in de app).

Thema's hebben een set achtergrondafbeeldingen waaruit je kunt kiezen met `Super + Ctrl + W`.

Je vindt nog meer thema's op [de pagina met extra thema's](https://omarchy.org/themes/) of je kunt zelfs [je eigen thema maken](43-making-your-own-theme.md).

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

### App-pictogrammen

De pictogrammen in de app-launcher en het dock worden getekend in de kleuren van je thema, dus ze veranderen mee. Ze komen uit een pictogrammenset, die je los van het thema kiest onder _Uiterlijk > Pictogrammen_, aan de hand van voorbeelden van elke set, op dezelfde manier als je een thema kiest:

- _Papercraft_ is de standaard: alles wat geïnstalleerd wordt meegeleverd, getekend in één stijl. Apps die bekend zijn om hun logo, zoals Chrome, HEY of YouTube, behouden hun vorm en nemen de kleuren van het thema aan.
- _Arcade_ tekent dezelfde apps als 8-bit pixelart, zoals een oude spelconsole dat zou doen.
- _Original_ toont elke app met het pictogram dat de maker ervan heeft meegegeven.

Je kunt een pictogrammenset die iemand anders heeft gemaakt installeren met _Installeren > Stijl > Pictogrammen_ (of `omarchy icons install <git url>`), en die weer verwijderen onder _Verwijderen > Pictogrammen_. _Bijwerken > Extra pictogrammen_ haalt de nieuwste versie op van de sets die je hebt geïnstalleerd.

Om je eigen set te maken, zet je je pictogrammen in `~/.config/omarchy/icons/<name>/`, één bestand per app, genoemd naar de `Icon=`-regel van het `.desktop`-bestand van de app. Een bestand dat eindigt op `.svg` wordt weergegeven zoals het is. Een bestand dat eindigt op `.svg.tpl` wordt getekend in de kleuren van het thema: schrijf `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` of `{{ icon_shadow }}` waar een kleur hoort. De standaardset in `/usr/share/omarchy/icons/papercraft/` is een goed startpunt. Voeg een `preview.png` toe om je set in de kiezer te tonen; zonder zo'n bestand tekent Omarchy een voorbeeld op basis van je pictogrammen. Om één enkel pictogram van de standaardset te wijzigen, zet je jouw versie in `~/.config/omarchy/icons/papercraft/`.

### Opstarten en inloggen

Het scherm dat om je schijfwachtwoord vraagt wanneer de computer opstart, en het inlogscherm, volgen het thema ook. Elke keer dat je van thema wisselt, nemen ze daarvan de achtergrond, tekst, accentkleur en rode kleuren over, dus er is geen apart ontgrendelingsontwerp om te kiezen. Op Apple Silicon Macs behoudt het scherm voor het schijfwachtwoord de standaardweergave van Omarchy, wat het thema ook is.
