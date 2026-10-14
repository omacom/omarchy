# Mac-support

Omarchy har indbygget support til **Intel-Macs**. Der er et par kendte begrænsninger i øjeblikket, men så længe du er klar over dem og OK med dem, kan du puste nyt liv i dine gamle Macs ved at indlæse Omarchy.

Bemærk venligst, at installation på en M-series-Mac ikke understøttes direkte på nuværende tidspunkt. Du kan finde ud af mere om status for dette i #omarchy-on-other i vores [Discord](https://discord.gg/tXFUdasqhY).

I en simpel test var vi i stand til at opnå 36% ydeevnegevinst på en 2019 MacBook Pro blot ved at installere Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Installer Omarchy på Mac

Omarchy understøtter kun at være det **eneste** installerede OS i øjeblikket. Under installationen vil drevet blive slettet, og MacOS vil ikke længere være bootbart.

Du kan stadig gendanne det senere via Internet Recovery, hvis du vil.

I denne del vil vi antage, at du allerede har gennemgået [Kom godt i gang](02-getting-started.md) og har dit USB-drev klar. Hvis du ikke har, så gå i gang og gør det nu.

#### Deaktiver Secure Boot

Det er nødvendigt at deaktivere Apples Secure Boot for at boote den bootbare USB såvel som OS'et. For at deaktivere det skal du gøre følgende:

1. Sluk din Mac
2. Tænd den og tryk _med det samme_ på Command-R og hold det nede, indtil du ser indlæsningsskærmen vises
3. Vælg din bruger og indtast din adgangskode, hvis du bliver bedt om det
4. Når du er på gendannelsesskærmen, vælg **Utilities > Startup Security Utility** fra menulinjen
5. Indtast din adgangskode, når du bliver bedt om at godkende
6. Vælg "No Security" fra Secure Boot-mulighederne
7. Vælg "Allow booting from external or removable media" fra External Boot-mulighederne

#### Start installationen

1. Indsæt USB-drevet
2. Genstart din Mac og tryk _med det samme_ på Option og hold det nede, indtil du ser en skærm med bootenheder
3. Vælg den orange EFI Boot-enhed
4. Fortsæt med [installation som normalt](02-getting-started.md)

Installeren registrerer Mac-hardware og anvender de nødvendige rettelser automatisk: Broadcom Wi-Fi-drivere og firmware, SPI-tastaturdriveren på de MacBook-modeller, der har brug for den, og en NVMe-hvilereparation til de samme modeller.

### Kendte begrænsninger

Medlemmer af fællesskabet arbejder konstant på løsninger til disse udfordringer, så hvis disse er problematiske for dig, så join #omarchy-on-other i vores [Discord](https://discord.gg/tXFUdasqhY) og se, om der er nogen opdaterede metoder til at løse dem.

#### Enheder med T1-chip

Apple T1-chippen blev introduceret i slutningen af 2016 og blev udelukkende brugt i første generation af MacBook Pro-modeller med Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Kendte problemer

- Touch Bar er ikke-funktionel
- Lyd fungerer ikke

#### Enheder med T2-chip

Apple T2 Security Chip blev introduceret i 2017. T2-chippen blev udfaset med overgangen til Apple silicon (M-series-chips) fra 2020.

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

På disse modeller sætter installeren automatisk den patchede `linux-t2`-kerne op, T2-lydkonfigurationen, Apples Broadcom Wi-Fi/Bluetooth-firmware og blæserstyring via `t2fanrd`. Touch Bar kører på kernens indbyggede Boot Camp-lignende support.
