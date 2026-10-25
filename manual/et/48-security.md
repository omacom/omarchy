# Turvalisus

Omarchy suhtub turvalisusse äärmiselt tõsiselt. See on mõeldud operatsioonisüsteemiks, millega saad teha _Päris Tööd_ _Päris Maailmas_. Kus sülearvuti kaotamine ei saa viia turvahädaolukorrani. Nii et siin on, mida me teeme:

1. *Kogu ketta krüpteerimine on kohustuslik*: See on kõige olulisem samm sinu andmete füüsiliseks kaitsmiseks. Kui sinu arvuti kaob või varastatakse, on andmed täielikult krüpteeritud standardse LUKS-i (Linux Unified Key Setup) abil.
2. *Tulemüür on vaikimisi lubatud*: Kogu sissetulev liiklus on vaikimisi blokeeritud, välja arvatud port 53317 [LocalSend](https://localsend.org/) jaoks. Isegi ssh on välja lülitatud, kuni lülitad selle sisse valiku _Seadistus > Turvalisus > SSHD_ kaudu, mis avab seadistuse osana pordi 22 (kiirusepiiranguga jõurünnete vastu). Me lukustame isegi Dockeri juurdepääsu [ufw-docker](https://github.com/chaifeng/ufw-docker) seadistuse abil, et vältida sinu konteinerite kogemata maailmale paljastamist.
3. *Archil on alati uusimad uuendused*: Arch, alusdistributsioon, millele Omarchy on ehitatud, on jooksev distributsioon. See tähendab, et iga turvanõrkus, mis avastatakse ja mõnes paketis parandatakse, on kiiresti installimiseks saadaval käsuga `omarchy-update`. Nii kasutad alati kõige uuemaid ja turvalisemaid versioone kõigest.
4. *Omarchy hooldab oma pakette ja peeglit*: Omarchy tugineb vaikimisi ainult Archi enda core/extra/multilib repositooriumide pakettidele ja oma Omarchy Package Repository pakettidele. Sa saad installida tarkvara otse AUR-ist, kuid baasinstall seda ei tee — ainult mõned valikulised installid, nagu kolmandate osapoolte brauserid, võtavad pakette AUR-ist.
5. *Cloudflare kaitseb meid DDoS-i eest*: Omarchy levitaristu — ISO-d, Omarchy paketid, Archi peegel — on kaitstud Cloudflare'i aukartustäratava DDoS-kilbi taga ja majutatud nende CDN-is. See tagab suurepärase kättesaadavuse.

## Paroolide muutmine

Krüpteeritud installil on sul kaks parooli: üks, mis avab ketta käivitamisel, ja teine, millega logid sisse ja kasutad `sudo`t. Seadistus teeb need samaks. Mõlemat saab muuta Omarchy menüüs valiku _Uuenda > Parool_ alt — esimest valikuga _Ketta krüpteerimine_, teist valikuga _Kasutaja_. Ketta parooli muutmine küsib esmalt praegust parooli, nii et hoia see käepärast. Kui muutmine katkeb, käivita _Ketta krüpteerimine_ uuesti: see küsib parooli, mis ketta praegu avab, ja viib muudatuse lõpule.

## Juba kasutatud masina edasiandmine

Kui annad oma masina kellelegi teisele üle, ei pea sa seda uuesti installima. Käivita Omarchy menüüs _Seadistus > Lähtesta arvuti_, kirjuta kinnituseks `reset` ja taaskäivita. See kustutab iga kasutajakonto ja kõik `/home` all oleva, viskab ära kõik paketid ja süsteemimuudatused, mille oled pärast installimist teinud, ning puhastab masina identiteedi — võrguühendused, hostivõtmed ja kõik. Üles tuleb esimese käivituse seadistusviisard, valmis uue omaniku jaoks sisestama oma nime, parooli ja krüpteerimisparooli.

See töötab installija tehtud lähteseisundi hetktõmmise taastamisega, nii et see on saadaval ainult Omarchy ISO-st installitud masinatel. Ja krüpteerimata kettal on lähtestamine kustutamine, mitte turvaline ülekirjutamine, nii et kui andmed olid tundlikud, tee selle asemel värske install.

## Paroolita sudo

Mõnikord tahad, et `sudo` lõpetaks küsimise, kõige sagedamini siis, kui AI agent teeb sinu eest pikka süsteemitööd. _Seadistus > Turvalisus > Paroolita Sudo_ küsib, kui kauaks juurdepääsu lubada: **15 minutit**, **1 tund**, **1 päev** või **Püsivalt**. Juurdepääsu aktiivsuse ajal ilmub teiste menüüriba indikaatorite kõrvale punane hoiatusikoon. Klõpsa sellel või käivita käsk uuesti, et juurdepääs välja lülitada. Saad ka oma minutite arvu (1 kuni 1440) anda käsuga `omarchy-sudo-passwordless 30` või kasutada käsku `omarchy-sudo-passwordless permanent`.

Ajastatud juurdepääs aegub automaatselt, sealhulgas kohe pärast jätkamist peatamisest, mis ületas tähtaja. Arvuti taaskäivitamine lõpetab selle varakult. Püsiv juurdepääs jääb taaskäivituste järel alles ja püsib lubatuna, kuni selle keelad.

Omarchy seadete paketi uuendamine või eemaldamine lõpetab iga ajutise loa enne, kui selle aegumise tugi muutub. Kui käsk teatab autoriseerimis- või puhastusveast, lahenda see enne, kui proovid lubada uut luba; viga ei tähenda, et paroolita juurdepääs oleks mitteaktiivne.

Ole selle osas selgepilguline: kui see on sees, saab kõik, mis töötab sinu kasutajana, teha kõike root-ina ilma küsimata. See ongi kogu mõte ja see on ka kogu risk.

## Allkirjastamisvõtmed

Avalik võti kõigi ISO allkirjade ja Omarchy repo pakettide jaoks on `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([kontrolli openpgp.org lehel](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakett `omarchy/omarchy-keyring` sisaldab seda samuti ja seda kasutatakse võimalike uuenduste sujuvaks juurutamiseks.

Iga ISO väljalaske allkirja leiad, lisades URL-ile .sig. Nagu https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
