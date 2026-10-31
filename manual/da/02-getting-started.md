# Kom godt i gang

Omarchy installeres ved hjælp af en ISO. Du kan vælge mellem en installation på hele disken, som overtager hele drevet, eller en installation på ledig plads, som lægger Omarchy på den ikke-allokerede plads på et drev — det er sådan, du dual boot'er ved siden af Windows eller et andet OS (se [installation med dual boot](50-dual-boot-install.md) — bemærk, at du først skal slå BitLocker fra i Windows). Uanset hvad er installationen som standard med fuld kryptering, og muligheden med hele disken sletter det valgte drev, så sørg for at tage en backup, før du bruger et eksisterende drev!

[Download Omarchy-ISO'en](https://omarchy.org/) først, læg den på en USB-stick (brug [balenaEtcher](https://etcher.balena.io/) på Mac/Windows eller [caligula](https://github.com/ifd3f/caligula) på Linux), og boot fra sticken.

_Du skal slå Secure Boot og/eller TPM fra i BIOS'en. Du er nødt til at slå dem fra for at kunne installere Omarchy. De er Microsoft-sikkerhedsordninger beregnet til Windows og Microsoft-tilknyttede Linux-distributioner._

Besvar derefter konfigurationsspørgsmålene, og bekræft dem sådan her:

 ![install-config](images/install-config.webp)

Vælg derefter et drev til din installation, og læn dig tilbage og se installationsshowet køre. Det kan klares på under et minut på de hurtigste moderne maskiner, men det bør ikke tage mere end 5 minutter selv på en ældre computer.

 ![install-done](images/install-done.webp)

Nu er du klar til Omarchy!

### Brug et kablet eller 2.4ghz-tastatur!

Med fuld diskkryptering kan du ikke indtaste adgangskoden fra et Bluetooth-tastatur ved opstart. Ligesom du ikke kan bruge et Bluetooth-tastatur til at gå ind i BIOS'en på en PC. Du skal bruge et tastatur, der enten bruger en 2.4ghz-dongle eller et kabel (hvilket alligevel er meget bedre for latency!). Jeg elsker personligt [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Installation til en anden ejer

Hvis du sætter en maskine op til en anden — et familiemedlem, en ny medarbejder, en køber — bør du ikke besvare de personlige spørgsmål på deres vegne. Tryk på `Ctrl + C` på installatørens allerførste skærm (valg af tastatur), så tilbyder Omarchy i stedet at forberede maskinen til en anden ejer. Systemet installeres med det samme, men al den personlige opsætning — tastaturlayout, brugernavn, adgangskode — udskydes, indtil maskinen booter for første gang. Drevet er stadig krypteret som standard, og den adgangskode, den nye ejer vælger ved den første boot, bliver også krypteringsadgangskoden. (En maskine, du allerede har brugt, kan også overdrages uden geninstallation — se [nulstilling af computeren](48-security.md).)

### Uovervågede installationer

ISO'en kan også installere helt på egen hånd — intet tastatur, ingen guide — når den får sin konfiguration på et andet drev. Det er måden at behandle Omarchy som et basisimage til VM'er og flådemaskiner på. Se [uovervågede installationer](51-unattended-installs.md).

### Installationer uden kryptering

Omarchy installeres med kryptering som standard. Det er det sikre, ansvarlige valg for enhver computer, der overhovedet kan blive væk eller stjålet. Du vil ikke have, at nogen med adgang til din hardware skal kunne få fat i dine data!

Men under særlige omstændigheder, som fjerne Omarchy-installationer på beskyttede computere eller til engangsinstallationer uden følsomme data, vil du måske installere uden kryptering. Du kan trykke på `Ctrl + C` ved bekræftelsen af diskformatering for at skifte til en installation uden kryptering.

### Sprog

Omarchy taler 50 sprog — det samme sæt som omarchy.org — og engelsk er standarden. For at skifte skal du åbne Omarchy-menuen og gå til _Setup > Language_ eller køre `omarchy language <code>` i en terminal (`omarchy language list` viser koderne). Menuen, skrivebordet og Omarchys egne notifikationer skifter sprog med det samme, og alle programmer, du åbner bagefter, følger også med. Programmer, der allerede var åbne, skifter, når du genstarter dem.

### Hjælp, hvis du sidder fast

Hvis du sidder fast, kan du som regel finde nogen, der er villig til at hjælpe, i kanalen _#omarchy-help_ på [fællesskabets Discord](https://omarchy.org/discord).
