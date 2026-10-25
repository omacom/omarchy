# Sikkerhed

Omarchy tager sikkerhed ekstremt alvorligt. Det her skal være et operativsystem, du kan bruge til at lave _Rigtigt Arbejde_ i _Den Virkelige Verden_. Hvor det at miste en bærbar ikke kan føre til en sikkerhedsnødsituation. Så her er, hvad vi gør:

1. *Fulddiskkryptering er obligatorisk*: Dette er det vigtigste skridt til at sikre den fysiske beskyttelse af dine data. Hvis din computer bliver væk eller stjålet, er dataene fuldt krypterede med standard LUKS (Linux Unified Key Setup).
2. *Firewall er aktiveret som standard*: Al indgående trafik blokeres som standard, undtagen port 53317 til [LocalSend](https://localsend.org/). Selv ssh er slået fra, indtil du slår det til via _Setup > Security > SSHD_, som åbner port 22 (hastighedsbegrænset mod brute force) som en del af opsætningen. Vi låser endda Docker-adgang ned ved hjælp af [ufw-docker](https://github.com/chaifeng/ufw-docker)-opsætningen for at forhindre, at dine containere ved et uheld bliver eksponeret for verden.
3. *Arch har altid de nyeste opdateringer*: Arch, den underliggende distro, som Omarchy er bygget på, er en rolling distribution. Det betyder, at enhver sikkerhedssårbarhed, der bliver opdaget og rettet i en pakke, hurtigt bliver tilgængelig til installation med `omarchy-update`. På den måde kører du altid de nyeste, mest sikre versioner af alt.
4. *Omarchy vedligeholder sine egne pakker og sit eget mirror*: Omarchy bruger som standard kun pakker fra Archs egne core/extra/multilib-repositories og sit eget Omarchy Package Repository. Du kan installere software direkte fra AUR, men basisinstallationen gør det ikke — kun nogle få valgfrie installationer, som tredjepartsbrowserne, henter fra AUR.
5. *Cloudflare beskytter os mod DDoS*: Omarchys distributionsinfrastruktur — ISO'erne, Omarchy-pakkerne, Arch-mirrored — er beskyttet bag Cloudflares formidable DDoS-skjold og hostes på deres CDN. Det giver fremragende tilgængelighed.

## Ændring af dine adgangskoder

Du har to adgangskoder på en krypteret installation: den, der låser drevet op ved opstart, og den, du logger ind og bruger `sudo` med. Opsætningen gør dem til den samme. Begge kan ændres under _Update > Password_ i Omarchy-menuen — _Drive Encryption_ til den første, _User_ til den anden. Ændring af drevadgangskoden beder først om den nuværende, så hav den ved hånden. Hvis en ændring bliver afbrudt, så kør _Drive Encryption_ igen: den beder om den adgangskode, der låser drevet op nu, og gennemfører ændringen.

## Videregivelse af en maskine, du allerede har brugt

Hvis du afleverer din maskine til en anden, behøver du ikke at geninstallere den. Kør _Setup > Reset Computer_ i Omarchy-menuen, skriv `reset` for at bekræfte, og genstart. Det sletter hver eneste brugerkonto og alt i `/home`, smider alle de pakker og systemændringer væk, du har lavet siden installationen, og rydder maskinens identitet — netværksforbindelser, host keys og det hele. Det, der kommer op igen, er opsætningsguiden fra første opstart, klar til, at dens nye ejer kan indtaste sit eget navn, sin egen adgangskode og sin egen krypteringsadgangskode.

Det fungerer ved at gendanne det baseline-snapshot, som installationsprogrammet tager, så det er kun tilgængeligt på maskiner, der er installeret fra Omarchy ISO'en. Og på et drev uden kryptering er en nulstilling en sletning snarere end en sikker sletning, så hvis dataene var følsomme, skal du i stedet lave en frisk installation.

## Sudo uden adgangskode

Nogle gange vil du have `sudo` til at holde op med at spørge, oftest når en AI-agent udfører et langt stykke systemarbejde for dig. _Setup > Security > Passwordless Sudo_ spørger, hvor længe adgangen skal tillades: **15 minutter**, **1 Time**, **1 Dag** eller **Permanent**. Et rødt advarselsikon vises ved siden af de andre indikatorer på menulinjen, mens adgangen er aktiv. Klik på det eller kør kommandoen igen for at slå adgangen fra. Du kan også angive dit eget antal minutter (fra 1 til 1440) med `omarchy-sudo-passwordless 30`, eller bruge `omarchy-sudo-passwordless permanent`.

Tidsbegrænset adgang udløber automatisk, herunder umiddelbart efter genoptagelse fra en suspend, der krydsede fristen. Genstart af computeren afslutter den tidligt. Permanent adgang overlever genstarter og forbliver aktiveret, indtil du deaktiverer den.

Opdatering eller fjernelse af Omarchys indstillingspakke afslutter enhver midlertidig tildeling, før dens udløbsunderstøttelse ændres. Hvis kommandoen rapporterer en autorisations- eller oprydningsfejl, skal du løse den, før du forsøger at aktivere en anden tildeling; en fejl betyder ikke, at adgang uden adgangskode er inaktiv.

Vær klarøjet omkring den her: mens den er slået til, kan alt, der kører som din bruger, gøre alt som root uden at blive spurgt. Det er hele pointen, og det er også hele risikoen.

## Signeringsnøgler

Den offentlige nøgle til alle ISO-signaturer og Omarchy-repo-pakken er `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verificer på openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakken `omarchy/omarchy-keyring` indeholder også denne og vil blive brugt til problemfrit at udrulle eventuelle opdateringer.

Du kan finde signaturen til enhver ISO-udgivelse ved at tilføje .sig til URL'en. Som https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
