# Slaapstand van het systeem

Omarchy schakelt slaapstand en sluimerstand standaard in, maar als je op je machine problemen ondervindt met een van beide, kun je ze uitschakelen.

Op NVIDIA GB10-machines, zoals de DGX Spark en de ASUS Ascent GX10, zijn slaapstand en sluimerstand uitgeschakeld, net als in NVIDIA's DGX OS, omdat nog niet is aangetoond dat slaapstand op die hardware werkt. Hetzelfde geldt voor de ASUS Zenbook A16 (UX3607OA), waar de slaapstand de chip nog niet volledig in slaap brengt en 's nachts kan vastlopen. De schakelaar voor de slaapstand en de instelling van de sluimerstand zijn daar niet van toepassing. Om slaapstand weer in te schakelen, verwijder je `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` met `sudo rm`; Slaapstand keert dan terug in het menu, en de sluimerstand kan worden ingesteld zoals op andere machines. Met `sudo omarchy apply hardware --install-user "$USER"` zet je het bestand terug.

### Energieprofielen

Op een laptop onthoudt Omarchy je energieprofiel afzonderlijk voor aangesloten op netstroom en werken op de accu, en schakelt het tussen de twee wanneer je de stekker aansluit of loskoppelt. Standaard betekent dat performance op netstroom en balanced op de accu.

Je kunt zien wat je machine biedt met `omarchy powerprofiles list`, en degene instellen die je wilt voor de toestand waarin je je momenteel bevindt met `omarchy powerprofiles set autodetect power-saver`. Om de andere toestand in te stellen zonder iets los te koppelen, benoem je die direct: `omarchy powerprofiles set battery power-saver`. Wat je ook kiest, dat krijg je de volgende keer dat je in die toestand bent weer terug.

### Slaapstand omschakelen

Je schakelt de slaapstand om door `omarchy toggle suspend` uit te voeren vanuit de terminal. Dat toont/verbergt alleen de optie onder _System_ (of `Super + Esc`), en dan kun je zien of het consequent werkt op je systeem. Zo niet, dan kun je het weer verbergen met dezelfde opdracht.

### Sluimerstand omschakelen

Je stelt de sluimerstand in door `omarchy hibernation setup` uit te voeren vanuit de terminal. De sluimerstand maakt een /swap-subvolume aan op je opstartschijf ter grootte van je fysieke RAM-toewijzing, dus zorg ervoor dat je genoeg ruimte over hebt. Op een machine met 32GB heb je altijd 32GB+ vrij nodig voor dit volume. De sluimerstand vereist ook de standaard Limine-bootloader.

Wanneer het is ingesteld, zie je de optie voor sluimerstand onder _System_ (of `Super + Esc`), en dan kun je zien of het consequent werkt op je systeem. Zo niet, dan kun je het weer verwijderen door `omarchy hibernation remove` uit te voeren.
