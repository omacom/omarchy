# Dual Boot-installasjon

Du kan installere Omarchy på en enkelt partisjon ved siden av Windows eller andre installasjoner.

Denne installasjonsmetoden kommer fortsatt med LUKS-kryptering for partisjonen som standard, så den er i praksis ikke forskjellig fra full disk og krever ganske enkelt at ledig plass er tilgjengelig på disken.

## Lage plass på Windows

For å installere ved siden av Windows, skriv `disk management` i startmenyen og velg alternativet for **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Finn den aktuelle partisjonen, høyreklikk og velg **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Skriv inn mengden du vil krympe volumet med. Merk at dette vil være størrelsen på den fremtidige Omarchy-installasjonen din inkludert oppstartspartisjonen.

 ![dual-boot-3](images/dual-boot-3.webp)

Når du er ferdig, bør du se noe sånt som dette der 50GB-delen er der vi installerer Omarchy i dette eksemplet.

 ![dual-boot-4](images/dual-boot-4.webp)

## Installere Omarchy

Installasjonsprosessen for Omarchy er i praksis den samme som normalt. Etter at du velger disken din, får du alternativet **Free space install**. Velg det alternativet for å forhindre at hele disken slettes.

 ![dual-boot-5](images/dual-boot-5.webp)

Bekreft at alt ser bra ut og vent til installasjonen er ferdig som normalt. Det er også her du kan velge å installere ukryptert (anbefales ikke) akkurat som på en fulldisk-installasjon.
 ![dual-boot-6](images/dual-boot-6.webp)

## Legge til andre installasjoner i bootloaderen

Når du er ferdig med Omarchy-installasjonen, vil du merke at Limine-bootloaderen er standarden nå. Med denne kan du også legge til alternativer i Limine for de andre installasjonene dine, som Windows.

For å gjøre det, kjør `limine-scan` og følg instruksjonene for å legge til de elementene du vil i limine-konfigurasjonen din. Når du så starter opp, vil du se de vanlige alternativene dine for Omarchy, i tillegg til Windows Boot Manager eller andre.

## Bitlocker

Det er viktig å merke seg at denne installasjonsmetoden ikke er kompatibel med Bitlocker, siden den krypterer hele disken, ikke bare partisjonen. Hvis du støter på en feil som sier at Bitlocker er aktivert, start opp i Windows, gå til **Settings -> Privacy & Security -> Device encryption** og slå Bitlocker av. Det kan ta litt tid å dekryptere disken.

 ![dual-boot-7](images/dual-boot-7.webp)
