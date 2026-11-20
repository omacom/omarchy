# Tietoturva

Omarchy ottaa tietoturvan erittäin vakavasti. Tämä on tarkoitettu käyttöjärjestelmäksi, jolla voit tehdä _Oikeaa Työtä_ _Oikeassa Maailmassa_. Jossa kannettavan menettäminen ei voi johtaa tietoturvahätätilanteeseen. Näin me siis teemme sen:

1. *Koko levyn salaus on oletuksena päällä*: Tämä on tärkein askel tietojesi fyysisen suojauksen varmistamisessa. Jos tietokoneesi katoaa tai varastetaan, tiedot on salattu kokonaan tavallisella LUKS (Linux Unified Key Setup) -salauksella. Asennusohjelma antaa sinun jättää sen pois kertakäyttökoneissa (katso [Aloittaminen](02-getting-started.md)); salauksettomalla asennuksella ei ole mitään tästä suojauksesta, ja jokainen, jonka hallussa levy on, voi lukea sen.
2. *Palomuuri on oletuksena päällä*: Kaikki saapuva liikenne on oletuksena estetty, muutamaa poikkeusta lukuun ottamatta: portti 53317 [LocalSendille](https://localsend.org/); DNS-kyselyt tietokoneen omaan selvitinpalveluun Docker-sillan osoitteessa (172.17.0.1), jotka hyväksytään niiltä yksityisiltä osoitealueilta, jotka Docker antaa säilöilleen; ja monilähetys-DNS (portti 5353), jonka avulla tulostimet ja muut verkkosi laitteet löytävät toisensa ja joka myös ilmoittaa tietokoneesi nimen siellä. Näiden lisäksi palomuuri säilyttää UFW:n tavalliset sallimiset ping-kyselyille, osoitteen hakemiselle reitittimeltäsi (DHCP) ja UPnP-etsinnälle. Jopa ssh on pois päältä, kunnes laitat sen päälle kohdasta _Setup > Security > SSHD_, mikä avaa portin 22 (nopeusrajoitettu raakaa voimaa vastaan) osana käyttöönottoa. Lukitsemme jopa Docker-käytön [ufw-docker](https://github.com/chaifeng/ufw-docker) -määrityksellä estääksemme säilöjäsi altistumasta vahingossa maailmalle.
3. *Archissa on aina uusimmat päivitykset*: Arch, perusjakelu, jonka päälle Omarchy on rakennettu, on jatkuvasti päivittyvä jakelu. Tämä tarkoittaa, että jokainen tietoturva-aukko, joka löydetään ja korjataan missä tahansa paketissa, on nopeasti saatavilla asennettavaksi komennolla `omarchy-update`. Näin käytät aina kaiken uusimpia, turvallisimpia versioita.
4. *Omarchy ylläpitää omia pakettejaan ja peiliään*: Omarchy luottaa oletuksena vain paketteihin Archin omista core/extra/multilib-pakettivarastoista ja omasta Omarchy Package Repository -pakettivarastostaan. Voit asentaa ohjelmistoja suoraan AUR:sta, mutta perusasennus ei tee niin — vain muutama valinnainen asennus, kuten kolmannen osapuolen selaimet, hakee AUR:sta.
5. *Cloudflare suojaa meitä DDoS:lta*: Omarchyn jakeluinfrastruktuuri — ISO-levykuvat, Omarchy-paketit, Arch-peili — on suojattu Cloudflaren valtavan DDoS-kilven takana ja hostattu heidän CDN:ssään. Tämä tarjoaa erinomaisen saatavuuden.

## Salasanojesi vaihtaminen

Salatussa asennuksessa sinulla on kaksi salasanaa: yksi, joka avaa levyn lukituksen käynnistyksessä, ja yksi, jolla kirjaudut sisään ja käytät `sudo`a. Käyttöönotto tekee niistä samat. Molemmat voi vaihtaa Omarchy-valikon kohdasta _Update > Password_ — ensimmäisen kohdasta _Drive Encryption_, toisen kohdasta _User_. Levyn salasanan vaihtaminen kysyy ensin nykyisen salasanan, joten pidä se käden ulottuvilla. Jos vaihtaminen keskeytyy, aja _Drive Encryption_ uudelleen: se kysyy salasanan, joka avaa levyn nyt, ja viimeistelee vaihdon.

## Jo käyttämäsi koneen luovuttaminen eteenpäin

Jos luovutat koneesi jollekulle toiselle, sinun ei tarvitse asentaa sitä uudelleen. Aja Omarchy-valikosta _Remove > Factory Reset_, kirjoita vahvistukseksi `reset` ja käynnistä uudelleen. Se pyyhkii jokaisen käyttäjätilin ja kaiken hakemistosta `/home`, heittää pois kaikki asennuksen jälkeen tekemäsi paketit ja järjestelmämuutokset ja tyhjentää koneen identiteetin — verkkoyhteydet, isäntäavaimet ja kaiken. Ylös nousee ensimmäisen käynnistyksen ohjattu käyttöönotto, valmiina siihen, että uusi omistaja syöttää oman nimensä, salasanansa ja salaussalasanansa.

Se toimii palauttamalla perusvedoksen, jonka asennusohjelma ottaa, joten se on käytettävissä vain koneissa, jotka on asennettu Omarchy ISO:lta. Ja salaamattomalla levyllä tehdasasetusten palautus on poistamista eikä turvallista pyyhkimistä, joten jos tiedot olivat arkaluonteisia, tee sen sijaan puhdas asennus.

## Salasanaton sudo

Joskus haluat `sudo`n lopettavan kysymisen, useimmiten silloin, kun AI-agentti tekee pitkän rupeaman järjestelmätyötä puolestasi. _Setup > Security > Passwordless Sudo_ kysyy, kuinka kauan käytön sallitaan: **15 minuuttia**, **1 tunti**, **1 päivä** tai **Pysyvästi**. Punainen varoituskuvake näkyy muiden valikkopalkin ilmaisimien vieressä, kun käyttö on aktiivinen. Klikkaa sitä tai aja komento uudelleen kytkeäksesi käytön pois. Voit myös antaa oman minuuttimääräsi (1–1440) komennolla `omarchy-sudo-passwordless 30` tai käyttää komentoa `omarchy-sudo-passwordless permanent`.

Ajastettu käyttö vanhenee automaattisesti, myös heti sen jälkeen, kun kone palaa keskeytystilasta, joka ylitti määräajan. Tietokoneen uudelleenkäynnistäminen päättää sen ennenaikaisesti. Pysyvä käyttö säilyy uudelleenkäynnistysten yli ja pysyy päällä, kunnes kytket sen pois.

Omarchyn asetuspaketin päivittäminen tai poistaminen päättää jokaisen tilapäisen käyttöoikeuden ennen kuin sen vanhenemistuki muuttuu. Jos komento ilmoittaa valtuutus- tai siivousvirheen, ratkaise se ennen kuin yrität ottaa toista käyttöoikeutta käyttöön; virhe ei tarkoita, että salasanaton käyttö ei olisi aktiivinen.

Ole tämän suhteen selvänäköinen: kun se on päällä, kaikki käyttäjänäsi ajettava voi tehdä mitä tahansa roottina ilman, että kysytään. Se on koko idea, ja se on myös koko riski.

## Allekirjoitusavaimet

Kaikkien ISO-allekirjoitusten ja Omarchy-varaston pakettien julkinen avain on `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([tarkista openpgp.orgissa](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Myös paketti `omarchy/omarchy-keyring` sisältää tämän, ja sitä käytetään mahdollisten päivitysten saumattomaan levittämiseen.

Löydät jokaisen ISO-julkaisun allekirjoituksen lisäämällä sen URL-osoitteeseen `.sig`, kuten `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
