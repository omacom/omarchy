# Turvalisus

Omarchy suhtub turvalisusse äärmiselt tõsiselt. See on mõeldud operatsioonisüsteemina, mida saad kasutada _päris töö_ tegemiseks _päris maailmas_. Kus sülearvuti kaotamine ei saa viia turvahädaolukorrani. Nii et siin on, mida me teeme:

1. *Täisketta krüpteerimine on kohustuslik*: see on kõige olulisem samm sinu andmete füüsiliseks kaitsmiseks. Kui sinu arvuti läheb kaduma või varastatakse, on andmed täielikult krüpteeritud standardse LUKS-iga (Linux Unified Key Setup).
2. *Tulemüür on vaikimisi lubatud*: kogu sissetulev liiklus on vaikimisi blokeeritud, välja arvatud port 53317 [LocalSend](https://localsend.org/) jaoks. Isegi ssh on välja lülitatud, kuni lülitad selle sisse valiku _Setup > Security > SSHD_ kaudu, mis avab seadistuse osana pordi 22 (jõurünnete vastu kiirusepiiranguga). Lukustame isegi Dockeri juurdepääsu [ufw-docker](https://github.com/chaifeng/ufw-docker) seadistusega, et sinu konteinerid kogemata maailmale ei paljastuks.
3. *Archil on alati uusimad värskendused*: Arch, alusdistributsioon, millele Omarchy on ehitatud, on jooksev distributsioon. See tähendab, et iga turvanõrkus, mis avastatakse ja mõnes paketis parandatakse, on kiiresti installimiseks saadaval käsuga `omarchy-update`. Nii kasutad alati kõige uusimaid ja kõige turvalisemaid versioone kõigest.
4. *Omarchy haldab oma pakette ja peeglit*: Omarchy tugineb vaikimisi ainult Archi enda core/extra/multilib hoidlate pakettidele ja oma Omarchy Package Repository hoidlale. Saad tarkvara installida otse AUR-ist, kuid baasinstall seda ei tee — ainult mõned valikulised installid, nagu kolmandate osapoolte brauserid, võtavad pakette AUR-ist.
5. *Cloudflare kaitseb meid DDoS-i eest*: Omarchy levitamise infrastruktuur — ISO-d, Omarchy paketid, Archi peegel — on kaitstud Cloudflare'i võimsa DDoS-kilbi taga ja majutatud nende CDN-is. See tagab suurepärase kättesaadavuse.

## Paroolide muutmine

Krüpteeritud installil on sul kaks parooli: üks, mis avab ketta alglaadimisel, ja teine, millega sa sisse logid ja `sudo` õigusi kasutad. Seadistus teeb need samaks. Mõlemat saab muuta Omarchy menüüs valiku _Update > Password_ alt — esimest valikuga _Drive Encryption_, teist valikuga _User_. Ketta parooli muutmine küsib esmalt praegust parooli, nii et hoia see käepärast. Kui muutmine katkeb, käivita _Drive Encryption_ uuesti: see küsib parooli, mis ketta praegu avab, ja viib muudatuse lõpule.

## Kasutatud masina edasiandmine

Kui annad oma masina kellelegi teisele üle, ei pea sa seda uuesti installima. Käivita Omarchy menüüs _Setup > Reset Computer_, kirjuta kinnitamiseks `reset` ja taaskäivita. See kustutab iga kasutajakonto ja kõik, mis on kaustas `/home`, viskab ära kõik paketid ja süsteemimuudatused, mis oled pärast installimist teinud, ning puhastab masina identiteedi — võrguühendused, hostivõtmed ja kõik muu. Tagasi tuleb esimese alglaadimise seadistusviisard, valmis selleks, et uus omanik saaks sisestada oma nime, parooli ja krüpteerimisparooli.

See toimib, taastades baashetktõmmise, mille installer teeb, nii et see on saadaval ainult masinatel, mis on installitud Omarchy ISO-lt. Ja krüpteerimiseta kettal on lähtestamine kustutamine, mitte turvaline kustutus, nii et kui andmed olid tundlikud, tee selle asemel värske install.

## Paroolita sudo

Mõnikord tahad, et `sudo` lõpetaks küsimise, kõige sagedamini siis, kui AI agent teeb sinu eest pikalt süsteemitööd. _Setup > Security > Passwordless Sudo_ küsib, kui kauaks juurdepääsu lubada: **15 minutit**, **1 tund**, **1 päev** või **alaliselt**. Punane hoiatusikoon ilmub teiste menüüriba indikaatorite kõrvale, kuni juurdepääs on aktiivne. Klõpsa sellel või käivita käsk uuesti, et juurdepääs välja lülitada. Võid ka anda oma minutite arvu (1 kuni 1440) käsuga `omarchy-sudo-passwordless 30` või kasutada käsku `omarchy-sudo-passwordless permanent`.

Ajastatud juurdepääs aegub automaatselt, sealhulgas kohe pärast jätkamist peatamisest, mis ületas tähtaja. Arvuti taaskäivitamine lõpetab selle enneaegselt. Alaline juurdepääs säilib pärast taaskäivitusi ja jääb lubatuks, kuni selle keelad.

Omarchy seadete paketi värskendamine või eemaldamine lõpetab iga ajutise loa enne, kui selle aegumise tugi muutub. Kui käsk teatab autoriseerimis- või puhastusveast, lahenda see enne uue loa lubamise proovimist; viga ei tähenda, et paroolita juurdepääs oleks mitteaktiivne.

Ole selle osas selge pilguga: kuni see on sees, saab kõik, mis töötab sinu kasutajana, teha kõike root-kasutajana, ilma et küsitaks. See ongi kogu mõte ja see on ka kogu risk.

## Allkirjastamisvõtmed

Kõigi ISO allkirjade ja Omarchy repo pakettide avalik võti on `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([kontrolli saidil openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakett `omarchy/omarchy-keyring` sisaldab samuti seda ja seda kasutatakse võimalike värskenduste sujuvaks juurutamiseks.

Iga ISO väljalaske allkirja leiad, lisades selle URL-ile `.sig`, näiteks `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
