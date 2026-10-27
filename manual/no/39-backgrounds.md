# Bakgrunner

Hvert tema leveres med sitt eget sett med bakgrunner, og du kan legge til dine egne ekstra i `~/.config/omarchy/backgrounds/[theme]`. Hvis du vil legge til et ekstra bakgrunnsbilde til for eksempel nord-temaet, legger du bare filen i `~/.config/omarchy/backgrounds/nord`.

Du gjør dette enklest ved å gå til _Install > Style > Background_ i Omarchy Menu. Det åpner mappen der bakgrunnene for det temaet er lagret. Trykk `Super + Shift + F` for å starte en annen filbehandler, finn bakgrunnen din og kopier den over. Nå blir den inkludert blant bakgrunnene du kan velge mellom med `Super + Ctrl + W`.

Bakgrunner kan være videoer så vel som stillbilder. Legg en `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- eller `avi`-fil i samme mappe, så dukker den opp sammen med bildene. Videoer spilles av av OWE-bakgrunnsmotoren. Den dekoder videoen én gang for alle skjermer og spiller av lyden gjennom standard lydutgang, og den stopper avspillingen når ingenting kan se den. En videobakgrunn bruker likevel langt mer strøm enn en stillbildebakgrunn.

Temaer kan inkludere en kort intro for en stillbildebakgrunn. For `backgrounds/road.webp` ligger den tilhørende videoen på `backgrounds/intros/road.mp4`. Den spilles automatisk ved oppstart og når du bytter til et tema med den bakgrunnen valgt, og går deretter tilbake til stillbildet. Introvideoer holdes utenfor bakgrunnsvelgeren og går aldri i løkke.

Å slå av _Appearance > Animations_ slår også av bakgrunnsintroer. Omarchy gjør dette som standard i en virtuell maskin. Kommandoen `omarchy theme bg intro toggle` kan veksle introer separat. Å oppfriske et tema eller velge en annen bakgrunn innenfor samme tema spiller ikke av en intro.

Du finner en enorm samling kule, kuraterte bakgrunner i [dharmx/walls](https://github.com/dharmx/walls).

Låseskjermen viser et stillbilde fra en videobakgrunn, på samme måte som den viser et stillbilde fra en animert GIF.
