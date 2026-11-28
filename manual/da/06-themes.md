# Temaer

Omarchy leveres med treogtyve smukke temaer. Du kan vælge mellem dem via _Udseende > Tema_ i Omarchy-menuen (`Super + Space`) eller hoppe direkte til temavælgeren med `Super + Ctrl + T`.

Hvert tema styler skrivebordet, terminalen, neovim, aktivitetsvisningen (btop), din browser (Chrome, Chromium, Edge eller Brave) og hele Omarchy-skallen: øverste bjælke, menu, notifikationer, OSD og låseskærmen. (Til Obsidian skal du manuelt vælge Omarchy-temaet via _Udseende > Temaer_ inde i appen).

Temaer har et sæt baggrundsbilleder, som du kan vælge mellem med `Super + Ctrl + W`.

Du kan finde endnu flere temaer på [siden med ekstratemaer](https://omarchy.org/themes/) eller endda [lave dit eget tema](43-making-your-own-theme.md).

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

### App-ikoner

Ikonerne i app-launcheren og docken tegnes i dit temas farver, så de ændrer sig sammen med det. De kommer fra et ikonsæt, som du vælger adskilt fra temaet under _Udseende > Ikoner_, ud fra forhåndsvisninger af hvert sæt, på samme måde som du vælger et tema:

- _Papercraft_ er standarden: alt det, der følger med installeret, tegnet i én stil. Apps, der kendes på deres logo, som Chrome, HEY eller YouTube, beholder sin form og antager temaets farver.
- _Arcade_ tegner de samme apps som 8-bit pixelkunst, som en gammel spillekonsol ville gøre det.
- _Original_ viser hver app med det ikon, dens skaber gav den.

Du kan installere et ikonsæt, som en anden har lavet, med _Installér > Stil > Ikoner_ (eller `omarchy icons install <git url>`), og fjerne det igen under _Fjern > Ikoner_. _Opdater > Ekstra ikoner_ henter den nyeste version af de sæt, du har installeret.

For at lave dit eget skal du lægge dine ikoner i `~/.config/omarchy/icons/<name>/`, én fil pr. app, opkaldt efter `Icon=`-linjen i appens `.desktop`-fil. En fil, der ender på `.svg`, vises, som den er. En fil, der ender på `.svg.tpl`, tegnes i temaets farver: skriv `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` eller `{{ icon_shadow }}`, hvor en farve skal være. Standardsættet i `/usr/share/omarchy/icons/papercraft/` er et godt sted at starte fra. Tilføj en `preview.png` for at vise dit sæt i vælgeren; uden en tegner Omarchy en forhåndsvisning ud fra dine ikoner. For at ændre et enkelt ikon i standardsættet skal du lægge din version i `~/.config/omarchy/icons/papercraft/`.

### Opstart og login

Skærmen, der beder om din drevadgangskode, når computeren starter, og loginskærmen følger også temaet. Hver gang du skifter tema, overtager de dets baggrunds-, tekst-, accent- og røde farver, så der ikke er et separat oplåsningsdesign at vælge. På Apple Silicon-Mac'er beholder drevadgangskodeskærmen Omarchys standardudseende, uanset temaet.
