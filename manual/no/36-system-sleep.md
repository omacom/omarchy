# Systemsøvn

Omarchy aktiverer hvilemodus som standard, og dvalemodus når den er satt opp, men hvis du har problemer med noen av dem på maskinen din, kan du slå dem av.

På NVIDIA GB10-maskiner, som DGX Spark og ASUS Ascent GX10, er hvilemodus og dvalemodus slått av, slik de er i NVIDIAs DGX OS, fordi søvn ennå ikke har vist seg å fungere på den maskinvaren. Bryteren for hvilemodus og oppsettet for dvalemodus gjelder ikke der. For å slå søvn på igjen fjerner du `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` med `sudo rm`; Hvilemodus kommer da tilbake til menyen, og dvalemodus kan settes opp som på andre maskiner. Å kjøre `sudo omarchy apply hardware --install-user "$USER"` legger filen tilbake.

### Strømprofiler

På en bærbar PC husker Omarchy strømprofilen din separat for når den er koblet til strøm og når den går på batteri, og bytter mellom de to når du kobler til og fra. Rett ut av boksen betyr det ytelse på AC og balansert på batteri.

Du kan se hva maskinen din tilbyr med `omarchy powerprofiles list`, og angi den du vil ha for tilstanden du er i akkurat nå med `omarchy powerprofiles set autodetect power-saver`. For å angi den andre tilstanden uten å koble fra noe, navngir du den direkte: `omarchy powerprofiles set battery power-saver`. Uansett hva du velger, er det det du får tilbake neste gang du er i den tilstanden.

### Slå hvilemodus av og på

Du slår hvilemodus av og på ved å kjøre `omarchy toggle suspend` fra terminalen. Det viser/skjuler bare alternativet under _System_ (eller `Super + Esc`), og så kan du se om det fungerer konsekvent på systemet ditt. Hvis ikke, kan du skjule det igjen med samme kommando.

### Slå dvalemodus av og på

Du setter opp dvalemodus ved å kjøre `omarchy hibernation setup` fra terminalen (den er ikke tilgjengelig på Apple Silicon-Macer). Dvalemodus oppretter et /swap-undervolum på oppstartsstasjonen din med størrelsen på den fysiske RAM-tildelingen din, så sørg for at du har rikelig med plass til overs. På en 32GB-maskin trenger du alltid 32GB+ ledig til dette volumet. Dvalemodus krever også standard Limine-oppstartslasteren.

Når den er satt opp, ser du dvalealternativet under _System_ (eller `Super + Esc`), og så kan du se om det fungerer konsekvent på systemet ditt. Hvis ikke, kan du fjerne det igjen ved å kjøre `omarchy hibernation remove`.
