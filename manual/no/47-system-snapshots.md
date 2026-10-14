# Systemsnapshots

Vi oppretter snapshots automatisk ved hver Omarchy-oppdatering, men skulle du ønske å lage dine egne, kan du bruke `omarchy-snapshot create`.

For å starte opp og gjenopprette et snapshot velger du det fra Limine-bootloaderen. (Hvis du for øyeblikket starter rett inn i Omarchy-dekrypteringsskjermen, må du først velge Limine som et oppstartsalternativ via BIOS-en).

Fra den skjermen velger du snapshotet du vil starte opp i basert på dato og versjon. Versjonen av Omarchy på tidspunktet for snapshotet kan sees nederst i venstre hjørne.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Når du ankommer inni, vil et varsel sprette opp og varsle deg om at du er i et oppstartbart snapshot, og hvis du klikker på det, starter gjenopprettingsprosessen. Alternativt kan du bruke `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Dette vil gjenopprette rotfilsystemet ditt, men ikke `/home`. Så det fungerer for å angre en ødelagt systemoppdatering, men ikke for å gjenopprette tapte personlige filer.

Dette betyr også at `~/.config`-mappen din beholdes som den er. Så hvis du ruller tilbake til en tidligere versjon av et bibliotek eller en applikasjon som lagrer konfigurasjonsfiler i et nytt format, må du ordne det manuelt.

_Merk: Denne funksjonen er bare tilgjengelig på installasjoner som bruker Limine-bootloaderen, som har vært standard siden Omarchy 2.0. Den er ikke tilgjengelig hvis du er på GRUB eller systemd-boot._

### Hoppe over oppstartsmenyen

Hvis du aldri rører oppstartsmenyen og bare vil at maskinen skal gå rett til dekrypteringsskjermen, kjør _Oppsett > Direkte oppstart_ i Omarchy-menyen. Det legger til en EFI-oppføring som peker direkte på Omarchy, så firmwaren starter den uten å stoppe ved Limine.

Avveiningen er den som er nevnt øverst: med direkte oppstart på betyr det å komme til et snapshot at du først må velge Limine fra BIOS-oppstartsmenyen. Kjør _Oppsett > Direkte oppstart_ igjen for å fjerne oppføringen og gå tilbake til å starte opp gjennom Limine. Noen firmware tar ikke godt imot egendefinerte EFI-oppføringer, så oppsettet nekter å kjøre på American Megatrends- og Apple-firmware.
