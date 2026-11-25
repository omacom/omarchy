# Windows VM

Omarchy tilbyder en nem måde at køre Windows på gennem en Docker VM på x86_64-maskiner. Du kan installere den ved hjælp af _Install > Windows_ fra Omarchy-menuen (`Super + Space`).

Din maskine skal bruge KVM-virtualisering til dette, hvilket de fleste gør — men det er nogle gange slået fra i BIOS, og installationsprogrammet vil fortælle dig, hvis det er tilfældet. Du vil også gerne have diskpladsen: hvad end du giver Windows, plus omkring 10GB til selve imaget.

Installationsprogrammet spørger, hvor meget RAM, hvor mange CPU-kerner og hvor meget disk der skal gives videre (64GB eller mere er det fornuftige minimum), derefter om et Windows-brugernavn og en adgangskode. Lad dem stå tomme, og du får `docker` / `admin`. Downloaden tager et stykke tid — 10-15 minutter er normalt — og du kan følge fremskridtet i browseren på `http://127.0.0.1:8006`. Browseren beder om det samme brugernavn og den samme adgangskode, før konsollen åbnes.

 ![windows-vm](images/windows-vm.webp)

## Sådan bruger du den

Når den er installeret, skal du starte _Windows_ fra appstarteren. Det starter VM'en, hvis den ikke allerede kører, og forbinder dig via RDP i fuld skærm. Giv den 15-30 sekunder ved en kold start.

RDP-sessionen medbringer lyd, din mikrofon og et delt udklipsholder, så kopiering af tekst mellem Linux og Windows bare virker. Opløsningen følger dit vindue, og Omarchy sender din skærmskalering videre, så det ikke er et sløret rod på en HiDPI-skærm.

Når du lukker RDP-vinduet, lukker VM'en automatisk ned. Hvis du hellere vil lade den køre — lad os sige, du har noget i gang derinde — så start den med `omarchy windows vm launch --keep-alive` i stedet.

Resten af kontrollerne er på den samme kommando:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Deling af filer

Mappen `~/Windows` i din hjemmemappe deles automatisk med VM'en. Læg filer der, hvis du vil have dem tilgængelige for Windows. VM'en har ikke adgang til nogen anden del af dit filsystem, så du er sikker mod alt grimt på Windows-siden. Dens egen virtuelle disk er tilgængelig på `~/.windows`.

De velkendte hjemmestier forbliver på deres egne filsystemer. De kan også være symlinks til mapper, du ejer, hvilket er nyttigt, når den virtuelle disk ligger på et større drev. Installationsprogrammet måler ledig plads på det filsystem, der faktisk indeholder `~/.windows`, ikke nødvendigvis det filsystem, der indeholder din hjemmemappe.

Hold disk- og delte stier som separate, ikke-overlappende mapper. Fjernelse tømmer bevidst diskmappen, men bevarer den delte mappe. Umiddelbart før sletning udfører Omarchy en afgrænset indeslutningskontrol og nægter at fjerne noget, hvis den kontrol får timeout eller ikke kan bevise, at de to træer er separate.

Før VM'en starter, åbner og fastholder Omarchy de to mapper, og bind-mounter derefter de nøjagtige mappe-inoder på private ankre pr. bruger under `/var/lib/omarchy/windows/mounts`. Docker ser kun de rod-beskyttede ankre. Dette bevarer brugerdefinerede diskplaceringer, samtidig med at det forhindrer en anden proces, der kører som dig, i at bytte en kontrolleret sti, før den privilegerede container bruger den. Eksisterende disk- og delte mapper strammes til tilstanden `0700` under migrering, så andre lokale konti ikke kan gennemse deres indhold.

VM'ens porte er kun bundet til localhost, så intet på dit netværk kan nå Windows-maskinen. Webkonsollen kræver også det konfigurerede Windows-brugernavn og adgangskode, hvilket forhindrer en anden lokal konto i at styre VM'en via port 8006.

## Begrænsninger og licensering

Der er ingen GPU-passthrough med denne opsætning, så den er ikke egnet til gaming eller videoredigering. Det er en fantastisk måde at køre Microsoft Office på, eller hvad du ellers absolut skal have.

Den installerede version er Windows 11 Pro, ikke aktiveret. Du skal bruge din egen licensnøgle for at bruge de låste funktioner.

Hvis denne computer blev leveret med Windows, er OEM-nøglen stadig i firmwaren, selv efter installation af Omarchy. Udskriv den med `omarchy windows key`. Den nøgle er bundet til denne maskine — den vil aktivere Windows geninstalleret på denne hardware, men den vil normalt ikke aktivere VM'en.

Du kan ændre ressourceallokeringen senere ved at køre `omarchy windows vm install` i en terminal, hvilket omskriver VM'ens konfiguration ud fra dine svar. Compose-filen selv bor nu på `/var/lib/omarchy/windows/docker-compose.yml` og ejes af root — det er bevidst, så en proces, der kører som dig, ikke kan omskrive den og få den privilegerede opstart til at mounte hele din disk ind i containeren. Hvis du har brug for at redigere den manuelt (for eksempel for at mounte en USB-enhed), så rediger den med `sudo` og se alle mulighederne på [Dockur Windows-projektet](https://github.com/dockur/windows).

For at slippe af med det hele skal du bruge _Remove > Windows_ fra Omarchy-menuen. Det sletter VM'ens disk i `~/.windows` og alt installeret inde i Windows, så kopiér alt, hvad du har brug for, ud af VM'en først. Din delte `~/Windows`-mappe lades i fred.
