# Pikanäppäimet

Näet kaikki tärkeimmät näppäinsidonnat näppäimillä `Super + K` (Tmux-sidonnat näppäimillä `Super + Alt + K` ja Herdr-sidonnat näppäimillä `Super + Ctrl + K`).

## Miten pikanäppäimet on järjestetty

Jokainen pikanäppäin sijaitsee tasolla, jonka sen muunnosnäppäimet määräävät, ja jokaisella tasolla on yksi tehtävä. Se pitää pikanäppäimet erillään toisistaan, ja sen ansiosta voit yleensä arvata, missä jokin sijaitsee.

| Taso | Mitä siellä on | Esimerkkejä |
| --- | --- | --- |
| `Super + key` | Järjestelmä: ikkunat, työtilat, asettelut ja ydinvalikot | `Super + Space` Omarchy-valikko, `Super + W` sulje ikkuna, `Super + F` koko näyttö |
| `Super + Shift + key` | Sovellukset | `Super + Shift + B` selain, `Super + Shift + E` sähköposti, `Super + Shift + N` editori |
| `Super + Ctrl + key` | Paneelit ja järjestelmävalikot | `Super + Ctrl + A` ääni, `Super + Ctrl + N` verkko, `Super + Ctrl + C` kaappausvalikko |
| `Super + Ctrl + Alt + key` | Pikatoiminnot ja ilmoitukset | `Super + Ctrl + Alt + T` näytä aika, `Super + Ctrl + Alt + B` akku, `Super + Ctrl + Alt + C` kuvakaappaus |

`Alt`-näppäimen lisääminen pikanäppäimeen antaa sinulle muunnelman samasta asiasta, ei koskaan jotakin täysin muuta:

- `Super + Shift + B` avaa selaimen; `Super + Shift + Alt + B` avaa yksityisen ikkunan
- `Super + Shift + E` avaa sähköpostin; `Super + Shift + Alt + E` aloittaa uuden sähköpostin
- `Super + F` siirtyy koko näyttöön; `Super + Alt + F` siirtyy koko leveyteen
- `Super + Ctrl + C` avaa kaappausvalikon; `Super + Ctrl + Alt + C` ohittaa valikon ja ottaa kuvakaappauksen

Kun lisäät pikanäppäimen:

1. Valitse taso sen perusteella, mitä se tekee, ja valitse sitten näppäin.
2. Älä siirrä olemassa olevaa pikanäppäintä tehdäksesi tilaa. Etsi vapaa näppäin oikealta tasolta.
3. Käytä `Alt`-näppäintä vain ilman sitä olevan pikanäppäimen muunnelmaan.

Muutama pikanäppäin rikkoo näitä sääntöjä, koska ne ovat käteviä. `Shift` nuolen tai `Tab`-näppäimen kanssa siirtää tai kääntää suunnan sen sijaan, että avaisi sovelluksen, ja `Print`, medianäppäimet, `Alt + Tab` ja `Ctrl + Alt + Del` toimivat niin kuin ne toimivat kaikkialla muuallakin. Ne ovat poikkeuksia, eivät kopioitavia malleja.

Jos oletus ei sovi sinulle (sanotaan, että haluat näppäimet `Super + Shift + S` kuvakaappauksille kuten Windowsissa), sido se uudelleen tiedostossa `~/.config/hypr/bindings.lua`.

