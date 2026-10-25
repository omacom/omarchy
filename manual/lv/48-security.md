# Drošība

Omarchy drošību uztver ārkārtīgi nopietni. Šai ir jābūt operētājsistēmai, ko varat izmantot, lai darītu _Īstu Darbu_ _Īstajā Pasaulē_. Kur klēpjdatora pazaudēšana nevar izvērsties par drošības ārkārtas situāciju. Lūk, ko mēs darām:

1. *Pilna diska šifrēšana ir obligāta*: Tas ir vissvarīgākais solis jūsu datu fiziskajai aizsardzībai. Ja dators tiek pazaudēts vai nozagts, dati ir pilnībā šifrēti, izmantojot standarta LUKS (Linux Unified Key Setup).
2. *Ugunsmūris ir iespējots pēc noklusējuma*: Visa ienākošā datplūsma pēc noklusējuma tiek bloķēta, izņemot 53317. portu [LocalSend](https://localsend.org/) vajadzībām. Pat ssh ir izslēgts, līdz to ieslēdzat sadaļā _Setup > Security > SSHD_, kas iestatīšanas gaitā atver 22. portu (ar ātruma ierobežojumu pret brutāla spēka uzbrukumiem). Mēs pat ierobežojam Docker piekļuvi, izmantojot [ufw-docker](https://github.com/chaifeng/ufw-docker) iestatījumu, lai jūsu konteineri netiktu nejauši pakļauti pasaulei.
3. *Arch vienmēr ir jaunākie atjauninājumi*: Arch, pamatā esošā distributīva, uz kuras būvēta Omarchy, ir ritoša distributīva. Tas nozīmē, ka ikviena drošības ievainojamība, kas tiek atklāta un izlabota jebkurā pakotnē, ātri kļūst pieejama instalēšanai ar `omarchy-update`. Tādējādi jūs vienmēr darbināt jaunākās, visdrošākās visa versijas.
4. *Omarchy uztur savas pakotnes un spoguli*: Omarchy pēc noklusējuma paļaujas tikai uz pakotnēm no pašas Arch core/extra/multilib repozitorijiem un sava Omarchy Package Repository. Programmatūru varat instalēt tieši no AUR, taču pamata instalācija to nedara — tikai dažas papildu instalācijas, piemēram, trešo pušu pārlūkprogrammas, izmanto AUR.
5. *Cloudflare mūs aizsargā pret DDoS*: Omarchy izplatīšanas infrastruktūra — ISO, Omarchy pakotnes, Arch spogulis — ir aizsargāta aiz Cloudflare iespaidīgā DDoS vairoga un tiek mitināta viņu CDN. Tas nodrošina lielisku pieejamību.

## Paroļu maiņa

Šifrētā instalācijā jums ir divas paroles: viena, kas sāknēšanas laikā atbloķē disku, un otra, ar kuru piesakāties un lietojat `sudo`. Iestatīšana tās padara vienādas. Abas var mainīt Omarchy izvēlnes sadaļā _Update > Password_ — pirmo sadaļā _Drive Encryption_, otro sadaļā _User_. Mainot diska paroli, vispirms tiek prasīta pašreizējā parole, tāpēc turiet to pa rokai. Ja maiņa tiek pārtraukta, palaidiet _Drive Encryption_ vēlreiz: tā prasīs paroli, kas pašlaik atbloķē disku, un pabeigs maiņu.

## Nododot tālāk datoru, ko jau esat lietojis

Ja nododat savu datoru kādam citam, jums tas nav jāpārinstalē. Palaidiet Omarchy izvēlnē _Setup > Reset Computer_, ierakstiet `reset`, lai apstiprinātu, un pārstartējiet. Tas izdzēš katru lietotāja kontu un visu, kas atrodas `/home`, izmet visas pakotnes un sistēmas izmaiņas, ko esat veicis kopš instalēšanas, un notīra datora identitāti — tīkla savienojumus, resursdatora atslēgas un visu pārējo. Pēc tam atkal parādās pirmās sāknēšanas iestatīšanas vednis, gatavs jaunajam īpašniekam ievadīt savu vārdu, paroli un šifrēšanas paroli.

Tas darbojas, atjaunojot bāzes momentuzņēmumu, ko uzņem instalētājs, tāpēc tas ir pieejams tikai datoros, kas instalēti no Omarchy ISO. Un diskā bez šifrēšanas atiestatīšana ir dzēšana, nevis droša dzēšana, tāpēc, ja dati bija sensitīvi, tā vietā veiciet svaigu instalēšanu.

## Sudo bez paroles

Dažkārt vēlaties, lai `sudo` beigtu prasīt paroli, visbiežāk tad, kad AI aģents jūsu vietā veic garu sistēmas darbu. _Setup > Security > Passwordless Sudo_ jautā, cik ilgi atļaut piekļuvi: **15 minutes**, **1 Hour**, **1 Day** vai **Permanently**. Kamēr piekļuve ir aktīva, blakus citiem izvēļņu joslas rādītājiem parādās sarkana brīdinājuma ikona. Noklikšķiniet uz tās vai palaidiet komandu vēlreiz, lai piekļuvi izslēgtu. Varat arī norādīt savu minūšu skaitu (no 1 līdz 1440) ar `omarchy-sudo-passwordless 30` vai izmantot `omarchy-sudo-passwordless permanent`.

Piekļuve ar laika ierobežojumu automātiski beidzas, tostarp tūlīt pēc atsākšanas no apturēšanas, kas šķērsoja termiņu. Datora restartēšana to pārtrauc ātrāk. Pastāvīgā piekļuve saglabājas pēc pārstartēšanas un paliek iespējota, līdz to atspējojat.

Omarchy iestatījumu pakotnes atjaunināšana vai noņemšana izbeidz jebkuru pagaidu piešķīrumu, pirms mainās tā termiņa beigu atbalsts. Ja komanda ziņo par autorizācijas vai tīrīšanas kļūdu, novērsiet to, pirms mēģināt iespējot citu piešķīrumu; kļūda nenozīmē, ka piekļuve bez paroles ir neaktīva.

Skatieties uz to ar atvērtām acīm: kamēr tā ir ieslēgta, jebkas, kas darbojas ar jūsu lietotāju, var darīt jebko kā root, neko neprasot. Tā ir visa būtība, un tas ir arī viss risks.

## Parakstīšanas atslēgas

Visu ISO parakstu un Omarchy repo pakotņu publiskā atslēga ir `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([pārbaudīt vietnē openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakotne `omarchy/omarchy-keyring` arī to satur un tiks izmantota, lai nemanāmi ieviestu jebkādus iespējamos atjauninājumus.

Jebkura ISO laidiena parakstu varat atrast, pievienojot tā URL `.sig`, piemēram, `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
