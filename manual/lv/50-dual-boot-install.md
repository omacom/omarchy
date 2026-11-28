# Divkāršās sāknēšanas instalēšana

Omarchy vari instalēt vienā nodalījumā līdzās Windows vai citām instalācijām.

Šī instalēšanas metode pēc noklusējuma joprojām ietver nodalījuma LUKS šifrēšanu, tāpēc tā faktiski neatšķiras no instalēšanas visā diskā un vienkārši prasa, lai diskā būtu pieejama brīva vieta.

## Vietas atbrīvošana Windows

Lai instalētu līdzās Windows, sākuma izvēlnē ieraksti `disk management` un atlasī opciju **Izveidot un formatēt cietā diska nodalījumus**.

 ![dual-boot-1](images/dual-boot-1.webp)

Atrodi atbilstošo nodalījumu, noklikšķini uz tā ar peles labo pogu un izvēlies **Samazināt sējumu**.

![dual-boot-2](images/dual-boot-2.webp)

 Ievadi apjomu, par kādu vēlies samazināt sējumu. Ņem vērā, ka tas būs tavas nākamās Omarchy instalācijas lielums, ieskaitot sāknēšanas nodalījumu.

 ![dual-boot-3](images/dual-boot-3.webp)

Kad būsi pabeidzis, vajadzētu redzēt kaut ko līdzīgu šim, kur 50GB sadaļa šajā piemērā ir vieta, kur instalēsim Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy instalēšana

Omarchy instalēšanas process faktiski ir tāds pats kā parasti. Kad būsi atlasījis disku, tev tiks piedāvāta opcija **Instalēšana brīvajā vietā**. Atlasī šo opciju, lai neizdzēstu visu disku.

 ![dual-boot-5](images/dual-boot-5.webp)

Apstiprini, ka viss izskatās labi, un gaidi, līdz instalēšana pabeigsies kā parasti. Šeit vari arī izvēlēties instalēt bez šifrēšanas (nav ieteicams), tāpat kā instalējot visā diskā.
 ![dual-boot-6](images/dual-boot-6.webp)

## Citu instalāciju pievienošana sāknēšanas ielādētājam

Kad būsi pabeidzis Omarchy instalēšanu, pamanīsi, ka tagad noklusējuma sāknēšanas ielādētājs ir Limine. Ar to vari Limine pievienot arī opcijas citām instalācijām, piemēram, Windows.

Lai pievienotu citas operētājsistēmas, palaid `limine-scan` un seko norādēm, lai savai Limine konfigurācijai pievienotu vajadzīgos ierakstus. Sāknēšanas izvēlne pēc noklusējuma paliek paslēpta un pēc vienas sekundes palaiž Omarchy. Lai izvēlētos Windows vai citu ierakstu, nospied jebkuru taustiņu, tiklīdz Limine sāk darboties; kad parādās izvēlne, izmanto bulttaustiņus, lai atlasītu ierakstu, un nospied Enter. Ja Omarchy sāk darboties, pirms paspēj nospiest taustiņu, restartē un mēģini vēlreiz.

## Bitlocker

Svarīgi ņemt vērā, ka šī instalēšanas metode nav saderīga ar Bitlocker, jo tas šifrē visu disku, nevis tikai nodalījumu. Ja redzi kļūdu, kas norāda, ka Bitlocker ir iespējots, sāknē Windows, dodies uz **Iestatījumi -> Konfidencialitāte un drošība -> Ierīces šifrēšana** un izslēdz Bitlocker. Diska atšifrēšana var aizņemt kādu laiku.

 ![dual-boot-7](images/dual-boot-7.webp)

## Windows pārinstalēšana

Ja šis dators tika piegādāts ar Windows, tā produkta atslēga ir saglabāta programmaparatūrā. Palaid `omarchy windows key`, lai to izdrukātu, lai varētu Windows atkal aktivizēt, ja kādreiz to šajā datorā pārinstalēsi.
