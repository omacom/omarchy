# Opdateringer

Omarchy og dine pakker holdes opdateret via _Update > Omarchy_ i Omarchy-menuen (`Super + Space`).

Omarchy selv er installeret som almindelige pacman-pakker fra [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), så en opdatering installerer [den seneste Omarchy-udgivelse](https://github.com/omacom/omarchy/releases), kører eventuelle ventende migrationer for at få dit system i sync med den seneste version og opdaterer alle systempakker fra [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) og [AUR](https://aur.archlinux.org/) (hvis du har installeret nogen AUR-pakker).

Når der kommer nye udgivelser, vises et cirkelpileikon til højre for dit ur. Klik på det, og opdateringsprocessen starter.

![update-available](images/update-available.webp)

### Fire kanaler

Omarchy opdateres ad fire kanaler: stable, RC, edge og dev. Nye installationer starter på stable-kanalen, som følger de [officielle udgivelser](https://github.com/omacom/omarchy/releases/) samt det [stabile Omarchy Arch-mirror](https://github.com/omacom-io/omarchy-mirror), der kører én måned bagud i forhold til det seneste, så vi kan fange eventuelle nye inkompatibiliteter, der kræver konfigurationsændringer, før de skaber problemer for folk.

Men hvis du gerne vil hjælpe med at opdage de potentielle problemer, kan du køre på edge-kanalen. Det holder dine Omarchy-pakker på de seneste udviklingsbuilds og lader dig opdatere til de seneste Arch-pakker, så snart de er tilgængelige. Du bør kun gøre det, hvis du har erfaring med Linux og ved, hvordan man genopretter et system, der har problemer.

Før enhver ny større udgivelse foretager vi den endelige validering via RC-kanalen. Hvis du er interesseret i at hjælpe med den sidste finpudsning, så kom og hæng ud i #omarchy-release-candidates på Discord.

Endelig er der dev-kanalen, som knytter Omarchy direkte til et git-checkout af kildekoden i `~/omarchy`, kombineret med edge-pakkerne. Du bør kun bruge denne kanal, hvis du er en erfaren Linux-bruger, arbejder direkte på Omarchy og er villig til at acceptere, at ting går i stykker.

Du kan skifte mellem kanaler via _Update > Channel_ i Omarchy-menuen (eller `omarchy-channel-set` i terminalen).

### Skift af kernel

Omarchy starter sin egen `linux-omarchy`-kernel, men du kan have andre installeret ved siden af den, f.eks. den almindelige Arch-`linux`-kernel eller et eksperimentelt build, du tester. Når der er mere end én, viser _Update > Kernel_ i Omarchy-menuen dem med et flueben ved siden af den, der starter som standard. Vælg en anden, indtast din adgangskode én gang, og så starter den efter næste genstart. De andre kernels bliver i bootmenuen, så du stadig kan vælge en manuelt, hvis den nye standard giver dig problemer. I terminalen bruger du `omarchy-kernel` til at se den aktuelle standard, `omarchy-kernel list` til at se, hvad der er installeret, og `omarchy-kernel set <kernel>` til at skifte.

### Firmwareopdateringer

Dine pakker er ikke det eneste, der bliver forældet. Mange bærbare computere og perifere enheder leverer BIOS-, SSD- og dock-firmware via Linux Vendor Firmware Service, og _Update > Firmware_ i Omarchy-menuen henter og installerer det, din hardware venter på. Den installerer `fwupd`, første gang du kører den. Masser af firmware kan kun skrives under en genstart, så bliv ikke overrasket over at blive bedt om en.

### Advarsel om direkte pacman/yay-opdateringer

Hvis du allerede er fortrolig med Arch, kan du blive fristet til bare selv at køre `pacman -Syu` eller `yay -Syu`, men hvis du gør det, går du glip af det snapshot, de migrationer og de konfigurationsopdateringer, som Omarchy kører sammen med nye pakker. Derfor stopper Omarchy faktisk en direkte systemopgradering og henviser dig i stedet til `omarchy update`. (Hvis du virkelig ved, hvad du laver, fortæller beskyttelsen dig, hvordan du kan omgå den for en enkelt transaktion.)

### Tilbagerulning af dårlige opdateringer

Hvis du nogensinde får et problem efter en opdatering, kan du rulle dit system tilbage til det snapshot, der blev taget før opdateringen. Genstart blot, og vælg snapshot'et i bootloader-menuen fra før, du startede opdateringen.

![bootloader](images/bootloader.webp)

Hvis dine konfigurationsfiler på en eller anden måde er blevet ødelagt, kan du også foretage en geninstallation af Omarchy med `omarchy reinstall` i terminalen. Det geninstallerer alle Omarchys standardpakker, sætter dig på stable og nedgraderer eventuelle pakker, der er for nye, og nulstiller alle konfigurationsfilerne. Bemærk, at alle dine brugerændringer af Omarchys standardkonfiguration bliver overskrevet, når du gør det!
