# Þemu

Omarchy kemur með tuttugu og þrjú falleg þemu. Þú getur valið á milli þeirra í gegnum _Útlit > Þema_ í Omarchy Menu (`Super + Space`) eða farið beint í þemavalið með `Super + Ctrl + T`.

Hvert þema stílar skjáborðið, útstöðina, neovim, virkniskjáinn (btop), vafrann þinn (Chrome, Chromium, Edge eða Brave) og alla Omarchy skelina: efstu stikuna, valmyndina, tilkynningar, OSD og læsiskjáinn. (Fyrir Obsidian þarftu að velja Omarchy þemað handvirkt í gegnum _Útlit > Þemu_ inni í forritinu).

Þemu eru með safn af bakgrunnsmyndum sem þú getur valið á milli með `Super + Ctrl + W`.

Þú finnur enn fleiri þemu á [síðunni með aukaþemum](https://omarchy.org/themes/) eða jafnvel [búið til þitt eigið þema](43-making-your-own-theme.md).

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

### Tákn forrita

Táknin í forritaræsinum og bryggjunni eru dregin í litum þemans þíns, svo þau breytast með því. Þau koma úr táknasetti, sem þú velur aðskilið frá þemanu undir _Útlit > Tákn_, úr forskoðunum á hverju setti, á sama hátt og þú velur þema:

- _Papercraft_ er sjálfgefið: allt sem kemur uppsett, dregið í einum stíl. Forrit sem þekkjast af merkinu sínu, eins og Chrome, HEY eða YouTube, halda lögun sinni og taka á sig liti þemans.
- _Arcade_ dregur sömu forrit sem 8-bita pixlamyndlist, eins og gömul leikjatölva myndi gera.
- _Original_ sýnir hvert forrit með tákninu sem framleiðandi þess gaf því.

Þú getur sett upp táknasett sem einhver annar hefur búið til með _Setja upp > Stíll > Tákn_ (eða `omarchy icons install <git url>`) og fjarlægt það aftur undir _Fjarlægja > Tákn_. _Uppfæra > Aukatákn_ sækir nýjustu útgáfuna af settunum sem þú hefur sett upp.

Til að búa til þitt eigið skaltu setja táknin þín í `~/.config/omarchy/icons/<name>/`, eina skrá fyrir hvert forrit, nefnda eftir `Icon=` línunni í `.desktop` skrá forritsins. Skrá sem endar á `.svg` er sýnd eins og hún er. Skrá sem endar á `.svg.tpl` er dregin í litum þemans: skrifaðu `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` eða `{{ icon_shadow }}` þar sem litur á að vera. Sjálfgefna settið í `/usr/share/omarchy/icons/papercraft/` er góður staður til að byrja á. Bættu við `preview.png` til að sýna settið þitt í veljaranum; án einnar slíkrar dregur Omarchy forskoðun úr táknunum þínum. Til að breyta einu tákni í sjálfgefna settinu skaltu setja útgáfuna þína í `~/.config/omarchy/icons/papercraft/`.

### Ræsing og innskráning

Skjárinn sem biður um lykilorð drifsins þíns þegar tölvan ræsir og innskráningarskjárinn fylgja þemanu líka. Í hvert sinn sem þú skiptir um þemu taka þeir upp bakgrunn þess, textalit, áherslulit og rauða litinn, svo það er engin aðskilin aflæsingarhönnun til að velja. Á Apple Silicon Mac tölvum heldur skjárinn fyrir lykilorð drifsins sjálfgefnu útliti Omarchy, hvaða þema sem er.
