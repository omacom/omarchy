# Drošība

Omarchy drošību uztver ārkārtīgi nopietni. Šī ir domāta kā operētājsistēma, ko varat izmantot, lai veiktu _Īstu Darbu_ _Īstajā Pasaulē_. Kur klēpjdatora pazaudēšana nevar novest pie drošības ārkārtas situācijas. Lūk, ko mēs darām:

1. *Pilna diska šifrēšana pēc noklusējuma ir ieslēgta*: Tas ir vissvarīgākais solis jūsu datu fiziskajai aizsardzībai. Ja jūsu dators tiek pazaudēts vai nozagts, dati ir pilnībā šifrēti, izmantojot standarta LUKS (Linux Unified Key Setup). Instalētājs ļauj atteikties no tās vienreizlietojamām iekārtām (skatiet [Darba sākšana](02-getting-started.md)); instalācijai bez šifrēšanas šīs aizsardzības nav, un ikviens, kura rokās ir disks, var to izlasīt.
2. *Ugunsmūris pēc noklusējuma ir iespējots*: Visa ienākošā datplūsma pēc noklusējuma ir bloķēta, ar dažiem izņēmumiem: ports 53317 [LocalSend](https://localsend.org/) vajadzībām; DNS vaicājumi uz datora paša atrisinātāju Docker tilta adresē (172.17.0.1), kas pieņemti no privāto adrešu diapazoniem, ko Docker piešķir saviem konteineriem; un multiraides DNS (ports 5353), kas ļauj printeriem un citām ierīcēm jūsu tīklā atrast vienai otru un arī paziņo tur jūsu datora nosaukumu. Papildus tiem ugunsmūris saglabā UFW standarta atļaujas ping, adreses iegūšanai no jūsu maršrutētāja (DHCP) un UPnP atklāšanai. Pat ssh ir izslēgts, līdz to ieslēdzat sadaļā _Iestatīšana > Drošība > SSHD_, kas autorizē jūsu SSH atslēgu, izslēdz pieteikšanos ar paroli un tikai tad atver 22. portu (ar ātruma ierobežojumu pret brutāla spēka uzbrukumiem). Mēs pat ierobežojam piekļuvi Docker, izmantojot [ufw-docker](https://github.com/chaifeng/ufw-docker) iestatījumu, lai novērstu, ka jūsu konteineri nejauši tiek pakļauti pasaulei.
3. *Arch vienmēr ir jaunākie atjauninājumi*: Arch, pamatā esošā distribūcija, uz kuras būvēta Omarchy, ir ritošā distribūcija. Tas nozīmē, ka jebkura drošības ievainojamība, kas tiek atklāta un izlabota jebkurā pakotnē, ātri ir pieejama instalēšanai, izmantojot `omarchy-update`. Tādā veidā jūs vienmēr darbināt jaunākās, visdrošākās visa versijas.
4. *Omarchy uztur savas pakotnes un spoguli*: Omarchy pēc noklusējuma paļaujas tikai uz pakotnēm no Arch paša core/extra/multilib repozitorijiem (ARM iekārtās — Arch Linux ARM, plus Asahi ALARM Apple Silicon iekārtās) un sava Omarchy pakotņu repozitorija. Programmatūru varat instalēt tieši no AUR, bet bāzes instalācija to nedara — tikai dažas papildu instalācijas, piemēram, trešo pušu pārlūkprogrammas, izmanto AUR.
5. *Cloudflare mūs aizsargā pret DDoS*: Omarchy izplatīšanas infrastruktūru — ISO, Omarchy pakotnes, Arch spoguli — aizsargā Cloudflare iespaidīgais DDoS vairogs, un tā tiek viesota viņu CDN. Tas nodrošina izcilu pieejamību.

## Paroļu maiņa

Šifrētā instalācijā jums ir divas paroles: viena, kas sāknēšanas laikā atbloķē disku, un viena, ar kuru piesakāties un izmantojat `sudo`. Iestatīšana padara tās vienādas. Sadaļa _Atjaunināšana > Parole_ Omarchy izvēlnē maina abas vienlaikus, lai tās paliktu vienādas: tā prasa pašreizējo diska paroli, pēc tam jauno, maina diska paroli un pēc tam iestata jūsu pieteikšanās paroli atbilstoši tai. Bez diska šifrēšanas tā maina tikai jūsu pieteikšanās paroli. Ja maiņa tiek pārtraukta, palaidiet _Atjaunināšana > Parole_ vēlreiz: tā prasīs paroli, kas tagad atbloķē disku, pabeigs maiņu un iestatīs jūsu pieteikšanās paroli uz to. Lai mainītu cita šifrēta diska paroli, terminālī palaidiet `omarchy-drive-password`.

## Jau lietotas iekārtas nodošana citam

Ja nododat savu iekārtu kādam citam, jums tā nav jāinstalē no jauna. Palaidiet _Noņemšana > Rūpnīcas atiestatīšana_ Omarchy izvēlnē, ierakstiet `reset`, lai apstiprinātu, ievadiet diska šifrēšanas paroli, ja tiek prasīts, un pārstartējiet. Tas dzēš katru lietotāja kontu un visu, kas atrodas `/home`, atmet visas pakotnes un sistēmas izmaiņas, ko esat veicis kopš instalēšanas, un notīra iekārtas identitāti — tīkla savienojumus, resursdatora atslēgas un visu. Pēc tam atkal parādās iestatīšanas vednis no pirmās sāknēšanas, gatavs jaunajam īpašniekam ievadīt savu vārdu, paroli un šifrēšanas paroli.

Tas darbojas, atjaunojot bāzes momentuzņēmumu, ko instalētājs uzņem, tāpēc tas ir pieejams tikai iekārtās, kas instalētas no Omarchy ISO. Un diskā bez šifrēšanas atiestatīšana ir dzēšana, nevis droša dzēšana, tāpēc, ja dati bija sensitīvi, tā vietā veiciet svaigu instalēšanu.

## sudo bez paroles

Dažreiz vēlaties, lai `sudo` pārstātu prasīt, visbiežāk tad, kad AI aģents jūsu vietā veic ilgu sistēmas darbu. Sadaļa _Iestatīšana > Drošība > Sudo bez paroles_ prasa, cik ilgi atļaut piekļuvi: **15 minūtes**, **1 stunda**, **1 diena** vai **Pastāvīgi**. Kamēr piekļuve ir aktīva, blakus citiem izvēlnes joslas indikatoriem parādās sarkana brīdinājuma ikona. Noklikšķiniet uz tās vai palaidiet komandu vēlreiz, lai piekļuvi izslēgtu. Varat arī norādīt savu minūšu skaitu (no 1 līdz 1440) ar `omarchy-sudo-passwordless 30` vai izmantot `omarchy-sudo-passwordless permanent`.

Piekļuvei ar laika ierobežojumu automātiski beidzas termiņš, tostarp tūlīt pēc atsākšanas no apturēšanas, kas šķērsoja termiņu. Datora restartēšana to izbeidz priekšlaicīgi. Pastāvīga piekļuve saglabājas pēc pārstartēšanas un paliek iespējota, līdz to atspējojat.

Omarchy iestatījumu pakotnes atjaunināšana vai noņemšana izbeidz jebkuru pagaidu piešķīrumu, pirms mainās tās termiņa beigu atbalsts. Ja komanda ziņo par autorizācijas vai sakopšanas kļūdu, novērsiet to, pirms mēģināt iespējot citu piešķīrumu; kļūda nenozīmē, ka piekļuve bez paroles ir neaktīva.

Esiet par šo skaidrībā: kamēr tā ir ieslēgta, jebkas, kas darbojas ar jūsu lietotāju, var bez prasīšanas darīt jebko kā root. Tieši tas ir mērķis, un tieši tas ir arī risks.

## Parakstīšanas atslēgas

Publiskā atslēga visiem ISO parakstiem un Omarchy repozitorija pakotnēm ir `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([pārbaudīt vietnē openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakotnē `omarchy/omarchy-keyring` tā arī ir iekļauta un tiks izmantota, lai nemanāmi ieviestu jebkurus iespējamos atjauninājumus.

Jebkuras ISO versijas parakstu varat atrast, pievienojot tās URL `.sig`, piemēram, `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
