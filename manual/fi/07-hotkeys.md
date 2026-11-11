# Pikanäppäimet

Näet kaikki tärkeimmät näppäinsidonnat näppäinyhdistelmällä `Super + K` (Tmux-sidonnat näppäinyhdistelmällä `Super + Alt + K` ja Herdr-sidonnat näppäinyhdistelmällä `Super + Ctrl + K`).

## Miten pikanäppäimet on järjestetty

Jokainen pikanäppäin sijaitsee tasolla, jonka sen muokkausnäppäimet määrittävät, ja jokaisella tasolla on yksi tehtävä. Siksi pikanäppäimet eivät sekoitu keskenään, ja yleensä voit arvata, missä jokin sijaitsee.

| Taso | Mitä siellä sijaitsee | Esimerkkejä |
| --- | --- | --- |
| `Super + key` | Järjestelmä: ikkunat, työtilat, asettelut ja ydinvalikot | `Super + Space` Omarchy-valikko, `Super + W` sulje ikkuna, `Super + F` koko näyttö |
| `Super + Shift + key` | Sovellukset | `Super + Shift + B` selain, `Super + Shift + E` sähköposti, `Super + Shift + N` editori |
| `Super + Ctrl + key` | Paneelit ja järjestelmävalikot | `Super + Ctrl + A` ääni, `Super + Ctrl + N` verkko, `Super + Ctrl + C` kaappausvalikko |
| `Super + Ctrl + Alt + key` | Pikatoiminnot ja ilmoitukset | `Super + Ctrl + Alt + T` näytä aika, `Super + Ctrl + Alt + B` akku, `Super + Ctrl + Alt + C` kuvakaappaus |

`Alt`-näppäimen lisääminen pikanäppäimeen antaa saman asian muunnelman, ei koskaan jotain täysin muuta:

- `Super + Shift + B` avaa selaimen; `Super + Shift + Alt + B` avaa yksityisen ikkunan
- `Super + Shift + E` avaa sähköpostin; `Super + Shift + Alt + E` aloittaa uuden sähköpostin
- `Super + F` siirtyy koko näyttöön; `Super + Alt + F` siirtyy koko leveyteen
- `Super + Ctrl + C` avaa kaappausvalikon; `Super + Ctrl + Alt + C` ohittaa valikon ja ottaa kuvakaappauksen

Pikanäppäintä lisättäessä:

1. Valitse taso sen perusteella, mitä se tekee, ja valitse sitten näppäin.
2. Älä siirrä olemassa olevaa pikanäppäintä tehdäksesi tilaa. Etsi vapaa näppäin oikealta tasolta.
3. Käytä `Alt`-näppäintä vain sellaisen pikanäppäimen muunnelmaan, jossa sitä ei ole.

Muutama pikanäppäin rikkoo näitä sääntöjä, koska ne ovat käteviä. `Shift` nuolinäppäimen tai `Tab`-näppäimen kanssa siirtää tai kääntää suunnan sen sijaan, että avaisi sovelluksen, ja `Print`, medianäppäimet, `Alt + Tab` ja `Ctrl + Alt + Del` toimivat samalla tavalla kuin kaikkialla muuallakin. Ne ovat poikkeuksia, eivät kopioitavia malleja.

Jos oletus ei sovi sinulle (esimerkiksi haluat kuvakaappauksille näppäinyhdistelmän `Super + Shift + S` kuten Windowsissa), sido se uudelleen tiedostossa `~/.config/hypr/bindings.lua`.

