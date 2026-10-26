# Sikkerhet

Omarchy tar sikkerhet ekstremt alvorlig. Dette skal være et operativsystem du kan bruke til å gjøre _Virkelig Arbeid_ i den _Virkelige Verden_. Der det å miste en bærbar PC ikke kan føre til en sikkerhetskrise. Så her er hva vi gjør:

1. *Full diskkryptering er obligatorisk*: Dette er det viktigste steget for å sikre det fysiske vernet av dataene dine. Hvis datamaskinen din blir mistet eller stjålet, er dataene fullstendig kryptert med standard LUKS (Linux Unified Key Setup).
2. *Brannmuren er aktivert som standard*: All innkommende trafikk blokkeres som standard, bortsett fra port 53317 for [LocalSend](https://localsend.org/). Selv ssh er av til du slår det på via _Setup > Security > SSHD_, som åpner port 22 (med hastighetsbegrensning mot brute force) som en del av oppsettet. Vi låser til og med ned Docker-tilgang ved hjelp av [ufw-docker](https://github.com/chaifeng/ufw-docker)-oppsettet for å hindre at containerne dine ved et uhell blir eksponert mot verden.
3. *Arch har alltid de nyeste oppdateringene*: Arch, den underliggende distro-en Omarchy er bygget på, er en rullende distribusjon. Det betyr at enhver sikkerhetssårbarhet som blir oppdaget og fikset i en pakke, raskt blir tilgjengelig for installasjon med `omarchy-update`. På den måten kjører du alltid de nyeste, sikreste versjonene av alt.
4. *Omarchy vedlikeholder sine egne pakker og sitt eget speil*: Omarchy bruker som standard bare pakker fra Arch sine egne core/extra/multilib-repositorier og sitt eget Omarchy Package Repository. Du kan installere programvare direkte fra AUR, men baseinstallasjonen gjør det ikke — bare noen få valgfrie installasjoner, som tredjeparts nettlesere, henter fra AUR.
5. *Cloudflare beskytter oss mot DDoS*: Distribusjonsinfrastrukturen til Omarchy — ISO-ene, Omarchy-pakkene, Arch-speilet — er beskyttet bak Cloudflares formidable DDoS-skjold og hostet på deres CDN. Dette gir suveren tilgjengelighet.

## Endre passordene dine

Du har to passord på en kryptert installasjon: det som låser opp disken ved oppstart, og det du logger inn og bruker `sudo` med. Oppsettet gjør dem like. Begge kan endres under _Update > Password_ i Omarchy-menyen — _Drive Encryption_ for det første, _User_ for det andre. Når du endrer diskpassordet, blir du først spurt om det nåværende, så ha det for hånden. Hvis en endring blir avbrutt, kjører du _Drive Encryption_ igjen: den spør etter passordet som låser opp disken nå, og fullfører endringen.

## Gi videre en maskin du allerede har brukt

Hvis du skal overlevere maskinen din til noen andre, trenger du ikke å installere den på nytt. Kjør _Setup > Reset Computer_ i Omarchy-menyen, skriv `reset` for å bekrefte, og start på nytt. Det sletter alle brukerkontoer og alt i `/home`, forkaster alle pakkene og systemendringene du har gjort siden installasjonen, og fjerner maskinens identitet — nettverkstilkoblinger, vertsnøkler, alt sammen. Det som kommer opp igjen, er oppsettsveiviseren fra første oppstart, klar for at den nye eieren kan skrive inn sitt eget navn, passord og krypteringspassord.

Det fungerer ved å gjenopprette grunnlinje-øyeblikksbildet installasjonsprogrammet tar, så det er bare tilgjengelig på maskiner installert fra Omarchy ISO-en. Og på en disk uten kryptering er en tilbakestilling sletting snarere enn sikker sletting, så hvis dataene var sensitive, gjør du en fersk installasjon i stedet.

## Passordløs sudo

Noen ganger vil du at `sudo` skal slutte å spørre, oftest når en AI-agent gjør et langt stykke systemarbeid for deg. _Setup > Security > Passwordless Sudo_ spør hvor lenge du vil tillate tilgang: **15 minutter**, **1 time**, **1 dag** eller **Permanent**. Et rødt advarselsikon vises ved siden av de andre indikatorene på menylinjen mens tilgangen er aktiv. Klikk på det eller kjør kommandoen igjen for å slå tilgangen av. Du kan også oppgi ditt eget antall minutter (fra 1 til 1440) med `omarchy-sudo-passwordless 30`, eller bruke `omarchy-sudo-passwordless permanent`.

Tidsbegrenset tilgang utløper automatisk, også umiddelbart etter at maskinen våkner fra en hvilemodus som krysset tidsfristen. Å starte datamaskinen på nytt avslutter den tidlig. Permanent tilgang overlever omstarter og forblir aktivert til du deaktiverer den.

Å oppdatere eller fjerne innstillingspakken til Omarchy avslutter enhver midlertidig tildeling før støtten for utløp endres. Hvis kommandoen melder om en autorisasjons- eller oppryddingsfeil, må du løse den før du prøver å aktivere en ny tildeling; en feil betyr ikke at passordløs tilgang er inaktiv.

Vær klarsynt om dette: mens den er på, kan alt som kjører som brukeren din, gjøre hva som helst som root uten å bli spurt. Det er hele poenget, og det er også hele risikoen.

## Signeringsnøkler

Den offentlige nøkkelen for alle ISO-signaturer og Omarchy-repo-pakker er `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifiser på openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakken `omarchy/omarchy-keyring` inneholder også denne og vil bli brukt til å rulle ut eventuelle oppdateringer sømløst.

Du finner signaturen for enhver ISO-utgivelse ved å legge til `.sig` i URL-en dens, som `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