## Navigointi

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy-valikko (sovellukset ja kaikki muu)    |
| `Super + Alt + Space` | Sovellusruudukko |
| `Super + Escape` | Järjestelmävalikko (lepotila, uudelleenkäynnistys jne.)  |
| `Super + Ctrl + L` | Lukitse tietokone |
| `Super + W` tai `Super + Q` | Sulje ikkuna             |
| `Ctrl + Alt + Del` | Sulje kaikki ikkunat |
| `Super + K` | Näytä kaikki pikanäppäimet |
| `Super + Alt + K` | Näytä tmux-pikanäppäimet |
| `Super + Ctrl + K` | Näytä herdr-pikanäppäimet |
| `Super + M` | Pienennä ikkuna telakkaan |
| `Super + T`               | Vaihda ikkuna laatoituksen ja kelluvan välillä             |
| `Super + J` | Vaihda ikkunan asentoa (vaaka/pysty) |
| `Super + O`               | Vaihda ikkuna esiin ponnahtavaan sticky'n'floating-tilaan |
| `Super + L`               | Kierrä dwindle-, scrolling- ja floating-asettelujen läpi |
| `Super + Alt + L`         | Kierrä asettelujen läpi päinvastaisessa järjestyksessä |
| `Super + P`               | Vaihda pseudo-ikkunatyyliä (natural v stretch) |
| `Super + F`                 | Siirry koko näyttöön              |
| `Super + Alt + F`                 | Siirry koko leveyteen              |
| `Super + Ctrl + F`                 | Siirry koko näyttöön ikkunan sisällä              |
| `Super + 1…9/0`         | Siirry tiettyyn työtilaan (0 on 10) kohdistetulla näytöllä |
| `Super + Tab` | Siirry seuraavaan työtilaan kohdistetulla näytöllä |
| `Super + Shift + Tab` | Siirry edelliseen työtilaan kohdistetulla näytöllä |
| `Super + Ctrl + Tab` | Siirry aiempaan työtilaan kohdistetulla näytöllä |
| `Super + Shift + 1…9/0` | Siirrä ikkuna työtilaan kohdistetulla näytöllä |
| `Super + Shift + Alt + 1…9/0` | Siirrä ikkuna työtilaan kohdistetulla näytöllä seuraamatta mukana |
| `Super + S` | Vaihda koko scratchpad |
| `Super + Alt + S` | Siirrä ikkuna koko scratchpadiin |
| `Super + Grave` | Vaihda Quake-konsoli |
| `Super + Shift + Grave` | Siirrä ikkuna Quake-konsoliin |
| `Super + Shift + Ctrl + Arrows` | Siirrä ikkuna kyseisen suunnan näytölle |
| `Super + Shift + Alt + Arrows` | Siirrä työtila kyseisen suunnan näytölle |
| `Super + Arrow`  | Siirrä kohdistus nuolen suuntaiseen ikkunaan, ylittäen näytön reunalta kyseisen puolen näytölle |
| `Super + Shift + Arrow`  | Vaihda ikkuna toiseen nuolen suunnassa, mukaan lukien kyseisen puolen näytöllä oleva |
| `Super + Minus` | Laajenna ikkunaa vasemmalle |
| `Super + Equal` | Kutista ikkunaa vasemmalta |
| `Super + Shift + Minus` | Kutista ikkunaa ylhäältä |
| `Super + Shift + Equal` | Laajenna ikkunaa alaspäin |
| `Super + Alt + Minus/Equal` | Sama koon muuttaminen pienemmin askelin |
| `Super + Ctrl + Minus/Equal` | Sama koon muuttaminen suuremmin askelin |
| `Super + Alt + Home` | Tallenna ikkunan leveys |
| `Super + Home` | Palauta tallennettu ikkunan leveys |
| `Super + Left Mouse` | Vedä ikkunaa ympäri |
| `Super + Right Mouse` | Muuta ikkunan kokoa |
| `Super + Scroll Wheel` | Selaa työtiloja kohdistetulla näytöllä |
| `Super + G`               | Vaihda ikkunoiden ryhmittelyä      |
| `Super + Alt + G`               | Siirrä ikkuna pois ryhmittelystä      |
| `Super + Alt + Tab`               | Kierrä ryhmittelyn ikkunoiden välillä      |
| `Super + Alt + Shift + Tab`               | Kierrä taaksepäin ryhmittelyn ikkunoiden välillä      |
| `Super + Alt + Scroll Wheel` | Kierrä ryhmittelyn ikkunoiden välillä |
| `Super + Alt + 1/2/3/4/5`               | Siirry tiettyyn ikkunaan ryhmittelyssä      |
| `Super + Alt + Arrow`  | Siirrä ikkuna ryhmittelyyn nuolen suunnassa, mukaan lukien kyseisen puolen näytöllä oleva |
| `Super + Ctrl + Left/Right`  | Siirry ikkunoiden välillä laatoitusryhmän sisällä |
| `Super + Ctrl + Z` | Lähennä näyttöä (toista lisätäksesi zoomausta) |
| `Super + Ctrl + Alt + Z` | Loitonna näyttö täysin |
| `Super + /` | Siirry eteenpäin näytön skaalausvaihtoehdoissa |
| `Super + Alt + /` | Siirry taaksepäin näytön skaalausvaihtoehdoissa |
| `Alt + Tab` | Kierrä eteenpäin aktiivisen työtilan ikkunoiden läpi |
| `Alt + Shift + Tab` | Kierrä taaksepäin aktiivisen työtilan ikkunoiden läpi |
| `Ctrl + Alt + Tab`| Kierrä kohdistusta eteenpäin näyttöjen läpi |
| `Ctrl + Alt + Shift + Tab`| Kierrä kohdistusta taaksepäin näyttöjen läpi |
| `Super + I` | Vaihda syöttökieltä (kun käytössä on useampi kuin yksi asettelu tai syöttötapa) |
| `Super + Shift + I` | Vaihda syöttökieli takaisin |