## Navigointi

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy-valikko (sovellukset ja kaikki muu)    |
| `Super + Alt + Space` | Sovellusruudukko |
| `Super + Escape` | Järjestelmävalikko (lepotila, uudelleenkäynnistys jne.)  |
| `Super + Ctrl + L` | Lukitse tietokone |
| `Super + W` or `Super + Q` | Sulje ikkuna             |
| `Ctrl + Alt + Del` | Sulje kaikki ikkunat |
| `Super + T`               | Vaihda ikkuna laatoituksen/kellumisen välillä             |
| `Super + J` | Vaihda ikkunan asento (vaaka/pysty) |
| `Super + O`               | Vaihda ikkuna tahmeana kelluvaksi ponnahdusikkunaksi |
| `Super + L`               | Kierrä dwindle-, scrolling- ja floating-asettelujen välillä |
| `Super + Alt + L`         | Kierrä asetteluja päinvastaisessa järjestyksessä |
| `Super + P`               | Vaihda pseudoikkunatyyli (luonnollinen vs. venytetty) |
| `Super + F`                 | Siirry koko näyttöön              |
| `Super + Alt + F`                 | Siirry koko leveyteen              |
| `Super + Ctrl + F`                 | Siirry koko näyttöön ikkunan sisällä              |
| `Super + 1/2/3/4`         | Siirry tiettyyn työtilaan kohdistetulla näytöllä |
| `Super + Tab` | Siirry seuraavaan työtilaan kohdistetulla näytöllä |
| `Super + Shift + Tab` | Siirry edelliseen työtilaan kohdistetulla näytöllä |
| `Super + Ctrl + Tab` | Siirry aiempaan työtilaan kohdistetulla näytöllä |
| `Super + Shift + 1/2/3/4` | Siirrä ikkuna työtilaan kohdistetulla näytöllä |
| `Super + Shift + Alt + 1/2/3/4` | Siirrä ikkuna työtilaan kohdistetulla näytöllä seuraamatta mukana |
| `Super + S` | Vaihda koko scratchpadin näkyvyys |
| `Super + Alt + S` | Siirrä ikkuna koko scratchpadiin |
| `Super + Grave` | Vaihda Quake-konsolin näkyvyys |
| `Super + Shift + Grave` | Siirrä ikkuna Quake-konsoliin |
| `Super + Shift + Ctrl + Arrows` | Siirrä ikkuna siinä suunnassa olevalle näytölle |
| `Super + Shift + Alt + Arrows` | Siirrä työtila siinä suunnassa olevalle näytölle |
| `Super + Arrow`  | Siirrä kohdistus nuolen suunnassa olevaan ikkunaan, ylittäen näytön reunalla sillä puolella olevalle näytölle |
| `Super + Shift + Arrow`  | Vaihda ikkuna toiseen nuolen suunnassa, mukaan lukien sillä puolella olevalla näytöllä oleva |
| `Super + Minus` | Laajenna ikkunaa vasemmalle |
| `Super + Equal` | Pienennä ikkunaa vasemmalle |
| `Super + Shift + Minus` | Pienennä ikkunaa ylöspäin |
| `Super + Shift + Equal` | Laajenna ikkunaa alaspäin |
| `Super + Alt + Minus/Equal` | Sama koon muuttaminen pienemmin askelin |
| `Super + Ctrl + Minus/Equal` | Sama koon muuttaminen suuremmin askelin |
| `Super + Alt + Home` | Tallenna ikkunan leveys |
| `Super + Home` | Palauta tallennettu ikkunan leveys |
| `Super + Left Mouse` | Raahaa ikkunaa |
| `Super + Right Mouse` | Muuta ikkunan kokoa |
| `Super + Scroll Wheel` | Selaa työtiloja kohdistetulla näytöllä |
| `Super + G`               | Vaihda ikkunoiden ryhmittely      |
| `Super + Alt + G`               | Siirrä ikkuna pois ryhmittelystä      |
| `Super + Alt + Tab`               | Kierrä ryhmittelyn ikkunoiden välillä      |
| `Super + Alt + Shift + Tab`               | Kierrä taaksepäin ryhmittelyn ikkunoiden välillä      |
| `Super + Alt + Scroll Wheel` | Kierrä ryhmittelyn ikkunoiden välillä |
| `Super + Alt + 1/2/3/4/5`               | Siirry tiettyyn ikkunaan ryhmittelyssä      |
| `Super + Alt + Arrow`  | Siirrä ikkuna ryhmittelyyn nuolen suunnassa, mukaan lukien sillä puolella olevalla näytöllä oleva |
| `Super + Ctrl + Left/Right`  | Siirry laatoitusryhmän sisällä olevien ikkunoiden välillä |
| `Super + Ctrl + Z` | Lähennä näkymää näytöllä (toista lisätäksesi zoomausta) |
| `Super + Ctrl + Alt + Z` | Loitonna näkymä kokonaan näytöltä |
| `Super + /` | Askella eteenpäin näytön skaalausvaihtoehtojen läpi |
| `Super + Alt + /` | Askella taaksepäin näytön skaalausvaihtoehtojen läpi |
| `Alt + Tab` | Kierrä eteenpäin aktiivisen työtilan ikkunoiden läpi |
| `Alt + Shift + Tab` | Kierrä taaksepäin aktiivisen työtilan ikkunoiden läpi |
| `Ctrl + Alt + Tab`| Kierrä kohdistusta eteenpäin näyttöjen läpi |
| `Ctrl + Alt + Shift + Tab`| Kierrä kohdistusta taaksepäin näyttöjen läpi |

