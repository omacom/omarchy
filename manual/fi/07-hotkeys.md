# Pikanäppäimet

Näet kaikki tärkeimmät näppäinsidonnat näppäinyhdistelmällä `Super + K` (Tmux-sidonnat näppäinyhdistelmällä `Super + Alt + K` ja Herdr-sidonnat näppäinyhdistelmällä `Super + Ctrl + K`).

## Miten pikanäppäimet on järjestetty

Jokainen pikanäppäin on tasolla, jonka sen muokkausnäppäimet määrittävät, ja jokaisella tasolla on yksi tehtävä. Siksi pikanäppäimet eivät mene sekaisin, ja yleensä arvaat, missä mikäkin sijaitsee.

| Taso | Mitä siellä on | Esimerkkejä |
| --- | --- | --- |
| `Super + key` | Järjestelmä: ikkunat, työtilat, asettelut ja ydinvalikot | `Super + Space` Omarchy-valikko, `Super + W` sulje ikkuna, `Super + F` koko näyttö |
| `Super + Shift + key` | Sovellukset | `Super + Shift + B` selain, `Super + Shift + E` sähköposti, `Super + Shift + N` editori |
| `Super + Ctrl + key` | Paneelit ja järjestelmävalikot | `Super + Ctrl + A` ääni, `Super + Ctrl + N` verkko, `Super + Ctrl + C` kaappausvalikko |
| `Super + Ctrl + Alt + key` | Pikatoiminnot ja huomautukset | `Super + Ctrl + Alt + T` näytä aika, `Super + Ctrl + Alt + B` akku, `Super + Ctrl + Alt + C` kuvakaappaus |

`Alt`-näppäimen lisääminen pikanäppäimeen antaa saman asian muunnelman, ei koskaan mitään asiaan kuulumatonta:

- `Super + Shift + B` avaa selaimen; `Super + Shift + Alt + B` avaa yksityisen ikkunan
- `Super + Shift + E` avaa sähköpostin; `Super + Shift + Alt + E` aloittaa uuden sähköpostin
- `Super + F` siirtyy koko näyttöön; `Super + Alt + F` siirtyy täyteen leveyteen
- `Super + Ctrl + C` avaa kaappausvalikon; `Super + Ctrl + Alt + C` ohittaa valikon ja ottaa kuvakaappauksen

Kun lisäät pikanäppäimen:

1. Valitse taso sen perusteella, mitä se tekee, ja valitse sitten näppäin.
2. Älä siirrä olemassa olevaa pikanäppäintä tehdäksesi tilaa. Etsi vapaa näppäin oikealta tasolta.
3. Käytä `Alt`-näppäintä vain ilman sitä olevan pikanäppäimen muunnelmaan.

Muutama pikanäppäin rikkoo näitä sääntöjä, koska se on kätevää. `Shift` nuolen tai `Tab`-näppäimen kanssa siirtää tai kääntää suunnan sen sijaan, että avaisi sovelluksen, ja `Print`, medianäppäimet, `Alt + Tab` ja `Ctrl + Alt + Del` toimivat samalla tavalla kuin kaikkialla muuallakin. Ne ovat poikkeuksia, eivät kopioitavia kaavoja.

Jos oletus ei sovi sinulle (esimerkiksi jos haluat kuvakaappauksille näppäinyhdistelmän `Super + Shift + S` kuten Windowsissa), sido se uudelleen tiedostossa `~/.config/hypr/bindings.lua`.

