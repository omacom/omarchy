# Pikanäppäimet

Näet kaikki tärkeimmät näppäinsidokset näppäimillä `Super + K` (Tmux-sidokset näppäimillä `Super + Alt + K` ja Herdr-sidokset näppäimillä `Super + Ctrl + K`).

## Miten pikanäppäimet on järjestetty

Jokainen pikanäppäin on tasolla, jonka sen muokkausnäppäimet asettavat, ja jokaisella tasolla on yksi tehtävä. Siksi pikanäppäimet eivät mene sekaisin, ja yleensä voit arvata, missä jokin sijaitsee.

| Taso | Mitä siellä on | Esimerkkejä |
| --- | --- | --- |
| `Super + key` | Järjestelmä: ikkunat, työtilat, asettelut ja ydinvalikot | `Super + Space` Omarchy-valikko, `Super + W` sulje ikkuna, `Super + F` koko näyttö |
| `Super + Shift + key` | Sovellukset | `Super + Shift + B` selain, `Super + Shift + E` sähköposti, `Super + Shift + N` editori |
| `Super + Ctrl + key` | Paneelit ja järjestelmävalikot | `Super + Ctrl + A` ääni, `Super + Ctrl + N` verkko, `Super + Ctrl + C` sieppausvalikko |
| `Super + Ctrl + Alt + key` | Pikatoiminnot ja ilmoitukset | `Super + Ctrl + Alt + T` näytä aika, `Super + Ctrl + Alt + B` akku, `Super + Ctrl + Alt + C` kuvakaappaus |

`Alt`-näppäimen lisääminen pikanäppäimeen antaa saman asian muunnelman, ei koskaan jotain täysin muuta:

- `Super + Shift + B` avaa selaimen; `Super + Shift + Alt + B` avaa yksityisen ikkunan
- `Super + Shift + E` avaa sähköpostin; `Super + Shift + Alt + E` aloittaa uuden sähköpostin
- `Super + F` siirtyy koko näyttöön; `Super + Alt + F` siirtyy täyteen leveyteen
- `Super + Ctrl + C` avaa sieppausvalikon; `Super + Ctrl + Alt + C` ohittaa valikon ja ottaa kuvakaappauksen

Kun lisäät pikanäppäimen:

1. Valitse taso sen perusteella, mitä se tekee, ja valitse sitten näppäin.
2. Älä siirrä olemassa olevaa pikanäppäintä tehdäksesi tilaa. Etsi vapaa näppäin oikealta tasolta.
3. Käytä `Alt`-näppäintä vain muunnelmaan pikanäppäimestä ilman sitä.

Muutama pikanäppäin rikkoo näitä sääntöjä, koska ne ovat käteviä. `Shift` nuolen tai `Tab`-näppäimen kanssa siirtää tai kääntää suunnan sen sijaan, että avaisi sovelluksen, ja `Print`, medianäppäimet, `Alt + Tab` ja `Ctrl + Alt + Del` toimivat niin kuin ne toimivat kaikkialla muuallakin. Ne ovat poikkeuksia, eivät kopioitavia malleja.

