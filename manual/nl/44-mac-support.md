# Mac-ondersteuning

Omarchy heeft ingebouwde ondersteuning voor **Intel-Macs**. Er zijn op dit moment een paar bekende beperkingen, maar zolang je daarvan op de hoogte bent en ermee kunt leven, kun je je oude Macs nieuw leven inblazen door Omarchy te installeren.

Let op: installeren op een Mac uit de M-serie wordt op dit moment niet direct ondersteund. Je kunt meer te weten komen over de stand van zaken in #omarchy-on-other in onze [Discord](https://discord.gg/tXFUdasqhY).

In een eenvoudige test konden we 36% prestatiewinst behalen op een MacBook Pro uit 2019 door simpelweg Omarchy te installeren.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy installeren op een Mac

Omarchy ondersteunt op dit moment alleen dat het het **enige** geïnstalleerde besturingssysteem is. Tijdens de installatie wordt de schijf gewist en is MacOS niet langer opstartbaar.

Je kunt het later alsnog herstellen via Internet Recovery als je dat wilt.

Voor dit gedeelte gaan we ervan uit dat je [Aan de slag](02-getting-started.md) al hebt doorgenomen en je USB-stick klaar hebt. Als dat niet zo is, doe dat dan nu.

#### Secure Boot uitschakelen

Het is nodig om Apple's Secure Boot uit te schakelen om de opstartbare USB te kunnen opstarten, evenals het besturingssysteem. Doe het volgende om het uit te schakelen:

1. Zet je Mac uit
2. Zet hem aan en houd _onmiddellijk_ Command-R ingedrukt totdat je het laadscherm ziet verschijnen
3. Selecteer je gebruiker en voer je wachtwoord in als daarom wordt gevraagd
4. Kies eenmaal in het herstelscherm **Utilities > Startup Security Utility** in de menubalk
5. Voer je wachtwoord in wanneer daarom wordt gevraagd om te authenticeren
6. Kies "No Security" uit de Secure Boot-opties
7. Kies "Allow booting from external or removable media" uit de External Boot-opties

#### De installatie starten

1. Steek de USB-stick in
2. Herstart je Mac en houd _onmiddellijk_ Option ingedrukt totdat je een scherm met opstartapparaten ziet
3. Selecteer het oranje EFI Boot-apparaat
4. Ga verder met de [installatie zoals normaal](02-getting-started.md)

Het installatieprogramma detecteert Mac-hardware en past de benodigde oplossingen automatisch toe: Broadcom wifi-stuurprogramma's en -firmware, het SPI-toetsenbordstuurprogramma op de MacBook-modellen die het nodig hebben, en een NVMe-suspendoplossing voor diezelfde modellen.

### Bekende beperkingen

Leden van de community werken voortdurend aan oplossingen voor deze uitdagingen, dus als deze voor jou problematisch zijn, word dan lid van #omarchy-on-other in onze [Discord](https://discord.gg/tXFUdasqhY) en kijk of er actuele methoden zijn om ze op te lossen.

#### Apparaten met T1-chip

De Apple T1-chip werd eind 2016 geïntroduceerd en uitsluitend gebruikt in de MacBook Pro-modellen van de eerste generatie met Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Bekende problemen

- Touch Bar werkt niet
- Geluid werkt niet

#### Apparaten met T2-chip

De Apple T2 Security Chip werd in 2017 geïntroduceerd. De T2-chip werd stopgezet met de overstap naar Apple silicon (chips uit de M-serie) vanaf 2020.

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

Op deze modellen stelt het installatieprogramma automatisch de gepatchte `linux-t2`-kernel, de T2-audioconfiguratie, Apple's Broadcom wifi-/Bluetooth-firmware en ventilatorregeling via `t2fanrd` in. De Touch Bar draait op de ingebouwde Boot Camp-achtige ondersteuning van de kernel.
