# Installation med dual boot

Du kan installere Omarchy på en enkelt partition ved siden af Windows eller andre installationer.

Denne installationsmetode leveres stadig med LUKS-kryptering af partitionen som standard, så den er reelt ikke anderledes end en installation på hele drevet og kræver blot, at der er ledig plads tilgængelig på disken.

## Gøre plads på Windows

For at installere ved siden af Windows skal du skrive `disk management` i startmenuen og vælge muligheden **Opret og formatér harddiskpartitioner**.

 ![dual-boot-1](images/dual-boot-1.webp)

Find den relevante partition, højreklik, og vælg **Formindsk diskenhed**.

![dual-boot-2](images/dual-boot-2.webp)

 Indtast det antal, du vil formindske diskenheden med. Bemærk, at dette bliver størrelsen på din fremtidige Omarchy-installation inklusive bootpartitionen.

 ![dual-boot-3](images/dual-boot-3.webp)

Når du er færdig, bør du se noget i denne stil, hvor sektionen på 50GB er der, hvor vi installerer Omarchy i dette eksempel.

 ![dual-boot-4](images/dual-boot-4.webp)

## Installation af Omarchy

Installationsprocessen for Omarchy er reelt den samme som normalt. Når du har valgt din disk, får du muligheden **Installation på ledig plads**. Vælg den mulighed for at undgå at slette hele disken.

 ![dual-boot-5](images/dual-boot-5.webp)

Bekræft, at alt ser godt ud, og vent på, at installationen afsluttes som normalt. Det er også her, du kan vælge at installere ukrypteret (anbefales ikke), ligesom ved en installation på hele drevet.
 ![dual-boot-6](images/dual-boot-6.webp)

## Tilføjelse af andre installationer til bootloaderen

Når du afslutter din Omarchy-installation, vil du bemærke, at Limine-bootloaderen nu er standard. Med den kan du også tilføje valg til Limine for dine andre installationer, f.eks. Windows.

For at tilføje andre operativsystemer skal du køre `limine-scan` og følge anvisningerne for at tilføje de poster, du ønsker, til din Limine-konfiguration. Bootmenuen forbliver som standard skjult og starter Omarchy efter ét sekund. For at vælge Windows eller en anden post skal du trykke på en vilkårlig tast, så snart Limine starter; når menuen vises, skal du bruge piletasterne til at vælge en post og trykke på Enter. Hvis Omarchy starter, før du når at trykke på en tast, skal du genstarte og prøve igen.

## Bitlocker

Det er vigtigt at bemærke, at denne installationsmetode ikke er kompatibel med Bitlocker, da den krypterer hele drevet, ikke kun partitionen. Hvis du får en fejl om, at Bitlocker er aktiveret, skal du starte Windows, gå til **Indstillinger -> Beskyttelse af personlige oplysninger og sikkerhed -> Enhedskryptering** og slå Bitlocker fra. Det kan tage noget tid at dekryptere drevet.

 ![dual-boot-7](images/dual-boot-7.webp)

## Geninstallation af Windows

Hvis denne computer blev leveret med Windows, er dens produktnøgle gemt i firmwaren. Kør `omarchy windows key` for at udskrive den, så du kan aktivere Windows igen, hvis du nogensinde geninstallerer det på denne maskine.
