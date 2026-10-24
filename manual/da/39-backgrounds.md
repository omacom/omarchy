# Baggrunde

Hvert tema leveres med sit eget sæt baggrunde, og du kan tilføje ekstra af dine egne i `~/.config/omarchy/backgrounds/[theme]`. Hvis du vil tilføje et ekstra baggrundsbillede til f.eks. nord-temaet, lægger du bare filen i `~/.config/omarchy/backgrounds/nord`.

Det gør du lettest ved at gå til _Installer > Stil > Baggrund_ i Omarchy-menuen. Det åbner mappen, hvor baggrundene til det tema er gemt. Tryk `Super + Shift + F` for at starte en anden filhåndtering, find din baggrund, og kopiér den over. Nu vil den være inkluderet i valgmulighederne for baggrunde, du kan vælge imellem med `Super + Ctrl + Space`.

Baggrunde kan være videoer såvel som stillbilleder. Læg en `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- eller `avi`-fil i samme mappe, og den vises sammen med billederne. Videoer afspilles af OWE-baggrundsmotoren. Den dekoder videoen én gang til alle skærme og afspiller dens lyd gennem standardlydoutputtet, og den stopper afspilningen, når intet kan se den. Låseskærmen tegner den samme dekodning, slået fra, gennem OWE. En videobaggrund koster stadig langt mere strøm end et stillbillede.

Temaer kan inkludere en kort intro til en still-baggrund. Til `backgrounds/road.webp` bor den matchende video på `backgrounds/intros/road.mp4`. Den afspilles automatisk ved opstart og ved skift til et tema med den baggrund valgt og vender derefter tilbage til stillbilledet. Introvideoer holder sig ude af baggrundsvælgeren og looper aldrig.

At slukke _Udløs > Udseende > Animationer_ slukker også for baggrundsintroer. Omarchy gør det som standard i en virtuel maskine. Kommandoen `omarchy theme bg intro toggle` kan slå introer til/fra separat. At opdatere et tema eller vælge en anden baggrund inden for samme tema afspiller ikke en intro.

Du kan finde en kæmpe samling af fede, kuraterede baggrunde på https://github.com/dharmx/walls.

Videobaggrunde beholder et cachet stillbillede på låseskærmen, mens afspilning er sat på pause eller utilgængelig. Animerede GIF'er afspilles på skrivebordet og viser et stillbillede på låseskærmen.
