# Sikkerhet

Omarchy tar sikkerhet ekstremt alvorlig. Dette er ment å være et operativsystem som du kan bruke til å gjøre _ekte arbeid_ i den _virkelige verden_. Der det å miste en bærbar datamaskin ikke kan føre til en sikkerhetskrise. Så her er hva vi gjør:

1. *Fulldiskkryptering er på som standard*: Dette er det viktigste steget for å sikre den fysiske beskyttelsen av dataene dine. Hvis datamaskinen din blir mistet eller stjålet, er dataene fullstendig kryptert med standard LUKS (Linux Unified Key Setup). Installasjonsprogrammet lar deg velge det bort for kaste-maskiner (se [Kom i gang](02-getting-started.md)); en installasjon uten kryptering har ingen av denne beskyttelsen, og hvem som helst som har disken, kan lese den.
2. *Brannmuren er aktivert som standard*: All innkommende trafikk blokkeres som standard, med noen få unntak: port 53317 for [LocalSend](https://localsend.org/); DNS-spørringer til datamaskinens egen resolver på Docker-bro-adressen (172.17.0.1), akseptert fra de private adresseområdene Docker gir til containerne sine; og multicast DNS (port 5353), som lar skrivere og andre enheter på nettverket ditt finne hverandre og også kunngjør datamaskinens navn der. I tillegg til disse beholder brannmuren UFWs standardtillatelser for ping, å få en adresse fra ruteren din (DHCP), og UPnP-oppdagelse. Selv ssh er av til du slår det på via _Oppsett > Sikkerhet > SSHD_, som åpner port 22 (hastighetsbegrenset mot brute force) som en del av oppsettet. Vi låser til og med ned Docker-tilgangen med [ufw-docker](https://github.com/chaifeng/ufw-docker)-oppsettet for å hindre at containerne dine ved et uhell blir eksponert for verden.
3. *Arch har alltid de nyeste oppdateringene*: Arch, den underliggende distro-en som Omarchy er bygget på, er en rullende distribusjon. Det betyr at enhver sikkerhetssårbarhet som oppdages og fikses i en pakke, raskt er tilgjengelig for installasjon med `omarchy-update`. På den måten kjører du alltid de nyeste, mest sikre versjonene av alt.
4. *Omarchy vedlikeholder sine egne pakker og speil*: Omarchy er bare avhengig av pakker fra Archs egne core/extra/multilib-repositorier og sitt eget Omarchy Package Repository som standard. Du kan installere programvare direkte fra AUR, men baseinstallasjonen gjør det ikke — bare noen få valgfrie installasjoner, som tredjeparts nettlesere, henter fra AUR.
5. *Cloudflare beskytter oss mot DDoS*: Omarchy-distribusjonsinfrastruktur — ISO-ene, Omarchy-pakkene, Arch-speilet — er beskyttet bak Cloudflares formidable DDoS-skjold og hostet på deres CDN. Dette gir suveren tilgjengelighet.

## Endre passordene dine

Du har to passord på en kryptert installasjon: det som låser opp disken ved oppstart, og det du logger inn og bruker `sudo` med. Oppsettet gjør dem like. Begge kan endres under _Oppdater > Passord_ i Omarchy-menyen — _Diskkryptering_ for det første, _Bruker_ for det andre. Å endre diskpassordet ber om det nåværende først, så ha det klart. Hvis en endring blir avbrutt, kjør _Diskkryptering_ igjen: den ber om passordet som låser opp disken nå og fullfører endringen.

## Gi videre en maskin du allerede har brukt

Hvis du gir maskinen din videre til noen andre, trenger du ikke å installere den på nytt. Kjør _Fjern > Fabrikktilbakestilling_ i Omarchy-menyen, skriv `reset` for å bekrefte, og start på nytt. Det sletter hver brukerkonto og alt i `/home`, kaster alle pakkene og systemendringene du har gjort siden installasjonen, og fjerner maskinens identitet — nettverkstilkoblinger, vertsnøkler og alt. Det som kommer opp igjen, er oppsettsveiviseren fra første oppstart, klar for at den nye eieren kan skrive inn sitt eget navn, passord og krypteringspassord.

Det fungerer ved å gjenopprette baseline-øyeblikksbildet installasjonsprogrammet tar, så det er bare tilgjengelig på maskiner installert fra Omarchy ISO-en. Og på en disk uten kryptering er en tilbakestilling sletting snarere enn en sikker sletting, så hvis dataene var sensitive, gjør en fersk installasjon i stedet.

## Passordløs sudo

Noen ganger vil du at `sudo` skal slutte å spørre, oftest når en AI-agent gjør en lang strekning med systemarbeid for deg. _Oppsett > Sikkerhet > Passordløs sudo_ spør hvor lenge tilgangen skal tillates: **15 minutter**, **1 time**, **1 dag**, eller **Permanent**. Et rødt advarselsikon vises ved siden av de andre menylinjeindikatorene mens tilgangen er aktiv. Klikk på det eller kjør kommandoen igjen for å slå tilgangen av. Du kan også angi ditt eget antall minutter (fra 1 til 1440) med `omarchy-sudo-passwordless 30`, eller bruke `omarchy-sudo-passwordless permanent`.

Tidsbegrenset tilgang utløper automatisk, inkludert umiddelbart etter gjenopptak fra en dvale som krysset fristen. Å starte datamaskinen på nytt avslutter den tidlig. Permanent tilgang overlever omstarter og forblir aktivert til du deaktiverer den.

Å oppdatere eller fjerne Omarchys innstillingspakke avslutter enhver midlertidig tildeling før støtten for utløp endres. Hvis kommandoen rapporterer en autorisasjons- eller oppryddingsfeil, løs den før du prøver å aktivere en annen tildeling; en feil betyr ikke at passordløs tilgang er inaktiv.

Vær klarøyd om denne: mens den er på, kan alt som kjører som din bruker, gjøre alt som root uten å bli spurt. Det er hele poenget, og det er også hele risikoen.

## Signeringsnøkler

Den offentlige nøkkelen for alle ISO-signaturer og Omarchy-repo-pakker er `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifiser på openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakken `omarchy/omarchy-keyring` inneholder også denne og vil bli brukt til å rulle ut eventuelle oppdateringer sømløst.

Du kan finne signaturen for enhver ISO-utgivelse ved å legge til `.sig` til URL-en dens, som `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