## Navigointi

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy-valikko (sovellukset ja kaikki muu) |
| `Super + Alt + Space` | Sovellusruudukko |
| `Super + Escape` | Järjestelmävalikko (lepotila, uudelleenkäynnistys jne.) |
| `Super + Ctrl + L` | Lukitse tietokone |
| `Super + W` or `Super + Q` | Sulje ikkuna |
| `Ctrl + Alt + Del` | Sulje kaikki ikkunat |
| `Super + K` | Näytä kaikki pikanäppäimet |
| `Super + Alt + K` | Näytä tmux-pikanäppäimet |
| `Super + Ctrl + K` | Näytä herdr-pikanäppäimet |
| `Super + M` | Pienennä ikkuna telakkaan |
| `Super + T` | Vaihda ikkuna laatoituksen/kelluvan välillä |
| `Super + J` | Vaihda ikkunan asento (vaaka/pysty) |
| `Super + O` | Vaihda ikkunan sticky'n'floating-tila |
| `Super + L` | Kierrä dwindle-, scrolling- ja floating-asetteluja |
| `Super + Alt + L` | Kierrä asetteluja päinvastaisessa järjestyksessä |
| `Super + P` | Vaihda pseudo-ikkunatyyli (natural v stretch) |
| `Super + F` | Siirry koko näyttöön |
| `Super + Alt + F` | Siirry täyteen leveyteen |
| `Super + Ctrl + F` | Siirry koko näyttöön ikkunan sisällä |
| `Super + 1…9/0` | Siirry tiettyyn työtilaan (0 on 10) kohdistetulla näytöllä |
| `Super + Tab` | Siirry seuraavaan työtilaan kohdistetulla näytöllä |
| `Super + Shift + Tab` | Siirry edelliseen työtilaan kohdistetulla näytöllä |
| `Super + Ctrl + Tab` | Siirry aiempaan työtilaan kohdistetulla näytöllä |
| `Super + Shift + 1…9/0` | Siirrä ikkuna työtilaan kohdistetulla näytöllä |
| `Super + Shift + Alt + 1…9/0` | Siirrä ikkuna työtilaan kohdistetulla näytöllä seuraamatta mukana |
| `Super + S` | Vaihda täysi scratchpad |
| `Super + Alt + S` | Siirrä ikkuna täyteen scratchpadiin |
| `Super + Grave` | Vaihda Quake-konsoli |
| `Super + Shift + Grave` | Siirrä ikkuna Quake-konsoliin |
| `Super + Shift + Ctrl + Arrows` | Siirrä ikkuna kyseisen suunnan näytölle |
| `Super + Shift + Alt + Arrows` | Siirrä työtila kyseisen suunnan näytölle |
| `Super + Arrow` | Siirrä kohdistus nuolen suuntaiseen ikkunaan, ylittäen kyseisen puolen näytölle näytön reunalla |
| `Super + Shift + Arrow` | Vaihda ikkuna toiseen nuolen suunnassa, mukaan lukien kyseisen puolen näytöllä oleva |
| `Super + Minus` | Laajenna ikkunaa vasemmalle |
| `Super + Equal` | Kutista ikkunaa vasemmalle |
| `Super + Shift + Minus` | Kutista ikkunaa ylöspäin |
| `Super + Shift + Equal` | Laajenna ikkunaa alaspäin |
| `Super + Alt + Minus/Equal` | Sama koon muuttaminen pienemmin askelin |
| `Super + Ctrl + Minus/Equal` | Sama koon muuttaminen suuremmin askelin |
| `Super + Alt + Home` | Tallenna ikkunan leveys |
| `Super + Home` | Palauta tallennettu ikkunan leveys |
| `Super + Left Mouse` | Vedä ikkunaa ympäri |
| `Super + Right Mouse` | Muuta ikkunan kokoa |
| `Super + Scroll Wheel` | Selaa työtiloja kohdistetulla näytöllä |
| `Super + G` | Vaihda ikkunoiden ryhmittely |
| `Super + Alt + G` | Siirrä ikkuna pois ryhmittelystä |
| `Super + Alt + Tab` | Kierrä ryhmittelyn ikkunoiden välillä |
| `Super + Alt + Shift + Tab` | Kierrä taaksepäin ryhmittelyn ikkunoiden välillä |
| `Super + Alt + Scroll Wheel` | Kierrä ryhmittelyn ikkunoiden välillä |
| `Super + Alt + 1/2/3/4/5` | Siirry tiettyyn ikkunaan ryhmittelyssä |
| `Super + Alt + Arrow` | Siirrä ikkuna ryhmittelyyn nuolen suunnassa, mukaan lukien kyseisen puolen näytöllä oleva |
| `Super + Ctrl + Left/Right` | Siirry laatoitusryhmän sisällä olevien ikkunoiden välillä |
| `Super + Ctrl + Z` | Zoomaa näyttöön (toista zoomauksen lisäämiseksi) |
| `Super + Ctrl + Alt + Z` | Zoomaa kokonaan ulos näytöstä |
| `Super + /` | Astu eteenpäin näytön skaalausvaihtoehdoissa |
| `Super + Alt + /` | Astu taaksepäin näytön skaalausvaihtoehdoissa |
| `Alt + Tab` | Kierrä eteenpäin aktiivisen työtilan ikkunoiden läpi |
| `Alt + Shift + Tab` | Kierrä taaksepäin aktiivisen työtilan ikkunoiden läpi |
| `Ctrl + Alt + Tab` | Kierrä kohdistusta eteenpäin näyttöjen läpi |
| `Ctrl + Alt + Shift + Tab` | Kierrä kohdistusta taaksepäin näyttöjen läpi |
| `Super + I` | Vaihda syöttökieltä (kun asetteluja tai syöttömenetelmiä on useampi kuin yksi) |
| `Super + Shift + I` | Vaihda syöttökieltä takaisin |

