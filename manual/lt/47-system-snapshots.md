# Sistemos momentinės kopijos

Momentines kopijas automatiškai kuriame su kiekvienu Omarchy naujinimu, bet jei norėtum sukurti savų, gali naudoti `omarchy-snapshot create`.

Kad įkrautum ir atkurtum momentinę kopiją, ją pasirenki iš Limine įkroviklio. (Jei šiuo metu krauniesi tiesiai į Omarchy iššifravimo ekraną, pirmiausia turėsi per BIOS pasirinkti Limine kaip įkrovos parinktį).

Iš to ekrano pasirink momentinę kopiją, į kurią norėtum įkrauti, pagal datą ir versiją. Omarchy versiją momentinės kopijos metu gali pamatyti apatiniame kairiajame kampe.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Kai atsidursi viduje, iššoks pranešimas, pranešantis, kad esi įkraunamoje momentinėje kopijoje, ir jei jį spustelėsi, jis pradės atkūrimo procesą. Arba gali panaudoti `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Tai atkurs tavo šakninę failų sistemą, bet ne tavo `/home`. Taigi tai veikia sugedusiam sistemos naujinimui grąžinti, bet ne prarastiems asmeniniams failams atgauti.

Tai taip pat reiškia, kad tavo `~/.config` katalogas paliekamas kaip yra. Todėl jei grįžti prie ankstesnės bibliotekos ar programos, kuri konfigūracijos failus saugo nauju formatu, versijos, tai turėsi sutvarkyti rankiniu būdu.

_Pastaba: ši funkcija prieinama tik įdiegimuose, naudojančiuose Limine įkroviklį, kuris yra numatytasis nuo Omarchy 2.0. Ji neprieinama, jei esi GRUB ar systemd-boot._

### Įkrovos meniu praleidimas

Jei įkrovos meniu niekad nelieti ir tiesiog nori, kad kompiuteris eitų tiesiai į iššifravimo ekraną, Omarchy meniu paleisk _Nuostatos > Tiesioginė įkrova_. Tai prideda EFI įrašą, rodantį tiesiai į Omarchy, todėl mikroprograminė įranga ją įkrauna nesustodama ties Limine.

Kompromisas yra tas, minėtas viršuje: su įjungta tiesiogine įkrova patekti prie momentinės kopijos reiškia pirmiausia BIOS įkrovos meniu pasirinkti Limine. Vėl paleisk _Nuostatos > Tiesioginė įkrova_, kad pašalintum įrašą ir grįžtum prie įkrovos per Limine. Kai kuri mikroprograminė įranga nemėgsta pasirinktinių EFI įrašų, todėl sąranka atsisako veikti American Megatrends ir Apple mikroprograminėje įrangoje.
