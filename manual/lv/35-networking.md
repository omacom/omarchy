# Tīklošana

Tīklošanu Omarchy vidē pārvalda NetworkManager, un tu to vadi no tīkla ikonas [augšējā joslā](05-the-top-bar.md) vai ar `Super + Ctrl + N`.

Šis panelis meklē Wi-Fi tīklus, rāda signāla stiprumu un izveido savienojumu. Ethernet nevajag neko — vienkārši pieslēdz to, un tas darbojas. Ja labprātāk paliec terminālī, `nmtui` piedāvā tās pašas vadīklas, un ir arī `omarchy network` komandu grupa.

## Sava Wi-Fi kopīgošana

Nevis skaļi nolasi garu paroli, bet, esot Wi-Fi tīklā, palaid _Iestatīšana > Tīkls > QR Code_. Tas ekrānā parāda QR kodu, ko jebkura tālruņa kamera var noskenēt, lai pievienotos. Tā ir viena no tām lietām, ko izmantosi biežāk, nekā gaidītu, tiklīdz zināsi, ka tā tur ir.

Ja tev patiešām vajag pašu paroli, `omarchy network password <interface>` to izdrukā.

## DNS

Omarchy izmanto jebkuru DNS, ko tavs tīkls izsniedz ar DHCP. To vari aizstāt visai iekārtai sadaļā _Iestatīšana > Tīkls > DNS_, kur Cloudflare un Google ir viena klikšķa attālumā. Izvēlies _Custom_, lai ievadītu savus serverus.

No termināļa `omarchy dns` izdrukā pašreizējo pakalpojumu sniedzēju, un `omarchy dns Cloudflare` iestata kādu.

## Wi-Fi joslas piesaistīšana

Ja tavs rūteris 2.4GHz, 5GHz un 6GHz izvieto ar vienu un to pašu tīkla nosaukumu, tavs klēpjdators dažreiz pieķersies lēnajai joslai. `omarchy network band` parāda, kurā joslā esi, un `omarchy network band 5` to piesaista. Izmanto `auto`, lai atkal ļautu tam izvēlēties pašam.

Tas piesaista joslu, nevis konkrētu piekļuves punktu, tāpēc tu turpini kā parasti pārslēgties starp AP.

## Cik ātrs tas ir?

_Aktivizētājs > Ātruma tests > Tīkla ātruma tests_ ar divām skalām izmēra tavu faktisko augšupielādes un lejupielādes ātrumu. No termināļa tas ir `omarchy network speedtest down` vai `up`. (Blakus šajā izvēlnē ir arī diska ātruma tests, ja salīdzini otru vājo vietu.)

## Ugunsmūris

Ugunsmūris pēc noklusējuma ir ieslēgts un bloķē visu ienākošo trafiku, ar vienu izņēmumu: ports 53317, lai [LocalSend](22-guis.md) darbotos uzreiz pēc instalēšanas.

SSH ir izslēgts, līdz to ieslēdz sadaļā _Iestatīšana > Drošība > SSHD_, kas palaiž dēmonu, atver 22. portu ar ātruma ierobežojumu pret brutāla spēka uzbrukumiem un autorizē atslēgu. Arī Docker ir noslēgts, lai konteineri nejauši neatklātu sevi pasaulei. Visu stāstu skati sadaļā [drošība](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) ir mesh VPN, kas padara visu tavu datoru un serveru sasniegšanu internetā vienkāršu un drošu. Instalē to ar _Instalēt > Pakalpojums > Tailscale_.

Tas pievieno Tailscale paneli joslā, kas izveido un pārtrauc savienojumu ar tailnet, pārslēdz kontus un izvēlas izejas mezglu — sarakstā parādās gan tavas iekārtas, gan Mullvad reģioni. Tas arī pārlūko tavas iekārtas, un tur dzīvo Taildrop: izvēlies iekārtu un nospied `s`, lai nosūtītu tai failus, vai `c`, `n` un `d`, lai kopētu tās IP, nosaukumu vai pilno DNS nosaukumu. Ekvivalents terminālī ir `omarchy tailscale send <machine> [file...]`, un tev nosūtītie faili automātiski nonāk `~/Downloads`. Paziņojums par pienākšanu gaida, līdz to noklikšķini, lai atvērtu, vai noraidi, tāpēc fails, kas pienāk, kamēr esi prom no iekārtas, joprojām būs tur, lai uz to atbildētu, kad atgriezīsies.

Tā instalēšana pievieno arī tīmekļa lietotni Tailscale administratora konsolei.

## Kad tas pārstāj darboties

Pirms pārstartēšanas mēģini pārstartēt tikai vainīgo daļu atsevišķi. _Atjaunināt > Aparatūra_ piedāvā Wi-Fi, Bluetooth, Audio un Trackpad, un kādas no tām pārlādēšana atrisina lielāko daļu situāciju „pirms piecām minūtēm tas darbojās”. Skati [problēmu novēršana](45-troubleshooting.md).
