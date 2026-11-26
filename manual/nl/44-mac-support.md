# Mac-ondersteuning

## Omarchy voor Apple Silicon

Omarchy voor Apple Silicon is een officiële oplossing van Omacom, voor het eerst uitgebracht met Omarchy 4.5. Het installeert naast macOS, en bij het opstarten van je Mac kies je tussen de twee.

Kreeg je een melding over Omarchy Mac? Ga naar [Kom je van Omarchy Mac](#coming-from-omarchy-mac).

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

M4 en nieuwere Macs worden nog niet ondersteund. Ondersteuning voor M4 wordt getest op het edge-kanaal en volgt als volgende. Het installatieprogramma controleert je Mac voordat het iets verandert.

Op elke Apple Silicon-Mac, ook M4 en nieuwer, kun je Omarchy draaien in een virtuele machine met [Try Omarchy](https://github.com/omacom/try-omarchy).

### Wat je nodig hebt

- macOS 15 Sequoia of later, en een beheerdersaccount
- Vrije schijfruimte voor Omarchy. Het installatieprogramma stelt een grootte voor en laat je die aanpassen.
- Een back-up van je Mac, stroom en een internetverbinding. De installatie downloadt meerdere gigabytes.

### Installeren

Je installeert vanuit macOS. Installeer de Omarchy Installer met [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Of download de nieuwste Omarchy Installer van zijn [releasepagina](https://github.com/omacom/omarchy-mac-installer/releases) en open hem.

Het installatieprogramma controleert je Mac, toont je het plan en maakt ruimte voor Omarchy door de macOS-partitie te verkleinen. macOS blijft op de schijf staan en er is geen USB-stick nodig. Als de eerste fase klaar is, leidt het je door het voltooien van de installatie in macOS-herstel: zet de Mac uit, houd de aan/uit-knop ingedrukt totdat "Loading startup options" verschijnt, kies Omarchy en volg de stappen.

Bij de eerste start vraagt Omarchy om een wachtwoord dat zijn schijf versleutelt. Er is geen herstelsleutel: als je het wachtwoord vergeet, kunnen je Omarchy-bestanden niet worden hersteld.

Om later tussen Omarchy en macOS te wisselen, zet je de Mac uit, houd je vervolgens de aan/uit-knop ingedrukt totdat de opstartopties verschijnen en kies je er een.

### Kom je van Omarchy Mac

Omarchy Mac maakt nu deel uit van Omarchy voor Apple Silicon, en elke Mac die het draaide wordt ondersteund. Je huidige installatie blijft draaien en de systeempakketten ervan worden nog steeds bijgewerkt, maar hij krijgt geen Omarchy-updates meer. Er is geen deadline en geen upgrade ter plaatse: je maakt een back-up, verwijdert de oude installatie, installeert vers en zet alles terug. Stap 2 tot en met 5 gebeuren in macOS, dus open deze pagina op je telefoon voordat je opnieuw opstart.

1. **Maak een back-up vanuit Omarchy, buiten de Mac.** Het verwijderen van de oude installatie wist hem, en macOS kan de Omarchy-schijf niet lezen. Kopieer je thuismap naar een externe schijf of een andere computer, inclusief SSH- en GPG-sleutels, browserprofielen en werk dat nog niet is gepusht. Sla je pakketlijst op met `pacman -Qqe > ~/packages.txt`. Maak ook een back-up van macOS, want zowel verwijderen als installeren past de grootte van zijn schijf aan.
2. **Start je Mac in macOS.** Zet hem uit, houd de aan/uit-knop ingedrukt totdat de opstartopties verschijnen en kies macOS.
3. **Installeer de Omarchy Installer** zoals getoond in [Installeren](#installing).
4. **Verwijder de oude installatie.** Open de Omarchy Installer en kies Installation > Remove Omarchy. Hij toont wat hij zal verwijderen en geeft de ruimte terug aan macOS. Als hij je installatie niet herkent, stopt hij zonder de schijf te veranderen. Vraag om hulp in [Discord](https://discord.gg/tXFUdasqhY) in plaats van partities met de hand te verwijderen, waardoor je macOS kunt wissen.
5. **Installeer Omarchy voor Apple Silicon** met het installatieprogramma.
6. **Zet je bestanden terug.** Breng je instellingen stukje bij beetje terug in plaats van heel `~/.config` over de nieuwe standaardwaarden heen te kopiëren, want oude instellingen kunnen die overschrijven.

### Goed om te weten

- Op M1- en M2-MacBooks wek je hem uit sluimerstand door het deksel te openen of op de aan/uit-knop te drukken.
- Vragen of problemen: stel ze in onze [Discord](https://discord.gg/tXFUdasqhY).

De [README van het installatieprogramma](https://github.com/omacom/omarchy-mac-installer#readme) behandelt releasekanalen, het bijwerken van het installatieprogramma en het verwijderen van Omarchy.

## Intel-Macs

In een eenvoudige test haalden we 36% prestatiewinst op een MacBook Pro uit 2019, alleen door Omarchy te installeren.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy installeren op een Mac

Omarchy ondersteunt op dit moment alleen dat het het **enige** geïnstalleerde besturingssysteem is. Tijdens de installatie wordt de schijf gewist en is MacOS niet meer opstartbaar.

Je kunt het later nog altijd herstellen via Internet Recovery als je wilt.

Voor dit deel gaan we ervan uit dat je [Aan de slag](02-getting-started.md) al hebt doorgenomen en je USB-stick klaar hebt liggen. Zo niet, doe dat dan nu eerst.

#### Secure Boot uitschakelen

Je moet Apple's Secure Boot uitschakelen om de opstartbare USB-stick te kunnen starten, en ook het besturingssysteem. Doe daarvoor het volgende:

1. Zet je Mac uit
2. Zet hem aan en druk _meteen_ op Command-R en houd die ingedrukt totdat je het laadscherm ziet verschijnen
3. Selecteer je gebruiker en voer je wachtwoord in als daarom wordt gevraagd
4. Kies in het herstelscherm **Utilities > Startup Security Utility** in de menubalk
5. Voer je wachtwoord in wanneer je wordt gevraagd je te authenticeren
6. Kies "No Security" bij de Secure Boot-opties
7. Kies "Allow booting from external or removable media" bij de External Boot-opties

#### De installatie starten

1. Steek de USB-stick erin
2. Herstart je Mac en druk _meteen_ op Option en houd die ingedrukt totdat je een scherm met opstartapparaten ziet
3. Selecteer het oranje EFI Boot-apparaat
4. Ga verder met de [installatie zoals normaal](02-getting-started.md)

Het installatieprogramma detecteert Mac-hardware en past de benodigde fixes automatisch toe: Broadcom Wi-Fi-drivers en -firmware, de FaceTime HD-cameradriver op machines met een Broadcom 1570 (zijn firmware wordt van Apple gedownload zodra de Mac online is, omdat het installatieprogramma offline werkt), de SPI-toetsenborddriver op de MacBook-modellen die hem nodig hebben, en een NVMe-fix voor sluimerstand voor diezelfde modellen.

### Bekende beperkingen

Leden van de community werken voortdurend aan oplossingen voor deze uitdagingen, dus als dit voor jou problematisch is, kom dan naar #omarchy-on-other in onze [Discord](https://discord.gg/tXFUdasqhY) en kijk of er actuele methoden zijn om ze op te lossen.

#### FaceTime HD-camera

De cameradriver laat de machine vastlopen als hij geladen is wanneer de Mac in winterslaap gaat, dus wordt hij eerst ontladen. Hij kan niet worden ontladen terwijl een app de camera open heeft staan, dus wordt de winterslaap geannuleerd met een melding waarin de app wordt genoemd: sluit hem en ga opnieuw in winterslaap. Dat geldt ook voor automatisch in winterslaap gaan bij een kritieke batterij, en voor suspend-then-hibernate, wat wordt geweigerd voordat hij in sluimerstand gaat. Gewone sluimerstand wordt door de driver zelf geweigerd terwijl de camera openstaat, zonder melding.

De firmware van de camera wordt van Apple gedownload, dus de camera werkt pas zodra de Mac online is geweest. De download start bij het opstarten en wordt elke 15 minuten opnieuw geprobeerd zolang het netwerk het probleem is; als Apple's bestand is veranderd, stopt hij en wacht hij op een Omarchy-update. Als de camera niet verschijnt, vertelt `journalctl -u facetimehd-firmware-fetcher` waarom, probeert `sudo systemctl restart facetimehd-firmware-fetcher` het opnieuw, en laadt een herstart de driver als de download klaar was maar de camera er nog steeds niet is.

#### Apparaten met T1-chip

De Apple T1-chip werd eind 2016 geïntroduceerd en uitsluitend gebruikt in de eerste generatie MacBook Pro-modellen met Touch Bar.
- MacBook Pro 13-inch (2016, twee Thunderbolt 3-poorten) – Model: A1706
- MacBook Pro 13-inch (2016, vier Thunderbolt 3-poorten) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Bekende problemen

- Touch Bar werkt niet
- Geluid werkt niet

#### Apparaten met T2-chip

De Apple T2 Security Chip werd in 2017 geïntroduceerd. De T2-chip werd stopgezet met de overgang naar Apple silicon (M-serie chips) vanaf 2020.

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

De 27-inch iMac uit 2017 heeft geen T2-chip, dus stelt het installatieprogramma hem in zoals de andere Intel-Macs.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Bekende problemen

- Het scherm draait niet op zijn native 5120×2880: het paneel bestaat uit twee tegels, en de standaarddriver licht er maar één op
- Geluid werkt niet
- De helderheidsregeling heeft geen effect
- Sluimerstand laat de machine vastlopen; alleen uit- en weer aanzetten herstelt hem

Een community-patcher voor dit model fixt het scherm, het geluid en de helderheid: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