Jos oletus ei sovi sinulle (esimerkiksi haluat näppäimet `Super + Shift + S` kuvakaappauksiin kuten Windowsissa), sido se uudelleen tiedostossa `~/.config/hypr/bindings.lua`.

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
| `Super + J` | Vaihda ikkunan asentoa (vaaka/pysty) |
| `Super + O` | Vaihda ikkunan ponnauttaminen sticky'n'floating-tilaan |
| `Super + L` | Kierrä dwindle-, scrolling- ja floating-asetteluja |
| `Super + Alt + L` | Kierrä asetteluja päinvastaisessa järjestyksessä |
| `Super + P` | Vaihda pseudo-ikkunatyyliä (luonnollinen v venytetty) |
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
| `Super + the key above Tab` (grave-näppäin yhdysvaltalaisissa asetteluissa) | Vaihda Quake-konsoli |
| `Super + Shift + the key above Tab` (grave-näppäin yhdysvaltalaisissa asetteluissa) | Siirrä ikkuna Quake-konsoliin |
| `Super + Shift + Ctrl + Arrows` | Siirrä ikkuna näyttöön siinä suunnassa |
| `Super + Shift + Alt + Arrows` | Siirrä työtila näyttöön siinä suunnassa |
| `Super + Arrow` | Siirrä kohdistus nuolen suuntaiseen ikkunaan, ylittäen näytön reunalla sillä puolella olevaan näyttöön |
| `Super + Shift + Arrow` | Vaihda ikkuna toiseen nuolen suunnassa, mukaan lukien sillä puolella olevalla näytöllä oleva |
| `Super + Minus` | Laajenna ikkunaa vasemmalle |
| `Super + Equal` | Kutista ikkunaa vasemmalle |
| `Super + Shift + Minus` | Kutista ikkunaa ylöspäin |
| `Super + Shift + Equal` | Laajenna ikkunaa alaspäin |
| `Super + Alt + Minus/Equal` | Sama koon muuttaminen pienemmin askelin |
| `Super + Ctrl + Minus/Equal` | Sama koon muuttaminen suuremmin askelin |
| `Super + Alt + Home` | Tallenna ikkunan leveys |
| `Super + Home` | Palauta tallennettu ikkunan leveys |
| `Super + Left Mouse` | Vedä ikkunaa ympäriinsä |
| `Super + Right Mouse` | Muuta ikkunan kokoa |
| `Super + Scroll Wheel` | Selaa työtiloja kohdistetulla näytöllä |
| `Super + G` | Vaihda ikkunoiden ryhmittely |
| `Super + Alt + G` | Siirrä ikkuna pois ryhmittelystä |
| `Super + Alt + Tab` | Kierrä ryhmittelyn ikkunoiden välillä |
| `Super + Alt + Shift + Tab` | Kierrä taaksepäin ryhmittelyn ikkunoiden välillä |
| `Super + Alt + Scroll Wheel` | Kierrä ryhmittelyn ikkunoiden välillä |
| `Super + Alt + 1/2/3/4/5` | Siirry tiettyyn ikkunaan ryhmittelyssä |
| `Super + Alt + Arrow` | Siirrä ikkuna ryhmittelyyn nuolen suuntaan, mukaan lukien sillä puolella olevalla näytöllä oleva |
| `Super + Ctrl + Left/Right` | Siirry ikkunoiden välillä laatoitusryhmän sisällä |
| `Super + Ctrl + Z` | Lähennä näyttöä (toista saadaksesi lisää lähennystä) |
| `Super + Ctrl + Alt + Z` | Loitonna kokonaan näytöstä |
| `Super + /` | Siirry eteenpäin näytön skaalausvaihtoehdoissa |
| `Super + Alt + /` | Siirry taaksepäin näytön skaalausvaihtoehdoissa |
| `Alt + Tab` | Kierrä eteenpäin aktiivisen työtilan ikkunoiden läpi |
| `Alt + Shift + Tab` | Kierrä taaksepäin aktiivisen työtilan ikkunoiden läpi |
| `Ctrl + Alt + Tab` | Kierrä kohdistusta eteenpäin näyttöjen läpi |
| `Ctrl + Alt + Shift + Tab` | Kierrä kohdistusta taaksepäin näyttöjen läpi |
| `Super + I` | Vaihda syöttökieltä (kun käytössä on useampi kuin yksi asettelu tai syöttötapa) |
| `Super + Shift + I` | Vaihda syöttökieli takaisin |

Kosketuslevyllä kolmen ja neljän sormen pyyhkäisyt vaihtavat työtiloja, siirtävät ikkunoita ja avaavat valikon ja Quake-konsolin; katso eleet kohdasta [näppäimistö, hiiri ja ohjauslevy](34-keyboard-mouse-trackpad.md).

Koon muuttamisessa käytetään kahta näppäintä 0:n oikealla puolella, mitä tahansa näppäimistösi niihin painaakin: `-` ja `=` yhdysvaltalaisilla näppäimistöillä, `+` ja `´` tanskalaisilla ja ruotsalaisilla, `+` ja `\` norjalaisilla, `ß` ja `´` saksalaisilla, `'` ja `¡` espanjalaisilla ja `-` ja `^` japanilaisilla (JIS). `Super + K` luettelee ne niin kuin näppäimistösi ne painaa. JIS-asettelussa `Super + ^` on `Super + Equal`, kun taas `Super + Shift + -` (joka kirjoittaa `=`) on `Super + Shift + Minus`. Näytön skaalaus ja salasananhallinta käyttävät merkkiä `/`; asetteluissa, jotka kirjoittavat merkin `/` vain Shift-näppäimellä, kuten useimmat eurooppalaiset tekevät, ne käyttävät sen sijaan näppäintä oikean Shift-näppäimen vasemmalla puolella (`-` tanskalaisilla ja saksalaisilla).

