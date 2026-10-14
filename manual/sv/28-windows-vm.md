# Windows VM

Omarchy erbjuder ett enkelt sätt att köra Windows via en Docker-VM. Du kan installera den via _Installera > Windows_ från Omarchy-menyn (`Super + Space`).

Din maskin behöver KVM-virtualisering för det här, vilket de flesta har — men det är ibland avstängt i BIOS, och installern berättar för dig om så är fallet. Du vill också ha diskutrymmet: vad du än ger Windows, plus omkring 10GB för själva avbilden.

Installern frågar hur mycket RAM, hur många CPU-kärnor och hur mycket disk som ska lämnas över (64GB eller mer är den förnuftiga lägstanivån), sedan efter ett Windows-användarnamn och lösenord. Lämna dem tomma så får du `docker` / `admin`. Nedladdningen tar ett tag — 10-15 minuter är normalt — och du kan följa förloppet i webbläsaren på `http://127.0.0.1:8006`. Webbläsaren ber om samma användarnamn och lösenord innan den öppnar konsolen.

 ![windows-vm](images/windows-vm.webp)

## Använda den

När den väl är installerad, starta _Windows_ från app-launchern. Det startar VM:en om den inte redan körs och ansluter dig via RDP, i helskärm. Ge den 15-30 sekunder vid en kallstart.

RDP-sessionen för över ljud, din mikrofon och ett delat urklipp, så att kopiera text mellan Linux och Windows bara fungerar. Upplösningen följer ditt fönster, och Omarchy skickar vidare din skärmskalning, så det är inte en suddig röra på en HiDPI-skärm.

När du stänger RDP-fönstret stängs VM:en av automatiskt. Om du hellre vill lämna den igång — säg att du har något som arbetar på där inne — starta den med `omarchy windows vm launch --keep-alive` istället.

Resten av kontrollerna finns på samma kommando:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Dela filer

Katalogen `~/Windows` i din hemkatalog delas automatiskt med VM:en. Lägg filer där om du vill att de ska vara tillgängliga för Windows. VM:en har ingen åtkomst till någon annan del av ditt filsystem, så du är säker från allt otäckt på Windows-sidan. Dess egen virtuella disk finns på `~/.windows`.

De välbekanta hemsökvägarna stannar på sina egna filsystem. De kan också vara symlinkar till kataloger du äger, vilket är användbart när den virtuella disken bor på en större enhet. Installern mäter ledigt utrymme på filsystemet som faktiskt innehåller `~/.windows`, inte nödvändigtvis filsystemet som innehåller din hemkatalog.

Håll disk- och delade sökvägar som separata, icke-överlappande kataloger. Borttagning tömmer medvetet disk-katalogen men bevarar den delade katalogen. Omedelbart före borttagning utför Omarchy en avgränsad inneslutningskontroll och vägrar att ta bort något om den kontrollen timear ut eller inte kan bevisa att de två träden är separata.

Innan VM:en startar öppnar och fäster Omarchy de två katalogerna, och bind-monterar sedan de exakta katalog-inodernas på privata per-användare-ankare under `/var/lib/omarchy/windows/mounts`. Docker ser bara de root-skyddade ankarna. Det här bevarar anpassade diskplatser samtidigt som det hindrar en annan process som körs som du från att byta ut en kontrollerad sökväg innan den privilegierade containern konsumerar den. Befintliga disk- och delade kataloger stramas åt till läge `0700` under migrationen så att andra lokala konton inte kan bläddra i deras innehåll.

VM:ens portar är bundna till localhost endast, så ingenting på ditt nätverk kan nå Windows-maskinen. Webbkonsolen kräver också det konfigurerade Windows-användarnamnet och lösenordet, vilket hindrar ett annat lokalt konto från att styra VM:en via port 8006.

## Begränsningar och licensiering

Det finns ingen GPU-passthrough med den här uppsättningen, så den är inte lämplig för gaming eller videoredigering. Det är ett utmärkt sätt att köra Microsoft Office eller vad annat du absolut måste ha.

Versionen som installeras är Windows 11 Pro, oaktiverad. Du behöver din egen licensnyckel för att använda de avspärrade funktionerna.

Om den här datorn levererades med Windows finns OEM-nyckeln fortfarande i firmwaren även efter att du installerat Omarchy. Skriv ut den med `omarchy windows key`. Den nyckeln är bunden till den här maskinen — den aktiverar Windows som installerats om på den här hårdvaran, men den aktiverar vanligtvis inte VM:en.

Du kan ändra resursallokeringen senare genom att köra om `omarchy-windows-vm install`, vilket skriver om VM:ens konfiguration från dina svar. Compose-filen själv bor nu på `/var/lib/omarchy/windows/docker-compose.yml` och ägs av root — det är medvetet, så att en process som körs som du inte kan skriva om den och få den privilegierade uppstarten att montera hela din disk i containern. Om du behöver redigera den för hand (till exempel för att montera en USB-enhet), redigera den med `sudo` och se alla alternativ på [Dockur Windows-projektet](https://github.com/dockur/windows).

För att göra dig av med hela grejen, använd _Ta bort > Windows_ från Omarchy-menyn. Det raderar VM:ens disk och alla dess data, så se till att allt du bryr dig om är ute ur `~/Windows` först.
