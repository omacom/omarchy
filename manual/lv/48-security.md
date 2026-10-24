# Drošība

Omarchy drošību uztver ārkārtīgi nopietni. Šai ir jābūt operētājsistēmai, ko varat izmantot _Īstam darbam_ _Īstajā pasaulē_. Kur klēpjdatora pazaudēšana nevar izraisīt drošības ārkārtas situāciju. Tāpēc lūk, ko mēs darām:

1. *Pilna diska šifrēšana ir obligāta*: tas ir vissvarīgākais solis jūsu datu fiziskās aizsardzības nodrošināšanai. Ja jūsu dators tiek pazaudēts vai nozagts, dati ir pilnībā šifrēti, izmantojot standarta LUKS (Linux Unified Key Setup).
2. *Ugunsmūris ir iespējots pēc noklusējuma*: visa ienākošā datplūsma pēc noklusējuma ir bloķēta, izņemot portu 53317 [LocalSend](https://localsend.org/). Pat ssh ir izslēgts, līdz to ieslēdzat sadaļā _Iestatīšana > Drošība > SSHD_, kas iestatīšanas ietvaros atver 22. portu (ar ātruma ierobežojumu pret brutālu spēku). Mēs pat noslēdzam Docker piekļuvi, izmantojot [ufw-docker](https://github.com/chaifeng/ufw-docker) iestatījumu, lai novērstu, ka jūsu konteineri nejauši tiek atklāti pasaulei.
3. *Arch vienmēr ir jaunākie atjauninājumi*: Arch, pamatā esošā izplatīšana, uz kuras Omarchy ir būvēta, ir ritoša izplatīšana. Tas nozīmē, ka jebkura drošības ievainojamība, kas tiek atklāta un izlabota jebkurā pakotnē, ātri ir pieejama instalēšanai, izmantojot `omarchy-update`. Tā jūs vienmēr darbināt jaunākās, drošākās visa versijas.
4. *Omarchy uztur savas pakotnes un spoguli*: Omarchy pēc noklusējuma paļaujas tikai uz pakotnēm no paša Arch core/extra/multilib repozitorijiem un sava Omarchy pakotņu repozitorija. Programmatūru varat instalēt tieši no AUR, bet bāzes instalācija tā nedara — tikai dažas izvēles instalācijas, piemēram, trešo pušu pārlūki, ņem no AUR.
5. *Cloudflare mūs aizsargā no DDoS*: visa Omarchy izplatīšanas infrastruktūra — ISO, Omarchy pakotnes, Arch spogulis — ir aizsargāta aiz Cloudflare iespaidīgā DDoS vairoga un viesota viņu CDN. Tas nodrošina lielisku pieejamību.

## Paroļu maiņa

Šifrētā instalācijā jums ir divas paroles: tā, kas sāknēšanas laikā atbloķē disku, un tā, ar ko piesakāties un izmantojat `sudo`. Iestatīšana tās padara vienādas. Abas var mainīt Omarchy izvēlnē sadaļā _Atjaunināt > Parole_ — _Diska šifrēšana_ pirmajai, _Lietotājs_ otrajai. Diska paroles maiņa vispirms prasa pašreizējo, tāpēc turiet to pa rokai. Ja maiņa tiek pārtraukta, palaidiet _Diska šifrēšana_ vēlreiz: tā prasa paroli, kas tagad atbloķē disku, un pabeidz maiņu.

## Jau lietotas iekārtas nodošana tālāk

Ja nododat savu iekārtu kādam citam, jums tā nav jāpārinstalē. Omarchy izvēlnē palaidiet _Iestatīšana > Atiestatīt datoru_, ierakstiet `reset`, lai apstiprinātu, un pārstartējiet. Tas notīra katru lietotāja kontu un visu mapē `/home`, izmet visas pakotnes un sistēmas izmaiņas, ko veicāt kopš instalēšanas, un notīra iekārtas identitāti — tīkla savienojumus, saimnieka atslēgas un visu. Augšā atgriežas pirmās sāknēšanas iestatīšanas vednis, gatavs jaunajam īpašniekam ievadīt savu vārdu, paroli un šifrēšanas paroli.

Tas darbojas, atjaunojot bāzlīnijas momentuzņēmumu, ko instalētājs uzņem, tāpēc tas ir pieejams tikai iekārtās, kas instalētas no Omarchy ISO. Un diskā bez šifrēšanas atiestatīšana ir dzēšana, nevis droša izdzēšana, tāpēc, ja dati bija sensitīvi, tā vietā veiciet svaigu instalēšanu.

## Sudo bez paroles

Dažkārt vēlaties, lai `sudo` pārstāj prasīt, visbiežāk, kad AI aģents jums veic garu sistēmas darba posmu. _Iestatīšana > Drošība > Sudo bez paroles_ jautā, cik ilgi atļaut piekļuvi: **15 minūtes**, **1 stunda**, **1 diena** vai **pastāvīgi**. Kamēr piekļuve ir aktīva, blakus pārējiem izvēlņu joslas rādītājiem parādās sarkana brīdinājuma ikona. Noklikšķiniet to vai palaidiet komandu vēlreiz, lai piekļuvi izslēgtu. Varat arī padot savu minūšu skaitu (no 1 līdz 1440) ar `omarchy-sudo-passwordless 30` vai izmantot `omarchy-sudo-passwordless permanent`.

Laikā ierobežota piekļuve automātiski beidzas, tostarp tūlīt pēc atsākšanas no apturēšanas, kas šķērsoja termiņu. Datora restartēšana to beidz priekšlaicīgi. Pastāvīga piekļuve pārdzīvo pārstartēšanas un paliek iespējota, līdz to atspējojat.

Omarchy iestatījumu pakotnes atjaunināšana vai noņemšana beidz jebkuru pagaidu piešķīrumu pirms tā termiņa beigām atbalsta maiņas. Ja komanda ziņo par autorizācijas vai tīrīšanas kļūdu, atrisiniet to pirms mēģināt iespējot citu piešķīrumu; kļūda nenozīmē, ka piekļuve bez paroles ir neaktīva.

Par šo skaidru acu priekšā: kamēr tas ir ieslēgts, jebkas, kas darbojas kā jūsu lietotājs, var darīt jebko kā root, neprasīts. Tā ir visa būtība, un tas ir arī viss risks.

## Paraksta atslēgas

Publiskā atslēga visiem ISO parakstiem un Omarchy repozitorija pakotnei ir `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([pārbaudiet vietnē openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakotne `omarchy/omarchy-keyring` arī to satur un tiks izmantota, lai nemanāmi ieviestu jebkurus iespējamos atjauninājumus.

Jebkura ISO laidiena parakstu varat atrast, URL pievienojot .sig. Piemēram, https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
