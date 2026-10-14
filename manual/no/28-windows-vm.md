# Windows-VM

Omarchy tilbyr en enkel måte å kjøre Windows via en Docker-VM på. Du kan installere den med _Installer > Windows_ fra Omarchy-menyen (`Super + Space`).

Maskinen din trenger KVM-virtualisering for dette, noe de fleste har — men den er noen ganger slått av i BIOS, og installasjonsprogrammet forteller deg det hvis det er tilfellet. Du vil også trenge diskplassen: hva enn du gir Windows, pluss ca. 10GB til selve avbildingen.

Installasjonsprogrammet spør hvor mye RAM, hvor mange CPU-kjerner og hvor mye disk det skal overlevere (64GB eller mer er et fornuftig minimum), deretter om et Windows-brukernavn og -passord. La dem stå tomme, så får du `docker` / `admin`. Nedlastingen tar en stund — 10–15 minutter er normalt — og du kan følge fremdriften i nettleseren på `http://127.0.0.1:8006`. Nettleseren ber om samme brukernavn og passord før den åpner konsollen.

 ![windows-vm](images/windows-vm.webp)

## Bruke den

Når den er installert, start _Windows_ fra appstarteren. Det starter VM-en hvis den ikke allerede kjører, og kopler deg til over RDP i fullskjerm. Gi den 15–30 sekunder på en kaldstart.

RDP-økten bærer lyd, mikrofonen din og en delt utklippstavle, så kopiering av tekst mellom Linux og Windows bare fungerer. Oppløsningen følger vinduet ditt, og Omarchy sender skjermskaleringen din gjennom, så det ikke er et uskarpt rot på en HiDPI-skjerm.

Når du lukker RDP-vinduet, slås VM-en av automatisk. Hvis du heller vil la den kjøre — si du har noe i gang der inne — start den med `omarchy windows vm launch --keep-alive` i stedet.

Resten av kontrollene er på samme kommando:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Dele filer

Mappen `~/Windows` i hjemmemappen din deles automatisk med VM-en. Legg filer der hvis du vil at de skal være tilgjengelige for Windows. VM-en har ingen tilgang til noen annen del av filsystemet ditt, så du er trygg mot alt stygt på Windows-siden. Dens egen virtuelle disk er tilgjengelig på `~/.windows`.

De velkjente hjemmestiene holder seg på sine egne filsystemer. De kan også være symlenker til mapper du eier, noe som er nyttig når den virtuelle disken bor på en større disk. Installasjonsprogrammet måler ledig plass på filsystemet som faktisk inneholder `~/.windows`, ikke nødvendigvis filsystemet som inneholder hjemmemappen din.

Hold disk- og delestiene som separate, ikke-overlappende mapper. Fjerning tømmer diskmappen med vilje, men bevarer delingsmappen. Umiddelbart før sletting utfører Omarchy en avgrenset inneslutningssjekk og nekter å fjerne noe hvis sjekken går til tidsavbrudd eller ikke kan bevise at de to trærne er separate.

Før VM-en starter, åpner og fester Omarchy de to mappene, og bind-monterer deretter de nøyaktige mappe-inodene på private per-bruker-ankere under `/var/lib/omarchy/windows/mounts`. Docker ser bare de root-beskyttede ankerne. Dette bevarer egendefinerte diskplasseringer samtidig som det hindrer en annen prosess som kjører som deg fra å bytte ut en sjekket sti før den privilegerte containeren bruker den. Eksisterende disk- og delingsmapper strammes til modus `0700` under migrering, slik at andre lokale kontoer ikke kan bla i innholdet.

VM-ens porter er kun bundet til localhost, så ingenting på nettverket ditt kan nå Windows-maskinen. Webkonsollen krever også det konfigurerte Windows-brukernavnet og -passordet, noe som hindrer en annen lokal konto fra å styre VM-en gjennom port 8006.

## Grenser og lisensiering

Det finnes ingen GPU-gjennomføring med dette oppsettet, så det egner seg ikke til spilling eller videoredigering. Det er en flott måte å kjøre Microsoft Office eller hva annet du absolutt må ha.

Versjonen som installeres er Windows 11 Pro, uaktivert. Du trenger din egen lisensnøkkel for å bruke de stengte funksjonene.

Hvis denne datamaskinen ble levert med Windows, er OEM-nøkkelen fortsatt i fastvaren selv etter installasjon av Omarchy. Skriv den ut med `omarchy windows key`. Den nøkkelen er bundet til denne maskinen — den aktiverer Windows installert på nytt på denne maskinvaren, men den aktiverer vanligvis ikke VM-en.

Du kan endre ressurstildelingen senere ved å kjøre `omarchy-windows-vm install` på nytt, som skriver om VM-ens konfigurasjon fra svarene dine. Selve compose-filen bor nå på `/var/lib/omarchy/windows/docker-compose.yml` og eies av root — det er med vilje, slik at en prosess som kjører som deg ikke kan skrive den om og få den privilegerte oppstarten til å montere hele disken din i containeren. Hvis du må redigere den for hånd (for eksempel for å montere en USB-enhet), rediger den med `sudo` og se alle valgene på [Dockur Windows-prosjektet](https://github.com/dockur/windows).

For å kvitte deg med hele greia, bruk _Fjern > Windows_ fra Omarchy-menyen. Det sletter VM-ens disk og alle dataene, så sørg for at alt du bryr deg om er ute av `~/Windows` først.
