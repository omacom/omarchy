# Atnaujinimai

Omarchy ir jūsų paketai nuolat atnaujinami per _Atnaujinti > Omarchy_ Omarchy meniu (`Super + Space`).

Pati Omarchy įdiegiama kaip įprasti pacman paketai iš [Omarchy paketų saugyklos](https://github.com/omacom-io/omarchy-pkgs), todėl atnaujinimas įdiegia [naujausią Omarchy leidimą](https://github.com/omacom/omarchy/releases), paleidžia visas laukiančias migracijas, kad jūsų sistema atitiktų naujausią versiją, ir atnaujina visus sistemos paketus iš [Omarchy Arch veidrodinės kopijos](https://github.com/omacom-io/omarchy-mirror) ir [AUR](https://aur.archlinux.org/) (jei esate įdiegę kokių nors AUR paketų).

Kai išleidžiamos naujos versijos, dešinėje nuo laikrodžio atsiras apskritimo rodyklės piktograma. Spustelėkite ją ir atnaujinimo procesas prasidės.

![update-available](images/update-available.webp)

### Keturi kanalai

Omarchy atnaujinama per keturis kanalus: stable, RC, edge ir dev. Nauji diegimai prasideda stable kanale, kuris seka [oficialius leidimus](https://github.com/omacom/omarchy/releases/), taip pat [stabilią Omarchy Arch veidrodinę kopiją](https://github.com/omacom-io/omarchy-mirror), kuri vienu mėnesiu atsilieka nuo naujausios, kad galėtume pagauti visus naujus nesuderinamumus, kuriems reikia konfigūracijos pakeitimų, dar prieš jiems sukeliant problemų žmonėms.

Bet jei norėtumėte padėti pastebėti tas galimas problemas, galite naudoti edge kanalą. Tada jūsų Omarchy paketai seks naujausias kūrimo versijas, o Arch paketus galėsite atnaujinti į naujausius, kai tik jie taps prieinami. Tai turėtumėte daryti tik jei turite patirties su Linux ir žinote, kaip atkurti problemų turinčią sistemą.

Prieš kiekvieną naują pagrindinį leidimą atliksime galutinį patikrinimą naudodami RC kanalą. Jei norite padėti su galutiniu šlifavimu, užsukite į #omarchy-release-candidates Discord kanale.

Galiausiai yra dev kanalas, kuris susieja Omarchy tiesiogiai su git šaltinio kodo kopija `~/omarchy`, kartu su edge paketais. Šį kanalą turėtumėte naudoti tik jei esate patyręs Linux naudotojas, dirbate tiesiogiai su Omarchy ir esate pasirengę toleruoti gedimus.

Tarp kanalų galite perjungti naudodami _Atnaujinti > Kanalas_ Omarchy meniu (arba `omarchy-channel-set` terminale).

### Branduolių perjungimas

Omarchy paleidžiama su savo `linux-omarchy` branduoliu, bet šalia galite laikyti įdiegtus kitus, pavyzdžiui, standartinį Arch `linux` branduolį arba eksperimentinę versiją, kurią testuojate. Kai jų yra daugiau nei vienas, _Atnaujinti > Branduolys_ Omarchy meniu pateikia jų sąrašą su varnele prie to, kuris paleidžiamas pagal numatytuosius nustatymus. Pasirinkite kitą, vieną kartą įveskite slaptažodį ir jis bus paleistas po kito perkrovimo. Kiti branduoliai lieka įkrovos meniu, todėl vis tiek galite pasirinkti vieną rankiniu būdu, jei naujasis numatytasis sukels problemų. Terminale `omarchy-kernel` parodo dabartinį numatytąjį, `omarchy-kernel list` — kas įdiegta, o `omarchy-kernel set <kernel>` — perjungia.

### Mikroprograminės įrangos atnaujinimai

Pasensta ne tik jūsų paketai. Daugelis nešiojamųjų kompiuterių ir periferinių įrenginių BIOS, SSD ir stotelių mikroprograminę įrangą gauna per Linux Vendor Firmware Service, o _Atnaujinti > Mikroprograminė įranga_ Omarchy meniu atsisiųs ir įdiegs viską, ko laukia jūsų aparatinė įranga. Pirmą kartą paleidus įdiegiama `fwupd`. Daug mikroprograminės įrangos galima įrašyti tik perkrovimo metu, todėl nenustebkite, jei jūsų paprašys perkrauti.

### Įspėjimas dėl tiesioginių pacman/yay atnaujinimų

Jei jau pažįstate Arch, gali kilti pagunda tiesiog pačiam paleisti `pacman -Syu` arba `yay -Syu`, bet jei taip padarysite, praleisite momentinę kopiją, migracijas ir konfigūracijos atnaujinimus, kuriuos Omarchy paleidžia kartu su naujais paketais. Todėl Omarchy iš tikrųjų sustabdys tiesioginį sistemos atnaujinimą ir nukreips jus į `omarchy update`. (Jei tikrai žinote, ką darote, apsauga pasakys, kaip ją apeiti vienai operacijai.)

### Grįžimas po blogo atnaujinimo

Jei po atnaujinimo kada nors kils problemų, galite grąžinti sistemą į momentinę kopiją, padarytą prieš atnaujinimą. Tiesiog perkraukite ir įkrovos meniu pasirinkite momentinę kopiją iš laikotarpio prieš pradedant atnaujinimą.

![bootloader](images/bootloader.webp)

Jei kaip nors jūsų konfigūracijos failai buvo sugadinti, taip pat galite iš naujo įdiegti Omarchy naudodami `omarchy reinstall` terminale. Tai iš naujo įdiegs visus numatytuosius Omarchy paketus, perjungs jus į stable ir pažemins visus per naujus paketus bei atkurs visus konfigūracijos failus. Atkreipkite dėmesį, kad visi jūsų naudotojo pakeitimai Omarchy numatytosiose nuostatose tai darant bus perrašyti!
