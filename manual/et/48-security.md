# Turvalisus

Omarchy võtab turvalisust äärmiselt tõsiselt. See on operatsioonisüsteem, millega saad teha _Päris Tööd_ _Päris Maailmas_. Kus sülearvuti kaotamine ei saa viia turvahädaolukorrani. Siin on, mida me teeme:

1. *Kogu ketta krüptimine on vaikimisi sisse lülitatud*: See on kõige olulisem samm sinu andmete füüsiliseks kaitsmiseks. Kui sinu arvuti läheb kaduma või varastatakse, on andmed täielikult krüptitud standardse LUKS-iga (Linux Unified Key Setup). Paigaldaja laseb sul ühekordsetel masinatel sellest loobuda (vaata [Alustamine](02-getting-started.md)); ilma krüptimiseta paigaldusel puudub see kaitse täielikult ja igaüks, kelle käes ketas on, saab seda lugeda.
2. *Tulemüür on vaikimisi sisse lülitatud*: Kogu sissetulev liiklus on vaikimisi blokeeritud, välja arvatud mõned erandid: port 53317 [LocalSend](https://localsend.org/) jaoks; DNS päringud arvuti enda resolverile Docker bridge aadressil (172.17.0.1), mida võetakse vastu privaatsetest aadressivahemikest, mille Docker oma konteineritele annab; ja multicast DNS (port 5353), mis laseb printeritel ja muudel seadmetel sinu võrgus üksteist leida ja teatab seal ka sinu arvuti nime. Nendele lisaks säilitab tulemüür UFW standardseid lubasid pingi, ruuterilt aadressi saamise (DHCP) ja UPnP avastamise jaoks. Isegi ssh on välja lülitatud, kuni lülitad selle sisse menüüst _Setup > Security > SSHD_, mis autoriseerib sinu SSH võtme, lülitab parooliga sisselogimised välja ja alles seejärel avab pordi 22 (kiirust piiratakse brute force vastu). Me lukustame isegi Docker juurdepääsu [ufw-docker](https://github.com/chaifeng/ufw-docker) seadistuse abil, et sinu konteinerid ei satuks kogemata maailmale avatuks.
3. *Archil on alati uusimad uuendused*: Arch, alusdistro, millele Omarchy on ehitatud, on pidevalt uuenev distributsioon. See tähendab, et iga turvanõrkus, mis avastatakse ja mis tahes paketis parandatakse, on kiiresti paigaldamiseks saadaval käsuga `omarchy-update`. Nii kasutad alati kõige uuemaid ja kõige turvalisemaid versioone kõigest.
4. *Omarchy haldab oma pakette ja peeglit*: Omarchy tugineb vaikimisi ainult pakettidele Archi enda core/extra/multilib repositooriumidest (ARM masinatel Arch Linux ARM-i omadest, lisaks Apple Siliconil Asahi ALARM) ja oma Omarchy Package Repository-st. Sa saad tarkvara paigaldada otse AUR-ist, aga baaspaigaldus seda ei tee — ainult mõned valikulised paigaldused, näiteks kolmandate osapoolte brauserid, võtavad AUR-ist.
5. *Cloudflare kaitseb meid DDoS-i eest*: Omarchy levitamise taristu — ISO-d, Omarchy paketid, Archi peegel — on kaitstud Cloudflare'i võimsa DDoS kilbi taga ja majutatud nende CDN-is. See tagab suurepärase kättesaadavuse.

## Paroolide muutmine

Krüptitud paigaldusel on sul kaks parooli: üks, mis avab ketta alglaadimisel, ja teine, millega logid sisse ja kasutad `sudo`-t. Setup teeb need samaks. Mõlemat saab muuta Omarchy menüüst _Update > Password_ alt — esimest _Drive Encryption_ alt, teist _User_ alt. Ketta parooli muutmine küsib kõigepealt praegust parooli, nii et hoia see käepärast. Kui muutmine katkeb, käivita _Drive Encryption_ uuesti: see küsib parooli, mis avab ketta praegu, ja viib muutmise lõpule.

## Juba kasutatud masina edasiandmine

Kui annad oma masina kellelegi teisele üle, ei pea sa seda uuesti paigaldama. Käivita Omarchy menüüst _Remove > Factory Reset_, tippige kinnitamiseks `reset`, sisesta küsimisel oma ketta krüptimise parool ja taaskäivita. See kustutab iga kasutajakonto ja kõik, mis on `/home`-is, viskab ära kõik paketid ja süsteemimuudatused, mille oled pärast paigaldamist teinud, ning kustutab masina identiteedi — võrguühendused, host keys ja kõik. Üles tuleb esimese alglaadimise seadistusviisard, valmis selleks, et uus omanik sisestaks oma nime, parooli ja krüptimise parooli.

See toimib nii, et taastab algtaseme snapshoti, mille paigaldaja teeb, nii et see on saadaval ainult masinatel, mis on paigaldatud Omarchy ISO-lt. Ja ilma krüptimiseta kettal on lähtestamine kustutamine, mitte turvaline ülekirjutamine, nii et kui andmed olid tundlikud, tee selle asemel värske paigaldus.

## Paroolita sudo

Mõnikord tahad, et `sudo` lõpetaks küsimise, kõige sagedamini siis, kui AI agent teeb sinu eest pikka süsteemitööd. _Setup > Security > Passwordless Sudo_ küsib, kui kauaks juurdepääsu lubada: **15 minutit**, **1 Hour**, **1 Day** või **Permanently**. Punane hoiatusikoon ilmub teiste menüüriba indikaatorite kõrvale, kuni juurdepääs on aktiivne. Klõpsa sellel või käivita käsk uuesti, et juurdepääs välja lülitada. Sa saad anda ka oma minutite arvu (1 kuni 1440) käsuga `omarchy-sudo-passwordless 30` või kasutada käsku `omarchy-sudo-passwordless permanent`.

Ajastatud juurdepääs aegub automaatselt, sealhulgas kohe pärast jätkamist suspendist, mis ületas tähtaja. Arvuti taaskäivitamine lõpetab selle varem. Püsiv juurdepääs jääb taaskäivituste järel alles ja püsib sisse lülitatuna, kuni selle välja lülitad.

Omarchy settings paketi uuendamine või eemaldamine lõpetab iga ajutise loa enne, kui selle aegumise tugi muutub. Kui käsk teatab autoriseerimise või puhastamise veast, lahenda see enne, kui proovid lubada teist luba; viga ei tähenda, et paroolita juurdepääs oleks passiivne.

Ole selle puhul selgepilguline: kuni see on sees, saab kõik, mis töötab sinu kasutajana, teha root-ina kõike, ilma et küsitaks. See ongi kogu mõte ja see on ka kogu risk.

## Allkirjastamisvõtmed

Kõigi ISO allkirjade ja Omarchy repo paketi avalik võti on `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([kontrolli openpgp.org-is](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakett `omarchy/omarchy-keyring` sisaldab seda samuti ja seda kasutatakse võimalike uuenduste sujuvaks levitamiseks.

Iga ISO väljalaske allkirja leiad, kui lisad selle URL-ile `.sig`, näiteks `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
