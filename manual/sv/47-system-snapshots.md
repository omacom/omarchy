# Systemögonblicksbilder

Vi skapar ögonblicksbilder automatiskt vid varje Omarchy-uppdatering, men om du vill skapa en egen kan du använda `omarchy-snapshot create`.

Hur du startar från och återställer en ögonblicksbild beror på vilken starthanterare din dator startar med. Nya UEFI-installationer använder systemd-boot; äldre installationer och BIOS-datorer använder Limine. `omarchy-boot-backend` talar om för dig vilken du har.

## Med systemd-boot

Välj _System > Snapshots_ i Omarchy-menyn och välj den ögonblicksbild du vill starta från. Datorn startar om från den en gång. Eller håll ned Space medan datorn startar för att se startmenyn, där varje ögonblicksbild listas med den nyaste först, tillsammans med dess Omarchy-version och datum.

En ögonblicksbild startar med ett tillfälligt lager ovanpå, så du kan använda den som vanligt, men allt du ändrar är borta vid nästa omstart. För att behålla den, gör den till ditt system: klicka på aviseringen som visas när du loggar in, välj _System > Snapshots > Restore This Snapshot_, eller kör `omarchy-snapshot restore`. Återställningen sker medan datorn startar om. Systemet som det var innan finns kvar i startmenyn som _Before restore_, och `omarchy-snapshot restore backup` återställer det.

Från terminalen:

- `omarchy-snapshot list` listar de ögonblicksbilder du kan starta från;
- `omarchy-snapshot boot 12` startar om från ögonblicksbild 12 en gång;
- `omarchy-snapshot restore 12` gör ögonblicksbild 12 till systemet vid nästa omstart, och `omarchy-snapshot restore --cancel` låter dig ångra dig före den omstarten.

## Med Limine

För att starta från och återställa en ögonblicksbild väljer du den från Limine-starthanteraren. Startmenyn är dold som standard, så tryck på valfri tangent så snart Limine startar för att visa den.

Från den skärmen väljer du den ögonblicksbild du vill starta från, baserat på datum och version. Vilken version av Omarchy som gällde när ögonblicksbilden togs ser du i det nedre vänstra hörnet.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

När du har kommit in visas en avisering som talar om att du befinner dig i en startbar ögonblicksbild, och om du klickar på den startar återställningsprocessen. Alternativt kan du använda `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## Vad en återställning omfattar

En återställning återställer ditt rotfilsystem, men inte din `/home`. Så den fungerar för att rulla tillbaka en trasig systemuppdatering, men inte för att återställa förlorade personliga filer.

Det betyder också att din katalog `~/.config` behålls som den är. Så om du rullar tillbaka till en tidigare version av ett bibliotek eller ett program som lagrar konfigurationsfiler i ett nytt format, får du reda ut det manuellt.

Samma sak gäller Omarchys egen registrering av vilka migreringar som redan har körts: den finns i din hemkatalog, så den överlever återställningen. Migreringar som kördes efter att ögonblicksbilden togs förblir markerade som klara, även om ändringarna de gjorde i rotfilsystemet har rullats tillbaka, och nästa `omarchy update` kommer inte att köra dem igen. Så om du uppdaterar igen efter en återställning och något som en tidigare uppdatering hade ställt in fortfarande saknas, är det den troliga orsaken.
