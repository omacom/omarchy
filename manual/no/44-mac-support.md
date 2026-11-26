# Mac-støtte

## Omarchy for Apple Silicon

Omarchy for Apple Silicon er en offisiell Omacom-løsning, først utgitt med Omarchy 4.5. Den installeres ved siden av macOS, og du velger mellom de to når Macen starter.

Fikk du et varsel om Omarchy Mac? Gå til [Kommer fra Omarchy Mac](#coming-from-omarchy-mac).

Den kjører på disse Macene:

| Mac | Brikker |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4 og nyere Macer støttes ikke ennå. Støtte for M4 testes på edge-kanalen og kommer som det neste. Installasjonsprogrammet sjekker Macen din før det endrer noe.

På alle Apple Silicon-Macer, inkludert M4 og nyere, kan du kjøre Omarchy i en virtuell maskin med [Try Omarchy](https://github.com/omacom/try-omarchy).

### Hva du trenger

- macOS 15 Sequoia eller nyere, og en administratorkonto
- Ledig diskplass til Omarchy. Installasjonsprogrammet foreslår en størrelse og lar deg endre den.
- En sikkerhetskopi av Macen, strøm og en internettforbindelse. Installasjonen laster ned flere gigabyte.

### Installasjon

Du installerer fra macOS. Installer Omarchy Installer med [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Eller last ned den nyeste Omarchy Installer fra [utgivelsessiden](https://github.com/omacom/omarchy-mac-installer/releases) og åpne den.

Installasjonsprogrammet sjekker Macen din, viser deg planen og gjør plass til Omarchy ved å krympe macOS-partisjonen. macOS blir værende på disken, og ingen USB-stasjon trengs. Når første trinn er ferdig, veileder det deg gjennom å fullføre oppsettet i macOS Recovery: slå av, hold inne av/på-knappen til «Loading startup options» vises, velg Omarchy og følg trinnene.

Ved første oppstart ber Omarchy om et passord som krypterer disken. Det finnes ingen gjenopprettingsnøkkel: Hvis du glemmer passordet, kan ikke Omarchy-filene dine gjenopprettes.

For å bytte mellom Omarchy og macOS senere slår du av, holder deretter inne av/på-knappen til oppstartsalternativene vises og velger ett av dem.

### Kommer fra Omarchy Mac

Omarchy Mac er nå en del av Omarchy for Apple Silicon, og alle Macer som kjørte den, støttes. Den nåværende installasjonen din fortsetter å kjøre, og systempakkene oppdateres fortsatt, men den får ikke flere Omarchy-oppdateringer. Det er ingen frist og ingen oppgradering på stedet: Du sikkerhetskopierer, fjerner den gamle installasjonen, installerer på nytt og gjenoppretter. Trinn 2 til 5 skjer i macOS, så åpne denne siden på telefonen før du starter på nytt.

1. **Sikkerhetskopier fra Omarchy, bort fra Macen.** Å fjerne den gamle installasjonen sletter den, og macOS kan ikke lese Omarchy-disken. Kopier hjemmemappen din til en ekstern stasjon eller en annen datamaskin, inkludert SSH- og GPG-nøkler, nettleserprofiler og arbeid som ikke er pushet. Lagre pakkelisten din med `pacman -Qqe > ~/packages.txt`. Sikkerhetskopier macOS også, siden både fjerning og installasjon endrer størrelsen på disken.
2. **Start Macen i macOS.** Slå av, hold inne av/på-knappen til oppstartsalternativene vises, og velg macOS.
3. **Installer Omarchy Installer** som vist i [Installasjon](#installing).
4. **Fjern den gamle installasjonen.** Åpne Omarchy Installer og velg Installation > Remove Omarchy. Den viser hva den vil slette, og gir plassen tilbake til macOS. Hvis den ikke gjenkjenner installasjonen din, stopper den uten å endre disken. Be om hjelp i [Discord](https://discord.gg/tXFUdasqhY) i stedet for å slette partisjoner for hånd, noe som kan slette macOS.
5. **Installer Omarchy for Apple Silicon** med installasjonsprogrammet.
6. **Gjenopprett filene dine.** Ta innstillingene dine tilbake litt etter litt i stedet for å kopiere hele `~/.config` over de nye standardinnstillingene, siden gamle innstillinger kan overstyre dem.

### Godt å vite

- På M1- og M2-MacBooker vekker du fra dvale ved å åpne lokket eller trykke på av/på-knappen.
- Spørsmål eller problemer: Spør i [Discord](https://discord.gg/tXFUdasqhY) vår.

[README-filen til installasjonsprogrammet](https://github.com/omacom/omarchy-mac-installer#readme) dekker utgivelseskanaler, oppdatering av installasjonsprogrammet og fjerning av Omarchy.

## Intel-Macer

I en enkel test klarte vi å oppnå 36 % bedre ytelse på en 2019 MacBook Pro bare ved å installere Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Installere Omarchy på Mac

Omarchy støtter for øyeblikket bare å være det **eneste** operativsystemet som er installert. Under installasjonen tømmes stasjonen, og MacOS kan ikke lenger startes.

Du kan fortsatt gjenopprette det senere via Internet Recovery hvis du vil.

I denne delen antar vi at du allerede har lest [Getting Started](02-getting-started.md) og har USB-stasjonen klar. Hvis du ikke har det, gjør det nå.

#### Deaktiver Secure Boot

Det er nødvendig å deaktivere Apples Secure Boot for å starte fra den oppstartbare USB-en, og også operativsystemet. For å deaktivere den gjør du følgende:

1. Slå av Macen
2. Slå den på og trykk og hold _umiddelbart_ inne Command-R til du ser lasteskjermen vises
3. Velg brukeren din og skriv inn passordet ditt hvis du blir bedt om det
4. Når du er på gjenopprettingsskjermen, velger du **Utilities > Startup Security Utility** fra menylinjen
5. Skriv inn passordet ditt når du blir bedt om å autentisere deg
6. Velg «No Security» fra Secure Boot-alternativene
7. Velg «Allow booting from external or removable media» fra External Boot-alternativene

#### Start installasjonen

1. Sett inn USB-stasjonen
2. Start Macen på nytt og trykk og hold _umiddelbart_ inne Option til du ser en skjerm med oppstartsenheter
3. Velg den oransje EFI Boot-enheten
4. Fortsett med [installasjonen som normalt](02-getting-started.md)

Installasjonsprogrammet oppdager Mac-maskinvare og bruker de nødvendige fiksene automatisk: Broadcom Wi-Fi-drivere og -fastvare, FaceTime HD-kameradriveren på maskiner med en Broadcom 1570 (fastvaren lastes ned fra Apple når Macen er på nett, siden installasjonsprogrammet fungerer frakoblet), SPI-tastaturdriveren på MacBook-modellene som trenger den, og en NVMe-fiks for hvilemodus på de samme modellene.

### Kjente begrensninger

Medlemmer av fellesskapet jobber hele tiden med løsninger på disse utfordringene, så hvis dette er problematisk for deg, bli med i #omarchy-on-other i [Discord](https://discord.gg/tXFUdasqhY) vår og se om det finnes oppdaterte metoder for å løse dem.

#### FaceTime HD-kamera

Kameradriveren henger maskinen hvis den er lastet når Macen går i dvale, så den lastes ut først. Den kan ikke lastes ut mens en app har kameraet åpent, så dvale avbrytes med et varsel som navngir appen: Lukk den og gå i dvale igjen. Det inkluderer å gå i dvale automatisk ved kritisk batteri, og suspend-then-hibernate, som avvises før den suspenderes. Vanlig suspendering avvises av selve driveren mens kameraet er åpent, uten et varsel.

Kameraets fastvare lastes ned fra Apple, så kameraet fungerer først når Macen har vært på nett. Nedlastingen starter ved oppstart og prøves på nytt hvert 15. minutt mens nettverket er problemet; hvis Apples fil har endret seg, stopper den og venter på en Omarchy-oppdatering. Hvis kameraet ikke vises, forteller `journalctl -u facetimehd-firmware-fetcher` hvorfor, `sudo systemctl restart facetimehd-firmware-fetcher` prøver igjen, og en omstart laster driveren hvis nedlastingen er ferdig, men kameraet fortsatt ikke er der.

#### Enheter med T1-brikke

Apple T1-brikken ble introdusert sent i 2016 og brukt utelukkende i førstegenerasjons MacBook Pro-modellene med Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Kjente problemer

- Touch Bar fungerer ikke
- Lyd fungerer ikke

#### Enheter med T2-brikke

Apple T2 Security Chip ble introdusert i 2017. T2-brikken ble avviklet med overgangen til Apple silicon (M-series chips) fra 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

På disse modellene setter installasjonsprogrammet automatisk opp den patchede `linux-t2`-kjernen, T2-lydkonfigurasjonen, Apples Broadcom Wi-Fi/Bluetooth-fastvare og viftestyring via `t2fanrd`. Touch Bar kjører på kjernens innebygde Boot Camp-lignende støtte.

#### iMac Retina 5K (2017)

2017 27-inch iMac har ingen T2-brikke, så installasjonsprogrammet setter den opp som de andre Intel-Macene.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Kjente problemer

- Skjermen kjører ikke på den opprinnelige oppløsningen 5120×2880: Panelet er to fliser, og standarddriveren lyser bare opp én
- Lyd fungerer ikke
- Lysstyrkekontrollen har ingen effekt
- Dvale henger maskinen; bare en av- og påslåing får den tilbake

En fellesskapspatcher for denne modellen fikser skjerm, lyd og lysstyrke: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