Kosketuslevyllä kolmen ja neljän sormen pyyhkäisyt vaihtavat työtiloja, siirtävät ikkunoita ja avaavat valikon ja Quake-konsolin; katso eleet kohdasta [näppäimistö, hiiri ja kosketuslevy](34-keyboard-mouse-trackpad.md).

Koonmuutospikanäppäimet käyttävät fyysisiä näppäimiä `code:20` ja `code:21` (XKB `<AE11>` ja `<AE12>`) riippumatta näppäimistöön painetuista merkeistä. US-näppäimistöillä nämä näppäimet ovat `-` ja `=`; japanilaisilla (JIS) näppäimistöillä ne ovat `-` ja `^`; espanjalaisilla näppäimistöillä ne ovat `'` ja `¡`. JIS-näppäimistöllä `Super + ^` on `Super + Equal`, kun taas `Super + Shift + -` (joka kirjoittaa merkin `=`) on `Super + Shift + Minus`.

## Järjestelmän hallinta

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Äänipaneeli    |
| `Super + Ctrl + B`           | Bluetooth-paneeli    |
| `Super + Ctrl + N`           | Wi-Fi-/verkkopaneeli    |
| `Super + Ctrl + D`           | Näyttöpaneeli    |
| `Super + Ctrl + P`           | Virtapaneeli    |
| `Super + Ctrl + X`           | Agenttipaneeli    |
| `Super + Ctrl + Alt + X`           | Paikallisten mallien paneeli    |
| `Super + Ctrl + Alt + D`           | Kalenteripaneeli    |
| `Super + Ctrl + Alt + E`           | Maailmankellopaneeli    |
| `Super + Ctrl + 1-9`           | Vaihda palkkipaneelia sijainnin mukaan    |
| `Super + Ctrl + S` | Jakovalikko (LocalSendin kautta) |
| `Super + Ctrl + C` | Kaappauksen hallinta (kuvakaappaus/-tallennus/valitsin) |
| `Super + Ctrl + O` | Vaihda valikko |
| `Super + Ctrl + H` | Laitteistovalikko |
| `Super + Ctrl + E` | Hymiövalitsin |
| `Super + Ctrl + .` | Transkoodaa media |
| `Super + Shift + Ctrl + A` | Käynnistä oletusagenttisi |
| `Power`-näppäin | Järjestelmävalikko |
| `Super + Shift + Copilot` -näppäin | Omarchy-valikko |

## Säädöt

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Näytön enimmäiskirkkaus |
| `Shift + Brightness Down` | Näytön vähimmäiskirkkaus |
| `Alt + Brightness Up/Down` | Tarkat 1% kirkkauden muutokset |
| `Alt + Volume Up/Down` | Tarkat 1% äänenvoimakkuuden muutokset |
| `Keyboard Brightness Up/Down` | Näppäimistön taustavalo kirkkaammaksi/himmeämmäksi |
| `Keyboard Backlight` | Kierrä näppäimistön taustavalon tasoja |
| `Ctrl + Brightness Up/Down` | Näppäimistön taustavalo kirkkaammaksi/himmeämmäksi näppäimistöillä, joilla ei ole omia näppäimiä |
| `Mic Mute` | Mykistä mikrofoni |
| `Shift + Mute` | Vaihda äänen ulostuloa |
| `Touchpad Toggle` | Kytke kosketuslevy päälle tai pois |
| `Display`-näppäin | Kierrä työtilan asettelua |
| `Alt + Play` | Seuraava kappale |
| `Alt + Shift + Play` | Edellinen kappale |

