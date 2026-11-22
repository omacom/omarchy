# Aan de slag

Omarchy wordt geïnstalleerd met behulp van een ISO. Je kunt kiezen tussen een installatie op de volledige schijf, die de hele schijf overneemt, of een installatie in de vrije ruimte, die Omarchy in de niet-toegewezen ruimte op een schijf plaatst — zo dual boot je naast Windows of een ander OS (zie [installatie voor dual boot](50-dual-boot-install.md) — let op dat je eerst BitLocker in Windows moet uitschakelen). In beide gevallen gebruikt de installatie standaard volledige versleuteling, en de optie voor de volledige schijf wist de geselecteerde schijf, dus zorg dat je een back-up maakt voordat je een bestaande schijf gebruikt!

[Download eerst de Omarchy ISO](https://omarchy.org/), zet hem op een USB-stick (gebruik [Rufus](https://rufus.ie/) op Windows, [balenaEtcher](https://etcher.balena.io/) op Mac, of [caligula](https://github.com/ifd3f/caligula) op Linux), en start op vanaf de stick.

_Je moet Secure Boot en/of TPM in de BIOS uitschakelen. Je moet deze uitschakelen om Omarchy te kunnen installeren. Het zijn beveiligingsschema's van Microsoft, bedoeld voor Windows en aan Microsoft gelieerde Linux-distributies._

Beantwoord daarna de configuratievragen en bevestig ze zo:

 ![install-config](images/install-config.webp)

Selecteer daarna een schijf voor je installatie, leun achterover en kijk hoe de installatieshow voorbijrolt. Op de snelste moderne machines kan het in minder dan een minuut klaar zijn, maar zelfs op een oudere computer zou het niet meer dan 5 minuten moeten duren.

 ![install-done](images/install-done.webp)

Nu ben je klaar voor Omarchy!

### Gebruik een bedraad toetsenbord of een toetsenbord met 2.4ghz!

Met de volledige schijfversleuteling kun je bij het opstarten geen wachtwoord invoeren vanaf een Bluetooth-toetsenbord. Net zoals je geen Bluetooth-toetsenbord kunt gebruiken om de BIOS op een pc te openen. Je hebt een toetsenbord nodig dat een 2.4ghz-dongle of een kabel gebruikt (wat voor latency sowieso veel fijner is!). Persoonlijk ben ik dol op de [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Installeren voor een andere eigenaar

Als je een machine instelt voor iemand anders — een familielid, een nieuwe medewerker, een koper — moet je de persoonlijke vragen niet namens hen beantwoorden. Druk op `Ctrl + C` op het allereerste scherm van het installatieprogramma (de toetsenbordselectie), en Omarchy biedt aan om de machine in plaats daarvan voor te bereiden voor een andere eigenaar. Het systeem wordt meteen geïnstalleerd, maar alle persoonlijke instellingen — toetsenbordindeling, gebruikersnaam, wachtwoord — worden uitgesteld tot de machine voor het eerst opstart. De schijf is nog steeds standaard versleuteld, en het wachtwoord dat de nieuwe eigenaar bij die eerste keer opstarten kiest, wordt ook het versleutelingswachtwoord. (Een machine die je al hebt gebruikt, kun je ook zonder herinstallatie overdragen — zie [de computer resetten](48-security.md).)

### Onbeheerde installaties

De ISO kan ook helemaal zelfstandig installeren — geen toetsenbord, geen wizard — als hij zijn configuratie op een tweede schijf krijgt aangeleverd. Dat is dé manier om Omarchy te behandelen als basisimage voor VMs en hele machineparken. Zie [onbeheerde installaties](51-unattended-installs.md).

### Installaties zonder versleuteling

Omarchy wordt standaard met versleuteling geïnstalleerd. Dat is de veilige, verantwoorde keuze voor elke computer die mogelijk verloren kan raken of gestolen kan worden. Je wilt niet dat iemand met toegang tot je hardware bij je gegevens kan!

Maar in bijzondere omstandigheden, zoals Omarchy-installaties op afstand op beschermde computers of voor wegwerpinstanties zonder gevoelige gegevens, wil je misschien installeren zonder versleuteling. Je kunt op `Ctrl + C` drukken bij de bevestiging voor het formatteren van de schijf om over te schakelen naar een installatie zonder versleuteling.

### Taal

Omarchy spreekt 50 talen — dezelfde set als omarchy.org — en Engels is de standaard. Om te wisselen open je het Omarchy-menu en ga je naar _Instellingen > Regio > Taal_, of voer je `omarchy language <code>` uit in een terminal (`omarchy language list` toont de codes). Het menu, het bureaublad en Omarchy's eigen meldingen veranderen onmiddellijk van taal, en elke applicatie die je daarna opent, volgt ook. Apps die al open waren, schakelen over zodra je ze opnieuw opstart.

Om de taal te behouden maar datums, tijden, getallen, geld, eenheden en papierformaten te schrijven zoals een andere regio dat doet (bijvoorbeeld Engels met Europese datums en een 24-uursklok), kies je een regio onder _Instellingen > Regio > Formaten_, waar elke keuze een voorbeeld toont, of voer je `omarchy region formats <code>` uit (`omarchy region formats list` toont de codes). Met _Zelfde als taal_ ga je terug naar de eigen formaten van de taal. Net als bij het wisselen van taal bereikt het de apps die je daarna opent.

### Hulp als je vastloopt

Als je vastloopt, vind je meestal wel iemand die wil helpen in het _#omarchy-help_-kanaal op [de community-Discord](https://omarchy.org/discord).
