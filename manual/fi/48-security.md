# Turvallisuus

Omarchy ottaa turvallisuuden äärimmäisen vakavasti. Tämän on tarkoitus olla käyttöjärjestelmä, jolla voit tehdä _oikeaa työtä_ _oikeassa maailmassa_. Maailmassa, jossa kannettavan katoaminen ei voi johtaa turvallisuushätätilanteeseen. Toimimme siis näin:

1. *Koko levyn salaus on pakollinen*: Tämä on tärkein askel tietojesi fyysisen suojauksen varmistamisessa. Jos tietokoneesi katoaa tai varastetaan, tiedot on salattu kokonaan tavallisella LUKS-järjestelmällä (Linux Unified Key Setup).
2. *Palomuuri on oletuksena käytössä*: Kaikki saapuva liikenne estetään oletuksena, paitsi portti 53317 [LocalSendille](https://localsend.org/). Jopa ssh on pois käytöstä, kunnes otat sen käyttöön kohdassa _Asetukset > Turvallisuus > SSHD_, mikä avaa portin 22 (raakaa voimaa käyttäviä hyökkäyksiä vastaan nopeusrajoitettuna) osana käyttöönottoa. Lukitsemme jopa Dockerin käytön [ufw-docker](https://github.com/chaifeng/ufw-docker)-asetuksilla, jotta konttisi eivät vahingossa paljastu maailmalle.
3. *Archissa on aina uusimmat päivitykset*: Arch, jakelu, jolle Omarchy on rakennettu, on jatkuvasti päivittyvä jakelu. Tämä tarkoittaa, että mikä tahansa löydetty ja korjattu tietoturva-aukko missä tahansa paketissa on nopeasti asennettavissa komennolla `omarchy-update`. Näin käytät aina kaikesta uusimpia ja turvallisimpia versioita.
4. *Omarchy ylläpitää omia pakettejaan ja peiliään*: Omarchy nojaa oletuksena vain Archin omien core/extra/multilib-pakettivarastojen paketteihin ja omaan Omarchy Package Repository -pakettivarastoonsa. Voit asentaa ohjelmistoja suoraan AUR:sta, mutta perusasennus ei sitä tee — vain muutamat valinnaiset asennukset, kuten kolmansien osapuolten selaimet, hakevat paketteja AUR:sta.
5. *Cloudflare suojaa meitä DDoS-hyökkäyksiltä*: Omarchyn jakeluinfrastruktuuri — ISO-levykuvat, Omarchy-paketit ja Arch-peili — on suojattu Cloudflaren mahtavan DDoS-suojan takana ja isännöity heidän CDN-verkossaan. Tämä tarjoaa erinomaisen saatavuuden.

## Salasanojesi vaihtaminen

Salatussa asennuksessa sinulla on kaksi salasanaa: yksi, joka avaa aseman lukituksen käynnistyksen yhteydessä, ja toinen, jolla kirjaudut sisään ja käytät `sudo`-komentoa. Käyttöönotto tekee niistä samat. Molemmat voi vaihtaa Omarchy-valikon kohdassa _Päivitys > Salasana_ — _Aseman salaus_ ensimmäiselle ja _Käyttäjä_ toiselle. Aseman salasanan vaihtaminen pyytää ensin nykyistä salasanaa, joten pidä se lähellä. Jos vaihto keskeytyy, suorita _Aseman salaus_ uudelleen: se pyytää salasanaa, joka avaa aseman lukituksen nyt, ja viimeistelee vaihdon.

## Jo käyttämäsi koneen luovuttaminen eteenpäin

Jos luovutat koneesi jollekulle toiselle, sitä ei tarvitse asentaa uudelleen. Suorita Omarchy-valikossa _Asetukset > Nollaa tietokone_, kirjoita vahvistukseksi `reset` ja käynnistä kone uudelleen. Se poistaa jokaisen käyttäjätilin ja kaiken hakemistosta `/home`, heittää pois kaikki asennuksen jälkeen tekemäsi paketit ja järjestelmämuutokset sekä tyhjentää koneen identiteetin — verkkoyhteydet, isäntäavaimet ja kaiken. Käynnistyksen jälkeen esiin tulee ensimmäisen käynnistyksen ohjattu käyttöönotto, joka on valmis uutta omistajaa varten syöttämään oman nimensä, salasanansa ja salaussalasanansa.

Se toimii palauttamalla asennusohjelman ottaman perusvedoksen, joten se on käytettävissä vain koneissa, jotka on asennettu Omarchy ISO -levykuvasta. Ja salaamattomalla asemalla nollaus on poistoa eikä suojattua tyhjennystä, joten jos tiedot olivat arkaluonteisia, tee sen sijaan uusi asennus.

## Salasanaton sudo

Joskus haluat, että `sudo` lakkaa kyselemästä, useimmiten silloin, kun tekoälyagentti tekee puolestasi pitkän rupeaman järjestelmätyötä. _Asetukset > Turvallisuus > Salasanaton sudo_ kysyy, kuinka kauan käyttöoikeus sallitaan: **15 minuuttia**, **1 tunti**, **1 päivä** tai **Pysyvästi**. Punainen varoituskuvake näkyy muiden valikkorivin ilmaisimien vieressä, kun käyttöoikeus on aktiivinen. Napsauta sitä tai suorita komento uudelleen kytkeäksesi käyttöoikeuden pois päältä. Voit myös antaa oman minuuttimääräsi (1–1440) komennolla `omarchy-sudo-passwordless 30` tai käyttää komentoa `omarchy-sudo-passwordless permanent`.

Ajastettu käyttöoikeus vanhenee automaattisesti, myös heti keskeytystilasta jatkamisen jälkeen, jos määräaika ylittyi keskeytyksen aikana. Tietokoneen uudelleenkäynnistys päättää sen ennenaikaisesti. Pysyvä käyttöoikeus säilyy uudelleenkäynnistysten yli ja pysyy käytössä, kunnes poistat sen käytöstä.

Omarchyn asetuspaketin päivittäminen tai poistaminen päättää minkä tahansa väliaikaisen käyttöoikeuden ennen sen vanhenemistuen muuttumista. Jos komento ilmoittaa valtuutus- tai siivousvirheestä, ratkaise se ennen kuin yrität ottaa toista käyttöoikeutta käyttöön; virhe ei tarkoita, että salasanaton käyttöoikeus olisi pois käytöstä.

Ole tämän suhteen selväsilmäinen: kun se on käytössä, mikä tahansa käyttäjänäsi toimiva ohjelma voi tehdä mitä tahansa pääkäyttäjänä ilman kyselyä. Se on koko idea, ja se on myös koko riski.

## Allekirjoitusavaimet

Kaikkien ISO-allekirjoitusten ja Omarchy-pakettivaraston pakettien julkinen avain on `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([tarkista osoitteessa openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paketti `omarchy/omarchy-keyring` sisältää myös tämän avaimen, ja sitä käytetään mahdollisten päivitysten saumattomaan käyttöönottoon.

Löydät minkä tahansa ISO-julkaisun allekirjoituksen lisäämällä sen URL-osoitteeseen päätteen `.sig`, kuten `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
