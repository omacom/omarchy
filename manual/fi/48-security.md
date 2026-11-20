# Tietoturva

Omarchy ottaa tietoturvan äärimmäisen vakavasti. Tämän on tarkoitus olla käyttöjärjestelmä, jolla voit tehdä _Oikeaa Työtä_ _Oikeassa Maailmassa_. Jossa kannettavan tietokoneen katoaminen ei voi johtaa tietoturvahätätilanteeseen. Tässä siis, mitä teemme:

1. *Koko levyn salaus on oletuksena käytössä*: Tämä on tärkein askel tietojesi fyysisen suojauksen turvaamisessa. Jos tietokoneesi katoaa tai varastetaan, tiedot on täysin salattu tavallisella LUKS (Linux Unified Key Setup) -menetelmällä. Asennusohjelma antaa sinun luopua siitä kertakäyttökoneiden kohdalla (katso [Aloittaminen](02-getting-started.md)); ilman salausta tehdyltä asennukselta puuttuu tämä suojaus kokonaan, ja kuka tahansa, jolla levy on hallussaan, voi lukea sen.
2. *Palomuuri on oletuksena käytössä*: Kaikki saapuva liikenne on oletuksena estetty, muutamaa poikkeusta lukuun ottamatta: portti 53317 [LocalSend](https://localsend.org/)-palvelulle; DNS-kyselyt tietokoneen omaan nimipalvelimeen Docker bridge -osoitteessa (172.17.0.1), jotka hyväksytään niiltä yksityisiltä osoitealueilta, jotka Docker antaa säilöilleen; ja multicast DNS (portti 5353), jonka avulla tulostimet ja muut verkossasi olevat laitteet löytävät toisensa ja joka myös ilmoittaa tietokoneesi nimen siellä. Näiden lisäksi palomuuri säilyttää UFW:n tavalliset sallivuudet pingille, osoitteen saamiselle reitittimeltäsi (DHCP) ja UPnP-etsinnälle. Jopa ssh on pois päältä, kunnes kytket sen käyttöön kohdasta _Asetukset > Tietoturva > SSHD_, mikä valtuuttaa SSH-avaimesi, kytkee salasanakirjautumiset pois päältä ja vasta sitten avaa portin 22 (nopeusrajoitettuna brute force -hyökkäyksiä vastaan). Lukitsemme jopa Docker-käytön [ufw-docker](https://github.com/chaifeng/ufw-docker)-järjestelyllä, jotta säilösi eivät vahingossa paljastuisi maailmalle.
3. *Archissa on aina uusimmat päivitykset*: Arch, Omarchyn pohjana oleva jakelu, on rolling-jakelu. Tämä tarkoittaa, että kaikki tietoturva-aukot, jotka löydetään ja paikataan missä tahansa paketissa, ovat nopeasti saatavilla asennettaviksi komennolla `omarchy-update`. Näin käytät aina kaiken uusimpia ja tietoturvallisimpia versioita.
4. *Omarchy ylläpitää omia pakettejaan ja peiliään*: Omarchy nojaa oletuksena vain Archin omien core/extra/multilib-pakettivarastojen paketteihin (ARM-koneilla Arch Linux ARM:n, sekä Apple Siliconilla Asahi ALARM:n) ja omaan Omarchy Package Repository -pakettivarastoonsa. Voit asentaa ohjelmistoja suoraan AUR:sta, mutta perusasennus ei tee niin — vain muutama valinnainen asennus, kuten kolmannen osapuolen selaimet, hakee paketteja AUR:sta.
5. *Cloudflare suojaa meitä DDoS-hyökkäyksiltä*: Omarchyn jakeluinfrastruktuuri — ISO:t, Omarchy-paketit, Arch-peili — on suojattu Cloudflaren mahtavan DDoS-kilven takana ja sitä isännöidään heidän CDN:ssään. Tämä tarjoaa erinomaisen saatavuuden.

## Salasanojesi vaihtaminen

Salatussa asennuksessa sinulla on kaksi salasanaa: se, joka avaa levyn käynnistyksen yhteydessä, ja se, jolla kirjaudut sisään ja käytät `sudo`-komentoa. Asetusvaiheessa niistä tehdään samat. Molemmat voit vaihtaa Omarchy-valikon kohdasta _Päivitys > Salasana_ — ensimmäisen kohdasta _Levyn salaus_, toisen kohdasta _Käyttäjä_. Levyn salasanan vaihtaminen pyytää ensin nykyistä salasanaasi, joten pidä se käsillä. Jos vaihto keskeytyy, suorita _Levyn salaus_ uudelleen: se pyytää salasanaa, joka avaa levyn tällä hetkellä, ja viimeistelee vaihdon.

## Jo käyttämäsi koneen luovuttaminen eteenpäin

Jos luovutat koneesi jollekulle toiselle, sinun ei tarvitse asentaa sitä uudelleen. Suorita Omarchy-valikosta _Poista > Tehdasasetusten palautus_, kirjoita `reset` vahvistaaksesi, syötä levyn salaus salasana, jos sitä pyydetään, ja käynnistä uudelleen. Se pyyhkii jokaisen käyttäjätilin ja kaiken `/home`-hakemistossa olevan, heittää pois kaikki asennuksen jälkeen tekemäsi paketit ja järjestelmämuutokset ja tyhjentää koneen identiteetin — verkkoyhteydet, host-avaimet ja kaiken. Käynnistyksen jälkeen esiin tulee ensimmäisen käynnistyksen ohjattu asetus, valmiina uutta omistajaa varten syöttämään oman nimensä, salasanansa ja salaus salasanansa.

Se toimii palauttamalla asennusohjelman ottaman perusvedoksen, joten se on saatavilla vain Omarchy ISO:sta asennetuille koneille. Ja salaamattomalla levyllä palautus on poistamista eikä turvallista tyhjentämistä, joten jos tiedot olivat arkaluonteisia, tee sen sijaan puhdas asennus.

## Salasanaton sudo

Joskus haluat `sudo`-komennon lopettavan kysymisen, useimmiten silloin, kun tekoälyagentti tekee pitkän pätkän järjestelmätyötä puolestasi. _Asetukset > Tietoturva > Salasanaton sudo_ kysyy, kuinka kauan pääsy sallitaan: **15 minuuttia**, **1 tunti**, **1 päivä** tai **Pysyvästi**. Punainen varoituskuvake näkyy muiden valikkopalkin ilmaisimien vieressä, kun pääsy on aktiivinen. Napsauta sitä tai suorita komento uudelleen kytkeäksesi pääsyn pois päältä. Voit myös antaa oman minuuttimääräsi (1–1440) komennolla `omarchy-sudo-passwordless 30` tai käyttää komentoa `omarchy-sudo-passwordless permanent`.

Ajastettu pääsy vanhenee automaattisesti, myös heti sen jälkeen, kun palataan lepotilasta, joka ylitti määräajan. Tietokoneen uudelleenkäynnistys päättää sen ennenaikaisesti. Pysyvä pääsy säilyy uudelleenkäynnistysten yli ja pysyy käytössä, kunnes poistat sen käytöstä.

Omarchyn asetuspaketin päivittäminen tai poistaminen päättää kaikki väliaikaiset luvat ennen kuin niiden vanhenemistuki muuttuu. Jos komento ilmoittaa valtuutus- tai siivousvirheestä, korjaa se ennen kuin yrität ottaa käyttöön toista lupaa; virhe ei tarkoita, että salasanaton pääsy olisi pois käytöstä.

Katso tätä silmät auki: kun se on päällä, kaikki käyttäjänäsi ajettava voi tehdä rootina mitä tahansa ilman kysymistä. Se on koko idea, ja se on myös koko riski.

## Allekirjoitusavaimet

Kaikkien ISO-allekirjoitusten ja Omarchy-repon pakettien julkinen avain on `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([tarkista openpgp.orgissa](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Myös paketti `omarchy/omarchy-keyring` sisältää tämän, ja sitä käytetään mahdollisten päivitysten saumattomaan käyttöönottoon.

Löydät minkä tahansa ISO-julkaisun allekirjoituksen lisäämällä sen URL-osoitteeseen `.sig`, esimerkiksi `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
