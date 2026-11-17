# Updates

Omarchy en je pakketten worden up-to-date gehouden via _Update > Omarchy_ in het Omarchy-menu (`Super + Space`).

Omarchy zelf wordt geïnstalleerd als gewone pacman-pakketten uit de [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), dus een update installeert [de nieuwste Omarchy-release](https://github.com/omacom/omarchy/releases), voert alle openstaande migraties uit om je systeem in sync te brengen met de nieuwste versie, en werkt alle systeempakketten bij uit de [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) en [AUR](https://aur.archlinux.org/) (als je AUR-pakketten hebt geïnstalleerd).

Wanneer er nieuwe releases uitkomen, verschijnt er een icoon met een cirkelpijl rechts van je klok. Klik erop en het updateproces start.

![update-available](images/update-available.webp)

### Vier kanalen

Omarchy wordt bijgewerkt via vier kanalen: stable, RC, edge en dev. Nieuwe installaties beginnen op het stable-kanaal, dat de [officiële releases](https://github.com/omacom/omarchy/releases/) volgt, evenals de [stable Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror) die een maand achterloopt op de nieuwste versie, zodat we nieuwe incompatibiliteiten die configuratiewijzigingen vereisen kunnen opvangen voordat ze problemen veroorzaken voor mensen.

Maar als je wilt helpen om die potentiële problemen op te sporen, kun je op het edge-kanaal draaien. Dan blijven je Omarchy-pakketten de nieuwste development-builds volgen, en kun je bijwerken naar de nieuwste Arch-pakketten zodra ze beschikbaar zijn. Doe dit alleen als je ervaren bent met Linux en weet hoe je een systeem herstelt dat problemen heeft.

Vóór elke nieuwe grote release doen we de laatste validatie via het RC-kanaal. Als je wilt helpen met de laatste puntjes op de i, kom dan hangen in #omarchy-release-candidates op de Discord.

Tot slot is er het dev-kanaal, dat Omarchy rechtstreeks koppelt aan een git-checkout van de broncode in `~/omarchy`, gecombineerd met de edge-pakketten. Gebruik dit kanaal alleen als je een ervaren Linux-gebruiker bent, rechtstreeks aan Omarchy werkt en bereid bent om breakage te tolereren.

Je kunt wisselen tussen kanalen via _Update > Channel_ in het Omarchy-menu (of `omarchy-channel-set` in de terminal).

### Van kernel wisselen

Omarchy start met zijn eigen `linux-omarchy`-kernel, maar je kunt er andere naast geïnstalleerd houden, zoals de standaard Arch `linux`-kernel of een experimentele build die je test. Als er meer dan één is, zet _Update > Kernel_ in het Omarchy-menu ze op een rij met een vinkje naast degene die standaard opstart. Kies een andere, voer eenmalig je wachtwoord in, en die start na de volgende herstart. De andere kernels blijven in het opstartmenu staan, dus je kunt er nog steeds handmatig een kiezen als de nieuwe standaard je problemen geeft. In de terminal gebruik je `omarchy-kernel` om de huidige standaard te zien, `omarchy-kernel list` voor wat er geïnstalleerd is, en `omarchy-kernel set <kernel>` om te wisselen.

### Firmware-updates

Je pakketten zijn niet het enige dat veroudert. Veel laptops en randapparatuur leveren BIOS-, SSD- en dockfirmware via de Linux Vendor Firmware Service, en _Update > Firmware_ in het Omarchy-menu haalt op en installeert wat er voor je hardware klaarstaat. De eerste keer dat je het uitvoert, installeert het `fwupd`. Veel firmware kan alleen tijdens een herstart worden weggeschreven, dus kijk er niet van op als je om een herstart wordt gevraagd.

Als je een instelling in de BIOS zelf moet wijzigen, houd je `Alt` ingedrukt in het systeemmenu (`Super + Escape`) en verandert _Reboot_ in _Reboot to BIOS_, waarmee je rechtstreeks opnieuw opstart in de firmware-setup zonder bij het opstarten op het juiste moment de juiste toets te hoeven raken. Vanuit de terminal is het `omarchy system firmware`.

### Waarschuwing over rechtstreekse pacman/yay-updates

Als je Arch al kent, kom je misschien in de verleiding om zelf gewoon `pacman -Syu` of `yay -Syu` uit te voeren, maar als je dat doet, mis je de snapshot, migraties en configuratie-updates die Omarchy samen met nieuwe pakketten uitvoert. Daarom stopt Omarchy een rechtstreekse systeemupgrade daadwerkelijk en verwijst je in plaats daarvan naar `omarchy update`. (Als je echt weet wat je doet, vertelt de beveiliging je hoe je die voor één enkele transactie kunt omzeilen.)

### Slechte updates terugdraaien

Als je ooit een probleem hebt na een update, kun je je systeem terugdraaien naar de snapshot die vóór de update is gemaakt. Herstart gewoon en kies in het opstartmenu de snapshot van vóór je met de update begon.

![bootloader](images/bootloader.webp)

Als je configuratiebestanden op de een of andere manier beschadigd zijn geraakt, kun je ook een Omarchy-herinstallatie uitvoeren met `omarchy reinstall` in de terminal. Dit installeert alle standaard Omarchy-pakketten opnieuw, zet je op stable en downgradet alle pakketten die te nieuw zijn, en reset alle configuratiebestanden. Let op: al je eigen configuratiewijzigingen ten opzichte van de Omarchy-standaarden worden hierbij overschreven!
