# Systemhvile

Omarchy aktiverer hvile og dvale som standard, men hvis du har problemer med noen av dem på maskinen din, kan du slå dem av.

### Strømprofiler

På en bærbar husker Omarchy strømprofilen din separat for tilkoblet strøm og batteridrift, og bytter mellom de to når du kobler til og fra. Rett ut av boksen betyr det ytelse på nettstrøm og balansert på batteri.

Du kan se hva maskinen din tilbyr med `omarchy powerprofiles list`, og sette den du vil ha for tilstanden du er i akkurat nå med `omarchy powerprofiles set autodetect power-saver`. For å sette den andre tilstanden uten å koble fra noe, navngi den direkte: `omarchy powerprofiles set battery power-saver`. Det du velger, er det du får tilbake neste gang du er i den tilstanden.

### Slå hvile av/på

Du slår hvile av/på ved å kjøre `omarchy toggle suspend` fra terminalen. Det viser/skjuler bare alternativet under _System_ (eller `Super + Esc`), og så kan du se om det fungerer konsekvent på systemet ditt. Hvis ikke, kan du skjule det igjen med samme kommando.

### Slå dvale av/på

Du setter opp dvale ved å kjøre `omarchy hibernation setup` fra terminalen. Dvale oppretter et /swap-undervolum på oppstartsdisken din på størrelse med den fysiske RAM-tildelingen din, så sørg for at du har rikelig med plass til overs. På en 32GB-maskin vil du alltid trenge 32GB+ ledig for dette volumet. Dvale krever også standard Limine-bootloaderen.

Når det er satt opp, vil du se dvalealternativet under _System_ (eller `Super + Esc`), og så kan du se om det fungerer konsekvent på systemet ditt. Hvis ikke, kan du fjerne det igjen ved å kjøre `omarchy hibernation remove`.
