# Teman

Omarchy levereras med tjugotre vackra teman. Du kan välja mellan dem via _Utseende > Tema_ i Omarchy-menyn (`Super + Space`) eller hoppa direkt till temaväljaren med `Super + Ctrl + T`.

Varje tema sätter stilen för skrivbordet, terminalen, neovim, aktivitetsskärmen (btop), din webbläsare (Chrome, Chromium, Edge eller Brave) och hela Omarchy-skalet: översta raden, menyn, aviseringar, OSD och låsskärmen. (För Obsidian måste du manuellt välja Omarchy-temat via _Utseende > Teman_ inne i appen).

Teman har en uppsättning bakgrundsbilder som du kan välja mellan med `Super + Ctrl + W`.

Du kan hitta ännu fler teman på [sidan med extra teman](https://omarchy.org/themes/) eller till och med [skapa ditt eget tema](43-making-your-own-theme.md).

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

Ikonerna i appstartaren och dockan ritas i ditt temas färger, så de ändras tillsammans med det. De kommer från en ikonuppsättning, som du väljer separat från temat under _Utseende > Ikoner_, från förhandsvisningar av varje uppsättning, på samma sätt som du väljer ett tema:

- _Papercraft_ är standard: allt som kommer installerat, ritat i en enda stil. Appar som känns igen på sin logotyp, som Chrome, HEY eller YouTube, behåller sin form och får temats färger.
- _Arcade_ ritar samma appar som 8-bitars pixelkonst, som en gammal spelkonsol skulle göra.
- _Original_ visar varje app med ikonen som dess skapare gav den.

Du kan installera en ikonuppsättning som någon annan har gjort med _Installera > Stil > Ikoner_ (eller `omarchy icons install <git url>`), och ta bort den igen under _Ta bort > Ikoner_. _Uppdatera > Extra ikoner_ hämtar den senaste versionen av uppsättningarna du har installerat.

För att göra din egen, lägg dina ikoner i `~/.config/omarchy/icons/<name>/`, en fil per app, namngiven efter `Icon=`-raden i appens `.desktop`-fil. En fil som slutar på `.svg` visas som den är. En fil som slutar på `.svg.tpl` ritas i temats färger: skriv `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` eller `{{ icon_shadow }}` där en färg ska vara. Standarduppsättningen i `/usr/share/omarchy/icons/papercraft/` är ett bra ställe att utgå från. Lägg till en `preview.png` för att visa din uppsättning i väljaren; utan en sådan ritar Omarchy en förhandsvisning från dina ikoner. För att ändra en enskild ikon i standarduppsättningen, lägg din version i `~/.config/omarchy/icons/papercraft/`.

### Upplåsningar

Teman kan också ha en anpassad upplåsningsdesign, som används för dekrypteringen vid uppstart. Du kan välja en av dessa under _Utseende > Lås upp_. De ser ut så här:

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