## Sovellusten käynnistäminen

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Super + Return`           | Pääte    |
| `Super + Alt + Return` | Tmux-pääte |
| `Super + Ctrl + Return` | Herdr (agenttien hallinta) |
| `Super + Shift + Return` tai `Super + Shift + B`  | Selain    |
| `Super + Shift + Alt + B`           | Selain (yksityinen/incognito)    |
| `Super + Shift + F`           | Tiedostonhallinta    |
| `Super + Shift + Alt + F`           | Tiedostonhallinta päätteen cwd:ssä    |
| `Super + Shift + M`           | Musiikki (Spotify)    |
| `Super + Shift + Alt + M`           | Musiikki (cliamp)    |
| `Super + Shift + /`           | Salasananhallinta (1password)    |
| `Super + Shift + Q` tai `Calculator`-näppäin  | Laskin (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, kun asennettu)    |
| `Super + Shift + T`           | Toiminta (btop)    |
| `Super + Shift + N`           | Editori (Plain tai valitsemasi oletus)  |
| `Super + Shift + C`           | Kalenteri ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Sähköposti ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Uusi sähköposti ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Oletusagenttisi tai ChatGPT, kunnes valitset sellaisen |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Viestisovellus (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Viestisovellus (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Viestisovellus (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Kirjoittaminen (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (uusi julkaisu) |
| `Super + Shift + Y`           | YouTube |

Muuta/lisää sidontoja tiedostossa `~/.config/hypr/bindings.lua`.

## Yleinen leikepöytä

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Super + A`           | Valitse kaikki sovelluksissa, jotka tukevat näppäimiä `Ctrl + A`    |
| `Super + C`           | Kopioi    |
| `Super + X`           | Leikkaa (ei päätteessä)    |
| `Super + V`           | Liitä    |
| `Super + Ctrl + V`           | Leikepöydän hallinta    |

Yleensä Linuxissa tarvitset näppäimet `Ctrl + Shift + C/V` kopiointiin ja liittämiseen päätteessä ja näppäimet `Ctrl + C/V` tehdäksesi sen kaikkialla muualla. Nämä Omarchyn yhtenäistetyt leikepöydän pikanäppäimet toimivat kaikkialla.

## Kaappaus

| Pikanäppäin              | Toiminto                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Kuvakaappaus                      |
| `Super + Ctrl + Alt + C`            | Kuvakaappaus (sama otos näppäimistöille, joilla ei ole Print Screen -näppäintä) |
| `Super + Ctrl + C` | Kaappausvalikko |
| `Alt + Print Screen`            | Näytön tallennus                     |
| `Super + Shift + Ctrl + Alt + C` | Näytön tallennus ilman ääntä, valikko ohittaen (paina uudelleen lopettaaksesi) |
| `Super + Print Screen` | Värivalitsin |
| `Super + Ctrl + Print Screen` | Tekstin poiminta leikepöydälle |
| `Super + Alt + [` | Pienennä webcam-peittokuvaa tallennuksen aikana |
| `Super + Alt + ]` | Suurenna webcam-peittokuvaa tallennuksen aikana |
| `Alt + Shift + L` | Kopioi nykyinen URL verkkosovelluksesta tai selaimesta |
| `Alt + Shift + D` | Lataa nykyisellä sivulla oleva video kansioon `~/Videos` |
| `Alt + Space` | Aloita/lopeta sanelu (vaatii kohdan _Setup > Defaults > Dictation_) |
| `Right Alt` | Pidä painettuna sanellaksesi (vaatii kohdan _Setup > Defaults > Dictation_) |

Näytön tallennuksissa pikanäppäin kysyy ensin, mitä ääntä haluat, ja aloittaa sitten tallennuksen. Paina sitä uudelleen lopettaaksesi. Katso yksityiskohdat kohdasta [kuvakaappaukset ja tallennus](12-screenshots-recording.md).

Kaikki kaappausvaihtoehdot ovat käytettävissä myös Omarchy-valikon kohdassa _Trigger > Capture_ (`Super + Space`).

## Ilmoitukset

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Super + ,` | Toimi uusimman ilmoituksen suhteen: avaa se tai paina sen ainoaa painiketta, valitse sen vaihtoehdoista tai hylkää se, kun sillä ei ole yhtään  |
| `Super + Shift + ,` | Hylkää kaikki ilmoitukset |
| `Super + Ctrl + ,` | Hallitse ilmoituksia näppäimistöllä  |
| `Super + Alt + ,` | Hylkää uusin ilmoitus  |
| `Super + Shift + Alt + ,` | Avaa ilmoitushistoria  |
| `Super + Ctrl + Alt + ,` | Vaihda ilmoitusten hiljentämistä  |

## Tyyli

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Valitse uusi teema (myös `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Valitse teeman tausta (myös `Super + Ctrl + Space`) |
| `Super + Backspace` | Vaihda ikkunan läpinäkyvyyttä |
| `Super + Ctrl + Backspace` | Vaihda yhden ikkunan neliönmuotoista kuvasuhdetta |

