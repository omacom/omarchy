# Drošība

Omarchy drošību uztver ārkārtīgi nopietni. Šī ir domāta kā operētājsistēma, ko vari izmantot, lai darītu _Īstu Darbu_ _Īstajā Pasaulē_. Kur pazaudēts klēpjdators nevar novest pie drošības ārkārtas situācijas. Tātad, lūk, ko mēs darām:

1. *Pilna diska šifrēšana ir ieslēgta pēc noklusējuma*: Šis ir vissvarīgākais solis tavu datu fiziskajai aizsardzībai. Ja tavs dators tiek pazaudēts vai nozagts, dati ir pilnībā šifrēti, izmantojot standarta LUKS (Linux Unified Key Setup). Instalētājs ļauj no tās atteikties vienreizlietojamām iekārtām (skat. [Darba sākšana](02-getting-started.md)); instalācijai bez šifrēšanas šādas aizsardzības nav nemaz, un ikviens, kura rokās ir disks, var to izlasīt.
2. *Ugunsmūris ir iespējots pēc noklusējuma*: Visa ienākošā datplūsma pēc noklusējuma ir bloķēta, ar dažiem izņēmumiem: ports 53317 priekš [LocalSend](https://localsend.org/); DNS vaicājumi datora paša atrisinātājam Docker tilta adresē (172.17.0.1), kas tiek pieņemti no privāto adrešu diapazoniem, ko Docker piešķir saviem konteineriem; un multiraides DNS (ports 5353), kas ļauj printeriem un citām ierīcēm tavā tīklā atrast vienai otru un arī paziņo tur tava datora nosaukumu. Papildus tiem ugunsmūris saglabā UFW standarta atļaujas ping, adreses saņemšanai no tava maršrutētāja (DHCP) un UPnP atklāšanai. Pat ssh ir izslēgts, līdz tu to ieslēdz caur _Iestatīšana > Drošība > SSHD_, kas autorizē tavu SSH atslēgu, izslēdz pieteikšanos ar paroli un tikai tad atver portu 22 (ar ātruma ierobežojumu pret brutāla spēka uzbrukumiem). Mēs pat ierobežojam Docker piekļuvi, izmantojot [ufw-docker](https://github.com/chaifeng/ufw-docker) iestatījumu, lai neļautu taviem konteineriem nejauši tikt pakļautiem pasaulei.
3. *Arch vienmēr ir jaunākie atjauninājumi*: Arch, pamatā esošā distributīva, uz kuras balstīta Omarchy, ir ritīgi izlaižama distributīva. Tas nozīmē, ka jebkura drošības ievainojamība, kas tiek atklāta un izlabota jebkurā pakotnē, ir ātri pieejama instalēšanai, izmantojot `omarchy-update`. Tādā veidā tu vienmēr izmanto jaunākās, visdrošākās visa versijas.
4. *Omarchy uztur savas pakotnes un spoguli*: Omarchy pēc noklusējuma paļaujas tikai uz pakotnēm no Arch pašas core/extra/multilib repozitorijiem (ARM iekārtās — Arch Linux ARM, kā arī Asahi ALARM Apple Silicon iekārtās) un sava Omarchy Package Repository. Tu vari instalēt programmatūru tieši no AUR, bet bāzes instalācija to nedara — tikai dažas papildu instalācijas, piemēram, trešo pušu pārlūkprogrammas, ņem no AUR.
5. *Cloudflare mūs aizsargā no DDoS*: Omarchy izplatīšanas infrastruktūra — ISO, Omarchy pakotnes, Arch spogulis — ir aizsargāta aiz Cloudflare iespaidīgā DDoS vairoga un viesota viņu CDN. Tas nodrošina lielisku pieejamību.

## Paroļu maiņa

Šifrētā instalācijā tev ir divas paroles: viena, kas atbloķē disku sāknēšanas laikā, un otra, ar kuru tu piesakies un izmanto `sudo`. Iestatīšana tās padara vienādas. Abas var mainīt sadaļā _Atjaunināšana > Parole_ Omarchy izvēlnē — pirmo sadaļā _Diska šifrēšana_, otro sadaļā _Lietotājs_. Mainot diska paroli, vispirms tiek prasīta pašreizējā, tāpēc turi to pa rokai. Ja maiņa tiek pārtraukta, palaid _Diska šifrēšana_ vēlreiz: tā prasīs paroli, kas pašlaik atbloķē disku, un pabeigs maiņu.

## Jau lietotas iekārtas nodošana citam

Ja tu nodod savu iekārtu kādam citam, tev tā nav jāinstalē no jauna. Palaid _Noņemšana > Rūpnīcas atiestatīšana_ Omarchy izvēlnē, ieraksti `reset`, lai apstiprinātu, ievadi savu diska šifrēšanas paroli, ja tiek prasīts, un pārstartē. Tas izdzēš katru lietotāja kontu un visu, kas ir `/home`, atmet visas pakotnes un sistēmas izmaiņas, ko esi veicis kopš instalēšanas, un notīra iekārtas identitāti — tīkla savienojumus, resursdatora atslēgas un visu pārējo. Tas, kas ieslēdzas pēc tam, ir iestatīšanas vednis no pirmās sāknēšanas, gatavs tās jaunajam īpašniekam ievadīt savu vārdu, paroli un šifrēšanas paroli.

Tas darbojas, atjaunojot bāzes momentuzņēmumu, ko uzņem instalētājs, tāpēc tas ir pieejams tikai iekārtās, kas instalētas no Omarchy ISO. Un diskā bez šifrēšanas atiestatīšana ir dzēšana, nevis droša izdzēšana, tāpēc, ja dati bija sensitīvi, tā vietā veic svaigu instalēšanu.

## sudo bez paroles

Dažreiz tu vēlies, lai `sudo` pārstāj prasīt, visbiežāk tad, kad AI aģents tavā labā veic garu sistēmas darba posmu. _Iestatīšana > Drošība > sudo bez paroles_ jautā, cik ilgi atļaut piekļuvi: **15 minūtes**, **1 stunda**, **1 diena** vai **Pastāvīgi**. Kamēr piekļuve ir aktīva, blakus pārējiem izvēļņu joslas indikatoriem parādās sarkana brīdinājuma ikona. Noklikšķini uz tās vai palaid komandu vēlreiz, lai izslēgtu piekļuvi. Tu vari arī norādīt savu minūšu skaitu (no 1 līdz 1440) ar `omarchy-sudo-passwordless 30` vai izmantot `omarchy-sudo-passwordless permanent`.

Piekļuve ar laika ierobežojumu automātiski beidzas, tostarp uzreiz pēc atsākšanas no apturēšanas, kuras laikā termiņš ir pagājis. Datora restartēšana to izbeidz agrāk. Pastāvīgā piekļuve saglabājas pēc pārstartēšanas un paliek iespējota, līdz tu to atspējo.

Omarchy iestatījumu pakotnes atjaunināšana vai noņemšana izbeidz jebkuru pagaidu piešķiršanu, pirms mainās tās derīguma termiņa atbalsts. Ja komanda ziņo par autorizācijas vai attīrīšanas kļūdu, novērs to pirms mēģini iespējot citu piešķiršanu; kļūda nenozīmē, ka piekļuve bez paroles ir neaktīva.

Skaties uz šo skaidrām acīm: kamēr tā ir ieslēgta, jebkas, kas darbojas ar tavu lietotāju, var darīt jebko kā root, netiekot prasīts. Tā ir visa jēga, un tas ir arī viss risks.

## Parakstīšanas atslēgas

Publiskā atslēga visiem ISO parakstiem un Omarchy repozitorija pakotnēm ir `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([pārbaudīt vietnē openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakotnē `omarchy/omarchy-keyring` tā arī ir iekļauta, un tā tiks izmantota, lai bez aizķeršanās ieviestu jebkādus iespējamos atjauninājumus.

Jebkura ISO laidiena parakstu vari atrast, pievienojot tā URL `.sig`, piemēram, `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
