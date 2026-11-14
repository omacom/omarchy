# Aan de slag

Omarchy wordt geïnstalleerd met behulp van een ISO. Je kunt kiezen tussen een installatie op de volledige schijf, die de hele schijf overneemt, of een installatie in vrije ruimte, die Omarchy in de niet-toegewezen ruimte op een schijf plaatst — zo dual-boot je naast Windows of een ander OS (zie [dual-boot-installatie](50-dual-boot-install.md) — let op dat je eerst BitLocker in Windows moet uitschakelen). Hoe dan ook is de installatie standaard volledig versleuteld, en de optie voor de volledige schijf wist de geselecteerde schijf, dus zorg ervoor dat je een back-up maakt voordat je een bestaande schijf gebruikt!

[Download de Omarchy ISO](https://omarchy.org/) eerst, zet hem op een USB-stick (gebruik [Rufus](https://rufus.ie/) op Windows, [balenaEtcher](https://etcher.balena.io/) op Mac, of [caligula](https://github.com/ifd3f/caligula) op Linux), en start op vanaf de stick.

_Je moet Secure Boot en/of TPM uitschakelen in de BIOS. Je moet deze uitschakelen om Omarchy te kunnen installeren. Het zijn Microsoft-beveiligingsschema's bedoeld voor Windows en aan Microsoft gelieerde Linux-distributies._

Beantwoord vervolgens de configuratievragen, en bevestig ze zoals dit:

 ![install-config](images/install-config.webp)

Selecteer vervolgens een schijf voor je installatie, en leun achterover en kijk hoe de installatieshow zich voltrekt. Het kan in minder dan een minuut klaar zijn op de snelste moderne machines, maar zelfs op een oudere computer zou het niet meer dan 5 minuten moeten duren.

 ![install-done](images/install-done.webp)

Nu ben je klaar om te Omarchy'en!

### Gebruik een bedraad of 2.4ghz-toetsenbord!

Door de versleuteling van de volledige schijf kun je het wachtwoord bij het opstarten niet invoeren vanaf een Bluetooth-toetsenbord. Net zoals je geen Bluetooth-toetsenbord kunt gebruiken om de BIOS op een PC te openen. Je hebt een toetsenbord nodig dat een 2.4ghz-dongle of een kabel gebruikt (wat sowieso veel fijner is voor de latency!). Persoonlijk ben ik dol op de [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Installeren voor een andere eigenaar

Als je een machine instelt voor iemand anders — een familielid, een nieuwe medewerker, een koper — moet je de persoonlijke vragen niet namens hen beantwoorden. Druk op `Ctrl + C` in het allereerste scherm van het installatieprogramma (de toetsenbordselectie), en Omarchy zal aanbieden om de machine in plaats daarvan voor te bereiden voor een andere eigenaar. Het systeem wordt meteen geïnstalleerd, maar alle persoonlijke instellingen — toetsenbordindeling, gebruikersnaam, wachtwoord — worden uitgesteld tot de machine voor de eerste keer opstart. De schijf is nog steeds standaard versleuteld, en het wachtwoord dat de nieuwe eigenaar bij die eerste keer opstarten kiest, wordt ook het versleutelingswachtwoord. (Een machine die je al hebt gebruikt, kan ook zonder herinstallatie worden overgedragen — zie [de computer resetten](48-security.md).)

### Onbeheerde installaties

De ISO kan ook volledig zelfstandig installeren — geen toetsenbord, geen wizard — wanneer de configuratie wordt aangeleverd op een tweede schijf. Dat is de manier om Omarchy te behandelen als basisimage voor VM's en fleet-machines. Zie [onbeheerde installaties](51-unattended-installs.md).

### Installaties zonder versleuteling

Omarchy wordt standaard met versleuteling geïnstalleerd. Dat is de veilige, verantwoorde keuze voor elke computer die mogelijk verloren kan raken of gestolen kan worden. Je wilt niet dat iemand met toegang tot je hardware bij je gegevens kan!

Maar in bijzondere omstandigheden, zoals externe Omarchy-installaties op beveiligde computers of voor wegwerpinstanties zonder gevoelige gegevens, wil je misschien installeren zonder versleuteling. Je kunt op `Ctrl + C` drukken bij de bevestiging van het formatteren van de schijf om over te schakelen naar een installatie zonder versleuteling.

### Taal

Omarchy spreekt 50 talen — dezelfde set als omarchy.org — en Engels is de standaardtaal. Om over te schakelen, open je het Omarchy-menu en ga je naar _Setup > Language_, of voer je `omarchy language <code>` uit in een terminal (`omarchy language list` toont de codes). Het menu, de desktop en Omarchy's eigen meldingen veranderen onmiddellijk van taal, en elke applicatie die je daarna opent, volgt ook. Apps die al open waren, schakelen om zodra je ze opnieuw opstart.

### Hulp als je vastloopt

Als je vastloopt, kun je meestal iemand vinden die bereid is te helpen in het _#omarchy-help_-kanaal op [de community Discord](https://omarchy.org/discord).
