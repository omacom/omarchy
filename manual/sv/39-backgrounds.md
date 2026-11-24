# Bakgrunder

Varje tema levereras med sin egen uppsättning bakgrunder, och du kan lägga till extra bakgrunder själv i `~/.config/omarchy/backgrounds/[theme]`. Om du vill lägga till en extra bakgrundsbild till till exempel temat nord lägger du bara filen i `~/.config/omarchy/backgrounds/nord`.

Du gör det enklast genom att gå till _Install > Style > Background_ i Omarchy Menu. Då öppnas mappen där bakgrunderna för det temat lagras. Tryck på `Super + Shift + F` för att starta en till filhanterare, leta upp din bakgrund och kopiera över den. Nu finns den med bland de bakgrunder du kan välja mellan med `Super + Ctrl + W`.

Bakgrunder kan vara videor såväl som stillbilder. Lägg en `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- eller `avi`-fil i samma mapp så visas den bredvid bilderna. Videor spelas upp av OWE wallpaper engine. Den avkodar videon en gång för alla bildskärmar, spelar upp ljudet via standardljudutgången och stoppar uppspelningen när ingenting kan se den. En videobakgrund drar ändå betydligt mer ström än en stillbild.

Teman kan innehålla ett kort intro till en stillbildsbakgrund. För `backgrounds/road.webp` ligger den matchande videon i `backgrounds/intros/road.mp4`. Den spelas upp automatiskt vid start, när du växlar till ett tema med den bakgrunden vald och när du väljer den bakgrunden, och återgår sedan till stillbilden. Introvideor visas inte i bakgrundsväljaren och loopas aldrig.

Att välja _Appearance > Animations Off_ stänger också av bakgrundsintron. Omarchy gör detta som standard i en virtual machine. Med kommandot `omarchy theme bg intro toggle` kan du slå av och på intron separat. Att uppdatera ett tema spelar inte upp ett intro.

En stillbild kan också ha en loop, en tyst version av samma bild som fortsätter att röra sig, i `backgrounds/loops/road.mp4`. Den spelas upp i stället för stillbilden, efter dess intro om det finns ett, och stoppas när animationer stängs av. När du kör på batteri visas stillbilden i stället, och loopen återkommer så snart du ansluter strömmen. Loopar visas inte i bakgrundsväljaren.

Du kan hitta en enorm samling snygga, utvalda bakgrunder i [dharmx/walls](https://github.com/dharmx/walls).

Låsskärmen visar en stillbildsruta från en videobakgrund, på samma sätt som den visar en stillbildsruta från en animerad GIF.
