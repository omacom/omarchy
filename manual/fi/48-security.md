# Tietoturva

Omarchy suhtautuu tietoturvaan äärimmäisen vakavasti. Tämän on tarkoitus olla käyttöjärjestelmä, jolla voit tehdä _Oikeaa Työtä_ _Oikeassa Maailmassa_. Sellainen, jossa kannettavan katoaminen ei voi johtaa tietoturvahätätilanteeseen. Toimimme siis näin:

1. *Koko levyn salaus on oletuksena käytössä*: Tämä on tärkein askel tietojesi fyysisen suojauksen turvaamisessa. Jos tietokoneesi katoaa tai varastetaan, tiedot on täysin salattu tavallisella LUKSilla (Linux Unified Key Setup). Asennusohjelma antaa sinun luopua siitä kertakäyttökoneiden kohdalla (katso [Aloittaminen](02-getting-started.md)); salauksettomalla asennuksella ei ole mitään tästä suojauksesta, ja kuka tahansa levyn haltija voi lukea sen.
2. *Palomuuri on oletuksena käytössä*: Kaikki saapuva liikenne on oletuksena estetty, muutamaa poikkeusta lukuun ottamatta: portti 53317 [LocalSend](https://localsend.org/)ille; DNS-kyselyt tietokoneen omaan nimipalvelimeen Docker-siltaosoitteessa (172.17.0.1), jotka hyväksytään niistä yksityisistä osoitealueista, jotka Docker antaa konteilleen; ja multicast-DNS (portti 5353), jonka avulla verkkosi tulostimet ja muut laitteet löytävät toisensa ja joka myös ilmoittaa tietokoneesi nimen siellä. Näiden lisäksi palomuuri säilyttää UFW:n tavalliset sallivuudet pingille, osoitteen saamiselle reitittimeltäsi (DHCP) ja UPnP-löytämiselle. Jopa ssh on pois päältä, kunnes kytket sen päälle kohdasta _Asetukset > Tietoturva > SSHD_, mikä avaa osana määritystä portin 22 (nopeusrajoitettuna brute force -hyökkäyksiä vastaan). Lukitsemme jopa Docker-käytön [ufw-docker](https://github.com/chaifeng/ufw-docker)-määrityksellä, jotta konttisi eivät vahingossa paljastu maailmalle.
3. *Archissa on aina uusimmat päivitykset*: Arch, taustalla oleva jakelu, jolle Omarchy on rakennettu, on jatkuvasti päivittyvä jakelu. Tämä tarkoittaa, että jokainen missä tahansa paketissa löydetty ja korjattu tietoturvahaavoittuvuus on nopeasti asennettavissa komennolla `omarchy-update`. Näin käytät aina kaiken uusimpia ja turvallisimpia versioita.
4. *Omarchy ylläpitää omia pakettejaan ja peiliään*: Omarchy tukeutuu oletuksena vain Archin omien core/extra/multilib-pakettivarastojen paketteihin ja omaan Omarchy Package Repositoryynsä. Voit asentaa ohjelmistoja suoraan AUR:sta, mutta perusasennus ei tee niin — vain muutama valinnainen asennus, kuten kolmannen osapuolen selaimet, hakee paketteja AUR:sta.
5. *Cloudflare suojaa meitä DDoS:lta*: Omarchyn jakeluinfrastruktuuri — ISO:t, Omarchy-paketit, Arch-peili — on suojattu Cloudflaren valtavan DDoS-kilven takana ja isännöity heidän CDN:ssään. Tämä tarjoaa erinomaisen saatavuuden.

## Salasanojen vaihtaminen

Sinulla on salatussa asennuksessa kaksi salasanaa: yksi, joka avaa levyn lukituksen käynnistyksessä, ja yksi, jolla kirjaudut sisään ja käytät `sudo`-komentoa. Määritys tekee niistä samat. Molemmat voi vaihtaa Omarchy-valikon kohdassa _Päivitys > Salasana_ — ensimmäisen kohdassa _Levyn salaus_, toisen kohdassa _Käyttäjä_. Levyn salasanan vaihtaminen pyytää ensin nykyistä salasanaa, joten pidä se lähellä. Jos vaihto keskeytyy, suorita _Levyn salaus_ uudelleen: se pyytää salasanaa, joka avaa levyn lukituksen nyt, ja viimeistelee vaihdon.

## Käyttämäsi koneen luovuttaminen eteenpäin

Jos luovutat koneesi jollekulle toiselle, sitä ei tarvitse asentaa uudelleen. Suorita Omarchy-valikossa _Asetukset > Palauta tietokone_, kirjoita vahvistukseksi `reset` ja käynnistä uudelleen. Se pyyhkii jokaisen käyttäjätilin ja kaiken hakemistossa `/home`, heittää pois kaikki asennuksen jälkeen lisäämäsi paketit ja tekemäsi järjestelmämuutokset sekä tyhjentää koneen identiteetin — verkkoyhteydet, isäntäavaimet ja kaiken. Käyttöön palaa ensimmäisen käynnistyksen ohjattu määritys, valmiina uutta omistajaansa varten syöttämään oman nimensä, salasanansa ja salaussalasanansa.

Se toimii palauttamalla asennusohjelman ottaman perustilavedoksen, joten se on käytettävissä vain koneissa, jotka on asennettu Omarchy-ISO:lta. Ja salauksettomalla levyllä palautus on poistamista eikä turvallista tyhjentämistä, joten jos tiedot olivat arkaluonteisia, tee sen sijaan puhdas asennus.

## Salasanaton sudo

Joskus haluat `sudo`-komennon lopettavan kyselemisen, useimmiten silloin, kun tekoälyagentti tekee puolestasi pitkän rupeaman järjestelmätyötä. _Asetukset > Tietoturva > Salasanaton sudo_ kysyy, kuinka pitkään käyttö sallitaan: **15 minuuttia**, **1 tunti**, **1 päivä** tai **Pysyvästi**. Punainen varoituskuvake ilmestyy muiden valikkopalkin ilmaisimien viereen, kun käyttö on aktiivisena. Napsauta sitä tai suorita komento uudelleen kytkeäksesi käytön pois päältä. Voit myös antaa oman minuuttimääräsi (1–1440) komennolla `omarchy-sudo-passwordless 30` tai käyttää komentoa `omarchy-sudo-passwordless permanent`.

Ajastettu käyttö vanhenee automaattisesti, myös heti sen jälkeen, kun palaat määräajan ylittäneestä keskeytystilasta. Tietokoneen uudelleenkäynnistys lopettaa sen ennenaikaisesti. Pysyvä käyttö säilyy uudelleenkäynnistysten yli ja pysyy käytössä, kunnes poistat sen käytöstä.

Omarchyn asetuspaketin päivittäminen tai poistaminen lopettaa jokaisen väliaikaisen käyttöoikeuden, ennen kuin sen vanhenemistuki muuttuu. Jos komento ilmoittaa valtuutus- tai siivousvirheestä, korjaa se ennen kuin yrität ottaa käyttöön toista käyttöoikeutta; virhe ei tarkoita, ettei salasanaton käyttö olisi aktiivinen.

Älä huijaa itseäsi tämän suhteen: kun se on päällä, kaikki käyttäjänäsi toimiva voi tehdä mitä tahansa rootina ilman, että siltä kysytään. Se on koko idea, ja se on myös koko riski.

## Allekirjoitusavaimet

Kaikkien ISO-allekirjoitusten ja Omarchy-pakettivarastopaketin julkinen avain on `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([tarkista openpgp.orgissa](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paketti `omarchy/omarchy-keyring` sisältää tämän myös, ja sitä käytetään mahdollisten päivitysten saumattomaan levittämiseen.

Löydät minkä tahansa ISO-julkaisun allekirjoituksen lisäämällä sen URL-osoitteeseen `.sig`, esimerkiksi `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
