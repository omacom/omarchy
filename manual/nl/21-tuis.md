# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) is een heerlijk alternatief voor zoiets als de GitHub Desktop-applicatie, en het draait in de terminal.

Je kunt het rechtstreeks uitvoeren door naar een willekeurige directory te gaan die door git wordt beheerd en `lazygit` uit te voeren. Of je kunt het in Neovim uitvoeren, waar het kan worden gestart met `Space G G`.

Je springt tussen de verschillende deelvensters met `Tab`. In het deelvenster Files selecteer je bestanden om te stagen met `Space`, en daarna kun je een nieuwe commit maken met `c`. Je kunt alle beschikbare commando's zien met `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) is een prachtige resourcemanager die geheugen-, CPU-, schijf- en netwerkgebruik toont. Hij toont ook alle actieve processen en laat je die beheren.

Omarchy noemt het Activity Monitor, en je start het vanuit de applicatiestarter of door op `Super + Shift + T` te drukken. Het opent als een zwevend venster, dat je kunt tegelen met `Super + T`.

## Herdr

[Herdr](https://herdr.dev) is een terminal workspace manager die je workspaces, tabbladen en deelvensters geeft, en ze allemaal draaiende houdt in een persistente sessie waarvan je kunt loskoppelen en waar je later naar kunt terugkeren.

Je start het (of maakt opnieuw verbinding met je bestaande sessie) vanuit de applicatiestarter of met `Super + Ctrl + Return`. Omarchy levert een Herdr-configuratie die zijn Tmux-configuratie spiegelt, dus de prefix-toets is hier ook `Ctrl + Space`. Je kunt alle sneltoetsen bekijken met `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) toont systeeminformatie, zoals kernelversie, uptime, thema, CPU, geheugen en meer. Het is een opvolger van de populaire neofetch-tool.

Omarchy heeft dit verpakt als _System > About_ in het Omarchy-menu (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) is een retro muziekspeler voor de terminal, geïnspireerd door Winamp 2.x, compleet met ingebouwde radiostations voor lo-fi beats. Start het met `Super + Shift + Alt + M`, of vanuit het Omarchy-menu onder _Apps_. Druk op `?` voor de volledige lijst met sneltoetsen.

## En Wi-Fi en Bluetooth dan?

Je vindt geen TUIs voor Wi-Fi en Bluetooth — die taken horen bij de Omarchy-shell. Klik op het Wi-Fi-pictogram in de bovenste balk (of druk op `Super + Ctrl + N`) om netwerken te zien en verbinding te maken, en klik op het Bluetooth-pictogram (of druk op `Super + Ctrl + B`) om apparaten te koppelen en te verbinden. Zie [netwerken](35-networking.md) voor het volledige verhaal.

## Je eigen toevoegen

Elk terminalprogramma kan de volledige app-behandeling krijgen. Ga naar _Install > TUI_ in het Omarchy-menu (`Super + Space`), geef het een naam, een startcommando, een vensterstijl en een pictogram, en het verschijnt in de applicatiestarter net als elke andere applicatie. Je kunt het weer verwijderen onder _Remove > TUI_.
