# Baggrunde

Hvert tema leveres med sit eget sæt af baggrunde, og du kan tilføje dine egne ekstra i `~/.config/omarchy/backgrounds/[theme]`. Hvis du vil føje et ekstra baggrundsbillede til f.eks. nord-temaet, lægger du bare filen i `~/.config/omarchy/backgrounds/nord`.

Det gør du nemmest ved at gå til _Install > Style > Background_ i Omarchy Menu. Det åbner mappen, hvor baggrundene til det pågældende tema er gemt. Tryk på `Super + Shift + F` for at starte endnu en filhåndtering, find din baggrund, og kopiér den over. Nu er den med blandt de baggrunde, du kan vælge imellem med `Super + Ctrl + W`.

Baggrunde kan være videoer såvel som stillbilleder. Læg en fil i formatet `mp4`, `m4v`, `mov`, `webm`, `mkv` eller `avi` i samme mappe, så vises den sammen med billederne. Videoer afspilles af OWE wallpaper engine. Den dekoder videoen én gang til alle skærme og afspiller lyden gennem standardlydudgangen, og den stopper afspilningen, når der ikke er noget, der kan se den. En videobaggrund bruger stadig langt mere strøm end en stillbaggrund.

Temaer kan indeholde en kort intro til en stillbaggrund. For `backgrounds/road.webp` ligger den tilhørende video på `backgrounds/intros/road.mp4`. Den afspilles automatisk ved opstart, når du skifter til et tema med den baggrund valgt, og når du vælger den baggrund, og vender derefter tilbage til stillbilledet. Introvideoer vises ikke i baggrundsvælgeren og looper aldrig.

Hvis du slår _Appearance > Animations_ fra, slår du også baggrundsintroer fra. Omarchy gør det som standard i en virtuel maskine. Kommandoen `omarchy theme bg intro toggle` kan slå introer til og fra separat. Opdatering af et tema afspiller ikke en intro.

Du kan finde en kæmpe samling af fede, kuraterede baggrunde i [dharmx/walls](https://github.com/dharmx/walls).

Låseskærmen viser et stillbillede fra en videobaggrund på samme måde, som den viser et stillbillede fra en animeret GIF.
