# Sikkerhet

Omarchy tar sikkerhet ekstremt alvorlig. Dette skal være et operativsystem du kan bruke til å gjøre _Real Work_ i _Real World_. Hvor det å miste en bærbar PC ikke kan føre til en sikkerhetskrise. Så her er hva vi gjør:

1. *Full diskkryptering er obligatorisk*: Dette er det viktigste steget for å sikre den fysiske beskyttelsen av dataene dine. Hvis datamaskinen din blir mistet eller stjålet, er dataene fullstendig kryptert med standard LUKS (Linux Unified Key Setup).
2. *Brannmur er aktivert som standard*: All innkommende trafikk blokkeres som standard, unntatt port 53317 for [LocalSend](https://localsend.org/). Selv ssh er av til du slår det på via _Setup > Security > SSHD_, som åpner port 22 (med hastighetsbegrensning mot brute force) som en del av oppsettet. Vi låser til og med ned Docker-tilgang ved hjelp av [ufw-docker](https://github.com/chaifeng/ufw-docker)-oppsettet for å hindre at containerne dine utilsiktet blir eksponert for verden.
3. *Arch har alltid de nyeste oppdateringene*: Arch, den underliggende distribusjonen som Omarchy er bygget på, er en rullende distribusjon. Det betyr at enhver sikkerhetssårbarhet som blir oppdaget og fikset i en pakke, raskt blir tilgjengelig for installasjon med `omarchy-update`. På den måten kjører du alltid de nyeste og sikreste versjonene av alt.
4. *Omarchy vedlikeholder sine egne pakker og sitt eget speil*: Som standard er Omarchy kun avhengig av pakker fra Archs egne core/extra/multilib-repositorier og sitt eget Omarchy Package Repository. Du kan installere programvare direkte fra AUR, men baseinstallasjonen gjør det ikke — bare noen få valgfrie installasjoner, som tredjeparts nettlesere, henter fra AUR.
5. *Cloudflare beskytter oss mot DDoS*: Distribusjonsinfrastrukturen til Omarchy — ISO-ene, Omarchy-pakkene, Arch-speilet — er beskyttet bak Cloudflares formidable DDoS-skjold og hostet på deres CDN. Dette gir suveren tilgjengelighet.

## Endre passordene dine

Du har to passord på en kryptert installasjon: det som låser opp disken ved oppstart, og det du logger inn og bruker `sudo` med. Oppsettet gjør dem like. Begge kan endres under _Update > Password_ i Omarchy-menyen — _Drive Encryption_ for det første, _User_ for det andre. For å endre diskpassordet må du først oppgi det nåværende, så ha det for hånden. Hvis en endring blir avbrutt, kjører du _Drive Encryption_ igjen: den ber om passordet som låser opp disken nå, og fullfører endringen.

## Gi videre en maskin du allerede har brukt

Hvis du skal overlevere maskinen din til noen andre, trenger du ikke å installere den på nytt. Kjør _Setup > Reset Computer_ i Omarchy-menyen, skriv `reset` for å bekrefte, og start på nytt. Det sletter alle brukerkontoer og alt i `/home`, kaster alle pakker og systemendringer du har gjort siden installasjonen, og fjerner maskinens identitet — nettverkstilkoblinger, vertsnøkler og alt. Det som kommer opp igjen, er oppsettsveiviseren fra første oppstart, klar for at den nye eieren skal legge inn sitt eget navn, passord og krypteringspassord.

Det fungerer ved å gjenopprette basis-snapshotet som installasjonsprogrammet tar, så det er bare tilgjengelig på maskiner som er installert fra Omarchy ISO-en. Og på en disk uten kryptering er en tilbakestilling sletting snarere enn sikker sletting, så hvis dataene var sensitive, bør du heller gjøre en fersk installasjon.

## Passordløs sudo

Noen ganger vil du at `sudo` skal slutte å spørre, oftest når en AI-agent gjør en lang økt med systemarbeid for deg. _Setup > Security > Passwordless Sudo_ spør hvor lenge tilgangen skal vare: **15 minutter**, **1 time**, **1 dag** eller **permanent**. Et rødt advarselsikon vises ved siden av de andre indikatorene i menylinjen mens tilgangen er aktiv. Klikk på det eller kjør kommandoen igjen for å slå av tilgangen. Du kan også oppgi ditt eget antall minutter (fra 1 til 1440) med `omarchy-sudo-passwordless 30`, eller bruke `omarchy-sudo-passwordless permanent`.

Tidsbegrenset tilgang utløper automatisk, også umiddelbart etter gjenopptak fra en hvilemodus som passerte fristen. Å starte datamaskinen på nytt avslutter den tidlig. Permanent tilgang overlever omstarter og forblir aktivert til du deaktiverer den.

Oppdatering eller fjerning av innstillingspakken til Omarchy avslutter enhver midlertidig tilgang før støtten for utløp endres. Hvis kommandoen rapporterer en autorisasjons- eller oppryddingsfeil, må du løse den før du prøver å aktivere en ny tilgang; en feil betyr ikke at passordløs tilgang er inaktiv.

Vær klarsynt om dette: mens den er på, kan alt som kjører som brukeren din, gjøre hva som helst som root uten å bli spurt. Det er hele poenget, og det er også hele risikoen.

## Signeringsnøkler

Den offentlige nøkkelen for alle ISO-signaturer og Omarchy-repo-pakken er `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifiser på openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakken `omarchy/omarchy-keyring` inneholder også denne og vil bli brukt til å rulle ut eventuelle oppdateringer sømløst.

Du finner signaturen for enhver ISO-utgivelse ved å legge til .sig i URL-en. Som https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
