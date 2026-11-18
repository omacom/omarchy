# Windows VM

Omarchy tilbyder en nem måde at køre Windows gennem en Docker VM. Du kan installere den ved hjælp af _Installer > Windows_ fra Omarchy-menuen (`Super + Space`).

Din maskine skal bruge KVM-virtualisering til dette, hvilket de fleste gør — men det er nogle gange slået fra i BIOS, og installationsprogrammet vil fortælle dig, hvis det er tilfældet. Du vil også ønske diskpladsen: hvad du end giver Windows, plus omkring 10GB til selve imaget.

Installationsprogrammet spørger, hvor meget RAM, hvor mange CPU-kerner og hvor meget disk der skal overdrages (64GB eller mere er det fornuftige minimum), derefter efter et Windows-brugernavn og en adgangskode. Lad dem stå tomme, og du får `docker` / `admin`. Downloadet tager et stykke tid — 10-15 minutter er normalt — og du kan følge fremskridtene i browseren på `http://127.0.0.1:8006`. Browseren beder om det samme brugernavn og den samme adgangskode, før den åbner konsollen.

 ![windows-vm](images/windows-vm.webp)

## Bruge den

Når den er installeret, skal du starte _Windows_ fra app-starteren. Det starter VM'en, hvis den ikke allerede kører, og forbinder dig via RDP i fuld skærm. Giv den 15-30 sekunder ved en kold start.

RDP-sessionen bærer lyd, din mikrofon og en delt udklipsholder, så kopiering af tekst mellem Linux og Windows bare virker. Opløsningen følger dit vindue, og Omarchy sender din skærmskalering igennem, så det ikke er et sløret rod på en HiDPI-skærm.

Når du lukker RDP-vinduet, lukker VM'en automatisk ned. Hvis du hellere vil lade den køre — lad os sige, at du har noget, der arbejder derinde — så start den i stedet med `omarchy windows vm launch --keep-alive`.

Resten af kontrollerne er på den samme kommando:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Dele filer

Mappen `~/Windows` i din hjemmemappe deles automatisk med VM'en. Læg filer der, hvis du vil have dem tilgængelige for Windows. VM'en har ingen adgang til nogen anden del af dit filsystem, så du er sikker mod alt grimt på Windows-siden. Dens egen virtuelle disk er tilgængelig på `~/.windows`.

De velkendte hjemmestier forbliver på deres egne filsystemer. De kan også være symlinks til mapper, du ejer, hvilket er nyttigt, når den virtuelle disk lever på et større drev. Installationsprogrammet måler ledig plads på det filsystem, der faktisk indeholder `~/.windows`, ikke nødvendigvis det filsystem, der indeholder din hjemmemappe.

Hold disk- og delestierne som separate, ikke-overlappende mapper. Fjernelse tømmer bevidst diskmappen, men bevarer den delte mappe. Umiddelbart før sletning udfører Omarchy et begrænset indeslutningstjek og nægter at fjerne noget, hvis det tjek timer ud eller ikke kan bevise, at de to træer er adskilte.

Før VM'en starter, åbner og fastgør Omarchy de to mapper og bind-monterer derefter de nøjagtige mappe-inoder på private ankre pr. bruger under `/var/lib/omarchy/windows/mounts`. Docker ser kun de root-beskyttede ankre. Dette bevarer brugerdefinerede diskplaceringer, mens det forhindrer en anden proces, der kører som dig, i at bytte en tjekket sti ud, før den privilegerede container forbruger den. Eksisterende disk- og delte mapper strammes til tilstanden `0700` under migreringen, så andre lokale konti ikke kan gennemse deres indhold.

VM'ens porte er kun bundet til localhost, så intet på dit netværk kan nå Windows-maskinen. Webkonsollen kræver også det konfigurerede Windows-brugernavn og den konfigurerede adgangskode, hvilket forhindrer en anden lokal konto i at styre VM'en gennem port 8006.

## Grænser og licensering

Der er ingen GPU-passthrough med denne opsætning, så den er ikke egnet til gaming eller videoredigering. Det er en fantastisk måde at køre Microsoft Office eller hvad du ellers absolut må have.

Den installerede version er Windows 11 Pro, uaktiveret. Du skal bruge din egen licensnøgle for at bruge de låste funktioner.

Hvis denne computer blev leveret med Windows, er OEM-nøglen stadig i firmwaren, selv efter installation af Omarchy. Udskriv den med `omarchy windows key`. Den nøgle er bundet til denne maskine — den vil aktivere Windows geninstalleret på denne hardware, men den vil normalt ikke aktivere VM'en.

Du kan ændre ressourceallokeringen senere ved at køre `omarchy-windows-vm install` igen, hvilket omskriver VM'ens konfiguration fra dine svar. Selve compose-filen lever nu på `/var/lib/omarchy/windows/docker-compose.yml` og ejes af root — det er bevidst, så en proces, der kører som dig, ikke kan omskrive den og få den privilegerede opstart til at montere hele din disk i containeren. Hvis du har brug for at redigere den i hånden (for eksempel for at montere en USB-enhed), skal du redigere den med `sudo` og se alle mulighederne på [Dockur Windows-projektet](https://github.com/dockur/windows).

For at slippe af med det hele skal du bruge _Fjern > Windows_ fra Omarchy-menuen. Det sletter VM'ens disk og alle dens data, så sørg for, at alt, hvad du holder af, er ude af `~/Windows` først.
