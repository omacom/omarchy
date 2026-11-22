# Sistēmas momentuzņēmumi

Mēs automātiski izveidojam momentuzņēmumus katrā Omarchy atjauninājumā, bet, ja vēlaties izveidot savu, varat izmantot `omarchy-snapshot create`.

Lai sāknētu un atjaunotu momentuzņēmumu, izvēlieties to no Limine sāknēšanas ielādētāja. Sāknēšanas izvēlne pēc noklusējuma paliek paslēpta, tāpēc nospiediet jebkuru taustiņu, tiklīdz Limine sāk darboties, lai to atvērtu.

Šajā ekrānā izvēlieties momentuzņēmumu, kurā vēlaties sāknēt, pēc datuma un versijas. Omarchy versiju momentuzņēmuma izveides brīdī var redzēt apakšējā kreisajā stūrī.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Kad būsiet iekšā, parādīsies paziņojums, kas informēs, ka atrodaties sāknējamā momentuzņēmumā, un, ja noklikšķināsiet uz tā, sāksies atjaunošanas process. Vai arī varat izmantot `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Tas atjaunos jūsu saknes failu sistēmu, bet ne jūsu `/home`. Tātad tas noder, lai atceltu bojātu sistēmas atjauninājumu, bet ne zaudētu personīgo failu atgūšanai.

Tas arī nozīmē, ka jūsu `~/.config` direktorija paliek nemainīga. Tātad, ja atgriežaties pie agrākas bibliotēkas vai lietojumprogrammas versijas, kas glabā konfigurācijas failus jaunā formātā, jums tas būs jārisina manuāli.

Tas pats attiecas uz Omarchy paša žurnālu par to, kuras migrācijas jau ir izpildītas: tas atrodas jūsu mājas direktorijā, tāpēc tas saglabājas pēc atjaunošanas. Migrācijas, kas izpildītas pēc momentuzņēmuma izveides, paliek atzīmētas kā paveiktas, pat ja to veiktās izmaiņas saknes failu sistēmā ir atceltas, un nākamais `omarchy update` tās vairs neizpildīs vēlreiz. Tātad, ja pēc atjaunošanas atjaunināsiet vēlreiz un kaut kas, ko bija iestatījis agrāks atjauninājums, joprojām trūkst, visticamāk, iemesls ir šis.

_Piezīme: Šī funkcija ir pieejama tikai instalācijās, kas izmanto Limine sāknēšanas ielādētāju, kas ir noklusējums kopš Omarchy 2.0. Tā nav pieejama, ja izmantojat GRUB vai systemd-boot._
