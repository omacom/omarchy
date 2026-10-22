# TUI's

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) is een heerlijk alternatief voor iets als de GitHub Desktop-applicatie, en het draait in de terminal.

Je kunt het direct uitvoeren door naar een willekeurige map te gaan die door git wordt beheerd en `lazygit` uit te voeren. Of je kunt het in Neovim uitvoeren, waar het gestart kan worden met `Space G G`.

Je springt tussen de verschillende panelen met `Tab`. In het Files-paneel selecteer je bestanden voor staging met `Space`, en daarna kun je een nieuwe commit maken met `c`. Je kunt alle beschikbare commando's zien met `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) is een prachtige resource-manager die geheugen-, CPU-, schijf- en netwerkgebruik toont. Het toont ook alle actieve processen en laat je ze beheren.

Omarchy noemt het Activity, en je start het door op `Super + Ctrl + T` te drukken. Het opent als een zwevend venster, dat je kunt betegelen met `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) is een terminal workspace manager die je workspaces, tabs en panelen geeft, en ze allemaal draaiende houdt in een persistente sessie waar je van kunt loskoppelen en later naar terug kunt komen.

Je start het (of koppelt opnieuw aan je bestaande sessie) met `Super + Ctrl + Return`. Omarchy levert een Herdr-configuratie die de Tmux-configuratie weerspiegelt, dus de prefix-toets is hier ook `Ctrl + Space`. Je kunt alle sneltoetsen doorbladeren met `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) toont systeeminformatie, zoals kernelversie, uptime, thema, CPU, geheugen en meer. Het is een opvolger van de populaire neofetch-tool.

Omarchy heeft dit verpakt als _Over_ in het Omarchy-menu (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) is een retro terminal-muziekspeler geïnspireerd door Winamp 2.x, compleet met ingebouwde radiostations voor lo-fi beats. Start het met `Super + Shift + Alt + M`, of vanuit het Omarchy-menu onder _Apps_. Druk op `?` voor de volledige sneltoetsenlijst.

## Hoe zit het met wifi en Bluetooth?

Je vindt geen TUI's voor wifi en Bluetooth — die taken horen bij de Omarchy-shell. Klik op het wifi-pictogram in de menubalk (of druk op `Super + Ctrl + W`) om netwerken te zien en verbinding te maken, en klik op het Bluetooth-pictogram (of druk op `Super + Ctrl + B`) om apparaten te koppelen en te verbinden. Zie [netwerken](35-networking.md) voor het volledige verhaal.

## Je eigen toevoegen

Elk terminalprogramma kan de volledige app-behandeling krijgen. Ga naar _Installeren > TUI_ in het Omarchy-menu (`Super + Space`), geef het een naam, een startcommando, een vensterstijl en een pictogram, en het verschijnt in de app-launcher zoals elke andere applicatie. Je kunt het weer verwijderen onder _Verwijderen > TUI_.
