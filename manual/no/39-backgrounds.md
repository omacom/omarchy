# Bakgrunner

Hvert tema leveres med sitt eget sett med bakgrunner, og du kan legge til ekstra bakgrunner selv i `~/.config/omarchy/backgrounds/[theme]`. Hvis du for eksempel vil legge til et ekstra bakgrunnsbilde i nord-temaet, legger du bare filen i `~/.config/omarchy/backgrounds/nord`.

Du gjør dette enklest ved å gå til _Installer > Stil > Bakgrunn_ i Omarchy-menyen. Da åpnes mappen der bakgrunnene for det temaet er lagret. Trykk på `Super + Shift + F` for å starte en annen filbehandler, finn bakgrunnen din, og kopier den over. Nå blir den med blant bakgrunnene du kan velge mellom med `Super + Ctrl + W`.

Bakgrunner kan være videoer så vel som stillbilder. Slipp en `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- eller `avi`-fil i den samme mappen, så vises den sammen med bildene. Videoer spilles av av OWE-bakgrunnsmotoren. Den dekoder videoen én gang for alle skjermer og spiller av lyden gjennom standard lydutgang, og den stopper avspillingen når ingenting kan se den. En bakgrunn med video koster likevel langt mer strøm enn en med stillbilde.

Temaer kan inneholde en kort intro for en bakgrunn med stillbilde. For `backgrounds/road.webp` ligger den tilhørende videoen på `backgrounds/intros/road.mp4`. Den spilles av automatisk ved oppstart og når du bytter til et tema med den bakgrunnen valgt, og går deretter tilbake til stillbildet. Introvideoer holdes utenfor bakgrunnsvelgeren og går aldri i løkke.

Å slå av _Utseende > Animasjoner_ slår også av bakgrunnsintroer. Omarchy gjør dette som standard i en virtuell maskin. Kommandoen `omarchy theme bg intro toggle` kan slå introer av og på separat. Å oppdatere et tema eller velge en annen bakgrunn i det samme temaet spiller ikke av en intro.

Du finner en enorm samling kule, håndplukkede bakgrunner på https://github.com/dharmx/walls.

Låseskjermen viser et stillbilde fra en videobakgrunn, på samme måte som den viser et stillbilde fra en animert GIF.