Lisätaustakuvat sijaitsevat kansiossa `~/.config/omarchy/backgrounds/<theme name>`. Saatavilla myös Omarchy-valikon kohdan _Install > Style > Background_ kautta.

Kaikki tyylivaihtoehdot ovat käytettävissä myös Omarchy-valikon kohdassa _Appearance_ (`Super + Space`).

## Vaihtotoiminnot

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Vaihda lukitusta joutilaana ollessa |
| `Super + Ctrl + Delete` | Vaihda kannettavan näyttö päälle/pois |
| `Super + Ctrl + Alt + Delete` | Vaihda kannettavan näytön peilausta |
| `Super + Shift + Space` | Vaihda yläpalkkia  |
| `Shift + Mute` | Vaihda seuraavaan äänen ulostuloon |
| `Shift + Play` | Vaihda seuraavaan medialähteeseen |
| `Super + Shift + Backspace` | Vaihda ikkunoiden välejä |
| `Super + Ctrl + Alt + F` | Vaihda koko näytön työpöytää (yläpalkki + ikkunoiden välit) |

## Muistutukset

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Aseta muistutus  |
| `Super + Ctrl + Alt + R` | Näytä kaikki muistutukset  |
| `Super + Ctrl + Shift + R` | Tyhjennä kaikki muistutukset  |

## Pikailmoitukset

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Näytä aika ilmoituksena  |
| `Super + Ctrl + Alt + B` | Näytä akku ilmoituksena  |
| `Super + Ctrl + Alt + W` | Vaihda sään näyttämistä ilmoituksena  |

## Tmux

Etuliitenäppäin on `Ctrl + Space` (`Ctrl + B` toimii myös). Voit muuttaa näitä sidontoja tiedostossa `~/.config/tmux/tmux.conf`.

### Ruudut

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Prefix + v` | Jaa ruutu viereen (pystysuunnassa) |
| `Prefix + h` | Jaa ruutu alle (vaakasuunnassa) |
| `Prefix + x` | Tapa ruutu |
| `Prefix + z` | Vaihda ruudun zoomausta (koko näyttö) |
| `Alt + Enter` | Jaa ruutu alle (ilman etuliitettä) |
| `Alt + Shift + Enter` | Jaa ruutu viereen (ilman etuliitettä) |
| `Alt + Escape` | Tapa ruutu (ilman etuliitettä) |
| `Ctrl + Alt + Arrows` | Siirry ruutujen välillä |
| `Ctrl + Alt + Shift + Arrows` | Muuta ruutujen kokoa |

### Ikkunat

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Prefix + c` | Uusi ikkuna |
| `Prefix + k` | Tapa ikkuna |
| `Prefix + r` | Nimeä ikkuna uudelleen |
| `Alt + 1-9` | Siirry tiettyyn ikkunaan |
| `Alt + Arrow Left/Right` | Siirry ikkunoiden välillä |
| `Alt + Shift + Arrow Left/Right` | Siirrä ikkunaa vasemmalle/oikealle |

### Istunnot

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Prefix + C` | Uusi istunto |
| `Prefix + K` | Tapa istunto |
| `Prefix + R` | Nimeä istunto uudelleen |
| `Prefix + N` | Seuraava istunto |
| `Prefix + P` | Edellinen istunto |
| `Alt + Arrow Up/Down` | Siirry istuntojen välillä |
| `Prefix + s` | Listaa istunnot |
| `Prefix + d` | Irrota istunnosta |

### Kopiointitila (vi-tyylinen)

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Prefix + [` | Siirry kopiointitilaan |
| `v` | Aloita valinta (kopiointitilassa) |
| `y` | Kopioi valinta (kopiointitilassa) |

