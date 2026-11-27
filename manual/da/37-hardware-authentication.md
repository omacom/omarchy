# Hardwaregodkendelse

### Godkendelse med fingeraftryk

Mange bærbare computere har en fingeraftrykssensor til godkendelse. Du kan bruge den med Omarchy ved at køre _Opsætning > Sikkerhed > Fingeraftryk_ i Omarchy-menuen (`Super + Space`).

Det åbner et fingeraftryk i fuld skærm, som fyldes ud, mens du rører ved sensoren. Bag kulisserne installerer Omarchy fingeraftrykspakken, registrerer dit aftryk, bekræfter det, og så er du klar til at bruge dit fingeraftryk til at låse op fra låseskærmen (som du kan aktivere med `Super + Ctrl + L`), aktivere sudo og godkende systemanmodninger.

Når låseskærmen har slukket for skærmen, går sensoren i hvile for at spare strøm, så væk skærmen med en vilkårlig tast eller touchpadden, før du rører ved den.

Når låget på din bærbare computer er lukket, springes fingeraftryksanmodningen automatisk over, så du går direkte til adgangskodeanmodningen i stedet for at vente på en sensor, du ikke kan nå. Hvis du ellers har brug for at arbejde på et eksternt tastatur, der ikke har en sensor, skal du blot trykke på `CTRL + C`, når du bliver bedt om dit fingeraftryk under `sudo`.

Du kan fjerne fingeraftryksgodkendelsen under _Fjern > Sikkerhed > Fingeraftryk_ i Omarchy-menuen.

### Fido2-godkendelse

Hvis du bruger en Fido2-enhed, kan du konfigurere den til `sudo`-godkendelse ved hjælp af _Opsætning > Sikkerhed > Fido2_ i Omarchy-menuen (`Super + Space`). Den dækker dog `sudo` og systemgodkendelsesanmodninger, ikke oplåsning af din computer.

Du kan fjerne Fido2-godkendelsen under _Fjern > Sikkerhed > Fido2_ i Omarchy-menuen.
