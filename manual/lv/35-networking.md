# Tīklošana

Tīklošanu Omarchy nodrošina NetworkManager, un jūs to vadāt no tīkla ikonas [augšējā joslā](05-the-top-bar.md) vai ar `Super + Ctrl + W`.

Šis panelis meklē Wi-Fi tīklus, rāda signāla stiprumu un savienojas. Ethernet neprasa neko — pievienojiet kabeli, un viss strādā. Ja labāk patīk terminālis, `nmtui` dod tās pašas vadīklas, un ir arī `omarchy network` komandu grupa.

## Sava Wi-Fi kopīgošana

Tā vietā, lai skaļi nolasītu garu paroli, esot Wi-Fi tīklā, palaidiet _Iestatīšana > Tīkls > QR kods_. Ekrānā parādīsies QR kods, ko jebkura tālruņa kamera var noskenēt, lai pievienotos. Tā ir viena no tām lietām, ko izmantosiet biežāk, nekā domājat, tiklīdz zināsiet, ka tā tur ir.

Ja jums patiešām vajadzīga pati parole, `omarchy network password <interface>` to izdrukā.

## DNS

Omarchy izmanto jebkuru DNS, ko jūsu tīkls izdala ar DHCP. Visai iekārtai to varat pārrakstīt sadaļā _Iestatīšana > Tīkls > DNS_, kur Cloudflare un Google ir viena klikšķa attālumā. Izvēlieties _Pielāgots_, lai ierakstītu savus serverus.

Terminālī `omarchy dns` izdrukā pašreizējo pakalpojumu sniedzēju, un `omarchy dns Cloudflare` iestata vienu.

## Wi-Fi joslas piespraušana

Ja jūsu maršrutētājs 2.4GHz, 5GHz un 6GHz liek zem viena tīkla nosaukuma, jūsu klēpjdators dažkārt turas pie lēnās joslas. `omarchy network band` parāda, kurā joslā esat, un `omarchy network band 5` to piesprauž. Izmantojiet `auto`, lai ļautu izvēlēties no jauna.

Tas piesprauž joslu, nevis konkrētu piekļuves punktu, tāpēc viesabonēšana starp AP turpinās kā ierasts.

## Cik ātri tas ir?

_Palaist > Ātruma tests > Tīkla ātruma tests_ mēra jūsu faktisko lejupielādes un augšupielādes ātrumu ar ciparnīcu pāri. Terminālī tas ir `omarchy network speedtest down` vai `up`. (Blakus šajā izvēlnē ir arī diska ātruma tests, ja mērāt otru vājo vietu.)

## Ugunsmūris

Ugunsmūris pēc noklusējuma ir ieslēgts un bloķē visu ienākošo datplūsmu ar vienu izņēmumu: ports 53317, lai [LocalSend](22-guis.md) darbotos uzreiz pēc uzstādīšanas.

SSH ir izslēgts, līdz to ieslēdzat sadaļā _Iestatīšana > Drošība > SSHD_, kas palaiž dēmonu, atver 22. portu ar ātruma ierobežojumu pret brutāla spēka uzbrukumiem un autorizē atslēgu. Arī Docker ir noslēgts, lai konteineri nejauši neatklātos pasaulei. Visu stāstu skatiet sadaļā [drošība](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) ir tīkla VPN, kas padara visu jūsu datoru un serveru sasniegšanu internetā vienkāršu un drošu. Instalējiet to sadaļā _Instalēt > Pakalpojums > Tailscale_.

Tas joslā dod Tailscale paneli, kas savieno un atvieno tailnet, pārslēdz kontus un izvēlas izejas mezglu — sarakstā parādās gan jūsu pašu iekārtas, gan Mullvad reģioni. Tas arī pārlūko jūsu iekārtas, un tieši tur mitinās Taildrop: atlasiet iekārtu un nospiediet `s`, lai nosūtītu tai failus, vai `c`, `n` un `d`, lai kopētu tās IP, nosaukumu vai pilnu DNS nosaukumu. Termināļa ekvivalents ir `omarchy tailscale send <machine> [file...]`, un jums nosūtītie faili automātiski nonāk `~/Downloads`. Paziņojums par ierašanos gaida, līdz to atverat vai noraidāt, tāpēc fails, kas ieradās, kamēr nebijāt pie datora, joprojām būs tur, kad atgriezīsieties.

Instalēšana pievieno arī tīmekļa lietotni Tailscale administratora konsolei.

## Kad tas pārstāj darboties

Pirms pārstartēšanas mēģiniet atsevišķi pārstartēt vainīgo daļu. Sadaļā _Atjaunināt > Aparatūra_ ir Wi-Fi, Bluetooth, Audio un Skārienpaliktnis, un viena no tiem pārlādēšana atrisina lielāko daļu situāciju „tas taču pirms piecām minūtēm strādāja“. Skatiet [problēmu novēršanu](45-troubleshooting.md).
