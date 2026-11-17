# Tīkls

Omarchy tīklu pārvalda NetworkManager, un tu to vadi no tīkla ikonas [augšējā joslā](05-the-top-bar.md) vai ar `Super + Ctrl + N`.

Šis panelis meklē Wi-Fi tīklus, rāda signāla stiprumu un savienojas. Ethernet nevajag neko — vienkārši pieslēdz to, un viss darbojas. Ja labprātāk paliec terminālī, `nmtui` sniedz tās pašas vadīklas, un ir arī `omarchy network` komandu grupa.

## Sava Wi-Fi koplietošana

Tā vietā, lai skaļi nolasītu garu paroli, kamēr esi pieslēdzies Wi-Fi, palaid _Setup > Network > QR Code_. Tas uz ekrāna parāda QR kodu, ko jebkura tālruņa kamera var noskenēt, lai pievienotos. Tā ir viena no tām lietām, ko izmantosi biežāk, nekā gaidītu, tiklīdz zināsi, ka tā tur ir.

Ja tev patiešām vajag pašu paroli, `omarchy network password <interface>` to izdrukā.

## DNS

Omarchy izmanto jebkuru DNS, ko tavs tīkls piešķir ar DHCP. Tu vari to mainīt visai iekārtai sadaļā _Setup > Network > DNS_, kur Cloudflare un Google ir viena klikšķa attālumā. Izvēlies _Custom_, lai ierakstītu savus serverus.

No termināļa `omarchy dns` izdrukā pašreizējo pakalpojumu sniedzēju, un `omarchy dns Cloudflare` iestata kādu no tiem.

## Wi-Fi joslas piesaiste

Ja tavs maršrutētājs 2.4GHz, 5GHz un 6GHz izvieto ar vienu un to pašu tīkla nosaukumu, tavs klēpjdators dažreiz pieķersies lēnajai joslai. `omarchy network band` parāda, kurā joslā esi, un `omarchy network band 5` to piesaista. Izmanto `auto`, lai ļautu tam atkal izvēlēties pašam.

Tas piesaista joslu, nevis konkrētu piekļuves punktu, tāpēc tu turpini kā parasti pārvietoties starp AP.

## Cik ātrs tas ir?

_Trigger > Speed Test > Network Speed Test_ mēra tavu faktisko augšupielādes un lejupielādes ātrumu ar diviem rādītājiem. No termināļa tas ir `omarchy network speedtest down` vai `up`. Tas mēra pret paša Omarchy pakalpojumu un skaita tikai savas testa pārsūtīšanas. Citas lejupielādes var sacensties par joslas platumu, bet tās netiek pieskaitītas ātruma testa rezultātam. (Blakus tam šajā izvēlnē atrodas diska ātruma tests, ja tu nosaki otru sašaurinājumu.)

## Ugunsmūris

Ugunsmūris pēc noklusējuma ir ieslēgts un bloķē visu ienākošo trafiku, ar vienu izņēmumu: ports 53317, lai [LocalSend](22-guis.md) darbotos uzreiz.

SSH ir izslēgts, līdz tu to ieslēdz ar _Setup > Security > SSHD_, kas palaiž dēmonu, atver 22. portu ar ātruma ierobežojumu pret brutāla spēka uzbrukumiem un autorizē atslēgu. Arī Docker ir stingri ierobežots, tāpēc konteineri nevar nejauši atklāt sevi pasaulei. Visu stāstu skati sadaļā [drošība](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) ir mesh VPN, kas padara visu tavu datoru un serveru sasniegšanu internetā vienkāršu un drošu. Instalē to ar _Install > Service > Tailscale_.

Tas piešķir tev Tailscale paneli joslā, kas savieno un atvieno tailnet, pārslēdz kontus un izvēlas izejas mezglu — sarakstā parādās gan tavas iekārtas, gan Mullvad reģioni. Tas arī pārlūko tavas iekārtas, un tur dzīvo Taildrop: izvēlies iekārtu un nospied `s`, lai nosūtītu tai failus, vai `c`, `n` un `d`, lai kopētu tās IP, nosaukumu vai pilno DNS nosaukumu. Termināļa ekvivalents ir `omarchy tailscale send <machine> [file...]`, un tev nosūtītie faili automātiski nonāk `~/Downloads`. Paziņojums par pienākšanu gaida, līdz tu to noklikšķini vaļā vai noraidi, tāpēc fails, kas parādās, kamēr esi prom no iekārtas, joprojām būs tur, lai uz to reaģētu, kad atgriezīsies.

To instalējot, tiek pievienota arī tīmekļa lietotne Tailscale administrēšanas konsolei.

## Kad tas pārstāj darboties

Pirms pārstartēšanas pamēģini pārstartēt traucējošo daļu atsevišķi. _Update > Hardware_ ir Wi-Fi, Bluetooth, Audio un Trackpad, un kādas no tām pārlādēšana atrisina lielāko daļu situāciju “tas darbojās pirms piecām minūtēm”. Skati [problēmu novēršanu](45-troubleshooting.md).