### Yleistä

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Prefix + q` | Lataa määritykset uudelleen |
| `Prefix + ?` | Näytä Tmux-näppäinsidonnat |
| `Prefix + :` | Komentokehote |

### Tmux-asettelutoiminnot

Nämä toiminnot on suoritettava Tmux-istunnon sisällä.

| Komento | Toiminto |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Luo kehitysasettelu editorilla, AI:lla ja päätteellä |
| `tdlm <ai> [<second_ai>]` | Luo kehitysasettelu alikansioittain |
| `tsl <count> <command>` | Luo moniruutuinen swarm-asettelu |

## Ghostty-pääte

Ghostty-pääte asennetaan Omarchy-valikon kohdan _Install > Terminal_ avulla.

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Uusi jako alle |
| `Ctrl + Shift + O` | Uusi jako viereen |
| `Ctrl + Alt + Arrows` | Siirry jakojen välillä |
| `Super + Ctrl + Shift + Arrows` | Muuta jaon kokoa 10 rivillä |
| `Super + Ctrl + Shift + Alt + Arrows` | Muuta jaon kokoa 100 rivillä |
| `Ctrl + Shift + T` | Uusi välilehti  |
| `Ctrl + Shift + Arrows` | Siirry välilehtien välillä |
| `Alt + Numbers` | Siirry tiettyyn välilehteen |
| `Shift + Pg Up/Down` | Selaa historiaa |
| `Ctrl + Left mouse` | Avaa linkki selaimessa |

## Tiedostonhallinta

| Pikanäppäin              | Toiminto                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Siirry polkuun                     |
| `Space`               | Esikatsele tiedostoa (nuolet navigoivat) |
| `Alt + Up`       | Siirry ylös emokansioon        |

## Neovim (w/ lazyvim)

### Navigointi

| Pikanäppäin                   | Toiminto                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Näytä komentovaihtoehdot            |
| `Space Space`              | Avaa tiedosto sumealla haulla      |
| `Space E`                  | Vaihda sivupalkkia                  |
| `Space G G`                | Näytä git-hallintatyökalut               |
| `Space S G`                | Etsi tiedoston sisällöstä             |
| `Ctrl + W W`               | Siirry sivupalkin ja editorin välillä |
| `Ctrl + Left/right arrow`  | Muuta sivupalkin kokoa          |
| `Shift + H`                      | Siirry vasempaan tiedostovälilehteen             |
| `Shift + L`                      | Siirry oikeaan tiedostovälilehteen            |
| `Space B D`                | Sulje tiedostovälilehti                  |

### Sivupalkissa ollessa

| Pikanäppäin                   | Toiminto                        |
| ------------------------ | ------------------------------- |
| `A`                        | Lisää uusi tiedosto emohakemistoon      |
| `Shift + A`                | Lisää uusi alihakemisto emohakemistoon    |
| `D`                        | Poista korostettu tiedosto/hakemisto     |
| `M`                        | Siirrä korostettu tiedosto/hakemisto       |
| `R`                        | Nimeä korostettu tiedosto/hakemisto uudelleen     |
| `?`                        | Näytä ohje kaikille komennoille      |

[Katso kaikki LazyVimin määrittämät Neovim-pikanäppäimet](https://www.lazyvim.org/keymaps).

## Pikahymiöt

Voit käyttää näppäimiä `Super + Ctrl + E` näyttääksesi täydellisen hymiövalitsimen, joka asettaa valinnan leikepöydälle, tai voit käyttää näitä pikakäyttövaihtoehtoja.

| Pikanäppäin       | EM | Vihje       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | hymy      |
| `Shift + CapsLock M C` | 😂 | itku        |
| `Shift + CapsLock M L` | 😍 | rakkaus       |
| `Shift + CapsLock M V` | ✌️ | voitto    |
| `Shift + CapsLock M H` | ❤️ | sydän      |
| `Shift + CapsLock M Y` | 👍 | kyllä        |
| `Shift + CapsLock M N` | 👎 | ei         |
| `Shift + CapsLock M F` | 🖕 | vittu       |
| `Shift + CapsLock M W` | 🤞 | toivomus       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | suukko       |
| `Shift + CapsLock M E` | 🙄 | silmien pyörittely    |
| `Shift + CapsLock M I` | 😉 | silmänisku       |
| `Shift + CapsLock M P` | 🙏 | rukoile |
| `Shift + CapsLock M D` | 🤤 | kuolaa      |
| `Shift + CapsLock M M` | 💰 | raha      |
| `Shift + CapsLock M X` | 🎉 | juhla |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | malja      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | tervehdys |
| `Shift + CapsLock M A` |💪 | käsivarsi |
| `Shift + CapsLock M B` |🤯 | räjähtävä |

## Pikatäydennykset

| Pikanäppäin       | Täydennys       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (pitkä viiva)   |
| `Shift + CapsLock Space N` | Nimesi (kuten se syötettiin asennuksessa)  |
| `Shift + CapsLock Space E` | Sähköpostisi (kuten se syötettiin asennuksessa)  |

Voit lisätä omiasi muokkaamalla tiedostoa `~/.XCompose` ja suorittamalla sitten päätteessä komennon `omarchy restart xcompose`, jotta muutokset otetaan käyttöön.
