# Sistemos momentinės kopijos

Momentines kopijas automatiškai sukuriame su kiekvienu Omarchy atnaujinimu, bet jei norite susikurti savąją, galite naudoti `omarchy-snapshot create`.

Norėdami paleisti ir atkurti momentinę kopiją, pasirinkite ją iš Limine įkrovos tvarkyklės. (Jei šiuo metu paleidžiate sistemą tiesiai į Omarchy iššifravimo ekraną, pirmiausia turėsite per BIOS pasirinkti Limine kaip įkrovos parinktį).

Tame ekrane pasirinkite momentinę kopiją, į kurią norite paleisti sistemą, pagal datą ir versiją. Omarchy versiją momentinės kopijos sukūrimo metu galima matyti apatiniame kairiajame kampe.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Kai pateksite į vidų, iššoks pranešimas, informuojantis, kad esate paleidžiamoje momentinėje kopijoje, ir jei jį spustelėsite, prasidės atkūrimo procesas. Arba galite naudoti `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Tai atkurs jūsų šakninę failų sistemą, bet ne jūsų `/home`. Taigi tai tinka norint atšaukti sugadintą sistemos atnaujinimą, bet ne norint atkurti prarastus asmeninius failus.

Tai taip pat reiškia, kad jūsų `~/.config` katalogas lieka toks, koks yra. Taigi, jei grįžtate prie ankstesnės bibliotekos ar programos versijos, kuri saugo konfigūracijos failus nauju formatu, turėsite tai sutvarkyti rankiniu būdu.

Tas pats galioja ir pačios Omarchy įrašui apie tai, kurios migracijos jau įvykdytos: jis yra jūsų namų kataloge, todėl išlieka po atkūrimo. Migracijos, kurios buvo įvykdytos po momentinės kopijos sukūrimo, lieka pažymėtos kaip atliktos, nors jų atlikti pakeitimai šakninėje failų sistemoje buvo atšaukti, ir kitas `omarchy update` jų vėl nevykdys. Taigi, jei po atkūrimo vėl atnaujinsite ir vis tiek trūks kažko, ką buvo nustatęs ankstesnis atnaujinimas, greičiausiai priežastis yra būtent tai.

_Pastaba: Ši funkcija prieinama tik tose instaliacijose, kurios naudoja Limine įkrovos tvarkyklę, kuri yra numatytoji nuo Omarchy 2.0. Ji neprieinama, jei naudojate GRUB arba systemd-boot._

### Įkrovos meniu praleidimas

Jei niekada neliečiate įkrovos meniu ir tiesiog norite, kad kompiuteris eitų tiesiai į iššifravimo ekraną, Omarchy meniu paleiskite _Setup > Direct Boot_. Tai prideda EFI įrašą, nukreipiantį tiesiai į Omarchy, todėl programinė įranga ją paleidžia nesustodama ties Limine.

Kompromisas yra tas, kuris paminėtas viršuje: kai tiesioginė įkrova įjungta, norint patekti į momentinę kopiją, pirmiausia reikia BIOS įkrovos meniu pasirinkti Limine. Paleiskite _Setup > Direct Boot_ dar kartą, kad pašalintumėte įrašą ir grįžtumėte prie įkrovos per Limine. Kai kuri programinė įranga nemėgsta pasirinktinių EFI įrašų, todėl sąranka atsisako veikti su American Megatrends ir Apple programine įranga.
