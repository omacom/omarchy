# Øyeblikksbilder av systemet

Vi oppretter øyeblikksbilder automatisk ved hver Omarchy-oppdatering, men hvis du vil opprette ditt eget, kan du bruke `omarchy-snapshot create`.

For å starte opp fra og gjenopprette et øyeblikksbilde velger du det fra Limine-oppstartslasteren. (Hvis du for øyeblikket starter rett inn på Omarchy-dekrypteringsskjermen, må du først velge Limine som oppstartsalternativ via BIOS).

Fra den skjermen velger du øyeblikksbildet du vil starte opp fra, basert på dato og versjon. Versjonen av Omarchy på tidspunktet for øyeblikksbildet ser du nederst i venstre hjørne.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Når du kommer inn, dukker det opp et varsel som forteller deg at du er i et oppstartbart øyeblikksbilde, og hvis du klikker på det, starter gjenopprettingsprosessen. Alternativt kan du bruke `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Dette gjenoppretter rotfilsystemet ditt, men ikke `/home`. Så det fungerer for å rulle tilbake en ødelagt systemoppdatering, men ikke for å gjenopprette tapte personlige filer.

Dette betyr også at `~/.config`-mappen din blir værende som den er. Så hvis du ruller tilbake til en tidligere versjon av et bibliotek eller en applikasjon som lagrer konfigurasjonsfiler i et nytt format, må du ordne det manuelt.

Det samme gjelder Omarchys egen oversikt over hvilke migreringer som allerede har kjørt: den ligger i hjemmemappen din, så den overlever gjenopprettingen. Migreringer som kjørte etter at øyeblikksbildet ble tatt, forblir markert som ferdige, selv om endringene de gjorde i rotfilsystemet har blitt rullet tilbake, og neste `omarchy update` vil ikke kjøre dem på nytt. Så hvis du oppdaterer igjen etter en gjenoppretting og noe en tidligere oppdatering hadde satt opp fortsatt mangler, er det den sannsynlige grunnen.

_Merk: Denne funksjonen er bare tilgjengelig på installasjoner som bruker Limine-oppstartslasteren, som har vært standard siden Omarchy 2.0. Den er ikke tilgjengelig hvis du bruker GRUB eller systemd-boot._

### Hoppe over oppstartsmenyen

Hvis du aldri bruker oppstartsmenyen og bare vil at maskinen skal gå rett til dekrypteringsskjermen, kjører du _Setup > Direct Boot_ i Omarchy-menyen. Det legger til en EFI-oppføring som peker direkte på Omarchy, slik at fastvaren starter den uten å stoppe ved Limine.

Ulempen er den som er nevnt øverst: med direkte oppstart på betyr det å komme til et øyeblikksbilde at du først må velge Limine fra BIOS-oppstartsmenyen. Kjør _Setup > Direct Boot_ igjen for å fjerne oppføringen og gå tilbake til å starte via Limine. Noe fastvare liker ikke egendefinerte EFI-oppføringer, så oppsettet nekter å kjøre på fastvare fra American Megatrends og Apple.
