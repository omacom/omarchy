# Baggrunde

Hvert tema leveres med sit eget sæt baggrunde, og du kan tilføje ekstra af dine egne i `~/.config/omarchy/backgrounds/[theme]`. Hvis du vil tilføje et ekstra baggrundsbillede til f.eks. nord-temaet, lægger du bare filen i `~/.config/omarchy/backgrounds/nord`.

Det gør du nemmest ved at gå til _Installer > Stil > Baggrund_ i Omarchy Menu. Det åbner mappen, hvor baggrundene til det tema er gemt. Tryk på `Super + Shift + F` for at starte en anden filhåndtering, find din baggrund, og kopier den over. Nu vil den være med blandt de baggrunde, du kan vælge imellem med `Super + Ctrl + W`.

Baggrunde kan være videoer såvel som stillbilleder. Smid en `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- eller `avi`-fil i samme mappe, så vises den sammen med billederne. Videoer afspilles af OWE-baggrundsmotoren. Den afkoder videoen én gang til alle skærme og afspiller dens lyd gennem standardlydoutputtet, og den stopper afspilningen, når intet kan se den. En videobaggrund bruger stadig langt mere strøm end en stillbilledebaggrund.

Temaer kan indeholde en kort intro til en stillbaggrund. For `backgrounds/road.webp` ligger den tilsvarende video på `backgrounds/intros/road.mp4`. Den afspilles automatisk ved opstart og ved skift til et tema med den baggrund valgt, og vender derefter tilbage til stillbilledet. Introvideoer vises ikke i baggrundsvælgeren og looper aldrig.

Hvis du slår _Udseende > Animationer_ fra, slår du også baggrundsintroer fra. Omarchy gør dette som standard i en virtuel maskine. Kommandoen `omarchy theme bg intro toggle` kan slå introer til og fra separat. Opdatering af et tema eller valg af en anden baggrund inden for samme tema afspiller ikke en intro.

Du kan finde en kæmpe samling af fede, nøje udvalgte baggrunde i [dharmx/walls](https://github.com/dharmx/walls).

Låseskærmen viser et stillbillede af en videobaggrund, på samme måde som den viser et stillbillede af en animeret GIF.
