# Mac-support

Omarchy har indbygget understøttelse af **Intel Macs**. Der er et par kendte begrænsninger lige nu, men så længe du er klar over dem og er OK med dem, kan du puste nyt liv i dine gamle Macs ved at installere Omarchy.

Bemærk, at installation på en Mac med M-serie ikke er direkte understøttet på nuværende tidspunkt. Du kan finde ud af mere om, hvordan det står til med det, i #omarchy-on-other i vores [Discord](https://discord.gg/tXFUdasqhY).

I en simpel test kunne vi opnå en ydelsesforbedring på 36 % på en MacBook Pro fra 2019 bare ved at installere Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Installation af Omarchy på Mac

Omarchy understøtter i øjeblikket kun at være det **eneste** OS installeret. Under installationen bliver drevet slettet, og MacOS vil ikke længere kunne startes.

Du kan stadig gendanne det senere via Internet Recovery, hvis du skulle få lyst.

I denne del antager vi, at du allerede har gennemgået [Kom godt i gang](02-getting-started.md) og har dit USB-drev klar. Hvis du ikke har det, så gør det nu.

#### Deaktiver Secure Boot

Det er nødvendigt at deaktivere Apples Secure Boot for at kunne starte fra den startbare USB samt fra operativsystemet. For at deaktivere den skal du gøre følgende:

1. Sluk din Mac
2. Tænd den, og tryk _med det samme_ på Command-R, og hold den nede, indtil du ser indlæsningsskærmen
3. Vælg din bruger, og indtast din adgangskode, hvis du bliver bedt om det
4. Når du er på gendannelsesskærmen, skal du vælge **Hjælpeprogrammer > Startup Security Utility** i menulinjen
5. Indtast din adgangskode, når du bliver bedt om at godkende
6. Vælg "No Security" blandt indstillingerne for Secure Boot
7. Vælg "Allow booting from external or removable media" blandt indstillingerne for External Boot

#### Start installationen

1. Indsæt USB-drevet
2. Genstart din Mac, og tryk _med det samme_ på Option, og hold den nede, indtil du ser en skærm med startenheder
3. Vælg den orange EFI Boot-enhed
4. Fortsæt med [installationen som normalt](02-getting-started.md)

Installationsprogrammet registrerer Mac-hardwaren og anvender automatisk de nødvendige rettelser: Broadcom Wi-Fi-drivere og -firmware, SPI-tastaturdriveren på de MacBook-modeller, der har brug for den, og en rettelse til NVMe-dvale til de samme modeller.

### Kendte begrænsninger

Medlemmer af fællesskabet arbejder hele tiden på løsninger på disse udfordringer, så hvis de er et problem for dig, så kom med i #omarchy-on-other i vores [Discord](https://discord.gg/tXFUdasqhY) og se, om der findes opdaterede metoder til at løse dem.

#### Enheder med T1-chip

Apple T1-chippen blev introduceret i slutningen af 2016 og blev udelukkende brugt i første generation af MacBook Pro-modellerne med Touch Bar.
- MacBook Pro 13-tommer (2016, to Thunderbolt 3-porte) – Model: A1706
- MacBook Pro 13-tommer (2016, fire Thunderbolt 3-porte) – Model: A1708
- MacBook Pro 15-tommer (2016) – Model: A1707

#### Kendte problemer

- Touch Bar fungerer ikke
- Lyden fungerer ikke

#### Enheder med T2-chip

Apple T2 Security Chip blev introduceret i 2017. T2-chippen blev udfaset med overgangen til Apple silicon (M-serie-chips) fra 2020.

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

På disse modeller opsætter installationsprogrammet automatisk den patchede `linux-t2`-kerne, T2-lydkonfigurationen, Apples Broadcom Wi-Fi/Bluetooth-firmware og blæserstyring via `t2fanrd`. Touch Bar kører på kernens indbyggede understøttelse i Boot Camp-stil.

#### iMac Retina 5K (2017)

27-tommer iMac fra 2017 har ingen T2-chip, så installationsprogrammet opsætter den ligesom de andre Intel Macs.

- iMac (Retina 5K, 27-tommer, 2017) – Model: A1419

#### Kendte problemer

- Skærmen kører ikke i dens oprindelige 5120×2880: panelet består af to dele, og standarddriveren tænder kun den ene
- Lyden fungerer ikke
- Lysstyrkestyringen har ingen effekt
- Dvale får maskinen til at hænge; kun en slukning og tænding får den tilbage

Et patchprogram fra fællesskabet til denne model retter skærm, lyd og lysstyrke: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
