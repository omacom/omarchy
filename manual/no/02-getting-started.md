# Komme i gang

Omarchy installeres med en ISO. Du kan velge mellom en installasjon på hele disken, som tar over hele disken, eller en installasjon i ledig plass, som legger Omarchy i den ikke-allokerte plassen på en disk — det er slik du dual-booter ved siden av Windows eller et annet OS (se [installasjon med dual boot](50-dual-boot-install.md) — merk at du må slå av BitLocker i Windows først). Uansett er kryptering standard ved installasjonen, og alternativet for hele disken sletter den valgte disken, så sørg for å ta en sikkerhetskopi før du bruker en eksisterende!

På en Apple Silicon Mac installerer du fra macOS i stedet, uten ISO eller USB-pinne. Se [Omarchy for Apple Silicon](44-mac-support.md#omarchy-for-apple-silicon).

[Last ned Omarchy ISO-en](https://omarchy.org/) først, legg den på en USB-pinne (bruk [Rufus](https://rufus.ie/) på Windows, [balenaEtcher](https://etcher.balena.io/) på Mac, eller [caligula](https://github.com/ifd3f/caligula) på Linux), og start opp fra pinnen.

_Du må slå av Secure Boot og/eller TPM i BIOS. Du må slå av disse for å kunne installere Omarchy. De er Microsofts sikkerhetsordninger ment for Windows og Microsoft-tilknyttede Linux-distribusjoner._

Svar deretter på konfigurasjonsspørsmålene, og bekreft dem slik:

 ![install-config](images/install-config.webp)

Velg deretter en disk for installasjonen, og len deg tilbake og se installasjonsshowet rulle. Det kan være gjort på under et minutt på de raskeste moderne maskinene, men det bør ikke ta mer enn 5 minutter selv på en eldre datamaskin.

 ![install-done](images/install-done.webp)

Nå er du klar for Omarchy!

### Bruk et kablet eller 2.4ghz-tastatur!

Fulldiskkrypteringen lar deg ikke skrive inn passordet fra et Bluetooth-tastatur ved oppstart. Akkurat som du ikke kan bruke et Bluetooth-tastatur til å gå inn i BIOS på en PC. Du trenger et tastatur som enten bruker en 2.4ghz-dongle eller en kabel (noe som uansett er mye bedre for latenstid!). Jeg elsker personlig [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Installere for en annen eier

Hvis du setter opp en maskin for noen andre — et familiemedlem, en ny ansatt, en kjøper — bør du ikke svare på de personlige spørsmålene på deres vegne. Trykk `Ctrl + C` på den aller første skjermen i installasjonsprogrammet (tastaturvalget), så tilbyr Omarchy å klargjøre maskinen for en annen eier i stedet. Systemet installeres med en gang, men alt det personlige oppsettet — tastaturoppsett, brukernavn, passord — utsettes til maskinen starter for første gang. Disken er fortsatt kryptert som standard, og passordet den nye eieren velger ved den første oppstarten, blir også krypteringspassordet. (En maskin du allerede har brukt, kan også overleveres uten reinstallasjon — se [nullstilling av datamaskinen](48-security.md).)

### Installasjoner uten tilsyn

ISO-en kan også installere helt på egen hånd — uten tastatur, uten veiviser — når den får konfigurasjonen sin på en annen disk. Det er måten å behandle Omarchy som et grunnbilde for VM-er og maskinparker på. Se [installasjoner uten tilsyn](51-unattended-installs.md).

### Installasjoner uten kryptering

Omarchy installeres med kryptering som standard. Det er det trygge, ansvarlige valget for enhver datamaskin som overhodet kan mistes eller bli stjålet. Du vil ikke at noen med tilgang til maskinvaren din skal kunne få tak i dataene dine!

Men under spesielle omstendigheter, som eksterne Omarchy-installasjoner på beskyttede datamaskiner eller for engangsinstallasjoner uten sensitive data, kan det hende du vil installere uten kryptering. Du kan trykke `Ctrl + C` på bekreftelsen for diskformatering for å bytte til en installasjon uten kryptering.

### Språk

Omarchy snakker 50 språk — det samme utvalget som omarchy.org — og engelsk er standarden. For å bytte åpner du Omarchy-menyen og går til _Oppsett > Region > Språk_, eller kjører `omarchy language <code>` i en terminal (`omarchy language list` viser kodene). Menyen, skrivebordet og Omarchys egne varsler skifter språk umiddelbart, og alle applikasjoner du åpner etterpå, følger etter også. Apper som allerede var åpne, skifter når du starter dem på nytt.

For å beholde språket, men skrive datoer, klokkeslett, tall, penger, enheter og papirstørrelser slik en annen region gjør det (for eksempel engelsk med europeiske datoer og 24-timers klokke), velger du en region under _Oppsett > Region > Formater_, der hvert valg viser et eksempel, eller kjører `omarchy region formats <code>` (`omarchy region formats list` viser kodene). _Samme som språk_ går tilbake til språkets egne formater. Akkurat som et språkbytte når det appene du åpner etterpå.

### Hjelp hvis du står fast

Hvis du står fast, finner du vanligvis noen som vil hjelpe i kanalen _#omarchy-help_ på [fellesskapets Discord](https://omarchy.org/discord).
