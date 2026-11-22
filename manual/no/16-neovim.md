# Neovim

[Neovim](https://neovim.io/) er en moderne implementering av [vi-editoren](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) som Bill Joy skapte helt tilbake i 1976. Det er en modal editor der innsettingsmodus og kommandomodus er atskilt, og det er litt av en superkraft når du først har lært deg bare en liten del av det utrolig dype settet med tastekommandoer. Men læringskurven er også ganske bratt!

Hvis du er helt ny til vim-aktig redigering, anbefaler jeg at du sjekker ut [ThePrimeagen's Vim As Your Editor series](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) på YouTube. Den lærer deg det grunnleggende. Bare vit at i motsetning til mer like, vanlige editorer kommer det til å ta deg lengre tid å oppnå grunnleggende ferdigheter med vim. Men når du først gjør det, er gevinsten også større.

Neovim er i praksis uendelig konfigurerbar. Hvis du virkelig vil gå helt amok, kan du lage din egen Neovim-konfigurasjon fra bunnen av. Det finnes et flott kurs fra [Typecraft om å sette opp Neovim fra bunnen av](https://www.youtube.com/watch?v=zHTeCSVAFNY). Og [ThePrimeagen har ett også](https://www.youtube.com/watch?v=w7i4amO_zaE).

Men Omarchy leveres med et komplett Neovim-oppsett — `omarchy-nvim`-pakken — som er kjærlig finjustert for å vise frem det beste av hva som er mulig rett ut av esken. Uten at du må skrive en eneste linje med konfigurasjon! Det er bygget på [LazyVim](https://www.lazyvim.org/), en distribusjon av Neovim-plugins og -konfigurasjoner. Det er fantastisk.

## Grunnleggende om LazyVim

Som nevnt kommer jeg ikke til å lære deg vim i denne korte introduksjonen, men jeg kan vise deg litt grunnleggende om LazyVim, og hvordan du finner veien rundt.

For det første har Neovim konseptet med en leader-tast. Det er i praksis inngangsporten til alle kommandoene. LazyVim har satt den til `Space`. Så bare trykk på den, vent et sekund, og du vil se en haug med alternativer forklart direkte på skjermen slik:

Her er noen grunnleggende kommandoer jeg bruker hele tiden:

- `Space Space` - Finn en hvilken som helst fil i gjeldende mappe med fuzzy-søk.
- `Space S G` - Søk i alle filer med grep, med forhåndsvisning.
- `Space E` - Slå filtreet av/på.
- `Ctrl + W W` - Hopp fra filtreet til editoren og tilbake.
- `Shift + H` - Flytt til venstre mellom de åpne fanene (vim kaller dem buffere).
- `Shift + L` - Flytt til høyre mellom de åpne fanene.
- `Space B D` - Lukk en fane.
- `Space B O` - Lukk alle andre faner enn den gjeldende.
- `Space G G` - Start LazyGit i en flytende rute fra gjeldende mappe.
- `Space U W` - Slå myk tekstbryting av/på.

Mens du er i filtreet (`Space E` for å vise det, `Ctrl + W W` for å hoppe dit), kan du legge til en ny fil med `a` eller en ny mappe med `A`. Trykk på `?` mens du er i treet for å se alle kommandoer.

Hvis du vil lære deg det grunnleggende vim-språket, har jeg skrevet om [den tredelte syntaksen](https://world.hey.com/dhh/wonderful-vi-a1d034d3) og hvordan du får til de syke kombinasjonstriksene!

Du kan se alle de mulige kommandoene på [LazyVim Keymaps-siden](https://www.lazyvim.org/keymaps).

## Starte Neovim

`Super + Shift + N` starter standardeditoren din, som er Plain på nye installasjoner; velg Neovim under _Setup > Defaults > Editor_ for å få den til å starte Neovim i stedet. Men det er vanligvis enklere å styre det fra terminalen ved å navigere til mappen du vil jobbe i og skrive `n`. `n` er aliaset for `nvim`, som som standard bruker gjeldende mappe til å åpne. Du kan åpne en enkeltfil med `n myfile.txt`.

## Bruke Neovim til sudo-redigering

Hvis du trenger å redigere filer som du bare kan endre som superbruker, kjører du `sudoedit /etc/sudoers.d/00-sudo-only-file`. Det åpner standardeditoren din, så sett Neovim under _Setup > Defaults > Editor_ hvis du vil ha den der med alle pluginene dine.
