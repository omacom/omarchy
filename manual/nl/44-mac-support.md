# Mac-ondersteuning

Omarchy heeft ingebouwde ondersteuning voor **Intel Macs**. Er zijn op dit moment een paar bekende beperkingen, maar zolang je daarvan op de hoogte bent en daarmee akkoord gaat, kun je je oude Macs nieuw leven inblazen door Omarchy erop te zetten.

Let op: installeren op een M-series Mac wordt op dit moment niet direct ondersteund. Meer informatie over de stand van zaken vind je in #omarchy-on-other in onze [Discord](https://discord.gg/tXFUdasqhY).

In een eenvoudige test wisten we 36% prestatiewinst te behalen op een MacBook Pro uit 2019, alleen al door Omarchy te installeren.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy installeren op een Mac

Omarchy ondersteunt op dit moment alleen dat het het **enige** geïnstalleerde besturingssysteem is. Tijdens de installatie wordt de schijf gewist en is MacOS daarna niet meer opstartbaar.

Je kunt het later alsnog herstellen via Internet Recovery als je dat wilt.

Voor dit gedeelte gaan we ervan uit dat je [Aan de slag](02-getting-started.md) al hebt doorgenomen en je USB-stick klaar hebt liggen. Zo niet, doe dat dan nu.

#### Secure Boot uitschakelen

Het is noodzakelijk om Apple's Secure Boot uit te schakelen om de opstartbare USB te kunnen opstarten, en ook het besturingssysteem. Doe het volgende om het uit te schakelen:

1. Zet je Mac uit
2. Zet hem aan en houd _meteen_ Command-R ingedrukt totdat je het laadscherm ziet verschijnen
3. Selecteer je gebruiker en voer je wachtwoord in als daarom wordt gevraagd
4. Kies in het herstelscherm **Utilities > Startup Security Utility** in de menubalk
5. Voer je wachtwoord in wanneer je wordt gevraagd om te authenticeren
6. Kies "No Security" bij de Secure Boot-opties
7. Kies "Allow booting from external or removable media" bij de External Boot-opties

#### De installatie starten

1. Steek de USB-stick erin
2. Herstart je Mac en houd _meteen_ Option ingedrukt totdat je een scherm met opstartapparaten ziet
3. Selecteer het oranje EFI Boot-apparaat
4. Ga verder met de [installatie zoals gebruikelijk](02-getting-started.md)

Het installatieprogramma detecteert Mac-hardware en past de benodigde fixes automatisch toe: Broadcom Wi-Fi-drivers en -firmware, de SPI-toetsenborddriver op de MacBook-modellen die dat nodig hebben, en een NVMe-suspendfix voor diezelfde modellen.

### Bekende beperkingen

Leden van de community werken voortdurend aan oplossingen voor deze uitdagingen, dus als dit voor jou problematisch is, ga dan naar #omarchy-on-other in onze [Discord](https://discord.gg/tXFUdasqhY) en kijk of er actuele methoden zijn om ze op te lossen.

#### Apparaten met T1-chip

De Apple T1-chip werd eind 2016 geïntroduceerd en uitsluitend gebruikt in de MacBook Pro-modellen van de eerste generatie met Touch Bar.
- MacBook Pro 13-inch (2016, twee Thunderbolt 3-poorten) – Model: A1706
- MacBook Pro 13-inch (2016, vier Thunderbolt 3-poorten) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Bekende problemen

- Touch Bar werkt niet
- Geluid werkt niet

#### Apparaten met T2-chip

De Apple T2 Security Chip werd in 2017 geïntroduceerd. De T2-chip werd uitgefaseerd met de overgang naar Apple silicon (M-series chips) vanaf 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, vier Thunderbolt 3-poorten) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, twee Thunderbolt 3-poorten) – Model: A2159
- MacBook Pro 13-inch (2019, vier Thunderbolt 3-poorten) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 en iMac20,2)
- MacBook Pro 13-inch (2020, twee Thunderbolt 3-poorten) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

Op deze modellen stelt het installatieprogramma automatisch de gepatchte `linux-t2`-kernel in, de T2-audioconfiguratie, Apple's Broadcom Wi-Fi/Bluetooth-firmware en ventilatorregeling via `t2fanrd`. De Touch Bar draait op de ingebouwde Boot Camp-achtige ondersteuning van de kernel.

#### iMac Retina 5K (2017)

De 27-inch iMac uit 2017 heeft geen T2-chip, dus stelt het installatieprogramma hem in zoals de andere Intel Macs.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Bekende problemen

- Het scherm draait niet op zijn native 5120×2880: het paneel bestaat uit twee tegels en de standaarddriver verlicht er maar één
- Geluid werkt niet
- De helderheidsregeling heeft geen effect
- Slaapstand laat de machine vastlopen; alleen uit- en weer aanzetten herstelt hem

Een patcher van de community voor dit model fixt het scherm, het geluid en de helderheid: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
