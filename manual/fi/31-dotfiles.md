# Dotfiles

Omarchy määritetään ensisijaisesti niin sanotuilla dotfile-tiedostoilla, jotka sijaitsevat kansiossa `~/.config`. Niitä pidetään sinun tiedostoinasi sinun muutoksiasi varten. Tiedostot, jotka sijaitsevat kansiossa `/usr/share/omarchy`, kuuluvat Omarchylle itselleen, eikä sinun pitäisi sorkkia niitä. Jos sinun täytyy muuttaa jotain kansiossa `/usr/share/omarchy`, sinun pitäisi sen sijaan ohittaa arvo kansiossa `~/.config`.

Tärkeimpiä asetuksia voi muokata suoraan Omarchy-valikosta (`Super + Space`), kuten _Setup > Keyboard > Keybindings_, _Setup > Input_ ja _Setup > Config > [file]_. Kun teet sen näin, kaikki prosessit, jotka täytyy käynnistää uudelleen asetusten muokkauksen jälkeen, käynnistetään automaattisesti uudelleen, kun suljet editorin (oletuksena Neovim — `:wq`, muistathan! — mutta voit vaihtaa sen kohdasta _Setup > Defaults > Editor_).

Tässä on luettelo kansiossa `~/.config` olevista tärkeimmistä tiedostoista ja siitä, mitä ne ohjaavat:

