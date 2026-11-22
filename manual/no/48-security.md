# Sikkerhet

Omarchy tar sikkerhet ekstremt alvorlig. Dette skal være et operativsystem du kan bruke til å gjøre _virkelig arbeid_ i den _virkelige verden_. Der det å miste en bærbar PC ikke kan føre til en sikkerhetskrise. Så her er hva vi gjør:

1. *Fulldiskkryptering er på som standard*: Dette er det viktigste steget for å sikre den fysiske beskyttelsen av dataene dine. Hvis datamaskinen din blir mistet eller stjålet, er dataene fullstendig kryptert med standard LUKS (Linux Unified Key Setup). Installasjonsprogrammet lar deg velge det bort for kasserbare maskiner (se [Kom i gang](02-getting-started.md)); en installasjon uten kryptering har ingen av denne beskyttelsen, og hvem som helst som har disken, kan lese den.
2. *Brannmuren er aktivert som standard*: All innkommende trafikk er blokkert som standard, med noen få unntak: port 53317 for [LocalSend](https://localsend.org/); DNS-forespørsler til datamaskinens egen resolver på Docker-bridgeadressen (172.17.0.1), akseptert fra de private adresseområdene Docker gir til containerne sine; og multicast DNS (port 5353), som lar skrivere og andre enheter på nettverket ditt finne hverandre og også kunngjør datamaskinens navn der. I tillegg til disse beholder brannmuren UFWs standardtillatelser for ping, å hente en adresse fra ruteren din (DHCP), og UPnP-oppdagelse. Selv ssh er av til du slår det på via _Oppsett > Sikkerhet > SSHD_, som godkjenner SSH-nøkkelen din, slår av passordinnlogginger, og først da åpner port 22 (med hastighetsbegrensning mot brute force). Vi låser til og med ned Docker-tilgangen ved hjelp av [ufw-docker](https://github.com/chaifeng/ufw-docker)-oppsettet for å hindre at containerne dine ved et uhell blir eksponert for verden.
3. *Arch har alltid de nyeste oppdateringene*: Arch, den underliggende distroen som Omarchy er bygget på, er en rullende distribusjon. Dette betyr at enhver sikkerhetssårbarhet som blir oppdaget og rettet i en hvilken som helst pakke, raskt blir tilgjengelig for installasjon ved hjelp av `omarchy-update`. På den måten kjører du alltid de nyeste, sikreste versjonene av alt.
4. *Omarchy vedlikeholder sine egne pakker og speil*: Omarchy er som standard kun avhengig av pakker fra Arch sine egne core/extra/multilib-repositorier (Arch Linux ARM sine på ARM-maskiner, pluss Asahi ALARM på Apple Silicon) og sitt eget Omarchy Package Repository. Du kan installere programvare direkte fra AUR, men baseinstallasjonen gjør det ikke — bare noen få valgfrie installasjoner, som tredjepartsnettleserne, henter fra AUR.
5. *Cloudflare beskytter oss mot DDoS*: Omarchys distribusjonsinfrastruktur — ISO-ene, Omarchy-pakkene, Arch-speilet — er beskyttet bak Cloudflares formidable DDoS-skjold og hostet på deres CDN. Dette gir suveren tilgjengelighet.

## Endre passordene dine

Du har to passord på en kryptert installasjon: det ene som låser opp disken ved oppstart, og det andre du logger inn og bruker `sudo` med. Oppsettet gjør dem til det samme. Begge kan endres under _Oppdater > Passord_ i Omarchy-menyen — _Diskkryptering_ for det første, _Bruker_ for det andre. Å endre diskpassordet krever at du oppgir det nåværende først, så ha det for hånden. Hvis en endring blir avbrutt, kjører du _Diskkryptering_ igjen: den ber om passordet som låser opp disken nå, og fullfører endringen.

## Overlevere en maskin du allerede har brukt

Hvis du skal overlevere maskinen din til noen andre, trenger du ikke å installere den på nytt. Kjør _Fjern > Fabrikktilbakestilling_ i Omarchy-menyen, skriv `reset` for å bekrefte, skriv inn diskkrypteringspassordet ditt hvis du blir bedt om det, og start på nytt. Det sletter hver eneste brukerkonto og alt i `/home`, kaster alle pakkene og systemendringene du har gjort siden installasjonen, og fjerner maskinens identitet — nettverksforbindelser, vertsnøkler og alt. Det som kommer opp igjen, er oppsettsveiviseren fra første oppstart, klar for at den nye eieren kan skrive inn sitt eget navn, passord og krypteringspassord.

Det fungerer ved å gjenopprette basis-snapshotet installasjonsprogrammet tar, så det er bare tilgjengelig på maskiner installert fra Omarchy-ISO-en. Og på en disk uten kryptering er en tilbakestilling sletting snarere enn en sikker sletting, så hvis dataene var sensitive, gjør en ny installasjon i stedet.

## Passordløs sudo

Noen ganger vil du at `sudo` skal slutte å spørre, oftest når en KI-agent gjør en lang økt med systemarbeid for deg. _Oppsett > Sikkerhet > Passordløs Sudo_ spør hvor lenge tilgangen skal vare: **15 minutter**, **1 time**, **1 dag** eller **Permanent**. Et rødt advarselsikon vises ved siden av de andre indikatorene på menylinjen mens tilgangen er aktiv. Klikk på det eller kjør kommandoen igjen for å slå tilgangen av. Du kan også oppgi ditt eget antall minutter (fra 1 til 1440) med `omarchy-sudo-passwordless 30`, eller bruke `omarchy-sudo-passwordless permanent`.

Tidsbegrenset tilgang utløper automatisk, også umiddelbart etter at du våkner fra en hvilemodus som krysset tidsfristen. Å starte datamaskinen på nytt avslutter den tidlig. Permanent tilgang overlever omstarter og forblir aktivert til du deaktiverer den.

Oppdatering eller fjerning av Omarchys innstillingspakke avslutter enhver midlertidig tildeling før støtten for utløp endres. Hvis kommandoen rapporterer en autorisasjons- eller oppryddingsfeil, må du løse den før du prøver å aktivere en annen tildeling; en feil betyr ikke at passordløs tilgang er inaktiv.

Vær klarøyd på denne: mens den er på, kan alt som kjører som brukeren din, gjøre alt som root uten å bli spurt. Det er hele poenget, og det er også hele risikoen.

## Signeringsnøkler

Den offentlige nøkkelen for alle ISO-signaturer og Omarchy-repo-pakker er `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifiser på openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakken `omarchy/omarchy-keyring` inneholder også denne og vil bli brukt til å rulle ut eventuelle oppdateringer sømløst.

Du kan finne signaturen for enhver ISO-utgivelse ved å legge til `.sig` i URL-en, som `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
