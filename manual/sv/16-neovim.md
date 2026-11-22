# Neovim

[Neovim](https://neovim.io/) är en modern implementation av [textredigeraren vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) som skapades av Bill Joy redan 1976. Det är en modal redigerare där infogningsläget och kommandoläget är åtskilda, och den är lite av en superkraft när du väl har lärt dig ens en del av den otroligt djupa uppsättningen tangentkommandon. Men inlärningskurvan är också rejäl!

Om du är helt ny på redigering i vim-stil rekommenderar jag att du kollar in [ThePrimeagen's Vim As Your Editor series](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) på YouTube. Den lär dig grunderna. Var bara medveten om att det, till skillnad från mer likartade vanliga redigerare, kommer att ta längre tid för dig att bli grundläggande duktig med vim. Men när du väl blir det är belöningen också större.

Neovim går i princip att konfigurera i det oändliga. Om du verkligen vill gå all in kan du skapa din egen Neovim-konfiguration från grunden. Det finns en utmärkt kurs från [Typecraft om att sätta upp Neovim från grunden](https://www.youtube.com/watch?v=zHTeCSVAFNY). Och [ThePrimeagen har en också](https://www.youtube.com/watch?v=w7i4amO_zaE).

Men Omarchy levereras med en komplett Neovim-uppsättning — paketet `omarchy-nvim` — som har finjusterats med omsorg för att visa det bästa av vad som är möjligt direkt ur lådan. Utan att du behöver skriva en enda rad konfiguration! Den är byggd på [LazyVim](https://www.lazyvim.org/), en distribution av Neovim-plugins och konfigurationer. Den är grym.

## Grunderna i LazyVim

Som sagt kommer jag inte att lära dig vim i den här korta introduktionen, men jag kan visa dig några grunder i LazyVim, och hur du tar dig runt.

Först har Neovim idén om leader-tangenten. Den är i princip inkörsporten till alla kommandon. LazyVim har satt den till `Space`. Så tryck bara på den, vänta en sekund, så ser du en massa alternativ förklarade inline så här:

Här är några grundläggande kommandon som jag använder hela tiden:

- `Space Space` - Fuzzy-sök efter valfri fil i den aktuella katalogen.
- `Space S G` - Sök i alla filer med grep med en förhandsgranskning.
- `Space E` - Växla filträdet på/av.
- `Ctrl + W W` - Hoppa från filträdet till redigeraren och tillbaka.
- `Shift + H` - Flytta åt vänster mellan de öppna flikarna (vim kallar dem buffertar).
- `Shift + L` - Flytta åt höger mellan de öppna flikarna.
- `Space B D` - Stäng en flik.
- `Space B O` - Stäng alla andra flikar utom den aktuella.
- `Space G G` - Starta LazyGit i en flytande ruta från den aktuella katalogen.
- `Space U W` - Växla mjuk radbrytning.

När du är i filträdet (`Space E` för att visa det, `Ctrl + W W` för att hoppa dit) kan du lägga till en ny fil med `a` eller en ny katalog med `A`. Tryck på `?` medan du är i trädet för att se alla kommandon.

Om du vill lära dig det grundläggande vim-språket har jag skrivit om [den tredelade syntaxen](https://world.hey.com/dhh/wonderful-vi-a1d034d3) och hur du lyckas med de där sjuka kombinationerna!

Du kan se alla möjliga kommandon på [sidan LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Starta Neovim

`Super + Shift + N` startar din standardredigerare, som är Plain på nya installationer; välj Neovim under _Setup > Defaults > Editor_ för att den ska starta Neovim i stället. Men det är oftast enklare att köra den från terminalen genom att navigera till katalogen du vill arbeta i och skriva `n`. `n` är aliaset för `nvim`, som som standard använder den aktuella katalogen att öppna. Du kan öppna en enskild fil med `n myfile.txt`.

## Använda Neovim för sudo-redigeringar

Om du behöver redigera filer som du bara kan ändra som superanvändare kör du `sudoedit /etc/sudoers.d/00-sudo-only-file`. Den öppnar din standardredigerare, så ställ in Neovim under _Setup > Defaults > Editor_ om du vill ha den där med alla dina plugins.