## Järjestelmäohjaimet

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Äänipaneeli |
| `Super + Ctrl + B` | Bluetooth-paneeli |
| `Super + Ctrl + N` | Wi-Fi-/verkkopaneeli |
| `Super + Ctrl + D` | Näyttöpaneeli |
| `Super + Ctrl + P` | Virtapaneeli |
| `Super + Ctrl + X` | Agenttipaneeli |
| `Super + Ctrl + Alt + D` | Kalenteripaneeli |
| `Super + Ctrl + Alt + E` | Maailmankellopaneeli |
| `Super + Ctrl + 1-9` | Vaihda palkkipaneelia sijainnin mukaan |
| `Super + Ctrl + S` | Jakovalikko (LocalSendin kautta) |
| `Super + Ctrl + C` | Sieppausohjaimet (kuvakaappaus/-tallennus/valitsin) |
| `Super + Ctrl + O` | Vaihda valikko |
| `Super + Ctrl + H` | Laitteistovalikko |
| `Super + Ctrl + E` | Emoji-valitsin |
| `Super + Ctrl + .` | Muunna media |
| `Super + Shift + Ctrl + A` | Käynnistä oletusagenttisi |
| `Power` key | Järjestelmävalikko |
| `Super + Shift + Copilot` key | Omarchy-valikko |

## Säädöt

| Pikanäppäin | Toiminto |
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
| `Display` key | Kierrä työtilan asettelua |
| `Alt + Play` | Seuraava kappale |
| `Alt + Shift + Play` | Edellinen kappale |

## Sovellusten käynnistäminen

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Super + Return` | Terminaali |
| `Super + Alt + Return` | Tmux-terminaali |
| `Super + Ctrl + Return` | Herdr (agenttien hallinta) |
| `Super + Shift + Return` or `Super + Shift + B` | Selain |
| `Super + Shift + Alt + B` | Selain (yksityinen/incognito) |
| `Super + Shift + F` | Tiedostonhallinta |
| `Super + Shift + Alt + F` | Tiedostonhallinta terminaalin cwd-hakemistossa |
| `Super + Shift + M` | Music (Spotify) |
| `Super + Shift + Alt + M` | Music (cliamp) |
| `Super + Shift + /` | Salasananhallinta (1password) |
| `Super + Shift + Q` or `Calculator` key | Laskin (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, kun asennettu) |
| `Super + Shift + T` | Aktiviteetti (btop) |
| `Super + Shift + N` | Editori (Plain tai valitsemasi oletus) |
| `Super + Shift + C` | Kalenteri ([HEY](https://hey.com/)) |
| `Super + Shift + E` | Sähköposti ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Uusi sähköposti ([HEY](https://hey.com/)) |
| `Super + Shift + A` | Oletusagenttisi tai ChatGPT, kunnes valitset sellaisen |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Viestipalvelu (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Viestipalvelu (WhatsApp) |
| `Super + Shift + Ctrl + G` | Viestipalvelu (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Kirjoittaminen (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (uusi julkaisu) |
| `Super + Shift + Y` | YouTube |

Muuta/lisää sidoksia tiedostossa `~/.config/hypr/bindings.lua`.

## Yleinen leikepöytä

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Super + A` | Valitse kaikki sovelluksissa, jotka tukevat näppäimiä `Ctrl + A` |
| `Super + C` | Kopioi |
| `Super + X` | Leikkaa (ei terminaalissa) |
| `Super + V` | Liitä |
| `Super + Ctrl + V` | Leikepöydän hallinta |

Yleensä Linuxissa tarvitset näppäimet `Ctrl + Shift + C/V` kopiointiin ja liittämiseen terminaalissa ja `Ctrl + C/V` tehdäksesi sen kaikkialla muualla. Nämä Omarchyn yhtenäistetyt leikepöydän pikanäppäimet toimivat kaikkialla.

## Sieppaus

