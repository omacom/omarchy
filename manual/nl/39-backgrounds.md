# Achtergronden

Elk thema wordt geleverd met zijn eigen set achtergronden, en je kunt er zelf extra's aan toevoegen in `~/.config/omarchy/backgrounds/[theme]`. Als je bijvoorbeeld een extra achtergrondafbeelding wilt toevoegen aan het nord-thema, plaats je het bestand gewoon in `~/.config/omarchy/backgrounds/nord`.

Dit doe je het makkelijkst door in het Omarchy Menu naar _Install > Style > Background_ te gaan. Dat opent de map waarin de achtergronden voor dat thema zijn opgeslagen. Druk op `Super + Shift + F` om nog een bestandsbeheerder te starten, zoek je achtergrond en kopieer hem daarheen. Nu staat hij tussen de achtergronden waaruit je kunt kiezen met `Super + Ctrl + W`.

Achtergronden kunnen ook video's zijn in plaats van stilstaande beelden. Plaats een `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- of `avi`-bestand in dezelfde map en het verschijnt naast de afbeeldingen. Video's worden afgespeeld door de OWE-wallpaper-engine. Die decodeert de video één keer voor alle monitoren, speelt het geluid af via de standaard audio-uitvoer en stopt het afspelen zodra niets hem kan zien. Een video-achtergrond kost nog altijd veel meer stroom dan een stilstaande.

Thema's kunnen een korte intro bevatten voor een stilstaande achtergrond. Voor `backgrounds/road.webp` staat de bijbehorende video op `backgrounds/intros/road.mp4`. Die speelt automatisch af bij het opstarten, wanneer je overschakelt naar een thema met die achtergrond geselecteerd en wanneer je die achtergrond kiest, en keert daarna terug naar het stilstaande beeld. Intro-video's blijven buiten de achtergrondkiezer en worden nooit herhaald.

_Appearance > Animations_ uitschakelen schakelt ook achtergrond-intro's uit. Omarchy doet dit standaard in een virtuele machine. Met het commando `omarchy theme bg intro toggle` kun je intro's afzonderlijk in- en uitschakelen. Een thema vernieuwen speelt geen intro af.

Een stilstaand beeld kan ook een loop hebben, een rustige versie van dezelfde afbeelding die blijft bewegen, op `backgrounds/loops/road.mp4`. Die speelt af op de plaats van het stilstaande beeld, na zijn intro als hij die heeft, en stopt wanneer animaties zijn uitgeschakeld. Op accu wordt in plaats daarvan het stilstaande beeld getoond, en de loop komt terug zodra je de stekker erin steekt. Loops blijven buiten de achtergrondkiezer.

Je vindt een enorme verzameling coole, samengestelde achtergronden in [dharmx/walls](https://github.com/dharmx/walls).

Het vergrendelscherm toont een stilstaand frame van een video-achtergrond, op dezelfde manier als het een stilstaand frame van een geanimeerde GIF toont.
