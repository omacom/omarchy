# Turvalisus

Omarchy suhtub turvalisusse ülimalt tõsiselt. See on mõeldud operatsioonisüsteemiks, mida saad kasutada _päris töö_ tegemiseks _päris maailmas_. Kus sülearvuti kaotamine ei saa viia turvahädaolukorrani. Nii et siin on, mida me teeme:

1. *Täisdiski krüptimine on vaikimisi sees*: see on kõige olulisem samm sinu andmete füüsiliseks kaitsmiseks. Kui sinu arvuti kaob või varastatakse, on andmed täielikult krüptitud standardse LUKS-i (Linux Unified Key Setup) abil. Installija võimaldab sul sellest loobuda äravisatavate masinate puhul (vaata [Alustamine](02-getting-started.md)); krüptimiseta installil seda kaitset ei ole ja igaüks, kelle käes draiv on, saab seda lugeda.
2. *Tulemüür on vaikimisi lubatud*: kogu sissetulev liiklus on vaikimisi blokeeritud, väheste eranditega: port 53317 [LocalSend](https://localsend.org/) jaoks; DNS-päringud arvuti enda nimelahendajale Docker bridge'i aadressil (172.17.0.1), mida võetakse vastu privaatsetest aadressivahemikest, mille Docker oma konteineritele annab; ja multisaate-DNS (port 5353), mis võimaldab printeritel ja teistel sinu võrgu seadmetel üksteist leida ning teatab seal ka sinu arvuti nime. Lisaks neile säilitab tulemüür UFW standardsed load pingimiseks, ruuterilt aadressi saamiseks (DHCP) ja UPnP avastamiseks. Isegi ssh on välja lülitatud, kuni lülitad selle sisse valikuga _Setup > Security > SSHD_, mis avab seadistuse osana pordi 22 (toore jõu rünnete vastu kiiruspiiranguga). Me lukustame isegi juurdepääsu Dockerile [ufw-docker](https://github.com/chaifeng/ufw-docker) seadistuse abil, et sinu konteinerid kogemata maailmale avatuks ei muutuks.
3. *Archil on alati uusimad värskendused*: Arch, alusdistributsioon, millele Omarchy on ehitatud, on pidevalt uuenev distributsioon. See tähendab, et iga avastatud ja parandatud turvanõrkus mis tahes paketis on käsuga `omarchy-update` kiiresti installimiseks saadaval. Nii kasutad alati kõige uuemaid ja turvalisemaid versioone kõigest.
4. *Omarchy hooldab oma pakette ja peeglit*: Omarchy tugineb vaikimisi ainult pakettidele Archi enda core/extra/multilib hoidlatest ja oma Omarchy Package Repository hoidlast. Sa saad tarkvara installida otse AUR-ist, kuid põhinstall seda ei tee — ainult mõned valikulised installid, näiteks kolmandate osapoolte brauserid, võtavad AUR-ist.
5. *Cloudflare kaitseb meid DDoS-i eest*: Omarchy levitaristu — ISO-d, Omarchy paketid, Archi peegel — on kaitstud Cloudflare'i tugeva DDoS-kilbi taga ja majutatud nende CDN-is. See pakub suurepärast kättesaadavust.

## Paroolide muutmine

Krüptitud installil on sul kaks parooli: üks, mis avab draivi käivitamisel, ja üks, millega logid sisse ja kasutad käsku `sudo`. Seadistamisel tehakse need samaks. Mõlemat saab muuta Omarchy menüüs valiku _Update > Password_ all — esimest valikuga _Drive Encryption_, teist valikuga _User_. Draivi parooli muutmine küsib esmalt praegust parooli, nii et hoia see käepärast. Kui muutmine katkeb, käivita _Drive Encryption_ uuesti: see küsib parooli, mis draivi praegu avab, ja viib muutmise lõpule.

## Juba kasutatud masina edasiandmine

Kui annad oma masina kellelegi teisele üle, ei pea sa seda uuesti installima. Käivita Omarchy menüüs _Setup > Reset Computer_, kirjuta kinnitamiseks `reset` ja taaskäivita arvuti. See pühib ära iga kasutajakonto ja kõik, mis asub kaustas `/home`, viskab ära kõik paketid ja süsteemimuudatused, mis oled pärast installimist teinud, ning kustutab masina identiteedi — võrguühendused, hostivõtmed ja kõik muu. Pärast seda käivitub esimese käivitamise seadistusviisard, valmis selleks, et uus omanik sisestaks oma nime, parooli ja krüptimisparooli.

See toimib installija tehtud lähteoleku hetktõmmise taastamisega, nii et see on saadaval ainult masinatel, mis on installitud Omarchy ISO abil. Ja krüptimiseta draivil on lähtestamine kustutamine, mitte turvaline ülekirjutamine, nii et kui andmed olid tundlikud, tee selle asemel uus install.

## Paroolita sudo

Mõnikord tahad, et `sudo` lõpetaks küsimise, kõige sagedamini siis, kui tehisintellekti agent teeb sinu eest pikka süsteemitööd. _Setup > Security > Passwordless Sudo_ küsib, kui kauaks juurdepääsu lubada: **15 minutit**, **1 Hour**, **1 Day** või **Permanently**. Punane hoiatusikoon ilmub teiste menüüriba indikaatorite kõrvale, kuni juurdepääs on aktiivne. Klõpsa sellel või käivita käsk uuesti, et juurdepääs välja lülitada. Samuti saad anda oma minutite arvu (1 kuni 1440) käsuga `omarchy-sudo-passwordless 30` või kasutada käsku `omarchy-sudo-passwordless permanent`.

Ajastatud juurdepääs aegub automaatselt, sealhulgas kohe pärast unerežiimist naasmist, kui tähtaeg selle ajal möödus. Arvuti taaskäivitamine lõpetab selle enneaegselt. Püsiv juurdepääs säilib taaskäivituste järel ja jääb lubatuks, kuni selle keelad.

Omarchy sätete paketi värskendamine või eemaldamine lõpetab iga ajutise loa enne, kui selle aegumise tugi muutub. Kui käsk teatab autoriseerimis- või puhastusveast, lahenda see enne uue loa lubamist; viga ei tähenda, et paroolita juurdepääs oleks mitteaktiivne.

Vaata sellele kainelt otsa: kuni see on sees, saab kõik, mis töötab sinu kasutajana, teha root'ina kõike ilma küsimata. See ongi kogu mõte ja see on ka kogu risk.

## Allkirjastamisvõtmed

Kõigi ISO allkirjade ja Omarchy repo paketi avalik võti on `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([kontrolli saidil openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakett `omarchy/omarchy-keyring` sisaldab seda samuti ja seda kasutatakse võimalike värskenduste sujuvaks juurutamiseks.

Iga ISO väljalaske allkirja leiad, kui lisad selle URL-ile `.sig`, näiteks `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
