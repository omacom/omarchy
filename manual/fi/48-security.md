# Turvallisuus

Omarchy suhtautuu turvallisuuteen erittäin vakavasti. Tämän on tarkoitus olla käyttöjärjestelmä, jota voit käyttää _Oikean Työn_ tekemiseen _Oikeassa Maailmassa_. Missä kannettavan menettäminen ei voi johtaa turvallisuushätätilanteeseen. Joten tässä on, mitä teemme:

1. *Koko levyn salaus on pakollinen*: Tämä on tärkein vaihe tietojesi fyysisen suojauksen turvaamiseksi. Jos tietokoneesi katoaa tai varastetaan, tiedot ovat täysin salattuja käyttäen standardia LUKSia (Linux Unified Key Setup).
2. *Palomuuri on oletuksena käytössä*: Kaikki saapuva liikenne estetään oletuksena lukuun ottamatta porttia 53317 [LocalSendille](https://localsend.org/). Jopa ssh on pois päältä, kunnes otat sen käyttöön kohdassa _Asetukset > Turvallisuus > SSHD_, mikä avaa portin 22 (väsytyshyökkäyksiä vastaan rajoitettuna) osana asennusta. Lukitsemme jopa Docker-käytön käyttäen [ufw-docker](https://github.com/chaifeng/ufw-docker) -asetusta estääksemme konttejasi paljastumasta vahingossa maailmalle.
3. *Archilla on aina uusimmat päivitykset*: Arch, taustalla oleva jakelu, jonka päälle Omarchy on rakennettu, on jatkuvasti päivittyvä jakelu. Tämä tarkoittaa, että mikä tahansa tietoturva-aukko, joka löydetään ja korjataan missä tahansa paketissa, on nopeasti asennettavissa komennolla `omarchy-update`. Ajat aina kaikkea uusimmissa, turvallisimmissa versioissa sillä tavalla.
4. *Omarchy ylläpitää omia pakettejaan ja peiliään*: Omarchy luottaa oletuksena vain paketteihin Archin omista core/extra/multilib-repoista ja omasta Omarchy Package Repositorystaan. Voit asentaa ohjelmistoja suoraan AUR:sta, mutta perusasennus ei tee niin — vain muutama valinnainen asennus, kuten kolmannen osapuolen selaimet, hakee AUR:sta.
5. *Cloudflare suojaa meitä DDoS:lta*: Kaikki Omarchyn jakeluinfrastruktuuri — ISO:t, Omarchy-paketit, Arch-peili — on suojattu Cloudflaren mahtavan DDoS-kilven takana ja isännöity heidän CDN:ssään. Tämä tarjoaa erinomaisen saatavuuden.

## Salasanojesi vaihtaminen

Sinulla on kaksi salasanaa salatussa asennuksessa: se, joka avaa aseman käynnistyksessä, ja se, jolla kirjaudut sisään ja käytät `sudo`a. Asetus tekee niistä samat. Molemmat voidaan vaihtaa Omarchy-valikosta kohdasta _Päivitä > Salasana_ — _Drive Encryption_ ensimmäiselle, _User_ toiselle. Aseman salasanan vaihtaminen kysyy nykyistä salasanaa ensin, joten pidä se käsillä. Jos vaihto keskeytyy, aja _Drive Encryption_ uudelleen: se kysyy salasanaa, joka avaa aseman nyt, ja viimeistelee vaihdon.

## Jo käytetyn koneen luovuttaminen eteenpäin

Jos luovutat koneesi jollekulle toiselle, sinun ei tarvitse asentaa sitä uudelleen. Aja Omarchy-valikossa _Asetukset > Nollaa tietokone_, kirjoita `reset` vahvistaaksesi ja käynnistä uudelleen. Se pyyhkii jokaisen käyttäjätilin ja kaiken kansiossa `/home`, heittää pois kaikki paketit ja järjestelmämuutokset, jotka teit asennuksen jälkeen, ja tyhjentää koneen identiteetin — verkkoyhteydet, isäntäavaimet ja kaiken. Takaisin tulee ensikäynnistyksen asennusvelho, valmiina uuden omistajansa syöttämään oman nimensä, salasanansa ja salauksen salasanansa.

Se toimii palauttamalla asennusohjelman ottaman perustilannekuvan, joten se on käytettävissä vain koneissa, jotka on asennettu Omarchy-ISO:sta. Ja salaamattomalla asemalla nollaus on poisto eikä turvallinen pyyhintä, joten jos tiedot olivat arkaluonteisia, tee sen sijaan tuore asennus.

## Salasanaton sudo

Joskus haluat `sudo`n lakkaavan kysymästä, useimmiten kun tekoälyagentti tekee puolestasi pitkän pätkän järjestelmätyötä. _Asetukset > Turvallisuus > Salasanaton sudo_ kysyy, kuinka kauan käyttöoikeutta sallitaan: **15 minutes**, **1 Hour**, **1 Day** tai **Permanently**. Punainen varoituskuvake ilmestyy muiden valikkopalkin ilmaisimien viereen, kun käyttöoikeus on aktiivinen. Napsauta sitä tai aja komento uudelleen sammuttaaksesi käyttöoikeuden. Voit myös antaa oman minuuttimääräsi (1–1440) komennolla `omarchy-sudo-passwordless 30` tai käyttää komentoa `omarchy-sudo-passwordless permanent`.

Ajastettu käyttöoikeus vanhenee automaattisesti, myös heti määräajan ylittäneestä lepotilasta palattua. Tietokoneen uudelleenkäynnistys päättää sen aikaisin. Pysyvä käyttöoikeus säilyy uudelleenkäynnistysten yli ja pysyy käytössä, kunnes poistat sen käytöstä.

Omarchyn asetuspaketin päivittäminen tai poistaminen päättää minkä tahansa väliaikaisen käyttöoikeuden ennen sen vanhenemistuen muuttumista. Jos komento ilmoittaa valtuutus- tai siivousvirheen, ratkaise se ennen toisen käyttöoikeuden käyttöönottoa; virhe ei tarkoita, että salasanaton käyttöoikeus olisi ei-aktiivinen.

Ole tässä rehellinen itsellesi: kun se on päällä, mikä tahansa käyttäjänäsi ajettava voi tehdä mitä tahansa rootina kysymättä. Se on koko tarkoitus, ja se on myös koko riski.

## Allekirjoitusavaimet

Julkinen avain kaikille ISO-allekirjoituksille ja Omarchy-repo-paketille on `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([tarkista osoitteessa openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paketti `omarchy/omarchy-keyring` sisältää myös tämän, ja sitä käytetään mahdollisten päivitysten saumattomaan käyttöönottoon.

Löydät allekirjoituksen mille tahansa ISO-julkaisulle lisäämällä URL-osoitteeseen .sig. Kuten https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
