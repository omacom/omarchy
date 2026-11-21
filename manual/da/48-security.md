# Sikkerhed

Omarchy tager sikkerhed ekstremt alvorligt. Dette er ment til at være et operativsystem, som du kan bruge til at udføre _Rigtigt Arbejde_ i den _Virkelige Verden_. Hvor det at miste en bærbar computer ikke kan føre til en sikkerhedsnødsituation. Så her er, hvad vi gør:

1. *Fulddiskkryptering er slået til som standard*: Dette er det vigtigste skridt til at sikre den fysiske beskyttelse af dine data. Hvis din computer bliver væk eller stjålet, er dataene fuldt krypteret ved hjælp af standard LUKS (Linux Unified Key Setup). Installationsprogrammet lader dig fravælge det til engangsmaskiner (se [Kom godt i gang](02-getting-started.md)); en installation uden kryptering har ingen af denne beskyttelse, og enhver, der har drevet i hånden, kan læse det.
2. *Firewallen er aktiveret som standard*: Al indgående trafik blokeres som standard, med nogle få undtagelser: port 53317 til [LocalSend](https://localsend.org/); DNS-forespørgsler til computerens egen resolver på Docker bridge-adressen (172.17.0.1), accepteret fra de private adresseområder, Docker giver sine containers; og multicast DNS (port 5353), som lader printere og andre enheder på dit netværk finde hinanden og også annoncerer din computers navn der. Oven i det beholder firewallen UFW's standardtilladelser til ping, til at få en adresse fra din router (DHCP) og til UPnP-opdagelse. Selv ssh er slået fra, indtil du slår det til via _Setup > Security > SSHD_, som autoriserer din SSH-nøgle, slår adgangskodelogins fra og først derefter åbner port 22 (hastighedsbegrænset mod brute force). Vi låser endda Docker-adgangen ned ved hjælp af [ufw-docker](https://github.com/chaifeng/ufw-docker)-opsætningen for at forhindre, at dine containers ved et uheld bliver eksponeret for verden.
3. *Arch har altid de nyeste opdateringer*: Arch, den underliggende distro, som Omarchy er bygget på, er en rullende distribution. Det betyder, at enhver sikkerhedssårbarhed, der opdages og rettes i en pakke, hurtigt er tilgængelig til installation ved hjælp af `omarchy-update`. På den måde kører du altid de nyeste, mest sikre versioner af alt.
4. *Omarchy vedligeholder sine egne pakker og sit eget spejl*: Omarchy bruger som standard kun pakker fra Arch's egne core/extra/multilib-repositories (Arch Linux ARM's på ARM-maskiner, plus Asahi ALARM på Apple Silicon) og sit eget Omarchy Package Repository. Du kan installere software direkte fra AUR, men basisinstallationen gør det ikke — kun nogle få valgfrie installationer, som tredjepartsbrowserne, henter fra AUR.
5. *Cloudflare beskytter os mod DDoS*: Omarchys distributionsinfrastruktur — ISO'erne, Omarchy-pakkerne, Arch-spejlet — er beskyttet bag Cloudflares formidable DDoS-skjold og hostet på deres CDN. Det giver fremragende tilgængelighed.

## Sådan ændrer du dine adgangskoder

Du har to adgangskoder på en krypteret installation: den, der låser drevet op ved opstart, og den, du logger ind og bruger `sudo` med. Opsætningen gør dem til den samme. Begge kan ændres under _Update > Password_ i Omarchy-menuen — _Drive Encryption_ for den første, _User_ for den anden. Ændring af drevets adgangskode beder først om den nuværende, så hav den ved hånden. Hvis en ændring afbrydes, så kør _Drive Encryption_ igen: den beder om den adgangskode, der låser drevet op nu, og gennemfører ændringen.

## Videregivelse af en maskine, du allerede har brugt

Hvis du overdrager din maskine til en anden, behøver du ikke at geninstallere den. Kør _Remove > Factory Reset_ i Omarchy-menuen, skriv `reset` for at bekræfte, indtast din drevkrypteringsadgangskode, hvis du bliver bedt om det, og genstart. Det sletter hver eneste brugerkonto og alt i `/home`, smider alle de pakker og systemændringer væk, du har foretaget siden installationen, og rydder maskinens identitet — netværksforbindelser, host keys og det hele. Det, der starter op igen, er opsætningsguiden fra første opstart, klar til, at dens nye ejer kan indtaste sit eget navn, sin egen adgangskode og krypteringsadgangskode.

Det fungerer ved at gendanne det baseline-snapshot, installationsprogrammet tager, så det er kun tilgængeligt på maskiner, der er installeret fra Omarchy ISO'en. Og på et drev uden kryptering er en nulstilling sletning snarere end en sikker sletning, så hvis dataene var følsomme, så foretag en frisk installation i stedet.

## sudo uden adgangskode

Nogle gange vil du have `sudo` til at holde op med at spørge, oftest når en AI-agent udfører et langt stykke systemarbejde for dig. _Setup > Security > Passwordless Sudo_ spørger, hvor længe adgangen skal tillades: **15 minutter**, **1 time**, **1 dag** eller **Permanent**. Et rødt advarselsikon vises ved siden af de andre indikatorer på menulinjen, mens adgangen er aktiv. Klik på det, eller kør kommandoen igen for at slå adgangen fra. Du kan også angive dit eget antal minutter (fra 1 til 1440) med `omarchy-sudo-passwordless 30` eller bruge `omarchy-sudo-passwordless permanent`.

Tidsbegrænset adgang udløber automatisk, herunder straks efter genoptagelse fra en suspendering, der overskred fristen. Genstart af computeren afslutter den før tid. Permanent adgang overlever genstarter og forbliver aktiveret, indtil du deaktiverer den.

Opdatering eller fjernelse af Omarchys indstillingspakke afslutter enhver midlertidig tildeling, før dens understøttelse af udløb ændres. Hvis kommandoen rapporterer en autorisations- eller oprydningsfejl, skal du løse den, før du forsøger at aktivere en anden tildeling; en fejl betyder ikke, at adgangen uden adgangskode er inaktiv.

Vær klarøjet omkring denne: mens den er slået til, kan alt, der kører som din bruger, gøre alt som root uden at blive spurgt. Det er hele pointen, og det er også hele risikoen.

## Signeringsnøgler

Den offentlige nøgle til alle ISO-signaturer og Omarchy repo-pakken er `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([bekræft på openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakken `omarchy/omarchy-keyring` indeholder også denne og vil blive brugt til problemfrit at udrulle eventuelle potentielle opdateringer.

Du kan finde signaturen for enhver ISO-udgivelse ved at tilføje `.sig` til dens URL, som `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
