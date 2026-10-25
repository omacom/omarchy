# Drošība

Omarchy uztver drošību ārkārtīgi nopietni. Šai ir jābūt operētājsistēmai, ko varat izmantot, lai veiktu _Īstu Darbu_ _Īstajā Pasaulē_. Kur klēpjdatora pazaudēšana nevar izvērsties drošības ārkārtas situācijā. Lūk, ko mēs darām:

1. *Pilna diska šifrēšana ir obligāta*: Šis ir vissvarīgākais solis jūsu datu fiziskajai aizsardzībai. Ja jūsu dators tiek pazaudēts vai nozagts, dati ir pilnībā šifrēti, izmantojot standarta LUKS (Linux Unified Key Setup).
2. *Ugunsmūris ir iespējots pēc noklusējuma*: Visa ienākošā datplūsma pēc noklusējuma ir bloķēta, izņemot 53317. portu [LocalSend](https://localsend.org/) vajadzībām. Pat ssh ir izslēgts, līdz to ieslēdzat sadaļā _Iestatīšana > Drošība > SSHD_, kas iestatīšanas ietvaros atver 22. portu (ar ātruma ierobežojumu pret brutāla spēka uzbrukumiem). Mēs pat ierobežojam Docker piekļuvi, izmantojot [ufw-docker](https://github.com/chaifeng/ufw-docker) iestatījumu, lai jūsu konteineri nejauši netiktu atklāti visai pasaulei.
3. *Arch vienmēr ir jaunākie atjauninājumi*: Arch, pamatā esošā distribūcija, uz kuras balstīta Omarchy, ir distribūcija ar nepārtrauktiem atjauninājumiem. Tas nozīmē, ka jebkura atklāta un izlabota drošības ievainojamība jebkurā pakotnē ir ātri pieejama instalēšanai, izmantojot `omarchy-update`. Tādējādi jūs vienmēr izmantojat jaunākās, visdrošākās visa versijas.
4. *Omarchy uztur savas pakotnes un spoguli*: Omarchy pēc noklusējuma paļaujas tikai uz pakotnēm no Arch paša core/extra/multilib repozitorijiem un sava Omarchy pakotņu repozitorija. Programmatūru varat instalēt tieši no AUR, bet bāzes instalācija to nedara — tikai dažas izvēles instalācijas, piemēram, trešo pušu pārlūkprogrammas, izmanto AUR.
5. *Cloudflare mūs aizsargā pret DDoS*: Omarchy izplatīšanas infrastruktūra — ISO, Omarchy pakotnes, Arch spogulis — ir aizsargāta aiz Cloudflare iespaidīgā DDoS vairoga un viesota viņu CDN. Tas nodrošina izcilu pieejamību.

## Paroļu maiņa

Šifrētā instalācijā jums ir divas paroles: viena, kas sāknēšanas laikā atbloķē disku, un otra, ar kuru piesakāties un lietojat `sudo`. Iestatīšana padara tās vienādas. Abas var mainīt Omarchy izvēlnes sadaļā _Atjaunināšana > Parole_ — pirmo ar _Diska šifrēšana_, otro ar _Lietotājs_. Mainot diska paroli, vispirms tiek prasīta pašreizējā parole, tāpēc turiet to pa rokai. Ja maiņa tiek pārtraukta, palaidiet _Diska šifrēšana_ vēlreiz: tā prasīs paroli, kas pašlaik atbloķē disku, un pabeigs maiņu.

## Datora, ko jau esat lietojis, nodošana citam

Ja nododat savu datoru kādam citam, tas nav jāinstalē no jauna. Palaidiet Omarchy izvēlnē _Iestatīšana > Atiestatīt datoru_, ierakstiet `reset`, lai apstiprinātu, un pārstartējiet. Tas izdzēš katru lietotāja kontu un visu, kas atrodas `/home`, atmet visas pakotnes un sistēmas izmaiņas, ko esat veicis kopš instalēšanas, un notīra datora identitāti — tīkla savienojumus, resursdatora atslēgas un visu pārējo. Pēc tam atkal parādās pirmās sāknēšanas iestatīšanas vednis, kas ir gatavs, lai jaunais īpašnieks ievadītu savu vārdu, paroli un šifrēšanas paroli.

Tas darbojas, atjaunojot bāzes momentuzņēmumu, ko izveido instalētājs, tāpēc tas ir pieejams tikai datoros, kas instalēti no Omarchy ISO. Un diskā bez šifrēšanas atiestatīšana ir dzēšana, nevis droša izdzēšana, tāpēc, ja dati bija sensitīvi, tā vietā veiciet svaigu instalēšanu.

## Sudo bez paroles

Dažreiz vēlaties, lai `sudo` pārstātu prasīt paroli, visbiežāk tad, kad AI aģents jūsu vietā ilgstoši veic sistēmas darbus. _Iestatīšana > Drošība > Sudo bez paroles_ prasa, cik ilgi atļaut piekļuvi: **15 minūtes**, **1 stunda**, **1 diena** vai **Pastāvīgi**. Kamēr piekļuve ir aktīva, blakus pārējiem izvēlnes joslas indikatoriem parādās sarkana brīdinājuma ikona. Noklikšķiniet uz tās vai palaidiet komandu vēlreiz, lai piekļuvi izslēgtu. Varat arī norādīt savu minūšu skaitu (no 1 līdz 1440) ar `omarchy-sudo-passwordless 30` vai izmantot `omarchy-sudo-passwordless permanent`.

Piekļuve ar laika ierobežojumu automātiski beidzas, tostarp tūlīt pēc atsākšanas no miega režīma, kas šķērsoja termiņu. Datora restartēšana to pārtrauc priekšlaicīgi. Pastāvīga piekļuve saglabājas pēc pārstartēšanas un paliek iespējota, līdz to atspējojat.

Omarchy iestatījumu pakotnes atjaunināšana vai noņemšana pārtrauc jebkuru pagaidu piešķīrumu, pirms mainās tā derīguma termiņa atbalsts. Ja komanda ziņo par autorizācijas vai tīrīšanas kļūdu, novērsiet to, pirms mēģināt iespējot citu piešķīrumu; kļūda nenozīmē, ka piekļuve bez paroles ir neaktīva.

Skatieties uz to ar atvērtām acīm: kamēr tā ir ieslēgta, jebkas, kas darbojas ar jūsu lietotāju, var darīt jebko kā root, neko neprasot. Tāds ir viss tās mērķis, un tāds ir arī viss tās risks.

## Parakstīšanas atslēgas

Publiskā atslēga visiem ISO parakstiem un Omarchy repo pakotnēm ir `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([pārbaudīt vietnē openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakotnē `omarchy/omarchy-keyring` tā arī ir iekļauta, un tā tiks izmantota, lai nemanāmi ieviestu jebkādus iespējamos atjauninājumus.

Jebkura ISO laidiena parakstu varat atrast, pievienojot URL .sig. Piemēram, https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
