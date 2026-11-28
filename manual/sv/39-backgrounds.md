# Bakgrunder

Varje tema levereras med sin egen uppsättning bakgrunder, och du kan lägga till egna extra i `~/.config/omarchy/backgrounds/[theme]`. Om du vill lägga till en extra bakgrundsbild till, säg, temat nord lägger du bara filen i `~/.config/omarchy/backgrounds/nord`.

Du gör det enklast genom att gå till _Installera > Stil > Bakgrund_ i Omarchy-menyn. Då öppnas mappen där bakgrunderna för det temat lagras. Tryck på `Super + Shift + F` för att starta en annan filhanterare, hitta din bakgrund och kopiera över den. Nu finns den med bland de bakgrunder du kan välja mellan med `Super + Ctrl + W`.

Ett tema utan egna bakgrunder får en som ritas utifrån dess färger: Omarchy-logotypen i temats accentfärg på dess bakgrundsfärg. Lägg till en egen för att ersätta den.

Bakgrunder kan vara videor såväl som stillbilder. Släpp en `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- eller `avi`-fil i samma mapp så visas den bredvid bilderna. Videor spelas upp av bakgrundsmotorn OWE. Den avkodar videon en gång för alla skärmar och spelar upp dess ljud genom standardljudutgången, och den stoppar uppspelningen när ingenting kan se den. En videobakgrund drar ändå betydligt mer ström än en stillbild.

Teman kan innehålla ett kort intro för en stillbildsbakgrund. För `backgrounds/road.webp` finns den matchande videon på `backgrounds/intros/road.mp4`. Den spelas upp automatiskt vid uppstart, när du byter till ett tema med den bakgrunden vald och när du väljer den bakgrunden, och återgår sedan till stillbilden. Introvideor visas inte i bakgrundsväljaren och loopar aldrig.

Att välja _Utseende > Animationer av_ stänger också av bakgrundsintron. Omarchy gör detta som standard i en virtuell maskin. Kommandot `omarchy theme bg intro toggle` kan slå av och på intron separat. Att uppdatera ett tema spelar inte upp något intro.

En stillbild kan också ha en loop, en lugn version av samma bild som fortsätter röra sig, på `backgrounds/loops/road.mp4`. Den spelas upp i stillbildens ställe, efter dess intro om den har ett, och stoppas när animationer stängs av. På batteri visas stillbilden i stället, och loopen kommer tillbaka när du ansluter strömmen igen. Loopar visas inte i bakgrundsväljaren.

Du hittar en enorm samling coola, noggrant utvalda bakgrunder i [dharmx/walls](https://github.com/dharmx/walls).

Låsskärmen visar en stillbildsruta av en videobakgrund, på samma sätt som den visar en stillbildsruta av en animerad GIF.
