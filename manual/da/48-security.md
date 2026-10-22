# Sikkerhed

Omarchy tager sikkerhed ekstremt alvorligt. Dette er ment til at være et operativsystem, du kan bruge til at lave _Rigtigt Arbejde_ i den _Virkelige Verden_. Hvor det at miste en bærbar ikke kan føre til en sikkerhedsnødsituation. Så her er, hvad vi gør:

1. *Fuld-disk-kryptering er obligatorisk*: Dette er det vigtigste skridt til at sikre den fysiske beskyttelse af dine data. Hvis din computer mistes eller stjæles, er dataene fuldt krypteret ved hjælp af standard LUKS (Linux Unified Key Setup).
2. *Firewall er aktiveret som standard*: Al indgående trafik blokeres som standard undtagen port 53317 til [LocalSend](https://localsend.org/). Selv ssh er slukket, indtil du tænder det via _Opsætning > Sikkerhed > SSHD_, som åbner port 22 (hastighedsbegrænset mod brute force) som en del af opsætningen. Vi låser endda Docker-adgang ned ved hjælp af [ufw-docker](https://github.com/chaifeng/ufw-docker)-opsætningen for at forhindre, at dine containere ved et uheld eksponeres for verden.
3. *Arch har altid de nyeste opdateringer*: Arch, den underliggende distro, Omarchy er bygget på, er en rullende distribution. Det betyder, at enhver sikkerhedssårbarhed, der opdages og patches i enhver pakke, hurtigt er tilgængelig til installation ved hjælp af `omarchy-update`. Du kører altid de nyeste, mest sikre versioner af alt på den måde.
4. *Omarchy vedligeholder sine egne pakker og mirror*: Omarchy er kun afhængig af pakker fra Archs egne core/extra/multilib-repositorier og sit eget Omarchy Pakke-repository som standard. Du kan installere software direkte fra AUR, men basisinstallationen gør det ikke — kun nogle få valgfrie installationer, som tredjepartsbrowserne, henter fra AUR.
5. *Cloudflare beskytter os mod DDoS*: Al Omarchy-distributionsinfrastruktur — ISO'erne, Omarchy-pakkerne, Arch-mirroret — er beskyttet bag Cloudflares formidable DDoS-skjold og hostet på deres CDN. Det giver superb tilgængelighed.

## Skift dine adgangskoder

Du har to adgangskoder på en krypteret installation: den, der låser drevet op ved opstart, og den, du logger ind og `sudo`'er med. Opsætningen gør dem ens. Begge kan ændres under _Opdater > Adgangskode_ i Omarchy-menuen — _Drevkryptering_ til den første, _Bruger_ til den anden. At skifte drevadgangskoden beder om den aktuelle først, så hav den klar. Hvis et skift afbrydes, så kør _Drevkryptering_ igen: den beder om adgangskoden, der låser drevet op nu, og fuldfører skiftet.

## Videregive en maskine, du allerede har brugt

Hvis du overgiver din maskine til en anden, behøver du ikke at geninstallere den. Kør _Opsætning > Nulstil computer_ i Omarchy-menuen, skriv `reset` for at bekræfte, og genstart. Det sletter enhver brugerkonto og alt i `/home`, smider alle de pakker og systemændringer væk, du har foretaget siden installationen, og rydder maskinens identitet — netværksforbindelser, værtsnøgler og alt. Det, der kommer tilbage op, er opsætningsguiden fra første opstart, klar til, at dens nye ejer kan indtaste deres eget navn, adgangskode og krypteringsadgangskode.

Det virker ved at gendanne baseline-snapshottet, installeren tager, så det kun er tilgængeligt på maskiner installeret fra Omarchy-ISO'en. Og på et drev uden kryptering er en nulstilling sletning frem for en sikker sletning, så hvis dataene var følsomme, så lav i stedet en frisk installation.

## Adgangskodeløs sudo

Nogle gange vil du have `sudo` til at holde op med at spørge, oftest når en AI-agent laver en lang strækning af systemarbejde for dig. _Opsætning > Sikkerhed > Adgangskodeløs Sudo_ spørger, hvor længe adgang skal tillades: **15 minutter**, **1 Time**, **1 Dag** eller **Permanent**. Et rødt advarselsikon vises ved siden af de andre menulinjeindikatorer, mens adgang er aktiv. Klik på det eller kør kommandoen igen for at slukke adgang. Du kan også angive dit eget antal minutter (fra 1 til 1440) med `omarchy-sudo-passwordless 30`, eller brug `omarchy-sudo-passwordless permanent`.

Tidsbegrænset adgang udløber automatisk, inklusive umiddelbart efter genoptagelse fra en hvile, der krydsede deadline. At genstarte computeren afslutter det tidligt. Permanent adgang overlever genstarter og forbliver aktiveret, indtil du deaktiverer den.

At opdatere eller fjerne Omarchys indstillingspakke afslutter enhver midlertidig tildeling, før dens udløbssupport ændres. Hvis kommandoen rapporterer en autorisations- eller oprydningsfejl, så løs den, før du forsøger at aktivere en anden tildeling; en fejl betyder ikke, at adgangskodeløs adgang er inaktiv.

Vær klarøjet omkring denne: mens den er tændt, kan alt, der kører som din bruger, gøre alt som root uden at blive spurgt. Det er hele pointen, og det er også hele risikoen.

## Signeringsnøgler

Den offentlige nøgle til alle ISO-signaturer og Omarchy-repo-pakker er `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verificér på openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakken `omarchy/omarchy-keyring` indeholder også denne og vil blive brugt til at udrulle eventuelle potentielle opdateringer sømløst.

Du kan finde signaturen til enhver ISO-udgivelse ved at tilføje .sig til URL'en. Ligesom https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
