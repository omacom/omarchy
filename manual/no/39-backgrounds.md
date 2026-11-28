# Bakgrunner

Hvert tema leveres med sitt eget sett med bakgrunner, og du kan legge til ekstra bakgrunner selv i `~/.config/omarchy/backgrounds/[theme]`. Hvis du vil legge til et ekstra bakgrunnsbilde i for eksempel nord-temaet, legger du bare filen i `~/.config/omarchy/backgrounds/nord`.

Du kan gjøre dette enklest ved å gå til _Installer > Stil > Bakgrunn_ i Omarchy Menu. Da åpnes mappen der bakgrunnene for det temaet er lagret. Trykk `Super + Shift + F` for å starte en annen filbehandler, finn bakgrunnen din, og kopier den over. Nå er den med blant bakgrunnene du kan velge mellom med `Super + Ctrl + W`.

Et tema uten egne bakgrunner får én som er tegnet ut fra fargene sine: Omarchy-logoen i temaets aksentfarge på temaets bakgrunnsfarge. Legg til dine egne for å erstatte den.

Bakgrunner kan være videoer så vel som stillbilder. Legg en `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- eller `avi`-fil i samme mappe, så dukker den opp sammen med bildene. Videoer spilles av av OWE-bakgrunnsmotoren. Den dekoder videoen én gang for alle skjermer og spiller av lyden gjennom standard lydutgang, og den stopper avspillingen når ingenting kan se den. En videobakgrunn bruker likevel langt mer strøm enn en stillbildebakgrunn.

Temaer kan ha en kort intro for en stillbildebakgrunn. For `backgrounds/road.webp` ligger den tilhørende videoen på `backgrounds/intros/road.mp4`. Den spilles av automatisk ved oppstart, når du bytter til et tema med den bakgrunnen valgt, og når du velger den bakgrunnen, og går deretter tilbake til stillbildet. Introvideoer vises ikke i bakgrunnsvelgeren og spilles aldri i løkke.

Å velge _Utseende > Animasjoner av_ slår også av bakgrunnsintroer. Omarchy gjør dette som standard i en virtuell maskin. Kommandoen `omarchy theme bg intro toggle` kan slå introer av og på separat. Å oppdatere et tema spiller ikke av en intro.

Et stillbilde kan også ha en løkke, en rolig versjon av det samme bildet som holder seg i bevegelse, på `backgrounds/loops/road.mp4`. Den spilles av i stedet for stillbildet, etter introen hvis det har en, og stopper når animasjoner er slått av. På batteri vises stillbildet i stedet, og løkken kommer tilbake når du kobler til strøm. Løkker vises ikke i bakgrunnsvelgeren.

Du finner en enorm samling av kule, kuraterte bakgrunner i [dharmx/walls](https://github.com/dharmx/walls).

Låseskjermen viser et stillbilde fra en videobakgrunn, på samme måte som den viser et stillbilde fra en animert GIF.
