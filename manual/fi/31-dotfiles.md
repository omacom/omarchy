# Dotfiles

Omarchy määritetään ensisijaisesti niin kutsutuilla dotfiles-tiedostoilla, jotka ovat kansiossa `~/.config`. Ne ovat sinun tiedostojasi sinun muutoksiasi varten. Tiedostot, jotka ovat kansiossa `/usr/share/omarchy`, kuuluvat Omarchylle itselleen, eikä sinun pitäisi peukaloida niitä. Jos sinun täytyy muuttaa jotain kansiossa `/usr/share/omarchy`, sinun pitäisi sen sijaan korvata arvo kansiossa `~/.config`.

Keskeisiä määrityksiä voi muokata suoraan Omarchy-valikosta (`Super + Space`), kuten _Setup > Keybindings_, _Setup > Input_ ja _Setup > Config > [file]_. Kun teet sen näin, kaikki prosessit, jotka täytyy käynnistää uudelleen määritysten muokkauksen jälkeen, käynnistetään automaattisesti uudelleen, kun suljet editorin (oletuksena Neovim — `:wq`, muista! — mutta voit vaihtaa sen kohdasta _Setup > Defaults > Editor_).

Tässä on luettelo kansion `~/.config` keskeisistä tiedostoista ja siitä, mitä ne ohjaavat:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hyprlandin päämääritystiedosto. Lataa Omarchyn oletukset sekä alla olevat omat ohitustiedostosi. [Lue lisää Hyprland-määrityksistä](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Omat näppäinsidontasi ja oletusten ohitukset. |
| `~/.config/hypr/monitors.lua` | Näyttöasetukset, joita näyttöpaneeli ei kata, kuten kierto, ylimääräiset tilat tai näytön pitäminen pois päältä. |
| `~/.config/hypr/input.lua` | Ohjaa näppäimistöasettelua, hiiren ja kosketuslevyn asetuksia. |
| `~/.config/hypr/looknfeel.lua` | Ohjaa välejä, reunuksia, animaatioita ja muuta ulkoasua. |
| `~/.config/hypr/autostart.lua` | Ohjaa istunnon mukana käynnistettäviä ylimääräisiä prosesseja. |
| `~/.config/omarchy/shell.json` | Ohjaa Omarchy shelliä: palkin sijaintia, asettelua ja widgetejä sekä näytönsäästäjän, lukituksen ja joutoajan ajoituksia. |
| `~/.config/foot/foot.ini` | Ohjaa päätettäsi (foot on oletus). |
| `~/.XCompose` | Määrittää pikakäyttöemojisi ja nimen/sähköpostin automaattisen täydennyksen. Muista suorittaa `omarchy-restart-xcompose` muutosten tekemisen jälkeen. |

Jos päädyt tekemään paljon muutoksia oman kokoonpanosi virittämiseksi, kaikki nämä dotfiles-tiedostot kannattaa varmuuskopioida. [Stow on loistava tapa tehdä se](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Omien sovellustesi käynnistäminen istunnon mukana

Jos haluat jonkin suoritettavan joka kerta, kun kirjaudut sisään — synkronointidaemonin, chat-sovelluksen, oman skriptisi — laita se tiedostoon `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Se käynnistää komennon osana istuntoa, joten se siivotaan kunnolla, kun kirjaudut taas ulos.

### Skriptien suorittaminen järjestelmätapahtumien yhteydessä

Omarchy laukaisee hookeja muutamissa hetkissä, ja voit ripustaa omia skriptejäsi niihin. Ne ovat kansiossa `~/.config/omarchy/hooks/<event>.d/`, yksi kansio per tapahtuma, ja jokainen siellä oleva suoritettava tiedosto suoritetaan, kun tapahtuma sattuu:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Heti työpöydän käynnistymisen jälkeen |
| `post-update` | Lähellä `omarchy update` -komennon loppua, pakettien, migraatioiden ja palvelujen uudelleenkäynnistysten jälkeen, ennen kuin mise-työkalut päivitetään |
| `pre-refresh-pacman` | Sen jälkeen, kun `omarchy refresh pacman` synkronoi pakettimääritykset uudelleen, ennen kuin se päivittää paketit; kanavan vaihto suorittaa sen saman refresh-vaiheen aikana |
| `theme-set` | Teeman vaihdon jälkeen (teeman nimi kohdassa `$1`) |
| `font-set` | Fontin vaihdon jälkeen (fontin nimi kohdassa `$1`) |
| `battery-low` | Kun akku on vähissä (prosenttiosuus kohdassa `$1`) |

`pre-refresh-pacman`-hook on paikka, johon mukautetut repositoriot tai `IgnorePkg`-rivit kuuluvat, koska se suoritetaan ennen pakettitransaktiota. Molemmat päivitykseen liittyvät hookit suoritetaan käyttäjänäsi sen jälkeen, kun Omarchy tyhjentää välimuistiin tallennetun sudo-valtuutuksensa, joten `sudo`-komentoa käyttävä hook tarvitsee oman valtuutuksensa ja saattaa pyytää salasanaasi.

Jokaisessa näistä kansioista on jo `.sample`-tiedosto, joka näyttää hookin muodon — poista nimestä `.sample` ottaaksesi sen käyttöön. Asentaaksesi muualle kirjoittamasi skriptin käytä komentoa `omarchy hook install post-boot ~/my-hook`, joka kopioi sen paikalleen ja tekee siitä suoritettavan.

### Omien valikkomerkintöjen lisääminen

Omarchy-valikkoa (`Super + Space`) voi laajentaa omilla riveilläsi muokkaamalla tiedostoa `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Merkinnät avataan pisteellisellä id:llä, ja id sijoittaa ne puuhun, joten `personal` näkyy juurivalikossa ja `personal.notes` näkyy sen sisällä:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Käytä olemassa olevaa id:tä uudelleen, niin ohitat kyseisen rivin sen sijaan, että lisäisit uuden. Tiedoston mukana tulevat kaikki käytettävissä olevat kentät kommentteina dokumentoituina.

### Omien shell-vientien, funktioiden ja aliasten lisääminen

Omarchyn mukana tulee joukko ergonomisia aliaksia ja hyödyllisiä funktioita, mutta omien lisääminen on hyvin yleistä. Sinun pitäisi lisätä sekä aliakset, funktiot että viennit tiedostoon `~/.bashrc`. Tätä tiedostoa ei korvata päivityksissä. Jos haluat muuttaa jotain Omarchyn oletuksista, voit myös turvallisesti lisätä ne tänne.

### Omarchyn sisäisten tiedostojen muuttaminen

Kuule, tämä on sinun tietokoneesi. Voit tehdä sillä mitä haluat, mutta neuvoisin olemaan tekemättä muutoksia suoraan kansion `/usr/share/omarchy` tiedostoihin. Ne kuuluvat Omarchyn pacman-pakettiin, joten muutoksesi korvataan yksinkertaisesti seuraavan päivityksen yhteydessä. Sinun kannattaa sen sijaan vain korvata kaikki oletusarvot, joista et pidä, kansiossa `~/.config/*`.

Voit muuttaa melkein kaiken sillä tavalla, kuten oletusnäppäinsidonnat. Muokkaa vain tiedostoa `~/.config/hypr/bindings.lua` esimerkiksi korvataksesi [Obsidianin](https://obsidian.md/) [Joplinilla](https://joplinapp.org/) (asenna komennolla `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` poistaa olemassa olevan sidonnan ennen korvaavan lisäämistä. Se ottaa samat argumentit kuin `o.bind`, mukaan lukien käynnistysapufunktiot ja sidonnan valinnat. Käytä `o.bind`-komentoa sidonnan lisäämiseen tai `hl.unbind`-komentoa sen poistamiseen korvaamatta sitä.

Jos välttämättä haluat hakkeroida Omarchyn sisäisiä tiedostoja, vaihda dev-kanavalle kohdasta _Update > Channel > Dev_. Se linkittää Omarchyn lähdekoodin git-työkopioon kansiossa `~/omarchy`, jota voit vapaasti muuttaa sydämesi kyllyydestä. Kukaan täällä ei ole kertomassa sinulle, mitä tehdä!

### Muutosten nollaaminen

Jos päädyt sotkemaan määritykset, voit aina palauttaa ne oletuksiin Omarchy-valikon kohdasta _Update > Config_. Tai suorittamalla komennon `omarchy reinstall configs` nollataksesi kaiken.
