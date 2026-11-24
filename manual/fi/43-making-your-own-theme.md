# Oman teeman tekeminen

Voit lisätä omia teemojasi kansioon `~/.config/omarchy/themes`. Kopioi vain jokin olemassa olevista pohjaksi (katso kansiosta `/usr/share/omarchy/themes`) ja muokkaa sitä sitten mielesi mukaan. Niin kauan kuin teemasi on tuossa kansiossa, se on mukana teeman valintavalikossa.

Tärkein muokattava tiedosto on `colors.toml`. Se määrittää värijoukon, jota käytetään sitten asetusten luomiseen seuraaville: terminaali (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt-sovellukset, näppäimistön taustavalo, syöttömenetelmä, näytönjaon valitsin, sovelluskuvakkeet, useat tekoälytyökalut (Claude, Pi, Hermes, T3 Code, Herdr) ja koko Omarchy-kuori (yläpalkki, valikko, ilmoitukset, OSD ja lukitusnäyttö).

Voit myös käyttää mukana tulevaa Aether-sovellusta uuden teeman luomiseen ihanalla GUI-käyttöliittymällä, jolla voit leikkiä väreillä ja etsiä taustakuvia. Käynnistä se vain sovellusruudukosta näppäinyhdistelmällä `Super + Alt + Space`.

### Mitä asennettu teema voi sisältää

Itse kansioon `~/.config/omarchy/themes` kirjoittamasi teema voi sisältää mitä ikinä haluat — kone on sinun ja tiedosto on sinun, ja Omarchy ottaa kaiken käyttöön.

Jonkun toisen reposta komennolla `omarchy theme install` asentamasi teema säilyttää kaiken, mikä liittyy väreihin, ja menettää ne harvat tiedostot, jotka suorittaisivat koodia koneellasi: kaikki `.lua`-tiedostot, terminaaliasetukset (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) ja `vscode.json`. Teeman `hyprland.lua` on Lua-koodia, jonka komposiittorisi suorittaa kirjautuessasi sisään, terminaaliasetus nimeää ohjelman, jonka terminaalisi käynnistää, ja `vscode.json` nimeää asennettavan VSCode-laajennuksen. Jonkun toisen teeman asentamisen pitäisi muuttaa sitä, miltä työpöytäsi näyttää, ei koskaan sitä, mitä se suorittaa.

Kaikki muu toimii edelleen täsmälleen niin kuin teeman tekijä on kirjoittanut — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, taustakuvat ja esikatselut säilyvät kaikki. Vain poistetut osat luodaan uudelleen koneellasi tiedoston `colors.toml` pohjalta.

Omarchy erottaa nämä kaksi toisistaan sen perusteella, onko teeman sisällä oma git-repo, jonka `omarchy theme install` jättää jälkeensä kloonatessaan. Itse kirjoittamasi teema pysyy siis sinun teemanasi, ja internetistä lataamasi pysyy pelkkinä väreinä.

### Vaalea tila

Jos teet vaalean tilan teemaa, aseta `mode = "light"` tiedostosi `colors.toml` alkuun. Silloin se yhdistetään automaattisesti vaaleaan tilaan kaikissa sovelluksissa. (Vanha tapa pudottaa tyhjä tiedosto nimeltä `light.mode` teemasi juureen toimii yhä myös.)

### Avauskuva

Teemat, joiden mukana toimitetaan `unlock.png`- ja `preview-unlock.png`-kuvat, näytetään kohdassa _Ulkoasu > Unlock_. Tiedostosi `unlock.png` kannattaa mieluiten olla läpinäkyvä png. Esikatselukuvan voit luoda komennolla `omarchy plymouth preview`.

### Sellaisten sovellusten teemoittaminen, joita Omarchy ei kata

Jos käytät sovellusta, joka ei ole tuolla listalla, voit opettaa Omarchyn teemoittamaan sen itse mallipohjan avulla. Pudota kansioon `~/.config/omarchy/themed/` tiedosto, joka on nimetty sen luoman asetustiedoston mukaan ja jonka päätteeksi lisätään `.tpl`, ja kirjoita asetukset käyttäen paikkamerkkeinä kohteita `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}`–`{{ color15 }}` sekä muuta palettia. Aina kun vaihdat teemaa, tiedosto luodaan uudelleen kyseisen teeman väreillä.

Kansiossa on kokonaan kommentoitu `alacritty.toml.tpl.sample`, jonka voit kopioida pohjaksi — se luettelee kaikki käytettävissä olevat muuttujat sekä muuntimet `_strip` ja `_rgb` sovelluksille, jotka haluavat värinsä ilman `#`-merkkiä tai desimaalisena RGB-muodossa. Omat mallipohjasi ovat etusijalla Omarchyn omiin nähden, joten voit käyttää tätä myös ohittamaan sen, miten sisäänrakennettu sovellus teemoitetaan.

### Teemasi jakaminen

Jos haluat jakaa teemaasi, jotta muut voivat käyttää sitä, sinun täytyy laittaa se julkiselle git-palvelimelle, kuten GitHubiin. Sitten ihmiset voivat asentaa sen Omarchy-valikon kohdasta _Asenna > Tyyli > Teema_ käyttämällä kyseistä URL-osoitetta. Suosittelemme noudattamaan nimeämiskäytäntöä `omarchy-[themename]-theme`, sillä teema näkyy asennuksen jälkeen teeman valintavalikossa oikein pelkkänä nimellä `[themename]`.

Jäljelle jäävästä `[themename]`-osasta tulee teeman hakemiston nimi, joten sen täytyy olla sellainen, jota Omarchy voi käsitellä turvallisesti: sen täytyy alkaa kirjaimella, numerolla tai alaviivalla, ja loppuosa voi sisältää kirjaimia, numeroita, merkkejä `.`, `_`, `+` ja `-`. Isot kirjaimet muutetaan pieniksi puolestasi, mutta kaikki muu — välilyönti, lainausmerkki, ei-englanninkielinen merkki — hylätään asennuksen yhteydessä sen sijaan, että siitä tehtäisiin hakemiston nimi. Niinpä `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` ja `omarchy-c++-theme` asentuvat kaikki ongelmitta.

Muista, että kun teema on asennettu reposta, kaikki sen mukana tulevat `.lua`-tiedostot, terminaaliasetukset tai `vscode.json` pudotetaan pois, joten älä rakenna teemaa niiden varaan.

Voit saada teemasi lisättyä [lisäteemojen sivulle](https://omarchy.org/themes/) lähettämällä pull requestin [omarchy-site-repoon](https://github.com/omacom-io/omarchy-site).
