# Bakgrunner

Hvert tema leveres med sitt eget sett med bakgrunner, og du kan legge til dine egne ekstrabakgrunner i `~/.config/omarchy/backgrounds/[theme]`. Hvis du vil legge til et ekstra bakgrunnsbilde til for eksempel nord-temaet, legger du bare filen i `~/.config/omarchy/backgrounds/nord`.

Du gjør dette enklest ved å gå til _Installer > Stil > Bakgrunn_ i Omarchy-menyen. Det åpner mappen der bakgrunnene for det temaet er lagret. Trykk `Super + Shift + F` for å starte en ny filbehandler, finn bakgrunnen din og kopier den over. Nå blir den inkludert i bakgrunnene du kan velge mellom med `Super + Ctrl + Space`.

Bakgrunner kan være videoer i tillegg til stillbilder. Slipp en `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- eller `avi`-fil i samme mappe, så dukker den opp ved siden av bildene. Videoer spilles av av OWE-bakgrunnsmotoren. Den dekoder videoen én gang for alle skjermer og spiller lyden gjennom standard lydutgang, og den stopper avspillingen når ingenting kan se den. Låseskjermen tegner samme dekoding, dempet, gjennom OWE. En videobakgrunn koster likevel langt mer strøm enn en stillbildebakgrunn.

Temaer kan inkludere en kort intro for en stillbildebakgrunn. For `backgrounds/road.webp` ligger den matchende videoen på `backgrounds/intros/road.mp4`. Den spilles av automatisk ved oppstart og når du bytter til et tema med den bakgrunnen valgt, og går deretter tilbake til stillbildet. Introvideoer holder seg ute av bakgrunnsvelgeren og looper aldri.

Å slå av _Utløs > Utseende > Animasjoner_ slår også av bakgrunnsintroer. Omarchy gjør dette som standard i en virtuell maskin. Kommandoen `omarchy theme bg intro toggle` kan slå introer av/på separat. Å oppdatere et tema eller velge en annen bakgrunn innenfor samme tema spiller ikke av en intro.

Du finner en enorm samling av kule, kuraterte bakgrunner på https://github.com/dharmx/walls.

Videobakgrunner beholder et bufret stillbilde på låseskjermen mens avspillingen er satt på pause eller utilgjengelig. Animerte GIF-er spilles av på skrivebordet og viser et stillbilde på låseskjermen.