Koonmuutoksen pikanäppäimet käyttävät fyysisiä näppäimiä `code:20` ja `code:21` (XKB `<AE11>` ja `<AE12>`), riippumatta näppäimistölle painetuista merkeistä. US-näppäimistöillä nämä näppäimet ovat `-` ja `=`; japanilaisilla (JIS) näppäimistöillä ne ovat `-` ja `^`; espanjalaisilla näppäimistöillä ne ovat `'` ja `¡`. JIS-näppäimistöllä `Super + ^` on `Super + Equal`, kun taas `Super + Shift + -` (joka kirjoittaa `=`) on `Super + Shift + Minus`.

## Järjestelmän hallinta

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Äänipaneeli    |
| `Super + Ctrl + B`           | Bluetooth-paneeli    |
| `Super + Ctrl + N`           | Wi-Fi-/verkkopaneeli    |
| `Super + Ctrl + D`           | Näyttöpaneeli    |
| `Super + Ctrl + P`           | Virtapaneeli    |
| `Super + Ctrl + X`           | Agenttipaneeli    |
| `Super + Ctrl + Alt + D`           | Kalenteripaneeli    |
| `Super + Ctrl + Alt + E`           | Maailmankellopaneeli    |
| `Super + Ctrl + 1-9`           | Vaihda palkkipaneeli sijainnin mukaan    |
| `Super + Ctrl + S` | Jakamisvalikko (LocalSendin kautta) |
| `Super + Ctrl + C` | Kaappauksen hallinta (kuvakaappaus/-tallennus/valitsin) |
| `Super + Ctrl + O` | Vaihtovalikko |
| `Super + Ctrl + H` | Laitteistovalikko |
| `Super + Ctrl + E` | Emoji-valitsin |
| `Super + Ctrl + .` | Transkoodaa media |
| `Super + Shift + Ctrl + A` | Valitse AI-agentti |

## Säädöt

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Näytön enimmäiskirkkaus |
| `Shift + Brightness Down` | Näytön vähimmäiskirkkaus |
| `Alt + Brightness Up/Down` | Tarkat 1% kirkkauden muutokset |
| `Alt + Volume Up/Down` | Tarkat 1% äänenvoimakkuuden muutokset |
| `Keyboard Brightness Up/Down` | Näppäimistön taustavalo kirkkaammaksi/himmeämmäksi |
| `Keyboard Backlight` | Kierrä näppäimistön taustavalon tasojen läpi |
| `Alt + Play` | Seuraava kappale |
| `Alt + Shift + Play` | Edellinen kappale |

## Sovellusten käynnistäminen

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Super + Return`           | Pääte    |
| `Super + Alt + Return` | Tmux-pääte |
| `Super + Ctrl + Return` | Herdr (agenttien hallinta) |
| `Super + Shift + Return`           | Selain    |
| `Super + Shift + Alt + B`           | Selain (yksityinen/incognito)    |
| `Super + Shift + F`           | Tiedostonhallinta    |
| `Super + Shift + Alt + F`           | Tiedostonhallinta päätteen cwd:ssä    |
| `Super + Shift + M`           | Musiikki (Spotify)    |
| `Super + Shift + Alt + M`           | Musiikki (cliamp)    |
| `Super + Shift + /`           | Salasananhallinta (1password)    |
| `Super + Shift + Q`           | Laskin (Omacalc)    |
| `Super + Shift + T`           | Aktiivisuus (btop)    |
| `Super + Shift + N`           | Editori (Neovim)  |
| `Super + Shift + C`           | Kalenteri ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Sähköposti ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Uusi sähköposti ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Viestisovellus (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Viestisovellus (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Viestisovellus (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Kirjoittaminen (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Muuta/lisää sidontoja tiedostossa `~/.config/hypr/bindings.lua`.

## Yleinen leikepöytä

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Super + A`           | Valitse kaikki sovelluksissa, jotka tukevat näppäinyhdistelmää `Ctrl + A`    |
| `Super + C`           | Kopioi    |
| `Super + X`           | Leikkaa (ei päätteessä)    |
| `Super + V`           | Liitä    |
| `Super + Ctrl + V`           | Leikepöydän hallinta    |

Linuxissa tarvitset yleensä näppäinyhdistelmää `Ctrl + Shift + C/V` kopioimiseen ja liittämiseen päätteessä ja näppäinyhdistelmää `Ctrl + C/V` tehdäksesi sen kaikkialla muualla. Nämä Omarchyn yhtenäiset leikepöydän pikanäppäimet toimivat kaikkialla.

## Kaappaus

