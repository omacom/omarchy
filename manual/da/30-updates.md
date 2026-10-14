# Opdateringer

Omarchy og dine pakker holdes opdateret via _Opdater > Omarchy_ i Omarchy-menuen (`Super + Space`).

Selve Omarchy installeres som almindelige pacman-pakker fra [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), så en opdatering installerer [den seneste Omarchy-udgivelse](https://github.com/omacom/omarchy/releases), kører alle ventende migreringer for at få dit system i sync med det seneste og opdaterer alle systempakker fra [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) og [AUR](https://aur.archlinux.org/) (hvis du har installeret nogen AUR-pakker).

Når der laves nye udgivelser, vil et cirkelpil-ikon dukke op til højre for dit ur. Klik på det, og opdateringsprocessen starter.

![update-available](images/update-available.webp)

### Fire kanaler

Omarchy opdateres langs fire kanaler: stable, RC, edge og dev. Nye installationer starter på stable-kanalen, som følger [de officielle udgivelser](https://github.com/omacom/omarchy/releases/) samt [det stabile Omarchy Arch-spejl](https://github.com/omacom-io/omarchy-mirror), der kører en måned bag det seneste, så vi kan fange eventuelle nye inkompatibiliteter, der kræver konfigurationsændringer, før de forårsager problemer for folk.

Men hvis du gerne vil hjælpe med at spotte de potentielle problemer, kan du køre på edge-kanalen. Det vil holde dine Omarchy-pakker med at følge de seneste udviklingsbuilds og lader dig opdatere til de seneste Arch-pakker, så snart de er tilgængelige. Du bør kun gøre dette, hvis du har erfaring med Linux og ved, hvordan man gendanner et system, der har problemer.

Før enhver ny større udgivelse vil vi lave den endelige validering ved hjælp af RC-kanalen. Hvis du er interesseret i at hjælpe med den endelige polering, så kom og hæng ud i #omarchy-release-candidates på Discord.

Endelig er der dev-kanalen, som forbinder Omarchy direkte til et git-checkout af kildekoden i `~/omarchy`, kombineret med edge-pakkerne. Du bør kun bruge denne kanal, hvis du er en erfaren Linux-bruger, der arbejder direkte på Omarchy og er villig til at tolerere brud.

Du kan skifte mellem kanaler ved hjælp af _Opdater > Channel_ fra Omarchy-menuen (eller `omarchy-channel-set` i terminalen).

### Firmwareopdateringer

Dine pakker er ikke det eneste, der bliver forældet. Mange bærbare computere og periferiudstyr leverer BIOS-, SSD- og dock-firmware gennem Linux Vendor Firmware Service, og _Opdater > Firmware_ i Omarchy-menuen vil hente og installere, hvad din hardware har ventende. Den installerer `fwupd` første gang, du kører den. Masser af firmware kan kun skrives under en genstart, så bliv ikke overrasket over at blive bedt om en.

### Advarsel om direkte pacman/yay-opdateringer

Hvis du allerede er bekendt med Arch, kan du blive fristet til bare at køre `pacman -Syu` eller `yay -Syu` selv, men hvis du gør det, vil du gå glip af snapshottet, migreringerne og konfigurationsopdateringerne, som Omarchy kører sammen med nye pakker. Derfor vil Omarchy faktisk stoppe en direkte systemopgradering og pege dig i stedet mod `omarchy update`. (Hvis du virkelig ved, hvad du laver, vil vagten fortælle dig, hvordan du omgår den til en enkelt transaktion.)

### Rulle dårlige opdateringer tilbage

Hvis du nogensinde har et problem efter at have lavet en opdatering, kan du rulle dit system tilbage til snapshottet taget før opdateringen. Genstart bare og vælg snapshottet i opstartsmenuen fra før, du startede opdateringen.

![bootloader](images/bootloader.webp)

Hvis dine konfigurationsfiler på en eller anden måde er blevet beskadiget, kan du også udføre en Omarchy-geninstallation ved hjælp af `omarchy reinstall` i terminalen. Dette vil geninstallere alle standard Omarchy-pakker, sætte dig på stable og nedgradere alle pakker, der er for nye, og nulstille alle konfigurationsfiler. Bemærk, at alle dine brugerkonfigurationsændringer til Omarchy-standarderne vil blive overskrevet ved at gøre dette!
