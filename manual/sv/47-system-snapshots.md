# Systemsnapshots

Vi skapar snapshots automatiskt vid varje Omarchy-uppdatering, men om du vill skapa en egen kan du använda `omarchy-snapshot create`.

För att starta från och återställa en snapshot väljer du den i Limines boot loader. Startmenyn är dold som standard, så tryck på valfri tangent så snart Limine startar för att visa den.

På den skärmen väljer du den snapshot du vill starta från, baserat på datum och version. Vilken version av Omarchy som användes när snapshoten togs ser du i det nedre vänstra hörnet.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

När du kommer in visas en avisering som talar om att du befinner dig i en startbar snapshot, och om du klickar på den startar återställningsprocessen. Alternativt kan du använda `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Detta återställer ditt rotfilsystem, men inte ditt `/home`. Så det fungerar för att rulla tillbaka en trasig systemuppdatering, men inte för att återställa förlorade personliga filer.

Detta innebär också att din `~/.config`-katalog behålls som den är. Så om du rullar tillbaka till en tidigare version av ett bibliotek eller en applikation som lagrar konfigurationsfiler i ett nytt format måste du reda ut det manuellt.

Samma sak gäller Omarchys egen registrering av vilka migreringar som redan har körts: den ligger i din hemkatalog, så den överlever återställningen. Migreringar som kördes efter att snapshoten togs förblir markerade som klara, även om de ändringar de gjorde i rotfilsystemet har rullats tillbaka, och nästa `omarchy update` kommer inte att köra dem igen. Så om du uppdaterar igen efter en återställning och något som en tidigare uppdatering hade ställt in fortfarande saknas är det den troliga orsaken.

_Obs: Den här funktionen är endast tillgänglig på installationer som använder Limines boot loader, vilket har varit standard sedan Omarchy 2.0. Den är inte tillgänglig om du använder GRUB eller systemd-boot._