| Pikanäppäin              | Toiminto                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Kuvakaappaus                      |
| `Super + Ctrl + Alt + C`            | Kuvakaappaus (sama otos näppäimistöille, joissa ei ole Print Screen -näppäintä) |
| `Super + Ctrl + C` | Kaappausvalikko |
| `Alt + Print Screen`            | Näyttötallennus                     |
| `Super + Print Screen` | Värivalitsin |
| `Super + Ctrl + Print Screen` | Tekstin poiminta leikepöydälle |
| `Super + Alt + [` | Pienennä verkkokameran päällyskuvaa tallennuksen aikana |
| `Super + Alt + ]` | Suurenna verkkokameran päällyskuvaa tallennuksen aikana |
| `Alt + Shift + L` | Kopioi nykyinen URL web-sovelluksesta tai Chromiumista |
| `Alt + Shift + D` | Lataa nykyisellä sivulla oleva video kansioon `~/Videos` |
| `Alt + Space` | Aloita/lopeta sanelu (vaatii _Setup > Defaults > Dictation_) |
| `Right Alt` | Pidä painettuna sanellaksesi (vaatii _Setup > Defaults > Dictation_) |

Näyttötallennuksissa pikanäppäin kysyy ensin, mitä ääntä haluat, ja aloittaa sitten tallennuksen. Paina sitä uudelleen lopettaaksesi. Katso lisätietoja kohdasta [kuvakaappaukset ja tallennus](12-screenshots-recording.md).

Kaikki kaappausvaihtoehdot ovat käytettävissä myös Omarchy-valikon kohdassa _Trigger > Capture_ (`Super + Space`).

## Ilmoitukset

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Super + ,` | Toimi uusimman ilmoituksen suhteen: avaa se tai paina sen ainoaa painiketta, valitse sen vaihtoehdoista tai hylkää se, kun sillä ei ole yhtään  |
| `Super + Shift + ,` | Hylkää kaikki ilmoitukset |
| `Super + Ctrl + ,` | Hallitse ilmoituksia näppäimistöllä  |
| `Super + Alt + ,` | Hylkää uusin ilmoitus  |
| `Super + Shift + Alt + ,` | Avaa ilmoitushistoria  |
| `Super + Ctrl + Alt + ,` | Vaihda ilmoitusten hiljentäminen  |

## Tyyli

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Valitse uusi teema (myös `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Valitse teeman tausta (myös `Super + Ctrl + Space`) |
| `Super + Backspace` | Vaihda ikkunan läpinäkyvyys |
| `Super + Ctrl + Backspace` | Vaihda yksittäisen ikkunan neliömäinen kuvasuhde |

Lisätaustakuvat sijaitsevat kansiossa `~/.config/omarchy/backgrounds/<theme name>`. Saatavilla myös Omarchy-valikon kohdan _Install > Style > Background_ kautta.

Kaikki tyylivaihtoehdot ovat käytettävissä myös Omarchy-valikon kohdassa _Style_ (`Super + Space`).

## Kytkimet

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Vaihda lukitus käyttämättömyyden aikana |
| `Super + Ctrl + Delete` | Vaihda kannettavan näyttö päälle/pois |
| `Super + Ctrl + Alt + Delete` | Vaihda kannettavan näytön peilaus |
| `Super + Shift + Space` | Vaihda yläpalkin näkyvyys  |
| `Shift + Mute` | Vaihda seuraavaan äänilähtöön |
| `Shift + Play` | Vaihda seuraavaan medialähteeseen |
| `Super + Shift + Backspace` | Vaihda ikkunoiden välit |
| `Super + Ctrl + Alt + F` | Vaihda koko näytön työpöytä (yläpalkki + ikkunoiden välit) |

## Muistutukset

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Aseta muistutus  |
| `Super + Ctrl + Alt + R` | Näytä kaikki muistutukset  |
| `Super + Ctrl + Shift + R` | Tyhjennä kaikki muistutukset  |

## Huomautukset

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Näytä aika ilmoituksena  |
| `Super + Ctrl + Alt + B` | Näytä akku ilmoituksena  |
| `Super + Ctrl + Alt + W` | Näytä/piilota sää ilmoituksena  |

## Tmux

Etuliitenäppäin on `Ctrl + Space` (`Ctrl + B` toimii myös). Voit muuttaa näitä sidontoja tiedostossa `~/.config/tmux/tmux.conf`.

