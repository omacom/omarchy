# Turvalisus

Omarchy võtab turvalisust äärmiselt tõsiselt. See on mõeldud operatsioonisüsteemina, mida saad kasutada _Päris Töö_ tegemiseks _Päris Maailmas_. Kus sülearvuti kaotamine ei saa viia turvaintsidendini. Nii et siin on, mida me teeme:

1. *Täisketta krüpteerimine on kohustuslik*: see on kõige olulisem samm sinu andmete füüsilise kaitse tagamiseks. Kui sinu arvuti kaob või varastatakse, on andmed täielikult krüpteeritud tavalist LUKS-i (Linux Unified Key Setup) kasutades.
2. *Tulemüür on vaikimisi lubatud*: kogu sissetulev liiklus on vaikimisi blokeeritud, välja arvatud port 53317 [LocalSendi](https://localsend.org/) jaoks. Isegi ssh on välja lülitatud, kuni lülitad selle sisse jaotise _Seaded > Turvalisus > SSHD_ kaudu, mis avab seadistuse osana pordi 22 (jõuvõtte vastu kiiruspiiranguga). Me lukustame isegi Dockeri juurdepääsu, kasutades [ufw-docker](https://github.com/chaifeng/ufw-docker) seadistust, et vältida sinu konteinerite kogemata maailmale paljastamist.
3. *Archil on alati uusimad värskendused*: Arch, aluseks olev distributsioon, millele Omarchy on ehitatud, on veerev distributsioon. See tähendab, et iga turvanõrkus, mis mis tahes paketis avastatakse ja paigatakse, on käsu `omarchy-update` abil kiiresti paigaldamiseks saadaval. Nii käivitad alati kõige uuemaid ja turvalisemaid versioone kõigest.
4. *Omarchy hooldab oma pakette ja peeglit*: Omarchy tugineb vaikimisi ainult Archi enda core/extra/multilib repositooriumide ja oma Omarchy pakettide repositooriumi pakettidele. Saad tarkvara paigaldada otse AUR-ist, aga baaspaigaldus seda ei tee — AUR-ist tõmbavad ainult mõned valikulised paigaldused, nagu kolmandate osapoolte brauserid.
5. *Cloudflare kaitseb meid DDoS-i eest*: kogu Omarchy levitamise taristu — ISO-d, Omarchy paketid, Archi peegel — on kaitstud Cloudflare'i tohutu DDoS-kilbi taga ja majutatud nende CDN-il. See tagab suurepärase kättesaadavuse.

## Paroolide muutmine

Krüpteeritud paigaldusel on sul kaks parooli: üks, mis avab ketta alglaadimisel, ja üks, millega sisse logid ja `sudo`'t kasutad. Seadistus teeb need samaks. Mõlemat saab muuta Omarchy menüüs jaotise _Uuenda > Parool_ all — _Ketta krüpteerimine_ esimese ja _Kasutaja_ teise jaoks. Ketta parooli muutmine küsib esmalt praegust, nii et hoia see käepärast. Kui muutmine katkestatakse, käivita _Ketta krüpteerimine_ uuesti: see küsib parooli, mis ketta praegu avab, ja viib muudatuse lõpule.

## Kasutatud masina edasiandmine

Kui annad oma masina kellelegi teisele üle, ei pea sa seda uuesti paigaldama. Käivita Omarchy menüüs _Seaded > Lähtesta arvuti_, kirjuta kinnituseks `reset` ja taaskäivita. See pühib iga kasutajakonto ja kõik kaustas `/home`, viskab minema kõik paketid ja süsteemimuudatused, mille alates paigaldamisest tegid, ja kustutab masina identiteedi — võrguühendused, hostivõtmed ja kõik. See, mis üles tuleb, on esimese alglaadimise seadistusviisard, valmis uuele omanikule oma nime, parooli ja krüpteerimisparooli sisestamiseks.

See töötab paigaldaja tehtud baashetktõmmise taastamisega, nii et see on saadaval ainult masinatel, mis on paigaldatud Omarchy ISO-lt. Ja krüpteerimata kettal on lähtestamine kustutamine, mitte turvaline pühkimine, nii et kui andmed olid tundlikud, tee selle asemel värske paigaldus.

## Paroolita sudo

Vahel tahad, et `sudo` lõpetaks küsimise, kõige sagedamini siis, kui tehisintellekti agent teeb sinu eest pika jada süsteemitööd. _Seaded > Turvalisus > Paroolita Sudo_ küsib, kui kauaks juurdepääsu lubada: **15 minutit**, **1 tund**, **1 päev** või **Alaliselt**. Punane hoiatusikoon ilmub teiste menüüriba näidikute kõrvale, kuni juurdepääs on aktiivne. Klõpsa sellel või käivita käsk uuesti, et juurdepääs välja lülitada. Saad anda ka oma minutite arvu (1 kuni 1440) käsuga `omarchy-sudo-passwordless 30` või kasutada käsku `omarchy-sudo-passwordless permanent`.

Ajastatud juurdepääs aegub automaatselt, sealhulgas kohe pärast tähtaja ületanud uinakust jätkamist. Arvuti taaskäivitamine lõpetab selle varakult. Alaline juurdepääs elab taaskäivitused üle ja jääb lubatuks, kuni selle keeled.

Omarchy seadistuste paketi värskendamine või eemaldamine lõpetab iga ajutise loa enne selle aegumistoetuse muutumist. Kui käsk teatab autoriseerimis- või puhastusveast, lahenda see enne teise loa lubamist; viga ei tähenda, et paroolita juurdepääs oleks mitteaktiivne.

Ole selle suhtes selge pilguga: kuni see on sees, saab kõik, mis sinu kasutajana töötab, teha root'ina mida tahes ilma küsimata. See ongi kogu mõte ja see on ka kogu risk.

## Allkirjavõtmed

Kõikide ISO allkirjade ja Omarchy repositooriumi pakettide avalik võti on `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([kinnita saidil openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakett `omarchy/omarchy-keyring` sisaldab seda samuti ja seda kasutatakse võimalike värskenduste sujuvaks juurutamiseks.

Iga ISO väljalaske allkirja leiad, lisades URL-ile .sig. Nagu https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
