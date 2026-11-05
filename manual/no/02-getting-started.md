# Kom i gang

Omarchy installeres ved hjelp av en ISO. Du kan velge mellom en installasjon på hele disken, som tar over hele stasjonen, eller en installasjon i ledig plass, som legger Omarchy i den ikke-allokerte plassen på en stasjon — det er slik du dual-booter ved siden av Windows eller et annet OS (se [installasjon med dual-boot](50-dual-boot-install.md) — merk at du må slå av BitLocker i Windows først). Uansett er full kryptering standarden for installasjonen, og alternativet for hele disken vil slette den valgte stasjonen, så sørg for å ta en sikkerhetskopi før du bruker en eksisterende en!

[Last ned Omarchy ISO-en](https://omarchy.org/) først, legg den på en USB-pinne (bruk [Rufus](https://rufus.ie/) på Windows, [balenaEtcher](https://etcher.balena.io/) på Mac eller [caligula](https://github.com/ifd3f/caligula) på Linux), og start opp fra pinnen.

_Du må slå av Secure Boot og/eller TPM i BIOS. Du må slå av disse for å kunne installere Omarchy. De er Microsofts sikkerhetsordninger ment for Windows og Microsoft-tilknyttede Linux-distribusjoner._

Svar deretter på konfigurasjonsspørsmålene, og bekreft dem slik:

 ![install-config](images/install-config.webp)

Velg deretter en stasjon for installasjonen, og len deg tilbake og se installasjonsshowet. Det kan være ferdig på under ett minutt på de raskeste moderne maskinene, men det bør ikke ta mer enn 5 minutter selv på en eldre datamaskin.

 ![install-done](images/install-done.webp)

Nå er du klar til å Omarchy!

### Bruk et kablet tastatur eller et 2.4ghz-tastatur!

Krypteringen av hele disken lar deg ikke skrive inn passordet fra et Bluetooth-tastatur ved oppstart. Akkurat som du ikke kan bruke et Bluetooth-tastatur til å gå inn i BIOS på en PC. Du trenger et tastatur som enten bruker en 2.4ghz-dongle eller en kabel (som uansett er mye bedre for latenstid!). Personlig elsker jeg [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Installere for en annen eier

Hvis du setter opp en maskin for noen andre — et familiemedlem, en ny ansatt, en kjøper — bør du ikke svare på de personlige spørsmålene på deres vegne. Trykk `Ctrl + C` på det aller første skjermbildet i installasjonsprogrammet (tastaturvalget), så vil Omarchy i stedet tilby å klargjøre maskinen for en annen eier. Systemet installeres med en gang, men all personlig konfigurasjon — tastaturoppsett, brukernavn, passord — utsettes til maskinen starter opp for første gang. Stasjonen er fortsatt kryptert som standard, og passordet den nye eieren velger ved den første oppstarten, blir også krypteringspassordet. (En maskin du allerede har brukt, kan også overleveres uten reinstallasjon — se [nullstille datamaskinen](48-security.md).)

### Installasjoner uten tilsyn

ISO-en kan også installere helt på egen hånd — uten tastatur, uten veiviser — når den får konfigurasjonen sin på en annen stasjon. Det er måten å behandle Omarchy som et basisbilde for VM-er og maskinparker på. Se [installasjoner uten tilsyn](51-unattended-installs.md).

### Installasjoner uten kryptering

Omarchy installeres med kryptering som standard. Det er det trygge, ansvarlige valget for enhver datamaskin som kan bli mistet eller stjålet. Du vil ikke at noen med tilgang til maskinvaren din skal kunne få tak i dataene dine!

Men under spesielle omstendigheter, som eksterne Omarchy-installasjoner på beskyttede datamaskiner eller for engangsinstallasjoner uten sensitive data, kan det hende du vil installere uten kryptering. Du kan trykke `Ctrl + C` ved bekreftelsen av diskformatering for å bytte til en installasjon uten kryptering.

### Språk

Omarchy snakker 50 språk — det samme utvalget som omarchy.org — og engelsk er standarden. For å bytte åpner du Omarchy-menyen og går til _Oppsett > Språk_, eller kjører `omarchy language <code>` i en terminal (`omarchy language list` viser kodene). Menyen, skrivebordet og Omarchys egne varsler skifter språk umiddelbart, og alle applikasjoner du åpner etterpå, følger også etter. Apper som allerede var åpne, bytter når du starter dem på nytt.

### Hjelp hvis du står fast

Hvis du står fast, kan du vanligvis finne noen som er villige til å hjelpe, i _#omarchy-help_-kanalen på [fellesskapets Discord](https://omarchy.org/discord).
