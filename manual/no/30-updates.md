# Oppdateringer

Omarchy og pakkene dine holdes oppdaterte via _Oppdater > Omarchy_ i Omarchy-menyen (`Super + Space`).

Selve Omarchy installeres som vanlige pacman-pakker fra [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), så en oppdatering installerer [den nyeste Omarchy-utgivelsen](https://github.com/omacom/omarchy/releases), kjører eventuelle ventende migreringer for å få systemet ditt synkronisert med det nyeste, og oppdaterer alle systempakker fra [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) og [AUR](https://aur.archlinux.org/) (hvis du har installert noen AUR-pakker).

Når nye utgivelser kommer, vises et sirkulært pilikon til høyre for klokka di. Klikk på det, så starter oppdateringsprosessen.

![update-available](images/update-available.webp)

### Fire kanaler

Omarchy oppdateres langs fire kanaler: stable, RC, edge og dev. Nye installasjoner starter på stable-kanalen, som følger [de offisielle utgivelsene](https://github.com/omacom/omarchy/releases/), i tillegg til [den stabile Omarchy Arch-speilingen](https://github.com/omacom-io/omarchy-mirror) som ligger én måned bak det nyeste, slik at vi kan fange opp nye inkompatibiliteter som krever konfigurasjonsendringer før de volder problemer for folk.

Men hvis du vil hjelpe til med å oppdage de potensielle problemene, kan du kjøre på edge-kanalen. Den holder Omarchy-pakkene dine på de nyeste utviklingsbyggene og lar deg oppdatere til de nyeste Arch-pakkene så snart de er tilgjengelige. Du bør bare gjøre dette hvis du har erfaring med Linux og vet hvordan du gjenoppretter et system med problemer.

Før enhver ny stor utgivelse gjør vi den siste valideringen med RC-kanalen. Hvis du er interessert i å hjelpe til med siste finpuss, kom til #omarchy-release-candidates på Discord.

Til slutt er det dev-kanalen, som lenker Omarchy direkte til en git-utsjekking av kildekoden i `~/omarchy`, kombinert med edge-pakkene. Du bør bare bruke denne kanalen hvis du er en erfaren Linux-bruker, jobber direkte på Omarchy og er villig til å tåle at ting går i stykker.

Du kan bytte mellom kanaler med _Oppdater > Kanal_ fra Omarchy-menyen (eller `omarchy-channel-set` i terminalen).

### Fastvareoppdateringer

Pakkene dine er ikke det eneste som blir utdatert. Mange bærbare datamaskiner og eksterne enheter leverer BIOS-, SSD- og dock-fastvare via Linux Vendor Firmware Service, og _Oppdater > Fastvare_ i Omarchy-menyen henter og installerer det maskinvaren din venter på. Den installerer `fwupd` første gang du kjører den. Mye fastvare kan bare skrives under en omstart, så ikke bli overrasket over å bli bedt om en.

### Advarsel om direkte pacman/yay-oppdateringer

Hvis du allerede kjenner Arch, kan du bli fristet til å bare kjøre `pacman -Syu` eller `yay -Syu` selv, men hvis du gjør det, går du glipp av øyeblikksbildet, migreringene og konfigurasjonsoppdateringene som Omarchy kjører sammen med nye pakker. Derfor stopper Omarchy faktisk en direkte systemoppgradering og peker deg til `omarchy update` i stedet. (Hvis du virkelig vet hva du gjør, forteller vakten deg hvordan du omgår den for én enkelt transaksjon.)

### Rulle tilbake dårlige oppdateringer

Hvis du noen gang får problemer etter en oppdatering, kan du rulle systemet tilbake til øyeblikksbildet som ble tatt før oppdateringen. Bare start på nytt og velg øyeblikksbildet i oppstartsmenyen fra før du startet oppdateringen.

![bootloader](images/bootloader.webp)

Hvis konfigurasjonsfilene dine på en eller annen måte er blitt ødelagt, kan du også reinstallere Omarchy med `omarchy reinstall` i terminalen. Dette reinstallerer alle Omarchy-standardpakkene, setter deg på stable og nedgraderer eventuelle pakker som er for nye, og tilbakestiller alle konfigurasjonsfilene. Merk at alle dine endringer i Omarchy-standardene overskrives hvis du gjør dette!
