# Atnaujinimai

Omarchy ir jūsų paketai atnaujinami per _Atnaujinimas > Omarchy_ Omarchy meniu (`Super + Space`).

Pati Omarchy įdiegiama kaip įprasti pacman paketai iš [Omarchy paketų saugyklos](https://github.com/omacom-io/omarchy-pkgs), todėl atnaujinimas įdiegia [naujausią Omarchy leidimą](https://github.com/omacom/omarchy/releases), paleidžia visas laukiančias migracijas, kad jūsų sistema atitiktų naujausią versiją, ir atnaujina visus sistemos paketus iš [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) ir [AUR](https://aur.archlinux.org/) (jei esate įdiegę kokių nors AUR paketų).

Kai išleidžiamos naujos versijos, dešinėje laikrodžio pusėje atsiras apskritos rodyklės piktograma. Spustelėkite ją ir atnaujinimo procesas prasidės.

![update-available](images/update-available.webp)

### Keturi kanalai

Omarchy atnaujinama keturiais kanalais: stable, RC, edge ir dev. Nauji įdiegimai prasideda stable kanale, kuris seka [oficialius leidimus](https://github.com/omacom/omarchy/releases/), taip pat [stabilų Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror), kuris vienu mėnesiu atsilieka nuo naujausios versijos, kad galėtume pagauti visus naujus nesuderinamumus, kuriems reikia konfigūracijos pakeitimų, dar prieš jiems sukeliant problemų žmonėms.

Bet jei norėtumėte padėti pastebėti tas galimas problemas, galite naudoti edge kanalą. Tada jūsų Omarchy paketai seks naujausias kūrimo versijas ir galėsite atnaujinti į naujausius Arch paketus, kai tik jie taps prieinami. Tai turėtumėte daryti tik jei turite patirties su Linux ir mokate atkurti problemų turinčią sistemą.

Prieš kiekvieną naują pagrindinį leidimą atliksime galutinį patikrinimą naudodami RC kanalą. Jei norite padėti su galutiniu šlifavimu, užsukite į #omarchy-release-candidates Discord.

Galiausiai yra dev kanalas, kuris susieja Omarchy tiesiogiai su git esančia pradinio kodo kopija `~/omarchy`, kartu su edge paketais. Šį kanalą turėtumėte naudoti tik jei esate patyręs Linux naudotojas, tiesiogiai dirbate su Omarchy ir esate pasirengęs toleruoti gedimus.

Galite perjungti kanalus naudodami _Atnaujinimas > Kanalas_ iš Omarchy meniu (arba `omarchy-channel-set` terminale).

### Branduolių keitimas

Omarchy paleidžia savo `linux-omarchy` branduolį, bet šalia jo galite laikyti įdiegtus ir kitus, pavyzdžiui, standartinį Arch `linux` branduolį arba eksperimentinę versiją, kurią bandote. Kai jų yra daugiau nei vienas, _Atnaujinimas > Branduolys_ Omarchy meniu išvardija juos su varnele šalia to, kuris paleidžiamas pagal numatytuosius nustatymus. Pasirinkite kitą, vieną kartą įveskite slaptažodį ir jis bus paleistas po kito perkrovimo. Kiti branduoliai lieka įkrovos meniu, todėl, jei naujasis numatytasis sukels problemų, vis tiek galėsite rankiniu būdu pasirinkti kitą. Terminale `omarchy-kernel` parodo dabartinį numatytąjį, `omarchy-kernel list` — kas įdiegta, o `omarchy-kernel set <kernel>` — perjungia.

### Programinės-aparatinės įrangos atnaujinimai

Jūsų paketai nėra vienintelis dalykas, kuris pasensta. Daugelis nešiojamųjų kompiuterių ir periferinių įrenginių BIOS, SSD ir dokų programinę-aparatinę įrangą gauna per Linux Vendor Firmware Service, o _Atnaujinimas > Programinė-aparatinė įranga_ Omarchy meniu atsisiųs ir įdiegs viską, ko laukia jūsų aparatinė įranga. Pirmą kartą paleidus, jis įdiegia `fwupd`. Daugelį programinės-aparatinės įrangos galima įrašyti tik perkrovimo metu, todėl nenustebkite, jei jūsų paprašys perkrauti.

Kai reikia pakeisti nustatymą pačioje BIOS, laikykite `Alt` sistemos meniu (`Super + Escape`) ir _Perkrauti_ pavirs į _Perkrauti į BIOS_, kas perkraus tiesiai į programinės-aparatinės įrangos sąranką, nereikės gaudyti tinkamo klavišo įkrovimo metu. Iš terminalo tai yra `omarchy system firmware`.

### Įspėjimas dėl tiesioginių pacman/yay atnaujinimų

Jei jau pažįstate Arch, jums gali kilti pagunda tiesiog pačiam paleisti `pacman -Syu` arba `yay -Syu`, bet jei tai padarysite, praleisite momentinę kopiją, migracijas ir konfigūracijos atnaujinimus, kuriuos Omarchy paleidžia kartu su naujais paketais. Todėl Omarchy iš tikrųjų sustabdys tiesioginį sistemos atnaujinimą ir nukreips jus į `omarchy update`. (Jei tikrai žinote, ką darote, apsauga pasakys, kaip ją apeiti vienai operacijai.)

### Nesėkmingų atnaujinimų atšaukimas

Jei po atnaujinimo kada nors kils problemų, galite grąžinti sistemą į momentinę kopiją, padarytą prieš atnaujinimą. Tiesiog perkraukite ir įkrovos meniu pasirinkite momentinę kopiją iš laikotarpio prieš pradedant atnaujinimą.

![bootloader](images/bootloader.webp)

Jei kaip nors jūsų konfigūracijos failai buvo sugadinti, taip pat galite atlikti Omarchy diegimą iš naujo naudodami `omarchy reinstall` terminale. Tai iš naujo įdiegs visus numatytuosius Omarchy paketus, perkels jus į stable ir pažemins visus per naujus paketus bei iš naujo nustatys visus konfigūracijos failus. Atkreipkite dėmesį, kad visi jūsų naudotojo konfigūracijos pakeitimai Omarchy numatytiesiems nustatymams tai darant bus perrašyti!
