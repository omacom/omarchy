# Bakgrunder

Varje tema levereras med sin egen uppsättning bakgrunder, och du kan lägga till egna extra bakgrunder i `~/.config/omarchy/backgrounds/[theme]`. Om du vill lägga till en extra bakgrundsbild till, säg, temat nord, lägger du bara filen i `~/.config/omarchy/backgrounds/nord`.

Du gör det enklast genom att gå till _Installera > Stil > Bakgrund_ i Omarchy-menyn. Då öppnas mappen där bakgrunderna för det temat lagras. Tryck på `Super + Shift + F` för att starta en annan filhanterare, hitta din bakgrund och kopiera över den. Nu finns den med bland de bakgrunder du kan välja mellan med `Super + Ctrl + W`.

Bakgrunder kan vara videor såväl som stillbilder. Lägg en `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- eller `avi`-fil i samma mapp så visas den bredvid bilderna. Videor spelas upp av bakgrundsmotorn OWE. Den avkodar videon en gång för alla skärmar och spelar upp dess ljud via standardljudutgången, och den stoppar uppspelningen när ingenting kan se den. En videobakgrund drar fortfarande betydligt mer ström än en stillbild.

Teman kan innehålla ett kort intro för en stillbildsbakgrund. För `backgrounds/road.webp` finns den matchande videon på `backgrounds/intros/road.mp4`. Den spelas upp automatiskt vid uppstart, när du byter till ett tema med den bakgrunden vald och när du väljer den bakgrunden, och återgår sedan till stillbilden. Introvideor visas inte i bakgrundsväljaren och loopar aldrig.

Att stänga av _Utseende > Animationer_ stänger också av bakgrundsintron. Omarchy gör detta som standard i en virtuell maskin. Kommandot `omarchy theme bg intro toggle` kan växla intron separat. Att uppdatera ett tema spelar inte upp något intro.

En stillbild kan också ha en loop, en stillsam version av samma bild som fortsätter röra sig, på `backgrounds/loops/road.mp4`. Den spelas upp i stillbildens ställe, efter dess intro om den har ett, och stoppas när animationer stängs av. Loopar visas inte i bakgrundsväljaren och drar, precis som alla videobakgrunder, mer ström än en stillbild.

Du hittar en enorm samling coola, handplockade bakgrunder i [dharmx/walls](https://github.com/dharmx/walls).

Låsskärmen visar en stillbild av en videobakgrund, på samma sätt som den visar en stillbild av en animerad GIF.
