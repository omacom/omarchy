# Mac-understøttelse

## Omarchy til Apple Silicon

Omarchy til Apple Silicon er en officiel Omacom-løsning, der først blev udgivet med Omarchy 4.5. Det installeres ved siden af macOS, og du vælger mellem de to, når din Mac starter.

Fik du en besked om Omarchy Mac? Gå til [Kommer du fra Omarchy Mac](#coming-from-omarchy-mac).

Det kører på disse Macs:

| Mac | Chips |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4 og nyere Macs understøttes ikke endnu. M4-understøttelse testes på edge-kanalen og kommer som det næste. Installationsprogrammet tjekker din Mac, før det ændrer noget.

På enhver Apple Silicon Mac, herunder M4 og nyere, kan du køre Omarchy i en virtuel maskine med [Try Omarchy](https://github.com/omacom/try-omarchy).

### Det skal du bruge

- macOS 15 Sequoia eller nyere og en administratorkonto
- Ledig diskplads til Omarchy. Installationsprogrammet foreslår en størrelse og lader dig ændre den.
- En backup af din Mac, strøm og en internetforbindelse. Installationen downloader flere gigabyte.

### Installation

Du installerer fra macOS. Installer Omarchy Installer med [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Eller download det nyeste Omarchy Installer fra dets [udgivelsesside](https://github.com/omacom/omarchy-mac-installer/releases) og åbn det.

Installationsprogrammet tjekker din Mac, viser dig planen og gør plads til Omarchy ved at formindske macOS-partitionen. macOS bliver på disken, og der er ikke brug for et USB-drev. Når den første fase er færdig, guider det dig gennem at færdiggøre opsætningen i macOS Recovery: luk ned, hold tænd/sluk-knappen nede, indtil "Loading startup options" vises, vælg Omarchy, og følg trinnene.

Ved første opstart beder Omarchy om en adgangskode, der krypterer dets disk. Der findes ingen gendannelsesnøgle: hvis du glemmer adgangskoden, kan dine Omarchy-filer ikke gendannes.

For at skifte mellem Omarchy og macOS senere skal du lukke ned, derefter holde tænd/sluk-knappen nede, indtil startindstillingerne vises, og vælge en af dem.

### Kommer du fra Omarchy Mac

Omarchy Mac er nu en del af Omarchy til Apple Silicon, og alle Macs, der kørte det, understøttes. Din nuværende installation bliver ved med at køre, og dens systempakker opdateres stadig, men den får ikke flere Omarchy-opdateringer. Der er ingen deadline og ingen opgradering på stedet: du tager backup, fjerner den gamle installation, installerer fra bunden og gendanner. Trin 2 til 5 foregår i macOS, så åbn denne side på din telefon, før du genstarter.

1. **Tag backup fra Omarchy, væk fra Mac'en.** Fjernelse af den gamle installation sletter den, og macOS kan ikke læse Omarchy-disken. Kopier din hjemmemappe til et eksternt drev eller en anden computer, herunder SSH- og GPG-nøgler, browserprofiler og arbejde, der ikke er pushet. Gem din pakkeliste med `pacman -Qqe > ~/packages.txt`. Tag også backup af macOS, da både fjernelse og installation ændrer størrelsen på dens disk.
2. **Start din Mac i macOS.** Luk ned, hold tænd/sluk-knappen nede, indtil startindstillingerne vises, og vælg macOS.
3. **Installer Omarchy Installer** som vist i [Installation](#installing).
4. **Fjern den gamle installation.** Åbn Omarchy Installer, og vælg Installation > Remove Omarchy. Det viser, hvad det vil slette, og giver pladsen tilbage til macOS. Hvis det ikke genkender din installation, stopper det uden at ændre disken. Bed om hjælp i [Discord](https://discord.gg/tXFUdasqhY) i stedet for at slette partitioner manuelt, hvilket kan slette macOS.
5. **Installer Omarchy til Apple Silicon** med installationsprogrammet.
6. **Gendan dine filer.** Få dine indstillinger tilbage lidt ad gangen i stedet for at kopiere hele `~/.config` over de nye standardindstillinger, da gamle indstillinger kan tilsidesætte dem.

### Værd at vide

- På M1- og M2-MacBooks vågner den fra dvale, når du åbner låget eller trykker på tænd/sluk-knappen.
- Spørgsmål eller problemer: spørg i vores [Discord](https://discord.gg/tXFUdasqhY).

[Installationsprogrammets README](https://github.com/omacom/omarchy-mac-installer#readme) dækker udgivelseskanaler, opdatering af installationsprogrammet og fjernelse af Omarchy.

## Intel-Macs

I en simpel test kunne vi opnå 36 % ydelsesforbedring på en MacBook Pro fra 2019 bare ved at installere Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Installation af Omarchy på Mac

Omarchy understøtter i øjeblikket kun at være det **eneste** OS installeret. Under installationen bliver drevet slettet, og MacOS vil ikke længere kunne startes.

Du kan stadig gendanne det senere via Internet Recovery, hvis du vil.

I denne del antager vi, at du allerede har gennemgået [Getting Started](02-getting-started.md) og har dit USB-drev klar. Hvis du ikke har det, så gør det nu.

#### Deaktiver Secure Boot

Det er nødvendigt at deaktivere Apples Secure Boot for at kunne starte fra det bootbare USB-drev såvel som OS'et. For at deaktivere det skal du gøre følgende:

1. Sluk din Mac
2. Tænd den, og tryk _med det samme_ på Command-R og hold det nede, indtil du ser indlæsningsskærmen vises
3. Vælg din bruger, og indtast din adgangskode, hvis du bliver bedt om det
4. Når du er på gendannelsesskærmen, skal du vælge **Utilities > Startup Security Utility** i menulinjen
5. Indtast din adgangskode, når du bliver bedt om at godkende
6. Vælg "No Security" i indstillingerne for Secure Boot
7. Vælg "Allow booting from external or removable media" i indstillingerne for External Boot

#### Start installationen

1. Indsæt USB-drevet
2. Genstart din Mac, og tryk _med det samme_ på Option og hold det nede, indtil du ser en skærm med bootenheder
3. Vælg den orange EFI Boot-enhed
4. Fortsæt med [installationen som normalt](02-getting-started.md)

Installationsprogrammet registrerer Mac-hardware og anvender automatisk de nødvendige rettelser: Broadcom Wi-Fi-drivere og -firmware, FaceTime HD-kameradriveren på maskiner med en Broadcom 1570 (dens firmware downloades fra Apple, når Mac'en er online, da installationsprogrammet arbejder offline), SPI-tastaturdriveren på de MacBook-modeller, der har brug for den, og en NVMe-rettelse til suspend på de samme modeller.

### Kendte begrænsninger

Medlemmer af fællesskabet arbejder konstant på løsninger på disse udfordringer, så hvis de er problematiske for dig, så deltag i #omarchy-on-other i vores [Discord](https://discord.gg/tXFUdasqhY) og se, om der findes nogen opdaterede metoder til at løse dem.

#### FaceTime HD-kamera

Kameradriveren får maskinen til at hænge, hvis den er indlæst, når Mac'en går i dvale, så den aflæses først. Den kan ikke aflæses, mens en app har kameraet åbent, så dvalen annulleres med en notifikation, der navngiver appen: luk den, og gå i dvale igen. Det gælder også automatisk dvale ved kritisk batteri og suspend-then-hibernate, som afvises, før den suspender. Almindelig suspend afvises af selve driveren, mens kameraet er åbent, uden en notifikation.

Kameraets firmware downloades fra Apple, så kameraet virker først, når Mac'en har været online. Downloadet starter ved opstart og forsøges igen hver 15. minut, mens netværket er problemet; hvis Apples fil har ændret sig, stopper det og venter på en Omarchy-opdatering. Hvis kameraet ikke vises, fortæller `journalctl -u facetimehd-firmware-fetcher` hvorfor, `sudo systemctl restart facetimehd-firmware-fetcher` forsøger igen, og en genstart indlæser driveren, hvis downloadet er færdigt, men kameraet stadig ikke er der.

#### Enheder med T1-chip

Apple T1-chippen blev introduceret i slutningen af 2016 og blev udelukkende brugt i første generation af MacBook Pro-modellerne med Touch Bar.
- MacBook Pro 13-tommer (2016, to Thunderbolt 3-porte) – Model: A1706
- MacBook Pro 13-tommer (2016, fire Thunderbolt 3-porte) – Model: A1708
- MacBook Pro 15-tommer (2016) – Model: A1707

#### Kendte problemer

- Touch Bar virker ikke
- Lyden virker ikke

#### Enheder med T2-chip

Apple T2 Security Chip blev introduceret i 2017. T2-chippen blev udfaset med overgangen til Apple silicon (M-seriens chips), der begyndte i 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-tommer (2018, fire Thunderbolt 3-porte) – Model: A1989
- MacBook Pro 15-tommer (2018) – Model: A1990
- MacBook Air (Retina, 13-tommer, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-tommer (2019, to Thunderbolt 3-porte) – Model: A2159
- MacBook Pro 13-tommer (2019, fire Thunderbolt 3-porte) – Model: A2178
- MacBook Pro 15-tommer (2019) – Model: A1990
- iMac (Retina 5K, 27-tommer, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-tommer (2020, to Thunderbolt 3-porte) – Model: A2265
- MacBook Pro 15-tommer (2020) – Model: A1990

På disse modeller opsætter installationsprogrammet automatisk den patchede `linux-t2`-kerne, T2-lydkonfigurationen, Apples Broadcom Wi-Fi/Bluetooth-firmware og blæserstyring via `t2fanrd`. Touch Bar kører på kernens indbyggede Boot Camp-lignende understøttelse.

#### iMac Retina 5K (2017)

27-tommer iMac'en fra 2017 har ingen T2-chip, så installationsprogrammet opsætter den ligesom de andre Intel-Macs.

- iMac (Retina 5K, 27-tommer, 2017) – Model: A1419

#### Kendte problemer

- Skærmen kører ikke ved dens oprindelige opløsning på 5120×2880: panelet består af to tiles, og standarddriveren tænder kun den ene
- Lyden virker ikke
- Lysstyrkekontrollen har ingen effekt
- Dvale får maskinen til at hænge; kun en tænd/sluk-cyklus får den tilbage

En fællesskabspatcher til denne model retter skærm, lyd og lysstyrke: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
