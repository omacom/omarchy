# Dual Boot diegimas

Omarchy galite įdiegti į vieną skaidinį greta Windows ar kitų įdiegtų sistemų.

Taikant šį diegimo būdą, skaidinys pagal numatytuosius nustatymus vis tiek šifruojamas naudojant LUKS, todėl iš esmės jis niekuo nesiskiria nuo diegimo į visą diską ir tiesiog reikia, kad diske būtų laisvos vietos.

## Vietos atlaisvinimas Windows sistemoje

Kad įdiegtumėte greta Windows, pradžios meniu įveskite `disk management` ir pasirinkite parinktį **Sukurti ir formatuoti standžiojo disko skaidinius**.

 ![dual-boot-1](images/dual-boot-1.webp)

Raskite tinkamą skaidinį, spustelėkite jį dešiniuoju pelės mygtuku ir pasirinkite **Sumažinti tomą**.

![dual-boot-2](images/dual-boot-2.webp)

 Įveskite dydį, kuriuo norite sumažinti tomą. Atminkite, kad tai bus jūsų būsimo Omarchy diegimo dydis, įskaitant įkrovos skaidinį.

 ![dual-boot-3](images/dual-boot-3.webp)

Baigę turėtumėte matyti maždaug tokį vaizdą, kuriame 50GB skirsnis šiame pavyzdyje yra ta vieta, į kurią diegsime Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy diegimas

Omarchy diegimo procesas iš esmės yra toks pat, kaip įprastai. Pasirinkę diską, gausite parinktį **Diegimas į laisvą vietą**. Pasirinkite tą parinktį, kad nebūtų ištrintas visas diskas.

 ![dual-boot-5](images/dual-boot-5.webp)

Patikrinkite, ar viskas atrodo gerai, ir, kaip įprastai, palaukite, kol diegimas bus baigtas. Čia taip pat galite pasirinkti diegti be šifravimo (nerekomenduojama), lygiai taip pat, kaip diegdami į visą diską.
 ![dual-boot-6](images/dual-boot-6.webp)

## Kitų įdiegtų sistemų įtraukimas į paleidyklę

Baigę Omarchy diegimą pastebėsite, kad dabar numatytoji paleidyklė yra Limine. Su ja į Limine taip pat galite įtraukti kitų įdiegtų sistemų, pavyzdžiui, Windows, parinktis.

Kad įtrauktumėte kitas operacines sistemas, paleiskite `limine-scan` ir vykdykite nurodymus, kad į savo Limine konfigūraciją įtrauktumėte norimus įrašus. Įkrovos meniu pagal numatytuosius nustatymus lieka paslėptas ir po vienos sekundės paleidžia Omarchy. Kad pasirinktumėte Windows ar kitą įrašą, vos tik paleidžiama Limine, paspauskite bet kurį klavišą; kai pasirodys meniu, rodyklių klavišais pasirinkite įrašą ir paspauskite Enter. Jei Omarchy pasileis nespėjus paspausti klavišo, paleiskite kompiuterį iš naujo ir bandykite dar kartą.

## Bitlocker

Svarbu atkreipti dėmesį, kad šis diegimo būdas nesuderinamas su Bitlocker, nes Bitlocker šifruoja visą diską, o ne tik skaidinį. Jei susidursite su klaida, kurioje teigiama, kad Bitlocker įjungtas, paleiskite Windows, eikite į **Nustatymai -> Privatumas ir sauga -> Įrenginio šifravimas** ir išjunkite Bitlocker. Disko iššifravimas gali užtrukti.

 ![dual-boot-7](images/dual-boot-7.webp)

## Windows diegimas iš naujo

Jei šis kompiuteris buvo pristatytas su Windows, jo produkto raktas saugomas programinėje aparatinėje įrangoje. Paleiskite `omarchy windows key`, kad jį išspausdintumėte, kad galėtumėte vėl suaktyvinti Windows, jei kada nors šiame kompiuteryje diegtumėte ją iš naujo.