Kosketuslevyllä kolmen ja neljän sormen pyyhkäisyt vaihtavat työtiloja, siirtävät ikkunoita ja avaavat valikon ja Quake-konsolin; katso eleet kohdasta [näppäimistö, hiiri ja kosketuslevy](34-keyboard-mouse-trackpad.md).

Koon muuttamisen pikanäppäimet käyttävät fyysisiä näppäimiä `code:20` ja `code:21` (XKB `<AE11>` ja `<AE12>`), riippumatta näppäimistöön painetuista merkeistä. Yhdysvaltalaisissa näppäimistöissä nämä näppäimet ovat `-` ja `=`; japanilaisissa (JIS) näppäimistöissä ne ovat `-` ja `^`; espanjalaisissa näppäimistöissä ne ovat `'` ja `¡`. JIS-näppäimistössä `Super + ^` on `Super + Equal`, kun taas `Super + Shift + -` (joka kirjoittaa merkin `=`) on `Super + Shift + Minus`.

## Järjestelmän ohjaimet

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Äänipaneeli |
| `Super + Ctrl + B` | Bluetooth-paneeli |
| `Super + Ctrl + N` | Wifi/verkko-paneeli |
| `Super + Ctrl + D` | Näyttöpaneeli |
| `Super + Ctrl + P` | Virtapaneeli |
| `Super + Ctrl + X` | Agenttipaneeli |
| `Super + Ctrl + Alt + D` | Kalenteripaneeli |
| `Super + Ctrl + Alt + E` | Maailmankellopaneeli |
| `Super + Ctrl + 1-9` | Vaihda palkin paneeli sijainnin mukaan |
| `Super + Ctrl + S` | Jakamisvalikko (LocalSendin kautta) |
| `Super + Ctrl + C` | Kaappausohjaimet (kuvakaappaus/-tallennus/valitsin) |
| `Super + Ctrl + O` | Vaihda valikko |
| `Super + Ctrl + H` | Laitteistovalikko |
| `Super + Ctrl + E` | Emoji-valitsin |
| `Super + Ctrl + .` | Transkoodaa media |
| `Super + Shift + Ctrl + A` | Valitse AI-agentti |
| `Power` key | Järjestelmävalikko |
| `Super + Shift + Copilot` key | Omarchy-valikko |

## Säädöt

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Näytön enimmäiskirkkaus |
| `Shift + Brightness Down` | Näytön vähimmäiskirkkaus |
| `Alt + Brightness Up/Down` | Tarkat 1 %:n kirkkauden muutokset |
| `Alt + Volume Up/Down` | Tarkat 1 %:n äänenvoimakkuuden muutokset |
| `Keyboard Brightness Up/Down` | Näppäimistön taustavalo kirkkaammaksi/himmeämmäksi |
| `Keyboard Backlight` | Kierrä näppäimistön taustavalon tasoja |
| `Ctrl + Brightness Up/Down` | Näppäimistön taustavalo kirkkaammaksi/himmeämmäksi näppäimistöissä, joissa ei ole omia näppäimiä |
| `Mic Mute` | Mykistä mikrofoni |
| `Shift + Mute` | Vaihda äänen ulostulo |
| `Touchpad Toggle` | Kytke kosketuslevy päälle tai pois |
| `Display` key | Kierrä työtilan asettelua |
| `Alt + Play` | Seuraava kappale |
| `Alt + Shift + Play` | Edellinen kappale |