### Ruudut

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Prefix + v` | Jaa ruutu viereen (pystysuuntaan) |
| `Prefix + h` | Jaa ruutu alle (vaakasuuntaan) |
| `Prefix + x` | Lopeta ruutu |
| `Prefix + z` | Vaihda ruudun zoomaus (koko näyttö) |
| `Alt + Enter` | Jaa ruutu alle (ei etuliitettä) |
| `Alt + Shift + Enter` | Jaa ruutu viereen (ei etuliitettä) |
| `Alt + Escape` | Lopeta ruutu (ei etuliitettä) |
| `Ctrl + Alt + Arrows` | Siirry ruutujen välillä |
| `Ctrl + Alt + Shift + Arrows` | Muuta ruutujen kokoa |

### Ikkunat

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Prefix + c` | Uusi ikkuna |
| `Prefix + k` | Lopeta ikkuna |
| `Prefix + r` | Nimeä ikkuna uudelleen |
| `Alt + 1-9` | Siirry tiettyyn ikkunaan |
| `Alt + Arrow Left/Right` | Siirry ikkunoiden välillä |
| `Alt + Shift + Arrow Left/Right` | Siirrä ikkunaa vasemmalle/oikealle |

### Istunnot

| Pikanäppäin                  | Toiminto              |
| ----------------------- | --------------------- |
| `Prefix + C` | Uusi istunto |
| `Prefix + K` | Lopeta istunto |
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

### Tmux-asettelufunktiot

Nämä funktiot on suoritettava Tmux-istunnon sisällä.

| Komento | Toiminto |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Luo kehitysasettelu editorilla, AI:lla ja päätteellä |
| `tdlm <ai> [<second_ai>]` | Luo kehitysasettelu alikansiota kohden |
| `tsl <count> <command>` | Luo usean ruudun swarm-asettelu |

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
| `Alt + Up`       | Siirry ylös yläkansioon        |

## Neovim (w/ lazyvim)

### Navigointi

| Pikanäppäin                   | Toiminto                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Näytä komentovaihtoehdot            |
| `Space Space`              | Avaa tiedosto sumealla haulla      |
| `Space E`                  | Vaihda sivupalkin näkyvyys                  |
| `Space G G`                | Näytä git-hallinta               |
| `Space S G`                | Hae tiedoston sisällöstä             |
| `Ctrl + W W`               | Hyppää sivupalkin ja editorin välillä |
| `Ctrl + Left/right arrow`  | Muuta sivupalkin kokoa          |
| `Shift + H`                      | Siirry vasempaan tiedostovälilehteen             |
| `Shift + L`                      | Siirry oikeaan tiedostovälilehteen            |
| `Space B D`                | Sulje tiedostovälilehti                  |

### Sivupalkissa ollessa

| Pikanäppäin                   | Toiminto                        |
| ------------------------ | ------------------------------- |
| `A`                        | Lisää uusi tiedosto yläkansioon      |
| `Shift + A`                | Lisää uusi alikansio yläkansioon    |
| `D`                        | Poista korostettu tiedosto/kansio     |
| `M`                        | Siirrä korostettu tiedosto/kansio       |
| `R`                        | Nimeä korostettu tiedosto/kansio uudelleen     |
| `?`                        | Näytä kaikkien komentojen ohje      |

[Katso kaikki LazyVimin määrittämät Neovim-pikanäppäimet](https://www.lazyvim.org/keymaps).

## Nopeat emojit

Voit käyttää näppäinyhdistelmää `Super + Ctrl + E` näyttääksesi täydellisen emoji-valitsimen, joka asettaa valinnan leikepöydälle, tai voit käyttää näitä pikakäyttövaihtoehtoja.

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
| `Shift + CapsLock M W` | 🤞 | toive       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | suukko       |
| `Shift + CapsLock M E` | 🙄 | silmien pyöritys    |
| `Shift + CapsLock M I` | 😉 | silmänisku       |
| `Shift + CapsLock M P` | 🙏 | rukoile |
| `Shift + CapsLock M D` | 🤤 | kuolaa      |
| `Shift + CapsLock M M` | 💰 | raha      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | malja      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | tervehdys |
| `Shift + CapsLock M A` |💪 | käsivarsi |
| `Shift + CapsLock M B` |🤯 | räjähtävä |

## Nopeat täydennykset

| Pikanäppäin       | Täydennys       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Nimesi (kuten asennuksen yhteydessä syötettiin)  |
| `Shift + CapsLock Space E` | Sähköpostisi (kuten asennuksen yhteydessä syötettiin)  |

Voit lisätä omiasi muokkaamalla tiedostoa `~/.XCompose` ja suorittamalla sitten päätteessä komennon `omarchy-restart-xcompose`, jotta muutokset tulevat käyttöön.
