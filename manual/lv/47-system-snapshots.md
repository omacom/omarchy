# Sistēmas momentuzņēmumi

Mēs automātiski izveidojam momentuzņēmumus katrā Omarchy atjauninājumā, bet, ja vēlaties izveidot savu, varat izmantot `omarchy-snapshot create`.

Lai sāknētu un atjaunotu momentuzņēmumu, izvēlieties to Limine sāknēšanas ielādētājā. (Ja pašlaik sāknējaties tieši Omarchy atšifrēšanas ekrānā, vispirms BIOS būs jāizvēlas Limine kā sāknēšanas opcija).

Tajā ekrānā izvēlieties momentuzņēmumu, kurā vēlaties sāknēties, pēc datuma un versijas. Omarchy versiju momentuzņēmuma izveides laikā var redzēt apakšējā kreisajā stūrī.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Kad būsiet iekšā, parādīsies paziņojums, kas informēs, ka atrodaties sāknējamā momentuzņēmumā, un, ja uz tā noklikšķināsiet, sāksies atjaunošanas process. Varat arī izmantot `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Tas atjaunos jūsu saknes failu sistēmu, bet ne jūsu `/home`. Tāpēc tas der bojāta sistēmas atjauninājuma atcelšanai, bet ne zaudētu personīgo failu atgūšanai.

Tas arī nozīmē, ka jūsu `~/.config` direktorijs paliek tāds, kāds tas ir. Tāpēc, ja atgriežaties pie vecākas bibliotēkas vai lietojumprogrammas versijas, kas konfigurācijas failus glabā jaunā formātā, jums tas būs jāatrisina pašam.

Tas pats attiecas uz paša Omarchy ierakstu par to, kuras migrācijas jau ir palaistas: tas atrodas jūsu mājas direktorijā, tāpēc tas pārdzīvo atjaunošanu. Migrācijas, kas palaistas pēc momentuzņēmuma izveides, paliek atzīmētas kā pabeigtas, lai gan to veiktās izmaiņas saknes failu sistēmā ir atceltas, un nākamais `omarchy update` tās vairs nepalaidīs vēlreiz. Tāpēc, ja pēc atjaunošanas atjaunināt vēlreiz un kaut kas, ko iepriekšējais atjauninājums bija iestatījis, joprojām trūkst, tas, visticamāk, ir iemesls.

_Piezīme: Šī funkcija ir pieejama tikai instalācijās, kas izmanto Limine sāknēšanas ielādētāju, kas ir noklusējums kopš Omarchy 2.0. Tā nav pieejama, ja izmantojat GRUB vai systemd-boot._

### Sāknēšanas izvēlnes izlaišana

Ja nekad neaiztiekat sāknēšanas izvēlni un vēlaties, lai dators dotos tieši uz atšifrēšanas ekrānu, Omarchy izvēlnē palaidiet _Setup > Direct Boot_. Tas pievieno EFI ierakstu, kas norāda tieši uz Omarchy, tāpēc programmaparatūra to sāknē, neapstājoties pie Limine.

Kompromiss ir tas pats, kas minēts sākumā: ja tiešā sāknēšana ir ieslēgta, lai piekļūtu momentuzņēmumam, vispirms BIOS sāknēšanas izvēlnē jāizvēlas Limine. Palaidiet _Setup > Direct Boot_ vēlreiz, lai noņemtu ierakstu un atgrieztos pie sāknēšanas caur Limine. Daža programmaparatūra nelabvēlīgi izturas pret pielāgotiem EFI ierakstiem, tāpēc iestatīšana atsakās darboties American Megatrends un Apple programmaparatūrā.
