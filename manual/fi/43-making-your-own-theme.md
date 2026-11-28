# Oman teeman tekeminen

Voit lisätä omia teemojasi kansioon `~/.config/omarchy/themes`. Kopioi vain yksi olemassa olevista pohjaksi (katso kansiosta `/usr/share/omarchy/themes`) ja muokkaa sitten mielesi mukaan. Niin kauan kuin teemasi on kyseisessä kansiossa, se näkyy teeman valintavalikossa.

Pääasiallinen muokattava tiedosto on `colors.toml`. Se määrittää värijoukon, josta sitten luodaan määritykset päätettä (Foot/Alacritty/Ghostty/Kitty), btopia, Chromiumia, Hyprlandia, Neovimia, Helixiä, VSCodea, Obsidiania, Qt-sovelluksia, näppäimistön taustavaloa, syöttömenetelmää, näytönjaon valitsinta, sovelluskuvakkeita, useita tekoälytyökaluja (Claude, Pi, Hermes, T3 Code, Herdr) ja koko Omarchy-kuorta (yläpalkki, valikko, ilmoitukset, OSD ja lukitusnäyttö) varten.

Voit myös käyttää mukana tulevaa Aether-sovellusta uuden teeman luomiseen ihanalla graafisella käyttöliittymällä, jossa voit leikitellä väreillä ja hakea taustakuvia. Käynnistä se vain sovellusruudukosta näppäimillä `Super + Alt + Space`.

### Mitä asennettu teema voi sisältää

Teema, jonka kirjoitat itse kansioon `~/.config/omarchy/themes`, voi sisältää mitä tahansa haluat — kone ja tiedosto ovat sinun, ja Omarchy käyttää kaiken.

Teema, jonka asennat jonkun toisen reposta komennolla `omarchy theme install`, säilyttää kaiken, mikä on väriä, ja menettää sen pienen joukon tiedostoja, jotka suorittaisivat koodia koneellasi: kaikki `.lua`-tiedostot, päätteen määritykset (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) ja `vscode.json`:n. Teeman `hyprland.lua` on Luaa, jonka komposiittorisi suorittaa kirjautumisen yhteydessä, päätteen määritys nimeää ohjelman, jonka päättees käynnistää, ja `vscode.json` nimeää asennettavan VSCode-laajennuksen. Jonkun toisen teeman asentamisen pitäisi muuttaa sitä, miltä työpöytäsi näyttää, ei koskaan sitä, mitä se suorittaa.

Kaikki muu toimii silti täsmälleen niin kuin teeman tekijä sen kirjoitti — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, taustakuvat ja esikatselut säilyvät kaikki. Vain pois pudotetut luodaan uudelleen `colors.toml`:sta koneellasi.

Omarchy erottaa nämä kaksi toisistaan sen perusteella, onko teeman sisällä oma git-reponsa, minkä `omarchy theme install` jättää jälkeensä kloonatessaan. Niinpä itse kirjoittamasi teema pysyy sinun, ja internetistä hakemasi pysyy väreinä.

### Vaalea tila

Jos teet vaalean tilan teemaa, aseta `mode = "light"` `colors.toml`:n alkuun. Silloin se yhdistetään automaattisesti vaaleaan tilaan kaikissa sovelluksissa. (Vanha tapa pudottaa tyhjä tiedosto nimeltä `light.mode` teemasi juureen toimii myös edelleen.)

### Käynnistys- ja kirjautumisnäytöt

Näyttö, joka kysyy aseman salasanaa käynnistyksen yhteydessä, ja kirjautumisnäyttö piirtävät Omarchy-logon teemasi `accent`-värillä sen `background`-värille, salasanakenttä sen `foreground`-värillä ja `red`-värillä väärää salasanaa varten. Niitä varten ei tarvitse toimittaa mitään ylimääräistä: Omarchy ei enää käytä teeman `unlock.png`- tai `preview-unlock.png`-tiedostoa. Apple Silicon -Maceilla aseman salasananäyttö säilyttää Omarchyn oletusulkoasun teemasta riippumatta.

### Sellaisten sovellusten teemoittaminen, joita Omarchy ei kata

Jos käytät sovellusta, joka ei ole tuolla listalla, voit itse opettaa Omarchyn teemoittamaan sen mallipohjalla. Pudota kansioon `~/.config/omarchy/themed/` tiedosto, joka on nimetty sen luoman määrityksen mukaan ja jonka pääte on `.tpl`, ja kirjoita määritys käyttämällä paikkamerkkejä `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` – `{{ color15 }}` ja paletin loppuosia. Joka kerta, kun vaihdat teemaa, tiedosto luodaan uudelleen kyseisen teeman väreillä.

Kansiossa on kopioitavaksi täysin kommentoitu `alacritty.toml.tpl.sample` — se listaa jokaisen käytettävissä olevan muuttujan sekä `_strip`- ja `_rgb`-muokkaajat sovelluksille, jotka haluavat värinsä ilman `#`-merkkiä tai desimaali-RGB-arvoina. Mallipohjasi ovat etusijalla Omarchyn omiin nähden, joten voit käyttää tätä myös ohittamaan sen, miten sisäänrakennettu sovellus teemoitetaan.

### Teemasi jakaminen

Jos haluat jakaa teemaasi niin, että muut voivat käyttää sitä, sinun täytyy laittaa se julkiselle git-palvelimelle, kuten GitHubiin. Sitten ihmiset voivat asentaa sen käyttämällä Omarchy-valikon kohdasta _Asenna > Tyyli > Teema_ kyseistä URL-osoitetta. On suositeltavaa noudattaa nimeämiskäytäntöä `omarchy-[themename]-theme`, sillä teema näkyy tällöin teeman valintavalikossa asennuksen jälkeen oikein pelkkänä `[themename]`.

Jäljelle jäävästä `[themename]` tulee teeman hakemiston nimi, joten sen on oltava sellainen, jota Omarchy voi käsitellä turvallisesti kaikkialla: sen on alettava kirjaimella, numerolla tai alaviivalla, ja loppuosa voi sisältää kirjaimia, numeroita, `.`, `_`, `+` ja `-`. Isot kirjaimet muutetaan pieniksi puolestasi, mutta kaikki muu — välilyönti, lainausmerkki, ei-englanninkielinen merkki — hylätään asennuksen yhteydessä sen sijaan, että siitä tehtäisiin hakemiston nimi. Niinpä `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` ja `omarchy-c++-theme` asentuvat kaikki ongelmitta.

Muista, että kun teema on asennettu reposta, kaikki sen mukana tulevat `.lua`, päätteen määritys tai `vscode.json` pudotetaan pois, joten älä rakenna teemaa niiden varaan.

Saat teemasi lisättyä [ylimääräisten teemojen sivulle](https://omarchy.org/themes/) lähettämällä pull requestin [omarchy-site-repositorioon](https://github.com/omacom-io/omarchy-site).
