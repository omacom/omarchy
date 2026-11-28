# Mga Tema

May dalawampu't tatlong magagandang tema ang Omarchy. Maaari kang pumili sa mga ito sa pamamagitan ng _Hitsura > Tema_ sa Omarchy Menu (`Super + Space`) o dumiretso sa tagapili ng tema gamit ang `Super + Ctrl + T`.

Iniistiluhan ng bawat tema ang desktop, terminal, neovim, activity screen (btop), ang browser mo (Chrome, Chromium, Edge o Brave), at ang buong Omarchy shell: top bar, menu, mga notification, OSD, at ang lock screen. (Para sa Obsidian, kailangan mong manu-manong piliin ang temang Omarchy sa pamamagitan ng _Hitsura > Mga Tema_ sa loob ng app).

May hanay ng mga background image ang mga tema na maaari mong pagpilian gamit ang `Super + Ctrl + W`.

Makakahanap ka pa ng mas maraming tema sa [pahina ng mga karagdagang tema](https://omarchy.org/themes/) o maaari ka pang [gumawa ng sarili mong tema](43-making-your-own-theme.md).

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

### Mga icon ng app

Ang mga icon sa app launcher at dock ay iginuguhit sa mga kulay ng tema mo, kaya nagbabago rin ang mga ito kasama nito. Nagmumula ang mga ito sa isang icon set, na hiwalay mong pinipili mula sa tema sa ilalim ng _Hitsura > Mga Icon_, mula sa mga preview ng bawat set, sa parehong paraan ng pagpili mo ng tema:

- _Papercraft_ ang default: lahat ng kasamang naka-install, iginuhit sa iisang estilo. Ang mga app na nakikilala sa logo nila, tulad ng Chrome, HEY, o YouTube, ay pinapanatili ang hugis nito at kinukuha ang mga kulay ng tema.
- Iginuguhit ng _Arcade_ ang parehong mga app bilang 8-bit pixel art, tulad ng gagawin ng isang lumang game console.
- Ipinapakita ng _Original_ ang bawat app gamit ang icon na ibinigay dito ng gumawa nito.

Maaari kang mag-install ng icon set na ginawa ng iba gamit ang _I-install > Estilo > Mga Icon_ (o `omarchy icons install <git url>`), at alisin itong muli sa ilalim ng _Alisin > Mga Icon_. Kinukuha ng _I-update > Mga Karagdagang Icon_ ang pinakabagong bersyon ng mga set na na-install mo.

Para gumawa ng sarili mo, ilagay ang mga icon mo sa `~/.config/omarchy/icons/<name>/`, isang file bawat app, na pinangalanan ayon sa linyang `Icon=` ng `.desktop` file ng app. Ang file na nagtatapos sa `.svg` ay ipinapakita kung ano ito. Ang file na nagtatapos sa `.svg.tpl` ay iginuguhit sa mga kulay ng tema: isulat ang `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` o `{{ icon_shadow }}` kung saan ilalagay ang isang kulay. Ang default na set sa `/usr/share/omarchy/icons/papercraft/` ay magandang lugar para magsimula. Magdagdag ng `preview.png` para ipakita ang set mo sa tagapili; kung wala nito, gagawa ang Omarchy ng preview mula sa mga icon mo. Para baguhin ang isang icon lang ng default na set, ilagay ang bersyon mo sa `~/.config/omarchy/icons/papercraft/`.

### Pag-boot at pag-login

Ang screen na humihingi ng password ng drive mo kapag nagsisimula ang computer, at ang login screen, ay sumusunod din sa tema. Sa bawat pagpapalit mo ng tema, kinukuha nila ang background, teksto, accent, at pulang kulay nito, kaya wala nang hiwalay na disenyo ng pag-unlock na pipiliin. Sa mga Apple Silicon Mac, pinapanatili ng screen ng password ng drive ang default na hitsura ng Omarchy anuman ang tema.
