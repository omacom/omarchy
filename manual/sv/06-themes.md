# Teman

Omarchy levereras med tjugotre vackra teman. Du kan välja mellan dem via _Utseende > Tema_ i Omarchy-menyn (`Super + Space`) eller hoppa direkt till temaväljaren med `Super + Ctrl + T`.

Varje tema stylar skrivbordet, terminalen, neovim, aktivitetsskärmen (btop), din webbläsare (Chrome, Chromium, Edge eller Brave) och hela Omarchy-skalet: översta fältet, menyn, aviseringar, OSD och låsskärmen. (För Obsidian måste du manuellt välja Omarchy-temat via _Utseende > Teman_ inuti appen).

Teman har en uppsättning bakgrundsbilder som du kan välja mellan med `Super + Ctrl + W`.

Du kan hitta ännu fler teman på [sidan med extra teman](https://omarchy.org/themes/) eller till och med [göra ditt eget tema](43-making-your-own-theme.md).

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

Ikonerna i apprutan och dockan ritas i ditt temas färger, så de ändras tillsammans med det. De kommer från en ikonuppsättning, som du väljer separat från temat under _Utseende > Ikoner_, från förhandsvisningar av varje uppsättning, på samma sätt som du väljer ett tema:

- _Papercraft_ är standard: allt som är installerat, ritat i en stil. Appar som känns igen på sin logotyp, som Chrome, HEY eller YouTube, behåller sin form och tar över temats färger.
- _Arcade_ ritar samma appar som 8-bitars pixelkonst, som en gammal spelkonsol skulle ha gjort det.
- _Original_ visar varje app med den ikon som dess skapare gav den.

Du kan installera en ikonuppsättning som någon annan har gjort med _Installera > Stil > Ikoner_ (eller `omarchy icons install <git url>`), och ta bort den igen under _Ta bort > Ikoner_. _Uppdatera > Extra ikoner_ hämtar den senaste versionen av de uppsättningar du har installerat.

För att göra din egen lägger du dina ikoner i `~/.config/omarchy/icons/<name>/`, en fil per app, namngiven efter `Icon=`-raden i appens `.desktop`-fil. En fil som slutar på `.svg` visas som den är. En fil som slutar på `.svg.tpl` ritas i temats färger: skriv `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` eller `{{ icon_shadow }}` där en färg ska vara. Standarduppsättningen i `/usr/share/omarchy/icons/papercraft/` är ett bra ställe att utgå från. Lägg till en `preview.png` för att visa din uppsättning i väljaren; utan en sådan ritar Omarchy en förhandsvisning från dina ikoner. För att ändra en enskild ikon i standarduppsättningen lägger du din version i `~/.config/omarchy/icons/papercraft/`.

### Uppstart och inloggning

Skärmen som ber om ditt disk lösenord när datorn startar, och inloggningsskärmen, följer också temat. Varje gång du byter tema tar de över dess bakgrund, text, accentfärg och röda färger, så det finns ingen separat upplåsningsdesign att välja. På Apple Silicon-Macar behåller skärmen för disk lösenord Omarchys standardutseende oavsett tema.
