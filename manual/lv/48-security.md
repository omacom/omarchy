# Drošība

Omarchy uztver drošību ārkārtīgi nopietni. Šī ir domāta kā operētājsistēma, ko vari izmantot, lai veiktu _Īstu Darbu_ _Reālajā Pasaulē_. Kur klēpjdatora pazaudēšana nevar pārvērsties drošības ārkārtas situācijā. Lūk, ko mēs darām:

1. *Pilna diska šifrēšana ir ieslēgta pēc noklusējuma*: Tas ir svarīgākais solis tavu datu fiziskās aizsardzības nodrošināšanā. Ja tavs dators tiek pazaudēts vai nozagts, dati ir pilnībā šifrēti, izmantojot standarta LUKS (Linux Unified Key Setup). Instalētājs ļauj no tās atteikties vienreizlietojamām mašīnām (skat. [Darba sākšana](02-getting-started.md)); instalācijai bez šifrēšanas šīs aizsardzības nav nemaz, un ikviens, kura rokās nonāk disks, to var izlasīt.
2. *Ugunsmūris ir iespējots pēc noklusējuma*: Visa ienākošā datplūsma pēc noklusējuma ir bloķēta, ar dažiem izņēmumiem: ports 53317 [LocalSend](https://localsend.org/) vajadzībām; DNS vaicājumi datora paša atrisinātājam Docker tilta adresē (172.17.0.1), pieņemti no privāto adrešu diapazoniem, ko Docker piešķir saviem konteineriem; un multiraides DNS (ports 5353), kas ļauj printeriem un citām ierīcēm tavā tīklā atrast vienai otru un arī paziņo tur tava datora nosaukumu. Papildus tiem ugunsmūris saglabā UFW standarta atļaujas ping, adreses iegūšanai no tava maršrutētāja (DHCP) un UPnP atklāšanai. Pat ssh ir izslēgts, līdz tu to ieslēdz caur _Iestatīšana > Drošība > SSHD_, kas iestatīšanas ietvaros atver 22. portu (ar ātruma ierobežojumu pret brutāla spēka uzbrukumiem). Mēs pat ierobežojam Docker piekļuvi, izmantojot [ufw-docker](https://github.com/chaifeng/ufw-docker) iestatījumu, lai tavi konteineri nejauši netiktu atklāti pasaulei.
3. *Arch vienmēr ir jaunākie atjauninājumi*: Arch, pamatā esošā distribūcija, uz kuras balstīta Omarchy, ir ritošā distribūcija. Tas nozīmē, ka jebkura drošības ievainojamība, kas tiek atklāta un izlabota jebkurā pakotnē, drīz ir pieejama instalēšanai, izmantojot `omarchy-update`. Tā tu vienmēr lieto visa jaunākās, visdrošākās versijas.
4. *Omarchy uztur savas pakotnes un spoguli*: Omarchy pēc noklusējuma paļaujas tikai uz pakotnēm no Arch paša core/extra/multilib repozitorijiem un sava Omarchy Package Repository. Tu vari instalēt programmatūru tieši no AUR, bet bāzes instalācija to nedara — tikai dažas izvēles instalācijas, piemēram, trešo pušu pārlūkprogrammas, ņem pakotnes no AUR.
5. *Cloudflare mūs aizsargā pret DDoS*: Omarchy izplatīšanas infrastruktūra — ISO, Omarchy pakotnes, Arch spogulis — ir aizsargāta aiz Cloudflare iespaidīgā DDoS vairoga un viesota viņu CDN. Tas nodrošina izcilu pieejamību.

## Paroļu maiņa

Tev šifrētā instalācijā ir divas paroles: viena, kas sāknēšanas laikā atbloķē disku, un otra, ar kuru tu piesakies un lieto `sudo`. Iestatīšana tās padara vienādas. Abas var mainīt sadaļā _Atjaunināšana > Parole_ Omarchy izvēlnē — pirmajai _Diska šifrēšana_, otrajai _Lietotājs_. Mainot diska paroli, vispirms tiek prasīta pašreizējā, tāpēc turi to pa rokai. Ja maiņa tiek pārtraukta, palaid _Diska šifrēšana_ vēlreiz: tā prasīs paroli, kas pašlaik atbloķē disku, un pabeigs maiņu.

## Jau lietota datora nodošana tālāk

Ja tu nodod savu mašīnu kādam citam, tev tā nav jāpārinstalē. Palaid _Iestatīšana > Atiestatīt datoru_ Omarchy izvēlnē, ieraksti `reset`, lai apstiprinātu, un pārstartē. Tas izdzēš katru lietotāja kontu un visu, kas ir `/home`, izmet visas pakotnes un sistēmas izmaiņas, ko esi veicis kopš instalēšanas, un notīra mašīnas identitāti — tīkla savienojumus, resursdatora atslēgas un visu pārējo. Pēc tam atkal parādās pirmās sāknēšanas iestatīšanas vednis, gatavs, lai jaunais īpašnieks ievadītu savu vārdu, paroli un šifrēšanas paroli.

Tas darbojas, atjaunojot bāzes momentuzņēmumu, ko instalētājs izveido, tāpēc tas ir pieejams tikai mašīnās, kas instalētas no Omarchy ISO. Un diskā bez šifrēšanas atiestatīšana ir dzēšana, nevis droša izdzēšana, tāpēc, ja dati bija sensitīvi, tā vietā veic svaigu instalāciju.

## Sudo bez paroles

Dažreiz tu vēlies, lai `sudo` pārstātu prasīt, visbiežāk tad, kad AI aģents tavā vietā veic garu sistēmas darba posmu. _Iestatīšana > Drošība > Sudo bez paroles_ jautā, cik ilgi atļaut piekļuvi: **15 minūtes**, **1 stunda**, **1 diena** vai **Pastāvīgi**. Kamēr piekļuve ir aktīva, blakus pārējiem izvēlnes joslas indikatoriem parādās sarkana brīdinājuma ikona. Noklikšķini uz tās vai palaid komandu vēlreiz, lai izslēgtu piekļuvi. Tu vari arī norādīt savu minūšu skaitu (no 1 līdz 1440) ar `omarchy-sudo-passwordless 30` vai izmantot `omarchy-sudo-passwordless permanent`.

Piekļuve ar laika ierobežojumu beidzas automātiski, tostarp tūlīt pēc atsākšanas no apturēšanas, kas šķērsoja termiņu. Datora restartēšana to beidz priekšlaicīgi. Pastāvīgā piekļuve saglabājas pēc pārstartēšanas un paliek iespējota, līdz tu to atspējo.

Omarchy iestatījumu pakotnes atjaunināšana vai noņemšana beidz jebkuru pagaidu piešķirumu, pirms mainās tās derīguma termiņa atbalsts. Ja komanda ziņo par autorizācijas vai tīrīšanas kļūdu, novērs to, pirms mēģini iespējot citu piešķirumu; kļūda nenozīmē, ka piekļuve bez paroles ir neaktīva.

Raugies uz to skaidri: kamēr tā ir ieslēgta, viss, kas darbojas kā tavs lietotājs, var kā root darīt jebko, netiekot prasīts. Tā ir visa būtība, un tāds ir arī viss risks.

## Parakstīšanas atslēgas

Publiskā atslēga visiem ISO parakstiem un Omarchy repo pakotnei ir `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([pārbaudīt vietnē openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). `omarchy/omarchy-keyring` pakotne arī satur šo atslēgu un tiks izmantota, lai bez aizķeršanās ieviestu jebkādus iespējamos atjauninājumus.

Tu vari atrast jebkura ISO laidiena parakstu, pievienojot tā URL `.sig`, piemēram, `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
