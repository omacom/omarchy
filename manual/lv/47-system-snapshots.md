# Sistēmas momentuzņēmumi

Mēs momentuzņēmumus veidojam automātiski katrā Omarchy atjauninājumā, bet, ja vēlaties izveidot savējo, varat izmantot `omarchy-snapshot create`.

Lai sāknētu un atjaunotu momentuzņēmumu, to atlasāt Limine sāknēšanas lādētājā. (Ja pašlaik sāknējaties tieši Omarchy atšifrēšanas ekrānā, vispirms BIOS būs jāizvēlas Limine kā sāknēšanas opcija).

Šajā ekrānā izvēlieties momentuzņēmumu, kurā vēlaties sāknēties, pēc datuma un versijas. Omarchy versiju momentuzņēmuma laikā var redzēt apakšējā kreisajā stūrī.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Kad ieradīsieties iekšā, parādīsies paziņojums, ka esat sāknējamā momentuzņēmumā, un, noklikšķinot uz tā, sāksies atjaunošanas process. Alternatīvi varat izmantot `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Tas atjaunos jūsu saknes failu sistēmu, bet ne jūsu `/home`. Tāpēc tas der salauzta sistēmas atjauninājuma atgriešanai, bet ne zaudētu personisko failu atgūšanai.

Tas nozīmē arī, ka jūsu direktorija `~/.config` tiek saglabāta tāda, kāda tā ir. Tāpēc, ja atgriežaties uz bibliotēkas vai lietojumprogrammas agrāku versiju, kas konfigurācijas failus glabā jaunā formātā, tas būs jākārto manuāli.

_Piezīme: šī funkcija ir pieejama tikai instalācijās, kas izmanto Limine sāknēšanas lādētāju, kas ir noklusējums kopš Omarchy 2.0. Tā nav pieejama, ja esat uz GRUB vai systemd-boot._

### Sāknēšanas izvēlnes izlaišana

Ja nekad neaiztiekat sāknēšanas izvēlni un vēlaties, lai iekārta dotos tieši uz atšifrēšanas ekrānu, Omarchy izvēlnē palaidiet _Iestatīšana > Tiešā palaišana_. Tas pievieno EFI ierakstu, kas norāda tieši uz Omarchy, tāpēc aparātprogrammatūra to sāknē, neapstājoties pie Limine.

Kompromiss ir augšā minētais: ar ieslēgtu tiešo sāknēšanu nokļūšana līdz momentuzņēmumam nozīmē vispirms BIOS sāknēšanas izvēlnē izvēlēties Limine. Palaidiet _Iestatīšana > Tiešā palaišana_ vēlreiz, lai noņemtu ierakstu un atgrieztos pie sāknēšanas caur Limine. Daža aparātprogrammatūra nemīl pielāgotus EFI ierakstus, tāpēc iestatīšana atsakās darboties uz American Megatrends un Apple aparātprogrammatūras.
