# Updates

Omarchy en je pakketten worden up-to-date gehouden via _Bijwerken > Omarchy_ in het Omarchy-menu (`Super + Space`).

Omarchy zelf wordt geïnstalleerd als gewone pacman-pakketten vanuit de [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), dus een update installeert [de nieuwste Omarchy-release](https://github.com/omacom/omarchy/releases), voert eventuele openstaande migraties uit om je systeem synchroon te brengen met de nieuwste versie, en werkt alle systeem-pakketten bij vanuit de [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) en [AUR](https://aur.archlinux.org/) (als je AUR-pakketten hebt geïnstalleerd).

Wanneer er nieuwe releases worden gemaakt, verschijnt er een cirkelpijlpictogram rechts van je klok. Klik erop en het updateproces start.

![update-available](images/update-available.webp)

### Vier kanalen

Omarchy wordt bijgewerkt via vier kanalen: stable, RC, edge en dev. Nieuwe installaties beginnen op het stable-kanaal, dat de [officiële releases](https://github.com/omacom/omarchy/releases/) volgt, evenals de [stable Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror) die een maand achterloopt op de nieuwste, zodat we nieuwe incompatibiliteiten die configuratiewijzigingen vereisen kunnen opvangen voordat ze problemen voor mensen veroorzaken.

Maar als je wilt helpen die potentiële problemen te spotten, kun je op het edge-kanaal draaien. Dat houdt je Omarchy-pakketten de nieuwste ontwikkelbuilds volgend, en laat je bijwerken naar de nieuwste Arch-pakketten zodra ze beschikbaar zijn. Je moet dit alleen doen als je ervaren bent met Linux, en weet hoe je een systeem met problemen kunt herstellen.

Voor elke nieuwe grote release doen we de uiteindelijke validatie met het RC-kanaal. Als je geïnteresseerd bent om te helpen met de laatste afwerking, kom dan hangen in #omarchy-release-candidates op de Discord.

Ten slotte is er het dev-kanaal, dat Omarchy direct koppelt aan een git-checkout van de broncode in `~/omarchy`, gecombineerd met de edge-pakketten. Je moet dit kanaal alleen gebruiken als je een ervaren Linux-gebruiker bent, direct aan Omarchy werkt, en bereid bent breuk te tolereren.

Je kunt schakelen tussen kanalen via _Bijwerken > Channel_ in het Omarchy-menu (of `omarchy-channel-set` in de terminal).

### Firmware-updates

Je pakketten zijn niet het enige dat veroudert. Veel laptops en randapparaten leveren BIOS-, SSD- en dockfirmware via de Linux Vendor Firmware Service, en _Bijwerken > Firmware_ in het Omarchy-menu haalt en installeert wat je hardware ook in de wacht heeft. Het installeert `fwupd` de eerste keer dat je het uitvoert. Veel firmware kan alleen tijdens een herstart worden geschreven, dus wees niet verbaasd als je erom wordt gevraagd.

### Waarschuwing over directe pacman/yay-updates

Als je al bekend bent met Arch, kom je misschien in de verleiding om gewoon zelf `pacman -Syu` of `yay -Syu` uit te voeren, maar als je dat doet, mis je de snapshot, migraties en configuratie-updates die Omarchy samen met nieuwe pakketten uitvoert. Daarom stopt Omarchy een directe systeemupgrade daadwerkelijk en wijst je in plaats daarvan naar `omarchy update`. (Als je echt weet wat je doet, vertelt de guard je hoe je hem voor een enkele transactie kunt omzeilen.)

### Slechte updates terugdraaien

Als je ooit een probleem hebt na het doen van een update, kun je je systeem terugdraaien naar de snapshot die vóór de update is genomen. Herstart gewoon en kies de snapshot in het bootloader-menu van voordat je de update startte.

![bootloader](images/bootloader.webp)

Als je configuratiebestanden op de een of andere manier beschadigd zijn geraakt, kun je ook een Omarchy-herinstallatie uitvoeren met `omarchy reinstall` in de terminal. Dit herinstalleert alle standaard Omarchy-pakketten, zet je op stable en downgradet alle pakketten die te nieuw zijn, en reset alle configuratiebestanden. Let op dat al je gebruikersconfiguratiewijzigingen aan de Omarchy-standaardwaarden hierbij worden overschreven!
