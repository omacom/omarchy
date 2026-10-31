# Divkāršas sāknēšanas instalēšana

Omarchy varat instalēt vienā nodalījumā blakus Windows vai citām instalācijām.

Šī instalēšanas metode pēc noklusējuma joprojām nāk ar LUKS šifrēšanu nodalījumam, tāpēc tā faktiski neatšķiras no pilna diska un vienkārši prasa, lai diskā būtu pieejama brīva vieta.

## Vietas atbrīvošana Windows

Lai instalētu blakus Windows, sākuma izvēlnē ierakstiet `disk management` un atlasiet opciju **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Atrodiet atbilstošo nodalījumu, noklikšķiniet ar labo pogu un izvēlieties **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Ievadiet lielumu, par cik vēlaties sējumu samazināt. Ņemiet vērā, ka tas būs jūsu nākotnes Omarchy instalācijas lielums, ieskaitot sāknēšanas nodalījumu.

 ![dual-boot-3](images/dual-boot-3.webp)

Kad esat pabeidzis, jums vajadzētu redzēt kaut ko līdzīgu šim, kur 50GB sadaļa ir vieta, kur šajā piemērā instalēsim Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy instalēšana

Omarchy instalēšanas process faktiski ir tāds pats kā parasti. Pēc diska atlases jums tiks dota opcija **Free space install**. Atlasiet šo opciju, lai nenotīrītu visu disku.

 ![dual-boot-5](images/dual-boot-5.webp)

Apstipriniet, ka viss izskatās labi, un kā parasti gaidiet, līdz instalēšana beidzas. Šeit jūs arī varētu izvēlēties instalēt nešifrēti (nav ieteicams), tāpat kā pilna diska instalācijā.
 ![dual-boot-6](images/dual-boot-6.webp)

## Citu instalāciju pievienošana sāknēšanas lādētājam

Kad pabeidzat Omarchy instalēšanu, pamanīsiet, ka tagad noklusējuma ir Limine sāknēšanas lādētājs. Ar to Limine varat pievienot arī opcijas savām citām instalācijām, piemēram, Windows.

Lai to izdarītu, palaidiet `limine-scan` un sekojiet uzvednēm, lai Limine konfigurācijai pievienotu vajadzīgos vienumus. Tad sāknēšanas laikā redzēsiet savas ierastās Omarchy opcijas, kā arī Windows Boot Manager vai citas.

## Bitlocker

Ir svarīgi ņemt vērā, ka šī instalēšanas metode nav saderīga ar Bitlocker, jo tas šifrē visu disku, ne tikai nodalījumu. Ja saskaraties ar kļūdu, ka Bitlocker ir iespējots, sāknējieties Windows, dodieties uz **Settings -> Privacy & Security -> Device encryption** un izslēdziet Bitlocker. Diska atšifrēšana var aizņemt kādu laiku.

 ![dual-boot-7](images/dual-boot-7.webp)
