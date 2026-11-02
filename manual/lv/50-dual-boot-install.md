# Divkāršās sāknēšanas instalēšana

Omarchy var instalēt vienā nodalījumā līdzās Windows vai citām instalācijām.

Šī instalēšanas metode nodalījumam pēc noklusējuma joprojām nodrošina LUKS šifrēšanu, tāpēc tā faktiski neatšķiras no instalēšanas visā diskā, un tai vienkārši nepieciešama brīva vieta diskā.

## Vietas atbrīvošana Windows sistēmā

Lai instalētu līdzās Windows, sākuma izvēlnē ierakstiet `disk management` un atlasiet opciju **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Atrodiet atbilstošo nodalījumu, noklikšķiniet ar peles labo pogu un izvēlieties **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Ievadiet apjomu, par kādu vēlaties samazināt sējumu. Ņemiet vērā, ka tas būs jūsu nākamās Omarchy instalācijas lielums, ieskaitot sāknēšanas nodalījumu.

 ![dual-boot-3](images/dual-boot-3.webp)

Kad būsiet pabeidzis, vajadzētu redzēt kaut ko līdzīgu šim, kur 50GB sadaļa šajā piemērā ir vieta, kur instalēsim Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy instalēšana

Omarchy instalēšanas process faktiski ir tāds pats kā parasti. Pēc diska atlasīšanas jums tiks piedāvāta opcija **Free space install**. Atlasiet šo opciju, lai novērstu visa diska dzēšanu.

 ![dual-boot-5](images/dual-boot-5.webp)

Apstipriniet, ka viss izskatās labi, un gaidiet, līdz instalēšana pabeidzas kā parasti. Šeit varat arī izvēlēties instalēt bez šifrēšanas (nav ieteicams), tāpat kā instalējot visā diskā.
 ![dual-boot-6](images/dual-boot-6.webp)

## Citu instalāciju pievienošana sāknēšanas ielādētājam

Kad pabeigsiet Omarchy instalēšanu, pamanīsiet, ka tagad pēc noklusējuma tiek izmantots Limine sāknēšanas ielādētājs. Ar to varat pievienot Limine arī opcijas citām instalācijām, piemēram, Windows.

Lai pievienotu citas operētājsistēmas, palaidiet `limine-scan` un izpildiet norādes, lai pievienotu vajadzīgos ierakstus savai Limine konfigurācijai. Sāknēšanas izvēlne pēc noklusējuma paliek paslēpta un pēc vienas sekundes startē Omarchy. Lai izvēlētos Windows vai citu ierakstu, nospiediet jebkuru taustiņu, tiklīdz startējas Limine; kad parādās izvēlne, izmantojiet bulttaustiņus, lai atlasītu ierakstu, un nospiediet Enter. Ja Omarchy startējas, pirms paspējat nospiest taustiņu, restartējiet un mēģiniet vēlreiz. Ja ieslēdzāt _Setup > Direct Boot_, programmaparatūra pilnībā izlaiž Limine, tāpēc BIOS sāknēšanas izvēlnē izvēlieties Limine vai vēlreiz palaidiet _Setup > Direct Boot_, lai noņemtu ierakstu.

## Bitlocker

Svarīgi ņemt vērā, ka šī instalēšanas metode nav saderīga ar Bitlocker, jo tas šifrē visu disku, nevis tikai nodalījumu. Ja rodas kļūda, kas norāda, ka Bitlocker ir iespējots, startējiet Windows, dodieties uz **Settings -> Privacy & Security -> Device encryption** un izslēdziet Bitlocker. Diska atšifrēšana var aizņemt kādu laiku.

 ![dual-boot-7](images/dual-boot-7.webp)
