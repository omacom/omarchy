# Baggrunde

Hvert tema leveres med sit eget sæt baggrunde, og du kan tilføje dine egne ekstra i `~/.config/omarchy/backgrounds/[theme]`. Hvis du vil tilføje et ekstra baggrundsbillede til f.eks. nord-temaet, lægger du bare filen i `~/.config/omarchy/backgrounds/nord`.

Det gør du nemmest ved at gå til _Install > Style > Background_ i Omarchy Menu. Det åbner mappen, hvor baggrundene til det tema er gemt. Tryk på `Super + Shift + F` for at starte en anden filhåndtering, find din baggrund, og kopiér den over. Nu er den med blandt de baggrunde, du kan vælge imellem med `Super + Ctrl + W`.

Et tema uden egne baggrunde får en, der er tegnet ud fra dets farver: Omarchy-logoet i temaets accentfarve på dets baggrundsfarve. Tilføj din egen for at erstatte den.

Baggrunde kan også være videoer, ikke kun stillbilleder. Læg en `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- eller `avi`-fil i samme mappe, så vises den sammen med billederne. Videoer afspilles af OWE wallpaper engine. Den dekoder videoen én gang til alle skærme og afspiller lyden gennem standardlydudgangen, og den stopper afspilningen, når intet kan se den. En videobaggrund bruger stadig langt mere strøm end en stillbaggrund.

Temaer kan indeholde en kort intro til en stillbaggrund. Til `backgrounds/road.webp` ligger den tilhørende video på `backgrounds/intros/road.mp4`. Den afspilles automatisk ved opstart, når du skifter til et tema med den baggrund valgt, og når du vælger den baggrund, og vender derefter tilbage til stillbilledet. Introvideoer vises ikke i baggrundsvælgeren og loopes aldrig.

Hvis du vælger _Appearance > Animations Off_, slås baggrundsintroer også fra. Omarchy gør dette som standard i en virtual machine. Kommandoen `omarchy theme bg intro toggle` kan slå introer til og fra separat. En opdatering af et tema afspiller ikke en intro.

Et stillbillede kan også have et loop, en stille version af det samme billede, der bliver ved med at bevæge sig, på `backgrounds/loops/road.mp4`. Det afspilles i stedet for stillbilledet, efter dets intro, hvis det har en, og stopper, når animationer slås fra. På batteri vises stillbilledet i stedet, og loopet vender tilbage, når du sætter strøm til. Loops vises ikke i baggrundsvælgeren.

Du kan finde en kæmpe samling af fede, håndplukkede baggrunde i [dharmx/walls](https://github.com/dharmx/walls).

Låseskærmen viser et stillbillede fra en videobaggrund, på samme måde som den viser et stillbillede fra en animeret GIF.