## Sovellusten käynnistäminen

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Super + Return` | Pääte |
| `Super + Alt + Return` | Tmux-pääte |
| `Super + Ctrl + Return` | Herdr (agenttien hallinta) |
| `Super + Shift + Return` or `Super + Shift + B` | Selain |
| `Super + Shift + Alt + B` | Selain (yksityinen/incognito) |
| `Super + Shift + F` | Tiedostonhallinta |
| `Super + Shift + Alt + F` | Tiedostonhallinta päätteen cwd:ssä |
| `Super + Shift + M` | Musiikki (Spotify) |
| `Super + Shift + Alt + M` | Musiikki (cliamp) |
| `Super + Shift + /` | Salasanojen hallinta (1password) |
| `Super + Shift + Q` or `Calculator` key | Laskin (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, kun se on asennettu) |
| `Super + Shift + T` | Aktiivisuus (btop) |
| `Super + Shift + N` | Editori (Plain tai valitsemasi oletus) |
| `Super + Shift + C` | Kalenteri ([HEY](https://hey.com/)) |
| `Super + Shift + E` | Sähköposti ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Uusi sähköposti ([HEY](https://hey.com/)) |
| `Super + Shift + A` | AI (ChatGPT) |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Viestin (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Viestin (WhatsApp) |
| `Super + Shift + Ctrl + G` | Viestin (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Kirjoittaminen (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (uusi julkaisu) |
| `Super + Shift + Y` | YouTube |

Muuta/lisää sidontoja tiedostossa `~/.config/hypr/bindings.lua`.

## Yleinen leikepöytä

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Super + A` | Valitse kaikki sovelluksissa, jotka tukevat näppäinyhdistelmää `Ctrl + A` |
| `Super + C` | Kopioi |
| `Super + X` | Leikkaa (ei päätteessä) |
| `Super + V` | Liitä |
| `Super + Ctrl + V` | Leikepöydän hallinta |

Yleensä Linuxissa tarvitset näppäinyhdistelmän `Ctrl + Shift + C/V` kopioimiseen ja liittämiseen päätteessä ja näppäinyhdistelmän `Ctrl + C/V` tehdäksesi sen kaikkialla muualla. Nämä Omarchyn yhtenäiset leikepöydän pikanäppäimet toimivat kaikkialla.

## Kaappaus

| Pikanäppäin | Toiminto |
| ------------------- | ------------------------------ |
| `Print Screen` | Kuvakaappaus |
| `Super + Ctrl + Alt + C` | Kuvakaappaus (sama otos näppäimistöille, joissa ei ole Print Screen -näppäintä) |
| `Super + Ctrl + C` | Kaappausvalikko |
| `Alt + Print Screen` | Näytön tallennus |
| `Super + Shift + Ctrl + Alt + C` | Näytön tallennus ilman ääntä, valikko ohittaen (paina uudelleen lopettaaksesi) |
| `Super + Print Screen` | Värivalitsin |
| `Super + Ctrl + Print Screen` | Tekstin poiminta leikepöydälle |
| `Super + Alt + [` | Pienennä verkkokameran peittokuvaa tallennuksen aikana |
| `Super + Alt + ]` | Suurenna verkkokameran peittokuvaa tallennuksen aikana |
| `Alt + Shift + L` | Kopioi nykyinen URL verkkosovelluksesta tai selaimesta |
| `Alt + Shift + D` | Lataa nykyisellä sivulla oleva video kansioon `~/Videos` |
| `Alt + Space` | Aloita/lopeta sanelu (vaatii kohdan _Setup > Defaults > Dictation_) |
| `Right Alt` | Pidä painettuna sanelua varten (vaatii kohdan _Setup > Defaults > Dictation_) |

Näytön tallennuksissa pikanäppäin kysyy ensin, minkä äänen haluat, ja aloittaa sitten tallennuksen. Paina sitä uudelleen lopettaaksesi. Katso yksityiskohdat kohdasta [kuvakaappaukset ja tallennus](12-screenshots-recording.md).

Kaikki kaappausvaihtoehdot ovat käytettävissä myös Omarchy-valikon kohdasta _Trigger > Capture_ (`Super + Space`).

## Ilmoitukset

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Super + ,` | Toimi uusimman ilmoituksen suhteen: avaa se tai paina sen ainoaa painiketta, valitse sen vaihtoehdoista tai hylkää se, kun sillä ei ole yhtään |
| `Super + Shift + ,` | Hylkää kaikki ilmoitukset |
| `Super + Ctrl + ,` | Hallitse ilmoituksia näppäimistöllä |
| `Super + Alt + ,` | Hylkää uusin ilmoitus |
| `Super + Shift + Alt + ,` | Avaa ilmoitushistoria |
| `Super + Ctrl + Alt + ,` | Vaihda ilmoitusten vaimentaminen |

## Tyyli

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Valitse uusi teema (myös `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Valitse teeman tausta (myös `Super + Ctrl + Space`) |
| `Super + Backspace` | Vaihda ikkunan läpinäkyvyys |
| `Super + Ctrl + Backspace` | Vaihda yhden ikkunan neliönmuotoinen kuvasuhde |

