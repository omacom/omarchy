# Sikkerhet

Omarchy tar sikkerhet ekstremt alvorlig. Dette skal være et operativsystem du kan bruke til å gjøre _Real Work_ i _Real World_. Der det å miste en bærbar datamaskin ikke kan føre til en sikkerhetskrise. Så her er hva vi gjør:

1. *Full diskkryptering er på som standard*: Dette er det viktigste steget for å sikre den fysiske beskyttelsen av dataene dine. Hvis datamaskinen din går tapt eller blir stjålet, er dataene fullstendig kryptert med standard LUKS (Linux Unified Key Setup). Installasjonsprogrammet lar deg velge det bort for engangsmaskiner (se [Kom i gang](02-getting-started.md)); en installasjon uten kryptering har ingen av denne beskyttelsen, og hvem som helst som har disken, kan lese den.
2. *Brannmur er aktivert som standard*: All innkommende trafikk blokkeres som standard, med noen få unntak: port 53317 for [LocalSend](https://localsend.org/); DNS-spørringer til datamaskinens egen resolver på Docker bridge-adressen (172.17.0.1), akseptert fra de private adresseområdene Docker gir containerne sine; og multicast DNS (port 5353), som lar skrivere og andre enheter på nettverket ditt finne hverandre og også kunngjør datamaskinens navn der. I tillegg til disse beholder brannmuren UFWs standardtillatelser for ping, for å få en adresse fra ruteren din (DHCP), og for UPnP-oppdagelse. Selv ssh er av til du slår den på via _Oppsett > Sikkerhet > SSHD_, som åpner port 22 (med hastighetsbegrensning mot brute force) som en del av oppsettet. Vi låser til og med ned Docker-tilgangen ved hjelp av [ufw-docker](https://github.com/chaifeng/ufw-docker)-oppsettet for å hindre at containerne dine ved et uhell blir eksponert for verden.
3. *Arch har alltid de nyeste oppdateringene*: Arch, den underliggende distroen som Omarchy er bygget på, er en rullende distribusjon. Det betyr at enhver sikkerhetssårbarhet som blir oppdaget og fikset i en pakke, raskt blir tilgjengelig for installasjon med `omarchy-update`. På den måten kjører du alltid de nyeste, sikreste versjonene av alt.
4. *Omarchy vedlikeholder sine egne pakker og sitt eget speil*: Omarchy baserer seg som standard kun på pakker fra Archs egne core/extra/multilib-repositorier og sitt eget Omarchy Package Repository. Du kan installere programvare direkte fra AUR, men grunninstallasjonen gjør det ikke — bare noen få valgfrie installasjoner, som tredjeparts nettlesere, henter fra AUR.
5. *Cloudflare beskytter oss mot DDoS*: Distribusjonsinfrastrukturen til Omarchy — ISO-ene, Omarchy-pakkene, Arch-speilet — er beskyttet bak Cloudflares formidable DDoS-skjold og hostet på CDN-en deres. Det gir suveren tilgjengelighet.

## Endre passordene dine

Du har to passord på en kryptert installasjon: det som låser opp disken ved oppstart, og det du logger inn og bruker `sudo` med. Oppsettet gjør dem like. Begge kan endres under _Oppdater > Passord_ i Omarchy-menyen — _Diskkryptering_ for det første, _Bruker_ for det andre. Når du endrer diskpassordet, blir du først bedt om det gjeldende, så ha det for hånden. Hvis en endring blir avbrutt, kjør _Diskkryptering_ igjen: den ber om passordet som låser opp disken nå, og fullfører endringen.

## Gi videre en maskin du allerede har brukt

Hvis du gir maskinen din videre til noen andre, trenger du ikke å installere den på nytt. Kjør _Oppsett > Tilbakestill datamaskin_ i Omarchy-menyen, skriv `reset` for å bekrefte, og start på nytt. Det sletter hver eneste brukerkonto og alt i `/home`, kaster alle pakkene og systemendringene du har gjort siden installasjonen, og fjerner maskinens identitet — nettverksforbindelser, vertsnøkler og alt. Det som kommer opp igjen, er oppsettsveiviseren fra første oppstart, klar for at den nye eieren kan skrive inn sitt eget navn, passord og krypteringspassord.

Det fungerer ved å gjenopprette basis-snapshotet som installasjonsprogrammet tar, så det er bare tilgjengelig på maskiner som er installert fra Omarchy ISO-en. Og på en disk uten kryptering er en tilbakestilling sletting snarere enn en sikker sletting, så hvis dataene var sensitive, gjør en fersk installasjon i stedet.

## Passordløs sudo

Noen ganger vil du at `sudo` skal slutte å spørre, oftest når en KI-agent gjør en lang økt med systemarbeid for deg. _Oppsett > Sikkerhet > Passordløs Sudo_ spør hvor lenge tilgangen skal tillates: **15 minutter**, **1 time**, **1 dag** eller **permanent**. Et rødt advarselsikon vises ved siden av de andre indikatorene på menylinjen mens tilgangen er aktiv. Klikk på det eller kjør kommandoen igjen for å slå av tilgangen. Du kan også oppgi ditt eget antall minutter (fra 1 til 1440) med `omarchy-sudo-passwordless 30`, eller bruke `omarchy-sudo-passwordless permanent`.

Tidsbegrenset tilgang utløper automatisk, også umiddelbart etter at du fortsetter fra en hvilemodus som krysset fristen. Å starte datamaskinen på nytt avslutter den tidlig. Permanent tilgang overlever omstarter og forblir aktivert til du deaktiverer den.

Å oppdatere eller fjerne innstillingspakken til Omarchy avslutter enhver midlertidig tilgang før støtten for utløp av den endres. Hvis kommandoen rapporterer en autorisasjons- eller oppryddingsfeil, må du løse den før du prøver å aktivere en ny tilgang; en feil betyr ikke at passordløs tilgang er inaktiv.

Vær klarøyd på denne: mens den er på, kan alt som kjører som brukeren din, gjøre hva som helst som root uten å bli spurt. Det er hele poenget, og det er også hele risikoen.

## Signeringsnøkler

Den offentlige nøkkelen for alle ISO-signaturer og Omarchy repo-pakken er `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifiser hos openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakken `omarchy/omarchy-keyring` inneholder også denne og vil bli brukt til å rulle ut eventuelle oppdateringer sømløst.

Du finner signaturen for enhver ISO-utgivelse ved å legge til `.sig` i URL-en dens, som `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
