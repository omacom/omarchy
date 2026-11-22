# Mac-støtte

## Omarchy for Apple Silicon

Omarchy for Apple Silicon er en offisiell Omacom-løsning, først utgitt med Omarchy 4.5. Den installeres ved siden av macOS, og du velger mellom de to når Macen starter.

Fikk du et varsel om Omarchy Mac? Gå til [Kommer du fra Omarchy Mac](#coming-from-omarchy-mac).

Den kjører på disse Macene:

| Mac | Chips |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Macer med M4 og nyere støttes ikke ennå. Støtte for M4 testes på edge-kanalen og kommer neste. Installasjonsprogrammet sjekker Macen din før det endrer noe.

På alle Macer med Apple Silicon, også M4 og nyere, kan du kjøre Omarchy i en virtuell maskin med [Try Omarchy](https://github.com/omacom/try-omarchy).

### Det trenger du

- macOS 15 Sequoia eller nyere, og en administratorkonto
- Ledig diskplass til Omarchy. Installasjonsprogrammet foreslår en størrelse og lar deg endre den.
- En sikkerhetskopi av Macen, strøm og en internettforbindelse. Installasjonen laster ned flere gigabyte.

### Installasjon

Du installerer fra macOS. Installer Omarchy Installer med [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Eller last ned den nyeste Omarchy Installer fra [utgivelsessiden](https://github.com/omacom/omarchy-mac-installer/releases) og åpne den.

Installasjonsprogrammet sjekker Macen din, viser deg planen og gjør plass til Omarchy ved å krympe macOS-partisjonen. macOS blir liggende på disken, og ingen USB-stasjon trengs. Når første trinn er ferdig, veileder det deg gjennom resten av oppsettet i macOS Recovery: slå av, hold inne av/på-knappen til "Loading startup options" vises, velg Omarchy og følg trinnene.

Ved første oppstart ber Omarchy om et passord som krypterer disken. Det finnes ingen gjenopprettingsnøkkel: glemmer du passordet, kan ikke Omarchy-filene dine gjenopprettes.

For å bytte mellom Omarchy og macOS senere, slå av, hold deretter inne av/på-knappen til oppstartsalternativene vises, og velg ett av dem.

### Kommer du fra Omarchy Mac

Omarchy Mac er nå en del av Omarchy for Apple Silicon, og alle Macer som kjørte den, støttes. Den nåværende installasjonen din fortsetter å kjøre, og systempakkene oppdateres fortsatt, men den får ikke flere Omarchy-oppdateringer. Det finnes ingen frist og ingen oppgradering på stedet: du sikkerhetskopierer, fjerner den gamle installasjonen, installerer på nytt og gjenoppretter. Trinn 2 til 5 skjer i macOS, så åpne denne siden på telefonen før du starter på nytt.

1. **Sikkerhetskopier fra Omarchy, bort fra Macen.** Å fjerne den gamle installasjonen sletter den, og macOS kan ikke lese Omarchy-disken. Kopier hjemmemappen din til en ekstern stasjon eller en annen datamaskin, inkludert SSH- og GPG-nøkler, nettleserprofiler og arbeid du ikke har pushet. Lagre pakkelisten med `pacman -Qqe > ~/packages.txt`. Sikkerhetskopier macOS også, siden både fjerning og installasjon endrer størrelsen på disken.
2. **Start Macen i macOS.** Slå av, hold inne av/på-knappen til oppstartsalternativene vises, og velg macOS.
3. **Installer Omarchy Installer** som vist i [Installasjon](#installing).
4. **Fjern den gamle installasjonen.** Åpne Omarchy Installer og velg Installation > Remove Omarchy. Den viser hva den vil slette, og gir plassen tilbake til macOS. Hvis den ikke kjenner igjen installasjonen din, stopper den uten å endre disken. Be om hjelp på [Discord](https://discord.gg/tXFUdasqhY) i stedet for å slette partisjoner for hånd, noe som kan slette macOS.
5. **Installer Omarchy for Apple Silicon** med installasjonsprogrammet.
6. **Gjenopprett filene dine.** Ta innstillingene tilbake litt om gangen i stedet for å kopiere hele `~/.config` over de nye standardene, siden gamle innstillinger kan overstyre dem.

### Greit å vite

- På MacBooker med M1 og M2 vekker du fra hvilemodus ved å åpne lokket eller trykke på av/på-knappen.
- Spørsmål eller problemer: spør på vår [Discord](https://discord.gg/tXFUdasqhY).

[README-en til installasjonsprogrammet](https://github.com/omacom/omarchy-mac-installer#readme) dekker utgivelseskanaler, oppdatering av installasjonsprogrammet og fjerning av Omarchy.

## Intel-Macer

I en enkel test klarte vi å oppnå 36 % bedre ytelse på en MacBook Pro fra 2019 bare ved å installere Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Installere Omarchy på Mac

Omarchy støtter for øyeblikket bare å være det **eneste** operativsystemet som er installert. Under installasjonen tørkes stasjonen, og macOS vil ikke lenger kunne startes.

Du kan fortsatt gjenopprette den senere via Internet Recovery hvis du vil.

I denne delen antar vi at du allerede har lest [Kom i gang](02-getting-started.md) og har USB-stasjonen klar. Hvis ikke, gjør det nå.

#### Deaktiver Secure Boot

Det er nødvendig å deaktivere Apples Secure Boot for å kunne starte fra den oppstartbare USB-en, så vel som operativsystemet. For å deaktivere den gjør du følgende:

1. Slå av Macen
2. Slå den på og trykk _umiddelbart_ og hold inne Command-R til du ser lasteskjermen
3. Velg brukeren din og skriv inn passordet hvis du blir bedt om det
4. Når du er på gjenopprettingsskjermen, velger du **Utilities > Startup Security Utility** fra menylinjen
5. Skriv inn passordet når du blir bedt om å autentisere deg
6. Velg "No Security" blant alternativene for Secure Boot
7. Velg "Allow booting from external or removable media" blant alternativene for External Boot

#### Start installasjonen

1. Sett inn USB-stasjonen
2. Start Macen på nytt og trykk _umiddelbart_ og hold inne Option til du ser en skjerm med oppstartsenheter
3. Velg den oransje EFI Boot-enheten
4. Fortsett med å [installere som normalt](02-getting-started.md)

Installasjonsprogrammet oppdager Mac-maskinvare og bruker nødvendige rettelser automatisk: Broadcom Wi-Fi-drivere og -fastvare, SPI-tastaturdriveren på MacBook-modellene som trenger den, og en NVMe-rettelse for hvilemodus på de samme modellene.

### Kjente begrensninger

Medlemmer av fellesskapet jobber hele tiden med løsninger på disse utfordringene, så hvis disse er problematiske for deg, bli med i #omarchy-on-other på vår [Discord](https://discord.gg/tXFUdasqhY) og se om det finnes oppdaterte metoder for å løse dem.

#### Enheter med T1-brikke

Apple T1-brikken ble introdusert sent i 2016 og ble bare brukt i første generasjon MacBook Pro-modeller med Touch Bar.
- MacBook Pro 13-tommers (2016, to Thunderbolt 3-porter) – Modell: A1706
- MacBook Pro 13-tommers (2016, fire Thunderbolt 3-porter) – Modell: A1708
- MacBook Pro 15-tommers (2016) – Modell: A1707

#### Kjente problemer

- Touch Bar fungerer ikke
- Lyden fungerer ikke

#### Enheter med T2-brikke

Apple T2 Security Chip ble introdusert i 2017. T2-brikken ble avviklet med overgangen til Apple silicon (M-serien) fra 2020.

- iMac Pro (2017) – Modell: A1862
- MacBook Pro 13-tommers (2018, fire Thunderbolt 3-porter) – Modell: A1989
- MacBook Pro 15-tommers (2018) – Modell: A1990
- MacBook Air (Retina, 13-tommers, 2018) – Modell: A1932
- Mac mini (2018) – Modell: A1998
- MacBook Pro 13-tommers (2019, to Thunderbolt 3-porter) – Modell: A2159
- MacBook Pro 13-tommers (2019, fire Thunderbolt 3-porter) – Modell: A2178
- MacBook Pro 15-tommers (2019) – Modell: A1990
- iMac (Retina 5K, 27-tommers, 2020) – Modell: A2115 (iMac20,1 og iMac20,2)
- MacBook Pro 13-tommers (2020, to Thunderbolt 3-porter) – Modell: A2265
- MacBook Pro 15-tommers (2020) – Modell: A1990

På disse modellene setter installasjonsprogrammet automatisk opp den patchede `linux-t2`-kjernen, T2-lydkonfigurasjonen, Apples Broadcom Wi-Fi/Bluetooth-fastvare og viftestyring via `t2fanrd`. Touch Bar kjører på kjernens innebygde Boot Camp-lignende støtte.

#### iMac Retina 5K (2017)

27-tommers iMac fra 2017 har ingen T2-brikke, så installasjonsprogrammet setter den opp som de andre Intel-Macene.

- iMac (Retina 5K, 27-tommers, 2017) – Modell: A1419

#### Kjente problemer

- Skjermen kjører ikke på den opprinnelige oppløsningen 5120×2880: panelet er to fliser, og standarddriveren lyser bare opp én
- Lyden fungerer ikke
- Lysstyrkekontrollen har ingen effekt
- Hvilemodus får maskinen til å henge; bare det å slå den av og på igjen får den tilbake

En fellesskapspatcher for denne modellen fikser skjerm, lyd og lysstyrke: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