Lisätaustakuvat ovat kansiossa `~/.config/omarchy/backgrounds/<theme name>`. Saatavilla myös Omarchy-valikon kohdasta _Install > Style > Background_.

Kaikki tyylivaihtoehdot ovat käytettävissä myös Omarchy-valikon kohdasta _Appearance_ (`Super + Space`).

## Päälle/pois-kytkimet

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Vaihda lukitus käyttämättömyyden aikana |
| `Super + Ctrl + Delete` | Vaihda kannettavan näyttö päälle/pois |
| `Super + Ctrl + Alt + Delete` | Vaihda kannettavan näytön peilaus |
| `Super + Shift + Space` | Vaihda yläpalkki |
| `Shift + Mute` | Vaihda seuraavaan äänen ulostuloon |
| `Shift + Play` | Vaihda seuraavaan medialähteeseen |
| `Super + Shift + Backspace` | Vaihda ikkunoiden välit |
| `Super + Ctrl + Alt + F` | Vaihda koko näytön työpöytä (yläpalkki + ikkunoiden välit) |

## Muistutukset

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Aseta muistutus |
| `Super + Ctrl + Alt + R` | Näytä kaikki muistutukset |
| `Super + Ctrl + Shift + R` | Tyhjennä kaikki muistutukset |

## Huomautukset

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Näytä aika ilmoituksena |
| `Super + Ctrl + Alt + B` | Näytä akku ilmoituksena |
| `Super + Ctrl + Alt + W` | Vaihda sää ilmoituksena |

## Tmux

Etuliitenäppäin on `Ctrl + Space` (`Ctrl + B` toimii myös). Voit muuttaa näitä sidontoja tiedostossa `~/.config/tmux/tmux.conf`.

### Ruudut

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Prefix + v` | Jaa ruutu viereen (pystysuora) |
| `Prefix + h` | Jaa ruutu alle (vaakasuora) |
| `Prefix + x` | Tapa ruutu |
| `Prefix + z` | Vaihda ruudun zoomaus (koko näyttö) |
| `Alt + Enter` | Jaa ruutu alle (ilman etuliitettä) |
| `Alt + Shift + Enter` | Jaa ruutu viereen (ilman etuliitettä) |
| `Alt + Escape` | Tapa ruutu (ilman etuliitettä) |
| `Ctrl + Alt + Arrows` | Siirry ruutujen välillä |
| `Ctrl + Alt + Shift + Arrows` | Muuta ruutujen kokoa |

### Ikkunat

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Prefix + c` | Uusi ikkuna |
| `Prefix + k` | Tapa ikkuna |
| `Prefix + r` | Nimeä ikkuna uudelleen |
| `Alt + 1-9` | Siirry tiettyyn ikkunaan |
| `Alt + Arrow Left/Right` | Siirry ikkunoiden välillä |
| `Alt + Shift + Arrow Left/Right` | Siirrä ikkunaa vasemmalle/oikealle |

### Istunnot

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Prefix + C` | Uusi istunto |
| `Prefix + K` | Tapa istunto |
| `Prefix + R` | Nimeä istunto uudelleen |
| `Prefix + N` | Seuraava istunto |
| `Prefix + P` | Edellinen istunto |
| `Alt + Arrow Up/Down` | Siirry istuntojen välillä |
| `Prefix + s` | Listaa istunnot |
| `Prefix + d` | Irrota istunnosta |

### Kopiointitila (vi-tyyli)

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Prefix + [` | Siirry kopiointitilaan |
| `v` | Aloita valinta (kopiointitilassa) |
| `y` | Kopioi valinta (kopiointitilassa) |

