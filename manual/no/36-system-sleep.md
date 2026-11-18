# Systemdvale

Omarchy aktiverer hvilemodus og dvalemodus som standard, men hvis du har problemer med en av dem på maskinen din, kan du slå dem av.

På NVIDIA GB10-maskiner, som DGX Spark og ASUS Ascent GX10, er hvilemodus og dvalemodus slått av, slik de også er i NVIDIA DGX OS, fordi hvilemodus ennå ikke har vist seg å fungere på den maskinvaren. Det samme gjelder ASUS Zenbook A16 (UX3607OA), der hvilemodus ennå ikke får brikken til å sove helt og kan henge over natten. Vekslingen for hvilemodus og oppsettet for dvalemodus gjelder ikke der. For å slå hvilemodus på igjen, fjern `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` med `sudo rm`; Hvilemodus kommer da tilbake i menyen, og dvalemodus kan settes opp som på andre maskiner. Å kjøre `sudo omarchy apply hardware --install-user "$USER"` legger filen tilbake.

### Strømprofiler

På en bærbar PC husker Omarchy strømprofilen din separat for når den er koblet til strøm og når den går på batteri, og bytter mellom de to når du kobler til og fra. Rett ut av boksen betyr det ytelse på nettstrøm og balansert på batteri.

Du kan se hva maskinen din tilbyr med `omarchy powerprofiles list`, og angi den du vil ha for tilstanden du er i akkurat nå med `omarchy powerprofiles set autodetect power-saver`. For å angi den andre tilstanden uten å koble fra noe, nevner du den direkte: `omarchy powerprofiles set battery power-saver`. Uansett hva du velger, er det det du får igjen neste gang du er i den tilstanden.

### Slå hvilemodus av og på

Du slår hvilemodus av og på ved å kjøre `omarchy toggle suspend` fra terminalen. Det viser/skjuler bare alternativet under _System_ (eller `Super + Esc`), og så kan du se om det fungerer stabilt på systemet ditt. Hvis ikke, kan du skjule det igjen med samme kommando.

### Slå dvalemodus av og på

Du setter opp dvalemodus ved å kjøre `omarchy hibernation setup` fra terminalen. Dvalemodus oppretter et /swap-undervolum på oppstartsdisken din med samme størrelse som den fysiske RAM-tildelingen din, så sørg for at du har god plass til overs. På en maskin med 32GB trenger du alltid 32GB+ ledig til dette volumet. Dvalemodus krever også standardoppstartslasteren Limine.

Når det er satt opp, ser du alternativet for dvalemodus under _System_ (eller `Super + Esc`), og så kan du se om det fungerer stabilt på systemet ditt. Hvis ikke, kan du fjerne det igjen ved å kjøre `omarchy hibernation remove`.
