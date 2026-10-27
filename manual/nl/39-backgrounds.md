# Achtergronden

Elk thema wordt geleverd met zijn eigen set achtergronden, en je kunt er zelf extra's aan toevoegen in `~/.config/omarchy/backgrounds/[theme]`. Wil je bijvoorbeeld een extra achtergrondafbeelding toevoegen aan het nord-thema, dan zet je het bestand gewoon in `~/.config/omarchy/backgrounds/nord`.

Dit doe je het eenvoudigst via _Installeren > Stijl > Achtergrond_ in het Omarchy Menu. Daarmee open je de map waarin de achtergronden voor dat thema zijn opgeslagen. Druk op `Super + Shift + F` om nog een bestandsbeheerder te starten, zoek je achtergrond en kopieer hem erheen. Nu staat hij tussen de achtergronden waaruit je kunt kiezen met `Super + Ctrl + W`.

Achtergronden kunnen zowel video's als stilstaande afbeeldingen zijn. Zet een `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- of `avi`-bestand in dezelfde map en het verschijnt naast de afbeeldingen. Video's worden afgespeeld door de OWE wallpaper engine. Die decodeert de video één keer voor alle monitoren, speelt het geluid af via de standaard audio-uitvoer en stopt met afspelen zodra niets hem kan zien. Een videoachtergrond kost nog altijd veel meer stroom dan een stilstaande.

Thema's kunnen een korte intro bevatten voor een stilstaande achtergrond. Voor `backgrounds/road.webp` staat de bijpassende video op `backgrounds/intros/road.mp4`. Die speelt automatisch af bij het opstarten en bij het overschakelen naar een thema waarin die achtergrond is geselecteerd, en keert daarna terug naar de stilstaande afbeelding. Introvideo's blijven buiten de achtergrondkiezer en worden nooit herhaald.

Als je _Weergave > Animaties_ uitschakelt, schakel je ook achtergrondintro's uit. Omarchy doet dit standaard in een virtuele machine. Met het commando `omarchy theme bg intro toggle` kun je intro's afzonderlijk in- en uitschakelen. Een thema vernieuwen of een andere achtergrond kiezen binnen hetzelfde thema speelt geen intro af.

Een enorme verzameling coole, zorgvuldig samengestelde achtergronden vind je in [dharmx/walls](https://github.com/dharmx/walls).

Het vergrendelscherm toont een stilstaand frame van een videoachtergrond, net zoals het een stilstaand frame van een geanimeerde GIF toont.
