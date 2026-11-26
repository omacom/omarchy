# Installasjon med dobbeltoppstart

Du kan installere Omarchy på en enkelt partisjon ved siden av Windows eller andre installasjoner.

Denne installasjonsmetoden leveres fortsatt med LUKS-kryptering for partisjonen som standard, så den er i praksis ikke forskjellig fra full disk og krever bare at det finnes ledig plass på disken.

## Lage plass på Windows

For å installere ved siden av Windows, skriv `disk management` i Start-menyen og velg alternativet for **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Finn riktig partisjon, høyreklikk, og velg **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Skriv inn hvor mye du vil krympe volumet med. Merk at dette blir størrelsen på den fremtidige Omarchy-installasjonen din, inkludert oppstartspartisjonen.

 ![dual-boot-3](images/dual-boot-3.webp)

Når du er ferdig, bør du se noe slikt som dette, der seksjonen på 50GB er der vi installerer Omarchy i dette eksemplet.

 ![dual-boot-4](images/dual-boot-4.webp)

## Installere Omarchy

Installasjonsprosessen for Omarchy er i praksis den samme som normalt. Etter at du velger disken din, får du alternativet **Free space install**. Velg det alternativet for å unngå å slette hele disken.

 ![dual-boot-5](images/dual-boot-5.webp)

Bekreft at alt ser bra ut, og vent til installasjonen er ferdig som normalt. Det er også her du kan velge å installere uten kryptering (ikke anbefalt), akkurat som ved en installasjon på full disk.
 ![dual-boot-6](images/dual-boot-6.webp)

## Legge til andre installasjoner i oppstartslasteren

Når du er ferdig med Omarchy-installasjonen, vil du merke at Limine-oppstartslasteren er standard nå. Med denne kan du også legge til alternativer i Limine for de andre installasjonene dine, for eksempel Windows.

For å legge til andre operativsystemer, kjør `limine-scan` og følg instruksjonene for å legge til oppføringene du vil ha, i Limine-konfigurasjonen din. Oppstartsmenyen forblir skjult som standard og starter Omarchy etter ett sekund. For å velge Windows eller en annen oppføring, trykk på en vilkårlig tast så snart Limine starter; når menyen vises, bruk piltastene til å velge en oppføring og trykk Enter. Hvis Omarchy starter før du rekker å trykke på en tast, start på nytt og prøv igjen.

## Bitlocker

Det er viktig å merke seg at denne installasjonsmetoden ikke er kompatibel med Bitlocker, siden den krypterer hele disken, ikke bare partisjonen. Hvis du får en feil som sier at Bitlocker er aktivert, start opp i Windows, gå til **Settings -> Privacy & Security -> Device encryption** og slå av Bitlocker. Det kan ta en stund å dekryptere disken.

 ![dual-boot-7](images/dual-boot-7.webp)

## Installere Windows på nytt

Hvis denne maskinen ble levert med Windows, er produktnøkkelen lagret i firmwaren. Kjør `omarchy windows key` for å skrive den ut, slik at du kan aktivere Windows på nytt hvis du noen gang installerer det på nytt på denne maskinen.
