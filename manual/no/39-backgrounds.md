# Bakgrunner

Hvert tema leveres med sitt eget sett med bakgrunner, og du kan legge til ekstra av dine egne i `~/.config/omarchy/backgrounds/[theme]`. Hvis du vil legge til et ekstra bakgrunnsbilde til for eksempel nord-temaet, legger du bare filen i `~/.config/omarchy/backgrounds/nord`.

Dette gjør du enklest ved å gå til _Install > Style > Background_ i Omarchy-menyen. Det åpner mappen der bakgrunnene for det temaet er lagret. Trykk `Super + Shift + F` for å starte en annen filbehandler, finn bakgrunnen din og kopier den over. Nå blir den med blant bakgrunnene du kan velge mellom med `Super + Ctrl + W`.

Bakgrunner kan være videoer så vel som stillbilder. Legg en `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- eller `avi`-fil i den samme mappen, så dukker den opp sammen med bildene. Videoer spilles av av OWE-bakgrunnsmotoren. Den dekoder videoen én gang for alle skjermer og spiller av lyden gjennom standard lydutgang, og den stopper avspillingen når ingenting kan se den. En videobakgrunn bruker likevel langt mer strøm enn en stillbakgrunn.

Temaer kan inkludere en kort intro for en stillbakgrunn. For `backgrounds/road.webp` ligger den tilhørende videoen i `backgrounds/intros/road.mp4`. Den spilles av automatisk ved oppstart, når du bytter til et tema med den bakgrunnen valgt, og når du velger den bakgrunnen, og går deretter tilbake til stillbildet. Introvideoer holdes utenfor bakgrunnsvelgeren og looper aldri.

Å slå av _Appearance > Animations_ slår også av bakgrunnsintroer. Omarchy gjør dette som standard i en virtuell maskin. Kommandoen `omarchy theme bg intro toggle` kan slå introer av og på separat. Å oppdatere et tema spiller ikke av en intro.

Du finner en enorm samling kule, kuraterte bakgrunner i [dharmx/walls](https://github.com/dharmx/walls).

Låseskjermen viser et stillbilde av en videobakgrunn, på samme måte som den viser et stillbilde av en animert GIF.
