# Hvilemodus for systemet

Omarchy aktiverer hvilemodus som standard, og dvalemodus når den er satt opp, men hvis du har problemer med en av dem på maskinen din, kan du slå dem av.

På NVIDIA GB10-maskiner, for eksempel DGX Spark og ASUS Ascent GX10, er hvilemodus og dvalemodus slått av, slik de er det i NVIDIA DGX OS, fordi hvile ennå ikke har vist seg å fungere på den maskinvaren. Det samme gjelder ASUS Zenbook A16 (UX3607OA), der hvilemodus ennå ikke setter brikken helt i hvile og kan henge over natten. Bryteren for hvilemodus og oppsettet for dvalemodus gjelder ikke der. For å slå hvile på igjen fjerner du `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` med `sudo rm`; da kommer hvilemodus tilbake i menyen, og dvalemodus kan settes opp som på andre maskiner. Å kjøre `sudo omarchy apply hardware --install-user "$USER"` legger filen tilbake.

### Strømprofiler

På en bærbar PC husker Omarchy strømprofilen din separat for tilkoblet strøm og batteridrift, og bytter mellom de to når du kobler til og fra. Rett ut av esken betyr det ytelse på AC og balansert på batteri.

Du kan se hva maskinen din tilbyr, med `omarchy powerprofiles list`, og angi den du vil ha for tilstanden du er i nå, med `omarchy powerprofiles set autodetect power-saver`. For å angi den andre tilstanden uten å koble fra noe navngir du den direkte: `omarchy powerprofiles set battery power-saver`. Det du velger, er det du får tilbake neste gang du er i den tilstanden.

### Slå hvilemodus av og på

Du slår hvilemodus av og på ved å kjøre `omarchy toggle suspend` fra terminalen. Det bare viser/skjuler valget under _System_ (eller `Super + Esc`), og så kan du se om det fungerer konsekvent på systemet ditt. Hvis ikke, kan du skjule det igjen med samme kommando.

### Slå dvalemodus av og på

Du setter opp dvalemodus ved å kjøre `omarchy hibernation setup` fra terminalen (den er ikke tilgjengelig på Apple Silicon-Macer). Dvalemodus oppretter et /swap-undervolum på oppstartsstasjonen din på størrelse med den fysiske RAM-tildelingen din, så sørg for at du har rikelig med plass til overs. På en 32GB-maskin vil du alltid trenge 32GB+ ledig til dette volumet. Dvalemodus krever også standardoppstartslasteren Limine.

Når den er satt opp, ser du dvale valget under _System_ (eller `Super + Esc`), og så kan du se om det fungerer konsekvent på systemet ditt. Hvis ikke, kan du fjerne det igjen ved å kjøre `omarchy hibernation remove`.