| Pikanäppäin | Toiminto |
| ------------------- | ------------------------------ |
| `Print Screen` | Kuvakaappaus |
| `Super + Ctrl + Alt + C` | Kuvakaappaus (sama otos, näppäimistöille joissa ei ole Print Screen -näppäintä) |
| `Super + Ctrl + C` | Sieppausvalikko |
| `Alt + Print Screen` | Näyttötallennus |
| `Super + Shift + Ctrl + Alt + C` | Näyttötallennus ilman ääntä, ohittaen valikon (paina uudelleen lopettaaksesi) |
| `Super + Print Screen` | Värivalitsin |
| `Super + Ctrl + Print Screen` | Tekstin poiminta leikepöydälle |
| `Super + Alt + [` | Pienennä verkkokameran päällystä tallennuksen aikana |
| `Super + Alt + ]` | Suurenna verkkokameran päällystä tallennuksen aikana |
| `Alt + Shift + L` | Kopioi nykyinen URL verkkosovelluksesta tai selaimesta |
| `Alt + Shift + D` | Lataa nykyisellä sivulla oleva video kansioon `~/Videos` |
| `Alt + Space` | Aloita/lopeta sanelu (vaatii kohdan _Setup > Defaults > Dictation_) |
| `Right Alt` | Pidä pohjassa sanellaksesi (vaatii kohdan _Setup > Defaults > Dictation_) |

Näyttötallennuksissa pikanäppäin kysyy ensin, minkä äänen haluat, ja aloittaa sitten tallennuksen. Paina sitä uudelleen lopettaaksesi. Katso yksityiskohdat kohdasta [kuvakaappaukset ja tallennus](12-screenshots-recording.md).

Kaikki sieppausvaihtoehdot ovat myös käytettävissä kohdassa _Trigger > Capture_ Omarchy-valikossa (`Super + Space`).

## Ilmoitukset

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Super + ,` | Toimi uusimman ilmoituksen mukaan: avaa se tai paina sen ainoaa painiketta, valitse sen vaihtoehdoista tai hylkää se, kun sillä ei ole yhtään |
| `Super + Shift + ,` | Hylkää kaikki ilmoitukset |
| `Super + Ctrl + ,` | Hallitse ilmoituksia näppäimistöllä |
| `Super + Alt + ,` | Hylkää uusin ilmoitus |
| `Super + Shift + Alt + ,` | Avaa ilmoitushistoria |
| `Super + Ctrl + Alt + ,` | Vaihda ilmoitusten hiljentäminen |

## Tyyli

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Valitse uusi teema (myös `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Valitse teeman tausta (myös `Super + Ctrl + Space`) |
| `Super + Backspace` | Vaihda ikkunan läpinäkyvyys |
| `Super + Ctrl + Backspace` | Vaihda yksittäisen ikkunan neliömuoto |

Ylimääräiset taustakuvat sijaitsevat kohdassa `~/.config/omarchy/backgrounds/<theme name>`. Myös käytettävissä kohdan _Install > Style > Background_ kautta Omarchy-valikossa.

Kaikki tyylivaihtoehdot ovat myös käytettävissä kohdassa _Appearance_ Omarchy-valikossa (`Super + Space`).

## Kytkimet

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Vaihda lukitus käyttämättömyyden aikana |
| `Super + Ctrl + Delete` | Vaihda kannettavan näyttö päälle/pois |
| `Super + Ctrl + Alt + Delete` | Vaihda kannettavan näytön peilaus |
| `Super + Shift + Space` | Vaihda yläpalkki |
| `Shift + Mute` | Vaihda seuraavaan äänen ulostuloon |
| `Shift + Play` | Vaihda seuraavaan medialähteeseen |
| `Super + Shift + Backspace` | Vaihda ikkunavälit |
| `Super + Ctrl + Alt + F` | Vaihda koko näytön työpöytä (yläpalkki + ikkunavälit) |

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

Etuliitenäppäin on `Ctrl + Space` (`Ctrl + B` toimii myös). Voit muuttaa näitä sidoksia tiedostossa `~/.config/tmux/tmux.conf`.

