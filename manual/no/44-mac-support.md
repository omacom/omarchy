# Mac-støtte

Omarchy har innebygd støtte for **Intel Mac-er**. Det er et par kjente begrensninger for øyeblikket, men så lenge du er klar over og OK med dem, kan du puste nytt liv i de gamle Mac-ene dine ved å laste inn Omarchy.

Vær oppmerksom på at installasjon på en M-serie Mac ikke støttes direkte for øyeblikket. Du kan finne ut mer om statusen for dette i #omarchy-on-other på [Discorden](https://discord.gg/tXFUdasqhY) vår.

I en enkel test klarte vi å oppnå 36 % ytelsesgevinst på en 2019 MacBook Pro bare ved å installere Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Installere Omarchy på Mac

Omarchy støtter for øyeblikket bare å være det **eneste** operativsystemet installert. Under installasjonen vil disken bli slettet, og MacOS vil ikke lenger være oppstartbar.

Du kan fortsatt gjenopprette det senere via Internet Recovery hvis du vil.

For denne delens skyld antar vi at du allerede har gjennomgått [Kom i gang](02-getting-started.md) og har USB-stasjonen klar. Hvis du ikke har det, gjør det nå.

#### Deaktiver Secure Boot

Det er nødvendig å deaktivere Apples Secure Boot for å starte opp den oppstartbare USB-en, så vel som operativsystemet. For å deaktivere den, gjør følgende:

1. Slå av Mac-en
2. Slå den på og trykk _umiddelbart_ og hold Command-R til du ser lasteskjermen vises
3. Velg brukeren din og skriv inn passordet hvis du blir bedt om det
4. Når du er på gjenopprettingsskjermen, velg **Utilities > Startup Security Utility** fra menylinjen
5. Skriv inn passordet ditt når du blir bedt om å autentisere
6. Velg «No Security» fra Secure Boot-alternativene
7. Velg «Allow booting from external or removable media» fra External Boot-alternativene

#### Start installasjonen

1. Sett inn USB-stasjonen
2. Start Mac-en på nytt og trykk _umiddelbart_ og hold Option til du ser en skjerm med oppstartsenheter
3. Velg den oransje EFI Boot-enheten
4. Fortsett med [installasjonen som normalt](02-getting-started.md)

Installasjonsprogrammet oppdager Mac-maskinvare og bruker de nødvendige rettelsene automatisk: Broadcom Wi-Fi-drivere og firmware, SPI-tastaturdriveren på MacBook-modellene som trenger den, og en NVMe-hvilerettelse for de samme modellene.

### Kjente begrensninger

Medlemmer av fellesskapet jobber stadig med løsninger på disse utfordringene, så hvis disse er problematiske for deg, bli med i #omarchy-on-other på [Discorden](https://discord.gg/tXFUdasqhY) vår og se om det finnes oppdaterte metoder for å løse dem.

#### Enheter med T1-brikke

Apple T1-brikken ble introdusert sent i 2016 og brukt utelukkende i førstegenerasjons MacBook Pro-modeller med Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Kjente problemer

- Touch Bar fungerer ikke
- Lyd fungerer ikke

#### Enheter med T2-brikke

Apple T2 Security Chip ble introdusert i 2017. T2-brikken ble avviklet med overgangen til Apple silicon (M-seriebrikker) fra 2020.

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

På disse modellene setter installasjonsprogrammet automatisk opp den patchede `linux-t2`-kjernen, T2-lydkonfigurasjonen, Apples Broadcom Wi-Fi/Bluetooth-firmware og viftekontroll via `t2fanrd`. Touch Bar kjører på kjernens innebygde Boot Camp-lignende støtte.
