# Komme i gang

Omarchy installeres ved hjelp av en ISO. Du kan velge mellom en installasjon på hele disken, som overtar hele disken, eller en installasjon på ledig plass, som legger Omarchy på den ikke-allokerte plassen på en disk — det er slik du dual booter ved siden av Windows eller et annet operativsystem (se [installasjon med dual boot](50-dual-boot-install.md) — merk at du først må slå av BitLocker i Windows). Uansett bruker installasjonen full kryptering som standard, og alternativet for hele disken vil slette den valgte disken, så sørg for å ta en sikkerhetskopi før du bruker en eksisterende disk!

[Last ned Omarchy ISO-en](https://omarchy.org/) først, legg den på en USB-minnepinne (bruk [balenaEtcher](https://etcher.balena.io/) på Mac/Windows eller [caligula](https://github.com/ifd3f/caligula) på Linux), og start opp fra minnepinnen.

_Du må slå av Secure Boot og/eller TPM i BIOS. Du må slå av disse for å kunne installere Omarchy. De er Microsoft-sikkerhetsopplegg ment for Windows og Microsoft-tilknyttede Linux-distribusjoner._

Deretter svarer du på konfigurasjonsspørsmålene, og bekrefter dem slik:

 ![install-config](images/install-config.webp)

Velg deretter en disk for installasjonen din, og len deg tilbake og se installasjonsshowet kjøre. Det kan være gjort på under ett minutt på de raskeste moderne maskinene, men det bør ikke ta mer enn 5 minutter selv på en eldre datamaskin.

 ![install-done](images/install-done.webp)

Nå er du klar til å Omarchy!

### Bruk et kablet tastatur eller et tastatur med 2.4ghz!

Fulldisk-krypteringen lar deg ikke taste inn passordet fra et Bluetooth-tastatur ved oppstart. Akkurat som du ikke kan bruke et Bluetooth-tastatur til å gå inn i BIOS på en PC. Du trenger et tastatur som enten bruker en dongle med 2.4ghz eller en kabel (som uansett er mye bedre for latenstid!). Selv elsker jeg [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Installere for en annen eier

Hvis du setter opp en maskin for noen andre — et familiemedlem, en ny ansatt, en kjøper — bør du ikke svare på de personlige spørsmålene på deres vegne. Trykk `Ctrl + C` på aller første skjerm i installasjonsprogrammet (tastaturvalget), så tilbyr Omarchy å klargjøre maskinen for en annen eier i stedet. Systemet installeres med en gang, men hele det personlige oppsettet — tastaturoppsett, brukernavn, passord — utsettes til maskinen starter opp for første gang. Disken er fortsatt kryptert som standard, og passordet den nye eieren velger ved den første oppstarten, blir også krypteringspassordet. (En maskin du allerede har brukt, kan også leveres videre uten reinstallasjon — se [tilbakestilling av datamaskinen](48-security.md).)

### Uovervåkede installasjoner

ISO-en kan også installere helt på egen hånd — uten tastatur, uten veiviser — når den får konfigurasjonen sin på en annen disk. Det er måten å behandle Omarchy som et basisbilde for VM-er og maskinflåter på. Se [uovervåkede installasjoner](51-unattended-installs.md).

### Installasjoner uten kryptering

Omarchy installeres med kryptering som standard. Det er det trygge, ansvarlige valget for enhver datamaskin som kan bli mistet eller stjålet. Du vil ikke at noen med tilgang til maskinvaren din skal kunne få tak i dataene dine!

Men under spesielle omstendigheter, som eksterne Omarchy-installasjoner på beskyttede datamaskiner eller for engangsinstallasjoner uten sensitive data, vil du kanskje installere uten kryptering. Du kan trykke `Ctrl + C` på bekreftelsen for diskformatering for å bytte til en installasjon uten kryptering.

### Språk

Omarchy snakker 50 språk — samme utvalg som omarchy.org — og engelsk er standarden. For å bytte åpner du Omarchy-menyen og går til _Oppsett > Språk_, eller kjører `omarchy language <code>` i en terminal (`omarchy language list` viser kodene). Menyen, skrivebordet og Omarchys egne varsler bytter språk umiddelbart, og alle programmer du åpner etterpå, følger også etter. Programmer som allerede var åpne, bytter når du starter dem på nytt.

### Hjelp hvis du sitter fast

Hvis du sitter fast, finner du vanligvis noen som er villige til å hjelpe, i kanalen _#omarchy-help_ på [fellesskapets Discord](https://omarchy.org/discord).
