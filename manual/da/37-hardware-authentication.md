# Hardwaregodkendelse

### Fingeraftryksgodkendelse

Mange bærbare computere leveres med en fingeraftrykssensor til godkendelse. Du kan bruge den med Omarchy ved at køre _Opsætning > Sikkerhed > Fingeraftryk_ i Omarchy-menuen (`Super + Space`).

Det installerer fingeraftrykspakken, indlæser dit aftryk, verificerer det, og så er du klar til at bruge dit fingeraftryk til at låse op fra låseskærmen (som du kan aktivere med `Super + Ctrl + L`), komme i sudo-tilstand og godkende systemprompter.

Når låseskærmen har slukket skærmen, hviler sensoren for at spare strøm, så væk skærmen med en hvilken som helst tast eller touchpad'en, før du rører ved den.

Når låget på din bærbare er lukket, bliver fingeraftryksprompten automatisk sprunget over, så du går direkte til adgangskodeprompten i stedet for at vente på en sensor, du ikke kan nå. Hvis du ellers skal arbejde på et eksternt tastatur, som ikke har en sensor, skal du bare trykke på `CTRL + C`, når du bliver bedt om dit fingeraftryk under `sudo`.

Du kan fjerne fingeraftryksgodkendelsen under _Fjern > Sikkerhed > Fingeraftryk_ i Omarchy-menuen.

### Fido2-godkendelse

Hvis du bruger en Fido2-enhed, kan du sætte den op til `sudo`-godkendelse ved hjælp af _Opsætning > Sikkerhed > Fido2_ i Omarchy-menuen (`Super + Space`). Den dækker dog `sudo` og systemgodkendelsesprompter, ikke oplåsningen af din computer.

Du kan fjerne fido2-godkendelsen under _Fjern > Sikkerhed > Fido2_ i Omarchy-menuen.
