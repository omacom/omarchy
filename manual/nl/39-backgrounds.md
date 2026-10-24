# Achtergronden

Elk thema wordt geleverd met zijn eigen set achtergronden, en je kunt zelf extra's toevoegen in `~/.config/omarchy/backgrounds/[theme]`. Als je een extra achtergrondafbeelding wilt toevoegen aan bijvoorbeeld het nord-thema, zet je het bestand gewoon in `~/.config/omarchy/backgrounds/nord`.

Je kunt dit het makkelijkst doen door naar _Installeren > Style > Background_ te gaan in het Omarchy-menu. Dat opent de map waar de achtergronden voor dat thema zijn opgeslagen. Druk op `Super + Shift + F` om een andere bestandsbeheerder te starten, zoek je achtergrond en kopieer hem erheen. Nu wordt hij opgenomen in de keuzes van achtergronden waaruit je kunt selecteren met `Super + Ctrl + Space`.

Achtergronden kunnen zowel video's als stilstaande beelden zijn. Zet een `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- of `avi`-bestand in dezelfde map en het verschijnt naast de afbeeldingen. Video's worden afgespeeld door de OWE-achtergrondengine. Die decodeert de video één keer voor alle monitors en speelt het geluid af via de standaard audio-uitvoer, en stopt het afspelen zodra niets hem kan zien. Het vergrendelscherm tekent dezelfde decodering, gedempt, via OWE. Een videoachtergrond kost nog steeds veel meer stroom dan een stilstaande.

Thema's kunnen een korte intro bevatten voor een stilstaande achtergrond. Voor `backgrounds/road.webp` leeft de bijpassende video op `backgrounds/intros/road.mp4`. Die speelt automatisch af bij het opstarten en bij het overschakelen naar een thema met die achtergrond geselecteerd, en keert dan terug naar het stilstaande beeld. Intro-video's blijven uit de achtergrondkiezer en herhalen nooit.

Het uitschakelen van _Activeren > Weergave > Animaties_ schakelt ook achtergrondintro's uit. Omarchy doet dit standaard in een virtuele machine. Het commando `omarchy theme bg intro toggle` kan intro's apart in- of uitschakelen. Het vernieuwen van een thema of het kiezen van een andere achtergrond binnen hetzelfde thema speelt geen intro af.

Je kunt een enorme verzameling coole samengestelde achtergronden vinden op https://github.com/dharmx/walls.

Videoachtergronden behouden een gecached stilstaand beeld op het vergrendelscherm terwijl het afspelen is gepauzeerd of niet beschikbaar is. Geanimeerde GIF's spelen af op het bureaublad en tonen een stilstaand frame op het vergrendelscherm.
