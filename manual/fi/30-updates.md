# Päivitykset

Omarchy ja pakettisi pysyvät ajan tasalla Omarchy-valikon kohdasta _Päivitys > Omarchy_ (`Super + Space`).

Omarchy itsessään asennetaan tavallisina pacman-paketteina [Omarchy-pakettivarastosta](https://github.com/omacom-io/omarchy-pkgs), joten päivitys asentaa [uusimman Omarchy-julkaisun](https://github.com/omacom/omarchy/releases), suorittaa kaikki odottavat migraatiot järjestelmäsi synkronoimiseksi uusimman version kanssa ja päivittää kaikki järjestelmäpaketit [Omarchy Arch Mirrorista](https://github.com/omacom-io/omarchy-mirror) ja [AUR](https://aur.archlinux.org/)ista (jos olet asentanut AUR-paketteja).

Kun uusia julkaisuja ilmestyy, kellosi oikealle puolelle ilmestyy ympyränuolikuvake. Napsauta sitä, niin päivitysprosessi käynnistyy.

![update-available](images/update-available.webp)

### Neljä kanavaa

Omarchya päivitetään neljällä kanavalla: stable, RC, edge ja dev. Uudet asennukset alkavat stable-kanavalla, joka seuraa [virallisia julkaisuja](https://github.com/omacom/omarchy/releases/) sekä [vakaata Omarchy Arch -peiliä](https://github.com/omacom-io/omarchy-mirror), joka kulkee kuukauden uusimman perässä, jotta voimme havaita kaikki uudet yhteensopimattomuudet, jotka vaativat asetusmuutoksia, ennen kuin ne aiheuttavat ongelmia ihmisille.

Mutta jos haluat auttaa havaitsemaan nämä mahdolliset ongelmat, voit käyttää edge-kanavaa. Se pitää Omarchy-pakettisi seuraamassa uusimpia kehitysversioita ja antaa sinun päivittää uusimpiin Arch-paketteihin heti, kun ne ovat saatavilla. Tee näin vain, jos olet kokenut Linux-käyttäjä ja tiedät, miten ongelmiin joutunut järjestelmä palautetaan.

Ennen jokaista uutta suurta julkaisua teemme lopullisen validoinnin RC-kanavalla. Jos olet kiinnostunut auttamaan viimeistelyssä, tule viettämään aikaa Discordissa kanavalle #omarchy-release-candidates.

Lopuksi on dev-kanava, joka linkittää Omarchyn suoraan lähdekoodin git-työkopioon kansiossa `~/omarchy` yhdistettynä edge-paketteihin. Käytä tätä kanavaa vain, jos olet kokenut Linux-käyttäjä, työskentelet suoraan Omarchyn parissa ja olet valmis sietämään rikkoutumista.

Voit vaihtaa kanavien välillä Omarchy-valikon kohdasta _Päivitys > Kanava_ (tai terminaalissa komennolla `omarchy channel set <stable|rc|edge|dev>`, ja komennolla `omarchy channel current` näet, millä kanavalla olet).

### Ytimien vaihtaminen

Omarchy käynnistyy omalla `linux-omarchy`-ytimellään, mutta voit pitää sen rinnalla asennettuna muitakin, kuten Archin vakio-`linux`-ytimen tai testaamasi kokeellisen version. Kun ytimiä on useampi kuin yksi, Omarchy-valikon _Päivitys > Ydin_ listaa ne ja näyttää valintamerkin sen vieressä, joka käynnistyy oletuksena. Valitse toinen, syötä salasanasi kerran, niin se käynnistyy seuraavan uudelleenkäynnistyksen jälkeen. Muut ytimet pysyvät käynnistysvalikossa, joten voit silti valita sellaisen käsin, jos uudesta oletuksesta on sinulle harmia. Terminaalissa `omarchy kernel` näyttää nykyisen oletuksen, `omarchy kernel list` asennetut ytimet ja `omarchy kernel set <kernel>` vaihtaa ytimen.

### Laiteohjelmistopäivitykset

Pakettisi eivät ole ainoa asia, joka vanhenee. Monet kannettavat ja oheislaitteet toimittavat BIOS-, SSD- ja telakka-laiteohjelmistonsa Linux Vendor Firmware Servicen kautta, ja Omarchy-valikon _Päivitys > Laiteohjelmisto_ hakee ja asentaa kaiken, mitä laitteistollesi on odottamassa. Se asentaa `fwupd`:n ensimmäisellä käyttökerralla. Moni laiteohjelmisto voidaan kirjoittaa vain uudelleenkäynnistyksen aikana, joten älä ylläty, jos sinua pyydetään käynnistämään kone uudelleen.

Kun sinun täytyy muuttaa jotain asetusta itse BIOSissa, pidä `Alt` pohjassa järjestelmävalikossa (`Super + Escape`), niin _Käynnistä uudelleen_ muuttuu muotoon _Käynnistä uudelleen BIOSiin_, joka käynnistää koneen suoraan laiteohjelmiston asetuksiin ilman, että sinun täytyy osua oikeaan näppäimeen käynnistyksen aikana. Terminaalissa komento on `omarchy system firmware`.

### Varoitus suorista pacman/yay-päivityksistä

Jos Arch on sinulle jo tuttu, saatat tuntea houkutusta ajaa vain `pacman -Syu` tai `yay -Syu` itse, mutta jos teet niin, ohitat tilannekuvan, migraatiot ja asetuspäivitykset, jotka Omarchy ajaa yhdessä uusien pakettien kanssa. Siksi Omarchy itse asiassa pysäyttää suoran järjestelmäpäivityksen ja ohjaa sinut sen sijaan käyttämään komentoa `omarchy update`. (Jos todella tiedät, mitä teet, suoja kertoo, miten sen voi ohittaa yksittäisen toimenpiteen ajaksi.)

### Huonojen päivitysten palauttaminen

Jos sinulla on koskaan ongelma päivityksen tekemisen jälkeen, voit palauttaa järjestelmäsi päivitystä ennen otettuun tilannekuvaan. Käynnistä vain uudelleen ja valitse käynnistyslatausvalikosta tilannekuva ajalta ennen päivityksen aloittamista.

![bootloader](images/bootloader.webp)

Jos asetustiedostosi ovat jotenkin vioittuneet, voit myös tehdä Omarchyn uudelleenasennuksen terminaalissa komennolla `omarchy reinstall`. Tämä asentaa uudelleen kaikki Omarchyn oletuspaketit, siirtää sinut stable-kanavalle (Apple Siliconilla edge-kanavalle), alentaa liian uusien pakettien version ja nollaa kaikki asetustiedostot. Huomaa, että kaikki Omarchyn oletuksiin tekemäsi omat asetusmuutokset korvataan tämän myötä!
