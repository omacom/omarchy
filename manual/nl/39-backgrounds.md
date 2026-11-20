# Achtergronden

Elk thema wordt geleverd met een eigen set achtergronden, en je kunt er zelf extra's aan toevoegen in `~/.config/omarchy/backgrounds/[theme]`. Als je bijvoorbeeld een extra achtergrondafbeelding wilt toevoegen aan het nord-thema, zet je het bestand gewoon in `~/.config/omarchy/backgrounds/nord`.

Dit doe je het eenvoudigst door in het Omarchy Menu naar _Installeren > Stijl > Achtergrond_ te gaan. Dat opent de map waarin de achtergronden voor dat thema zijn opgeslagen. Druk op `Super + Shift + F` om nog een bestandsbeheerder te starten, zoek je achtergrond en kopieer hem ernaartoe. Nu staat hij tussen de achtergronden waaruit je kunt kiezen met `Super + Ctrl + W`.

Achtergronden kunnen zowel video's als stilstaande beelden zijn. Zet een `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- of `avi`-bestand in dezelfde map en het verschijnt naast de afbeeldingen. Video's worden afgespeeld door de OWE wallpaper engine. Die decodeert de video één keer voor alle monitoren en speelt het geluid af via de standaard audio-uitvoer, en stopt met afspelen zodra niets hem kan zien. Een video-achtergrond kost nog steeds veel meer stroom dan een stilstaande.

Thema's kunnen een korte intro bevatten voor een stilstaande achtergrond. Voor `backgrounds/road.webp` staat de bijpassende video op `backgrounds/intros/road.mp4`. Die speelt automatisch af bij het opstarten, bij het overschakelen naar een thema waarin die achtergrond is geselecteerd en bij het kiezen van die achtergrond, en keert daarna terug naar het stilstaande beeld. Introvideo's blijven buiten de achtergrondkiezer en worden nooit in een lus afgespeeld.

_Uiterlijk > Animaties_ uitschakelen schakelt ook achtergrondintro's uit. Omarchy doet dit standaard in een virtuele machine. Met het commando `omarchy theme bg intro toggle` kun je intro's apart in- of uitschakelen. Een thema vernieuwen speelt geen intro af.

Een stilstaand beeld kan ook een loop hebben, een rustige versie van dezelfde afbeelding die blijft bewegen, op `backgrounds/loops/road.mp4`. Die speelt in plaats van het stilstaande beeld, na de intro als die er is, en stopt wanneer animaties zijn uitgeschakeld. Loops blijven buiten de achtergrondkiezer en kosten, net als elke video-achtergrond, meer stroom dan een stilstaand beeld.

Je vindt een enorme verzameling coole, zorgvuldig samengestelde achtergronden in [dharmx/walls](https://github.com/dharmx/walls).

Het vergrendelscherm toont een stilstaand beeld van een video-achtergrond, net zoals het een stilstaand beeld van een geanimeerde GIF toont.
