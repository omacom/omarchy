# Achtergronden

Elk thema wordt geleverd met zijn eigen set achtergronden, en je kunt zelf extra's toevoegen in `~/.config/omarchy/backgrounds/[theme]`. Als je bijvoorbeeld een extra achtergrondafbeelding wilt toevoegen aan het nord-thema, zet je het bestand gewoon in `~/.config/omarchy/backgrounds/nord`.

Je doet dit het makkelijkst door in het Omarchy Menu naar _Installeren > Stijl > Achtergrond_ te gaan. Dan opent de map waarin de achtergronden voor dat thema zijn opgeslagen. Druk op `Super + Shift + F` om nog een bestandsbeheerder te starten, zoek je achtergrond en kopieer hem erheen. Nu staat hij tussen de achtergronden waar je met `Super + Ctrl + W` uit kunt kiezen.

Achtergronden kunnen zowel video's als stilstaande beelden zijn. Zet een `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- of `avi`-bestand in dezelfde map en het verschijnt naast de afbeeldingen. Video's worden afgespeeld door de OWE-wallpaper-engine. Die decodeert de video één keer voor alle monitoren, speelt het geluid af via de standaard audio-uitvoer en stopt met afspelen zodra niets het kan zien. Een video-achtergrond kost nog altijd veel meer stroom dan een stilstaande.

Thema's kunnen een korte intro bevatten voor een stilstaande achtergrond. Voor `backgrounds/road.webp` staat de bijpassende video op `backgrounds/intros/road.mp4`. Die speelt automatisch af bij het opstarten, bij het overschakelen naar een thema waarin die achtergrond is geselecteerd en bij het kiezen van die achtergrond, en keert daarna terug naar het stilstaande beeld. Intro-video's blijven buiten de achtergrondkiezer en worden nooit herhaald.

Als je _Uiterlijk > Animaties uit_ kiest, worden ook achtergrond-intro's uitgeschakeld. Omarchy doet dit standaard in een virtuele machine. Met het commando `omarchy theme bg intro toggle` kun je intro's apart in- en uitschakelen. Bij het vernieuwen van een thema wordt geen intro afgespeeld.

Een stilstaand beeld kan ook een loop hebben, een rustige versie van dezelfde afbeelding die blijft bewegen, op `backgrounds/loops/road.mp4`. Die speelt in plaats van het stilstaande beeld, na de intro als die er is, en stopt wanneer animaties zijn uitgeschakeld. Op batterij wordt in plaats daarvan het stilstaande beeld getoond, en de loop komt terug zodra je de stekker aansluit. Loops blijven buiten de achtergrondkiezer.

Je vindt een enorme verzameling gave, zorgvuldig samengestelde achtergronden in [dharmx/walls](https://github.com/dharmx/walls).

Het vergrendelscherm toont een stilstaand frame van een video-achtergrond, op dezelfde manier als het een stilstaand frame van een geanimeerde GIF toont.
