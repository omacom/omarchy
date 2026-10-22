# Sikkerhet

Omarchy tar sikkerhet ekstremt alvorlig. Dette er ment å være et operativsystem du kan bruke til å gjøre _Ekte Arbeid_ i den _Ekte Verden_. Der det å miste en bærbar ikke kan føre til en sikkerhetskrise. Så her er hva vi gjør:

1. *Fulldiskkryptering er påbudt*: Dette er det viktigste steget for å sikre den fysiske beskyttelsen av dataene dine. Hvis datamaskinen din går tapt eller blir stjålet, er dataene fullstendig kryptert med standard LUKS (Linux Unified Key Setup).
2. *Brannmur er aktivert som standard*: All innkommende trafikk er blokkert som standard unntatt port 53317 for [LocalSend](https://localsend.org/). Selv ssh er av til du slår det på via _Oppsett > Sikkerhet > SSHD_, som åpner port 22 (med hastighetsbegrensning mot brute force) som en del av oppsettet. Vi låser til og med ned Docker-tilgang med [ufw-docker](https://github.com/chaifeng/ufw-docker)-oppsettet for å forhindre at containerne dine ved et uhell eksponeres for verden.
3. *Arch har alltid de nyeste oppdateringene*: Arch, den underliggende distro-en Omarchy er bygget på, er en rullende distribusjon. Det betyr at enhver sikkerhetssårbarhet som oppdages og patches i en pakke, raskt er tilgjengelig for installasjon med `omarchy-update`. Du kjører alltid de nyeste, sikreste versjonene av alt på den måten.
4. *Omarchy vedlikeholder sine egne pakker og speil*: Omarchy støtter seg bare på pakker fra Archs egne core/extra/multilib-repositorier og sitt eget Omarchy Package Repository som standard. Du kan installere programvare direkte fra AUR, men basisinstallasjonen gjør det ikke — bare noen få valgfrie installasjoner, som tredjepartsnettleserne, henter fra AUR.
5. *Cloudflare beskytter oss mot DDoS*: All Omarchy-distribusjonsinfrastrukturen — ISO-ene, Omarchy-pakkene, Arch-speilet — er beskyttet bak Cloudflares formidabele DDoS-skjold og hostet på CDN-et deres. Dette gir suveren tilgjengelighet.

## Endre passordene dine

Du har to passord på en kryptert installasjon: det som låser opp disken ved oppstart, og det du logger inn og `sudo`-er med. Oppsettet gjør dem like. Begge kan endres under _Oppdater > Passord_ i Omarchy-menyen — _Diskkryptering_ for det første, _Bruker_ for det andre. Å endre diskpassordet ber om det gjeldende først, så ha det for hånden. Hvis en endring blir avbrutt, kjør _Diskkryptering_ igjen: det ber om passordet som låser opp disken nå og fullfører endringen.

## Gi videre en maskin du allerede har brukt

Hvis du overleverer maskinen din til noen andre, trenger du ikke å installere den på nytt. Kjør _Oppsett > Nullstill datamaskin_ i Omarchy-menyen, skriv `reset` for å bekrefte og start på nytt. Det sletter hver brukerkonto og alt i `/home`, kaster alle pakkene og systemendringene du gjorde siden installasjonen, og sletter maskinens identitet — nettverkstilkoblinger, vertsnøkler og alt. Det som kommer opp igjen er oppsettsveiviseren fra første oppstart, klar for at den nye eieren kan skrive inn sitt eget navn, passord og krypteringspassord.

Det fungerer ved å gjenopprette baseline-snapshotet installasjonsprogrammet tar, så det er bare tilgjengelig på maskiner installert fra Omarchy ISO-en. Og på en disk uten kryptering er en nullstilling sletting i stedet for en sikker sletting, så hvis dataene var sensitive, gjør en fersk installasjon i stedet.

## Passordløs sudo

Noen ganger vil du at `sudo` skal slutte å spørre, oftest når en AI-agent gjør en lang økt med systemarbeid for deg. _Oppsett > Sikkerhet > Sudo uten passord_ spør hvor lenge tilgang skal tillates: **15 minutes**, **1 Hour**, **1 Day** eller **Permanently**. Et rødt advarselsikon vises ved siden av de andre menylinjeindikatorene mens tilgangen er aktiv. Klikk på det eller kjør kommandoen igjen for å slå av tilgangen. Du kan også oppgi ditt eget antall minutter (fra 1 til 1440) med `omarchy-sudo-passwordless 30`, eller bruke `omarchy-sudo-passwordless permanent`.

Tidsbegrenset tilgang utløper automatisk, inkludert umiddelbart etter å ha gjenopptatt fra en hvile som krysset fristen. Å starte datamaskinen på nytt avslutter den tidlig. Permanent tilgang overlever omstarter og forblir aktivert til du deaktiverer den.

Å oppdatere eller fjerne Omarchys innstillingspakke avslutter enhver midlertidig tildeling før utløpsstøtten dens endres. Hvis kommandoen rapporterer en autorisasjons- eller oppryddingsfeil, løs den før du prøver å aktivere en annen tildeling; en feil betyr ikke at passordløs tilgang er inaktiv.

Vær klarsynt om denne: mens den er på, kan alt som kjører som brukeren din gjøre hva som helst som root uten å bli spurt. Det er hele poenget, og det er også hele risikoen.

## Signeringsnøkler

Den offentlige nøkkelen for alle ISO-signaturer og Omarchy repo-pakken er `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifiser på openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). `omarchy/omarchy-keyring`-pakken inneholder også denne og vil bli brukt til å rulle ut eventuelle oppdateringer sømløst.

Du finner signaturen for enhver ISO-utgivelse ved å legge til .sig på URL-en. Som https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
