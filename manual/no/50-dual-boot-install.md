# Installasjon med dobbeltoppstart

Du kan installere Omarchy på én enkelt partisjon ved siden av Windows eller andre installasjoner.

Denne installasjonsmetoden leveres fortsatt med LUKS-kryptering for partisjonen som standard, så den er i praksis ikke forskjellig fra full disk og krever ganske enkelt ledig plass tilgjengelig på disken.

## Frigjøre plass i Windows

For å installere ved siden av Windows skriver du `disk management` i startmenyen og velger alternativet **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Finn den aktuelle partisjonen, høyreklikk, og velg **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Skriv inn hvor mye du vil krympe volumet med. Merk at dette blir størrelsen på den fremtidige Omarchy-installasjonen din, inkludert oppstartspartisjonen.

 ![dual-boot-3](images/dual-boot-3.webp)

Når du er ferdig, bør du se noe slikt som dette, der den 50GB-seksjonen er der vi installerer Omarchy i dette eksemplet.

 ![dual-boot-4](images/dual-boot-4.webp)

## Installere Omarchy

Installasjonsprosessen for Omarchy er i praksis den samme som normalt. Etter at du har valgt disk, får du alternativet **Free space install**. Velg det alternativet for å unngå å slette hele disken.

 ![dual-boot-5](images/dual-boot-5.webp)

Bekreft at alt ser bra ut, og vent til installasjonen er ferdig som normalt. Det er også her du kan velge å installere ukryptert (ikke anbefalt), akkurat som ved en installasjon på full disk.
 ![dual-boot-6](images/dual-boot-6.webp)

## Legge andre installasjoner til i oppstartslasteren

Når du er ferdig med Omarchy-installasjonen, vil du merke at Limine-oppstartslasteren er standard nå. Med denne kan du også legge til alternativer i Limine for de andre installasjonene dine, for eksempel Windows.

For å legge til andre operativsystemer kjører du `limine-scan` og følger instruksjonene for å legge til oppføringene du vil ha i Limine-konfigurasjonen din. Oppstartsmenyen er skjult som standard og starter Omarchy etter ett sekund. For å velge Windows eller en annen oppføring trykker du på en vilkårlig tast så snart Limine starter; når menyen vises, bruker du piltastene til å velge en oppføring og trykker på Enter. Hvis Omarchy starter før du rekker å trykke på en tast, starter du på nytt og prøver igjen. Hvis du har slått på _Setup > Direct Boot_, hopper fastvaren over Limine helt, så velg Limine fra BIOS-oppstartsmenyen din eller kjør _Setup > Direct Boot_ igjen for å fjerne oppføringen.

## Bitlocker

Det er viktig å merke seg at denne installasjonsmetoden ikke er kompatibel med Bitlocker, ettersom den krypterer hele disken, ikke bare partisjonen. Hvis du får en feilmelding om at Bitlocker er aktivert, starter du opp i Windows, går til **Settings -> Privacy & Security -> Device encryption** og slår Bitlocker av. Det kan ta litt tid å dekryptere disken.

 ![dual-boot-7](images/dual-boot-7.webp)
