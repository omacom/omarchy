# Systemsøvn

Omarchy har suspension og dvale aktiveret som standard, men hvis du har problemer med en af delene på din maskine, kan du slå dem fra.

På NVIDIA GB10-maskiner, såsom DGX Spark og ASUS Ascent GX10, er suspension og dvale slået fra, ligesom i NVIDIA's DGX OS, fordi søvn endnu ikke har vist sig at virke på den hardware. Det samme gælder for ASUS Zenbook A16 (UX3607OA), hvor suspension endnu ikke får chippen til at sove helt og kan hænge natten over. Kontakten til suspension og opsætningen af dvale gælder ikke dér. For at slå søvn til igen skal du fjerne `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` med `sudo rm`; Suspension vender derefter tilbage til menuen, og dvale kan sættes op som på andre maskiner. Hvis du kører `sudo omarchy apply hardware --install-user "$USER"`, kommer filen tilbage.

### Strømprofiler

På en bærbar husker Omarchy din strømprofil separat for tilsluttet strøm og batteridrift og skifter mellem de to, når du sætter strømmen til og tager den fra. Som standard betyder det performance på AC og balanced på batteri.

Du kan se, hvad din maskine tilbyder, med `omarchy powerprofiles list`, og indstille den, du vil have til den tilstand, du er i lige nu, med `omarchy powerprofiles set autodetect power-saver`. Hvis du vil indstille den anden tilstand uden at tage strømmen fra, skal du nævne den direkte: `omarchy powerprofiles set battery power-saver`. Uanset hvad du vælger, er det det, du får tilbage, næste gang du er i den tilstand.

### Slå suspension til/fra

Du slår suspension til/fra ved at køre `omarchy toggle suspend` fra terminalen. Det viser/skjuler bare valgmuligheden under _System_ (eller `Super + Esc`), og så kan du se, om det virker stabilt på dit system. Hvis ikke, kan du skjule den igen med den samme kommando.

### Slå dvale til/fra

Du sætter dvale op ved at køre `omarchy hibernation setup` fra terminalen. Dvale opretter et /swap-undervolumen på dit bootdrev på størrelse med din fysiske RAM-allokering, så sørg for, at du har rigeligt med plads til overs. På en 32GB-maskine skal du altid have 32GB+ fri til dette volumen. Dvale kræver også standard-Limine-bootloaderen.

Når det er sat op, ser du dvale-valgmuligheden under _System_ (eller `Super + Esc`), og så kan du se, om det virker stabilt på dit system. Hvis ikke, kan du fjerne den igen ved at køre `omarchy hibernation remove`.
