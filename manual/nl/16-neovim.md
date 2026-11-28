# Neovim

[Neovim](https://neovim.io/) is een moderne implementatie van [de vi-editor](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) die Bill Joy helemaal terug in 1976 heeft gemaakt. Het is een modale editor waarbij de invoegmodus en de commandmodus gescheiden zijn, en het is een beetje een superkracht zodra je ook maar een subset van de ongelooflijk diepe set toetscommando's leert. Maar de leercurve is ook behoorlijk steil!

Als je helemaal nieuw bent met vim-achtig bewerken, raad ik je aan om [ThePrimeagen's Vim As Your Editor-serie](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) op YouTube te bekijken. Daarmee leer je de basis. Weet alleen dat het, anders dan bij meer gangbare mainstream editors, langer zal duren voordat je vim enigszins onder de knie hebt. Maar zodra dat lukt, is de beloning ook groter.

Nu is Neovim in feite oneindig configureerbaar. Als je echt helemaal los wilt gaan, kun je je eigen Neovim-configuratie helemaal vanaf nul opbouwen. Er is een geweldige cursus van [Typecraft over het vanaf nul instellen van Neovim](https://www.youtube.com/watch?v=zHTeCSVAFNY). En [ThePrimeagen heeft er ook een](https://www.youtube.com/watch?v=w7i4amO_zaE).

Maar Omarchy wordt geleverd met een complete Neovim-setup — het `omarchy-nvim`-pakket — die met liefde is afgesteld om het beste te laten zien van wat er out of the box mogelijk is. Zonder dat je ook maar één regel configuratie hoeft te schrijven! Het is gebouwd op [LazyVim](https://www.lazyvim.org/), een distributie van Neovim-plugins en -configuraties. Het is geweldig.

## LazyVim-basisbeginselen

Zoals gezegd ga ik je in deze korte introductie geen vim leren, maar ik kan je wel een paar basisdingen van LazyVim laten zien, en hoe je je weg vindt.

Ten eerste heeft Neovim het idee van de leader-toets. Dat is in feite de toegangspoort tot alle commando's. LazyVim heeft die ingesteld op `Space`. Druk daar dus gewoon op, wacht een seconde, en je ziet een heleboel opties die inline worden uitgelegd, zoals dit:

Hier zijn een paar basiscommando's die ik de hele tijd gebruik:

- `Space Space` - Fuzzy-zoek naar een bestand in de huidige map.
- `Space S G` - Doorzoek alle bestanden met grep met een voorbeeldweergave.
- `Space E` - Schakel de bestandsboom in/uit.
- `Ctrl + W W` - Spring van de bestandsboom naar de editor en weer terug.
- `Shift + H` - Ga naar links tussen de open tabbladen (vim noemt ze buffers).
- `Shift + L` - Ga naar rechts tussen de open tabbladen.
- `Space B D` - Sluit een tabblad.
- `Space B O` - Sluit alle andere tabbladen behalve het huidige.
- `Space G G` - Start LazyGit in een zwevend paneel vanuit de huidige map.
- `Space U W` - Schakel zachte tekstterugloop in/uit.

Terwijl je in de bestandsboom zit (`Space E` om hem weer te geven, `Ctrl + W W` om ernaartoe te springen), kun je een nieuw bestand toevoegen met `a` of een nieuwe map met `A`. Druk op `?` terwijl je in de boom zit om alle commando's te zien.

Als je de basis van de vim-taal wilt oppikken, heb ik geschreven over [de driedelige syntaxis](https://world.hey.com/dhh/wonderful-vi-a1d034d3) en hoe je die vette combo-moves uitvoert!

Je kunt alle mogelijke commando's zien op [de LazyVim Keymaps-pagina](https://www.lazyvim.org/keymaps).

## Neovim starten

`Super + Shift + N` start je standaardeditor, dat is Plain op nieuwe installaties; kies Neovim onder _Setup > Defaults > Editor_ om in plaats daarvan Neovim te laten starten. Maar meestal is het makkelijker om het vanuit de terminal aan te sturen door naar de map te navigeren waarin je wilt werken en `n` te typen. De `n` is de alias voor `nvim`, die standaard de huidige map opent. Je kunt een enkel bestand openen met `n myfile.txt`.

## Neovim gebruiken voor sudo-bewerkingen

Als je bestanden moet bewerken die je alleen als superuser kunt wijzigen, voer dan `sudoedit /etc/sudoers.d/00-sudo-only-file` uit. Daarmee open je je standaardeditor, dus stel Neovim in onder _Setup > Defaults > Editor_ als je het daar wilt gebruiken met al je plugins.
