# Võrk

Omarchys tegeleb võrguga NetworkManager ja seda juhid [ülemise riba](05-the-top-bar.md) võrguikoonilt või klahvidega `Super + Ctrl + N`.

See paneel otsib Wi-Fi võrke, näitab signaali tugevust ja loob ühenduse. Ethernet ei vaja üldse midagi — ühenda kaabel ja see töötab. Kui eelistad terminalis püsida, annab `nmtui` sulle samad juhtnupud ja olemas on ka käsurühm `omarchy network`.

## Wi-Fi jagamine

Selle asemel, et pikka parooli valjusti ette lugeda, käivita Wi-Fi-s olles _Seaded > Võrk > QR-kood_. See paneb ekraanile QR-koodi, mida iga telefoni kaamera saab liitumiseks skannida. See on üks neist asjadest, mida hakkad kasutama rohkem, kui arvad, kui tead, et see on olemas.

Kui vajad parooli ennast, prindib `omarchy network password <interface>` selle välja.

## DNS

Omarchy kasutab seda DNS-i, mille sinu võrk DHCP kaudu kätte annab. Saad selle kogu masina jaoks alistada menüüs _Seaded > Võrk > DNS_, kus Cloudflare ja Google on ühe klõpsu kaugusel. Vali _Kohandatud_, et sisestada oma serverid.

Terminalist prindib `omarchy dns` praeguse pakkuja ja `omarchy dns Cloudflare` määrab selle.

## Wi-Fi sagedusriba fikseerimine

Kui sinu ruuter paneb 2.4GHz, 5GHz ja 6GHz sama võrgunime alla, klammerdub sülearvuti mõnikord aeglase külge. `omarchy network band` näitab, millisel ribal oled, ja `omarchy network band 5` fikseerib selle. Kasuta `auto`, et lasta sellel uuesti ise valida.

See fikseerib riba, mitte konkreetse pääsupunkti, nii et liigud AP-de vahel endiselt tavapäraselt.

## Kui kiire see on?

_Käivita > Kiirustest > Võrgu kiirustest_ mõõdab sinu tegelikku üles- ja allalaadimiskiirust paari näidikuga. Terminalist on see `omarchy network speedtest down` või `up`. (Samas menüüs on selle kõrval ka ketta kiirustest, kui testid teist pudelikaela.)

## Tulemüür

Tulemüür on vaikimisi sees ja blokeerib kogu sissetuleva liikluse ühte erandiga: port 53317, et [LocalSend](22-guis.md) töötaks kohe karbist võttes.

SSH on väljas, kuni lülitad selle sisse menüüs _Seaded > Turvalisus > SSHD_, mis käivitab deemoni, avab toore jõu rünnete vastu kiirusepiiranguga pordi 22 ja autoriseerib võtme. Docker on samuti lukustatud, nii et konteinerid ei saa end kogemata maailmale paljastada. Kogu lugu vaata jaotisest [turvalisus](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) on mesh VPN, mis muudab kõigi sinu arvutite ja serveriteni interneti kaudu jõudmise lihtsaks ja turvaliseks. Installi see menüüst _Installi > Teenus > Tailscale_.

See annab sulle ribale Tailscale'i paneeli, mis ühendab tailnetiga ja katkestab sellega ühenduse, vahetab kontosid ja valib väljundssõlme — loendis kuvatakse nii sinu enda masinad kui ka Mullvadi piirkonnad. See sirbib ka sinu masinaid ja seal elabki Taildrop: vali masin ja vajuta failide saatmiseks `s` või selle IP, nime või täieliku DNS-nime kopeerimiseks `c`, `n` ja `d`. Terminali vaste on `omarchy tailscale send <machine> [file...]` ja sulle saadetud failid maanduvad automaatselt kausta `~/Downloads`. Saabumist teatav teavitus ootab, kuni klõpsad selle lahti või loobud sellest, nii et fail, mis ilmub ajal, kui oled masinast eemal, on tagasi tulles endiselt vastamist ootamas.

Selle installimine lisab ka veebirakenduse Tailscale'i halduskonsooli jaoks.

## Kui see lakkab töötamast

Enne taaskäivitamist proovi häiriv osa eraldi taaskäivitada. Menüüs _Uuenda > Riistvara_ on Wi-Fi, Bluetooth, heli ja puuteplaat ning ühe neist uuesti laadimine lahendab enamiku „see töötas viis minutit tagasi“ olukordadest. Vaata [tõrkeotsing](45-troubleshooting.md).
