# Windows VM

Omarchy tilbyr en enkel måte å kjøre Windows på gjennom en Docker VM på x86_64-maskiner. Du kan installere den ved å bruke _Installer > Windows_ fra Omarchy-menyen (`Super + Space`).

Maskinen din trenger KVM-virtualisering for dette, noe de fleste har — men den er noen ganger slått av i BIOS, og installasjonsprogrammet vil fortelle deg det hvis det er tilfellet. Du vil også trenge diskplassen: det du gir til Windows, pluss omtrent 10GB til selve avbildningen.

Installasjonsprogrammet spør hvor mye RAM, hvor mange CPU-kjerner og hvor mye disk du vil gi den (64GB eller mer er den fornuftige nedre grensen), og deretter om et Windows-brukernavn og -passord. Lar du dem stå tomme, får du `docker` / `admin`. Nedlastingen tar en stund — 10-15 minutter er normalt — og du kan følge fremdriften i nettleseren på `http://127.0.0.1:8006`. Nettleseren ber om det samme brukernavnet og passordet før den åpner konsollen.

 ![windows-vm](images/windows-vm.webp)

## Slik bruker du den

Når den er installert, starter du _Windows_ fra programstarteren. Det starter VM-en hvis den ikke allerede kjører, og kobler deg til over RDP i fullskjerm. Gi den 15-30 sekunder ved kaldstart.

RDP-økten overfører lyd, mikrofonen din og en delt utklippstavle, så det å kopiere tekst mellom Linux og Windows bare fungerer. Oppløsningen følger vinduet ditt, og Omarchy sender skjermskaleringen din videre, så det ikke blir et uskarpt rot på en HiDPI-skjerm.

Når du lukker RDP-vinduet, slår VM-en seg av automatisk. Hvis du heller vil la den kjøre — for eksempel hvis du har noe som arbeider videre der inne — starter du den i stedet med `omarchy windows vm launch --keep-alive`.

Resten av kontrollene finner du på den samme kommandoen:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Deling av filer

Katalogen `~/Windows` i hjemmekatalogen din deles automatisk med VM-en. Legg filer der hvis du vil at de skal være tilgjengelige for Windows. VM-en har ikke tilgang til noen annen del av filsystemet ditt, så du er trygg for alt ekkelt på Windows-siden. Dens egen virtuelle disk er tilgjengelig på `~/.windows`.

Disse kjente hjemmestiene forblir på sine egne filsystemer. De kan også være symlinker til kataloger du eier, noe som er nyttig når den virtuelle disken ligger på en større disk. Installasjonsprogrammet måler ledig plass på filsystemet som faktisk inneholder `~/.windows`, ikke nødvendigvis filsystemet som inneholder hjemmekatalogen din.

Hold disk- og delingsstiene som separate kataloger som ikke overlapper. Fjerning tømmer diskkatalogen med vilje, men bevarer den delte katalogen. Rett før sletting utfører Omarchy en avgrenset inneslutningssjekk og nekter å fjerne noe som helst hvis den sjekken får tidsavbrudd eller ikke kan bevise at de to trærne er separate.

Før VM-en starter, åpner og fester Omarchy disse to katalogene, og bind-monterer deretter de nøyaktige katalog-inodene på private ankre per bruker under `/var/lib/omarchy/windows/mounts`. Docker ser bare disse root-beskyttede ankrene. Dette bevarer tilpassede diskplasseringer samtidig som det hindrer en annen prosess som kjører som deg, i å bytte ut en sjekket sti før den privilegerte containeren bruker den. Eksisterende disk- og delte kataloger strammes inn til modus `0700` under migrering, slik at andre lokale kontoer ikke kan bla gjennom innholdet deres.

Portene til VM-en er kun bundet til localhost, så ingenting på nettverket ditt kan nå Windows-maskinen. Webkonsollen krever også det konfigurerte Windows-brukernavnet og -passordet, noe som hindrer en annen lokal konto i å styre VM-en gjennom port 8006.

## Begrensninger og lisensiering

Det er ingen GPU-gjennomføring med dette oppsettet, så det egner seg ikke for spill eller videoredigering. Det er en flott måte å kjøre Microsoft Office på, eller hva annet du absolutt må ha.

Versjonen som installeres, er Windows 11 Pro, uaktivert. Du trenger din egen lisensnøkkel for å bruke de låste funksjonene.

Hvis denne datamaskinen ble levert med Windows, ligger OEM-nøkkelen fortsatt i firmware selv etter at du har installert Omarchy. Skriv den ut med `omarchy windows key`. Den nøkkelen er bundet til denne maskinen — den vil aktivere Windows som installeres på nytt på denne maskinvaren, men den vil vanligvis ikke aktivere VM-en.

Du kan endre ressurstildelingen senere ved å kjøre `omarchy windows vm install` i en terminal, noe som skriver VM-ens konfigurasjon på nytt ut fra svarene dine. Selve compose-filen ligger nå på `/var/lib/omarchy/windows/docker-compose.yml` og eies av root — det er med vilje, slik at en prosess som kjører som deg, ikke kan skrive den om og få den privilegerte oppstarten til å montere hele disken din i containeren. Hvis du trenger å redigere den for hånd (for eksempel for å montere en USB-enhet), redigerer du den med `sudo` og ser alle alternativene på [Dockur Windows-prosjektet](https://github.com/dockur/windows).

For å bli kvitt hele greia bruker du _Fjern > Windows_ fra Omarchy-menyen. Det sletter VM-ens disk i `~/.windows` og alt som er installert inne i Windows, så kopier alt du trenger ut av VM-en først. Den delte `~/Windows`-mappen din blir latt i fred.
