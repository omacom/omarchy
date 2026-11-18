# Installation med dual boot

Du kan installere Omarchy på en enkelt partition ved siden af Windows eller andre installationer.

Denne installationsmetode leveres stadig med LUKS-kryptering af partitionen som standard, så den reelt ikke adskiller sig fra installation på hele drevet og blot kræver, at der er ledig plads tilgængelig på disken.

## Gør plads på Windows

For at installere ved siden af Windows skal du skrive `disk management` i startmenuen og vælge muligheden **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Find den relevante partition, højreklik, og vælg **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Indtast den mængde, du vil formindske drevet med. Bemærk, at dette bliver størrelsen på din fremtidige Omarchy-installation inklusive bootpartitionen.

 ![dual-boot-3](images/dual-boot-3.webp)

Når du er færdig, bør du se noget i retning af dette, hvor sektionen på 50GB er der, hvor vi installerer Omarchy i dette eksempel.

 ![dual-boot-4](images/dual-boot-4.webp)

## Installation af Omarchy

Installationsprocessen for Omarchy er reelt den samme som normalt. Når du har valgt din disk, får du muligheden **Free space install**. Vælg den mulighed for at undgå at slette hele disken.

 ![dual-boot-5](images/dual-boot-5.webp)

Bekræft, at alt ser godt ud, og vent på, at installationen bliver færdig som normalt. Det er også her, du kan vælge at installere ukrypteret (anbefales ikke), ligesom ved en installation på hele drevet.
 ![dual-boot-6](images/dual-boot-6.webp)

## Tilføjelse af andre installationer til bootloaderen

Når du er færdig med din Omarchy-installation, vil du bemærke, at Limine-bootloaderen nu er standard. Med den kan du også føje muligheder til Limine for dine andre installationer, såsom Windows.

For at tilføje andre operativsystemer skal du køre `limine-scan` og følge anvisningerne for at føje de ønskede poster til din Limine-konfiguration. Bootmenuen forbliver skjult som standard og starter Omarchy efter ét sekund. For at vælge Windows eller en anden post skal du trykke på en vilkårlig tast, så snart Limine starter; når menuen vises, skal du bruge piletasterne til at vælge en post og trykke på Enter. Hvis Omarchy starter, før du når at trykke på en tast, skal du genstarte og prøve igen. Hvis du har slået _Setup > Direct Boot_ til, springer firmwaren Limine helt over, så vælg Limine i din BIOS-bootmenu, eller kør _Setup > Direct Boot_ igen for at fjerne posten.

## Bitlocker

Det er vigtigt at bemærke, at denne installationsmetode ikke er kompatibel med Bitlocker, da den krypterer hele drevet og ikke kun partitionen. Hvis du støder på en fejl om, at Bitlocker er aktiveret, skal du starte Windows, gå til **Settings -> Privacy & Security -> Device encryption** og slå Bitlocker fra. Det kan tage noget tid at dekryptere drevet.

 ![dual-boot-7](images/dual-boot-7.webp)
