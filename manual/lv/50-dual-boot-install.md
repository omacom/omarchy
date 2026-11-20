# Divkāršas sāknēšanas instalēšana

Omarchy var instalēt vienā nodalījumā līdzās Windows vai citām instalācijām.

Šai instalēšanas metodei nodalījumam pēc noklusējuma joprojām ir LUKS šifrēšana, tāpēc tā faktiski neatšķiras no pilna diska instalēšanas un vienkārši prasa, lai diskā būtu pieejama brīva vieta.

## Vietas atbrīvošana Windows sistēmā

Lai instalētu līdzās Windows, sākuma izvēlnē ierakstiet `disk management` un atlasiet opciju **Izveidot un formatēt cietā diska nodalījumus**.

 ![dual-boot-1](images/dual-boot-1.webp)

Atrodiet atbilstošo nodalījumu, noklikšķiniet ar peles labo pogu un izvēlieties **Samazināt sējumu**.

![dual-boot-2](images/dual-boot-2.webp)

 Ievadiet apjomu, par kādu vēlaties samazināt sējumu. Ņemiet vērā, ka tas būs jūsu turpmākās Omarchy instalācijas lielums, ieskaitot sāknēšanas nodalījumu.

 ![dual-boot-3](images/dual-boot-3.webp)

Kad būsiet pabeidzis, vajadzētu redzēt kaut ko līdzīgu šim, kur 50GB sadaļa šajā piemērā ir vieta, kur instalēsim Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy instalēšana

Omarchy instalēšanas process faktiski ir tāds pats kā parasti. Pēc diska atlasīšanas jums tiks piedāvāta opcija **Instalēšana brīvajā vietā**. Atlasiet šo opciju, lai novērstu visa diska dzēšanu.

 ![dual-boot-5](images/dual-boot-5.webp)

Apstipriniet, ka viss izskatās labi, un gaidiet, līdz instalēšana pabeigsies kā parasti. Šeit jūs arī varētu izvēlēties instalēt bez šifrēšanas (nav ieteicams), tāpat kā pilna diska instalēšanas gadījumā.
 ![dual-boot-6](images/dual-boot-6.webp)

## Citu instalāciju pievienošana sāknēšanas ielādētājam

Kad pabeigsiet Omarchy instalēšanu, pamanīsiet, ka tagad noklusējuma sāknēšanas ielādētājs ir Limine. Ar to varat arī pievienot Limine opcijas citām instalācijām, piemēram, Windows.

Lai pievienotu citas operētājsistēmas, palaidiet `limine-scan` un izpildiet norādījumus, lai pievienotu vēlamos ierakstus savai Limine konfigurācijai. Sāknēšanas izvēlne pēc noklusējuma paliek paslēpta un pēc vienas sekundes palaiž Omarchy. Lai izvēlētos Windows vai citu ierakstu, nospiediet jebkuru taustiņu, tiklīdz Limine palaižas; kad parādās izvēlne, izmantojiet bulttaustiņus, lai atlasītu ierakstu, un nospiediet Enter. Ja Omarchy palaižas, pirms paspējat nospiest taustiņu, restartējiet un mēģiniet vēlreiz.

## Bitlocker

Svarīgi ņemt vērā, ka šī instalēšanas metode nav saderīga ar Bitlocker, jo tas šifrē visu disku, nevis tikai nodalījumu. Ja redzat kļūdu, kas norāda, ka Bitlocker ir iespējots, sāknējiet Windows, dodieties uz **Iestatījumi -> Konfidencialitāte un drošība -> Ierīces šifrēšana** un izslēdziet Bitlocker. Diska atšifrēšana var aizņemt kādu laiku.

 ![dual-boot-7](images/dual-boot-7.webp)