| Tiedosto                  | Tarkoitus              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hyprlandin pääasetustiedosto. Lataa Omarchyn oletukset ja alla olevat ohitustiedostosi. [Lue lisää Hyprlandin asetuksista](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Omat näppäinsidontasi ja oletusten ohitukset. |
| `~/.config/hypr/monitors.lua` | Näyttöasetukset, joita näyttöpaneeli ei kata, kuten kierto, ylimääräiset tilat tai näytön pitäminen pois päältä. |
| `~/.config/hypr/input.lua` | Määrittää näppäimistöasettelusi sekä hiiren ja kosketuslevyn asetukset. |
| `~/.config/hypr/looknfeel.lua` | Määrittää välit, reunat, animaatiot ja muun ulkoasun. |
| `~/.config/hypr/autostart.lua` | Määrittää istunnon mukana käynnistettävät ylimääräiset prosessit. |
| `~/.config/omarchy/shell.json` | Määrittää Omarchy-shellin: palkin sijainnin, asettelun ja widgetit sekä näytönsäästäjän, lukituksen ja joutokäynnin ajoitukset. |
| `~/.config/foot/foot.ini` | Määrittää päätteesi (foot on oletus). |
| `~/.XCompose` | Määrittää pikakäyttöiset emojisi ja nimi-/sähköpostiautomaattitäydennyksesi. Muista ajaa `omarchy-restart-xcompose` muutosten tekemisen jälkeen. |

Jos päädyt tekemään paljon muutoksia oman kokoonpanosi virittämiseksi, on hyvä idea varmuuskopioida kaikki nämä dotfile-tiedostot. [Stow on erinomainen tapa tehdä se](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Omien sovellusten käynnistäminen istunnon mukana

Jos haluat jonkin ajettavan joka kerta, kun kirjaudut sisään — synkronointidaemonin, keskustelusovelluksen, oman skriptisi — laita se tiedostoon `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Se käynnistää komennon osana istuntoa, joten se siivotaan kunnolla pois, kun kirjaudut taas ulos.

### Skriptien ajaminen järjestelmätapahtumissa

Omarchy laukaisee hookeja muutamissa hetkissä, ja voit ripustaa omat skriptisi niihin. Ne sijaitsevat kansiossa `~/.config/omarchy/hooks/<event>.d/`, yksi kansio tapahtumaa kohden, ja jokainen siellä oleva suoritettava tiedosto ajetaan, kun tapahtuma sattuu:

| Tapahtuma | Milloin se ajetaan |
| ----- | ------------ |
| `post-boot` | Heti työpöydän käynnistymisen jälkeen |
| `post-update` | Lähellä `omarchy update` -komennon loppua, pakettien, migraatioiden ja palvelujen uudelleenkäynnistysten jälkeen, ennen kuin mise-työkalut päivitetään |
| `pre-refresh-pacman` | Kun `omarchy refresh pacman` on synkronoinut pakettiasetukset uudelleen, ennen kuin se päivittää paketit; kanavan vaihto ajaa sen saman päivitysvaiheen aikana |
| `theme-set` | Teeman vaihdon jälkeen (teeman nimi kohdassa `$1`) |
| `font-set` | Fontin vaihdon jälkeen (fontin nimi kohdassa `$1`) |
| `battery-low` | Kun akku on vähissä (prosenttiosuus kohdassa `$1`) |

`pre-refresh-pacman`-hook on paikka, johon mukautetut pakettivarastot tai `IgnorePkg`-rivit kuuluvat, koska se ajetaan ennen pakettitransaktiota. Molemmat päivitykseen liittyvät hookit ajetaan sinun käyttäjänäsi sen jälkeen, kun Omarchy tyhjentää välimuistiin tallennetun sudo-valtuutuksensa, joten `sudo`-komentoa käyttävä hook tarvitsee oman valtuutuksensa ja saattaa kysyä salasanaasi.

Jokaisessa näistä kansioista on jo `.sample`-tiedosto, joka näyttää hookin muodon — poista nimestä `.sample`, niin se ryhtyy töihin. Asentaaksesi muualle kirjoittamasi skriptin käytä komentoa `omarchy hook install post-boot ~/my-hook`, joka kopioi sen paikalleen ja tekee siitä suoritettavan.

### Omien valikkokohtien lisääminen

Omarchy-valikkoa (`Super + Space`) voi laajentaa omilla riveillä muokkaamalla tiedostoa `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Valikkokohtien avaimena on pisteellinen id, ja juuri id sijoittaa ne puuhun, joten `personal` näkyy päävalikossa ja `personal.notes` näkyy sen sisällä:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Jos käytät uudelleen olemassa olevaa id:tä, ohitat kyseisen rivin sen sijaan, että lisäisit uuden. Tiedoston mukana tulevat kaikki käytettävissä olevat kentät kommentteina dokumentoituina.

### Omien export-määrittelyjen, funktioiden ja aliasten lisääminen shelliin

Omarchyn mukana tulee joukko ergonomisia aliaksia ja hyödyllisiä funktioita, mutta omien lisääminen on hyvin yleistä. Sinun kannattaa lisätä aliakset, funktiot ja export-määrittelyt tiedostoon `~/.bashrc`. Tätä tiedostoa ei korvata päivityksissä. Jos haluat muuttaa jotain Omarchyn oletuksista, voit myös turvallisesti lisätä muutokset tänne.

### Ympäristömuuttujien asettaminen työpöydälle

Työpöytäistunnon export-määrittelyt kuuluvat kansioon `~/.config/uwsm/env.d/`. Nämä tiedostot ajetaan ennen työpöytäsi käynnistymistä, joten shell-virhe voi lähettää sinut takaisin kirjautumisnäkymään. Pidä toimiva pääte auki, kun muokkaat niitä. Poistaaksesi ohituksen käytöstä siirrä se pois kansiosta `env.d`. Katso [kirjautumisen palautus](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), jos muutos estää kirjautumisen.

### Omarchyn sisäisten tiedostojen muuttaminen

Kuule, tämä on sinun tietokoneesi. Voit tehdä sillä mitä haluat, mutta neuvoisin olemaan tekemättä muutoksia suoraan kansiossa `/usr/share/omarchy` oleviin tiedostoihin. Ne kuuluvat Omarchyn pacman-pakettiin, joten muutoksesi yksinkertaisesti korvataan seuraavassa päivityksessä. Sinun kannattaa sen sijaan vain ohittaa kansiossa `~/.config/*` kaikki oletusarvot, joista et pidä.

Voit muuttaa sillä tavalla melkein kaiken, kuten oletusnäppäinsidonnat. Muokkaa vain tiedostoa `~/.config/hypr/bindings.lua` esimerkiksi korvataksesi [Obsidian](https://obsidian.md/) sovelluksella [Joplin](https://joplinapp.org/) (asenna komennolla `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` poistaa olemassa olevan sidonnan ennen korvaavan lisäämistä. Se ottaa samat argumentit kuin `o.bind`, mukaan lukien käynnistysapufunktiot ja sidonta-asetukset. Käytä `o.bind`-funktiota sidonnan lisäämiseen tai `hl.unbind`-funktiota sidonnan poistamiseen korvaamatta sitä.

Jos välttämättä haluat hakkeroida Omarchyn sisäisiä tiedostoja, vaihda dev-kanavalle kohdasta _Update > Channel > Dev_. Se linkittää Omarchyn lähdekoodin git-checkoutiin kansiossa `~/omarchy`, jota saat muuttaa sydämesi kyllyydestä. Ei täällä kukaan ole sinua käskemässä!

### Kaikkien muutosten nollaaminen

Jos päädyt sotkemaan asetukset, voit aina palauttaa ne oletuksiin Omarchy-valikon kohdasta _Update > Config_. Tai ajamalla komennon `omarchy reinstall configs` nollataksesi kaiken.
