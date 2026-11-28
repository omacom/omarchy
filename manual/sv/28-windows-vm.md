# Windows VM

Omarchy erbjuder ett enkelt sätt att köra Windows genom en Docker VM på x86_64-maskiner. Du kan installera det via _Installera > Windows_ från Omarchy-menyn (`Super + Space`).

Din maskin behöver KVM-virtualisering för detta, vilket de flesta har — men den är ibland avstängd i BIOS, och installationsprogrammet talar om för dig om så är fallet. Du vill också ha diskutrymmet: det du ger till Windows, plus cirka 10GB för själva avbilden.

Installationsprogrammet frågar hur mycket RAM, hur många CPU-kärnor och hur mycket disk du vill ge den (64GB eller mer är det rimliga minimumet), och därefter efter ett användarnamn och lösenord för Windows. Lämna dem tomma så får du `docker` / `admin`. Nedladdningen tar en stund — 10-15 minuter är normalt — och du kan följa förloppet i webbläsaren på `http://127.0.0.1:8006`. Webbläsaren frågar efter samma användarnamn och lösenord innan den öppnar konsolen.

 ![windows-vm](images/windows-vm.webp)

## Att använda den

När den väl är installerad startar du _Windows_ från appstartaren. Det startar VM:en om den inte redan körs och ansluter dig via RDP, i helskärm. Ge den 15-30 sekunder vid en kallstart.

RDP-sessionen förmedlar ljud, din mikrofon och ett delat urklipp, så det fungerar helt enkelt att kopiera text mellan Linux och Windows. Upplösningen följer ditt fönster, och Omarchy skickar vidare din skärmskalning, så det inte blir en suddig röra på en HiDPI-skärm.

När du stänger RDP-fönstret stängs VM:en av automatiskt. Om du hellre låter den vara igång — säg att du har något som arbetar på där inne — startar du den i stället med `omarchy windows vm launch --keep-alive`.

Resten av kontrollerna finns på samma kommando:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Dela filer

Katalogen `~/Windows` i din hemkatalog delas automatiskt med VM:en. Lägg filer där om du vill att de ska vara åtkomliga för Windows. VM:en har inte åtkomst till någon annan del av ditt filsystem, så du är säker från allt otäckt på Windows-sidan. Dess egen virtuella disk finns på `~/.windows`.

De där välbekanta hemkatalogsökvägarna ligger kvar på sina egna filsystem. De kan också vara symlänkar till kataloger du äger, vilket är användbart när den virtuella disken ligger på en större enhet. Installationsprogrammet mäter ledigt utrymme på det filsystem som faktiskt innehåller `~/.windows`, inte nödvändigtvis det filsystem som innehåller din hemkatalog.

Håll disk- och delningssökvägarna som separata, icke-överlappande kataloger. Borttagning tömmer avsiktligt diskkatalogen men bevarar den delade katalogen. Omedelbart före radering utför Omarchy en begränsad inneslutningskontroll och vägrar att ta bort något om den kontrollen överskrider tidsgränsen eller inte kan bevisa att de två träden är separata.

Innan VM:en startar öppnar Omarchy och fäster de två katalogerna, och bind-monterar sedan de exakta kataloginoderna på privata ankare per användare under `/var/lib/omarchy/windows/mounts`. Docker ser bara de där root-skyddade ankarna. Detta bevarar anpassade diskplatser samtidigt som det förhindrar att en annan process som körs som du byter ut en kontrollerad sökväg innan den privilegierade containern använder den. Befintliga disk- och delade kataloger stramas åt till läge `0700` under migreringen så att andra lokala konton inte kan bläddra bland deras innehåll.

VM:ens portar är bundna endast till localhost, så ingenting på ditt nätverk kan nå Windows-maskinen. Webbkonsolen kräver också det konfigurerade användarnamnet och lösenordet för Windows, vilket förhindrar att ett annat lokalt konto driver VM:en via port 8006.

## Begränsningar och licensiering

Det finns ingen GPU-passthrough med den här uppsättningen, så den passar inte för spel eller videoredigering. Den är ett utmärkt sätt att köra Microsoft Office eller vad du nu absolut måste ha.

Versionen som installeras är Windows 11 Pro, oaktiverad. Du behöver din egen licensnyckel för att använda de låsta funktionerna.

Om den här datorn levererades med Windows finns OEM-nyckeln fortfarande kvar i den fasta programvaran även efter att du installerat Omarchy. Skriv ut den med `omarchy windows key`. Den nyckeln är bunden till den här maskinen — den aktiverar Windows som installerats om på den här hårdvaran, men den aktiverar vanligtvis inte VM:en.

Du kan ändra resurstilldelningen senare genom att köra `omarchy windows vm install` i en terminal, vilket skriver om VM:ens konfiguration utifrån dina svar. Själva compose-filen ligger nu på `/var/lib/omarchy/windows/docker-compose.yml` och ägs av root — det är avsiktligt, så att en process som körs som du inte kan skriva om den och få den privilegierade uppstarten att montera hela din disk i containern. Om du behöver redigera den för hand (till exempel för att montera en USB-enhet) redigerar du den med `sudo` och ser alla alternativ på [Dockur Windows-projektet](https://github.com/dockur/windows).

För att bli av med alltihop använder du _Ta bort > Windows_ från Omarchy-menyn. Det raderar VM:ens disk i `~/.windows` och allt som installerats inuti Windows, så kopiera ut allt du behöver från VM:en först. Din delade mapp `~/Windows` lämnas i fred.
