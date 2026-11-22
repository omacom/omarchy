# Systemsnapshots

Vi oppretter snapshots automatisk ved hver Omarchy-oppdatering, men hvis du vil opprette dine egne, kan du bruke `omarchy-snapshot create`.

For å starte opp fra og gjenopprette et snapshot velger du det fra Limine-oppstartslasteren. Oppstartsmenyen er skjult som standard, så trykk på en hvilken som helst tast så snart Limine starter for å få den frem.

Fra den skjermen velger du snapshotet du vil starte opp i, basert på dato og versjon. Versjonen av Omarchy på tidspunktet snapshotet ble tatt, ser du nederst i venstre hjørne.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Når du kommer inn, dukker det opp et varsel som forteller deg at du er i et oppstartbart snapshot, og hvis du klikker på det, starter gjenopprettingsprosessen. Alternativt kan du bruke `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Dette gjenoppretter rotfilsystemet ditt, men ikke `/home`. Så det fungerer for å rulle tilbake en ødelagt systemoppdatering, men ikke for å gjenopprette tapte personlige filer.

Dette betyr også at `~/.config`-katalogen din beholdes som den er. Så hvis du ruller tilbake til en tidligere versjon av et bibliotek eller et program som lagrer konfigurasjonsfiler i et nytt format, må du ordne det manuelt.

Det samme gjelder Omarchys egen oversikt over hvilke migreringer som allerede har kjørt: den ligger i hjemmekatalogen din, så den overlever gjenopprettingen. Migreringer som kjørte etter at snapshotet ble tatt, forblir markert som fullført, selv om endringene de gjorde i rotfilsystemet har blitt rullet tilbake, og neste `omarchy update` vil ikke kjøre dem igjen. Så hvis du oppdaterer igjen etter en gjenoppretting og noe en tidligere oppdatering hadde satt opp, fortsatt mangler, er det den sannsynlige årsaken.

_Merk: Denne funksjonen er bare tilgjengelig på installasjoner som bruker Limine-oppstartslasteren, som har vært standard siden Omarchy 2.0. Den er ikke tilgjengelig hvis du bruker GRUB eller systemd-boot._
