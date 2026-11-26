# Slaapstand van het systeem

Omarchy schakelt de slaapstand standaard in, en de sluimerstand zodra die is ingesteld, maar als je problemen hebt met een van beide op je machine, kun je ze uitschakelen.

Op NVIDIA GB10-machines, zoals de DGX Spark en de ASUS Ascent GX10, zijn de slaapstand en de sluimerstand uitgeschakeld, net als in NVIDIA's DGX OS, omdat nog niet is aangetoond dat de slaapstand op die hardware werkt. Hetzelfde geldt voor de ASUS Zenbook A16 (UX3607OA), waarbij de slaapstand de chip nog niet volledig in slaap brengt en 's nachts kan vastlopen. De schakelaar voor de slaapstand en het instellen van de sluimerstand zijn daar niet van toepassing. Om de slaapstand weer in te schakelen, verwijder je `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` met `sudo rm`; Suspend verschijnt dan weer in het menu, en de sluimerstand kan worden ingesteld zoals op andere machines. Door `sudo omarchy apply hardware --install-user "$USER"` uit te voeren, zet je het bestand terug.

### Energieprofielen

Op een laptop onthoudt Omarchy je energieprofiel afzonderlijk voor aangesloten op netstroom en werken op de accu, en schakelt het tussen de twee zodra je de stekker aansluit of loskoppelt. Standaard betekent dat performance op AC en balanced op de accu.

Je kunt zien wat je machine biedt met `omarchy powerprofiles list`, en het gewenste profiel instellen voor de toestand waarin je je momenteel bevindt met `omarchy powerprofiles set autodetect power-saver`. Om de andere toestand in te stellen zonder iets los te koppelen, benoem je die rechtstreeks: `omarchy powerprofiles set battery power-saver`. Wat je ook kiest, dat is wat je de volgende keer dat je in die toestand bent weer terugkrijgt.

### Slaapstand in- of uitschakelen

Je schakelt de slaapstand in of uit door `omarchy toggle suspend` uit te voeren vanuit de terminal. Dat toont/verbergt alleen de optie onder _System_ (of `Super + Esc`), waarna je kunt kijken of het consistent werkt op je systeem. Zo niet, dan kun je het met hetzelfde commando weer verbergen.

### Sluimerstand in- of uitschakelen

Je stelt de sluimerstand in door `omarchy hibernation setup` uit te voeren vanuit de terminal (het is niet beschikbaar op Apple Silicon Macs). De sluimerstand maakt een /swap-subvolume aan op je opstartschijf ter grootte van je fysieke RAM-toewijzing, dus zorg ervoor dat je voldoende ruimte over hebt. Op een machine met 32GB heb je altijd 32GB+ vrij nodig voor dit volume. De sluimerstand vereist ook de standaard Limine-bootloader.

Zodra het is ingesteld, zie je de optie voor de sluimerstand onder _System_ (of `Super + Esc`), waarna je kunt kijken of het consistent werkt op je systeem. Zo niet, dan kun je het weer verwijderen door `omarchy hibernation remove` uit te voeren.
