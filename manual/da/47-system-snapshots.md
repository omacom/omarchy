# Systemsnapshots

Vi opretter snapshots automatisk ved hver Omarchy-opdatering, men skulle du ønske at oprette dine egne, kan du bruge `omarchy-snapshot create`.

For at boote og gendanne et snapshot vælger du det fra Limine-bootloaderen. (Hvis du aktuelt booter direkte til Omarchy-dekrypteringsskærmen, skal du først vælge Limine som en bootmulighed via BIOS.)

Fra den skærm vælger du det snapshot, du gerne vil boote ind i, baseret på dato og version. Versionen af Omarchy på snapshot-tidspunktet kan ses i nederste venstre hjørne.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Når du ankommer indeni, vil en notifikation dukke op og underrette dig om, at du er i et bootbart snapshot, og hvis du klikker på den, vil det starte gendannelsesprocessen. Alternativt kan du benytte `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Dette vil gendanne dit rodfilsystem, men ikke dit `/home`. Så det virker til at fortryde en ødelagt systemopdatering, men ikke til at gendanne mistede personlige filer.

Det betyder også, at din `~/.config`-mappe beholdes, som den er. Så hvis du ruller tilbage til en tidligere version af et bibliotek eller en app, der gemmer konfigurationsfiler i et nyt format, skal du sortere det manuelt.

_Bemærk: Denne funktion er kun tilgængelig på installationer, der bruger Limine-bootloaderen, som har været standarden siden Omarchy 2.0. Den er ikke tilgængelig, hvis du er på GRUB eller systemd-boot._

### Spring bootmenuen over

Hvis du aldrig rører bootmenuen og bare vil have maskinen til at gå direkte til dekrypteringsskærmen, så kør _Opsætning > Direkte opstart_ i Omarchy-menuen. Det tilføjer en EFI-post, der peger direkte på Omarchy, så firmwaren booter den uden at stoppe ved Limine.

Kompromiset er det, der nævnes øverst: med direkte opstart tændt betyder det at komme til et snapshot først at vælge Limine fra din BIOS-bootmenu. Kør _Opsætning > Direkte opstart_ igen for at fjerne posten og gå tilbage til at boote gennem Limine. Nogle firmware tager ikke venligt imod brugerdefinerede EFI-poster, så opsætningen nægter at køre på American Megatrends- og Apple-firmware.
