# Systemhvile

Omarchy aktiverer hviletilstand og dvaletilstand som standard, men hvis du har problemer med en af dem på din maskine, kan du slå dem fra.

På NVIDIA GB10-maskiner, såsom DGX Spark og ASUS Ascent GX10, er hviletilstand og dvaletilstand slået fra, ligesom de er i NVIDIA's DGX OS, fordi hvile endnu ikke har vist sig at virke på den hardware. Kontakten til hviletilstand og opsætningen af dvaletilstand gælder ikke dér. For at slå hvile til igen skal du fjerne `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` med `sudo rm`; derefter vender Hvile tilbage til menuen, og dvaletilstand kan sættes op som på andre maskiner. Kørsel af `sudo omarchy apply hardware --install-user "$USER"` lægger filen tilbage.

### Strømprofiler

På en bærbar husker Omarchy din strømprofil separat for tilsluttet strøm og batteridrift og skifter mellem de to, når du sætter stikket i og tager det ud. Fra start betyder det ydeevne på AC og balanceret på batteri.

Du kan se, hvad din maskine tilbyder, med `omarchy powerprofiles list`, og indstille den, du vil have til den tilstand, du aktuelt er i, med `omarchy powerprofiles set autodetect power-saver`. For at indstille den anden tilstand uden at trække noget ud skal du nævne den direkte: `omarchy powerprofiles set battery power-saver`. Uanset hvad du vælger, er det det, du får tilbage, næste gang du er i den tilstand.

### Slå hviletilstand til/fra

Du slår hviletilstand til og fra ved at køre `omarchy toggle suspend` fra terminalen. Det viser/skjuler blot valgmuligheden under _System_ (eller `Super + Esc`), og så kan du se, om den virker konsekvent på dit system. Hvis ikke, kan du skjule den igen med samme kommando.

### Slå dvaletilstand til/fra

Du sætter dvaletilstand op ved at køre `omarchy hibernation setup` fra terminalen. Dvaletilstand opretter en /swap-undervolumen på dit bootdrev på størrelse med din fysiske RAM-allokering, så sørg for at have masser af plads til overs. På en 32GB-maskine skal du altid have 32GB+ ledig plads til denne volumen. Dvaletilstand kræver også standardbootloaderen Limine.

Når den er sat op, ser du dvale-valgmuligheden under _System_ (eller `Super + Esc`), og så kan du se, om den virker konsekvent på dit system. Hvis ikke, kan du fjerne den igen ved at køre `omarchy hibernation remove`.
