# Systemsnapshots

Vi opretter automatisk snapshots ved hver Omarchy-opdatering, men hvis du vil oprette dine egne, kan du bruge `omarchy-snapshot create`.

For at starte op fra og gendanne et snapshot vælger du det i Limine-bootloaderen. (Hvis du i øjeblikket starter direkte op til Omarchy-dekrypteringsskærmen, skal du først vælge Limine som startmulighed via BIOS).

På den skærm vælger du det snapshot, du vil starte op i, ud fra dato og version. Den version af Omarchy, der var aktiv, da snapshot'et blev taget, kan ses i nederste venstre hjørne.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Når du er kommet ind, dukker der en notifikation op, der fortæller dig, at du er i et bootbart snapshot, og hvis du klikker på den, starter gendannelsesprocessen. Alternativt kan du bruge `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Dette gendanner dit rodfilsystem, men ikke dit `/home`. Så det virker til at rulle en ødelagt systemopdatering tilbage, men ikke til at gendanne mistede personlige filer.

Det betyder også, at dit `~/.config`-bibliotek forbliver, som det er. Så hvis du ruller tilbage til en tidligere version af et bibliotek eller en applikation, der gemmer konfigurationsfiler i et nyt format, må du ordne det manuelt.

Det samme gælder Omarchys egen registrering af, hvilke migrationer der allerede er kørt: den ligger i dit hjemmebibliotek, så den overlever gendannelsen. Migrationer, der kørte, efter snapshot'et blev taget, forbliver markeret som udført, selvom de ændringer, de lavede i rodfilsystemet, er blevet rullet tilbage, og den næste `omarchy update` vil ikke køre dem igen. Så hvis du opdaterer igen efter en gendannelse, og noget, en tidligere opdatering havde sat op, stadig mangler, er det den sandsynlige årsag.

_Bemærk: Denne funktion er kun tilgængelig på installationer, der bruger Limine-bootloaderen, som har været standarden siden Omarchy 2.0. Den er ikke tilgængelig, hvis du bruger GRUB eller systemd-boot._

### Spring bootmenuen over

Hvis du aldrig rører bootmenuen og bare vil have maskinen til at gå direkte til dekrypteringsskærmen, skal du køre _Setup > Direct Boot_ i Omarchy-menuen. Det tilføjer en EFI-post, der peger direkte på Omarchy, så firmwaren starter den uden at stoppe ved Limine.

Kompromiset er det, der er nævnt øverst: med direkte opstart slået til betyder adgang til et snapshot, at du først skal vælge Limine i din BIOS-bootmenu. Kør _Setup > Direct Boot_ igen for at fjerne posten og gå tilbage til at starte via Limine. Nogle firmwaretyper bryder sig ikke om brugerdefinerede EFI-poster, så opsætningen nægter at køre på American Megatrends- og Apple-firmware.
