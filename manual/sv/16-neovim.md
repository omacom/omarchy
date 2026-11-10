# Neovim

[Neovim](https://neovim.io/) är en modern implementering av [vi-redigeraren](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) skapad av Bill Joy ända tillbaka 1976. Det är en modal redigerare där infogningsläge och kommandoläge är separerade, och det är lite av en superkraft när du lär dig även bara en delmängd av den otroligt djupa tangentkommandosättningen. Men det är också en rejäl inlärningskurva!

Om du är helt ny på redigering i vim-stil rekommenderar jag att du kollar in [ThePrimeagens Vim As Your Editor-serie](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) på YouTube. Den lär dig grunderna. Vet bara att till skillnad från mer likartade vanliga redigerare kommer det att ta längre tid att få grundläggande färdighet med vim. Men när du väl gör det är belöningen också större.

Nu är Neovim i princip oändligt konfigurerbart. Om du verkligen vill gå all in kan du skapa din egen Neovim-konfiguration från grunden. Det finns en fantastisk kurs från [Typecraft om att konfigurera Neovim från grunden](https://www.youtube.com/watch?v=zHTeCSVAFNY). Och [ThePrimeagen har en också](https://www.youtube.com/watch?v=w7i4amO_zaE).

Men Omarchy levereras med en komplett Neovim-konfiguration — paketet `omarchy-nvim` — som har finjusterats med kärlek för att visa upp det bästa av vad som är möjligt direkt ur lådan. Utan att du behöver skriva en enda rad konfiguration! Den är byggd på [LazyVim](https://www.lazyvim.org/), en distribution av Neovim-plugins och konfigurationer. Den är fantastisk.

## LazyVim-grunder

Som nämnt kommer jag inte att lära dig vim i den här korta introduktionen, men jag kan visa dig några grunder i LazyVim och hur du tar dig runt.

För det första har Neovim idén om ledartangenten. Det är i princip porten till alla kommandon. LazyVim har ställt in den på `Space`. Så tryck bara på den, vänta en sekund, så ser du en massa alternativ förklarade inline så här:

Här är några grundläggande kommandon jag använder hela tiden:

- `Space Space` - Fuzzy-sök valfri fil i den aktuella katalogen.
- `Space S G` - Sök igenom alla filer med grep med förhandsgranskning.
- `Space E` - Växla filträdet på/av.
- `Ctrl + W W` - Hoppa från filträdet till redigeraren och tillbaka.
- `Shift + H` - Flytta vänster mellan de öppna flikarna (vim kallar dem buffrar).
- `Shift + L` - Flytta höger mellan de öppna flikarna.
- `Space B D` - Stäng en flik.
- `Space B O` - Stäng alla andra flikar utom den aktuella.
- `Space G G` - Starta LazyGit i en flytande ruta från den aktuella katalogen.
- `Space U W` - Växla mjuk radbrytning.

Medan du är i filträdet (`Space E` för att visa, `Ctrl + W W` för att hoppa dit) kan du lägga till en ny fil med `a` eller en ny katalog med `A`. Tryck på `?` medan du är i trädet för att se alla kommandon.

Om du vill lära dig det grundläggande vim-språket har jag skrivit om [den tredelade syntaxen](https://world.hey.com/dhh/wonderful-vi-a1d034d3) och hur man utför de där sjuka kombinationerna!

Du kan se alla möjliga kommandon på [LazyVims Keymaps-sida](https://www.lazyvim.org/keymaps).

## Starta Neovim

Du kan starta Neovim med `Super + Shift + N` (bindningen startar din standardredigerare, som är Neovim direkt ur lådan), men det är vanligtvis lättare att driva den från terminalen genom att navigera till katalogen du vill arbeta i och skriva `n`. `n` är aliaset för `nvim`, som använder den aktuella katalogen att öppna som standard. Du kan öppna en enskild fil med `n myfile.txt`.

## Använda Neovim för sudo-redigeringar

Om du behöver redigera filer som du bara kan ändra som superanvändare kan du använda neovim med alla dina plugins konfigurerade genom att köra `sudoedit /etc/sudoers.d/00-sudo-only-file`.
