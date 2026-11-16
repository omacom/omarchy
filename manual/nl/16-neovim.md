# Neovim

[Neovim](https://neovim.io/) is een moderne implementatie van [de vi-editor](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) gemaakt door Bill Joy helemaal terug in 1976. Het is een modale editor waarbij insert-modus en commandomodus gescheiden zijn, en het is een soort superkracht zodra je zelfs maar een subset van de ongelooflijk diepe toetscommando-set leert. Maar het is ook best een leercurve!

Als je helemaal nieuw bent met vim-stijl bewerken, raad ik je aan om [ThePrimeagen's Vim As Your Editor-serie](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) op YouTube te bekijken. Dat leert je de basis. Weet alleen dat het, in tegenstelling tot meer vergelijkbare mainstream editors, langer zal duren om basisvaardigheid met vim te krijgen. Maar zodra je dat doet, is de beloning ook groter.

Nu is Neovim in principe oneindig configureerbaar. Als je echt helemaal los wilt gaan, kun je je eigen Neovim-configuratie vanaf nul maken. Er is een geweldige cursus van [Typecraft over het opzetten van Neovim vanaf nul](https://www.youtube.com/watch?v=zHTeCSVAFNY). En [ThePrimeagen heeft er ook een](https://www.youtube.com/watch?v=w7i4amO_zaE).

Maar Omarchy wordt geleverd met een complete Neovim-setup — het `omarchy-nvim`-pakket — dat liefdevol is afgestemd om het beste te laten zien van wat er direct uit de doos mogelijk is. Zonder dat je een enkele regel configuratie hoeft te schrijven! Het is gebouwd op [LazyVim](https://www.lazyvim.org/), een distributie van Neovim-plugins en configuraties. Het is geweldig.

## LazyVim-basis

Zoals gezegd ga ik je geen vim leren in deze korte introductie, maar ik kan je een paar basics van LazyVim laten zien, en hoe je je weg vindt.

Ten eerste heeft Neovim het idee van de leader-toets. Dat is in principe de toegangspoort tot alle commando's. LazyVim heeft die ingesteld op `Space`. Dus druk daar gewoon op, wacht een seconde, en je ziet een heleboel opties inline uitgelegd als volgt:

Hier zijn een paar basiscommando's die ik constant gebruik:

- `Space Space` - Fuzzy-zoek elk bestand in de huidige map.
- `Space S G` - Doorzoek alle bestanden met grep met een preview.
- `Space E` - Schakel de bestandsboom aan/uit.
- `Ctrl + W W` - Spring van de bestandsboom naar de editor en terug.
- `Shift + H` - Beweeg naar links tussen de open tabbladen (vim noemt ze buffers).
- `Shift + L` - Beweeg naar rechts tussen de open tabbladen.
- `Space B D` - Sluit een tabblad.
- `Space B O` - Sluit alle andere tabbladen behalve het huidige.
- `Space G G` - Start LazyGit in een zwevende pane vanuit de huidige map.
- `Space U W` - Schakel zachte regelterugloop.

Terwijl je in de bestandsboom bent (`Space E` om te onthullen, `Ctrl + W W` om ernaartoe te springen), kun je een nieuw bestand toevoegen met `a` of een nieuwe map met `A`. Druk op `?` terwijl je in de boom bent om alle commando's te zien.

Als je de basis vim-taal wilt oppikken, heb ik geschreven over [de driedelige syntaxis](https://world.hey.com/dhh/wonderful-vi-a1d034d3) en hoe je die vette combo-moves uitvoert!

Je kunt alle mogelijke commando's zien op [de LazyVim Keymaps-pagina](https://www.lazyvim.org/keymaps).

## Neovim starten

Je kunt Neovim starten met `Super + Shift + N` (de binding start je standaardeditor, wat direct uit de doos Neovim is), maar het is meestal gemakkelijker om het vanuit de terminal aan te sturen door te navigeren naar de map waarin je wilt werken en `n` te typen. De `n` is de alias voor `nvim`, die standaard de huidige map gebruikt om te openen. Je kunt een enkel bestand openen met `n myfile.txt`.

## Neovim gebruiken voor sudo-bewerkingen

Als je bestanden moet bewerken die je alleen als superuser kunt veranderen, kun je neovim met al je plugins gebruiken door `sudoedit /etc/sudoers.d/00-sudo-only-file` uit te voeren.
