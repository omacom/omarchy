# Neovim

[Neovim](https://neovim.io/) er en moderne implementasjon av [vi-editoren](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) som Bill Joy laget helt tilbake i 1976. Det er en modal editor der innsettingsmodus og kommand modus er atskilt, og det er litt av en superkraft når du lærer selv bare en delmengde av det utrolig dype tastekommandosettet. Men det er også ganske en læringskurve!

Hvis du er helt ny på vim-aktig redigering, anbefaler jeg at du sjekker ut [ThePrimeagens Vim As Your Editor-serie](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) på YouTube. Den lærer deg det grunnleggende. Bare vit at i motsetning til mer lignende, vanlige editorer, kommer det til å ta deg lengre tid å få grunnleggende ferdigheter i vim. Men når du gjør det, er gevinsten også større.

Nå er Neovim i bunn og grunn uendelig konfigurerbar. Hvis du virkelig vil gå amok, kan du lage din egen Neovim-konfigurasjon fra bunnen av. Det finnes et flott kurs fra [Typecraft om å sette opp Neovim fra bunnen av](https://www.youtube.com/watch?v=zHTeCSVAFNY). Og [ThePrimeagen har ett også](https://www.youtube.com/watch?v=w7i4amO_zaE).

Men Omarchy leveres med et komplett Neovim-oppsett — pakken `omarchy-nvim` — som er kjærlig innstilt for å vise frem det beste av hva som er mulig rett fra boksen. Uten at du må skrive en eneste linje med konfigurasjon! Den er bygget på [LazyVim](https://www.lazyvim.org/), en distribusjon av Neovim-plugins og konfigurasjoner. Den er fantastisk.

## Grunnleggende om LazyVim

Som nevnt skal jeg ikke lære deg vim i denne korte introduksjonen, men jeg kan vise deg noen grunnleggende ting om LazyVim, og hvordan du finner frem.

Først har Neovim ideen om ledertasten. Det er i bunn og grunn inngangsporten til alle kommandoene. LazyVim har satt den til `Space`. Så trykk bare den, vent et sekund, og du ser en haug med alternativer forklart innebygd, slik som dette:

Her er noen grunnleggende kommandoer jeg bruker hele tiden:

- `Space Space` - Finn enhver fil i gjeldende mappe med fuzzy-søk.
- `Space S G` - Søk i alle filer med grep og forhåndsvisning.
- `Space E` - Veksle filtreet av/på.
- `Ctrl + W W` - Hopp fra filtreet til editoren og tilbake.
- `Shift + H` - Flytt til venstre mellom de åpne fanene (vim kaller dem buffere).
- `Shift + L` - Flytt til høyre mellom de åpne fanene.
- `Space B D` - Lukk en fane.
- `Space B O` - Lukk alle andre faner enn den gjeldende.
- `Space G G` - Start LazyGit i en flytende rute fra gjeldende mappe.
- `Space U W` - Veksle myk linjebryting.

Mens du er i filtreet (`Space E` for å vise, `Ctrl + W W` for å hoppe dit), kan du legge til en ny fil med `a` eller en ny mappe med `A`. Trykk `?` mens du er i treet for å se alle kommandoer.

Hvis du vil lære deg det grunnleggende vim-språket, har jeg skrevet om [den tredelte syntaksen](https://world.hey.com/dhh/wonderful-vi-a1d034d3) og hvordan du får til de syke kombinasjonstrekkene!

Du kan se alle mulige kommandoer på [LazyVims Keymaps-side](https://www.lazyvim.org/keymaps).

## Starte Neovim

Du kan starte Neovim med `Super + Shift + N` (bindingen starter standardeditoren din, som er Neovim rett fra boksen), men det er vanligvis enklere å styre den fra terminalen ved å navigere til mappen du vil jobbe i og skrive `n`. `n` er aliaset for `nvim`, som bruker gjeldende mappe til å åpne som standard. Du kan åpne én enkelt fil med `n myfile.txt`.

## Bruke Neovim for sudo-redigeringer

Hvis du trenger å redigere filer du bare kan endre som superbruker, kan du bruke neovim med alle pluginene dine satt opp ved å kjøre `sudoedit /etc/sudoers.d/00-sudo-only-file`.
