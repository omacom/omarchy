# Mac-understøttelse

## Omarchy til Apple Silicon

Omarchy til Apple Silicon er en officiel Omacom-løsning, der første gang blev udgivet med Omarchy 4.5. Den installeres ved siden af macOS, og du vælger mellem de to, når din Mac starter.

Fik du en besked om Omarchy Mac? Gå til [Kommer du fra Omarchy Mac](#coming-from-omarchy-mac).

Den kører på disse Macs:

| Mac | Chips |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Macs med M4 og nyere understøttes ikke endnu. Understøttelse af M4 testes på edge-kanalen og kommer som det næste. Installationsprogrammet tjekker din Mac, før det ændrer noget.

På enhver Mac med Apple Silicon, herunder M4 og nyere, kan du køre Omarchy i en virtuel maskine med [Try Omarchy](https://github.com/omacom/try-omarchy).

### Det skal du bruge

- macOS 15 Sequoia eller nyere og en administratorkonto
- Ledig diskplads til Omarchy. Installationsprogrammet foreslår en størrelse og lader dig ændre den.
- En backup af din Mac, strøm og en internetforbindelse. Installationen downloader flere gigabyte.

### Installation

Du installerer fra macOS. Installer Omarchy Installer med [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Eller download det nyeste Omarchy Installer fra dets [udgivelsesside](https://github.com/omacom/omarchy-mac-installer/releases), og åbn det.

Installationsprogrammet tjekker din Mac, viser dig planen og gør plads til Omarchy ved at formindske macOS-partitionen. macOS bliver på disken, og der er ikke brug for et USB-drev. Når første fase er færdig, guider det dig gennem at færdiggøre opsætningen i macOS Recovery: luk ned, hold tænd/sluk-knappen nede, indtil "Loading startup options" vises, vælg Omarchy, og følg trinnene.

Ved første opstart beder Omarchy om en adgangskode, der krypterer dens disk. Der findes ingen gendannelsesnøgle: Hvis du glemmer adgangskoden, kan dine Omarchy-filer ikke gendannes.

For at skifte mellem Omarchy og macOS senere skal du lukke ned og derefter holde tænd/sluk-knappen nede, indtil startmulighederne vises, og vælge en af dem.

### Kommer du fra Omarchy Mac

Omarchy Mac er nu en del af Omarchy til Apple Silicon, og alle Macs, der kørte det, understøttes. Din nuværende installation bliver ved med at køre, og dens systempakker opdateres stadig, men den får ikke flere Omarchy-opdateringer. Der er ingen deadline og ingen opgradering på stedet: Du tager backup, fjerner den gamle installation, installerer fra bunden og gendanner. Trin 2 til 5 foregår i macOS, så åbn denne side på din telefon, før du genstarter.

1. **Tag backup fra Omarchy, væk fra din Mac.** Fjernelse af den gamle installation sletter den, og macOS kan ikke læse Omarchy-disken. Kopier din hjemmemappe til et eksternt drev eller en anden computer, herunder SSH- og GPG-nøgler, browserprofiler og arbejde, som ikke er pushet. Gem din pakkeliste med `pacman -Qqe > ~/packages.txt`. Tag også backup af macOS, da både fjernelse og installation ændrer størrelsen på dens disk.
2. **Start din Mac i macOS.** Luk ned, hold tænd/sluk-knappen nede, indtil startmulighederne vises, og vælg macOS.
3. **Installer Omarchy Installer** som vist i [Installation](#installing).
4. **Fjern den gamle installation.** Åbn Omarchy Installer, og vælg Installation > Remove Omarchy. Den viser, hvad den vil slette, og giver pladsen tilbage til macOS. Hvis den ikke genkender din installation, stopper den uden at ændre disken. Bed om hjælp på [Discord](https://discord.gg/tXFUdasqhY) i stedet for at slette partitioner manuelt, hvilket kan slette macOS.
5. **Installer Omarchy til Apple Silicon** med installationsprogrammet.
6. **Gendan dine filer.** Gendan dine indstillinger lidt ad gangen i stedet for at kopiere hele `~/.config` over de nye standardindstillinger, da gamle indstillinger kan tilsidesætte dem.

### Godt at vide

- På MacBooks med M1 og M2 vækker du fra dvale ved at åbne låget eller trykke på tænd/sluk-knappen.
- Spørgsmål eller problemer: Spørg på vores [Discord](https://discord.gg/tXFUdasqhY).

[Installationsprogrammets README](https://github.com/omacom/omarchy-mac-installer#readme) dækker udgivelseskanaler, opdatering af installationsprogrammet og fjernelse af Omarchy.

## Intel-Macs

I en enkel test lykkedes det os at opnå en ydelsesforbedring på 36% på en MacBook Pro fra 2019 bare ved at installere Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Installation af Omarchy på Mac

Omarchy understøtter i øjeblikket kun at være det **eneste** OS installeret. Under installationen bliver drevet slettet, og macOS vil ikke længere kunne startes.

Du kan stadig gendanne det senere via Internet Recovery, hvis du vil.

I denne del antager vi, at du allerede har læst [Kom godt i gang](02-getting-started.md) og har dit USB-drev klar. Hvis ikke, så gør det nu.

#### Deaktiver Secure Boot

Det er nødvendigt at deaktivere Apples Secure Boot for at kunne starte fra det bootbare USB-drev samt OS'et. For at deaktivere det skal du gøre følgende:

1. Sluk din Mac
2. Tænd den, og tryk _med det samme_ på Command-R, og hold tasterne nede, indtil du ser indlæsningsskærmen vises
3. Vælg din bruger, og indtast din adgangskode, hvis du bliver bedt om det
4. Når du er på gendannelsesskærmen, skal du vælge **Utilities > Startup Security Utility** i menulinjen
5. Indtast din adgangskode, når du bliver bedt om at godkende
6. Vælg "No Security" blandt mulighederne for Secure Boot
7. Vælg "Allow booting from external or removable media" blandt mulighederne for External Boot

#### Start installationen

1. Sæt USB-drevet i
2. Genstart din Mac, og tryk _med det samme_ på Option, og hold tasten nede, indtil du ser en skærm med startenheder
3. Vælg den orange EFI Boot-enhed
4. Fortsæt med [installationen som normalt](02-getting-started.md)

Installationsprogrammet registrerer Mac-hardware og anvender automatisk de nødvendige rettelser: Broadcom Wi-Fi-drivere og -firmware, SPI-tastaturdriveren på de MacBook-modeller, der har brug for den, og en NVMe-rettelse til dvale på de samme modeller.

### Kendte begrænsninger

Medlemmer af fællesskabet arbejder konstant på løsninger på disse udfordringer, så hvis de er problematiske for dig, så deltag i #omarchy-on-other på vores [Discord](https://discord.gg/tXFUdasqhY) og se, om der findes opdaterede metoder til at løse dem.

#### Enheder med T1-chip

Apple T1-chippen blev introduceret i slutningen af 2016 og blev udelukkende brugt i første generation af MacBook Pro-modellerne med Touch Bar.
- MacBook Pro 13-tommer (2016, to Thunderbolt 3-porte) – Model: A1706
- MacBook Pro 13-tommer (2016, fire Thunderbolt 3-porte) – Model: A1708
- MacBook Pro 15-tommer (2016) – Model: A1707

#### Kendte problemer

- Touch Bar fungerer ikke
- Lyden fungerer ikke

#### Enheder med T2-chip

Apple T2 Security Chip blev introduceret i 2017. T2-chippen blev udfaset med overgangen til Apple silicon (M-seriens chips) fra 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-tommer (2018, fire Thunderbolt 3-porte) – Model: A1989
- MacBook Pro 15-tommer (2018) – Model: A1990
- MacBook Air (Retina, 13-tommer, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-tommer (2019, to Thunderbolt 3-porte) – Model: A2159
- MacBook Pro 13-tommer (2019, fire Thunderbolt 3-porte) – Model: A2178
- MacBook Pro 15-tommer (2019) – Model: A1990
- iMac (Retina 5K, 27-tommer, 2020) – Model: A2115 (iMac20,1 og iMac20,2)
- MacBook Pro 13-tommer (2020, to Thunderbolt 3-porte) – Model: A2265
- MacBook Pro 15-tommer (2020) – Model: A1990

På disse modeller opsætter installationsprogrammet automatisk den patchede `linux-t2`-kerne, T2-lydkonfigurationen, Apples Broadcom Wi-Fi/Bluetooth-firmware og blæserstyring via `t2fanrd`. Touch Bar kører med kernens indbyggede Boot Camp-lignende understøttelse.

#### iMac Retina 5K (2017)

27-tommer iMac'en fra 2017 har ingen T2-chip, så installationsprogrammet opsætter den som de andre Intel-Macs.

- iMac (Retina 5K, 27-tommer, 2017) – Model: A1419

#### Kendte problemer

- Skærmen kører ikke ved dens oprindelige 5120×2880: Panelet består af to fliser, og standarddriveren tænder kun den ene
- Lyden fungerer ikke
- Lysstyrkestyringen har ingen effekt
- Dvale får maskinen til at hænge; kun en sluk-og-tænd-cyklus får den tilbage

Et community-patchprogram til denne model retter skærm, lyd og lysstyrke: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
