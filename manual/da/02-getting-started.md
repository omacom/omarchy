# Kom godt i gang

Omarchy installeres ved hjælp af en ISO. Du kan vælge mellem en installation på hele disken, som overtager hele drevet, eller en installation i ledig plads, som lægger Omarchy i den ikke-allokerede plads på et drev — det er sådan, du dual boot'er ved siden af Windows eller et andet OS (se [installation med dual-boot](50-dual-boot-install.md) — bemærk, at du først skal slå BitLocker fra i Windows). Under alle omstændigheder bruger installationen fuld kryptering som standard, og muligheden med hele disken sletter det valgte drev, så sørg for at tage en backup, før du bruger et eksisterende drev!

På en Apple Silicon Mac installerer du i stedet fra macOS, uden ISO eller USB-nøgle. Se [Omarchy til Apple Silicon](44-mac-support.md#omarchy-for-apple-silicon).

[Download Omarchy ISO'en](https://omarchy.org/) først, læg den på en USB-nøgle (brug [Rufus](https://rufus.ie/) på Windows, [balenaEtcher](https://etcher.balena.io/) på Mac eller [caligula](https://github.com/ifd3f/caligula) på Linux), og boot fra nøglen.

_Du skal slå Secure Boot og/eller TPM fra i BIOS. Du er nødt til at slå dem fra for at kunne installere Omarchy. De er Microsofts sikkerhedsordninger beregnet til Windows og Microsoft-tilknyttede Linux-distributioner._

Svar derefter på konfigurationsspørgsmålene, og bekræft dem sådan her:

 ![install-config](images/install-config.webp)

Vælg derefter et drev til din installation, og læn dig tilbage og se installationsshowet. Det kan være færdigt på under et minut på de hurtigste moderne maskiner, men det bør ikke tage mere end 5 minutter selv på en ældre computer.

 ![install-done](images/install-done.webp)

Nu er du klar til Omarchy!

### Brug et kablet eller 2.4ghz-tastatur!

Krypteringen af hele disken tillader ikke, at du indtaster adgangskoden fra et Bluetooth-tastatur ved opstart. Ligesom du ikke kan bruge et Bluetooth-tastatur til at komme ind i BIOS på en PC. Du skal bruge et tastatur, der enten bruger en 2.4ghz-dongle eller et kabel (hvilket alligevel er meget rarere, når det gælder forsinkelse!). Jeg elsker personligt [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Installation til en anden ejer

Hvis du sætter en maskine op til en anden — et familiemedlem, en ny medarbejder, en køber — bør du ikke besvare de personlige spørgsmål på deres vegne. Tryk på `Ctrl + C` på installatørens allerførste skærm (valg af tastatur), så tilbyder Omarchy i stedet at forberede maskinen til en anden ejer. Systemet installeres med det samme, men hele den personlige opsætning — tastaturlayout, brugernavn, adgangskode — udskydes, til maskinen booter første gang. Drevet er stadig krypteret som standard, og den adgangskode, den nye ejer vælger ved den første boot, bliver også krypteringsadgangskoden. (En maskine, du allerede har brugt, kan også overdrages uden en geninstallation — se [nulstilling af computeren](48-security.md).)

### Uovervågede installationer

ISO'en kan også installere helt på egen hånd — intet tastatur, ingen guide — når den får sin konfiguration på et andet drev. Det er måden at behandle Omarchy som et basis-image til VMs og maskinparker på. Se [uovervågede installationer](51-unattended-installs.md).

### Installationer uden kryptering

Omarchy installeres med kryptering som standard. Det er det sikre, ansvarlige valg for enhver computer, der overhovedet kan blive væk eller stjålet. Du vil ikke have, at nogen med adgang til din hardware skal kunne få fat i dine data!

Men under særlige omstændigheder, som ved fjerninstallationer af Omarchy på beskyttede computere eller til engangsinstallationer uden følsomme data, vil du måske installere uden kryptering. Du kan trykke på `Ctrl + C` ved bekræftelsen af diskformatering for at skifte til en installation uden kryptering.

### Sprog

Omarchy taler 50 sprog — det samme sæt som omarchy.org — og engelsk er standarden. Åbn Omarchy-menuen og gå til _Setup > Region > Language_ for at skifte, eller kør `omarchy language <code>` i en terminal (`omarchy language list` viser koderne). Menuen, skrivebordet og Omarchys egne notifikationer skifter sprog med det samme, og alle programmer, du åbner bagefter, følger også med. Programmer, der allerede var åbne, skifter, når du genstarter dem.

Hvis du vil beholde sproget, men skrive datoer, klokkeslæt, tal, penge, enheder og papirstørrelser, som man gør i en anden region (engelsk med europæiske datoer og 24-timers ur, for eksempel), så vælg en region under _Setup > Region > Formats_, hvor hvert valg viser et eksempel, eller kør `omarchy region formats <code>` (`omarchy region formats list` viser koderne). _Same as language_ går tilbage til sprogets egne formater. Ligesom et sprogskift gælder det for de programmer, du åbner bagefter.

### Hjælp, hvis du sidder fast

Hvis du sidder fast, kan du som regel finde nogen, der er villige til at hjælpe, i kanalen _#omarchy-help_ på [fællesskabets Discord](https://omarchy.org/discord).
