# Slaapstand van het systeem

Omarchy schakelt suspend en sluimerstand standaard in, maar als je met een van beide problemen hebt op je machine, kun je ze uitschakelen.

### Energieprofielen

Op een laptop onthoudt Omarchy je energieprofiel apart voor aangesloten op netstroom en draaiend op batterij, en schakelt het tussen de twee als je de stekker in- en uitplugt. Uit de doos betekent dat performance op netstroom en balanced op batterij.

Je kunt zien wat je machine biedt met `omarchy powerprofiles list`, en het profiel instellen dat je wilt voor de toestand waarin je je momenteel bevindt met `omarchy powerprofiles set autodetect power-saver`. Om de andere toestand in te stellen zonder iets los te koppelen, noem je hem direct: `omarchy powerprofiles set battery power-saver`. Wat je ook kiest, dat krijg je terug de volgende keer dat je in die toestand bent.

### Suspend in- of uitschakelen

Je schakelt suspend in of uit door `omarchy toggle suspend` uit te voeren vanuit de terminal. Dat toont of verbergt alleen de optie onder _Systeem_ (of `Super + Esc`), en dan kun je zien of het consistent werkt op je systeem. Zo niet, dan kun je hem weer verbergen met hetzelfde commando.

### Sluimerstand in- of uitschakelen

Je stelt de sluimerstand in door `omarchy hibernation setup` uit te voeren vanuit de terminal. De sluimerstand maakt een /swap-subvolume aan op je opstartschijf ter grootte van je fysieke RAM-toewijzing, dus zorg dat je genoeg ruimte over hebt. Op een machine met 32 GB heb je altijd 32 GB+ vrij nodig voor dit volume. De sluimerstand vereist ook de standaard Limine-bootloader.

Als hij is ingesteld, zie je de optie voor de sluimerstand onder _Systeem_ (of `Super + Esc`), en dan kun je zien of het consistent werkt op je systeem. Zo niet, dan kun je hem weer verwijderen door `omarchy hibernation remove` uit te voeren.
