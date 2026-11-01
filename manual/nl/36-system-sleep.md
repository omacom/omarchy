# Slaapstand van het systeem

Omarchy schakelt suspend en sluimerstand standaard in, maar als je op je machine problemen hebt met een van beide, kun je ze uitschakelen.

Op NVIDIA GB10-machines, zoals de DGX Spark en de ASUS Ascent GX10, zijn suspend en sluimerstand uitgeschakeld, net als in NVIDIA's DGX OS, omdat nog niet is aangetoond dat slaapstand op die hardware werkt. De suspend-schakelaar en de instelling van sluimerstand zijn daar niet van toepassing. Om slaapstand weer in te schakelen, verwijder je `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` met `sudo rm`; Suspend verschijnt dan weer in het menu, en sluimerstand kan worden ingesteld zoals op andere machines. Door `sudo omarchy apply hardware --install-user "$USER"` uit te voeren, zet je het bestand terug.

### Energieprofielen

Op een laptop onthoudt Omarchy je energieprofiel afzonderlijk voor aangesloten op netstroom en draaiend op de accu, en schakelt het tussen de twee wanneer je de stekker aansluit en loskoppelt. Standaard betekent dat de prestatiemodus op AC en de gebalanceerde modus op de accu.

Je kunt zien wat je machine te bieden heeft met `omarchy powerprofiles list`, en het profiel instellen dat je wilt voor de toestand waarin je je momenteel bevindt met `omarchy powerprofiles set autodetect power-saver`. Om de andere toestand in te stellen zonder iets los te koppelen, benoem je die rechtstreeks: `omarchy powerprofiles set battery power-saver`. Wat je ook kiest, dat krijg je de volgende keer dat je je in die toestand bevindt weer terug.

### Suspend in-/uitschakelen

Je schakelt suspend in of uit door `omarchy toggle suspend` uit te voeren vanuit de terminal. Daarmee toon/verberg je alleen de optie onder _Systeem_ (of `Super + Esc`), waarna je kunt zien of het consistent werkt op je systeem. Zo niet, dan kun je het met hetzelfde commando weer verbergen.

### Sluimerstand in-/uitschakelen

Je stelt sluimerstand in door `omarchy hibernation setup` uit te voeren vanuit de terminal. Sluimerstand maakt een /swap-subvolume aan op je opstartschijf ter grootte van je fysieke RAM-toewijzing, dus zorg ervoor dat je genoeg ruimte over hebt. Op een machine met 32GB heb je altijd 32GB+ vrij nodig voor dit volume. Voor sluimerstand is ook de standaard Limine-bootloader vereist.

Eenmaal ingesteld zie je de optie voor sluimerstand onder _Systeem_ (of `Super + Esc`), waarna je kunt zien of het consistent werkt op je systeem. Zo niet, dan kun je het weer verwijderen door `omarchy hibernation remove` uit te voeren.
