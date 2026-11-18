# Diegimas su dviguba įkrova

Omarchy galite įdiegti į vieną skaidinį greta Windows ar kitų įdiegtų sistemų.

Naudojant šį diegimo būdą, skaidinys pagal numatytuosius nustatymus vis tiek šifruojamas naudojant LUKS, todėl jis iš esmės niekuo nesiskiria nuo diegimo į visą diską ir tiesiog reikalauja, kad diske būtų laisvos vietos.

## Vietos atlaisvinimas sistemoje Windows

Norėdami įdiegti greta Windows, pradžios meniu įveskite `disk management` ir pasirinkite parinktį **Kurti ir formatuoti standžiojo disko skaidinius**.

 ![dual-boot-1](images/dual-boot-1.webp)

Raskite tinkamą skaidinį, spustelėkite jį dešiniuoju pelės mygtuku ir pasirinkite **Sutraukti tomą**.

![dual-boot-2](images/dual-boot-2.webp)

 Įveskite dydį, kuriuo norite sutraukti tomą. Atminkite, kad tai bus jūsų būsimo Omarchy diegimo dydis, įskaitant įkrovos skaidinį.

 ![dual-boot-3](images/dual-boot-3.webp)

Baigę turėtumėte matyti maždaug tokį vaizdą, kuriame 50GB skiltis šiame pavyzdyje yra vieta, į kurią diegsime Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy diegimas

Omarchy diegimo procesas iš esmės yra toks pat kaip įprastai. Pasirinkę diską, gausite parinktį **Diegimas į laisvą vietą**. Pasirinkite tą parinktį, kad neištrintumėte viso disko.

 ![dual-boot-5](images/dual-boot-5.webp)

Patvirtinkite, kad viskas atrodo gerai, ir palaukite, kol diegimas baigsis kaip įprastai. Čia taip pat galite pasirinkti diegti be šifravimo (nerekomenduojama), lygiai taip pat kaip diegdami į visą diską.
 ![dual-boot-6](images/dual-boot-6.webp)

## Kitų įdiegtų sistemų įtraukimas į įkrovos tvarkyklę

Baigę Omarchy diegimą pastebėsite, kad dabar numatytoji yra Limine įkrovos tvarkyklė. Naudodami ją, į Limine taip pat galite įtraukti parinktis kitoms įdiegtoms sistemoms, pavyzdžiui, Windows.

Norėdami įtraukti kitas operacines sistemas, paleiskite `limine-scan` ir vykdykite nurodymus, kad į savo Limine konfigūraciją įtrauktumėte norimus įrašus. Įkrovos meniu pagal numatytuosius nustatymus lieka paslėptas ir po vienos sekundės paleidžia Omarchy. Norėdami pasirinkti Windows ar kitą įrašą, vos tik paleidus Limine paspauskite bet kurį klavišą; kai pasirodys meniu, rodyklių klavišais pasirinkite įrašą ir paspauskite Enter. Jei Omarchy paleidžiama nespėjus paspausti klavišo, paleiskite kompiuterį iš naujo ir bandykite dar kartą. Jei įjungėte _Setup > Direct Boot_, programinė aparatinė įranga visiškai praleidžia Limine, todėl pasirinkite Limine savo BIOS įkrovos meniu arba dar kartą paleiskite _Setup > Direct Boot_, kad pašalintumėte įrašą.

## Bitlocker

Svarbu pažymėti, kad šis diegimo būdas nesuderinamas su Bitlocker, nes ji šifruoja visą diską, o ne tik skaidinį. Jei pamatysite klaidą, pranešančią, kad Bitlocker įjungta, paleiskite Windows, eikite į **Settings -> Privacy & Security -> Device encryption** ir išjunkite Bitlocker. Disko iššifravimas gali šiek tiek užtrukti.

 ![dual-boot-7](images/dual-boot-7.webp)
