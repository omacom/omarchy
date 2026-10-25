# Tietoturva

Omarchy suhtautuu tietoturvaan äärimmäisen vakavasti. Tämä on tarkoitettu käyttöjärjestelmäksi, jolla voit tehdä _oikeaa työtä_ _oikeassa maailmassa_. Maailmassa, jossa kannettavan tietokoneen menettäminen ei voi johtaa tietoturvahätätilanteeseen. Toimimme siis näin:

1. *Koko levyn salaus on pakollinen*: Tämä on tärkein askel tietojesi fyysisen suojauksen turvaamisessa. Jos tietokoneesi katoaa tai varastetaan, tiedot on salattu kokonaan tavallisella LUKSilla (Linux Unified Key Setup).
2. *Palomuuri on oletuksena käytössä*: Kaikki saapuva liikenne estetään oletuksena lukuun ottamatta porttia 53317 [LocalSendille](https://localsend.org/). Jopa ssh on pois päältä, kunnes otat sen käyttöön kohdasta _Setup > Security > SSHD_, mikä avaa portin 22 (nopeusrajoitettu raa'an voiman hyökkäyksiä vastaan) osana käyttöönottoa. Lukitsemme jopa Dockerin käytön [ufw-docker](https://github.com/chaifeng/ufw-docker)-asetuksilla estääksemme konttejasi paljastumasta vahingossa maailmalle.
3. *Archissa on aina uusimmat päivitykset*: Arch, taustalla oleva jakelu, jolle Omarchy on rakennettu, on jatkuvasti päivittyvä jakelu. Tämä tarkoittaa, että mikä tahansa tietoturva-aukko, joka löydetään ja korjataan missä tahansa paketissa, on nopeasti asennettavissa komennolla `omarchy-update`. Näin käytät aina kaiken uusimpia ja turvallisimpia versioita.
4. *Omarchy ylläpitää omia pakettejaan ja peilipalvelintaan*: Omarchy luottaa oletuksena vain Archin omien core/extra/multilib-pakettivarastojen paketteihin ja omaan Omarchy Package Repositoryynsä. Voit asentaa ohjelmistoja suoraan AUR:sta, mutta perusasennus ei tee niin — vain muutama valinnainen asennus, kuten kolmannen osapuolen selaimet, hakee paketteja AUR:sta.
5. *Cloudflare suojaa meitä DDoS:lta*: Omarchyn jakeluinfrastruktuuri — ISO:t, Omarchy-paketit, Arch-peilipalvelin — on suojattu Cloudflaren mahtavan DDoS-kilven takana ja isännöity heidän CDN:ssään. Tämä tarjoaa erinomaisen saatavuuden.

## Salasanojen vaihtaminen

Salatussa asennuksessa sinulla on kaksi salasanaa: yksi, joka avaa aseman lukituksen käynnistyksen yhteydessä, ja yksi, jolla kirjaudut sisään ja käytät `sudo`a. Käyttöönotto tekee niistä samat. Molemmat voi vaihtaa Omarchy-valikon kohdasta _Update > Password_ — _Drive Encryption_ ensimmäiselle, _User_ toiselle. Aseman salasanan vaihtaminen kysyy ensin nykyistä salasanaa, joten pidä se käden ulottuvilla. Jos vaihto keskeytyy, suorita _Drive Encryption_ uudelleen: se kysyy salasanaa, joka avaa aseman lukituksen nyt, ja viimeistelee vaihdon.

## Jo käyttämäsi koneen luovuttaminen eteenpäin

Jos luovutat koneesi jollekulle muulle, sinun ei tarvitse asentaa sitä uudelleen. Suorita Omarchy-valikosta _Setup > Reset Computer_, kirjoita vahvistukseksi `reset` ja käynnistä uudelleen. Se pyyhkii jokaisen käyttäjätilin ja kaiken `/home`ssa olevan, heittää pois kaikki asennuksen jälkeen tekemäsi paketit ja järjestelmämuutokset ja tyhjentää koneen identiteetin — verkkoyhteydet, isäntäavaimet ja kaiken. Käynnistyksessä palaa ensimmäisen käynnistyksen ohjattu käyttöönotto, valmiina uutta omistajaa varten syöttämään oman nimensä, salasanansa ja salaussalasanansa.

Se toimii palauttamalla asennusohjelman ottaman perusvedoksen, joten se on käytettävissä vain koneissa, jotka on asennettu Omarchy ISO:lta. Ja salaamattomalla asemalla palautus on poistoa eikä suojattua tyhjennystä, joten jos tiedot olivat arkaluonteisia, tee sen sijaan puhdas asennus.

## Salasanaton sudo

Joskus haluat `sudo`n lopettavan kysymisen, useimmiten silloin, kun AI-agentti tekee puolestasi pitkän rupeaman järjestelmätyötä. _Setup > Security > Passwordless Sudo_ kysyy, kuinka kauan käyttö sallitaan: **15 minuuttia**, **1 tunti**, **1 päivä** tai **Pysyvästi**. Punainen varoituskuvake ilmestyy muiden valikkopalkin ilmaisimien viereen, kun käyttö on aktiivinen. Kytke käyttö pois napsauttamalla sitä tai suorittamalla komento uudelleen. Voit myös antaa oman minuuttimääräsi (1–1440) komennolla `omarchy-sudo-passwordless 30` tai käyttää komentoa `omarchy-sudo-passwordless permanent`.

Ajoitettu käyttö vanhenee automaattisesti, myös heti keskeytystilasta palaamisen jälkeen, jos määräaika ylittyi sen aikana. Tietokoneen uudelleenkäynnistys päättää sen ennenaikaisesti. Pysyvä käyttö säilyy uudelleenkäynnistysten yli ja pysyy käytössä, kunnes poistat sen käytöstä.

Omarchyn asetuspaketin päivittäminen tai poistaminen päättää kaikki väliaikaiset myönnöt ennen kuin niiden vanhenemistuki muuttuu. Jos komento ilmoittaa valtuutus- tai siivousvirheestä, korjaa se ennen kuin yrität ottaa käyttöön toista myöntöä; virhe ei tarkoita, että salasanaton käyttö olisi pois käytöstä.

Katso tätä silmät auki: kun se on päällä, mikä tahansa käyttäjänäsi ajettava voi tehdä rootina mitä tahansa ilman, että sitä kysytään. Se on koko idea, ja se on myös koko riski.

## Allekirjoitusavaimet

Kaikkien ISO-allekirjoitusten ja Omarchy-pakettivaraston pakettien julkinen avain on `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([tarkista osoitteessa openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paketti `omarchy/omarchy-keyring` sisältää tämän myös, ja sitä käytetään mahdollisten päivitysten saumattomaan käyttöönottoon.

Löydät minkä tahansa ISO-julkaisun allekirjoituksen lisäämällä URL-osoitteeseen .sig. Kuten https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
