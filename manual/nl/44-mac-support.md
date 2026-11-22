# Mac-ondersteuning

## Omarchy voor Apple Silicon

Omarchy voor Apple Silicon is een officiële Omacom-oplossing, voor het eerst uitgebracht met Omarchy 4.5. Het installeert naast macOS, en je kiest tussen de twee wanneer je Mac start.

Heb je een melding gekregen over Omarchy Mac? Ga naar [Afkomstig van Omarchy Mac](#coming-from-omarchy-mac).

Het draait op deze Macs:

| Mac | Chips |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4 en nieuwere Macs worden nog niet ondersteund. Ondersteuning voor M4 wordt getest op het edge-kanaal en komt als volgende. Het installatieprogramma controleert je Mac voordat het iets verandert.

Op elke Apple Silicon-Mac, inclusief M4 en nieuwer, kun je Omarchy draaien in een virtuele machine met [Try Omarchy](https://github.com/omacom/try-omarchy).

### Wat je nodig hebt

- macOS 15 Sequoia of later, en een beheerdersaccount
- Vrije schijfruimte voor Omarchy. Het installatieprogramma stelt een grootte voor en laat je die wijzigen.
- Een back-up van je Mac, stroom en een internetverbinding. De installatie downloadt meerdere gigabytes.

### Installeren

Je installeert vanuit macOS. Installeer het Omarchy Installer met [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Of download de nieuwste Omarchy Installer van zijn [releasepagina](https://github.com/omacom/omarchy-mac-installer/releases) en open deze.

Het installatieprogramma controleert je Mac, toont je het plan en maakt ruimte voor Omarchy door de macOS-partitie te verkleinen. macOS blijft op de schijf en er is geen USB-stick nodig. Als de eerste fase klaar is, begeleidt het je bij het afronden van de installatie in macOS Recovery: schakel uit, houd de aan/uit-knop ingedrukt totdat "Loading startup options" verschijnt, kies Omarchy en volg de stappen.

Bij de eerste start vraagt Omarchy om een wachtwoord dat zijn schijf versleutelt. Er is geen herstelsleutel: als je het wachtwoord vergeet, kunnen je Omarchy-bestanden niet worden hersteld.

Om later te wisselen tussen Omarchy en macOS, schakel je uit, houd je vervolgens de aan/uit-knop ingedrukt totdat de startopties verschijnen en kies je er een.

### Afkomstig van Omarchy Mac

Omarchy Mac is nu onderdeel van Omarchy voor Apple Silicon, en elke Mac die het draaide wordt ondersteund. Je huidige installatie blijft draaien en de systeempakketten blijven updaten, maar het krijgt geen Omarchy-updates meer. Er is geen deadline en geen in-place upgrade: je maakt een back-up, verwijdert de oude installatie, installeert vers en herstelt. Stappen 2 tot en met 5 gebeuren in macOS, dus open deze pagina op je telefoon voordat je opnieuw start.

1. **Maak een back-up vanuit Omarchy, buiten de Mac.** Het verwijderen van de oude installatie wist deze, en macOS kan de Omarchy-schijf niet lezen. Kopieer je thuismap naar een externe schijf of een andere computer, inclusief SSH- en GPG-sleutels, browserprofielen en niet-gepusht werk. Bewaar je pakketlijst met `pacman -Qqe > ~/packages.txt`. Maak ook een back-up van macOS, omdat zowel verwijderen als installeren de schijf ervan verkleint of vergroot.
2. **Start je Mac in macOS.** Schakel uit, houd de aan/uit-knop ingedrukt totdat de startopties verschijnen en kies macOS.
3. **Installeer de Omarchy Installer** zoals getoond in [Installeren](#installing).
4. **Verwijder de oude installatie.** Open de Omarchy Installer en kies Installation > Remove Omarchy. Het toont wat het zal verwijderen en geeft de ruimte terug aan macOS. Als het je installatie niet herkent, stopt het zonder de schijf te wijzigen. Vraag om hulp in [Discord](https://discord.gg/tXFUdasqhY) in plaats van partities handmatig te verwijderen, wat macOS kan wissen.
5. **Installeer Omarchy voor Apple Silicon** met het installatieprogramma.
6. **Herstel je bestanden.** Breng je instellingen stukje bij beetje terug in plaats van heel `~/.config` over de nieuwe standaardwaarden heen te kopiëren, omdat oude instellingen deze kunnen overschrijven.

### Goed om te weten

- Op M1- en M2-MacBooks wek je uit slaapstand door het deksel te openen of op de aan/uit-knop te drukken.
- Vragen of problemen: vraag in onze [Discord](https://discord.gg/tXFUdasqhY).

De [README van het installatieprogramma](https://github.com/omacom/omarchy-mac-installer#readme) behandelt releasekanalen, het updaten van het installatieprogramma en het verwijderen van Omarchy.

## Intel-Macs

In een eenvoudige test konden we 36% prestatiewinst behalen op een MacBook Pro uit 2019 door alleen Omarchy te installeren.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy installeren op Mac

Omarchy ondersteunt momenteel alleen het **enige** besturingssysteem te zijn dat is geïnstalleerd. Tijdens de installatie wordt de schijf gewist en is MacOS niet langer opstartbaar.

Je kunt het later nog steeds herstellen via Internet Recovery als je dat wilt.

Voor dit deel nemen we aan dat je [Aan de slag](02-getting-started.md) al hebt doorgenomen en je USB-stick klaar hebt. Als je dat nog niet hebt gedaan, doe dat dan nu.

#### Secure Boot uitschakelen

Het is noodzakelijk om Apple's Secure Boot uit te schakelen om de opstartbare USB-stick te kunnen starten, evenals het besturingssysteem. Voer hiervoor het volgende uit:

1. Schakel je Mac uit
2. Schakel hem in en houd _meteen_ Command-R ingedrukt totdat je het laadscherm ziet verschijnen
3. Selecteer je gebruiker en voer je wachtwoord in als daarom wordt gevraagd
4. Kies zodra je in het herstelscherm bent **Utilities > Startup Security Utility** in de menubalk
5. Voer je wachtwoord in wanneer daarom wordt gevraagd om te authenticeren
6. Kies "No Security" uit de Secure Boot-opties
7. Kies "Allow booting from external or removable media" uit de External Boot-opties

#### De installatie starten

1. Plaats de USB-stick
2. Herstart je Mac en houd _meteen_ Option ingedrukt totdat je een scherm met opstartapparaten ziet
3. Selecteer het oranje EFI Boot-apparaat
4. Ga verder met de [installatie zoals normaal](02-getting-started.md)

Het installatieprogramma detecteert Mac-hardware en past de benodigde oplossingen automatisch toe: Broadcom Wi-Fi-stuurprogramma's en firmware, het SPI-toetsenbordstuurprogramma op de MacBook-modellen die dit nodig hebben, en een NVMe-suspendfix voor diezelfde modellen.

### Bekende beperkingen

Leden van de community werken voortdurend aan oplossingen voor deze uitdagingen, dus als deze voor jou problematisch zijn, sluit je aan bij #omarchy-on-other in onze [Discord](https://discord.gg/tXFUdasqhY) en kijk of er actuele methoden zijn om deze op te lossen.

#### Apparaten met T1-chip

De Apple T1-chip werd eind 2016 geïntroduceerd en werd uitsluitend gebruikt in de eerste generatie MacBook Pro-modellen met Touch Bar.
- MacBook Pro 13-inch (2016, twee Thunderbolt 3-poorten) – Model: A1706
- MacBook Pro 13-inch (2016, vier Thunderbolt 3-poorten) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Bekende problemen

- Touch Bar werkt niet
- Geluid werkt niet

#### Apparaten met T2-chip

De Apple T2 Security Chip werd in 2017 geïntroduceerd. De T2-chip werd stopgezet met de overgang naar Apple silicon (M-series chips) vanaf 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, vier Thunderbolt 3-poorten) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, twee Thunderbolt 3-poorten) – Model: A2159
- MacBook Pro 13-inch (2019, vier Thunderbolt 3-poorten) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, twee Thunderbolt 3-poorten) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

Op deze modellen stelt het installatieprogramma automatisch de gepatchte `linux-t2`-kernel in, de T2-audioconfiguratie, Apple's Broadcom Wi-Fi/Bluetooth-firmware en ventilatorregeling via `t2fanrd`. De Touch Bar draait op de ingebouwde Boot Camp-achtige ondersteuning van de kernel.

#### iMac Retina 5K (2017)

De 27-inch iMac uit 2017 heeft geen T2-chip, dus het installatieprogramma stelt hem in zoals de andere Intel-Macs.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Bekende problemen

- Het scherm draait niet op zijn native 5120×2880: het paneel bestaat uit twee tegels, en het standaardstuurprogramma verlicht er slechts één
- Geluid werkt niet
- De helderheidsregeling heeft geen effect
- Slaapstand laat de machine vastlopen; alleen uit- en weer aanzetten herstelt hem

Een communitypatcher voor dit model herstelt het scherm, geluid en helderheid: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
