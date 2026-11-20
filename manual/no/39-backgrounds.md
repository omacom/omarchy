# Bakgrunner

Hvert tema leveres med sitt eget sett med bakgrunner, og du kan legge til dine egne ekstra i `~/.config/omarchy/backgrounds/[theme]`. Hvis du for eksempel vil legge til et ekstra bakgrunnsbilde i temaet nord, legger du bare filen i `~/.config/omarchy/backgrounds/nord`.

Dette gjør du enklest ved å gå til _Installer > Stil > Bakgrunn_ i Omarchy-menyen. Da får du opp mappen der bakgrunnene for det temaet er lagret. Trykk `Super + Shift + F` for å starte en filbehandler til, finn bakgrunnen din og kopier den over. Nå blir den med blant bakgrunnene du kan velge mellom med `Super + Ctrl + W`.

Bakgrunner kan være videoer så vel som stillbilder. Slipp en `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- eller `avi`-fil i samme mappe, så dukker den opp sammen med bildene. Videoer spilles av av bakgrunnsmotoren OWE. Den dekoder videoen én gang for alle skjermer og spiller av lyden gjennom standard lydutgang, og den stopper avspillingen når ingenting kan se den. En videobakgrunn bruker likevel langt mer strøm enn en bakgrunn med stillbilde.

Temaer kan inneholde en kort intro til en bakgrunn med stillbilde. For `backgrounds/road.webp` ligger den tilhørende videoen i `backgrounds/intros/road.mp4`. Den spilles av automatisk ved oppstart, når du bytter til et tema der den bakgrunnen er valgt, og når du velger den bakgrunnen, og går deretter tilbake til stillbildet. Introvideoer holdes utenfor bakgrunnsvelgeren og går aldri i løkke.

Hvis du slår av _Utseende > Animasjoner_, slår du også av bakgrunnsintroer. Omarchy gjør dette som standard i en virtuell maskin. Med kommandoen `omarchy theme bg intro toggle` kan du slå introer av og på separat. Å oppdatere et tema spiller ikke av noen intro.

Et stillbilde kan også ha en loop, en rolig versjon av det samme bildet som holder seg i bevegelse, i `backgrounds/loops/road.mp4`. Den spilles av i stedet for stillbildet, etter introen hvis det finnes en, og stopper når animasjoner slås av. På batteri vises stillbildet i stedet, og loopen kommer tilbake når du kobler til strøm igjen. Looper holdes utenfor bakgrunnsvelgeren.

Du finner en enorm samling med kule, håndplukkede bakgrunner i [dharmx/walls](https://github.com/dharmx/walls).

Låseskjermen viser et stillbilde fra en videobakgrunn, på samme måte som den viser et stillbilde fra en animert GIF.
