# Slaapstand

Omarchy schakelt slaapstand standaard in, en sluimerstand zodra die is ingesteld, maar als je met een van beide problemen hebt op je machine, kun je ze uitschakelen.

Op NVIDIA GB10-machines, zoals de DGX Spark en de ASUS Ascent GX10, zijn slaapstand en sluimerstand uitgeschakeld, net als in NVIDIA's DGX OS, omdat nog niet is aangetoond dat slaapstand op die hardware werkt. De schakelaar voor slaapstand en het instellen van sluimerstand zijn daar niet van toepassing. Om slaapstand weer in te schakelen, verwijder je `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` met `sudo rm`; Slaapstand verschijnt dan weer in het menu, en sluimerstand kan worden ingesteld zoals op andere machines. Met `sudo omarchy apply hardware --install-user "$USER"` zet je het bestand weer terug.

### Energieprofielen

Op een laptop onthoudt Omarchy je energieprofiel afzonderlijk voor aangesloten op netstroom en werken op batterij, en schakelt tussen de twee als je de stekker aansluit of loskoppelt. Standaard betekent dat prestatie op netstroom en gebalanceerd op batterij.

Je kunt zien wat je machine biedt met `omarchy powerprofiles list`, en het profiel instellen dat je wilt voor de toestand waarin je je momenteel bevindt met `omarchy powerprofiles set autodetect power-saver`. Om de andere toestand in te stellen zonder iets los te koppelen, benoem je die direct: `omarchy powerprofiles set battery power-saver`. Wat je ook kiest, dat krijg je de volgende keer dat je in die toestand bent weer terug.

### Slaapstand in-/uitschakelen

Je schakelt slaapstand in of uit door `omarchy toggle suspend` uit te voeren vanuit de terminal. Dat toont/verbergt alleen de optie onder _System_ (of `Super + Esc`), waarna je kunt kijken of het consistent werkt op je systeem. Zo niet, dan kun je het met hetzelfde commando weer verbergen.

### Sluimerstand in-/uitschakelen

Je stelt sluimerstand in door `omarchy hibernation setup` uit te voeren vanuit de terminal (het is niet beschikbaar op Apple Silicon Macs). Sluimerstand maakt een /swap-subvolume aan op je opstartschijf ter grootte van je fysieke RAM-toewijzing, dus zorg dat je genoeg ruimte over hebt. Op een machine met 32GB heb je hier altijd 32GB+ vrij voor nodig. Sluimerstand vereist ook de standaard Limine-bootloader.

Eenmaal ingesteld zie je de optie voor sluimerstand onder _System_ (of `Super + Esc`), waarna je kunt kijken of het consistent werkt op je systeem. Zo niet, dan kun je het weer verwijderen door `omarchy hibernation remove` uit te voeren.