### Paneelit

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Prefix + v` | Jaa paneeli viereen (pystysuora) |
| `Prefix + h` | Jaa paneeli alle (vaakasuora) |
| `Prefix + x` | Tapa paneeli |
| `Prefix + z` | Vaihda paneelin zoomaus (koko näyttö) |
| `Alt + Enter` | Jaa paneeli alle (ilman etuliitettä) |
| `Alt + Shift + Enter` | Jaa paneeli viereen (ilman etuliitettä) |
| `Alt + Escape` | Tapa paneeli (ilman etuliitettä) |
| `Ctrl + Alt + Arrows` | Siirry paneelien välillä |
| `Ctrl + Alt + Shift + Arrows` | Muuta paneelien kokoa |

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
| `Prefix + s` | Luettele istunnot |
| `Prefix + d` | Irrota istunnosta |

### Kopiointitila (vi-tyylinen)

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Prefix + [` | Siirry kopiointitilaan |
| `v` | Aloita valinta (kopiointitilassa) |
| `y` | Kopioi valinta (kopiointitilassa) |

### Yleistä

| Pikanäppäin | Toiminto |
| ----------------------- | --------------------- |
| `Prefix + q` | Lataa konfiguraatio uudelleen |
| `Prefix + ?` | Näytä Tmux-näppäinsidokset |
| `Prefix + :` | Komentokehote |

### Tmux-asettelufunktiot

Nämä funktiot on suoritettava Tmux-istunnon sisällä.

| Komento | Toiminto |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Luo kehitysasettelu editorilla, AI:lla ja terminaalilla |
| `tdlm <ai> [<second_ai>]` | Luo kehitysasettelu alihakemistoa kohden |
| `tsl <count> <command>` | Luo monipaneelinen swarm-asettelu |

## Ghostty-terminaali

Ghostty-terminaali asennetaan kohdan _Install > Terminal_ kautta Omarchy-valikossa.

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
| `Alt + Up` | Siirry ylös ylähakemistoon |

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
| `Shift + H` | Siirry vasempaan tiedostovälilehteen |
| `Shift + L` | Siirry oikeaan tiedostovälilehteen |
| `Space B D` | Sulje tiedostovälilehti |

### Sivupalkissa ollessa

| Pikanäppäin | Toiminto |
| ------------------------ | ------------------------------- |
| `A` | Lisää uusi tiedosto ylähakemistoon |
| `Shift + A` | Lisää uusi alihakemisto ylähakemistoon |
| `D` | Poista korostettu tiedosto/hakemisto |
| `M` | Siirrä korostettu tiedosto/hakemisto |
| `R` | Nimeä korostettu tiedosto/hakemisto uudelleen |
| `?` | Näytä ohje kaikille komennoille |

[Katso kaikki LazyVimin määrittämät Neovim-pikanäppäimet](https://www.lazyvim.org/keymaps).

## Nopeat emojit

Voit käyttää näppäimiä `Super + Ctrl + E` näyttääksesi täydellisen emoji-valitsimen, joka asettaa valinnan leikepöydälle, tai voit käyttää näitä pikakäyttövaihtoehtoja.

| Pikanäppäin | EM | Vihje |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | hymy |
| `Shift + CapsLock M C` | 😂 | itku |
| `Shift + CapsLock M L` | 😍 | rakkaus |
| `Shift + CapsLock M V` | ✌️ | voitto |
| `Shift + CapsLock M H` | ❤️ | sydän |
| `Shift + CapsLock M Y` | 👍 | kyllä |
| `Shift + CapsLock M N` | 👎 | ei |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | toive |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | suukko |
| `Shift + CapsLock M E` | 🙄 | silmien pyörittely |
| `Shift + CapsLock M I` | 😉 | silmänisku |
| `Shift + CapsLock M P` | 🙏 | rukoile |
| `Shift + CapsLock M D` | 🤤 | kuolaa |
| `Shift + CapsLock M M` | 💰 | raha |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | malja |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | tervehdys |
| `Shift + CapsLock M A` |💪 | käsivarsi |
| `Shift + CapsLock M B` |🤯 | räjähtävä |

## Nopeat täydennykset

| Pikanäppäin | Täydennys |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | Nimesi (kuten syötetty asennuksessa) |
| `Shift + CapsLock Space E` | Sähköpostisi (kuten syötetty asennuksessa) |

Voit lisätä omiasi muokkaamalla tiedostoa `~/.XCompose` ja suorittamalla sitten terminaalissa komennon `omarchy restart xcompose`, jotta muutokset otetaan käyttöön.
