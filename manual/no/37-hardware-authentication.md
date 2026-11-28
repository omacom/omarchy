# Autentisering med maskinvare

### Autentisering med fingeravtrykk

Mange bærbare PC-er leveres med en fingeravtrykkssensor for autentisering. Du kan bruke den med Omarchy ved å kjøre _Oppsett > Sikkerhet > Fingeravtrykk_ i Omarchy-menyen (`Super + Space`).

Det åpner et fingeravtrykk i fullskjerm som fylles ut etter hvert som du berører sensoren. I bakgrunnen installerer Omarchy fingeravtrykkspakken, registrerer avtrykket ditt, verifiserer det, og så er du klar til å bruke fingeravtrykket ditt til å låse opp fra låseskjermen (som du kan åpne med `Super + Ctrl + L`), aktivere sudo-modus og godkjenne systemforespørsler.

Når låseskjermen har slått av skjermen, hviler sensoren for å spare strøm, så vekk skjermen med en hvilken som helst tast eller pekeplaten før du berører den.

Når lokket på den bærbare PC-en er lukket, hoppes forespørselen om fingeravtrykk automatisk over, slik at du går rett til forespørselen om passord i stedet for å vente på en sensor du ikke kan nå. Hvis du ellers må jobbe på et eksternt tastatur uten sensor, trykker du bare på `CTRL + C` når du blir bedt om fingeravtrykk under `sudo`.

Du kan fjerne autentisering med fingeravtrykk under _Fjern > Sikkerhet > Fingeravtrykk_ i Omarchy-menyen.

### Fido2-autentisering

Hvis du bruker en Fido2-enhet, kan du konfigurere den for `sudo`-autentisering ved å bruke _Oppsett > Sikkerhet > Fido2_ i Omarchy-menyen (`Super + Space`). Den dekker imidlertid `sudo` og forespørsler om systemautorisering, ikke opplåsing av datamaskinen.

Du kan fjerne fido2-autentisering under _Fjern > Sikkerhet > Fido2_ i Omarchy-menyen.
