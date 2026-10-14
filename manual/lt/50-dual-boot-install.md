# Dvigubos įkrovos įdiegimas

Gali įdiegti Omarchy į vieną skaidinį šalia Windows ar kitų įdiegimų.

Šis įdiegimo būdas pagal numatytuosius vis tiek turi LUKS šifravimą skaidiniui, todėl iš esmės niekuo nesiskiria nuo pilno disko ir tiesiog reikalauja, kad diske būtų laisvos vietos.

## Vietos atlaisvinimas Windows

Kad įdiegtum šalia Windows, pradžios meniu parašyk `disk management` ir pasirink parinktį **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Rask tinkamą skaidinį, spustelėk dešiniuoju pelės klavišu ir pasirink **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Įvesk dydį, kuriuo nori sumažinti volumį. Atkreipk dėmesį, kad tai bus tavo būsimo Omarchy įdiegimo dydis įskaitant įkrovos skaidinį.

 ![dual-boot-3](images/dual-boot-3.webp)

Kai baigsi, turėtum matyti kažką panašaus, kur 50GB skiltis šiame pavyzdyje yra ta vieta, kur įdiegsime Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy įdiegimas

Omarchy įdiegimo procesas iš esmės toks pat kaip įprastai. Pasirinkęs diską, gausi parinktį **Free space install**. Pasirink tą parinktį, kad neišvalytum viso disko.

 ![dual-boot-5](images/dual-boot-5.webp)

Patvirtink, kad viskas atrodo gerai, ir lauk, kol įdiegimas baigsis kaip įprastai. Čia taip pat galėtum pasirinkti įdiegti nešifruotą (nerekomenduojama), kaip ir pilno disko įdiegime.
 ![dual-boot-6](images/dual-boot-6.webp)

## Kitų įdiegimų pridėjimas į įkroviklį

Baigęs Omarchy įdiegimą, pastebėsi, kad Limine įkroviklis dabar numatytasis. Su juo taip pat gali į Limine pridėti parinkčių kitiems savo įdiegimams, pavyzdžiui, Windows.

Kad tai padarytum, paleisk `limine-scan` ir sek raginimus pridėti norimus elementus į savo limine konfigūraciją. Tada įkraunant matysi įprastas Omarchy parinktis, taip pat Windows Boot Manager ar kitas.

## Bitlocker

Svarbu pažymėti, kad šis įdiegimo būdas nesuderinamas su Bitlocker, nes jis šifruoja visą diską, ne tik skaidinį. Jei susiduri su klaida, sakančia, kad Bitlocker įjungtas, įkrauk Windows, eik į **Settings -> Privacy & Security -> Device encryption** ir išjunk Bitlocker. Disko iššifravimas gali šiek tiek užtrukti.

 ![dual-boot-7](images/dual-boot-7.webp)
