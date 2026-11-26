# Aan de slag

Omarchy installeer je met een ISO. Je kunt kiezen tussen een installatie op de volledige schijf, waarbij de hele schijf wordt overgenomen, of een installatie in vrije ruimte, waarbij Omarchy in de niet-toegewezen ruimte op een schijf wordt geplaatst — zo dualboot je naast Windows of een ander OS (zie [dual-boot-installatie](50-dual-boot-install.md) — let op dat je eerst BitLocker in Windows moet uitschakelen). Hoe dan ook is de installatie standaard volledig versleuteld, en de optie voor de volledige schijf wist de geselecteerde schijf, dus zorg ervoor dat je een back-up maakt voordat je een bestaande schijf gebruikt!

Op een Apple Silicon Mac installeer je in plaats daarvan vanuit macOS, zonder ISO of USB-stick. Zie [Omarchy voor Apple Silicon](44-mac-support.md#omarchy-for-apple-silicon).

[Download de Omarchy ISO](https://omarchy.org/) eerst, zet hem op een USB-stick (gebruik [Rufus](https://rufus.ie/) op Windows, [balenaEtcher](https://etcher.balena.io/) op Mac of [caligula](https://github.com/ifd3f/caligula) op Linux) en start op vanaf de stick.

_Je moet Secure Boot en/of TPM uitschakelen in het BIOS. Je moet deze uitschakelen om Omarchy te kunnen installeren. Het zijn beveiligingsschema's van Microsoft, bedoeld voor Windows en aan Microsoft gelieerde Linux-distributies._

Beantwoord daarna de configuratievragen en bevestig ze als volgt:

 ![install-config](images/install-config.webp)

Selecteer daarna een schijf voor je installatie, leun achterover en kijk hoe de installatieshow zich ontvouwt. Op de snelste moderne machines kan het in minder dan een minuut klaar zijn, maar zelfs op een oudere computer zou het niet meer dan 5 minuten mogen duren.

 ![install-done](images/install-done.webp)

Nu ben je klaar voor Omarchy!

### Gebruik een bedraad of 2.4ghz-toetsenbord!

Door de versleuteling van de volledige schijf kun je het wachtwoord bij het opstarten niet invoeren vanaf een Bluetooth-toetsenbord. Net zoals je geen Bluetooth-toetsenbord kunt gebruiken om het BIOS op een PC te openen. Je hebt een toetsenbord nodig dat een 2.4ghz-dongle gebruikt of een kabel (wat sowieso veel fijner is voor de latency!). Zelf ben ik dol op de [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Installeren voor een andere eigenaar

Als je een machine instelt voor iemand anders — een familielid, een nieuwe medewerker, een koper — moet je de persoonlijke vragen niet namens diegene beantwoorden. Druk op `Ctrl + C` in het allereerste scherm van het installatieprogramma (de toetsenbordselectie) en Omarchy zal aanbieden om de machine in plaats daarvan voor te bereiden voor een andere eigenaar. Het systeem wordt meteen geïnstalleerd, maar alle persoonlijke instellingen — toetsenbordindeling, gebruikersnaam, wachtwoord — worden uitgesteld tot de machine voor het eerst opstart. De schijf is nog steeds standaard versleuteld, en het wachtwoord dat de nieuwe eigenaar bij die eerste keer opstarten kiest, wordt ook het versleutelingswachtwoord. (Een machine die je al hebt gebruikt, kan ook zonder herinstallatie worden overgedragen — zie [de computer resetten](48-security.md).)

### Installaties zonder toezicht

De ISO kan ook volledig zelfstandig installeren — geen toetsenbord, geen wizard — wanneer de configuratie op een tweede schijf wordt aangeleverd. Zo behandel je Omarchy als een basisimage voor VM's en machineparken. Zie [installaties zonder toezicht](51-unattended-installs.md).

### Installaties zonder versleuteling

Omarchy wordt standaard met versleuteling geïnstalleerd. Dat is de veilige, verantwoorde keuze voor elke computer die mogelijk kwijtraakt of wordt gestolen. Je wilt niet dat iemand met toegang tot je hardware bij je gegevens kan!

Maar in speciale omstandigheden, zoals externe Omarchy-installaties op beveiligde computers of wegwerpinstanties zonder gevoelige gegevens, wil je misschien zonder versleuteling installeren. Je kunt op `Ctrl + C` drukken bij de bevestiging voor het formatteren van de schijf om over te schakelen naar een installatie zonder versleuteling.

### Taal

Omarchy spreekt 50 talen — dezelfde set als omarchy.org — en Engels is de standaardtaal. Om te wisselen open je het Omarchy-menu en ga je naar _Setup > Region > Language_, of voer je `omarchy language <code>` uit in een terminal (`omarchy language list` toont de codes). Het menu, het bureaublad en Omarchy's eigen meldingen wisselen onmiddellijk van taal, en elke applicatie die je daarna opent, volgt ook. Apps die al open waren, wisselen zodra je ze opnieuw opstart.

Om de taal te behouden maar datums, tijden, getallen, geld, eenheden en papierformaten te schrijven zoals een andere regio dat doet (bijvoorbeeld Engels met Europese datums en een 24-uursklok), kies je een regio onder _Setup > Region > Formats_, waar elke keuze een voorbeeld toont, of voer je `omarchy region formats <code>` uit (`omarchy region formats list` toont de codes). _Same as language_ gaat terug naar de formaten van de taal zelf. Net als bij het wisselen van taal geldt dit voor de apps die je daarna opent.

### Hulp als je vastzit

Als je vastzit, vind je meestal wel iemand die wil helpen in het _#omarchy-help_-kanaal op [de community-Discord](https://omarchy.org/discord).
