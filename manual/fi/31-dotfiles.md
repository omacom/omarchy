# Dotfiles

Omarchy määrätään ensisijaisesti niin sanottujen dotfilejen kautta, jotka sijaitsevat hakemistossa `~/.config`. Niitä pidetään sinun tiedostoinasi sinun muutoksiasi varten. Tiedostot, jotka sijaitsevat hakemistossa `/usr/share/omarchy`, kuuluvat itse Omarchylle, eikä sinun pitäisi sorkkia niitä. Jos sinun pitää muuttaa jotain hakemistossa `/usr/share/omarchy`, sinun pitäisi sen sijaan ylikirjoittaa arvo hakemistossa `~/.config`.

Tärkeimpiä määrityksiä voi muokata suoraan Omarchy-valikosta (`Super + Space`), kuten _Asetukset > Näytöt_, _Asetukset > Pikanäppäimet_, _Asetukset > Syöttö_ ja _Asetukset > Määritykset > [file]_. Kun teet sen näin, kaikki prosessit, jotka tarvitsevat uudelleenkäynnistystä määritysmuutosten jälkeen, käynnistetään automaattisesti sen jälkeen, kun suljet editorin (oletuksena Neovim — `:wq`, muistathan! — mutta voit muuttaa sen kohdassa _Asetukset > Oletukset > Editori_).

Tässä on luettelo hakemiston `~/.config` tärkeimmistä tiedostoista ja siitä, mitä ne ohjaavat:

