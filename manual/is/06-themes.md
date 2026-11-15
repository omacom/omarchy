# Þemu

Omarchy fylgja tuttugu og tvö falleg þemu. Þú getur valið á milli þeirra í gegnum _Útlit > Þema_ í Omarchy-valmyndinni (`Super + Space`) eða farið beint í þemavalið með `Super + Ctrl + T`.

Hvert þema stílar skjáborðið, útstöðina, neovim, virkniskjáinn (btop), Chromium og alla Omarchy-skelina: efstu stikuna, valmyndina, tilkynningar, OSD og læsiskjáinn. (Fyrir Obsidian þarftu að velja Omarchy-þemað handvirkt í gegnum _Útlit > Þemu_ inni í forritinu).

Þemu hafa mengi bakgrunnsmynda sem þú getur valið á milli með `Super + Ctrl + W`.

Þú getur fundið enn fleiri þemu á [síðunni með aukaþemum](https://omarchy.org/themes/) eða jafnvel [búið til þitt eigið þema](43-making-your-own-theme.md).

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

### Forritatákn

Táknin í forritaræsinum og bryggjunni eru teiknuð í litum þemans þíns, þannig að þau breytast með því. Þau koma úr táknasetti, sem þú velur aðskilið frá þemanu undir _Útlit > Tákn_, úr forskoðunum á hverju setti, á sama hátt og þú velur þema:

- _Papercraft_ er sjálfgefið: allt sem fylgir uppsett, teiknað í einum stíl. Forrit sem þekkjast af merki sínu, eins og Chrome, HEY eða YouTube, halda lögun sinni og taka á sig liti þemans.
- _Arcade_ teiknar sömu forrit sem 8-bita pixlamyndlist, eins og gömul leikjatölva myndi gera.
- _Original_ sýnir hvert forrit með tákninu sem framleiðandi þess gaf því.

Þú getur sett upp táknasett sem einhver annar hefur búið til með _Setja upp > Stíll > Tákn_ (eða `omarchy icons install <git url>`), og fjarlægt það aftur undir _Fjarlægja > Tákn_. _Uppfæra > Aukatákn_ sækir nýjustu útgáfuna af settunum sem þú hefur sett upp.

Til að búa til þitt eigið skaltu setja táknin þín í `~/.config/omarchy/icons/<name>/`, eina skrá fyrir hvert forrit, nefnda eftir `Icon=` línunni í `.desktop` skrá forritsins. Skrá sem endar á `.svg` er sýnd eins og hún er. Skrá sem endar á `.svg.tpl` er teiknuð í litum þemans: skrifaðu `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` eða `{{ icon_shadow }}` þar sem litur á að fara. Sjálfgefna settið í `/usr/share/omarchy/icons/papercraft/` er góður staður til að byrja á. Bættu við `preview.png` til að sýna settið þitt í veljaranum; án einnar slíkrar teiknar Omarchy forskoðun úr táknunum þínum. Til að breyta einu tákni í sjálfgefna settinu skaltu setja útgáfuna þína í `~/.config/omarchy/icons/papercraft/`.

### Aflæsingar

Þemu geta líka haft sérsniðna aflæsingarhönnun, sem er notuð fyrir afkóðunarferlið við ræsingu. Þú getur valið eina slíka undir _Útlit > Aflæsing_. Þær líta svona út:

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
