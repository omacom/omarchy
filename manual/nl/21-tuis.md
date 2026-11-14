# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) is een heerlijk alternatief voor zoiets als de GitHub Desktop-applicatie, en het draait in de terminal.

Je kunt het rechtstreeks draaien door naar een willekeurige directory te gaan die door git wordt beheerd en `lazygit` uit te voeren. Of je kunt het in Neovim draaien, waar het kan worden gestart met `Space G G`.

Je springt met `Tab` tussen de verschillende deelvensters. In het Files-deelvenster selecteer je bestanden om te stagen met `Space`, en daarna kun je met `c` een nieuwe commit maken. Je kunt alle beschikbare commando's zien met `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) is een prachtige resourcemanager die geheugen-, CPU-, schijf- en netwerkgebruik toont. Hij toont ook alle actieve processen en laat je die beheren.

Omarchy noemt het Activity, en je start het door op `Super + Shift + T` te drukken. Het opent als een zwevend venster, dat je met `Super + T` kunt tegelen.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) is een terminal-werkruimtemanager die je werkruimtes, tabbladen en deelvensters geeft, en ze allemaal laat draaien in een persistente sessie waar je je van kunt loskoppelen en later naar terug kunt keren.

Je start het (of koppelt opnieuw aan je bestaande sessie) met `Super + Ctrl + Return`. Omarchy levert een Herdr-configuratie die zijn Tmux-config spiegelt, dus de prefix-toets is hier ook `Ctrl + Space`. Je kunt alle sneltoetsen bekijken met `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) toont systeeminformatie, zoals kernelversie, uptime, thema, CPU, geheugen en meer. Het is een opvolger van de populaire neofetch-tool.

Omarchy heeft dit verpakt als _About_ in het Omarchy-menu (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) is een retro muziekspeler voor de terminal, geïnspireerd door Winamp 2.x, compleet met ingebouwde radiostations voor lo-fi beats. Start het met `Super + Shift + Alt + M`, of vanuit het Omarchy-menu onder _Apps_. Druk op `?` voor de volledige lijst met sneltoetsen.

## En hoe zit het met Wi-Fi en Bluetooth?

Je zult geen TUIs vinden voor Wi-Fi en Bluetooth — die taken horen bij de Omarchy-shell. Klik op het Wi-Fi-pictogram in de bovenbalk (of druk op `Super + Ctrl + N`) om netwerken te zien en verbinding te maken, en klik op het Bluetooth-pictogram (of druk op `Super + Ctrl + B`) om apparaten te koppelen en te verbinden. Zie [netwerken](35-networking.md) voor het volledige verhaal.

## Je eigen toevoegen

Elk terminalprogramma kan de volledige app-behandeling krijgen. Ga naar _Install > TUI_ in het Omarchy-menu (`Super + Space`), geef het een naam, een startcommando, een vensterstijl en een pictogram, en het verschijnt in de app-launcher zoals elke andere applicatie. Je kunt het weer verwijderen onder _Remove > TUI_.
