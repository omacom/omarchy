# Kom godt i gang

Omarchy installeres med en ISO. Du kan vælge mellem en installation på hele disken, som overtager hele drevet, eller en installation på ledig plads, som lægger Omarchy på den ikke-allokerede plads på et drev — det er sådan, du dual boot'er ved siden af Windows eller et andet OS (se [dual-boot-installation](50-dual-boot-install.md) — bemærk, at du først skal slå BitLocker fra i Windows). Uanset hvad er fuld kryptering standard under installationen, og valget med hele disken vil slette det valgte drev, så sørg for at tage en backup, før du bruger et eksisterende drev!

[Hent Omarchy ISO'en](https://omarchy.org/) først, læg den på en USB-nøgle (brug [Rufus](https://rufus.ie/) på Windows, [balenaEtcher](https://etcher.balena.io/) på Mac eller [caligula](https://github.com/ifd3f/caligula) på Linux), og boot fra nøglen.

_Du skal slå Secure Boot og/eller TPM fra i BIOS. Du er nødt til at slå dem fra for at kunne installere Omarchy. Det er Microsoft-sikkerhedsordninger beregnet til Windows og Microsoft-tilknyttede Linux-distributioner._

Besvar derefter konfigurationsspørgsmålene, og bekræft dem sådan her:

 ![install-config](images/install-config.webp)

Vælg derefter et drev til din installation, læn dig tilbage, og se installationsshowet køre. Det kan være færdigt på under et minut på de hurtigste moderne maskiner, men det bør ikke tage mere end 5 minutter, selv på en ældre computer.

 ![install-done](images/install-done.webp)

Nu er du klar til Omarchy!

### Brug et kablet eller 2.4ghz-tastatur!

Krypteringen af hele disken lader dig ikke indtaste adgangskoden fra et Bluetooth-tastatur ved opstart. Ligesom du ikke kan bruge et Bluetooth-tastatur til at komme ind i BIOS på en PC. Du skal bruge et tastatur, der enten bruger en 2.4ghz-dongle eller et kabel (hvilket alligevel er meget rarere, når det gælder latency!). Jeg elsker personligt [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Installation til en anden ejer

Hvis du sætter en maskine op til en anden — et familiemedlem, en ny medarbejder, en køber — bør du ikke besvare de personlige spørgsmål på deres vegne. Tryk på `Ctrl + C` på installatørens allerførste skærm (tastaturvalget), så tilbyder Omarchy i stedet at klargøre maskinen til en anden ejer. Systemet installeres med det samme, men hele den personlige opsætning — tastaturlayout, brugernavn, adgangskode — udskydes, til maskinen booter for første gang. Drevet er stadig krypteret som standard, og den adgangskode, den nye ejer vælger ved den første boot, bliver også krypteringsadgangskoden. (En maskine, du allerede har brugt, kan også overdrages uden en ny installation — se [nulstilling af computeren](48-security.md).)

### Installationer uden opsyn

ISO'en kan også installere helt af sig selv — intet tastatur, ingen guide — når den får sin konfiguration på et andet drev. Det er måden at behandle Omarchy som et basisimage til VM'er og maskinparker på. Se [installationer uden opsyn](51-unattended-installs.md).

### Installationer uden kryptering

Omarchy installeres med kryptering som standard. Det er det sikre, ansvarlige valg for enhver computer, der overhovedet kan blive væk eller stjålet. Du vil ikke have, at nogen med adgang til din hardware skal kunne få fat i dine data!

Men under særlige omstændigheder, som f.eks. fjerninstallationer af Omarchy på beskyttede computere eller til smid-væk-installationer uden følsomme data, vil du måske installere uden kryptering. Du kan trykke på `Ctrl + C` på bekræftelsen af diskformateringen for at skifte til en installation uden kryptering.

### Sprog

Omarchy taler 50 sprog — samme sæt som omarchy.org — og engelsk er standarden. For at skifte skal du åbne Omarchy-menuen og gå til _Opsætning > Region > Sprog_ eller køre `omarchy language <code>` i en terminal (`omarchy language list` viser koderne). Menuen, skrivebordet og Omarchys egne notifikationer skifter sprog med det samme, og alle programmer, du åbner bagefter, følger også med. Programmer, der allerede var åbne, skifter, når du genstarter dem.

For at beholde sproget, men skrive datoer, klokkeslæt, tal, penge, enheder og papirstørrelser, som man gør i en anden region (f.eks. engelsk med europæiske datoer og 24-timers ur), skal du vælge en region under _Opsætning > Region > Formater_, hvor hvert valg viser et eksempel, eller køre `omarchy region <code>` (`omarchy region list` viser koderne). _Samme som sprog_ går tilbage til sprogets egne formater. Ligesom et sprogskift gælder det for de programmer, du åbner bagefter.

### Hjælp, hvis du sidder fast

Hvis du sidder fast, kan du som regel finde nogen, der vil hjælpe, i kanalen _#omarchy-help_ på [fællesskabets Discord](https://omarchy.org/discord).
