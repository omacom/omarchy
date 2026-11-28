# Achtergronden

Elk thema wordt geleverd met zijn eigen set achtergronden, en je kunt er zelf extra aan toevoegen in `~/.config/omarchy/backgrounds/[theme]`. Wil je bijvoorbeeld een extra achtergrondafbeelding toevoegen aan het nord-thema, dan zet je het bestand gewoon in `~/.config/omarchy/backgrounds/nord`.

Dat doe je het makkelijkst via _Installeren > Stijl > Achtergrond_ in het Omarchy-menu. Daarmee open je de map waarin de achtergronden voor dat thema zijn opgeslagen. Druk op `Super + Shift + F` om nog een bestandsbeheerder te starten, zoek je achtergrond op en kopieer hem ernaartoe. Nu staat hij tussen de achtergronden waaruit je kunt kiezen met `Super + Ctrl + W`.

Een thema zonder eigen achtergronden krijgt er een die uit zijn kleuren is getekend: het Omarchy-logo in de accentkleur van het thema op de achtergrondkleur. Voeg je eigen achtergrond toe om die te vervangen.

Achtergronden kunnen zowel video's als stilstaande beelden zijn. Zet een `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- of `avi`-bestand in dezelfde map en het verschijnt naast de afbeeldingen. Video's worden afgespeeld door de OWE-wallpaper-engine. Die decodeert de video één keer voor alle monitoren, speelt het geluid af via de standaard audio-uitvoer en stopt met afspelen zodra niets hem kan zien. Een video-achtergrond kost nog altijd veel meer stroom dan een stilstaande.

Thema's kunnen een korte intro bevatten voor een stilstaande achtergrond. Voor `backgrounds/road.webp` staat de bijpassende video op `backgrounds/intros/road.mp4`. Die speelt automatisch af bij het opstarten, bij het wisselen naar een thema met die achtergrond geselecteerd en bij het kiezen van die achtergrond, en keert daarna terug naar het stilstaande beeld. Intro-video's blijven uit de achtergrondkiezer en worden nooit herhaald.

_Weergave > Animaties uit_ kiezen schakelt ook achtergrond-intro's uit. Omarchy doet dit standaard in een virtuele machine. Met het commando `omarchy theme bg intro toggle` kun je intro's afzonderlijk in- en uitschakelen. Een thema vernieuwen speelt geen intro af.

Een stilstaand beeld kan ook een loop hebben, een rustige versie van dezelfde afbeelding die blijft bewegen, op `backgrounds/loops/road.mp4`. Die speelt in plaats van het stilstaande beeld, na zijn intro als hij die heeft, en stopt als animaties zijn uitgeschakeld. Op batterij wordt in plaats daarvan het stilstaande beeld getoond, en de loop komt terug zodra je hem aansluit. Loops blijven uit de achtergrondkiezer.

Een enorme verzameling coole, samengestelde achtergronden vind je in [dharmx/walls](https://github.com/dharmx/walls).

Het vergrendelscherm toont een stilstaand frame van een video-achtergrond, op dezelfde manier als het een stilstaand frame van een geanimeerde GIF toont.
