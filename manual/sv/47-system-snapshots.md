# Systemögonblicksbilder

Vi skapar ögonblicksbilder automatiskt vid varje Omarchy-uppdatering, men om du vill skapa en egen kan du använda `omarchy-snapshot create`.

För att starta och återställa en ögonblicksbild väljer du den från Limine-bootloadern. (Om du för närvarande startar direkt till Omarchys dekrypteringsskärm måste du först välja Limine som startalternativ via BIOS).

Från den skärmen väljer du den ögonblicksbild du vill starta i baserat på datum och version. Versionen av Omarchy vid tidpunkten för ögonblicksbilden visas i det nedre vänstra hörnet.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

När du kommer in visas en avisering som meddelar dig att du befinner dig i en startbar ögonblicksbild och om du klickar på den startar återställningsprocessen. Alternativt kan du använda `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Detta återställer ditt rotfilsystem, men inte ditt `/home`. Så det fungerar för att återställa en trasig systemuppdatering, men inte för att återställa förlorade personliga filer.

Detta innebär också att din `~/.config`-katalog behålls som den är. Så om du rullar tillbaka till en tidigare version av ett bibliotek eller en applikation som lagrar konfigurationsfiler i ett nytt format måste du lösa det manuellt.

Detsamma gäller Omarchys egen registrering av vilka migreringar som redan har körts: den ligger i din hemkatalog, så den överlever återställningen. Migreringar som kördes efter att ögonblicksbilden togs förblir markerade som klara, även om ändringarna de gjorde i rotfilsystemet har rullats tillbaka, och nästa `omarchy update` kommer inte att köra dem igen. Så om du uppdaterar igen efter en återställning och något som en tidigare uppdatering hade ställt in fortfarande saknas är det den troliga orsaken.

_Obs: Den här funktionen är endast tillgänglig på installationer som använder Limine-bootloadern, som har varit standard sedan Omarchy 2.0. Den är inte tillgänglig om du använder GRUB eller systemd-boot._

### Hoppa över startmenyn

Om du aldrig rör startmenyn och bara vill att maskinen ska gå direkt till dekrypteringsskärmen kör du _Setup > Direct Boot_ i Omarchy-menyn. Det lägger till en EFI-post som pekar direkt på Omarchy, så att firmwaren startar den utan att stanna vid Limine.

Avvägningen är den som nämns i början: med direktstart på innebär det att du först måste välja Limine från din BIOS-startmeny för att komma till en ögonblicksbild. Kör _Setup > Direct Boot_ igen för att ta bort posten och gå tillbaka till att starta via Limine. Viss firmware gillar inte anpassade EFI-poster, så installationen vägrar att köras på American Megatrends- och Apple-firmware.