| Tiedosto                  | Tarkoitus              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hyprlandin päämääritys. Lataa Omarchyn oletukset sekä alla olevat ohitustiedostosi. [Lue lisää Hyprland-määrityksistä](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Omat pikanäppäimesi ja oletuksien ohituksesi. |
| `~/.config/hypr/monitors.lua` | Ohjaa näyttöjäsi, resoluutiotasi ja sijaintiasi. |
| `~/.config/hypr/input.lua` | Ohjaa näppäinasetteluasi, hiirtäsi ja kosketuslevysi asetuksia. |
| `~/.config/hypr/looknfeel.lua` | Ohjaa välejä, reunoja, animaatioita ja muuta ulkoasua. |
| `~/.config/hypr/autostart.lua` | Ohjaa istunnon mukana käynnistettäviä lisäprosesseja. |
| `~/.config/omarchy/shell.json` | Ohjaa Omarchy-shelliä: palkin sijaintia, asettelua ja widgettejä sekä näytönsäästäjän, lukon ja joutokäynnin ajoituksia. |
| `~/.config/foot/foot.ini` | Ohjaa päätettäsi (foot on oletus). |
| `~/.XCompose` | Määrittää pikakäyttö-emojisi ja nimi/sähköposti-automaattitäydennyksesi. Muista ajaa `omarchy-restart-xcompose` muutosten tekemisen jälkeen. |

Jos päädyt tekemään paljon muutoksia oman asetuksesi säätämiseksi, on hyvä idea varmuuskopioida kaikki nämä dotfilet. [Stow on erinomainen tapa tehdä se](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Omien sovellustesi käynnistäminen istunnon mukana

Jos haluat jonkin olevan käynnissä joka kerta, kun kirjaudut sisään — synkronointidaemonin, chat-sovelluksen, oman skriptisi — laita se tiedostoon `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Se käynnistää komennon osana istuntoa, joten se siivotaan kunnolla, kun kirjaudut jälleen ulos.

### Skriptien ajaminen järjestelmätapahtumissa

Omarchy laukaisee koukkuja kourallisessa hetkissä, ja voit ripustaa omat skriptisi niihin. Ne sijaitsevat hakemistossa `~/.config/omarchy/hooks/<event>.d/`, yksi hakemisto tapahtumaa kohden, ja jokainen siellä oleva suoritettava tiedosto ajetaan tapahtuman sattuessa:

| Tapahtuma | Milloin se ajetaan |
| ----- | ------------ |
| `post-boot` | Heti työpöydän käynnistymisen jälkeen |
| `post-update` | Lähellä komennon `omarchy update` loppua, pakettien, migraatioiden ja palveluiden uudelleenkäynnistysten jälkeen, ennen mise-työkalujen päivittämistä |
| `pre-refresh-pacman` | Sen jälkeen, kun `omarchy refresh pacman` synkronoi pakettimäärityksen uudelleen, ennen kuin se päivittää paketit; kanavan vaihto ajaa sen saman virkistysvaiheen aikana |
| `theme-set` | Teemanvaihdon jälkeen (teeman nimi muuttujassa `$1`) |
| `font-set` | Fontinvaihdon jälkeen (fontin nimi muuttujassa `$1`) |
| `battery-low` | Kun akku käy vähiin (prosentti muuttujassa `$1`) |

Koukku `pre-refresh-pacman` on paikka, johon mukautetut repositoriot tai `IgnorePkg`-rivit kuuluvat, koska se ajetaan ennen pakettitransaktiota. Molemmat päivitykseen liittyvät koukut ajetaan käyttäjänäsi sen jälkeen, kun Omarchy tyhjentää välimuistiin tallennetun sudo-valtuutuksensa, joten `sudo`a käyttävä koukku tarvitsee oman valtuutuksensa ja saattaa kysyä salasanaasi.

Jokaisessa noista hakemistoista on jo tiedosto `.sample`, joka näyttää koukun muodon — pudota `.sample` nimestä ottaaksesi sen käyttöön. Asentaaksesi muualle kirjoittamasi skriptin käytä komentoa `omarchy hook install post-boot ~/my-hook`, joka kopioi sen sisään ja tekee siitä suoritettavan.

### Omien valikkomerkintöjesi lisääminen

Omarchy-valikkoa (`Super + Space`) voi laajentaa omilla riveillä muokkaamalla tiedostoa `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Merkinnät avataan pisteellisellä id:llä, ja id on se, mikä sijoittaa ne puuhun, joten `personal` ilmestyy juurivalikkoon ja `personal.notes` ilmestyy sen sisään:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Käytä olemassa olevaa id:tä uudelleen, niin ohitat tuon rivin sen sijaan, että lisäisit uuden. Tiedosto toimitetaan kaikkien saatavilla olevien kenttien ollessa dokumentoituina kommentteina.

### Omien shell-vientiesi, funktioidesi ja aliastesi lisääminen

Omarchyssa on mukana joukko ergonomisia aliaksia ja hyödyllisiä funktioita, mutta on hyvin tavallista haluta lisätä omia. Lisää sekä aliakset, funktiot että viennit tiedostoon `~/.bashrc`. Tätä tiedostoa ei ylikirjoiteta päivityksissä. Jos haluat muuttaa jotain Omarchyn oletusta, voit myös turvallisesti lisätä sen tänne.

### Sisäisten Omarchy-tiedostojen muuttaminen

Kuuntele, tämä on sinun tietokoneesi. Voit tehdä sillä mitä haluat, mutta neuvoisin olemaan tekemättä muutoksia suoraan hakemiston `/usr/share/omarchy` tiedostoihin. Ne kuuluvat Omarchy-pacman-pakettiin, joten muutoksesi vain ylikirjoitetaan seuraavassa päivityksessä. Sinun on parempi vain ylikirjoittaa kaikki oletusarvot, joista et pidä, sen sijaan kansiossa `~/.config/*`.

Voit muuttaa melkein kaiken niin, kuten oletus-pikanäppäimet. Muokkaa vain tiedostoa `~/.config/hypr/bindings.lua` korvataksesi vaikkapa ohjelman [Obsidian](https://obsidian.md/) ohjelmalla [Joplin](https://joplinapp.org/) (asenna komennolla `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` poistaa olemassa olevan sidonnan ennen korvaajansa lisäämistä. Se ottaa samat argumentit kuin `o.bind`, mukaan lukien käynnistysavustajat ja sidontavaihtoehdot. Käytä `o.bind` lisätäksesi sidonnan tai `hl.unbind` poistaaksesi yhden korvaamatta sitä.

Jos vaadit hakkeroimaan sisäisiä Omarchy-tiedostoja, vaihda dev-kanavalle kohdassa _Päivitä > Kanava > Dev_. Se linkittää Omarchyn lähdekoodin git-noudettuun kopioon hakemistossa `~/omarchy`, jota saat muuttaa sydämesi kyllyydestä. Täällä ei ole kukaan kertomassa sinulle, mitä sinun pitäisi tehdä!

### Muutosten palauttaminen

Jos päädyt tekemään määrityksistä sekasotkun, voit aina palauttaa ne oletuksiin Omarchy-valikon kohdassa _Päivitä > Määritykset_. Tai ajamalla `omarchy reinstall configs` palauttaaksesi kaiken.
