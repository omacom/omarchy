# Baggrunde

Hvert tema leveres med sit eget sæt baggrunde, og du kan tilføje dine egne ekstra i `~/.config/omarchy/backgrounds/[theme]`. Hvis du vil tilføje et ekstra baggrundsbillede til f.eks. nord-temaet, lægger du bare filen i `~/.config/omarchy/backgrounds/nord`.

Det gør du nemmest ved at gå til _Install > Style > Background_ i Omarchy Menu. Det åbner den mappe, hvor baggrundene til det pågældende tema ligger. Tryk på `Super + Shift + F` for at starte en anden filhåndtering, find din baggrund, og kopiér den over. Nu indgår den i de baggrunde, du kan vælge imellem med `Super + Ctrl + W`.

Baggrunde kan være videoer såvel som stillbilleder. Smid en `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- eller `avi`-fil i den samme mappe, og den vises sammen med billederne. Videoer afspilles af OWE-wallpaper-motoren. Den afkoder videoen én gang til alle skærme og afspiller dens lyd gennem standardlydoutputtet, og den stopper afspilningen, når intet kan se den. En videobaggrund bruger stadig langt mere strøm end en stillbilledebaggrund.

Temaer kan indeholde en kort intro til en stillbilledebaggrund. For `backgrounds/road.webp` ligger den tilhørende video på `backgrounds/intros/road.mp4`. Den afspilles automatisk ved opstart, når der skiftes til et tema med den pågældende baggrund valgt, og når den baggrund vælges, og vender derefter tilbage til stillbilledet. Introvideoer holdes ude af baggrundsvælgeren og loopes aldrig.

Hvis du slår _Appearance > Animations_ fra, slår du også baggrundsintroer fra. Omarchy gør dette som standard i en virtuel maskine. Kommandoen `omarchy theme bg intro toggle` kan slå introer til og fra separat. En opdatering af et tema afspiller ikke en intro.

Et stillbillede kan også have et loop, en rolig version af det samme billede, som bliver ved med at bevæge sig, på `backgrounds/loops/road.mp4`. Det afspilles i stedet for stillbilledet, efter dets intro, hvis det har en, og stopper, når animationer slås fra. På batteri vises stillbilledet i stedet, og loopet vender tilbage, når du sætter strøm til. Loops holdes ude af baggrundsvælgeren.

Du kan finde en kæmpe samling af fede, håndplukkede baggrunde i [dharmx/walls](https://github.com/dharmx/walls).

Låseskærmen viser et stillbillede fra en videobaggrund på samme måde, som den viser et stillbillede fra en animeret GIF.
