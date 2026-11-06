# Maskinvareautentisering

### Fingeravtrykksautentisering

Mange bærbare datamaskiner leveres med en fingeravtrykkssensor for autentisering. Du kan bruke den med Omarchy ved å kjøre _Oppsett > Sikkerhet > Fingeravtrykk_ i Omarchy-menyen (`Super + Space`).

Det installerer fingeravtrykkspakken, registrerer avtrykket ditt, verifiserer det, og så er du klar til å bruke fingeravtrykket ditt til å låse opp fra låseskjermen (som du kan utløse med `Super + Ctrl + L`), gå inn i sudo-modus og godkjenne systemforespørsler.

Når låseskjermen har slått av skjermen, hviler sensoren for å spare strøm, så vekk skjermen med en hvilken som helst tast eller styreflaten før du berører den.

Når lokket på den bærbare datamaskinen er lukket, hoppes fingeravtrykksforespørselen automatisk over, så du går rett til passordforespørselen i stedet for å vente på en sensor du ikke når. Hvis du ellers må jobbe på et eksternt tastatur som ikke har en sensor, trykker du bare `CTRL + C` når du blir bedt om fingeravtrykket ditt under `sudo`.

Du kan fjerne fingeravtrykksautentiseringen under _Fjern > Sikkerhet > Fingeravtrykk_ i Omarchy-menyen.

### Fido2-autentisering

Hvis du bruker en Fido2-enhet, kan du sette den opp for `sudo`-autentisering ved å bruke _Oppsett > Sikkerhet > Fido2_ i Omarchy-menyen (`Super + Space`). Den dekker imidlertid `sudo` og forespørsler om systemautorisasjon, ikke opplåsing av datamaskinen din.

Du kan fjerne fido2-autentiseringen under _Fjern > Sikkerhet > Fido2_ i Omarchy-menyen.
