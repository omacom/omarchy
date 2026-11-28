# Teme

Omarchy dolazi s dvadeset tri prekrasne teme. Možete birati između njih putem _Izgled > Tema_ u izborniku Omarchy Menu (`Super + Space`) ili izravno otići na birač tema pomoću `Super + Ctrl + T`.

Svaka tema oblikuje radnu površinu, terminal, neovim, zaslon aktivnosti (btop), vaš preglednik (Chrome, Chromium, Edge ili Brave) i cijelu ljusku sustava Omarchy: gornju traku, izbornik, obavijesti, OSD i zaključani zaslon. (Za Obsidian morate ručno odabrati temu Omarchy putem _Izgled > Teme_ unutar aplikacije).

Teme imaju skup pozadinskih slika između kojih možete birati pomoću `Super + Ctrl + W`.

Još više tema možete pronaći na [stranici s dodatnim temama](https://omarchy.org/themes/) ili čak [izraditi vlastitu temu](43-making-your-own-theme.md).

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

### Ikone aplikacija

Ikone u pokretaču aplikacija i na docku nacrtane su u bojama vaše teme, pa se mijenjaju zajedno s njom. Dolaze iz skupa ikona, koji birate odvojeno od teme pod _Izgled > Ikone_, iz pregleda svakog skupa, na isti način na koji birate temu:

- _Papercraft_ je zadani: sve što dolazi instalirano, nacrtano u jednom stilu. Aplikacije prepoznatljive po svom logotipu, poput Chrome, HEY ili YouTube, zadržavaju njegov oblik i preuzimaju boje teme.
- _Arcade_ crta iste aplikacije kao 8-bitnu pixel art umjetnost, kao što bi to učinila stara igraća konzola.
- _Original_ prikazuje svaku aplikaciju s ikonom koju joj je dao njezin tvorac.

Skup ikona koji je izradio netko drugi možete instalirati pomoću _Instaliraj > Stil > Ikone_ (ili `omarchy icons install <git url>`), a ponovno ga ukloniti pod _Ukloni > Ikone_. _Ažuriraj > Dodatne ikone_ dohvaća najnoviju verziju skupova koje ste instalirali.

Da biste izradili vlastiti, stavite svoje ikone u `~/.config/omarchy/icons/<name>/`, jednu datoteku po aplikaciji, nazvanu prema retku `Icon=` u `.desktop` datoteci aplikacije. Datoteka koja završava na `.svg` prikazuje se kakva jest. Datoteka koja završava na `.svg.tpl` crta se u bojama teme: napišite `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` ili `{{ icon_shadow }}` tamo gdje ide boja. Zadani skup u `/usr/share/omarchy/icons/papercraft/` dobro je mjesto za početak. Dodajte `preview.png` da biste svoj skup prikazali u biraču; bez njega Omarchy crta pregled iz vaših ikona. Da biste promijenili jednu ikonu zadanog skupa, stavite svoju verziju u `~/.config/omarchy/icons/papercraft/`.

### Pokretanje i prijava

Zaslon koji traži lozinku vašeg diska kada se računalo pokrene i zaslon za prijavu također slijede temu. Svaki put kada promijenite temu, oni preuzimaju njezinu pozadinu, tekst, naglasnu i crvenu boju, pa ne postoji zaseban dizajn otključavanja koji treba birati. Na Apple Silicon Mac računalima zaslon za lozinku diska zadržava zadani izgled sustava Omarchy bez obzira na temu.
