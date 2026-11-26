# Turvalisus

Omarchy suhtub turvalisusse äärmiselt tõsiselt. See on mõeldud operatsioonisüsteemina, millega saad teha _päris tööd_ _pärismaailmas_. Kus sülearvuti kaotamine ei saa viia turvalisuse hädaolukorrani. Nii et siin on, mida me teeme:

1. *Kogu ketta krüpteerimine on vaikimisi sisse lülitatud*: See on kõige olulisem samm sinu andmete füüsiliseks kaitsmiseks. Kui sinu arvuti läheb kaotsi või varastatakse, on andmed täielikult krüpteeritud standardse LUKS-i (Linux Unified Key Setup) abil. Installer lubab sul sellest loobuda äraviskamismasinate puhul (vaata [Alustamine](02-getting-started.md)); krüpteerimiseta installil seda kaitset ei ole ja igaüks, kelle käes on ketas, saab seda lugeda.
2. *Tulemüür on vaikimisi lubatud*: Kogu sissetulev liiklus on vaikimisi blokeeritud, mõne erandiga: port 53317 [LocalSend](https://localsend.org/) jaoks; DNS-päringud arvuti enda resolverile Docker bridge'i aadressil (172.17.0.1), mida võetakse vastu privaatsetest aadressivahemikest, mille Docker oma konteineritele annab; ja multicast DNS (port 5353), mis lubab printeritel ja muudel sinu võrgus olevatel seadmetel üksteist leida ning teatab seal ka sinu arvuti nime. Lisaks neile säilitab tulemüür UFW standardsed load pingi, ruuterilt aadressi saamise (DHCP) ja UPnP avastamise jaoks. Isegi ssh on välja lülitatud, kuni lülitad selle sisse menüüst _Setup > Security > SSHD_, mis autoriseerib sinu SSH-võtme, lülitab parooliga sisselogimised välja ja avab alles seejärel pordi 22 (kiirusepiiranguga jõurünnete vastu). Lukustame isegi Docker juurdepääsu [ufw-docker](https://github.com/chaifeng/ufw-docker) seadistuse abil, et vältida sinu konteinerite kogemata maailmale avatuks sattumist.
3. *Archil on alati uusimad värskendused*: Arch, selle aluseks olev distro, millele Omarchy on ehitatud, on pidevalt uuenev distributsioon. See tähendab, et iga turvanõrkus, mis avastatakse ja mõnes paketis parandatakse, on kiiresti installimiseks saadaval käsuga `omarchy-update`. Nii kasutad alati kõige uuemaid ja turvalisemaid versioone kõigest.
4. *Omarchy hooldab oma pakette ja peeglit*: Omarchy tugineb vaikimisi ainult pakettidele Archi enda core/extra/multilib repositooriumidest (ARM-masinate puhul Arch Linux ARM-i omadest, lisaks Apple Siliconi puhul Asahi ALARM) ja oma Omarchy Package Repository'st. Saad tarkvara installida otse AUR-ist, kuid baasinstall seda ei tee — ainult mõned valikulised installid, näiteks kolmandate osapoolte brauserid, võtavad AUR-ist.
5. *Cloudflare kaitseb meid DDoS-i eest*: Omarchy levitamise taristu — ISO-d, Omarchy paketid, Archi peegel — on kaitstud Cloudflare'i hirmuäratava DDoS-kaitse taga ja majutatud nende CDN-is. See tagab suurepärase kättesaadavuse.

## Paroolide muutmine

Krüpteeritud installil on sul kaks parooli: üks, mis avab ketta käivitamisel, ja teine, millega logid sisse ja `sudo`-t kasutad. Seadistus teeb need samaks. Omarchy menüüs _Update > Password_ muudab mõlemat korraga, nii et need jäävad samaks: see küsib praegust kettaparooli, seejärel uut parooli, muudab ketta oma ja määrab seejärel sinu sisselogimisparooli sellega ühtima. Ilma kettakrüpteerimiseta muudab see ainult sinu sisselogimisparooli. Kui muutmine katkeb, käivita _Update > Password_ uuesti: see küsib parooli, mis avab ketta praegu, viib muudatuse lõpule ja määrab sinu sisselogimisparooli selleks. Teise krüpteeritud ketta parooli muutmiseks käivita terminalis `omarchy-drive-password`.

## Kasutatud masina edasiandmine

Kui annad oma masina kellelegi teisele üle, ei pea sa seda uuesti installima. Käivita Omarchy menüüs _Remove > Factory Reset_, kirjuta kinnitamiseks `reset`, sisesta küsimisel oma ketta krüpteerimisparool ja taaskäivita. See kustutab iga kasutajakonto ja kõik, mis on `/home` all, viskab ära kõik paketid ja süsteemimuudatused, mille oled alates installimisest teinud, ning kustutab masina identiteedi — võrguühendused, hostivõtmed ja kõik. Tagasi tuleb esimese käivituse seadistusviisard, mis on valmis selleks, et uus omanik sisestaks oma nime, parooli ja krüpteerimisparooli.

See toimib nii, et taastab installeri tehtud algtaseme hetktõmmise, nii et see on saadaval ainult masinatel, mis on installitud Omarchy ISO-st. Ja krüpteerimiseta kettal on lähtestamine kustutamine, mitte turvaline kustutamine, nii et kui andmed olid tundlikud, tee selle asemel värske install.

## Paroolita sudo

Mõnikord tahad, et `sudo` lõpetaks küsimise, kõige sagedamini siis, kui AI-agent teeb sinu eest pikka süsteemitööd. _Setup > Security > Passwordless Sudo_ küsib, kui kauaks juurdepääsu lubada: **15 minutit**, **1 tund**, **1 päev** või **alaliselt**. Punane hoiatusikoon ilmub teiste menüüriba indikaatorite kõrvale, kuni juurdepääs on aktiivne. Klõpsa seda või käivita käsk uuesti, et juurdepääs välja lülitada. Võid ka oma minutite arvu (1 kuni 1440) edastada käsuga `omarchy-sudo-passwordless 30` või kasutada käsku `omarchy-sudo-passwordless permanent`.

Ajastatud juurdepääs aegub automaatselt, sealhulgas kohe pärast jätkamist peatamisest, mis ületas tähtaja. Arvuti taaskäivitamine lõpetab selle varakult. Alaline juurdepääs säilib taaskäivituste korral ja jääb lubatuks, kuni selle keelad.

Omarchy seadete paketi värskendamine või eemaldamine lõpetab iga ajutise loa enne, kui selle aegumise tugi muutub. Kui käsk teatab autoriseerimis- või puhastusveast, lahenda see enne, kui proovid lubada teist luba; viga ei tähenda, et paroolita juurdepääs ei oleks aktiivne.

Ole selle osas selgepilguline: kuni see on sees, saab kõik, mis töötab sinu kasutajana, teha root'ina kõike ilma küsimata. See ongi kogu mõte ja see on ka kogu risk.

## Allkirjastamisvõtmed

Kõigi ISO allkirjade ja Omarchy repo paketi avalik võti on `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([kontrolli openpgp.org-is](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakett `omarchy/omarchy-keyring` sisaldab seda samuti ja seda kasutatakse võimalike värskenduste sujuvaks levitamiseks.

Iga ISO väljalaske allkirja leiad, lisades selle URL-ile `.sig`, näiteks `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
