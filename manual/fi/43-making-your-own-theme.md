# Oman teeman tekeminen

Voit lisätä omia teemojasi kansioon `~/.config/omarchy/themes`. Kopioi vain jokin olemassa olevista teemoista pohjaksi (katso kansiosta `/usr/share/omarchy/themes`) ja muokkaa sitä sitten mielesi mukaan. Kunhan teemasi on tuossa kansiossa, se sisällytetään teemanvalintavalikkoon.

Tärkein muokattava tiedosto on `colors.toml`. Se määrittelee värisarjan, josta sitten luodaan määritykset päätteelle (Foot/Alacritty/Ghostty/Kitty), btopille, Chromiumille, Hyprlandille, Neovimille, Helixille, VS Codelle, Obsidianille ja koko Omarchy-kuorelle (yläpalkki, valikko, ilmoitukset, OSD ja lukitusnäyttö).

Voit myös käyttää mukana tulevaa Aether-sovellusta uuden teeman luomiseen ihanalla GUI-käyttöliittymällä, jossa voit leikkiä väreillä ja hakea taustakuvia. Käynnistä se vain sovellusruudukosta näppäimillä `Super + Alt + Space`.

### Mitä asennettu teema voi sisältää

Teema, jonka kirjoitat itse kansioon `~/.config/omarchy/themes`, voi sisältää aivan mitä haluat — kone ja tiedosto ovat sinun, ja Omarchy käyttää sitä kaikkea.

Teema, jonka asennat jonkun toisen repositoriosta komennolla `omarchy theme install`, säilyttää kaiken väreihin liittyvän ja menettää sen kourallisen tiedostoja, jotka suorittaisivat koodia koneellasi: kaikki `.lua`-tiedostot, päätteen määritykset (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) ja `vscode.json`. Teeman `hyprland.lua` on Lua-koodia, jonka komposiittorisi suorittaa kirjautuessasi, päätteen määritys nimeää ohjelman, jonka päätteesi käynnistää, ja `vscode.json` nimeää asennettavan VS Code -laajennuksen. Jonkun teeman asentamisen pitäisi muuttaa sitä, miltä työpöytäsi näyttää, ei koskaan sitä, mitä se suorittaa.

Kaikki muu toimii edelleen juuri niin kuin teeman tekijä on sen kirjoittanut — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, taustakuvat ja esikatselut säilyvät kaikki. Vain pois pudotetut osat luodaan uudelleen tiedostosta `colors.toml` koneellasi.

Omarchy erottaa nämä kaksi sen perusteella, onko teeman sisällä oma git-repositorionsa, ja juuri sellaisen `omarchy theme install` jättää jälkeensä kloonatessaan. Näin kirjoittamasi teema pysyy omana teemanasi ja internetistä lataamasi pysyy pelkkinä väreinä.

### Vaalea tila

Jos teet vaalean tilan teemaa, aseta `mode = "light"` tiedostosi `colors.toml` alkuun. Silloin se yhdistetään automaattisesti vaaleaan tilaan kaikissa sovelluksissa. (Vanha tapa pudottaa tyhjä tiedosto nimeltä `light.mode` teemasi juureen toimii myös edelleen.)

### Kuvakkeiden värit

Jos haluat sovittaa tiedostonhallinnan kuvakkeiden värit teemaasi, lisää tiedosto nimeltä `icons.theme`, jossa on haluamasi kuvakesarjan nimi. Oletuksena vaihtoehdot ovat: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Lukituksen avauksen kuva

Teemat, joiden mukana toimitetaan kuvat `unlock.png` ja `preview-unlock.png`, luetellaan kohdassa _Ulkoasu > Lukituksen avaus_. Tiedostosi `unlock.png` kannattaa mieluiten olla läpinäkyvä png. Ja voit luoda esikatselukuvan komennolla `omarchy plymouth preview`.

### Sellaisten sovellusten teemoittaminen, joita Omarchy ei kata

Jos käytät sovellusta, joka ei ole tuolla listalla, voit opettaa Omarchyn teemoittamaan sen itse mallipohjalla. Pudota kansioon `~/.config/omarchy/themed/` tiedosto, joka on nimetty sen luoman määrityksen mukaan ja jonka pääte on `.tpl`, ja kirjoita määritys käyttämällä paikkamerkkejä `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}`–`{{ color15 }}` sekä muuta palettia. Aina kun vaihdat teemaa, tiedosto luodaan uudelleen kyseisen teeman väreillä.

Kansiossa on perusteellisesti kommentoitu `alacritty.toml.tpl.sample`, josta voit ottaa mallia — se luettelee kaikki käytettävissä olevat muuttujat sekä muuntimet `_strip` ja `_rgb` sovelluksille, jotka haluavat värinsä ilman `#`-merkkiä tai desimaalisina RGB-arvoina. Mallipohjasi ovat etusijalla Omarchyn omiin nähden, joten voit käyttää tätä myös ohittamaan sen, miten sisäänrakennettu sovellus teemoitetaan.

### Teemasi jakaminen

Jos haluat jakaa teemasi niin, että muut voivat käyttää sitä, sinun täytyy laittaa se julkiselle git-palvelimelle, kuten GitHubiin. Sitten ihmiset voivat asentaa sen Omarchy-valikon kohdasta _Asenna > Tyyli > Teema_ käyttämällä kyseistä URL-osoitetta. On suositeltavaa noudattaa nimeämiskäytäntöä `omarchy-[themename]-theme`, koska teema näkyy silloin asennuksen jälkeen teemanvalintavalikossa oikein pelkkänä nimellä `[themename]`.

Tuosta jäljelle jäävästä `[themename]`-osasta tulee teeman hakemiston nimi, joten sen täytyy olla nimi, jota Omarchy voi käsitellä turvallisesti: sen täytyy alkaa kirjaimella, numerolla tai alaviivalla, ja loppuosa saa sisältää kirjaimia, numeroita sekä merkkejä `.`, `_`, `+` ja `-`. Isot kirjaimet muutetaan pieniksi puolestasi, mutta kaikki muu — välilyönti, lainausmerkki, ei-englanninkielinen merkki — hylätään asennuksen yhteydessä sen sijaan, että siitä tehtäisiin hakemiston nimi. Niinpä `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` ja `omarchy-c++-theme` asentuvat kaikki ongelmitta.

Muista, että kun teema on asennettu repositoriosta, sen mukana tulevat `.lua`-tiedostot, päätteen määritykset tai `vscode.json` pudotetaan pois, joten älä rakenna teemaa niiden varaan.

Voit saada teemasi lisätyksi [lisäteemojen sivulle](https://omarchy.org/themes/) lähettämällä pull requestin [omarchy-site-repositorioon](https://github.com/omacom-io/omarchy-site).
