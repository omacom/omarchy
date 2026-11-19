# Installasjon med dobbeltoppstart

Du kan installere Omarchy på én enkelt partisjon ved siden av Windows eller andre installasjoner.

Denne installasjonsmetoden leveres fortsatt med LUKS-kryptering for partisjonen som standard, så den er i praksis ikke annerledes enn for hele disken og krever bare at ledig plass er tilgjengelig på disken.

## Frigjøre plass på Windows

For å installere ved siden av Windows skriver du `disk management` i startmenyen og velger alternativet **Opprett og formater harddiskpartisjoner**.

 ![dual-boot-1](images/dual-boot-1.webp)

Finn riktig partisjon, høyreklikk, og velg **Forminsk volum**.

![dual-boot-2](images/dual-boot-2.webp)

 Skriv inn hvor mye du vil forminske volumet med. Merk at dette vil være størrelsen på den fremtidige Omarchy-installasjonen din, inkludert oppstartspartisjonen.

 ![dual-boot-3](images/dual-boot-3.webp)

Når du er ferdig, bør du se noe som ligner på dette, der 50GB-delen er der vi installerer Omarchy i dette eksempelet.

 ![dual-boot-4](images/dual-boot-4.webp)

## Installere Omarchy

Installasjonsprosessen for Omarchy er i praksis den samme som normalt. Etter at du har valgt disken din, får du alternativet **Installasjon på ledig plass**. Velg det alternativet for å unngå å slette hele disken.

 ![dual-boot-5](images/dual-boot-5.webp)

Bekreft at alt ser bra ut, og vent til installasjonen er ferdig som normalt. Det er også her du kan velge å installere ukryptert (ikke anbefalt), akkurat som ved installasjon på hele disken.
 ![dual-boot-6](images/dual-boot-6.webp)

## Legge til andre installasjoner i oppstartslasteren

Når du er ferdig med Omarchy-installasjonen, vil du merke at Limine-oppstartslasteren nå er standard. Med den kan du også legge til alternativer i Limine for de andre installasjonene dine, for eksempel Windows.

For å legge til andre operativsystemer kjører du `limine-scan` og følger instruksjonene for å legge til oppføringene du vil ha, i Limine-konfigurasjonen din. Oppstartsmenyen holdes skjult som standard og starter Omarchy etter ett sekund. For å velge Windows eller en annen oppføring trykker du på en hvilken som helst tast så snart Limine starter; når menyen vises, bruker du piltastene til å velge en oppføring og trykker på Enter. Hvis Omarchy starter før du rekker å trykke på en tast, starter du på nytt og prøver igjen.

## Bitlocker

Det er viktig å merke seg at denne installasjonsmetoden ikke er kompatibel med Bitlocker, ettersom den krypterer hele disken, ikke bare partisjonen. Hvis du får en feilmelding om at Bitlocker er aktivert, starter du Windows, går til **Innstillinger -> Personvern og sikkerhet -> Enhetskryptering** og slår Bitlocker av. Det kan ta litt tid å dekryptere disken.

 ![dual-boot-7](images/dual-boot-7.webp)
