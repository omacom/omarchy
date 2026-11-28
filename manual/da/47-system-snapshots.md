# Systemsnapshots

Vi opretter snapshots automatisk ved hver Omarchy-opdatering, men hvis du vil oprette dit eget, kan du bruge `omarchy-snapshot create`.

Hvordan du starter og gendanner et snapshot, afhænger af den bootloader, din maskine starter med. Nye UEFI-installationer bruger systemd-boot; ældre installationer og BIOS-maskiner bruger Limine. `omarchy-boot-backend` fortæller dig, hvilken du har.

## Med systemd-boot

Vælg _System > Snapshots_ i Omarchy-menuen, og vælg det snapshot, du vil starte i. Maskinen genstarter i det én gang. Eller hold Space nede, mens maskinen starter, for at se bootmenuen, hvor hvert snapshot er listet med det nyeste først sammen med dets Omarchy-version og dato.

Et snapshot starter med et midlertidigt lag ovenpå, så du kan bruge det som normalt, men alt, hvad du ændrer, er væk ved næste genstart. For at beholde det skal du gøre det til dit system: klik på den notifikation, der vises, når du logger ind, vælg _System > Snapshots > Restore This Snapshot_, eller kør `omarchy-snapshot restore`. Gendannelsen sker, mens maskinen genstarter. Systemet, som det var før, forbliver i bootmenuen som _Before restore_, og `omarchy-snapshot restore backup` sætter det tilbage igen.

Fra terminalen:

- `omarchy-snapshot list` viser de snapshots, du kan starte;
- `omarchy-snapshot boot 12` genstarter i snapshot 12 én gang;
- `omarchy-snapshot restore 12` gør snapshot 12 til systemet ved næste genstart, og `omarchy-snapshot restore --cancel` ombestemmer dig før den genstart.

## Med Limine

For at starte og gendanne et snapshot vælger du det fra Limine-bootloaderen. Bootmenuen er skjult som standard, så tryk på en vilkårlig tast, så snart Limine starter, for at få den frem.

Fra den skærm vælger du det snapshot, du vil starte i, ud fra dato og version. Den version af Omarchy, der var gældende på tidspunktet for snapshotet, kan ses i nederste venstre hjørne.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Når du er kommet ind, dukker der en notifikation op, som fortæller dig, at du er i et startbart snapshot, og hvis du klikker på den, starter gendannelsesprocessen. Alternativt kan du bruge `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## Hvad en gendannelse dækker

En gendannelse bringer dit root-filsystem tilbage, men ikke dit `/home`. Så det virker til at rulle en ødelagt systemopdatering tilbage, men ikke til at gendanne mistede personlige filer.

Det betyder også, at dit `~/.config`-bibliotek forbliver, som det er. Så hvis du ruller tilbage til en tidligere version af et bibliotek eller et program, der gemmer konfigurationsfiler i et nyt format, må du ordne det manuelt.

Det samme gælder Omarchys egen registrering af, hvilke migrationer der allerede er kørt: den ligger i dit hjemmebibliotek, så den overlever gendannelsen. Migrationer, der kørte, efter snapshotet blev taget, forbliver markeret som udført, selvom de ændringer, de lavede i root-filsystemet, er blevet rullet tilbage, og den næste `omarchy update` vil ikke køre dem igen. Så hvis du opdaterer igen efter en gendannelse, og noget, som en tidligere opdatering havde sat op, stadig mangler, er det den sandsynlige årsag.
