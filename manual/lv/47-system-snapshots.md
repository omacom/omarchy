# Sistēmas momentuzņēmumi

Mēs automātiski izveidojam momentuzņēmumus pie katra Omarchy atjauninājuma, bet, ja vēlaties izveidot savējo, varat izmantot `omarchy-snapshot create`.

Tas, kā jūs sāknējaties momentuzņēmumā un atjaunojat no tā, ir atkarīgs no sāknēšanas ielādētāja, ar kuru jūsu dators startējas. Jaunās UEFI instalācijās tiek izmantots systemd-boot; vecākās instalācijās un BIOS datoros tiek izmantots Limine. `omarchy-boot-backend` pateiks, kurš no tiem ir jums.

## Ar systemd-boot

Omarchy izvēlnē izvēlieties _System > Snapshots_ un izvēlieties momentuzņēmumu, kurā vēlaties sāknēties. Dators tajā restartēsies vienu reizi. Vai arī turiet nospiestu Space, kamēr dators startējas, lai redzētu sāknēšanas izvēlni, kurā katrs momentuzņēmums ir uzskaitīts, sākot ar jaunāko, norādot tā Omarchy versiju un datumu.

Momentuzņēmums sāknējas ar pagaidu slāni virspusē, tāpēc varat to lietot kā parasti, bet viss, ko izmainīsiet, nākamajā restartēšanā būs pazudis. Lai to saglabātu, padariet to par savu sistēmu: noklikšķiniet uz paziņojuma, kas parādās, kad piesakāties, izvēlieties _System > Snapshots > Restore This Snapshot_ vai palaidiet `omarchy-snapshot restore`. Atjaunošana notiek, kamēr dators restartējas. Sistēma, kāda tā bija iepriekš, sāknēšanas izvēlnē paliek kā _Before restore_, un `omarchy-snapshot restore backup` to atgriež atpakaļ.

No termināļa:

- `omarchy-snapshot list` uzskaita momentuzņēmumus, kuros varat sāknēties;
- `omarchy-snapshot boot 12` vienu reizi restartējas momentuzņēmumā 12;
- `omarchy-snapshot restore 12` padara momentuzņēmumu 12 par sistēmu nākamajā restartēšanā, un `omarchy-snapshot restore --cancel` ļauj pārdomāt pirms šīs restartēšanās.

## Ar Limine

Lai sāknētos momentuzņēmumā un atjaunotu no tā, izvēlieties to Limine sāknēšanas ielādētājā. Sāknēšanas izvēlne pēc noklusējuma paliek paslēpta, tāpēc nospiediet jebkuru taustiņu, tiklīdz Limine startējas, lai to parādītu.

Šajā ekrānā izvēlieties momentuzņēmumu, kurā vēlaties sāknēties, pēc datuma un versijas. Omarchy versiju momentuzņēmuma izveides brīdī var redzēt apakšējā kreisajā stūrī.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Kad būsiet tajā iekšā, parādīsies paziņojums, kas informēs, ka atrodaties sāknējamā momentuzņēmumā, un, ja noklikšķināsiet uz tā, sāksies atjaunošanas process. Alternatīvi varat izmantot `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## Ko aptver atjaunošana

Atjaunošana atgriež jūsu saknes failu sistēmu, bet ne jūsu `/home`. Tāpēc tā der bojāta sistēmas atjauninājuma atcelšanai, bet ne zaudētu personīgo failu atgūšanai.

Tas nozīmē arī to, ka jūsu `~/.config` direktorija paliek tāda, kāda tā ir. Tāpēc, ja atgriežaties pie bibliotēkas vai lietojumprogrammas senākas versijas, kas konfigurācijas failus glabā jaunā formātā, jums tas būs jāsakārto pašam.

Tas pats attiecas uz paša Omarchy ierakstu par to, kuras migrācijas jau ir palaistas: tas atrodas jūsu mājas direktorijā, tāpēc atjaunošanu pārdzīvo. Migrācijas, kas palaistas pēc momentuzņēmuma uzņemšanas, paliek atzīmētas kā paveiktas, pat ja to veiktās izmaiņas saknes failu sistēmā ir atceltas, un nākamais `omarchy update` tās vairs nepalaidīs. Tāpēc, ja pēc atjaunošanas atjaunināt vēlreiz un kaut kas, ko iepriekšējais atjauninājums bija iestatījis, joprojām trūkst, tas, visticamāk, ir iemesls.
