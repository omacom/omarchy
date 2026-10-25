# Sikkerhed

Omarchy tager sikkerhed ekstremt alvorligt. Dette skal være et operativsystem, som du kan bruge til at udføre _Rigtigt Arbejde_ i den _Virkelige Verden_. Hvor det at miste en bærbar computer ikke kan føre til en sikkerhedsnødsituation. Så her er, hvad vi gør:

1. *Fuld diskkryptering er obligatorisk*: Dette er det vigtigste skridt til at sikre den fysiske beskyttelse af dine data. Hvis din computer bliver væk eller stjålet, er dataene fuldt krypterede ved hjælp af standard LUKS (Linux Unified Key Setup).
2. *Firewall er aktiveret som standard*: Al indgående trafik blokeres som standard undtagen port 53317 til [LocalSend](https://localsend.org/). Selv ssh er slået fra, indtil du slår det til via _Opsætning > Sikkerhed > SSHD_, som åbner port 22 (hastighedsbegrænset mod brute force) som en del af opsætningen. Vi låser endda Docker-adgang ned ved hjælp af [ufw-docker](https://github.com/chaifeng/ufw-docker)-opsætningen for at forhindre, at dine containere ved et uheld bliver eksponeret for verden.
3. *Arch har altid de nyeste opdateringer*: Arch, den underliggende distro, som Omarchy er bygget på, er en rullende distribution. Det betyder, at enhver sikkerhedssårbarhed, der opdages og rettes i en pakke, hurtigt er tilgængelig til installation ved hjælp af `omarchy-update`. På den måde kører du altid de nyeste og mest sikre versioner af alt.
4. *Omarchy vedligeholder sine egne pakker og sit eget spejl*: Omarchy er som standard kun afhængig af pakker fra Archs egne core/extra/multilib-repositorier og sit eget Omarchy Package Repository. Du kan installere software direkte fra AUR, men basisinstallationen gør det ikke — kun nogle få valgfrie installationer, som tredjepartsbrowserne, henter fra AUR.
5. *Cloudflare beskytter os mod DDoS*: Omarchys distributionsinfrastruktur — ISO'erne, Omarchy-pakkerne, Arch-spejlet — er beskyttet bag Cloudflares formidable DDoS-skjold og hostet på deres CDN. Dette giver fremragende tilgængelighed.

## Ændring af dine adgangskoder

Du har to adgangskoder på en krypteret installation: den, der låser drevet op ved opstart, og den, du logger ind og bruger `sudo` med. Opsætningen gør dem ens. Begge kan ændres under _Opdatering > Adgangskode_ i Omarchy-menuen — _Drevkryptering_ for den første, _Bruger_ for den anden. Ændring af drevadgangskoden beder først om den nuværende, så hav den ved hånden. Hvis en ændring bliver afbrudt, skal du køre _Drevkryptering_ igen: den beder om den adgangskode, der låser drevet op nu, og fuldfører ændringen.

## Videregivelse af en maskine, du allerede har brugt

Hvis du overdrager din maskine til en anden, behøver du ikke at geninstallere den. Kør _Opsætning > Nulstil computer_ i Omarchy-menuen, skriv `reset` for at bekræfte, og genstart. Det sletter hver eneste brugerkonto og alt i `/home`, smider alle de pakker og systemændringer væk, som du har foretaget siden installationen, og rydder maskinens identitet — netværksforbindelser, værtsnøgler og det hele. Det, der kommer op igen, er opsætningsguiden fra den første opstart, klar til at dens nye ejer kan indtaste sit eget navn, sin egen adgangskode og sin egen krypteringsadgangskode.

Det fungerer ved at gendanne det grundlæggende snapshot, som installationsprogrammet tager, så det er kun tilgængeligt på maskiner, der er installeret fra Omarchy ISO'en. Og på et drev uden kryptering er en nulstilling sletning snarere end en sikker sletning, så hvis dataene var følsomme, skal du i stedet foretage en frisk installation.

## Sudo uden adgangskode

Nogle gange vil du have `sudo` til at holde op med at spørge, oftest når en AI-agent udfører et langt stykke systemarbejde for dig. _Opsætning > Sikkerhed > Sudo uden adgangskode_ spørger, hvor længe adgangen skal tillades: **15 minutter**, **1 time**, **1 dag** eller **Permanent**. Et rødt advarselsikon vises ved siden af de andre indikatorer på menulinjen, mens adgangen er aktiv. Klik på det, eller kør kommandoen igen for at slå adgangen fra. Du kan også angive dit eget antal minutter (fra 1 til 1440) med `omarchy-sudo-passwordless 30` eller bruge `omarchy-sudo-passwordless permanent`.

Tidsbegrænset adgang udløber automatisk, herunder umiddelbart efter genoptagelse fra en dvale, der overskred fristen. Genstart af computeren afslutter den før tid. Permanent adgang overlever genstarter og forbliver aktiveret, indtil du deaktiverer den.

Opdatering eller fjernelse af Omarchys indstillingspakke afslutter enhver midlertidig tildeling, før dens understøttelse af udløb ændres. Hvis kommandoen rapporterer en autorisations- eller oprydningsfejl, skal du løse den, før du prøver at aktivere en anden tildeling; en fejl betyder ikke, at adgang uden adgangskode er inaktiv.

Vær klarøjet omkring denne: mens den er slået til, kan alt, der kører som din bruger, gøre alt som root uden at blive spurgt. Det er hele pointen, og det er også hele risikoen.

## Signeringsnøgler

Den offentlige nøgle til alle ISO-signaturer og Omarchy-repo-pakker er `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([bekræft på openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakken `omarchy/omarchy-keyring` indeholder også denne og vil blive brugt til problemfrit at udrulle eventuelle potentielle opdateringer.

Du kan finde signaturen til enhver ISO-udgivelse ved at tilføje `.sig` til dens URL, som `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
