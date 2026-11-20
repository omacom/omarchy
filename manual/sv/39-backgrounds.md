# Bakgrunder

Varje tema levereras med sin egen uppsättning bakgrunder, och du kan lägga till egna extra i `~/.config/omarchy/backgrounds/[theme]`. Om du vill lägga till en extra bakgrundsbild till, säg, nord-temat lägger du bara filen i `~/.config/omarchy/backgrounds/nord`.

Enklast gör du det genom att gå till _Install > Style > Background_ i Omarchy Menu. Då öppnas mappen där bakgrunderna för det temat lagras. Tryck på `Super + Shift + F` för att starta en annan filhanterare, hitta din bakgrund och kopiera över den.  Nu kommer den att finnas med bland bakgrunderna du kan välja mellan med `Super + Ctrl + W`.

Bakgrunder kan vara videor såväl som stillbilder. Släpp en `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- eller `avi`-fil i samma mapp så visas den bredvid bilderna. Videor spelas upp av OWE wallpaper engine. Den avkodar videon en gång för alla skärmar och spelar upp dess ljud via standardljudutgången, och den stoppar uppspelningen när ingenting kan se den. En videobakgrund drar fortfarande betydligt mer ström än en stillbild.

Teman kan innehålla ett kort intro till en stillbildsbakgrund. För `backgrounds/road.webp` finns den matchande videon på `backgrounds/intros/road.mp4`. Den spelas upp automatiskt vid uppstart, när du byter till ett tema med den bakgrunden vald och när du väljer den bakgrunden, och återgår sedan till stillbilden. Introvideor hålls utanför bakgrundsväljaren och loopar aldrig.

Att stänga av _Appearance > Animations_ stänger också av bakgrundsintron. Omarchy gör detta som standard i en virtuell maskin. Kommandot `omarchy theme bg intro toggle` kan växla intron separat. Att uppdatera ett tema spelar inte upp något intro.

En stillbild kan också ha en loop, en lugn version av samma bild som hela tiden rör sig, på `backgrounds/loops/road.mp4`. Den spelas upp i stillbildens ställe, efter dess intro om den har ett, och den stoppar när animationer stängs av. På batteri visas stillbilden i stället, och loopen kommer tillbaka när du kopplar in strömmen igen. Loopar hålls utanför bakgrundsväljaren.

Du hittar en enorm samling coola, noggrant utvalda bakgrunder i [dharmx/walls](https://github.com/dharmx/walls).

Låsskärmen visar en stillbildsruta ur en videobakgrund, på samma sätt som den visar en stillbildsruta ur en animerad GIF.
