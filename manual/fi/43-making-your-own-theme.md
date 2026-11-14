# Oman teeman tekeminen

Voit lisätä omia teemojasi hakemistoon `~/.config/omarchy/themes`. Kopioi vain jokin olemassa olevista pohjaksi (katso hakemistosta `/usr/share/omarchy/themes`) ja säädä sitä sitten mielesi mukaan. Niin kauan kuin teemasi on sen kansion sisällä, se sisältyy teemanvalintavalikkoon.

Tärkein säädettävä tiedosto on `colors.toml`. Se määrittelee värisarjan, josta sitten luodaan määritykset seuraaville: pääte (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian ja koko Omarchy-kuori (yläpalkki, valikko, ilmoitukset, OSD ja lukitusnäyttö).

Voit myös luoda uuden teeman mukana tulevalla Aether-sovelluksella, jonka ihanassa GUI-käyttöliittymässä voit leikitellä väreillä ja etsiä taustakuvia. Käynnistä se vain sovellusruudukosta näppäimillä `Super + Alt + Space`.

### Mitä asennettu teema voi sisältää

Hakemistoon `~/.config/omarchy/themes` itse kirjoittamasi teema voi sisältää mitä ikinä haluat — kone on sinun ja tiedosto on sinun, ja Omarchy ottaa kaiken käyttöön.

Komennolla `omarchy theme install` jonkun toisen reposta asentamasi teema säilyttää kaiken, mikä on väriä, ja menettää sen pienen joukon tiedostoja, jotka suorittaisivat koodia koneellasi: kaikki `.lua`-tiedostot, päätteen määritykset (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) ja `vscode.json`-tiedoston. Teeman `hyprland.lua` on Lua-koodia, jonka komposiittorisi suorittaa sisäänkirjautuessa, päätteen määritys nimeää ohjelman, jonka päätteesi käynnistää, ja `vscode.json` nimeää asennettavan VSCode-laajennuksen. Jonkun teeman asentamisen pitäisi muuttaa sitä, miltä työpöytäsi näyttää, ei koskaan sitä, mitä se suorittaa.

Kaikki muu toimii edelleen täsmälleen niin kuin teeman tekijä on sen kirjoittanut — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, taustakuvat ja esikatselut säilytetään kaikki. Vain pois pudotetut luodaan koneellasi uudelleen tiedostosta `colors.toml`.

Omarchy erottaa nämä kaksi siitä, onko teeman sisällä oma git-reponsa, minkä `omarchy theme install` jättää jälkeensä kloonatessaan. Itse kirjoittamasi teema pysyy siis omana, ja internetistä haettu pysyy väreinä.

### Vaalea tila

Jos teet vaalean tilan teemaa, aseta `mode = "light"` tiedostosi `colors.toml` alkuun. Silloin se yhdistetään automaattisesti vaaleaan tilaan kaikissa sovelluksissa. (Vanha tapa pudottaa tyhjä tiedosto nimeltä `light.mode` teemasi juureen toimii yhä.)

### Lukituksen avauskuva

Teemat, joiden mukana toimitetaan kuvat `unlock.png` ja `preview-unlock.png`, luetellaan kohdassa _Ulkoasu > Lukituksen avaus_. Tiedostosi `unlock.png` pitäisi olla mieluiten läpinäkyvä png. Esikatselukuvan voit luoda komennolla `omarchy plymouth preview`.

### Sellaisten sovellusten teemoittaminen, joita Omarchy ei kata

Jos käytät sovellusta, jota ei ole siinä luettelossa, voit itse opettaa Omarchyn teemoittamaan sen mallipohjalla. Pudota hakemistoon `~/.config/omarchy/themed/` tiedosto, joka on nimetty sen luoman määrityksen mukaan niin, että perään on lisätty `.tpl`-pääte, ja kirjoita määritys käyttämällä paikkamerkkeinä kohteita `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}`–`{{ color15 }}` ja paletin loppuosaa. Aina vaihtaessasi teemaa tiedosto luodaan uudelleen kyseisen teeman väreillä.

Siinä kansiossa on perusteellisesti kommentoitu `alacritty.toml.tpl.sample`, josta voit kopioida — se luettelee kaikki käytettävissä olevat muuttujat sekä muuntimet `_strip` ja `_rgb` sovelluksille, jotka haluavat värinsä ilman `#`-merkkiä tai desimaalisina RGB-arvoina. Mallipohjasi ovat etusijalla Omarchyn omiin nähden, joten voit käyttää tätä myös ohittamaan sen, miten sisäänrakennettu sovellus teemoitetaan.

### Teemasi levittäminen

Jos haluat levittää teemaasi niin, että muut voivat käyttää sitä, se on laitettava julkiselle git-palvelimelle, esimerkiksi GitHubiin. Sitten ihmiset voivat asentaa sen Omarchy-valikon kohdasta _Asenna > Tyyli > Teema_ käyttämällä kyseistä URL-osoitetta. On suositeltavaa noudattaa nimeämiskäytäntöä `omarchy-[themename]-theme`, sillä asennuksen jälkeen teema näkyy teemanvalintavalikossa oikein pelkkänä `[themename]`.

Siitä jäljelle jäävästä `[themename]`-osasta tulee teeman hakemiston nimi, joten sen on oltava sellainen, jota Omarchy voi käsitellä turvallisesti: sen on alettava kirjaimella, numerolla tai alaviivalla, ja loppuosa voi sisältää kirjaimia, numeroita sekä merkkejä `.`, `_`, `+` ja `-`. Isot kirjaimet muutetaan puolestasi pieniksi, mutta kaikki muu — välilyönti, lainausmerkki, ei-englanninkielinen merkki — hylätään asennusvaiheessa sen sijaan, että siitä tehtäisiin hakemiston nimi. Niinpä `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` ja `omarchy-c++-theme` asentuvat kaikki ongelmitta.

Muista, että kun teema on asennettu reposta, kaikki sen mukana tulevat `.lua`-tiedostot, päätteen määritykset ja `vscode.json` pudotetaan pois, joten älä rakenna teemaa niiden varaan.

Saat teemasi lisättyä [lisäteemojen sivulle](https://omarchy.org/themes/) lähettämällä pull requestin [omarchy-site-repoon](https://github.com/omacom-io/omarchy-site).
