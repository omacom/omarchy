# Systemdvale

Omarchy aktiverer hvile og dvale som standard, men hvis du har problemer med en af dem på din maskine, kan du slå dem fra.

### Strømprofiler

På en bærbar husker Omarchy din strømprofil separat for tilsluttet strøm og batteridrift og skifter mellem de to, efterhånden som du sætter stikket i og tager det ud. Ud af boksen betyder det ydeevne på AC og balanceret på batteri.

Du kan se, hvad din maskine tilbyder, med `omarchy powerprofiles list` og sætte den, du vil have, for den tilstand, du aktuelt er i, med `omarchy powerprofiles set autodetect power-saver`. For at sætte den anden tilstand uden at trække noget ud skal du navngive den direkte: `omarchy powerprofiles set battery power-saver`. Uanset hvad du vælger, er det, hvad du får tilbage, næste gang du er i den tilstand.

### Slå hvile til/fra

Du slår hvile til/fra ved at køre `omarchy toggle suspend` fra terminalen. Det viser/skjuler blot muligheden under _System_ (eller `Super + Esc`), og så kan du se, om det virker konsistent på dit system. Hvis ikke, kan du skjule den igen med samme kommando.

### Slå dvale til/fra

Du sætter dvale op ved at køre `omarchy hibernation setup` fra terminalen. Dvale opretter et /swap-undervolumen på dit bootdrev på størrelse med din fysiske RAM-allokering, så sørg for, at du har masser af plads til overs. På en 32GB-maskine skal du altid bruge 32GB+ fri til dette volumen. Dvale kræver også standard-Limine-bootloaderen.

Når det er sat op, vil du se dvale-muligheden under _System_ (eller `Super + Esc`), og så kan du se, om det virker konsistent på dit system. Hvis ikke, kan du fjerne det igen ved at køre `omarchy hibernation remove`.
