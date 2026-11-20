# Aan de slag

Omarchy wordt geïnstalleerd met een ISO. Je kunt kiezen tussen een installatie op de volledige schijf, die de hele schijf overneemt, of een installatie in vrije ruimte, die Omarchy in de niet-toegewezen ruimte op een schijf plaatst — zo dual boot je naast Windows of een ander OS (zie [dual-boot-installatie](50-dual-boot-install.md) — let op dat je eerst BitLocker in Windows moet uitschakelen). In beide gevallen gebruikt de installatie standaard volledige versleuteling, en de optie voor de volledige schijf wist de geselecteerde schijf, dus zorg dat je een back-up maakt voordat je een bestaande schijf gebruikt!

[Download eerst de Omarchy ISO](https://omarchy.org/), zet hem op een USB-stick (gebruik [Rufus](https://rufus.ie/) op Windows, [balenaEtcher](https://etcher.balena.io/) op Mac, of [caligula](https://github.com/ifd3f/caligula) op Linux), en start op vanaf de stick.

_Je moet Secure Boot en/of TPM uitschakelen in de BIOS. Je moet deze uitschakelen om Omarchy te kunnen installeren. Het zijn beveiligingsschema's van Microsoft, bedoeld voor Windows en aan Microsoft gelieerde Linux-distributies._

Beantwoord daarna de configuratievragen en bevestig ze zo:

 ![install-config](images/install-config.webp)

Selecteer daarna een schijf voor je installatie, leun achterover en kijk hoe de installatieshow voorbijrolt. Op de snelste moderne machines kan het in minder dan een minuut klaar zijn, maar zelfs op een oudere computer zou het niet meer dan 5 minuten moeten duren.

 ![install-done](images/install-done.webp)

Nu ben je klaar voor Omarchy!

### Gebruik een bedraad of 2.4ghz-toetsenbord!

Met de volledige schijfversleuteling kun je bij het opstarten het wachtwoord niet invoeren vanaf een Bluetooth-toetsenbord. Net zoals je geen Bluetooth-toetsenbord kunt gebruiken om de BIOS op een PC te openen. Je hebt een toetsenbord nodig dat een 2.4ghz-dongle of een kabel gebruikt (wat voor de latency sowieso veel fijner is!). Persoonlijk ben ik dol op de [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Installeren voor een andere eigenaar

Als je een machine instelt voor iemand anders — een familielid, een nieuwe medewerker, een koper — moet je de persoonlijke vragen niet namens hen beantwoorden. Druk op `Ctrl + C` in het allereerste scherm van het installatieprogramma (de toetsenbordselectie), en Omarchy zal aanbieden om de machine in plaats daarvan voor te bereiden voor een andere eigenaar. Het systeem wordt meteen geïnstalleerd, maar alle persoonlijke instellingen — toetsenbordindeling, gebruikersnaam, wachtwoord — worden uitgesteld tot de machine voor het eerst opstart. De schijf is nog steeds standaard versleuteld, en het wachtwoord dat de nieuwe eigenaar bij die eerste keer opstarten kiest, wordt ook het versleutelingswachtwoord. (Een machine die je al hebt gebruikt, kan ook zonder herinstallatie worden overgedragen — zie [de computer resetten](48-security.md).)

### Installaties zonder toezicht

De ISO kan ook volledig zelfstandig installeren — geen toetsenbord, geen wizard — wanneer de configuratie op een tweede schijf wordt aangeleverd. Dat is de manier om Omarchy te behandelen als basisimage voor VM's en machinevloten. Zie [installaties zonder toezicht](51-unattended-installs.md).

### Installaties zonder versleuteling

Omarchy wordt standaard met versleuteling geïnstalleerd. Dat is de veilige, verantwoorde keuze voor elke computer die mogelijk verloren kan raken of gestolen kan worden. Je wilt niet dat iemand met toegang tot je hardware bij je gegevens kan!

Maar in speciale omstandigheden, zoals externe Omarchy-installaties op beveiligde computers of voor wegwerpinstanties zonder gevoelige gegevens, wil je misschien zonder versleuteling installeren. Je kunt op `Ctrl + C` drukken bij de bevestiging voor het formatteren van de schijf om over te schakelen naar een installatie zonder versleuteling.

### Taal

Omarchy spreekt 50 talen — dezelfde set als omarchy.org — en Engels is de standaard. Om te wisselen open je het Omarchy-menu en ga je naar _Instellen > Regio > Taal_, of voer je `omarchy language <code>` uit in een terminal (`omarchy language list` toont de codes). Het menu, de desktop en Omarchy's eigen meldingen veranderen onmiddellijk van taal, en elke applicatie die je daarna opent, volgt ook. Apps die al open waren, wisselen zodra je ze opnieuw opstart.

Om de taal te behouden maar datums, tijden, getallen, geld, eenheden en papierformaten te schrijven zoals een andere regio dat doet (bijvoorbeeld Engels met Europese datums en een 24-uursklok), kies je een regio onder _Instellen > Regio > Indelingen_, waar elke keuze een voorbeeld toont, of voer je `omarchy region <code>` uit (`omarchy region list` toont de codes). _Zelfde als taal_ gaat terug naar de eigen indelingen van de taal. Net als bij het wisselen van taal geldt dit voor de apps die je daarna opent.

### Hulp als je vastloopt

Als je vastloopt, vind je meestal wel iemand die wil helpen in het _#omarchy-help_-kanaal op [de community-Discord](https://omarchy.org/discord).
