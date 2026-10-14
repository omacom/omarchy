# Systemögonblicksbilder

Vi skapar ögonblicksbilder automatiskt vid varje Omarchy-uppdatering, men om du skulle vilja skapa dina egna kan du använda `omarchy-snapshot create`.

För att starta och återställa en ögonblicksbild väljer du den från Limine-bootloadern. (Om du för närvarande startar direkt in till Omarchy-dekrypteringsskärmen måste du först välja Limine som startalternativ via BIOS).

Från den skärmen väljer du ögonblicksbilden du vill starta in i baserat på datum och version. Omarchy-versionen vid tidpunkten för ögonblicksbilden kan ses i nedre vänstra hörnet.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

När du anländer inuti kommer en avisering att dyka upp och meddela dig om att du befinner dig i en startbar ögonblicksbild och, om du klickar på den, startar återställningsprocessen. Alternativt kan du använda `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Detta kommer att återställa ditt rotfilsystem, men inte ditt `/home`. Så det fungerar för att återställa en trasig systemuppdatering, men inte för att återhämta förlorade personliga filer.

Detta betyder också att din `~/.config`-katalog behålls som den är. Så om du rullar tillbaka till en tidigare version av ett bibliotek eller en applikation som lagrar konfigurationsfiler i ett nytt format måste du sortera ut det manuellt.

_Obs: Denna funktion är endast tillgänglig på installationer som använder Limine-bootloadern, som har varit standard sedan Omarchy 2.0. Den är inte tillgänglig om du är på GRUB eller systemd-boot._

### Hoppa över startmenyn

Om du aldrig rör startmenyn och bara vill att datorn ska gå direkt till dekrypteringsskärmen kör du _Installation > Direct Boot_ i Omarchy-menyn. Det lägger till en EFI-post som pekar direkt på Omarchy, så firmwaren startar den utan att stanna vid Limine.

Kompromissen är den som nämns i början: med direktstart på betyder att komma till en ögonblicksbild att först välja Limine från din BIOS-startmeny. Kör _Installation > Direct Boot_ igen för att ta bort posten och gå tillbaka till att starta via Limine. Viss firmware tar inte vänligt emot anpassade EFI-poster, så installationen vägrar att köra på American Megatrends och Apple-firmware.
