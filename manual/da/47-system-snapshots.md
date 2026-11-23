# Systemsnapshots

Vi opretter automatisk snapshots ved hver Omarchy-opdatering, men hvis du vil oprette dine egne, kan du bruge `omarchy-snapshot create`.

For at starte op fra og gendanne et snapshot vælger du det i Limine-bootloaderen. Opstartsmenuen er skjult som standard, så tryk på en vilkårlig tast, så snart Limine starter, for at få den frem.

På den skærm vælger du det snapshot, du vil starte op i, ud fra dato og version. Den version af Omarchy, der var aktiv, da snapshottet blev taget, kan ses i nederste venstre hjørne.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Når du er kommet ind, dukker der en notifikation op, der fortæller dig, at du er i et snapshot, der kan startes op fra, og hvis du klikker på den, starter gendannelsesprocessen. Alternativt kan du bruge `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Dette gendanner dit rodfilsystem, men ikke dit `/home`. Så det virker til at rulle en ødelagt systemopdatering tilbage, men ikke til at gendanne mistede personlige filer.

Det betyder også, at dit `~/.config`-bibliotek forbliver, som det er. Så hvis du ruller tilbage til en tidligere version af et bibliotek eller en applikation, der gemmer konfigurationsfiler i et nyt format, må du selv ordne det manuelt.

Det samme gælder Omarchys egen registrering af, hvilke migrationer der allerede har kørt: den ligger i dit hjemmebibliotek, så den overlever gendannelsen. Migrationer, der kørte, efter snapshottet blev taget, forbliver markeret som færdige, selvom de ændringer, de lavede i rodfilsystemet, er blevet rullet tilbage, og den næste `omarchy update` vil ikke køre dem igen. Så hvis du opdaterer igen efter en gendannelse, og noget, som en tidligere opdatering havde sat op, stadig mangler, er det den sandsynlige årsag.

_Bemærk: Denne funktion er kun tilgængelig på installationer, der bruger Limine-bootloaderen, som har været standarden siden Omarchy 2.0. Den er ikke tilgængelig, hvis du bruger GRUB eller systemd-boot._
