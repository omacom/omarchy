# Achtergronden

Elk thema wordt geleverd met zijn eigen set achtergronden, en je kunt zelf extra achtergronden toevoegen in `~/.config/omarchy/backgrounds/[theme]`. Als je bijvoorbeeld een extra achtergrondafbeelding wilt toevoegen aan het nord-thema, plaats je het bestand gewoon in `~/.config/omarchy/backgrounds/nord`.

Je doet dit het eenvoudigst via _Install > Style > Background_ in het Omarchy Menu. Daarmee open je de map waarin de achtergronden voor dat thema zijn opgeslagen. Druk op `Super + Shift + F` om nog een bestandsbeheerder te starten, zoek je achtergrond en kopieer hem er naartoe. Nu staat hij tussen de achtergronden waaruit je kunt kiezen met `Super + Ctrl + W`.

Achtergronden kunnen zowel video's als stilstaande beelden zijn. Plaats een `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- of `avi`-bestand in dezelfde map en het verschijnt naast de afbeeldingen. Video's worden afgespeeld door de OWE-wallpaper-engine. Die decodeert de video één keer voor alle monitoren, speelt het geluid af via de standaard audio-uitvoer en stopt met afspelen zodra niets hem kan zien. Een video-achtergrond kost nog steeds veel meer stroom dan een stilstaande achtergrond.

Thema's kunnen een korte intro bevatten voor een stilstaande achtergrond. Voor `backgrounds/road.webp` staat de bijpassende video op `backgrounds/intros/road.mp4`. Die wordt automatisch afgespeeld bij het opstarten, wanneer je overschakelt naar een thema waarin die achtergrond is geselecteerd, en wanneer je die achtergrond kiest, en keert daarna terug naar het stilstaande beeld. Intro-video's blijven buiten de achtergrondkiezer en worden nooit herhaald.

Als je _Appearance > Animations_ uitschakelt, schakel je ook de achtergrondintro's uit. Omarchy doet dit standaard in een virtuele machine. Met de opdracht `omarchy theme bg intro toggle` kun je intro's afzonderlijk in- of uitschakelen. Bij het vernieuwen van een thema wordt geen intro afgespeeld.

Je vindt een enorme verzameling coole, zorgvuldig samengestelde achtergronden in [dharmx/walls](https://github.com/dharmx/walls).

Het vergrendelscherm toont een stilstaand frame van een video-achtergrond, op dezelfde manier als het een stilstaand frame van een geanimeerde GIF toont.
