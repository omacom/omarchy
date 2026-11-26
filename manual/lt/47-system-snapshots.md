# Sistemos momentinės kopijos

Momentines kopijas automatiškai sukuriame su kiekvienu Omarchy atnaujinimu, bet jei norite susikurti savo, galite naudoti `omarchy-snapshot create`.

Tai, kaip paleidžiate ir atkuriate momentinę kopiją, priklauso nuo įkrovos tvarkyklės, su kuria paleidžiamas jūsų kompiuteris. Nauji UEFI diegimai naudoja systemd-boot; senesni diegimai ir BIOS kompiuteriai naudoja Limine. `omarchy-boot-backend` parodys, kurią turite jūs.

## Su systemd-boot

Omarchy meniu pasirinkite _Sistema > Momentinės kopijos_ ir pasirinkite momentinę kopiją, į kurią norite paleisti sistemą. Kompiuteris vieną kartą persikraus į ją. Arba paleisdami kompiuterį laikykite nuspaudę Space, kad pamatytumėte įkrovos meniu, kuriame kiekviena momentinė kopija išvardyta nuo naujausios iki seniausios su jos Omarchy versija ir data.

Momentinė kopija paleidžiama su laikinu sluoksniu viršuje, todėl galite ja naudotis kaip įprastai, bet viskas, ką pakeisite, dings kitą kartą perkraunant sistemą. Norėdami ją pasilikti, padarykite ją savo sistema: spustelėkite pranešimą, pasirodžiusį jums prisijungus, pasirinkite _Sistema > Momentinės kopijos > Atkurti šią momentinę kopiją_ arba paleiskite `omarchy-snapshot restore`. Atkūrimas vyksta kompiuteriui persikraunant. Sistema, kokia ji buvo anksčiau, įkrovos meniu lieka kaip _Prieš atkūrimą_, o `omarchy-snapshot restore backup` ją grąžina atgal.

Iš terminalo:

- `omarchy-snapshot list` išvardija momentines kopijas, į kurias galite paleisti sistemą;
- `omarchy-snapshot boot 12` vieną kartą perkrauna į 12 momentinę kopiją;
- `omarchy-snapshot restore 12` kito perkrovimo metu padaro 12 momentinę kopiją sistema, o `omarchy-snapshot restore --cancel` leidžia persigalvoti iki to perkrovimo.

## Su Limine

Norėdami paleisti ir atkurti momentinę kopiją, pasirinkite ją iš Limine įkrovos tvarkyklės. Pagal numatytuosius nustatymus įkrovos meniu lieka paslėptas, todėl vos tik paleidžiama Limine, paspauskite bet kurį klavišą, kad jį parodytumėte.

Tame ekrane pagal datą ir versiją pasirinkite momentinę kopiją, į kurią norite paleisti sistemą. Omarchy versiją momentinės kopijos sukūrimo metu galima matyti apatiniame kairiajame kampe.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Kai pateksite į vidų, iššoks pranešimas, pranešantis, kad esate paleidžiamoje momentinėje kopijoje, ir, jei jį spustelėsite, bus pradėtas atkūrimo procesas. Arba galite naudoti `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## Ką apima atkūrimas

Atkūrimas grąžina jūsų šakninę failų sistemą, bet ne jūsų `/home`. Taigi jis tinka sugedusiam sistemos atnaujinimui atšaukti, bet ne prarastiems asmeniniams failams atkurti.

Tai taip pat reiškia, kad jūsų `~/.config` katalogas lieka toks, koks yra. Taigi, jei grįžtate prie ankstesnės bibliotekos ar programos versijos, kuri konfigūracijos failus saugo nauju formatu, teks tai sutvarkyti rankiniu būdu.

Tas pats galioja ir pačios Omarchy įrašui apie tai, kurios migracijos jau buvo įvykdytos: jis yra jūsų namų kataloge, todėl išlieka atlikus atkūrimą. Migracijos, įvykdytos sukūrus momentinę kopiją, lieka pažymėtos kaip atliktos, net nors jų atlikti pakeitimai šakninėje failų sistemoje buvo atšaukti, ir kitas `omarchy update` jų iš naujo nebevykdys. Taigi, jei po atkūrimo vėl atnaujinsite ir vis dar trūks kažko, ką buvo nustatęs ankstesnis atnaujinimas, tai greičiausiai ir yra priežastis.
