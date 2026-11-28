# Tietoturva

Omarchy suhtautuu tietoturvaan äärimmäisen vakavasti. Tämän on tarkoitus olla käyttöjärjestelmä, jota voit käyttää _oikeaan työhön_ _oikeassa maailmassa_. Jossa kannettavan menettäminen ei voi johtaa tietoturvahätätilanteeseen. Tässä on siis, mitä teemme:

1. *Koko levyn salaus on oletuksena käytössä*: Tämä on tärkein vaihe tietojesi fyysisen suojauksen turvaamisessa. Jos tietokoneesi katoaa tai varastetaan, tiedot on täysin salattu tavallisella LUKSilla (Linux Unified Key Setup). Asennusohjelma antaa sinun luopua tästä poisheitettävien koneiden kohdalla (katso [Aloittaminen](02-getting-started.md)); ilman salausta tehdyltä asennukselta puuttuu tämä suojaus kokonaan, ja kuka tahansa, jolla levy on hallussaan, voi lukea sen.
2. *Palomuuri on oletuksena käytössä*: Kaikki saapuva liikenne estetään oletuksena, muutamia poikkeuksia lukuun ottamatta: LocalSendin portti 53317 ([LocalSend](https://localsend.org/)); DNS-kyselyt tietokoneen omalle nimipalvelimelle Docker-sillan osoitteessa (172.17.0.1), jotka hyväksytään yksityisiltä osoitealueilta, jotka Docker antaa säilöilleen; ja monilähetys-DNS (portti 5353), jonka avulla tulostimet ja muut verkkosi laitteet löytävät toisensa ja joka myös ilmoittaa tietokoneesi nimen siellä. Näiden lisäksi palomuuri säilyttää UFW:n vakioluvat pingille, osoitteen saamiselle reitittimeltäsi (DHCP) ja UPnP-havaitsemiselle. Jopa ssh on pois päältä, kunnes otat sen käyttöön kohdassa _Setup > Security > SSHD_, joka valtuuttaa SSH-avaimesi, poistaa salasanakirjautumiset käytöstä ja avaa vasta sitten portin 22 (nopeusrajoitettuna raakaa voimaa käyttäviä hyökkäyksiä vastaan). Lukitsemme jopa Docker-käytön [ufw-docker](https://github.com/chaifeng/ufw-docker)-asetuksilla estääksemme säilöjäsi paljastumasta vahingossa maailmalle.
3. *Archilla on aina uusimmat päivitykset*: Arch, taustalla oleva jakelu, jonka päälle Omarchy on rakennettu, on jatkuvasti päivittyvä jakelu. Tämä tarkoittaa, että kaikki tietoturva-aukot, jotka löydetään ja korjataan missä tahansa paketissa, ovat nopeasti asennettavissa komennolla `omarchy-update`. Käytät sillä tavalla aina kaiken uusimpia ja turvallisimpia versioita.
4. *Omarchy ylläpitää omia pakettejaan ja peiliään*: Omarchy nojaa oletuksena vain Archin omien core/extra/multilib-pakettivarastojen paketteihin (ARM-koneilla Arch Linux ARM:n, sekä Apple Siliconilla Asahi ALARMin) ja omaan Omarchy Package Repositoryynsä. Voit asentaa ohjelmistoja suoraan AUR:sta, mutta perusasennus ei tee niin — vain muutamat valinnaiset asennukset, kuten kolmannen osapuolen selaimet, hakevat AUR:sta.
5. *Cloudflare suojaa meitä DDoS:ilta*: Omarchyn jakeluinfrastruktuuri — ISO:t, Omarchy-paketit, Arch-peili — on suojattu Cloudflaren mahtavan DDoS-kilven takana ja isännöity heidän CDN:ssään. Tämä tarjoaa erinomaisen saatavuuden.

## Salasanojesi vaihtaminen

Salatulla asennuksella sinulla on kaksi salasanaa: se, joka avaa levyn lukituksen käynnistyksessä, ja se, jolla kirjaudut sisään ja käytät `sudo`-komentoa. Asennus tekee niistä samat. Omarchy-valikon _Update > Password_ vaihtaa molemmat kerralla, joten ne pysyvät samoina: se kysyy nykyistä levyn salasanaa, sitten uutta, vaihtaa levyn salasanan ja asettaa sitten kirjautumissalasanasi vastaamaan sitä. Ilman levyn salausta se vaihtaa vain kirjautumissalasanasi. Jos vaihto keskeytyy, suorita _Update > Password_ uudelleen: se kysyy salasanaa, joka avaa levyn nyt, viimeistelee vaihdon ja asettaa kirjautumissalasanasi siksi. Vaihtaaksesi toisen salatun levyn salasanan, suorita päätelaitteessa `omarchy-drive-password`.

## Jo käyttämäsi koneen luovuttaminen eteenpäin

Jos luovutat koneesi jollekulle muulle, sinun ei tarvitse asentaa sitä uudelleen. Suorita Omarchy-valikossa _Remove > Factory Reset_, kirjoita vahvistukseksi `reset`, syötä levyn salausalasana, jos sitä kysytään, ja käynnistä uudelleen. Se pyyhkii jokaisen käyttäjätilin ja kaiken hakemistossa `/home`, heittää pois kaikki asennuksen jälkeen tekemäsi paketit ja järjestelmämuutokset ja tyhjentää koneen identiteetin — verkkoyhteydet, isäntäavaimet ja kaiken. Takaisin käynnistyy ensimmäisen käynnistyksen ohjattu asennus, valmiina uutta omistajaansa varten syöttämään oman nimensä, salasanansa ja salausalasanansa.

Se toimii palauttamalla asennusohjelman ottaman perustason tilannevedoksen, joten se on saatavilla vain Omarchy ISO:sta asennetuilla koneilla. Ja ilman salausta olevalla levyllä nollaus on poistoa pikemminkin kuin suojattua tyhjennystä, joten jos tiedot olivat arkaluonteisia, tee sen sijaan uusi asennus.

## Salasanaton sudo

Joskus haluat `sudo`-komennon lopettavan kysymisen, useimmiten silloin, kun tekoälyagentti tekee pitkää pätkää järjestelmätyötä puolestasi. _Setup > Security > Passwordless Sudo_ kysyy, kuinka kauan pääsy sallitaan: **15 minutes**, **1 Hour**, **1 Day** tai **Permanently**. Punainen varoituskuvake näkyy muiden valikkopalkin ilmaisimien vieressä, kun pääsy on aktiivinen. Napsauta sitä tai suorita komento uudelleen kytkeäksesi pääsyn pois. Voit myös antaa oman minuuttimääräsi (1–1440) komennolla `omarchy-sudo-passwordless 30` tai käyttää komentoa `omarchy-sudo-passwordless permanent`.

Ajastettu pääsy vanhenee automaattisesti, myös heti keskeytyksestä jatkamisen jälkeen, jos keskeytys ylitti määräajan. Tietokoneen uudelleenkäynnistäminen päättää sen aikaisin. Pysyvä pääsy säilyy uudelleenkäynnistysten yli ja pysyy käytössä, kunnes poistat sen käytöstä.

Omarchyn asetuspaketin päivittäminen tai poistaminen päättää minkä tahansa tilapäisen myönnön ennen kuin sen vanhenemistuki muuttuu. Jos komento ilmoittaa valtuutus- tai siivousvirheestä, korjaa se ennen kuin yrität ottaa käyttöön toista myöntöä; virhe ei tarkoita, että salasanaton pääsy ei olisi aktiivinen.

Katso tätä silmät auki: kun se on päällä, mikä tahansa käyttäjänäsi suoritettava voi tehdä mitä tahansa pääkäyttäjänä ilman, että kysytään. Se on koko tarkoitus, ja se on myös koko riski.

## Allekirjoitusavaimet

Kaikkien ISO-allekirjoitusten ja Omarchy-varastopakettien julkinen avain on `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([tarkista openpgp.orgissa](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paketti `omarchy/omarchy-keyring` sisältää tämän myös ja sitä käytetään mahdollisten päivitysten saumattomaan käyttöönottoon.

Löydät minkä tahansa ISO-julkaisun allekirjoituksen lisäämällä sen URL-osoitteeseen `.sig`, kuten `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
