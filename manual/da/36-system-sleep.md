# Systemdvale

Omarchy aktiverer suspendering som standard og dvale, når det er sat op, men hvis du har problemer med en af delene på din maskine, kan du slå dem fra.

På NVIDIA GB10-maskiner, såsom DGX Spark og ASUS Ascent GX10, er suspendering og dvale slået fra, ligesom i NVIDIA's DGX OS, fordi søvn endnu ikke har vist sig at virke på den hardware. Det samme gælder for ASUS Zenbook A16 (UX3607OA), hvor suspendering endnu ikke får chippen til at sove helt og kan få systemet til at hænge natten over. Knappen til at slå suspendering til/fra og opsætningen af dvale gælder ikke dér. For at slå søvn til igen skal du fjerne `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` med `sudo rm`; Suspender vender derefter tilbage til menuen, og dvale kan sættes op som på andre maskiner. Hvis du kører `sudo omarchy apply hardware --install-user "$USER"`, bliver filen genskabt.

### Strømprofiler

På en bærbar husker Omarchy din strømprofil separat for tilsluttet strøm og batteridrift og skifter mellem de to, når du sætter strøm til og tager den fra. Som standard betyder det ydeevne på AC og balanceret på batteri.

Du kan se, hvad din maskine tilbyder, med `omarchy powerprofiles list` og indstille den, du ønsker for den tilstand, du aktuelt er i, med `omarchy powerprofiles set autodetect power-saver`. For at indstille den anden tilstand uden at tage strømmen fra skal du navngive den direkte: `omarchy powerprofiles set battery power-saver`. Hvad du end vælger, er det, du får tilbage, næste gang du er i den tilstand.

### Slå suspendering til/fra

Du slår suspendering til/fra ved at køre `omarchy toggle suspend` fra terminalen. Det viser/skjuler blot muligheden under _System_ (eller `Super + Esc`), og derefter kan du se, om det virker konsekvent på dit system. Hvis ikke, kan du skjule den igen med den samme kommando.

### Slå dvale til/fra

Du sætter dvale op ved at køre `omarchy hibernation setup` fra terminalen (det er ikke tilgængeligt på Apple Silicon-Macs). Dvale opretter et /swap-undervolumen på dit opstartsdrev på størrelse med din fysiske RAM-allokering, så sørg for, at du har rigeligt med plads til overs. På en 32GB-maskine skal du altid have 32GB+ ledigt til dette volumen. Dvale kræver også den standard Limine-bootloader.

Når det er sat op, vil du se dvalemuligheden under _System_ (eller `Super + Esc`), og derefter kan du se, om det virker konsekvent på dit system. Hvis ikke, kan du fjerne den igen ved at køre `omarchy hibernation remove`.
