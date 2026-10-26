# Aan de slag

Omarchy wordt geïnstalleerd met een ISO. Je kunt kiezen tussen een installatie op de volledige schijf, die de hele schijf overneemt, of een installatie in vrije ruimte, die Omarchy in de niet-toegewezen ruimte op een schijf plaatst — zo dual-boot je naast Windows of een ander OS (zie [dual-boot-installatie](50-dual-boot-install.md) — let op dat je eerst BitLocker in Windows moet uitschakelen). Hoe dan ook gebruikt de installatie standaard volledige versleuteling, en de optie voor de volledige schijf wist de geselecteerde schijf, dus maak beslist een back-up voordat je een bestaande schijf gebruikt!

[Download de Omarchy ISO](https://omarchy.org/) eerst, zet hem op een USB-stick (gebruik [balenaEtcher](https://etcher.balena.io/) op Mac/Windows of [caligula](https://github.com/ifd3f/caligula) op Linux), en start op vanaf de stick.

_Je moet Secure Boot en/of TPM uitschakelen in de BIOS. Je moet deze uitschakelen om Omarchy te kunnen installeren. Het zijn beveiligingsschema's van Microsoft, bedoeld voor Windows en aan Microsoft gelieerde Linux-distributies._

Beantwoord vervolgens de configuratievragen en bevestig ze zo:

 ![install-config](images/install-config.webp)

Selecteer vervolgens een schijf voor je installatie, leun achterover en kijk hoe de installatieshow voorbijtrekt. Het kan in minder dan een minuut klaar zijn op de snelste moderne machines, maar het zou zelfs op een oudere computer niet langer dan 5 minuten moeten duren.

 ![install-done](images/install-done.webp)

Nu ben je klaar om te Omarchy'en!

### Gebruik een bedraad of 2.4ghz-toetsenbord!

Met de volledige-schijfversleuteling kun je bij het opstarten het wachtwoord niet invoeren vanaf een Bluetooth-toetsenbord. Net zoals je op een PC geen Bluetooth-toetsenbord kunt gebruiken om de BIOS in te gaan. Je hebt een toetsenbord nodig dat ofwel een 2.4ghz-dongle gebruikt, ofwel een kabel (wat sowieso veel fijner is voor de latency!). Zelf ben ik dol op de [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Installeren voor een andere eigenaar

Als je een machine klaarzet voor iemand anders — een familielid, een nieuwe werknemer, een koper — hoor je de persoonlijke vragen niet namens hen te beantwoorden. Druk op `Ctrl + C` in het allereerste scherm van het installatieprogramma (de toetsenbordselectie), en Omarchy zal aanbieden om de machine in plaats daarvan klaar te maken voor een andere eigenaar. Het systeem wordt meteen geïnstalleerd, maar alle persoonlijke configuratie — toetsenbordindeling, gebruikersnaam, wachtwoord — wordt uitgesteld tot de machine voor het eerst opstart. De schijf is nog steeds standaard versleuteld, en het wachtwoord dat de nieuwe eigenaar bij die eerste start kiest, wordt ook het versleutelingswachtwoord. (Een machine die je al gebruikt hebt, kan ook zonder herinstallatie worden overgedragen — zie [de computer resetten](48-security.md).)

### Installaties zonder toezicht

De ISO kan ook volledig zelfstandig installeren — geen toetsenbord, geen wizard — wanneer hij zijn configuratie aangereikt krijgt op een tweede schijf. Zo behandel je Omarchy als basisimage voor VMs en vlootmachines. Zie [installaties zonder toezicht](51-unattended-installs.md).

### Installaties zonder versleuteling

Omarchy wordt standaard geïnstalleerd met versleuteling. Dat is de veilige, verantwoorde keuze voor elke computer die mogelijk verloren kan gaan of gestolen kan worden. Je wilt niet dat iemand met toegang tot je hardware bij je gegevens kan!

Maar in speciale omstandigheden, zoals externe Omarchy-installaties op beschermde computers of voor wegwerpinstallaties zonder gevoelige gegevens, wil je misschien installeren zonder versleuteling. Je kunt op `Ctrl + C` drukken bij de bevestiging voor het formatteren van de schijf om over te schakelen naar een installatie zonder versleuteling.

### Taal

Omarchy spreekt 50 talen — dezelfde set als omarchy.org — en Engels is de standaard. Om te wisselen open je het Omarchy-menu en ga je naar _Setup > Language_, of voer je `omarchy language <code>` uit in een terminal (`omarchy language list` toont de codes). Het menu, het bureaublad en Omarchy's eigen meldingen veranderen onmiddellijk van taal, en elke applicatie die je daarna opent, volgt ook. Apps die al open waren, wisselen zodra je ze opnieuw opstart.

### Help als je vastloopt

Als je vastloopt, vind je meestal wel iemand die wil helpen in het kanaal _#omarchy-help_ op [de community-Discord](https://omarchy.org/discord).
