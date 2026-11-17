# Päivitykset

Omarchy ja pakettisi pidetään ajan tasalla Omarchy-valikon kohdasta _Päivitys > Omarchy_ (`Super + Space`).

Omarchy itse asennetaan tavallisina pacman-paketteina [Omarchy-pakettivarastosta](https://github.com/omacom-io/omarchy-pkgs), joten päivitys asentaa [uusimman Omarchy-julkaisun](https://github.com/omacom/omarchy/releases), ajaa kaikki odottavat migraatiot saadakseen järjestelmäsi synkronoitua uusimman kanssa ja päivittää kaikki järjestelmäpaketit [Omarchy Arch Mirrorista](https://github.com/omacom-io/omarchy-mirror) ja [AUR](https://aur.archlinux.org/)ista (jos olet asentanut AUR-paketteja).

Kun uusia julkaisuja tehdään, kellosi oikealle puolelle ilmestyy ympyränuolikuvake. Napsauta sitä, niin päivitysprosessi käynnistyy.

![update-available](images/update-available.webp)

### Neljä kanavaa

Omarchya päivitetään neljää kanavaa pitkin: stable, RC, edge ja dev. Uudet asennukset aloittavat stable-kanavalla, joka seuraa [virallisia julkaisuja](https://github.com/omacom/omarchy/releases/) sekä [vakaata Omarchy Arch -peiliä](https://github.com/omacom-io/omarchy-mirror), joka kulkee kuukauden uusinta jäljessä, jotta voimme havaita kaikki uudet yhteensopivuusongelmat, jotka vaativat määritysmuutoksia, ennen kuin ne aiheuttavat ongelmia ihmisille.

Mutta jos haluat auttaa havaitsemaan nuo mahdolliset ongelmat, voit käyttää edge-kanavaa. Se pitää Omarchy-pakettisi seuraamassa uusimpia kehitysversioita ja antaa sinun päivittää uusimpiin Arch-paketteihin heti, kun ne ovat saatavilla. Tee näin vain, jos olet kokenut Linuxin kanssa ja tiedät, miten ongelmiin joutunut järjestelmä palautetaan.

Ennen jokaista uutta suurta julkaisua teemme viimeisen validoinnin RC-kanavalla. Jos olet kiinnostunut auttamaan viimeisessä hionnassa, tule hengailemaan Discordissa kanavalle #omarchy-release-candidates.

Lopuksi on dev-kanava, joka yhdistää Omarchyn suoraan lähdekoodin git-työkopioon kansiossa `~/omarchy` yhdessä edge-pakettien kanssa. Käytä tätä kanavaa vain, jos olet kokenut Linux-käyttäjä, työskentelet suoraan Omarchyn parissa ja olet valmis sietämään rikkoutumista.

Voit vaihtaa kanavien välillä Omarchy-valikon kohdasta _Päivitys > Kanava_ (tai `omarchy-channel-set` päätteessä).

### Ytimien vaihtaminen

Omarchy käynnistyy omalla `linux-omarchy`-ytimellään, mutta voit pitää sen rinnalla asennettuina muitakin, kuten Archin vakio-`linux`-ytimen tai testaamasi kokeellisen koontiversion. Kun ytimiä on useampi kuin yksi, Omarchy-valikon _Päivitys > Ydin_ listaa ne valintamerkillä sen vieressä, joka käynnistyy oletuksena. Valitse toinen, syötä salasanasi kerran, niin se käynnistyy seuraavan uudelleenkäynnistyksen jälkeen. Muut ytimet pysyvät käynnistysvalikossa, joten voit silti valita sellaisen käsin, jos uudesta oletuksesta on harmia. Päätteessä nykyisen oletuksen näet komennolla `omarchy-kernel`, asennetut komennolla `omarchy-kernel list` ja vaihtaminen onnistuu komennolla `omarchy-kernel set <kernel>`.

### Laiteohjelmistopäivitykset

Pakettisi eivät ole ainoa asia, joka vanhenee. Monet kannettavat ja oheislaitteet toimittavat BIOS-, SSD- ja telakkalaiteohjelmistoja Linux Vendor Firmware Servicen kautta, ja Omarchy-valikon _Päivitys > Laiteohjelmisto_ hakee ja asentaa kaiken, mitä laitteistollesi on odottamassa. Se asentaa `fwupd`-ohjelman ensimmäisellä käyttökerralla. Runsaasti laiteohjelmistoja voidaan kirjoittaa vain uudelleenkäynnistyksen aikana, joten älä ylläty, jos sinua pyydetään käynnistämään uudelleen.

Kun sinun tarvitsee muuttaa asetusta itse BIOSissa, pidä `Alt` pohjassa järjestelmävalikossa (`Super + Escape`), niin _Käynnistä uudelleen_ muuttuu muotoon _Käynnistä uudelleen BIOSiin_, joka käynnistyy suoraan laiteohjelmiston asetuksiin ilman, että sinun tarvitsee osua oikeaan näppäimeen käynnistyksen yhteydessä. Päätteessä komento on `omarchy system firmware`.

### Varoitus suorista pacman/yay-päivityksistä

Jos Arch on sinulle jo tuttu, saatat tuntea houkutusta ajaa itse vain `pacman -Syu` tai `yay -Syu`, mutta jos teet niin, ohitat tilannekuvan, migraatiot ja määrityspäivitykset, jotka Omarchy ajaa yhdessä uusien pakettien kanssa. Siksi Omarchy itse asiassa pysäyttää suoran järjestelmäpäivityksen ja ohjaa sinut sen sijaan käyttämään komentoa `omarchy update`. (Jos todella tiedät, mitä teet, suojaus kertoo, miten sen voi ohittaa yksittäisen transaktion ajaksi.)

### Huonojen päivitysten palauttaminen

Jos sinulla on koskaan ongelma päivityksen tekemisen jälkeen, voit palauttaa järjestelmäsi päivitystä ennen otettuun tilannekuvaan. Käynnistä vain uudelleen ja valitse käynnistysvalikosta tilannekuva ajalta ennen päivityksen aloittamista.

![bootloader](images/bootloader.webp)

Jos määritystiedostosi ovat jotenkin vioittuneet, voit myös tehdä Omarchyn uudelleenasennuksen käyttämällä päätteessä komentoa `omarchy reinstall`. Tämä asentaa kaikki Omarchyn oletuspaketit uudelleen, siirtää sinut stable-kanavalle, alentaa kaikkien liian uusien pakettien versiot ja nollaa kaikki määritystiedostot. Huomaa, että kaikki Omarchyn oletuksiin tekemäsi käyttäjämääritysten muutokset ylikirjoitetaan tämän aikana!
