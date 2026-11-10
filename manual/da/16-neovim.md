# Neovim

[Neovim](https://neovim.io/) er en moderne implementering af [vi-editoren](<https://en.wikipedia.org/wiki/Vi_(text_editor)>), som Bill Joy skabte helt tilbage i 1976. Det er en modal editor, hvor indsætningstilstand og kommandotilstand er adskilt, og det er lidt af en superkraft, når du først lærer bare en delmængde af det utroligt dybe tastekommandosæt. Men det er også en ordentlig indlæringskurve!

Hvis du er helt ny inden for vim-lignende redigering, anbefaler jeg, at du tjekker [ThePrimeagens Vim As Your Editor-serie](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) på YouTube. Den vil lære dig det grundlæggende. Du skal bare vide, at i modsætning til mere lignende almindelige editorer kommer det til at tage dig længere tid at få grundlæggende færdigheder med vim. Men når du gør det, er gevinsten også større.

Nu er Neovim dybest set uendeligt konfigurerbar. Hvis du virkelig vil gå amok, kan du oprette din egen Neovim-konfiguration fra bunden. Der er et fantastisk kursus fra [Typecraft om at sætte Neovim op fra bunden](https://www.youtube.com/watch?v=zHTeCSVAFNY). Og [ThePrimeagen har også ét](https://www.youtube.com/watch?v=w7i4amO_zaE).

Men Omarchy leveres med en komplet Neovim-opsætning — pakken `omarchy-nvim` — som er blevet kærligt tunet til at vise det bedste af, hvad der er muligt lige fra start. Uden at du behøver at skrive en eneste linje konfiguration! Den er bygget på [LazyVim](https://www.lazyvim.org/), en distribution af Neovim-plugins og -konfigurationer. Den er fantastisk.

## Det grundlæggende i LazyVim

Som nævnt vil jeg ikke lære dig vim i denne korte introduktion, men jeg kan vise dig et par grundlæggende ting i LazyVim, og hvordan du finder rundt.

Først har Neovim idéen om leadertasten. Det er dybest set porten til alle kommandoerne. LazyVim har sat den til `Space`. Så tryk bare på den, vent et sekund, og du vil se en masse muligheder forklaret inline sådan her:

Her er nogle grundlæggende kommandoer, jeg bruger hele tiden:

- `Space Space` - Uklar søgning efter en hvilken som helst fil i den aktuelle mappe.
- `Space S G` - Søg i alle filer med grep med en forhåndsvisning.
- `Space E` - Slå filtræet til/fra.
- `Ctrl + W W` - Hop fra filtræet til editoren og tilbage.
- `Shift + H` - Flyt til venstre mellem de åbne faner (vim kalder dem buffere).
- `Shift + L` - Flyt til højre mellem de åbne faner.
- `Space B D` - Luk en fane.
- `Space B O` - Luk alle andre faner end den aktuelle.
- `Space G G` - Start LazyGit i et flydende panel fra den aktuelle mappe.
- `Space U W` - Slå blød ombrydning til/fra.

Mens du er i filtræet (`Space E` for at afsløre, `Ctrl + W W` for at hoppe derover), kan du tilføje en ny fil med `a` eller en ny mappe med `A`. Tryk på `?`, mens du er i træet, for at se alle kommandoer.

Hvis du vil lære det grundlæggende vim-sprog, har jeg skrevet om [den tredelte syntaks](https://world.hey.com/dhh/wonderful-vi-a1d034d3), og hvordan man udfører de fede combos!

Du kan se alle de mulige kommandoer på [siden LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Start af Neovim

Du kan starte Neovim med `Super + Shift + N` (bindingen starter din standardeditor, som er Neovim fra start), men det er som regel lettere at styre den fra terminalen ved at navigere til den mappe, du ønsker at arbejde i, og skrive `n`. `n` er aliaset for `nvim`, som bruger den aktuelle mappe til at åbne som standard. Du kan åbne en enkelt fil med `n myfile.txt`.

## Brug af Neovim til sudo-redigeringer

Hvis du har brug for at redigere filer, som du kun kan ændre som superbruger, kan du bruge neovim med alle dine plugins sat op ved at køre `sudoedit /etc/sudoers.d/00-sudo-only-file`.
