# Dotfiles

Omarchy määritetään ensisijaisesti niin kutsutuilla dotfileilla, jotka sijaitsevat kansiossa `~/.config`. Niitä pidetään sinun tiedostoinasi sinun muutoksiasi varten. Tiedostot, jotka sijaitsevat kansiossa `/usr/share/omarchy`, kuuluvat itse Omarchylle, eikä sinun pitäisi sorkkia niitä. Jos sinun täytyy muuttaa jotakin kansiossa `/usr/share/omarchy`, sinun pitäisi sen sijaan korvata arvo kansiossa `~/.config`.

Tärkeimpiä määrityksiä voi muokata suoraan Omarchy-valikosta (`Super + Space`), kuten kohdista _Setup > Keyboard > Keybindings_, _Setup > Input_ ja _Setup > Config > [file]_. Kun teet sen tällä tavalla, kaikki prosessit, jotka täytyy käynnistää uudelleen määritysmuutosten jälkeen, käynnistyvät automaattisesti uudelleen sen jälkeen, kun suljet editorin (oletuksena Neovim — `:wq`, muistathan! — mutta voit vaihtaa sen kohdasta _Setup > Defaults > Editor_).

Tässä on luettelo kansion `~/.config` tärkeimmistä tiedostoista ja siitä, mitä ne hallitsevat:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hyprlandin päämääritystiedosto. Lataa Omarchyn oletukset sekä alla olevat korvaavat tiedostosi. [Lue lisää Hyprland-määrityksistä](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Omat näppäinsidontasi ja oletusten korvaukset. |
| `~/.config/hypr/monitors.lua` | Näyttöasetukset, joita näyttöpaneeli ei kata, kuten kierto, ylimääräiset tilat tai näytön pitäminen pois päältä. |
| `~/.config/hypr/input.lua` | Hallitsee näppäimistöasettelua, hiirtä ja kosketuslevyn asetuksia. |
| `~/.config/hypr/looknfeel.lua` | Hallitsee välejä, reunuksia, animaatioita ja muuta ulkoasua. |
| `~/.config/hypr/autostart.lua` | Hallitsee istunnon mukana käynnistettäviä lisäprosesseja. |
| `~/.config/omarchy/shell.json` | Hallitsee Omarchy shelliä: palkin sijaintia, asettelua ja widgettejä sekä näytönsäästäjän, lukituksen ja joutoajan ajoituksia. |
| `~/.config/foot/foot.ini` | Hallitsee päätettäsi (foot on oletus). |
| `~/.XCompose` | Määrittää pikakäyttöiset emojisi sekä nimen/sähköpostin automaattisen täydennyksen. Muista suorittaa `omarchy-restart-xcompose` muutosten tekemisen jälkeen. |

Jos päädyt tekemään paljon muutoksia oman kokoonpanosi virittämiseksi, kaikki nämä dotfilet kannattaa varmuuskopioida. [Stow on loistava tapa tehdä se](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Omien sovellustesi käynnistäminen istunnon mukana

Jos haluat jonkin toimivan joka kerta, kun kirjaudut sisään — synkronointidaemonin, keskustelusovelluksen, oman skriptisi — laita se tiedostoon `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Se käynnistää komennon osana istuntoa, joten se siivotaan kunnolla pois, kun kirjaudut taas ulos.

### Skriptien suorittaminen järjestelmätapahtumien yhteydessä

Omarchy laukaisee koukuja muutamassa kohdassa, ja voit ripustaa omia skriptejäsi niihin. Ne sijaitsevat kansiossa `~/.config/omarchy/hooks/<event>.d/`, yksi kansio tapahtumaa kohden, ja jokainen siellä oleva tiedosto, joka ei pääty `.sample`, suoritetaan bashilla, kun tapahtuma sattuu:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Heti työpöydän käynnistymisen jälkeen |
| `post-update` | Lähellä `omarchy update` -komennon loppua, pakettien, migraatioiden ja palveluiden uudelleenkäynnistysten jälkeen, ennen kuin mise-työkalut päivitetään |
| `pre-refresh-pacman` | Sen jälkeen, kun `omarchy refresh pacman` on synkronoinut pakettimääritykset uudelleen, ennen kuin se päivittää paketit; kanavan vaihto suorittaa sen saman päivitysvaiheen aikana |
| `theme-set` | Teeman vaihdon jälkeen (teeman nimi muuttujassa `$1`) |
| `font-set` | Fontin vaihdon jälkeen (fontin nimi muuttujassa `$1`) |
| `battery-low` | Kun akku käy vähiin (prosenttiosuus muuttujassa `$1`) |

`pre-refresh-pacman`-koukku on paikka, johon mukautetut repositoriot tai `IgnorePkg`-rivit kuuluvat, koska se suoritetaan ennen pakettitapahtumaa. Molemmat suoritetaan käyttäjänäsi. `post-update` suoritetaan, kun `omarchy update` -komennon sudo-valtuutus on vielä tuore, joten sudoa käyttävä koukku ei kysy salasanaasi uudelleen; `pre-refresh-pacman` suoritetaan heti sen jälkeen, kun `omarchy refresh pacman` on itse käyttänyt sudoa.

Jokaisessa näistä kansioista on jo `.sample`-tiedosto, joka näyttää koukun muodon — pudota `.sample` nimestä, niin se astuu töihin. Asentaaksesi muualle kirjoittamasi skriptin käytä komentoa `omarchy hook install post-boot ~/my-hook`, joka kopioi sen paikalleen ja tekee siitä suoritettavan.

### Omien valikkokohtiesi lisääminen

Omarchy-valikkoa (`Super + Space`) voi laajentaa omilla riveilläsi muokkaamalla tiedostoa `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Kohteet avataan pisteellisellä id:llä, ja id sijoittaa ne puuhun, joten `personal` näkyy juurivalikossa ja `personal.notes` näkyy sen sisällä:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Käytä olemassa olevaa id:tä uudelleen, niin korvaat kyseisen rivin uuden lisäämisen sijaan. Tiedoston mukana toimitetaan kaikki käytettävissä olevat kentät kommentteina dokumentoituina.

### Omien shell-vientien, funktioiden ja aliasten lisääminen

Omarchyn mukana tulee joukko ergonomisia aliaksia ja hyödyllisiä funktioita, mutta omien lisääminen on hyvin tavallista. Sekä aliakset, funktiot että viennit kannattaa lisätä tiedostoon `~/.bashrc`. Tätä tiedostoa ei korvata päivityksissä. Jos haluat muuttaa jotakin Omarchyn oletuksista, voit myös turvallisesti lisätä ne tänne.

### Ympäristömuuttujien asettaminen työpöydälle

Työpöytäistunnon viennit kuuluvat kansioon `~/.config/uwsm/env.d/`. Nämä tiedostot suoritetaan ennen työpöytäsi käynnistymistä, joten shell-virhe voi lähettää sinut takaisin kirjautumisnäyttöön. Pidä toimiva pääte auki, kun muokkaat niitä. Poistaaksesi korvauksen käytöstä siirrä se pois kansiosta `env.d`. Katso [kirjautumisen palautus](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), jos muutos estää kirjautumisen.

### Sisäisten Omarchy-tiedostojen muuttaminen

Kuule, tämä on sinun tietokoneesi. Voit tehdä sillä mitä haluat, mutta neuvoisin olemaan tekemättä muutoksia suoraan tiedostoihin kansiossa `/usr/share/omarchy`. Ne kuuluvat Omarchyn pacman-pakettiin, joten muutoksesi yksinkertaisesti korvataan seuraavassa päivityksessä. Sinun kannattaa mieluummin vain korvata kaikki oletusarvot, joista et pidä, kansiossa `~/.config/*`.

Voit muuttaa lähes kaiken sillä tavalla, kuten oletusnäppäinsidonnat. Muokkaa vain tiedostoa `~/.config/hypr/bindings.lua` ja korvaa esimerkiksi [Obsidian](https://obsidian.md/) sovelluksella [Joplin](https://joplinapp.org/) (asenna komennolla `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` poistaa olemassa olevan sidonnan ennen korvaavan lisäämistä. Se ottaa samat argumentit kuin `o.bind`, mukaan lukien käynnistysapufunktiot ja sidonta-asetukset. Käytä `o.bind` lisätäksesi sidonnan tai `hl.unbind` poistaaksesi sellaisen korvaamatta sitä.

Jos välttämättä haluat hakkeroida sisäisiä Omarchy-tiedostoja, vaihda dev-kanavaan kohdasta _Update > Channel > Dev_. Se linkittää Omarchyn lähdekoodin git-kopioon kansiossa `~/omarchy`, jota voit vapaasti muuttaa sydämesi kyllyydestä. Täällä ei ole kukaan kertomassa sinulle, mitä tehdä!

### Kaikkien muutosten nollaaminen

Jos päädyt tekemään määrityksistä sotkun, voit aina palauttaa ne oletuksiin Omarchy-valikon kohdasta _Update > Config_. Tai suorittamalla komennon `omarchy reinstall configs` nollataksesi kaiken.