### Yleistä

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Prefix + q` | Lataa asetukset uudelleen |
| `Prefix + ?` | Näytä Tmux-näppäinsidonnat |
| `Prefix + :` | Komentokehote |

### Tmux-asettelufunktiot

Nämä funktiot on suoritettava Tmux-istunnon sisällä.

| Komento | Toiminto |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Luo kehitysasettelu editorilla, AI:lla ja päätteellä |
| `tdlm <ai> [<second_ai>]` | Luo kehitysasettelu alikansiota kohden |
| `tsl <count> <command>` | Luo moniruutuinen swarm-asettelu |

## Ghostty-pääte

Ghostty-pääte asennetaan Omarchy-valikon kohdan _Install > Terminal_ kautta.

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Uusi jako alle |
| `Ctrl + Shift + O` | Uusi jako viereen |
| `Ctrl + Alt + Arrows` | Siirry jakojen välillä |
| `Super + Ctrl + Shift + Arrows` | Muuta jaon kokoa 10 rivillä |
| `Super + Ctrl + Shift + Alt + Arrows` | Muuta jaon kokoa 100 rivillä |
| `Ctrl + Shift + T` | Uusi välilehti |
| `Ctrl + Shift + Arrows` | Siirry välilehtien välillä |
| `Alt + Numbers` | Siirry tiettyyn välilehteen |
| `Shift + Pg Up/Down` | Selaa historiaa |
| `Ctrl + Left mouse` | Avaa linkki selaimessa |

## Tiedostonhallinta

| Pikanäppäin | Toiminto |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Siirry polkuun |
| `Space` | Esikatsele tiedostoa (nuolet navigoivat) |
| `Alt + Up` | Siirry ylös ylätason kansioon |

## Neovim (w/ lazyvim)

### Navigointi

| Pikanäppäin | Toiminto |
| ------------------------ | ------------------------------- |
| `Space` | Näytä komentovaihtoehdot |
| `Space Space` | Avaa tiedosto sumealla haulla |
| `Space E` | Vaihda sivupalkki |
| `Space G G` | Näytä git-ohjaimet |
| `Space S G` | Hae tiedoston sisällöstä |
| `Ctrl + W W` | Hyppää sivupalkin ja editorin välillä |
| `Ctrl + Left/right arrow` | Muuta sivupalkin kokoa |
| `Shift + H` | Siirry vasemmanpuoleiseen tiedostovälilehteen |
| `Shift + L` | Siirry oikeanpuoleiseen tiedostovälilehteen |
| `Space B D` | Sulje tiedostovälilehti |

### Sivupalkissa ollessa

| Pikanäppäin | Toiminto |
| ------------------------ | ------------------------------- |
| `A` | Lisää uusi tiedosto ylätason kansioon |
| `Shift + A` | Lisää uusi alikansio ylätason kansioon |
| `D` | Poista korostettu tiedosto/kansio |
| `M` | Siirrä korostettu tiedosto/kansio |
| `R` | Nimeä korostettu tiedosto/kansio uudelleen |
| `?` | Näytä kaikkien komentojen ohje |

[Katso kaikki LazyVimin määrittämät Neovim-pikanäppäimet](https://www.lazyvim.org/keymaps).

## Pika-emojit

Voit käyttää näppäinyhdistelmää `Super + Ctrl + E` näyttääksesi täydellisen emoji-valitsimen, joka asettaa valinnan leikepöydälle, tai voit käyttää näitä pikakäyttövaihtoehtoja.

| Pikanäppäin | EM | Vihje |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | smile |
| `Shift + CapsLock M C` | 😂 | cry |
| `Shift + CapsLock M L` | 😍 | love |
| `Shift + CapsLock M V` | ✌️ | victory |
| `Shift + CapsLock M H` | ❤️ | heart |
| `Shift + CapsLock M Y` | 👍 | yes |
| `Shift + CapsLock M N` | 👎 | no |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | wish |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | kiss |
| `Shift + CapsLock M E` | 🙄 | eyeroll |
| `Shift + CapsLock M I` | 😉 | wink |
| `Shift + CapsLock M P` | 🙏 | pray |
| `Shift + CapsLock M D` | 🤤 | drool |
| `Shift + CapsLock M M` | 💰 | money |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | toast |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | greeting |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | blowing |

## Pikatäydennykset

| Pikanäppäin | Täydennys |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | Nimesi (kuten se syötettiin asennuksen yhteydessä) |
| `Shift + CapsLock Space E` | Sähköpostisi (kuten se syötettiin asennuksen yhteydessä) |

Voit lisätä omiasi muokkaamalla tiedostoa `~/.XCompose` ja suorittamalla sitten päätteessä komennon `omarchy restart xcompose`, jotta muutokset otetaan käyttöön.
