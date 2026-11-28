# Temaer

Omarchy leveres med tjuetre vakre temaer. Du kan velge mellom dem via _Utseende > Tema_ i Omarchy-menyen (`Super + Space`) eller hoppe rett til temavelgeren med `Super + Ctrl + T`.

Hvert tema setter stil på skrivebordet, terminalen, neovim, aktivitetsskjermen (btop), nettleseren din (Chrome, Chromium, Edge eller Brave) og hele Omarchy-skallet: topplinjen, menyen, varsler, OSD og låseskjermen. (I Obsidian må du velge Omarchy-temaet manuelt via _Utseende > Temaer_ inne i appen).

Temaer har et sett med bakgrunnsbilder som du kan velge mellom med `Super + Ctrl + W`.

Du finner enda flere temaer på [siden med ekstra temaer](https://omarchy.org/themes/) eller til og med [lage ditt eget tema](43-making-your-own-theme.md).

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

### Appikoner

Ikonene i appstarteren og dokken tegnes i fargene til temaet ditt, så de endres sammen med det. De kommer fra et ikonsett, som du velger uavhengig av temaet under _Utseende > Ikoner_, fra forhåndsvisninger av hvert sett, på samme måte som du velger et tema:

- _Papercraft_ er standarden: alt som følger med installert, tegnet i én stil. Apper som er kjent for logoen sin, som Chrome, HEY eller YouTube, beholder formen sin og får fargene til temaet.
- _Arcade_ tegner de samme appene som 8-biters pikselkunst, slik en gammel spillkonsoll ville gjort.
- _Original_ viser hver app med ikonet skaperen ga den.

Du kan installere et ikonsett noen andre har laget med _Installer > Stil > Ikoner_ (eller `omarchy icons install <git url>`), og fjerne det igjen under _Fjern > Ikoner_. _Oppdater > Ekstra ikoner_ henter den nyeste versjonen av settene du har installert.

For å lage ditt eget legger du ikonene dine i `~/.config/omarchy/icons/<name>/`, én fil per app, oppkalt etter `Icon=`-linjen i appens `.desktop`-fil. En fil som slutter på `.svg`, vises som den er. En fil som slutter på `.svg.tpl`, tegnes i fargene til temaet: skriv `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` eller `{{ icon_shadow }}` der en farge skal være. Standardsettet i `/usr/share/omarchy/icons/papercraft/` er et godt utgangspunkt. Legg til en `preview.png` for å vise settet ditt i velgeren; uten en slik tegner Omarchy en forhåndsvisning fra ikonene dine. For å endre ett enkelt ikon i standardsettet legger du din versjon i `~/.config/omarchy/icons/papercraft/`.

### Oppstart og innlogging

Skjermen som ber om diskpassordet ditt når datamaskinen starter, og innloggingsskjermen, følger også temaet. Hver gang du bytter tema, får de bakgrunnen, teksten, aksenten og de røde fargene fra det, så det finnes ikke noe eget opplåsingsdesign å velge. På Apple Silicon-Macer beholder skjermen for diskpassord Omarchys standardutseende uansett tema.
