# Oppdateringer

Omarchy og pakkene dine holdes oppdatert via _Oppdater > Omarchy_ i Omarchy-menyen (`Super + Space`).

Omarchy selv installeres som vanlige pacman-pakker fra [Omarchy-pakkerepositoriet](https://github.com/omacom-io/omarchy-pkgs), så en oppdatering installerer [den nyeste Omarchy-utgivelsen](https://github.com/omacom/omarchy/releases), kjører eventuelle ventende migreringer for å få systemet ditt i synk med det nyeste, og oppdaterer alle systempakker fra [Omarchy Arch-speilet](https://github.com/omacom-io/omarchy-mirror) og [AUR](https://aur.archlinux.org/) (hvis du har installert noen AUR-pakker).

Når nye utgivelser kommer, vises et sirkelpil-ikon til høyre for klokken din. Klikk på det, så starter oppdateringsprosessen.

![update-available](images/update-available.webp)

### Fire kanaler

Omarchy oppdateres via fire kanaler: stable, RC, edge og dev. Nye installasjoner starter på stable-kanalen, som følger de [offisielle utgivelsene](https://github.com/omacom/omarchy/releases/), samt det [stabile Omarchy Arch-speilet](https://github.com/omacom-io/omarchy-mirror) som ligger én måned bak det nyeste, slik at vi kan fange opp eventuelle nye inkompatibiliteter som krever konfigurasjonsendringer før de skaper problemer for folk.

Men hvis du vil hjelpe til med å oppdage slike potensielle problemer, kan du kjøre på edge-kanalen. Da vil Omarchy-pakkene dine følge de nyeste utviklingsbyggene, og du kan oppdatere til de nyeste Arch-pakkene så snart de er tilgjengelige. Du bør bare gjøre dette hvis du er erfaren med Linux og vet hvordan du gjenoppretter et system som har problemer.

Før hver nye større utgivelse gjør vi siste validering på RC-kanalen. Hvis du har lyst til å hjelpe til med siste finpuss, kom og heng i #omarchy-release-candidates på Discord.

Til slutt er det dev-kanalen, som kobler Omarchy direkte til en git-utsjekking av kildekoden i `~/omarchy`, kombinert med edge-pakkene. Du bør bare bruke denne kanalen hvis du er en erfaren Linux-bruker, jobber direkte på Omarchy og er villig til å tåle at ting går i stykker.

Du kan bytte mellom kanaler med _Oppdater > Kanal_ fra Omarchy-menyen (eller `omarchy channel set <stable|rc|edge|dev>` i terminalen, med `omarchy channel current` for å se hvor du er).

### Bytte kjerne

Omarchy starter med sin egen `linux-omarchy`-kjerne, men du kan ha andre installert ved siden av, som standard Arch-`linux`-kjernen eller et eksperimentelt bygg du tester. Når det er mer enn én, lister _Oppdater > Kjerne_ i Omarchy-menyen dem opp med en hake ved siden av den som starter som standard. Velg en annen, skriv inn passordet ditt én gang, så starter den etter neste omstart. De andre kjernene blir liggende i oppstartsmenyen, så du kan fortsatt velge en manuelt hvis den nye standarden gir deg problemer. I terminalen bruker du `omarchy kernel` for å se gjeldende standard, `omarchy kernel list` for hva som er installert, og `omarchy kernel set <kernel>` for å bytte.

### Fastvareoppdateringer

Pakkene dine er ikke det eneste som blir utdatert. Mange bærbare PC-er og eksterne enheter leverer BIOS-, SSD- og dokkfastvare gjennom Linux Vendor Firmware Service, og _Oppdater > Fastvare_ i Omarchy-menyen henter og installerer det maskinvaren din måtte ha ventende. Den installerer `fwupd` første gang du kjører den. Mye fastvare kan bare skrives under en omstart, så ikke bli overrasket om du blir bedt om en.

Når du trenger å endre en innstilling i selve BIOS-en, holder du `Alt` i systemmenyen (`Super + Escape`), og _Start på nytt_ blir til _Start på nytt til BIOS_, som starter rett på nytt inn i fastvareoppsettet uten at du må treffe riktig tast ved oppstart. Fra terminalen bruker du `omarchy system firmware`.

### Advarsel om direkte pacman/yay-oppdateringer

Hvis du allerede er kjent med Arch, kan du bli fristet til å bare kjøre `pacman -Syu` eller `yay -Syu` selv, men gjør du det, går du glipp av øyeblikksbildet, migreringene og konfigurasjonsoppdateringene som Omarchy kjører sammen med nye pakker. Derfor stopper Omarchy faktisk en direkte systemoppgradering og viser deg til `omarchy update` i stedet. (Hvis du virkelig vet hva du driver med, forteller vakten deg hvordan du omgår den for én enkelt transaksjon.)

### Rulle tilbake dårlige oppdateringer

Hvis du noen gang får et problem etter en oppdatering, kan du rulle tilbake systemet ditt til øyeblikksbildet som ble tatt før oppdateringen. Bare start på nytt og velg øyeblikksbildet i oppstartsmenyen fra før du startet oppdateringen.

![bootloader](images/bootloader.webp)

Hvis konfigurasjonsfilene dine på en eller annen måte har blitt ødelagt, kan du også reinstallere Omarchy med `omarchy reinstall` i terminalen. Dette reinstallerer alle standard Omarchy-pakkene, setter deg på stable (edge på Apple Silicon) og nedgraderer eventuelle pakker som er for nye, og tilbakestiller alle konfigurasjonsfilene. Merk at alle brukerendringene dine i Omarchy-standardkonfigurasjonen blir overskrevet når du gjør dette!
