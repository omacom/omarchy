# Kom godt i gang

Omarchy installeres ved hjælp af en ISO. Du kan vælge mellem en installation på hele disken, som overtager hele drevet, eller en installation i ledig plads, som lægger Omarchy i den ikke-allokerede plads på et drev — det er sådan, du dual booter sammen med Windows eller et andet OS (se [installation med dual boot](50-dual-boot-install.md) — bemærk, at du først skal slå BitLocker fra i Windows). Uanset hvad er installationen som standard med fuld kryptering, og muligheden med hele disken sletter det valgte drev, så sørg for at tage en backup, før du bruger et eksisterende!

[Download Omarchy ISO'en](https://omarchy.org/) først, læg den på en USB-nøgle (brug [Rufus](https://rufus.ie/) på Windows, [balenaEtcher](https://etcher.balena.io/) på Mac eller [caligula](https://github.com/ifd3f/caligula) på Linux), og boot fra nøglen.

_Du skal slå Secure Boot og/eller TPM fra i BIOS'en. Du er nødt til at slå dem fra for at kunne installere Omarchy. De er Microsofts sikkerhedsordninger beregnet til Windows og Microsoft-tilknyttede Linux-distributioner._

Besvar derefter konfigurationsspørgsmålene, og bekræft dem sådan her:

 ![install-config](images/install-config.webp)

Vælg derefter et drev til din installation, og læn dig tilbage og se installationen køre. Det kan være gjort på under et minut på de hurtigste moderne maskiner, men det bør ikke tage mere end 5 minutter, selv på en ældre computer.

 ![install-done](images/install-done.webp)

Nu er du klar til Omarchy!

### Brug et kablet eller 2.4ghz-tastatur!

Krypteringen af hele disken tillader ikke, at du indtaster adgangskoden fra et Bluetooth-tastatur ved opstart. Ligesom du ikke kan bruge et Bluetooth-tastatur til at komme ind i BIOS'en på en PC. Du skal bruge et tastatur, der enten bruger en 2.4ghz-dongle eller et kabel (hvilket alligevel er meget rarere med hensyn til forsinkelse!). Jeg elsker personligt [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Installation til en anden ejer

Hvis du sætter en maskine op til en anden — et familiemedlem, en ny medarbejder, en køber — bør du ikke besvare de personlige spørgsmål på deres vegne. Tryk på `Ctrl + C` på installatørens allerførste skærm (tastaturvalget), så tilbyder Omarchy i stedet at klargøre maskinen til en anden ejer. Systemet installeres med det samme, men al den personlige opsætning — tastaturlayout, brugernavn, adgangskode — udskydes, til maskinen booter første gang. Drevet er stadig krypteret som standard, og den adgangskode, den nye ejer vælger ved den første boot, bliver også krypteringsadgangskoden. (En maskine, du allerede har brugt, kan også overdrages uden en geninstallation — se [nulstilling af computeren](48-security.md).)

### Uovervågede installationer

ISO'en kan også installere helt på egen hånd — uden tastatur, uden guide — når den får sin konfiguration på et andet drev. Det er måden at behandle Omarchy som et basisimage til VM'er og maskinparker på. Se [uovervågede installationer](51-unattended-installs.md).

### Installationer uden kryptering

Omarchy installeres med kryptering som standard. Det er det sikre, ansvarlige valg til enhver computer, der overhovedet kan mistes eller blive stjålet. Du vil ikke have, at nogen med adgang til din hardware skal kunne få fat i dine data!

Men under særlige omstændigheder, som ved fjerninstallationer af Omarchy på beskyttede computere eller til installationer, der kan kasseres, uden følsomme data, vil du måske installere uden kryptering. Du kan trykke på `Ctrl + C` ved bekræftelsen af diskformateringen for at skifte til en installation uden kryptering.

### Sprog

Omarchy taler 50 sprog — samme udvalg som omarchy.org — og engelsk er standarden. For at skifte skal du åbne Omarchy-menuen og gå til _Opsætning > Region > Sprog_ eller køre `omarchy language <code>` i en terminal (`omarchy language list` viser koderne). Menuen, skrivebordet og Omarchys egne notifikationer skifter sprog med det samme, og alle programmer, du åbner bagefter, følger også med. Programmer, der allerede var åbne, skifter, når du genstarter dem.

Hvis du vil beholde sproget, men skrive datoer, klokkeslæt, tal, penge, enheder og papirstørrelser, som en anden region gør (engelsk med europæiske datoer og 24-timers ur, for eksempel), skal du vælge en region under _Opsætning > Region > Formater_, hvor hvert valg viser et eksempel, eller køre `omarchy region formats <code>` (`omarchy region formats list` viser koderne). _Samme som sprog_ går tilbage til sprogets egne formater. Ligesom et sprogskift gælder det de programmer, du åbner bagefter.

### Hjælp, hvis du sidder fast

Hvis du sidder fast, kan du som regel finde nogen, der vil hjælpe, i kanalen _#omarchy-help_ på [fællesskabets Discord](https://omarchy.org/discord).
