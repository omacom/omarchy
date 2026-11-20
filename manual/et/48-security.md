# Turvalisus

Omarchy suhtub turvalisusse äärmiselt tõsiselt. See on mõeldud operatsioonisüsteemina, mida saad kasutada _päris töö_ tegemiseks _päris maailmas_. Kus sülearvuti kaotamine ei saa viia turvahädaolukorrani. Nii et siin on, mida me teeme:

1. *Täielik ketta krüpteerimine on vaikimisi sees*: See on kõige olulisem samm sinu andmete füüsiliseks kaitsmiseks. Kui sinu arvuti läheb kaduma või varastatakse, on andmed täielikult krüpteeritud standardse LUKS-i (Linux Unified Key Setup) abil. Paigaldaja lubab sul sellest loobuda äraviskamismasinate puhul (vaata [Alustamine](02-getting-started.md)); ilma krüpteerimiseta paigaldusel seda kaitset ei ole ja igaüks, kelle käes on ketas, saab seda lugeda.
2. *Tulemüür on vaikimisi lubatud*: Kogu sissetulev liiklus on vaikimisi blokeeritud, mõne erandiga: port 53317 [LocalSend](https://localsend.org/) jaoks; DNS päringud arvuti enda resolverile Docker bridge aadressil (172.17.0.1), mida võetakse vastu privaatsetest aadressivahemikest, mille Docker oma konteineritele annab; ja multicast DNS (port 5353), mis laseb printeritel ja teistel sinu võrgus olevatel seadmetel üksteist leida ja teatab seal ka sinu arvuti nime. Lisaks neile säilitab tulemüür UFW standardsed load pingi, ruuterilt aadressi saamise (DHCP) ja UPnP avastamise jaoks. Isegi ssh on välja lülitatud, kuni lülitad selle sisse läbi _Setup > Security > SSHD_, mis avab seadistuse osana pordi 22 (toore jõu rünnete vastu piiratud kiirusega). Me piirame isegi Docker juurdepääsu, kasutades [ufw-docker](https://github.com/chaifeng/ufw-docker) seadistust, et vältida sinu konteinerite juhuslikku maailmale paljastamist.
3. *Archil on alati uusimad värskendused*: Arch, aluseks olev distro, millele Omarchy on ehitatud, on pidevalt uuenev distributsioon. See tähendab, et iga turvanõrkus, mis avastatakse ja mis tahes paketis parandatakse, on kiiresti paigaldamiseks saadaval, kasutades `omarchy-update`. Nii kasutad sa alati kõige uuemaid, kõige turvalisemaid versioone kõigest.
4. *Omarchy haldab oma pakette ja peeglit*: Omarchy tugineb vaikimisi ainult pakettidele Archi enda core/extra/multilib repositooriumidest ja oma Omarchy Package Repository repositooriumist. Sa saad paigaldada tarkvara otse AUR-ist, aga baaspaigaldus seda ei tee — ainult mõned valikulised paigaldused, nagu kolmandate osapoolte brauserid, tõmbavad AUR-ist.
5. *Cloudflare kaitseb meid DDoS-i eest*: Omarchy jaotustaristu — ISO-d, Omarchy paketid, Archi peegel — on kaitstud Cloudflare'i võimsa DDoS-kilbi taga ja majutatud nende CDN-is. See tagab suurepärase kättesaadavuse.

## Paroolide muutmine

Krüpteeritud paigaldusel on sul kaks parooli: üks, mis avab ketta alglaadimisel, ja teine, millega sa sisse logid ja `sudo`t kasutad. Seadistus teeb need samaks. Mõlemat saab muuta Omarchy menüüs _Update > Password_ alt — esimest _Drive Encryption_, teist _User_. Ketta parooli muutmine küsib kõigepealt praegust parooli, nii et hoia see käepärast. Kui muutmine katkeb, käivita _Drive Encryption_ uuesti: see küsib parooli, mis ketta praegu avab, ja viib muutmise lõpule.

## Juba kasutatud masina edasiandmine

Kui annad oma masina kellelegi teisele üle, ei pea sa seda uuesti paigaldama. Käivita Omarchy menüüs _Remove > Factory Reset_, kirjuta kinnitamiseks `reset` ja taaskäivita. See kustutab iga kasutajakonto ja kõik, mis on `/home` all, viskab ära kõik paketid ja süsteemimuudatused, mis sa pärast paigaldamist tegid, ja kustutab masina identiteedi — võrguühendused, host keys ja kõik. Mis üles tuleb, on esimesel alglaadimisel nähtav seadistusviisard, valmis selleks, et selle uus omanik sisestaks oma nime, parooli ja krüpteerimisparooli.

See töötab, taastades algtaseme hetktõmmise, mille paigaldaja teeb, nii et see on saadaval ainult masinatel, mis on paigaldatud Omarchy ISO-lt. Ja krüpteerimiseta kettal on lähtestamine kustutamine, mitte turvaline ülekirjutamine, nii et kui andmed olid tundlikud, tee selle asemel värske paigaldus.

## Paroolita sudo

Mõnikord tahad, et `sudo` lõpetaks küsimise, kõige sagedamini siis, kui AI agent teeb sinu eest pikka süsteemitööd. _Setup > Security > Passwordless Sudo_ küsib, kui kauaks juurdepääsu lubada: **15 minutit**, **1 tund**, **1 päev** või **Püsivalt**. Punane hoiatusikoon ilmub teiste menüüriba näidikute kõrvale, kuni juurdepääs on aktiivne. Klõpsa sellel või käivita käsk uuesti, et juurdepääs välja lülitada. Sa saad ka edasi anda oma minutite arvu (1 kuni 1440) käsuga `omarchy-sudo-passwordless 30` või kasutada käsku `omarchy-sudo-passwordless permanent`.

Ajastatud juurdepääs aegub automaatselt, sealhulgas kohe pärast jätkamist suspendist, mis ületas tähtaja. Arvuti taaskäivitamine lõpetab selle varakult. Püsiv juurdepääs säilib taaskäivituste korral ja jääb lubatuks, kuni sa selle välja lülitad.

Omarchy seadete paketi värskendamine või eemaldamine lõpetab iga ajutise loa enne, kui selle aegumistoetus muutub. Kui käsk teatab autoriseerimis- või puhastusveast, lahenda see enne, kui proovid teist luba lubada; viga ei tähenda, et paroolita juurdepääs oleks mitteaktiivne.

Ole selle osas selgepilguline: kuni see on sees, saab kõik, mis töötab sinu kasutajana, teha kõike root'ina, ilma et küsitaks. See on kogu mõte ja see on ka kogu risk.

## Allkirjastamisvõtmed

Kõigi ISO allkirjade ja Omarchy repo pakettide avalik võti on `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([kontrolli openpgp.org-is](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakett `omarchy/omarchy-keyring` sisaldab seda samuti ja seda kasutatakse võimalike värskenduste sujuvaks levitamiseks.

Iga ISO väljalaske allkirja leiad, lisades selle URL-ile `.sig`, nagu `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
