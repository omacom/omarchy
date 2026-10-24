# Võrk

Võrku haldab Omarchys NetworkManager ja sa juhid seda [menüüriba](05-the-top-bar.md) võrguikoonilt või klahvikombinatsiooniga `Super + Ctrl + W`.

See paneel otsib Wi-Fi võrke, näitab signaalitugevust ja loob ühenduse. Ethernet ei vaja üldse midagi — ühenda kaabel külge ja see töötab. Kui eelistad terminali, annab `nmtui` sulle samad valikud ja olemas on ka käsurühm `omarchy network`.

## Wi-Fi jagamine

Selle asemel, et pikka parooli valjusti ette lugeda, käivita Wi-Fis olles _Seaded > Võrk > QR-kood_. See kuvab ekraanile QR-koodi, mida iga telefoni kaamera saab võrguga liitumiseks skannida. See on üks neist asjadest, mida hakkad kasutama sagedamini, kui arvad, kui tead, et see olemas on.

Kui vajad parooli ennast, prindib `omarchy network password <liides>` selle välja.

## DNS

Omarchy kasutab seda DNS-i, mida sinu võrk DHCP kaudu annab. Sa saad selle kogu masina ulatuses üle kirjutada jaotises _Seaded > Võrk > DNS_, kus Cloudflare ja Google on ühe klõpsu kaugusel. Vali _Kohandatud_, et sisestada oma serverid.

Terminalist prindib `omarchy dns` praeguse teenusepakkuja ja `omarchy dns Cloudflare` seab selle.

## Wi-Fi sagedusriba fikseerimine

Kui sinu ruuter paneb 2,4GHz, 5GHz ja 6GHz ühe ja sama võrgunime alla, klammerdub sülearvuti vahel aeglase oma külge. `omarchy network band` näitab, millisel sagedusribal sa oled, ja `omarchy network band 5` fikseerib selle. Kasuta valikut `auto`, et lasta sel uuesti ise valida.

See fikseerib sagedusriba, mitte kindlat pääsupunkti, nii et rändad pääsupunktide vahel edasi tavapäraselt.

## Kui kiire see on?

_Käivita > Kiirustest > Võrgukiiruse test_ mõõdab sinu tegelikku üles- ja allalaadimiskiirust kahe näidikuga. Terminalist on see `omarchy network speedtest down` või `up`. (Samas menüüs selle kõrval on ka kettakiiruse test, kui testid teist kitsaskohta.)

## Tulemüür

Tulemüür on vaikimisi sisse lülitatud ja blokeerib kogu sissetuleva liikluse ühe erandiga: port 53317, et [LocalSend](22-guis.md) töötaks kohe karbist võttes.

SSH on välja lülitatud, kuni lülitad selle sisse jaotises _Seaded > Turvalisus > SSHD_, mis käivitab deemoni, avab pordi 22 jõuvõtte vastu kiiruspiiranguga ja volitab võtme. Ka Docker on lukustatud, et konteinerid ei saaks end kogemata maailmale paljastada. Kogu lugu leiad jaotisest [turvalisus](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) on silmvõrk-VPN, mis muudab kõigi su arvutite ja serverite interneti kaudu kättesaamise lihtsaks ja turvaliseks. Paigalda see jaotises _Paigalda > Teenus > Tailscale_.

See annab sulle ribale Tailscale'i paneeli, mis ühendab tailneti külge ja lahti, vahetab kontosid ja valib väljundsõlme — loendis on nii sinu enda masinad kui ka Mullvadi piirkonnad. See sirvib ka sinu masinaid ja just seal elab Taildrop: vali masin ja vajuta `s`, et sellele faile saata, või `c`, `n` ja `d`, et kopeerida selle IP, nimi või täielik DNS-nimi. Terminali vaste on `omarchy tailscale send <masin> [fail...]` ja sulle saadetud failid maanduvad automaatselt kausta `~/Downloads`. Saabumisest teavitav teavitus jääb ootele, kuni selle avad või sellest loobud, nii et fail, mis saabus ajal, mil masina juures polnud, on ikka alles, kui tagasi jõuad.

Paigaldamine lisab ka veebirakenduse Tailscale'i halduskonsooli jaoks.

## Kui see lakkab töötamast

Enne taaskäivitamist proovi solvavat tükki eraldi taaskäivitada. Jaotises _Uuenda > Riistvara_ on Wi-Fi, Bluetooth, Heli ja Puuteplaat ning ühe neist uuesti laadimine lahendab enamiku olukordadest, kus miski „viis minutit tagasi veel töötas“. Vaata [tõrkeotsingut](45-troubleshooting.md).
