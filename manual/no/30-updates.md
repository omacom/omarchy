# Oppdateringer

Omarchy og pakkene dine holdes oppdatert via _Oppdater > Omarchy_ i Omarchy-menyen (`Super + Space`).

Omarchy selv installeres som vanlige pacman-pakker fra [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), så en oppdatering installerer [den nyeste Omarchy-utgivelsen](https://github.com/omacom/omarchy/releases), kjører eventuelle ventende migreringer for å få systemet ditt i synk med det nyeste, og oppdaterer alle systempakker fra [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) og [AUR](https://aur.archlinux.org/) (hvis du har installert noen AUR-pakker).

Når nye utgivelser kommer, vises et sirkelpil-ikon til høyre for klokken din. Klikk på det, så starter oppdateringsprosessen.

![update-available](images/update-available.webp)

### Fire kanaler

Omarchy oppdateres via fire kanaler: stable, RC, edge og dev. Nye installasjoner starter på stable-kanalen, som følger de [offisielle utgivelsene](https://github.com/omacom/omarchy/releases/), samt [det stabile Omarchy Arch-speilet](https://github.com/omacom-io/omarchy-mirror) som ligger én måned bak det nyeste, slik at vi kan fange opp nye inkompatibiliteter som krever konfigurasjonsendringer før de skaper problemer for folk.

Men hvis du vil hjelpe til med å oppdage de potensielle problemene, kan du kjøre på edge-kanalen. Da vil Omarchy-pakkene dine følge de nyeste utviklingsbyggene, og du kan oppdatere til de nyeste Arch-pakkene så snart de er tilgjengelige. Du bør bare gjøre dette hvis du har erfaring med Linux og vet hvordan du gjenoppretter et system som har problemer.

Før hver nye store utgivelse gjør vi siste validering på RC-kanalen. Hvis du er interessert i å hjelpe til med siste finpuss, kom og heng i #omarchy-release-candidates på Discord.

Til slutt er det dev-kanalen, som kobler Omarchy direkte til en git-utsjekking av kildekoden i `~/omarchy`, kombinert med edge-pakkene. Du bør bare bruke denne kanalen hvis du er en erfaren Linux-bruker, jobber direkte med Omarchy og er villig til å tåle at ting går i stykker.

Du kan bytte mellom kanaler med _Oppdater > Kanal_ i Omarchy-menyen (eller `omarchy-channel-set` i terminalen).

### Bytte kjerne

Omarchy starter med sin egen `linux-omarchy`-kjerne, men du kan ha andre installert ved siden av, som standard Arch-kjernen `linux` eller et eksperimentelt bygg du tester. Når det finnes mer enn én, lister _Oppdater > Kjerne_ i Omarchy-menyen dem opp med en hake ved siden av den som starter som standard. Velg en annen, skriv inn passordet ditt én gang, så starter den etter neste omstart. De andre kjernene blir liggende i oppstartsmenyen, så du kan fortsatt velge en manuelt hvis den nye standarden gir deg problemer. I terminalen bruker du `omarchy-kernel` for å se gjeldende standard, `omarchy-kernel list` for det som er installert, og `omarchy-kernel set <kernel>` for å bytte.

### Fastvareoppdateringer

Pakkene dine er ikke det eneste som blir utdatert. Mange bærbare PC-er og mye tilbehør leverer BIOS-, SSD- og dokking-fastvare gjennom Linux Vendor Firmware Service, og _Oppdater > Fastvare_ i Omarchy-menyen henter og installerer det maskinvaren din venter på. Den installerer `fwupd` første gang du kjører den. Mye fastvare kan bare skrives under en omstart, så ikke bli overrasket om du blir bedt om en.

Når du må endre en innstilling i selve BIOS-en, holder du `Alt` i systemmenyen (`Super + Escape`), så blir _Start på nytt_ til _Start på nytt til BIOS_, som starter rett på nytt inn i fastvareoppsettet uten at du må treffe riktig tast ved oppstart. Fra terminalen er det `omarchy system firmware`.

### Advarsel om direkte pacman/yay-oppdateringer

Hvis du allerede kjenner Arch, kan du bli fristet til å bare kjøre `pacman -Syu` eller `yay -Syu` selv, men gjør du det, går du glipp av øyeblikksbildet, migreringene og konfigurasjonsoppdateringene som Omarchy kjører sammen med nye pakker. Derfor stopper Omarchy faktisk en direkte systemoppgradering og henviser deg til `omarchy update` i stedet. (Hvis du virkelig vet hva du driver med, forteller vakten deg hvordan du omgår den for én enkelt transaksjon.)

### Rulle tilbake dårlige oppdateringer

Hvis du noen gang får problemer etter en oppdatering, kan du rulle tilbake systemet til øyeblikksbildet som ble tatt før oppdateringen. Bare start på nytt og velg øyeblikksbildet fra før du startet oppdateringen i oppstartsmenyen.

![bootloader](images/bootloader.webp)

Hvis konfigurasjonsfilene dine på en eller annen måte har blitt ødelagt, kan du også reinstallere Omarchy med `omarchy reinstall` i terminalen. Det reinstallerer alle standard Omarchy-pakkene, setter deg på stable og nedgraderer pakker som er for nye, og tilbakestiller alle konfigurasjonsfilene. Merk at alle brukerendringene dine i Omarchy-standardene blir overskrevet når du gjør dette!
