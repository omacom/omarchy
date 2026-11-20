# Diegimas su dviguba įkrova

Galite įdiegti Omarchy į vieną skaidinį greta Windows ar kitų įdiegtų sistemų.

Šis diegimo būdas pagal numatytuosius nustatymus vis tiek naudoja LUKS šifravimą skaidiniui, todėl iš esmės niekuo nesiskiria nuo diegimo į visą diską ir tiesiog reikalauja, kad diske būtų laisvos vietos.

## Vietos atlaisvinimas Windows sistemoje

Norėdami įdiegti greta Windows, pradžios meniu įveskite `disk management` ir pasirinkite parinktį **Sukurti ir formatuoti standžiojo disko skaidinius**.

 ![dual-boot-1](images/dual-boot-1.webp)

Raskite tinkamą skaidinį, spustelėkite jį dešiniuoju pelės mygtuku ir pasirinkite **Sumažinti tomą**.

![dual-boot-2](images/dual-boot-2.webp)

 Įveskite dydį, kuriuo norite sumažinti tomą. Atminkite, kad tai bus jūsų būsimo Omarchy diegimo dydis, įskaitant įkrovos skaidinį.

 ![dual-boot-3](images/dual-boot-3.webp)

Baigę turėtumėte matyti kažką panašaus į tai, kur 50GB skirsnis šiame pavyzdyje yra vieta, kurioje įdiegsime Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy diegimas

Omarchy diegimo procesas iš esmės yra toks pat kaip įprastai. Pasirinkę diską, gausite parinktį **Free space install**. Pasirinkite tą parinktį, kad nebūtų ištrintas visas diskas.

 ![dual-boot-5](images/dual-boot-5.webp)

Patvirtinkite, kad viskas atrodo gerai, ir palaukite, kol diegimas baigsis kaip įprastai. Čia taip pat galite pasirinkti diegti be šifravimo (nerekomenduojama), lygiai taip pat kaip diegdami į visą diską.
 ![dual-boot-6](images/dual-boot-6.webp)

## Kitų įdiegtų sistemų pridėjimas prie įkrovos tvarkyklės

Baigę Omarchy diegimą pastebėsite, kad dabar numatytoji yra Limine įkrovos tvarkyklė. Su ja taip pat galite pridėti Limine parinkčių kitoms įdiegtoms sistemoms, pavyzdžiui, Windows.

Norėdami pridėti kitų operacinių sistemų, paleiskite `limine-scan` ir vykdykite nurodymus, kad pridėtumėte norimus įrašus į savo Limine konfigūraciją. Įkrovos meniu pagal numatytuosius nustatymus lieka paslėptas ir po vienos sekundės paleidžia Omarchy. Norėdami pasirinkti Windows ar kitą įrašą, paspauskite bet kurį klavišą, kai tik paleidžiama Limine; kai pasirodys meniu, rodyklių klavišais pasirinkite įrašą ir paspauskite Enter. Jei Omarchy paleidžiama prieš jums paspaudžiant klavišą, paleiskite kompiuterį iš naujo ir bandykite dar kartą.

## Bitlocker

Svarbu atkreipti dėmesį, kad šis diegimo būdas nesuderinamas su Bitlocker, nes jis šifruoja visą diską, o ne tik skaidinį. Jei pamatysite klaidą, nurodančią, kad Bitlocker įjungtas, paleiskite Windows, eikite į **Nustatymai -> Privatumas ir sauga -> Įrenginio šifravimas** ir išjunkite Bitlocker. Disko iššifravimas gali užtrukti.

 ![dual-boot-7](images/dual-boot-7.webp)
