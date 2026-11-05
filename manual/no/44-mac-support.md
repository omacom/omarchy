# Mac-støtte

Omarchy har innebygd støtte for **Intel-Mac-er**. Det finnes et par kjente begrensninger akkurat nå, men så lenge du er klar over dem og er OK med det, kan du blåse nytt liv i de gamle Mac-ene dine ved å installere Omarchy.

Vær oppmerksom på at installasjon på en Mac med M-serien ikke støttes direkte på dette tidspunktet. Du kan finne ut mer om statusen for dette i #omarchy-on-other på vår [Discord](https://discord.gg/tXFUdasqhY).

I en enkel test klarte vi å oppnå 36 % bedre ytelse på en 2019 MacBook Pro bare ved å installere Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Installere Omarchy på Mac

Omarchy støtter for øyeblikket bare å være det **eneste** operativsystemet som er installert. Under installasjonen blir disken slettet, og MacOS vil ikke lenger være oppstartbart.

Du kan fortsatt gjenopprette det senere via Internet Recovery hvis du skulle ønske det.

I denne delen antar vi at du allerede har lest [Kom i gang](02-getting-started.md) og har USB-stasjonen din klar. Hvis du ikke har det, gjør det nå.

#### Deaktiver Secure Boot

Det er nødvendig å deaktivere Apples Secure Boot for å starte opp fra den oppstartbare USB-en, så vel som operativsystemet. For å deaktivere den gjør du følgende:

1. Slå av Mac-en din
2. Slå den på og hold _umiddelbart_ Command-R inne til du ser lasteskjermen
3. Velg brukeren din og skriv inn passordet ditt hvis du blir bedt om det
4. Når du er på gjenopprettingsskjermen, velger du **Utilities > Startup Security Utility** fra menylinjen
5. Skriv inn passordet ditt når du blir bedt om å autentisere
6. Velg "No Security" blant alternativene for Secure Boot
7. Velg "Allow booting from external or removable media" blant alternativene for External Boot

#### Start installasjonen

1. Sett inn USB-stasjonen
2. Start Mac-en på nytt og hold _umiddelbart_ Option inne til du ser en skjerm med oppstartsenheter
3. Velg den oransje EFI Boot-enheten
4. Fortsett med [installasjonen som normalt](02-getting-started.md)

Installasjonsprogrammet oppdager Mac-maskinvare og tar i bruk de nødvendige fiksene automatisk: Broadcom Wi-Fi-drivere og -fastvare, SPI-tastaturdriveren på MacBook-modellene som trenger den, og en NVMe-fiks for hvilemodus for de samme modellene.

### Kjente begrensninger

Medlemmer av fellesskapet jobber hele tiden med løsninger på disse utfordringene, så hvis de er problematiske for deg, bli med i #omarchy-on-other på vår [Discord](https://discord.gg/tXFUdasqhY) og se om det finnes oppdaterte metoder for å løse dem.

#### Enheter med T1-brikke

Apple T1-brikken ble introdusert i slutten av 2016 og ble utelukkende brukt i første generasjon MacBook Pro-modeller med Touch Bar.
- MacBook Pro 13-tommers (2016, to Thunderbolt 3-porter) – Modell: A1706
- MacBook Pro 13-tommers (2016, fire Thunderbolt 3-porter) – Modell: A1708
- MacBook Pro 15-tommers (2016) – Modell: A1707

#### Kjente problemer

- Touch Bar fungerer ikke
- Lyden fungerer ikke

#### Enheter med T2-brikke

Apple T2 Security Chip ble introdusert i 2017. T2-brikken ble avviklet med overgangen til Apple silicon (M-seriebrikker) fra 2020.

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

På disse modellene setter installasjonsprogrammet automatisk opp den lappede `linux-t2`-kjernen, T2-lydkonfigurasjonen, Apples Broadcom Wi-Fi/Bluetooth-fastvare og viftestyring via `t2fanrd`. Touch Bar kjører på kjernens innebygde Boot Camp-lignende støtte.

#### iMac Retina 5K (2017)

27-tommers iMac-en fra 2017 har ingen T2-brikke, så installasjonsprogrammet setter den opp som de andre Intel-Mac-ene.

- iMac (Retina 5K, 27-tommers, 2017) – Modell: A1419

#### Kjente problemer

- Skjermen kjører ikke med sin innebygde oppløsning på 5120×2880: panelet består av to fliser, og standarddriveren lyser bare opp den ene
- Lyden fungerer ikke
- Lysstyrkekontrollen har ingen effekt
- Hvilemodus får maskinen til å henge; bare det å slå den av og på igjen får den tilbake

En fellesskapsutviklet lapper for denne modellen fikser skjerm, lyd og lysstyrke: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
