# Teemad

Omarchyga on kaasas kakskümmend kolm ilusat teemat. Neid saad valida Omarchy menüüs (`Super + Space`) jaotise _Välimus > Teema_ kaudu või hüpata otse teemavalijasse klahvikombinatsiooniga `Super + Ctrl + T`.

Iga teema kujundab töölauda, terminali, neovimi, tegevusekraani (btop), sinu brauserit (Chrome, Chromium, Edge või Brave) ja kogu Omarchy kesta: ülemist riba, menüüd, teavitusi, OSD-d ja lukustuskuva. (Obsidiani puhul pead Omarchy teema käsitsi valima rakenduse sees jaotise _Välimus > Teemad_ kaudu).

Teemadel on hulk taustapilte, mille vahel saad valida klahvikombinatsiooniga `Super + Ctrl + W`.

Veel rohkem teemasid leiad [lisateemade lehelt](https://omarchy.org/themes/) või saad isegi [oma teema teha](43-making-your-own-theme.md).

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

### Rakenduste ikoonid

Rakenduste käivitaja ja doki ikoonid on joonistatud sinu teema värvides, seega muutuvad need koos teemaga. Need pärinevad ikoonikomplektist, mille valid teemast eraldi jaotise _Välimus > Ikoonid_ alt iga komplekti eelvaadete järgi, samamoodi nagu valid teemat:

- _Papercraft_ on vaikevalik: kõik, mis tuleb kaasa paigaldatuna, on joonistatud ühes stiilis. Rakendused, mida tuntakse nende logo järgi, nagu Chrome, HEY või YouTube, säilitavad oma kuju ja võtavad üle teema värvid.
- _Arcade_ joonistab samad rakendused 8-bitise pikselkunstina, nagu vana mängukonsool teeks.
- _Original_ näitab iga rakendust ikooniga, mille selle tegija sellele andis.

Kellegi teise tehtud ikoonikomplekti saad paigaldada jaotise _Paigalda > Stiil > Ikoonid_ kaudu (või käsuga `omarchy icons install <git url>`) ja selle uuesti eemaldada jaotise _Eemalda > Ikoonid_ alt. _Värskenda > Lisaikoonid_ toob ära sinu paigaldatud komplektide uusima versiooni.

Oma komplekti tegemiseks pane oma ikoonid kausta `~/.config/omarchy/icons/<name>/`, iga rakenduse kohta üks fail, mille nimi vastab rakenduse `.desktop` faili reale `Icon=`. Faili, mis lõpeb laiendiga `.svg`, näidatakse sellisena, nagu see on. Fail, mis lõpeb laiendiga `.svg.tpl`, joonistatakse teema värvides: kirjuta `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` või `{{ icon_shadow }}` kohta, kuhu värv kuulub. Vaikekomplekt kaustas `/usr/share/omarchy/icons/papercraft/` on hea koht, kust alustada. Lisa fail `preview.png`, et oma komplekti valijas näidata; ilma selleta joonistab Omarchy eelvaate sinu ikoonidest. Vaikekomplekti ühe ikooni muutmiseks pane oma versioon kausta `~/.config/omarchy/icons/papercraft/`.

### Käivitamine ja sisselogimine

Kuva, mis küsib arvuti käivitumisel sinu ketta parooli, ja sisselogimiskuva järgivad samuti teemat. Iga kord, kui teemat vahetad, võtavad need üle selle tausta-, teksti-, aktsendi- ja punase värvi, seega pole vaja eraldi avamiskujundust valida. Apple Silicon Macidel säilitab ketta parooli kuva Omarchy vaikeilme olenemata teemast.
