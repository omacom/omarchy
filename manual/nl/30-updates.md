# Updates

Omarchy en je pakketten worden up-to-date gehouden via _Update > Omarchy_ in het Omarchy-menu (`Super + Space`).

Omarchy zelf wordt geïnstalleerd als reguliere pacman-pakketten uit de [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), dus een update installeert [de nieuwste Omarchy-release](https://github.com/omacom/omarchy/releases), voert alle openstaande migraties uit om je systeem in sync te brengen met de nieuwste versie, en werkt alle systeempakketten bij vanaf de [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) en [AUR](https://aur.archlinux.org/) (als je AUR-pakketten hebt geïnstalleerd).

Wanneer er nieuwe releases verschijnen, verschijnt er een icoon met een cirkelpijl rechts van je klok. Klik erop en het updateproces begint.

![update-available](images/update-available.webp)

### Vier kanalen

Omarchy wordt bijgewerkt via vier kanalen: stable, RC, edge en dev. Nieuwe installaties beginnen op het stable-kanaal, dat de [officiële releases](https://github.com/omacom/omarchy/releases/) volgt, evenals de [stable Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror) die een maand achterloopt op de nieuwste versie, zodat we nieuwe incompatibiliteiten die configuratiewijzigingen vereisen kunnen opvangen voordat ze problemen veroorzaken voor mensen.

Maar als je wilt helpen om die potentiële problemen op te sporen, kun je op het edge-kanaal draaien. Dan blijven je Omarchy-pakketten de nieuwste ontwikkelbuilds volgen, en kun je updaten naar de nieuwste Arch-pakketten zodra ze beschikbaar zijn. Doe dit alleen als je ervaren bent met Linux en weet hoe je een systeem met problemen kunt herstellen.

Voor elke nieuwe grote release doen we een laatste validatie via het RC-kanaal. Als je wilt helpen met de laatste afwerking, kom dan hangen in #omarchy-release-candidates op de Discord.

Tot slot is er het dev-kanaal, dat Omarchy rechtstreeks koppelt aan een git-checkout van de broncode in `~/omarchy`, gecombineerd met de edge-pakketten. Gebruik dit kanaal alleen als je een ervaren Linux-gebruiker bent, rechtstreeks aan Omarchy werkt en bereid bent om breakage te tolereren.

Je kunt tussen kanalen wisselen via _Update > Channel_ in het Omarchy-menu (of `omarchy channel set <stable|rc|edge|dev>` in de terminal, met `omarchy channel current` om te zien waar je zit).

### Kernels wisselen

Omarchy start met zijn eigen `linux-omarchy`-kernel, maar je kunt er andere naast geïnstalleerd houden, zoals de standaard Arch `linux`-kernel of een experimentele build die je aan het testen bent. Als er meer dan één is, toont _Update > Kernel_ in het Omarchy-menu ze met een vinkje naast degene die standaard opstart. Kies een andere, voer eenmaal je wachtwoord in, en die start op na de volgende herstart. De andere kernels blijven in het opstartmenu staan, dus je kunt er nog steeds handmatig een kiezen als de nieuwe standaard problemen geeft. In de terminal is het `omarchy kernel` om de huidige standaard te zien, `omarchy kernel list` voor wat er geïnstalleerd is, en `omarchy kernel set <kernel>` om te wisselen.

### Firmware-updates

Je pakketten zijn niet het enige dat veroudert. Veel laptops en randapparatuur leveren BIOS-, SSD- en dockfirmware via de Linux Vendor Firmware Service, en _Update > Firmware_ in het Omarchy-menu haalt alles op en installeert het wat je hardware klaar heeft staan. De eerste keer dat je het uitvoert, installeert het `fwupd`. Veel firmware kan alleen tijdens een herstart worden weggeschreven, dus wees niet verbaasd als er om een herstart wordt gevraagd.

Wanneer je een instelling in de BIOS zelf moet wijzigen, houd je `Alt` ingedrukt in het systeemmenu (`Super + Escape`) en verandert _Reboot_ in _Reboot to BIOS_, waarmee je rechtstreeks herstart naar de firmware-setup zonder op het juiste moment de juiste toets te hoeven indrukken bij het opstarten. Vanuit de terminal is het `omarchy system firmware`.

### Waarschuwing over directe pacman/yay-updates

Als je al bekend bent met Arch, kom je misschien in de verleiding om zelf gewoon `pacman -Syu` of `yay -Syu` uit te voeren, maar als je dat doet, mis je de snapshot, migraties en configuratie-updates die Omarchy samen met nieuwe pakketten uitvoert. Daarom stopt Omarchy een directe systeemupgrade en verwijst je in plaats daarvan naar `omarchy update`. (Als je echt weet wat je doet, vertelt de beveiliging je hoe je die voor een enkele transactie kunt omzeilen.)

### Slechte updates terugdraaien

Als je ooit een probleem hebt na het uitvoeren van een update, kun je je systeem terugzetten naar de snapshot die vóór de update is genomen. Herstart gewoon en kies in het opstartmenu de snapshot van vóór je met de update begon.

![bootloader](images/bootloader.webp)

Als je configuratiebestanden op de een of andere manier beschadigd zijn geraakt, kun je ook een Omarchy-herinstallatie uitvoeren met `omarchy reinstall` in de terminal. Dit installeert alle standaard Omarchy-pakketten opnieuw, zet je op stable (edge op Apple Silicon) en downgradet alle pakketten die te nieuw zijn, en reset alle configuratiebestanden. Let op: al je eigen configuratiewijzigingen aan de Omarchy-standaarden worden hierbij overschreven!
