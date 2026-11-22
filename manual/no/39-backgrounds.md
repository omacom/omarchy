# Bakgrunner

Hvert tema leveres med sitt eget sett med bakgrunner, og du kan legge til dine egne ekstra i `~/.config/omarchy/backgrounds/[theme]`. Hvis du vil legge til et ekstra bakgrunnsbilde i for eksempel nord-temaet, legger du bare filen i `~/.config/omarchy/backgrounds/nord`.

Du kan gjøre dette enklest ved å gå til _Install > Style > Background_ i Omarchy Menu. Det åpner mappen der bakgrunnene for det temaet er lagret. Trykk `Super + Shift + F` for å starte en annen filbehandler, finn bakgrunnen din, og kopier den over. Nå blir den med blant bakgrunnene du kan velge mellom med `Super + Ctrl + W`.

Bakgrunner kan være videoer i tillegg til stillbilder. Legg en `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- eller `avi`-fil i samme mappe, så dukker den opp sammen med bildene. Videoer spilles av av OWE wallpaper engine. Den dekoder videoen én gang for alle skjermer og spiller av lyden gjennom standard lydutgang, og den stopper avspillingen når ingenting kan se den. En videobakgrunn bruker likevel langt mer strøm enn en stillbildebakgrunn.

Temaer kan ha en kort intro for en stillbildebakgrunn. For `backgrounds/road.webp` ligger den tilhørende videoen på `backgrounds/intros/road.mp4`. Den spilles av automatisk ved oppstart, når du bytter til et tema med den bakgrunnen valgt, og når du velger den bakgrunnen, og går deretter tilbake til stillbildet. Introvideoer holdes utenfor bakgrunnsvelgeren og går aldri i loop.

Å velge _Appearance > Animations Off_ slår også av bakgrunnsintroer. Omarchy gjør dette som standard i en virtual machine. Kommandoen `omarchy theme bg intro toggle` kan slå introer av og på separat. Å oppdatere et tema spiller ikke av en intro.

Et stillbilde kan også ha en loop, en rolig versjon av samme bilde som holder seg i bevegelse, på `backgrounds/loops/road.mp4`. Den spilles av i stedet for stillbildet, etter introen hvis det har en, og stopper når animasjoner er slått av. På batteri vises stillbildet i stedet, og loopen kommer tilbake når du kobler til strøm. Looper holdes utenfor bakgrunnsvelgeren.

Du finner en enorm samling av kule kuraterte bakgrunner i [dharmx/walls](https://github.com/dharmx/walls).

Låseskjermen viser et stillbilde fra en videobakgrunn, på samme måte som den viser et stillbilde fra en animert GIF.
