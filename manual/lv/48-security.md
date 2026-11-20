# Drošība

Omarchy drošību uztver ārkārtīgi nopietni. Šai ir jābūt operētājsistēmai, ko varat izmantot, lai veiktu _Īstu Darbu_ _Īstajā Pasaulē_. Kur klēpjdatora pazaudēšana nevar izvērsties drošības ārkārtas situācijā. Lūk, ko mēs darām:

1. *Pilna diska šifrēšana ir ieslēgta pēc noklusējuma*: Tas ir vissvarīgākais solis jūsu datu fiziskai aizsardzībai. Ja dators tiek pazaudēts vai nozagts, dati ir pilnībā šifrēti, izmantojot standarta LUKS (Linux Unified Key Setup). Instalētājs ļauj no tās atteikties vienreizlietojamām ierīcēm (skatiet [Darba sākšana](02-getting-started.md)); instalācijai bez šifrēšanas šīs aizsardzības nav nemaz, un ikviens, kura rokās nonāk disks, var to izlasīt.
2. *Ugunsmūris ir iespējots pēc noklusējuma*: Visa ienākošā datplūsma pēc noklusējuma tiek bloķēta, ar dažiem izņēmumiem: ports 53317 [LocalSend](https://localsend.org/) vajadzībām; DNS vaicājumi uz datora paša resolver Docker bridge adresē (172.17.0.1), pieņemti no privāto adrešu diapazoniem, ko Docker piešķir saviem konteineriem; un multicast DNS (ports 5353), kas ļauj printeriem un citām ierīcēm jūsu tīklā atrast vienai otru un tur arī paziņo jūsu datora nosaukumu. Papildus tiem ugunsmūris saglabā UFW standarta atļaujas ping, adreses iegūšanai no jūsu maršrutētāja (DHCP) un UPnP atklāšanai. Pat ssh ir izslēgts, līdz to ieslēdzat sadaļā _Setup > Security > SSHD_, kas kā daļu no iestatīšanas atver 22. portu (ar ātruma ierobežojumu pret brute force). Mēs pat ierobežojam Docker piekļuvi, izmantojot [ufw-docker](https://github.com/chaifeng/ufw-docker) iestatījumu, lai jūsu konteineri nejauši netiktu atklāti pasaulei.
3. *Arch vienmēr ir jaunākie atjauninājumi*: Arch, pamatā esošā distribūcija, uz kuras balstīta Omarchy, ir rolling distribūcija. Tas nozīmē, ka jebkura drošības ievainojamība, kas tiek atklāta un salabota jebkurā paketē, ātri kļūst pieejama instalēšanai ar `omarchy-update`. Tādā veidā jūs vienmēr darbināt jaunākās, visdrošākās visa versijas.
4. *Omarchy uztur savas paketes un spoguli*: Omarchy pēc noklusējuma paļaujas tikai uz paketēm no Arch paša core/extra/multilib repozitorijiem un sava Omarchy Package Repository. Programmatūru varat instalēt tieši no AUR, bet bāzes instalācija to nedara — tikai dažas papildu instalācijas, piemēram, trešo pušu pārlūkprogrammas, izmanto AUR.
5. *Cloudflare mūs aizsargā no DDoS*: Omarchy izplatīšanas infrastruktūra — ISO faili, Omarchy paketes, Arch spogulis — ir aizsargāta aiz Cloudflare iespaidīgā DDoS vairoga un mitināta viņu CDN. Tas nodrošina izcilu pieejamību.

## Paroļu maiņa

Šifrētā instalācijā jums ir divas paroles: viena, kas sāknēšanas laikā atbloķē disku, un otra, ar kuru piesakāties un lietojat `sudo`. Iestatīšana padara tās vienādas. Abas var mainīt Omarchy izvēlnes sadaļā _Update > Password_ — pirmo ar _Drive Encryption_, otro ar _User_. Mainot diska paroli, vispirms tiek prasīta pašreizējā parole, tāpēc turiet to pie rokas. Ja maiņa tiek pārtraukta, palaidiet _Drive Encryption_ vēlreiz: tā prasīs paroli, kas pašlaik atbloķē disku, un pabeigs maiņu.

## Jau lietotas ierīces nodošana tālāk

Ja nododat savu ierīci kādam citam, jums tā nav jāinstalē no jauna. Omarchy izvēlnē palaidiet _Remove > Factory Reset_, ierakstiet `reset`, lai apstiprinātu, un pārstartējiet datoru. Tas izdzēš katru lietotāja kontu un visu, kas atrodas `/home`, atmet visas paketes un sistēmas izmaiņas, ko esat veicis kopš instalēšanas, un notīra ierīces identitāti — tīkla savienojumus, resursdatora atslēgas un visu pārējo. Pēc tam atkal parādās pirmās sāknēšanas iestatīšanas vednis, gatavs, lai jaunais īpašnieks ievadītu savu vārdu, paroli un šifrēšanas paroli.

Tas darbojas, atjaunojot bāzes momentuzņēmumu, ko izveido instalētājs, tāpēc tas ir pieejams tikai ierīcēs, kas instalētas no Omarchy ISO. Un diskā bez šifrēšanas atiestatīšana ir dzēšana, nevis droša izdzēšana, tāpēc, ja dati bija sensitīvi, tā vietā veiciet svaigu instalāciju.

## Sudo bez paroles

Dažkārt vēlaties, lai `sudo` pārstātu prasīt, visbiežāk tad, kad AI aģents jūsu vietā veic garu sistēmas darba posmu. _Setup > Security > Passwordless Sudo_ prasa, cik ilgi atļaut piekļuvi: **15 minūtes**, **1 stunda**, **1 diena** vai **Pastāvīgi**. Kamēr piekļuve ir aktīva, blakus citiem izvēlnes joslas indikatoriem parādās sarkana brīdinājuma ikona. Noklikšķiniet uz tās vai palaidiet komandu vēlreiz, lai piekļuvi izslēgtu. Varat arī norādīt savu minūšu skaitu (no 1 līdz 1440) ar `omarchy-sudo-passwordless 30` vai izmantot `omarchy-sudo-passwordless permanent`.

Laikā ierobežota piekļuve automātiski beidzas, tostarp tūlīt pēc atsākšanas no apturēšanas, kas šķērsojusi termiņu. Datora pārstartēšana to izbeidz ātrāk. Pastāvīga piekļuve saglabājas pēc pārstartēšanas un paliek iespējota, līdz to atspējojat.

Omarchy iestatījumu paketes atjaunināšana vai noņemšana izbeidz jebkuru pagaidu piešķīrumu, pirms mainās tā termiņa beigu atbalsts. Ja komanda ziņo par autorizācijas vai attīrīšanas kļūdu, novērsiet to, pirms mēģināt iespējot citu piešķīrumu; kļūda nenozīmē, ka piekļuve bez paroles ir neaktīva.

Skatieties uz to ar skaidrām acīm: kamēr tā ir ieslēgta, jebkas, kas darbojas ar jūsu lietotāju, var darīt jebko kā root, neko neprasot. Tā ir visa būtība, un tas ir arī viss risks.

## Parakstīšanas atslēgas

Publiskā atslēga visiem ISO parakstiem un Omarchy repo paketei ir `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([pārbaudiet vietnē openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakete `omarchy/omarchy-keyring` arī to satur un tiks izmantota, lai nemanāmi ieviestu visus iespējamos atjauninājumus.

Jebkuras ISO versijas parakstu varat atrast, pievienojot tās URL `.sig`, piemēram, `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
