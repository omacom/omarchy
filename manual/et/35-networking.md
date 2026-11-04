# Võrk

Omarchy võrku haldab NetworkManager ja sa juhid seda [ülemise riba](05-the-top-bar.md) võrguikoonilt või klahvidega `Super + Ctrl + N`.

See paneel otsib Wi-Fi võrke, näitab signaali tugevust ja loob ühenduse. Ethernet ei vaja üldse midagi — ühenda see ja kõik töötab. Kui eelistad jääda terminali, annab `nmtui` sulle samad juhtimisvõimalused ja olemas on ka käsurühm `omarchy network`.

## Wi-Fi jagamine

Selle asemel et pikka parooli valjusti ette lugeda, käivita Wi-Fi-s olles _Setup > Network > QR Code_. See paneb ekraanile QR-koodi, mida iga telefoni kaamera saab liitumiseks skannida. See on üks neist asjadest, mida hakkad kasutama rohkem, kui arvatagi oskaksid, kui juba tead, et see olemas on.

Kui vajad siiski parooli ennast, prindib selle `omarchy network password <interface>`.

## DNS

Omarchy kasutab seda DNS-i, mille sinu võrk DHCP kaudu väljastab. Saad selle kogu masina jaoks alistada jaotises _Setup > Network > DNS_, kus Cloudflare ja Google on ühe klõpsu kaugusel. Vali oma serverite sisestamiseks _Custom_.

Terminalist prindib `omarchy dns` praeguse teenusepakkuja ja `omarchy dns Cloudflare` määrab selle.

## Wi-Fi sagedusriba lukustamine

Kui su ruuter paneb 2.4GHz, 5GHz ja 6GHz sama võrgunime alla, klammerdub su sülearvuti mõnikord aeglase külge. `omarchy network band` näitab, millisel sagedusribal sa oled, ja `omarchy network band 5` lukustab selle. Et lasta sel uuesti ise valida, kasuta `auto`.

See lukustab sagedusriba, mitte konkreetse pääsupunkti, nii et liigud AP-de vahel endiselt tavapäraselt.

## Kui kiire see on?

_Trigger > Speed Test > Network Speed Test_ mõõdab su tegelikku üles- ja allalaadimiskiirust paari osutiga. Terminalist on see `omarchy network speedtest down` või `up`. See mõõdab Omarchy enda teenuse vastu ja loeb ainult oma testülekandeid. Teised allalaadimised võivad ribalaiuse pärast võistelda, aga neid kiirusetesti tulemusse ei lisata. (Samas menüüs on selle kõrval kettakiiruse test, kui mõõdad teist pudelikaela.)

## Tulemüür

Tulemüür on vaikimisi sisse lülitatud ja blokeerib kogu sissetuleva liikluse ühe erandiga: port 53317, et [LocalSend](22-guis.md) töötaks kohe karbist võttes.

SSH on välja lülitatud, kuni lülitad selle sisse jaotisest _Setup > Security > SSHD_, mis käivitab deemoni, avab pordi 22 kiirusepiiranguga jõurünnakute vastu ja autoriseerib võtme. Ka Docker on lukku pandud, et konteinerid ei saaks end kogemata maailmale paljastada. Kogu loo leiad jaotisest [turvalisus](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) on mesh VPN, mis teeb kõigi su arvutite ja serveriteni interneti kaudu jõudmise lihtsaks ja turvaliseks. Paigalda see jaotisest _Install > Service > Tailscale_.

See annab sulle ribale Tailscale'i paneeli, mis ühendab tailnetiga ja katkestab sellega ühenduse, vahetab kontosid ja valib väljundsõlme — loendis kuvatakse nii su enda masinad kui ka Mullvad piirkonnad. See sirbib ka su masinaid ja seal elabki Taildrop: vali masin ja vajuta failide saatmiseks `s` või selle IP, nime või täieliku DNS-nime kopeerimiseks `c`, `n` ja `d`. Terminali vaste on `omarchy tailscale send <machine> [file...]` ja sulle saadetud failid maanduvad automaatselt kausta `~/Downloads`. Saabumist teatav teavitus ootab, kuni klõpsad selle avamiseks või sellest loobud, nii et fail, mis saabub ajal, kui oled masina juurest ära, on tagasi tulles endiselt vastamist ootamas.

Selle paigaldamine lisab ka veebirakenduse Tailscale'i halduskonsooli jaoks.

## Kui see lakkab töötamast

Enne taaskäivitamist proovi tõrkuv osa eraldi taaskäivitada. Jaotises _Update > Hardware_ on Wi-Fi, Bluetooth, Audio ja Trackpad ning ühe neist uuesti laadimine lahendab enamiku olukordadest „see töötas viis minutit tagasi“. Vaata [tõrkeotsing](45-troubleshooting.md).
