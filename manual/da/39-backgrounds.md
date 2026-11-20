# Baggrunde

Hvert tema leveres med sit eget sæt baggrunde, og du kan tilføje dine egne ekstra i `~/.config/omarchy/backgrounds/[theme]`. Hvis du vil tilføje et ekstra baggrundsbillede til f.eks. nord-temaet, lægger du bare filen i `~/.config/omarchy/backgrounds/nord`.

Det gør du nemmest ved at gå til _Install > Style > Background_ i Omarchy Menu. Det åbner mappen, hvor baggrundene til det tema er gemt. Tryk på `Super + Shift + F` for at starte en anden filhåndtering, find din baggrund, kopiér den over. Nu er den med blandt de baggrunde, du kan vælge imellem med `Super + Ctrl + W`.

Baggrunde kan være videoer såvel som stillbilleder. Smid en `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- eller `avi`-fil i den samme mappe, så vises den sammen med billederne. Videoer afspilles af OWE wallpaper engine. Den afkoder videoen én gang til alle skærme og afspiller dens lyd gennem standardlydudgangen, og den stopper afspilningen, når ingenting kan se den. En videobaggrund koster stadig langt mere strøm end en stillbaggrund.

Temaer kan indeholde en kort intro til en stillbaggrund. For `backgrounds/road.webp` ligger den tilsvarende video på `backgrounds/intros/road.mp4`. Den afspilles automatisk ved opstart, når der skiftes til et tema med den baggrund valgt, og når den baggrund vælges, og vender derefter tilbage til stillbilledet. Introvideoer vises ikke i baggrundsvælgeren og looper aldrig.

Slår du _Appearance > Animations_ fra, slår du også baggrundsintroer fra. Omarchy gør dette som standard i en virtuel maskine. Kommandoen `omarchy theme bg intro toggle` kan slå introer til og fra separat. Opdatering af et tema afspiller ikke en intro.

Et stillbillede kan også have et loop, en rolig version af det samme billede, der bliver ved med at bevæge sig, på `backgrounds/loops/road.mp4`. Det afspilles i stillbilledets sted, efter dets intro, hvis det har en, og stopper, når animationer slås fra. Loops vises ikke i baggrundsvælgeren og koster, som enhver videobaggrund, mere strøm end et stillbillede.

Du kan finde en kæmpe samling af fede, nøje udvalgte baggrunde i [dharmx/walls](https://github.com/dharmx/walls).

Låseskærmen viser et stillbillede fra en videobaggrund på samme måde, som den viser et stillbillede fra en animeret GIF.
