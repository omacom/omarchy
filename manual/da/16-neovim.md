# Neovim

[Neovim](https://neovim.io/) er en moderne implementering af [vi-editoren](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) skabt af Bill Joy helt tilbage i 1976. Det er en modal editor, hvor indsætningstilstand og kommandotilstand er adskilt, og det er lidt af en superkraft, når du først lærer bare en delmængde af det utroligt dybe sæt af tastekommandoer. Men det er også noget af en læringskurve!

Hvis du er helt ny til vim-agtig redigering, anbefaler jeg, at du tjekker [ThePrimeagen's Vim As Your Editor series](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) på YouTube. Den lærer dig det grundlæggende. Du skal bare vide, at i modsætning til mere lignende mainstream-editorer kommer det til at tage dig længere tid at blive nogenlunde dygtig til vim. Men når du først bliver det, er udbyttet også større.

Nu er Neovim stort set uendeligt konfigurerbar. Hvis du virkelig vil gå amok, kan du skabe din egen Neovim-konfiguration helt fra bunden. Der findes et fantastisk kursus fra [Typecraft om at sætte Neovim op fra bunden](https://www.youtube.com/watch?v=zHTeCSVAFNY). Og [ThePrimeagen har også et](https://www.youtube.com/watch?v=w7i4amO_zaE).

Men Omarchy leveres med en komplet Neovim-opsætning — `omarchy-nvim`-pakken — som er blevet kærligt tunet til at vise det bedste af, hvad der er muligt lige ud af boksen. Uden at du skal skrive en eneste linje konfiguration! Den er bygget på [LazyVim](https://www.lazyvim.org/), en distribution af Neovim-plugins og -konfigurationer. Den er fantastisk.

## Grundlæggende om LazyVim

Som nævnt kommer jeg ikke til at lære dig vim i denne korte introduktion, men jeg kan vise dig nogle grundlæggende ting om LazyVim, og hvordan du finder rundt.

For det første har Neovim idéen om leader-tasten. Det er i bund og grund indgangen til alle kommandoerne. LazyVim har sat den til `Space`. Så tryk bare på den, vent et sekund, og du vil se en masse muligheder forklaret inline sådan her:

Her er nogle grundlæggende kommandoer, jeg bruger hele tiden:

- `Space Space` - Find enhver fil i den aktuelle mappe med fuzzy-søgning.
- `Space S G` - Søg i alle filer med grep med en forhåndsvisning.
- `Space E` - Slå filtræet til/fra.
- `Ctrl + W W` - Hop fra filtræet til editoren og tilbage.
- `Shift + H` - Flyt til venstre mellem de åbne faner (vim kalder dem buffers).
- `Shift + L` - Flyt til højre mellem de åbne faner.
- `Space B D` - Luk en fane.
- `Space B O` - Luk alle andre faner end den aktuelle.
- `Space G G` - Start LazyGit i en flydende rude fra den aktuelle mappe.
- `Space U W` - Slå soft wrap til/fra.

Mens du er i filtræet (`Space E` for at vise det, `Ctrl + W W` for at hoppe derover), kan du tilføje en ny fil med `a` eller en ny mappe med `A`. Tryk på `?`, mens du er i træet, for at se alle kommandoer.

Hvis du vil lære det grundlæggende vim-sprog, har jeg skrevet om [den tredelte syntaks](https://world.hey.com/dhh/wonderful-vi-a1d034d3), og hvordan man laver de vilde combo-moves!

Du kan se alle de mulige kommandoer på [LazyVim Keymaps-siden](https://www.lazyvim.org/keymaps).

## Sådan starter du Neovim

`Super + Shift + N` starter din standardeditor, som er Plain på nye installationer; vælg Neovim under _Setup > Defaults > Editor_ for at få den til at starte Neovim i stedet. Men det er som regel nemmere at styre den fra terminalen ved at navigere til den mappe, du vil arbejde i, og skrive `n`. `n` er aliaset for `nvim`, som som standard vil bruge den aktuelle mappe at åbne i. Du kan åbne en enkelt fil med `n myfile.txt`.

## Sådan bruger du Neovim til sudo-redigeringer

Hvis du skal redigere filer, som du kun kan ændre som superbruger, skal du køre `sudoedit /etc/sudoers.d/00-sudo-only-file`. Den åbner din standardeditor, så sæt Neovim under _Setup > Defaults > Editor_, hvis du vil have den der med alle dine plugins.
