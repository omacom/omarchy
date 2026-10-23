# Dual Boot Installation

Du er i stand til at installere Omarchy på en enkelt partition ved siden af Windows eller andre installationer.

Denne installationsmetode leveres stadig med LUKS-kryptering til partitionen som standard, så den er effektivt ikke anderledes end fuldt drev og kræver blot, at fri plads er tilgængelig på disken.

## Gør plads på Windows

For at installere ved siden af Windows skal du skrive `disk management` i startmenuen og vælge muligheden for **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Find den passende partition, højreklik, og vælg **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Indtast den mængde, du gerne vil skrumpe volumenet med. Bemærk, at dette vil være størrelsen på din fremtidige Omarchy-installation inklusive bootpartitionen.

 ![dual-boot-3](images/dual-boot-3.webp)

Når du er færdig, bør du se noget som dette, hvor 50GB-sektionen er, hvor vi installerer Omarchy i dette eksempel.

 ![dual-boot-4](images/dual-boot-4.webp)

## Installer Omarchy

Installationsprocessen for Omarchy er effektivt den samme som normalt. Når du har valgt din disk, får du muligheden for **Free space install**. Vælg den mulighed for at forhindre sletning af hele disken.

 ![dual-boot-5](images/dual-boot-5.webp)

Bekræft, at alt ser godt ud, og vent på, at installationen fuldfører som normalt. Dette er også, hvor du kunne vælge at installere ukrypteret (ikke anbefalet), ligesom på en fuld-drev-installation.
 ![dual-boot-6](images/dual-boot-6.webp)

## Tilføj andre installationer til bootloaderen

Når du fuldfører din Omarchy-installation, vil du bemærke, at Limine-bootloaderen er standarden nu. Med denne kan du også tilføje muligheder til Limine for dine andre installationer såsom Windows.

For at gøre det skal du køre `limine-scan` og følge prompterne for at tilføje de elementer, du gerne vil have, til din limine-konfiguration. Når du derefter booter, vil du se dine normale muligheder for Omarchy såvel som Windows Boot Manager eller andre.

## Bitlocker

Det er vigtigt at bemærke, at denne installationsmetode ikke er kompatibel med Bitlocker, da den krypterer hele drevet, ikke kun partitionen. Hvis du støder på en fejl, der angiver, at Bitlocker er aktiveret, så boot til Windows, gå til **Settings -> Privacy & Security -> Device encryption** og slå Bitlocker fra. Det kan tage noget tid at dekryptere drevet.

 ![dual-boot-7](images/dual-boot-7.webp)
