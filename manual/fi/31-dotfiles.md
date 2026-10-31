# Dotfiles

Omarchy määritetään ensisijaisesti niin sanotuilla dotfiles-tiedostoilla, jotka sijaitsevat kansiossa `~/.config`. Ne ovat sinun tiedostojasi sinun muutoksiasi varten. Kansiossa `/usr/share/omarchy` olevat tiedostot kuuluvat itse Omarchylle, eikä sinun pitäisi sotkea niitä. Jos sinun täytyy muuttaa jotain kansiossa `/usr/share/omarchy`, sinun pitäisi sen sijaan korvata arvo kansiossa `~/.config`.

Tärkeimpiä asetuksia voi muokata suoraan Omarchy-valikosta (`Super + Space`), kuten _Asetukset > Näppäinsidonnat_, _Asetukset > Syöte_ ja _Asetukset > Asetukset > [tiedosto]_. Kun teet sen näin, kaikki prosessit, jotka täytyy käynnistää uudelleen asetusten muokkauksen jälkeen, käynnistetään automaattisesti sen jälkeen, kun suljet editorin (oletuksena Neovim — `:wq`, muista! — mutta voit vaihtaa sen kohdassa _Asetukset > Oletukset > Editori_).

Tässä on luettelo kansion `~/.config` tärkeimmistä tiedostoista ja siitä, mitä ne ohjaavat:

| Tiedosto | Tarkoitus |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hyprlandin pääasetustiedosto. Lataa Omarchyn oletukset sekä alla olevat omat ohitustiedostosi. [Lue lisää Hyprlandin asetuksista](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Omat näppäinsidontasi ja oletusten ohitukset. |
| `~/.config/hypr/monitors.lua` | Näyttöasetukset, joita näyttöpaneeli ei kata, kuten kierto, lisätilat tai näytön pitäminen pois päältä. |
| `~/.config/hypr/input.lua` | Ohjaa näppäimistöasettelua, hiiren ja kosketuslevyn asetuksia. |
| `~/.config/hypr/looknfeel.lua` | Ohjaa välejä, reunuksia, animaatioita ja muuta ulkoasua. |
| `~/.config/hypr/autostart.lua` | Ohjaa istunnon mukana käynnistettäviä lisäprosesseja. |
| `~/.config/omarchy/shell.json` | Ohjaa Omarchy shelliä: palkin sijaintia, asettelua ja widgettejä sekä näytönsäästäjän, lukituksen ja joutoajan ajoituksia. |
| `~/.config/foot/foot.ini` | Ohjaa päätettäsi (foot on oletus). |
| `~/.XCompose` | Määrittää pikakäyttöiset emojisi sekä nimen/sähköpostin automaattisen täydennyksen. Muista ajaa `omarchy-restart-xcompose` muutosten tekemisen jälkeen. |

Jos päädyt tekemään paljon muutoksia oman kokoonpanosi viilaamiseksi, kaikki nämä dotfiles-tiedostot kannattaa varmuuskopioida. [Stow on loistava tapa tehdä se](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Omien sovellustesi käynnistäminen istunnon mukana

Jos haluat jonkin toimivan joka kerta, kun kirjaudut sisään — synkronointipalvelun, chattisovelluksen, oman skriptisi — laita se tiedostoon `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Se käynnistää komennon osana istuntoa, joten se siivotaan kunnolla pois, kun kirjaudut taas ulos.

### Skriptien ajaminen järjestelmätapahtumien yhteydessä

Omarchy laukaisee hookkeja muutamissa hetkissä, ja voit ripustaa omat skriptisi niihin. Ne sijaitsevat kansiossa `~/.config/omarchy/hooks/<event>.d/`, yksi kansio per tapahtuma, ja jokainen siellä oleva suoritettava tiedosto ajetaan, kun tapahtuma sattuu:

| Tapahtuma | Milloin se ajetaan |
| ----- | ------------ |
| `post-boot` | Heti työpöydän käynnistymisen jälkeen |
| `post-update` | Lähellä komennon `omarchy update` loppua, pakettien, migraatioiden ja palveluiden uudelleenkäynnistysten jälkeen, ennen kuin mise-työkalut päivitetään |
| `pre-refresh-pacman` | Sen jälkeen, kun `omarchy refresh pacman` synkronoi pakettiasetukset uudelleen, ennen kuin se päivittää paketit; kanavan vaihto ajaa sen saman refresh-vaiheen aikana |
| `theme-set` | Teeman vaihdon jälkeen (teeman nimi muuttujassa `$1`) |
| `font-set` | Fontin vaihdon jälkeen (fontin nimi muuttujassa `$1`) |
| `battery-low` | Kun akku käy vähiin (prosenttiosuus muuttujassa `$1`) |

`pre-refresh-pacman`-hook on paikka, johon mukautetut repositoriot tai `IgnorePkg`-rivit kuuluvat, koska se ajetaan ennen pakettitapahtumaa. Molemmat päivityksiin liittyvät hookit ajetaan käyttäjänäsi sen jälkeen, kun Omarchy tyhjentää välimuistiin tallennetun sudo-valtuutuksensa, joten sudoa käyttävä hook tarvitsee oman valtuutuksensa ja saattaa kysyä salasanaasi.

Jokaisessa näistä kansioista on jo `.sample`-tiedosto, joka näyttää hookin muodon — poista nimestä `.sample`, niin se otetaan käyttöön. Asentaaksesi muualle kirjoittamasi skriptin käytä komentoa `omarchy hook install post-boot ~/my-hook`, joka kopioi sen paikalleen ja tekee siitä suoritettavan.

### Omien valikkorivien lisääminen

Omarchy-valikkoa (`Super + Space`) voi laajentaa omilla riveillä muokkaamalla tiedostoa `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Rivit avataan pisteellisellä id:llä, ja id määrittää niiden paikan puussa, joten `personal` näkyy päävalikossa ja `personal.notes` näkyy sen sisällä:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Käytä olemassa olevaa id:tä uudelleen, niin ohitat kyseisen rivin uuden lisäämisen sijaan. Tiedostossa on kaikki käytettävissä olevat kentät dokumentoitu kommentteina.

### Omien shell-exportien, funktioiden ja aliasten lisääminen

Omarchyn mukana tulee kasa ergonomisia aliaksia ja hyödyllisiä funktioita, mutta omien lisääminen on hyvin tavallista. Sinun pitäisi lisätä sekä aliakset, funktiot että exportit tiedostoon `~/.bashrc`. Tätä tiedostoa ei korvata päivityksissä. Jos haluat muuttaa jotain Omarchyn oletuksista, voit myös lisätä ne turvallisesti tänne.

### Ympäristömuuttujien asettaminen työpöydälle

Työpöytäistunnon exportit kuuluvat kansioon `~/.config/uwsm/env.d/`. Nämä tiedostot ajetaan ennen työpöytäsi käynnistymistä, joten shell-virhe voi lähettää sinut takaisin kirjautumisnäyttöön. Pidä toimiva pääte auki, kun muokkaat niitä. Poistaaksesi ohituksen käytöstä siirrä se pois kansiosta `env.d`. Katso [kirjautumisen palautus](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), jos muutos estää kirjautumisen.

### Omarchyn sisäisten tiedostojen muuttaminen

Kuule, tämä on sinun tietokoneesi. Voit tehdä sillä mitä haluat, mutta neuvoisin olemaan tekemättä muutoksia suoraan kansiossa `/usr/share/omarchy` oleviin tiedostoihin. Ne kuuluvat Omarchyn pacman-pakettiin, joten muutoksesi yksinkertaisesti korvataan seuraavassa päivityksessä. Sinun kannattaa sen sijaan vain korvata kansiossa `~/.config/*` kaikki oletusarvot, joista et pidä.

Voit muuttaa melkein kaiken sillä tavalla, kuten oletusnäppäinsidonnat. Muokkaa vain tiedostoa `~/.config/hypr/bindings.lua` ja korvaa esimerkiksi [Obsidian](https://obsidian.md/) sovelluksella [Joplin](https://joplinapp.org/) (asenna komennolla `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` poistaa olemassa olevan sidonnan ennen korvaavan lisäämistä. Se ottaa samat argumentit kuin `o.bind`, mukaan lukien käynnistysapufunktiot ja sidonnan asetukset. Käytä funktiota `o.bind` sidonnan lisäämiseen tai funktiota `hl.unbind` sidonnan poistamiseen ilman sitä korvaamista.

Jos välttämättä haluat hakkeroida Omarchyn sisäisiä tiedostoja, vaihda dev-kanavaan kohdassa _Päivitys > Kanava > Dev_. Se linkittää Omarchyn lähdekoodin git-kopioon kansiossa `~/omarchy`, jota voit vapaasti muuttaa sydämesi kyllyydestä. Täällä ei ole kukaan kertomassa sinulle, mitä tehdä!

### Kaikkien muutosten nollaaminen

Jos päädyt sotkemaan asetukset, voit aina palauttaa ne oletuksiin Omarchy-valikon kohdassa _Päivitys > Asetukset_. Tai ajamalla komennon `omarchy reinstall configs` nollataksesi kaiken.
