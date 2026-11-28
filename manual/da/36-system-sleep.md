# Systemsøvn

Omarchy aktiverer suspendering som standard og dvale, når den er sat op, men hvis du har problemer med en af delene på din maskine, kan du slå dem fra.

På NVIDIA GB10-maskiner, såsom DGX Spark og ASUS Ascent GX10, er suspendering og dvale slået fra, ligesom de er i NVIDIA's DGX OS, fordi søvn endnu ikke har vist sig at fungere på den hardware. Kontakten til suspendering og opsætningen af dvale gælder ikke dér. For at slå søvn til igen skal du fjerne `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` med `sudo rm`; så vender Suspend tilbage til menuen, og dvale kan sættes op som på andre maskiner. Hvis du kører `sudo omarchy apply hardware --install-user "$USER"`, kommer filen tilbage.

### Strømprofiler

På en bærbar husker Omarchy din strømprofil separat for tilsluttet strøm og batteridrift og skifter mellem de to, når du sætter stikket i og tager det ud. Som standard betyder det performance på AC og balanced på batteri.

Du kan se, hvad din maskine tilbyder, med `omarchy powerprofiles list` og indstille den, du ønsker for den tilstand, du aktuelt er i, med `omarchy powerprofiles set autodetect power-saver`. For at indstille den anden tilstand uden at tage stikket ud skal du navngive den direkte: `omarchy powerprofiles set battery power-saver`. Det, du vælger, er det, du får tilbage, næste gang du er i den tilstand.

### Slå suspendering til/fra

Du slår suspendering til/fra ved at køre `omarchy toggle suspend` fra terminalen. Det viser/skjuler bare indstillingen under _System_ (eller `Super + Esc`), og så kan du se, om det fungerer konsekvent på dit system. Hvis ikke, kan du skjule den igen med den samme kommando.

### Slå dvale til/fra

Du sætter dvale op ved at køre `omarchy hibernation setup` fra terminalen (det er ikke tilgængeligt på Apple Silicon Macs). Dvale opretter et /swap-undervolumen på dit opstartsdrev på størrelse med din fysiske RAM-allokering, så sørg for, at du har rigeligt med plads tilovers. På en 32GB-maskine skal du altid have 32GB+ ledig plads til dette volumen. Dvale kræver også standardbootloaderen Limine.

Når det er sat op, ser du dvaleindstillingen under _System_ (eller `Super + Esc`), og så kan du se, om det fungerer konsekvent på dit system. Hvis ikke, kan du fjerne den igen ved at køre `omarchy hibernation remove`.
