# Atnaujinimai

Omarchy ir jūsų paketai atnaujinami per _Atnaujinti > Omarchy_ Omarchy meniu (`Super + Space`).

Omarchy pati įdiegiama kaip įprasti pacman paketai iš [Omarchy paketų saugyklos](https://github.com/omacom-io/omarchy-pkgs), todėl atnaujinimas įdiegia [naujausią Omarchy leidimą](https://github.com/omacom/omarchy/releases), paleidžia visas laukiančias migracijas, kad jūsų sistema atitiktų naujausią versiją, ir atnaujina visus sistemos paketus iš [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) ir [AUR](https://aur.archlinux.org/) (jei esate įdiegę kokių nors AUR paketų).

Kai pasirodo nauji leidimai, laikrodžio dešinėje atsiras apskritos rodyklės piktograma. Spustelėkite ją ir atnaujinimo procesas prasidės.

![update-available](images/update-available.webp)

### Keturi kanalai

Omarchy atnaujinama keturiais kanalais: stable, RC, edge ir dev. Nauji diegimai prasideda stable kanale, kuris seka [oficialius leidimus](https://github.com/omacom/omarchy/releases/), taip pat stabilų [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror), kuris veikia vienu mėnesiu atsilikęs nuo naujausios versijos, kad galėtume pastebėti visus naujus nesuderinamumus, kuriems reikia konfigūracijos pakeitimų, kol jie dar nesukėlė problemų žmonėms.

Bet jei norite padėti pastebėti tas galimas problemas, galite naudoti edge kanalą. Tada jūsų Omarchy paketai seks naujausias kūrimo versijas ir galėsite atnaujinti į naujausius Arch paketus, vos tik jie pasirodys. Tai darykite tik jei esate patyrę su Linux ir mokate atkurti problemų turinčią sistemą.

Prieš kiekvieną naują stambų leidimą atliksime galutinį patikrinimą naudodami RC kanalą. Jei norite padėti su galutiniu šlifavimu, užsukite į #omarchy-release-candidates Discord platformoje.

Galiausiai yra dev kanalas, kuris susieja Omarchy tiesiogiai su šaltinio kodo git kopija `~/omarchy`, kartu su edge paketais. Šį kanalą naudokite tik jei esate patyręs Linux naudotojas, tiesiogiai dirbate su Omarchy ir esate pasirengęs taikstytis su gedimais.

Kanalus galite perjungti Omarchy meniu pasirinkę _Atnaujinti > Kanalas_ (arba terminale `omarchy channel set <stable|rc|edge|dev>`, o `omarchy channel current` parodys, kuriame esate).

### Branduolio keitimas

Omarchy paleidžia savo `linux-omarchy` branduolį, bet šalia jo galite laikyti įdiegtus kitus, pavyzdžiui, standartinį Arch `linux` branduolį arba eksperimentinę versiją, kurią testuojate. Kai jų yra daugiau nei vienas, _Atnaujinti > Branduolys_ Omarchy meniu išvardija juos su varnele prie to, kuris paleidžiamas pagal numatytuosius nustatymus. Pasirinkite kitą, vieną kartą įveskite slaptažodį ir jis bus paleistas po kito perkrovimo. Kiti branduoliai liks įkrovos meniu, todėl vis tiek galėsite pasirinkti vieną rankiniu būdu, jei naujasis numatytasis sukels problemų. Terminale `omarchy kernel` parodo dabartinį numatytąjį, `omarchy kernel list` – kas įdiegta, o `omarchy kernel set <kernel>` – perjungia.

### Programinės aparatinės įrangos atnaujinimai

Jūsų paketai nėra vienintelis dalykas, kuris pasensta. Daugelis nešiojamųjų kompiuterių ir išorinių įrenginių gauna BIOS, SSD ir doko programinę aparatinę įrangą per Linux Vendor Firmware Service, o _Atnaujinti > Programinė aparatinė įranga_ Omarchy meniu atsisiųs ir įdiegs viską, kas laukia jūsų aparatinei įrangai. Pirmą kartą paleidus, bus įdiegtas `fwupd`. Daug programinės aparatinės įrangos galima įrašyti tik perkraunant, todėl nenustebkite, jei jūsų paprašys tai padaryti.

Kai reikia pakeisti nustatymą pačiame BIOS, sistemos meniu (`Super + Escape`) laikykite `Alt` ir _Paleisti iš naujo_ virs _Paleisti iš naujo į BIOS_ – taip sistema perkraus tiesiai į programinės aparatinės įrangos sąranką, nereikės įkrovos metu gaudyti reikiamo klavišo. Iš terminalo tai yra `omarchy system firmware`.

### Įspėjimas dėl tiesioginių pacman/yay atnaujinimų

Jei jau pažįstate Arch, gali kilti pagunda tiesiog pačiam paleisti `pacman -Syu` arba `yay -Syu`, bet jei taip padarysite, praleisite momentinę kopiją, migracijas ir konfigūracijos atnaujinimus, kuriuos Omarchy paleidžia kartu su naujais paketais. Todėl Omarchy iš tikrųjų sustabdys tiesioginį sistemos atnaujinimą ir vietoj to nukreips jus į `omarchy update`. (Jei tikrai žinote, ką darote, apsauga pasakys, kaip ją apeiti vienai operacijai.)

### Blogų atnaujinimų atšaukimas

Jei po atnaujinimo kada nors kils problemų, galite grąžinti sistemą į momentinę kopiją, padarytą prieš atnaujinimą. Tiesiog perkraukite ir įkrovos meniu pasirinkite momentinę kopiją iš laikotarpio prieš pradedant atnaujinimą.

![bootloader](images/bootloader.webp)

Jei jūsų konfigūracijos failai kaip nors buvo sugadinti, taip pat galite iš naujo įdiegti Omarchy terminale naudodami `omarchy reinstall`. Tai iš naujo įdiegs visus numatytuosius Omarchy paketus, perjungs jus į stable (Apple Silicon atveju – edge), pažemins visus per naujus paketus ir atkirs visus konfigūracijos failus į pradinę būseną. Atkreipkite dėmesį, kad tai atlikus visi jūsų padaryti Omarchy numatytųjų nustatymų pakeitimai bus perrašyti!
