# Opdateringer

Omarchy og dine pakker holdes opdateret via _Opdatering > Omarchy_ i Omarchy-menuen (`Super + Space`).

Omarchy selv installeres som almindelige pacman-pakker fra [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), så en opdatering installerer [den nyeste Omarchy-udgivelse](https://github.com/omacom/omarchy/releases), kører alle ventende migreringer for at synkronisere dit system med den nyeste version og opdaterer alle systempakker fra [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) og [AUR](https://aur.archlinux.org/) (hvis du har installeret nogen AUR-pakker).

Når der kommer nye udgivelser, vises et ikon med en cirkelpil til højre for dit ur. Klik på det, så går opdateringsprocessen i gang.

![update-available](images/update-available.webp)

### Fire kanaler

Omarchy opdateres via fire kanaler: stable, RC, edge og dev. Nye installationer starter på stable-kanalen, som følger de [officielle udgivelser](https://github.com/omacom/omarchy/releases/) samt det [stabile Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror), der kører en måned bagud i forhold til det nyeste, så vi kan fange alle nye inkompatibiliteter, der kræver konfigurationsændringer, før de skaber problemer for folk.

Men hvis du gerne vil hjælpe med at opdage de potentielle problemer, kan du køre på edge-kanalen. Det får dine Omarchy-pakker til at følge de nyeste udviklingsbuilds og lader dig opdatere til de nyeste Arch-pakker, så snart de er tilgængelige. Du bør kun gøre det, hvis du har erfaring med Linux og ved, hvordan du genopretter et system, der har problemer.

Før hver ny større udgivelse foretager vi den endelige validering via RC-kanalen. Hvis du er interesseret i at hjælpe med den sidste finpudsning, så kom og hæng ud i #omarchy-release-candidates på Discord.

Til sidst er der dev-kanalen, som forbinder Omarchy direkte til en git-checkout af kildekoden i `~/omarchy`, kombineret med edge-pakkerne. Du bør kun bruge denne kanal, hvis du er en erfaren Linux-bruger, arbejder direkte på Omarchy og er villig til at tolerere, at ting går i stykker.

Du kan skifte mellem kanalerne via _Opdatering > Kanal_ i Omarchy-menuen (eller `omarchy-channel-set` i terminalen).

### Skift mellem kerner

Omarchy starter med sin egen `linux-omarchy`-kerne, men du kan have andre installeret ved siden af den, f.eks. den almindelige Arch `linux`-kerne eller et eksperimentelt build, du tester. Når der er mere end én, oplister _Opdatering > Kerne_ i Omarchy-menuen dem med et flueben ud for den, der startes som standard. Vælg en anden, indtast din adgangskode én gang, så starter den efter næste genstart. De andre kerner bliver i opstartsmenuen, så du stadig kan vælge en manuelt, hvis den nye standard giver dig problemer. I terminalen er det `omarchy-kernel` for at se den nuværende standard, `omarchy-kernel list` for, hvad der er installeret, og `omarchy-kernel set <kernel>` for at skifte.

### Firmwareopdateringer

Dine pakker er ikke det eneste, der bliver forældet. Mange bærbare computere og perifere enheder leverer BIOS-, SSD- og dock-firmware gennem Linux Vendor Firmware Service, og _Opdatering > Firmware_ i Omarchy-menuen henter og installerer alt det, din hardware har liggende og venter. Den installerer `fwupd` første gang, du kører den. Masser af firmware kan kun skrives under en genstart, så bliv ikke overrasket, hvis du bliver bedt om en.

Når du har brug for at ændre en indstilling i selve BIOS'en, skal du holde `Alt` nede i systemmenuen (`Super + Escape`), så bliver _Genstart_ til _Genstart til BIOS_, som genstarter direkte ind i firmwareopsætningen, uden at du skal ramme den rigtige tast ved opstart. Fra terminalen er det `omarchy system firmware`.

### Advarsel om direkte pacman/yay-opdateringer

Hvis du allerede kender Arch, kan du blive fristet til bare selv at køre `pacman -Syu` eller `yay -Syu`, men hvis du gør det, går du glip af det snapshot, de migreringer og de konfigurationsopdateringer, som Omarchy kører sammen med nye pakker. Derfor stopper Omarchy faktisk en direkte systemopgradering og henviser dig til `omarchy update` i stedet. (Hvis du virkelig ved, hvad du laver, fortæller beskyttelsen dig, hvordan du omgår den for en enkelt transaktion.)

### Rul dårlige opdateringer tilbage

Hvis du nogensinde får et problem efter en opdatering, kan du rulle dit system tilbage til det snapshot, der blev taget før opdateringen. Genstart blot, og vælg snapshot'et fra før du startede opdateringen i opstartsmenuen.

![bootloader](images/bootloader.webp)

Hvis dine konfigurationsfiler på en eller anden måde er blevet beskadiget, kan du også foretage en geninstallation af Omarchy med `omarchy reinstall` i terminalen. Det geninstallerer alle standardpakkerne fra Omarchy, sætter dig over på stable og nedgraderer alle pakker, der er for nye, og nulstiller alle konfigurationsfilerne. Bemærk, at alle dine egne konfigurationsændringer til Omarchy-standarderne bliver overskrevet, når du gør det!
