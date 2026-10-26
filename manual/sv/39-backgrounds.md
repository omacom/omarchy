# Bakgrunder

Varje tema levereras med sin egen uppsättning bakgrunder, och du kan lägga till extra bakgrunder själv i `~/.config/omarchy/backgrounds/[theme]`. Om du vill lägga till en extra bakgrundsbild till, säg, temat nord, lägger du bara filen i `~/.config/omarchy/backgrounds/nord`.

Det enklaste sättet att göra detta är att gå till _Install > Style > Background_ i Omarchy Menu. Då öppnas mappen där bakgrunderna för det temat lagras. Tryck på `Super + Shift + F` för att starta en annan filhanterare, hitta din bakgrund och kopiera över den. Nu kommer den att finnas med bland de bakgrunder du kan välja mellan med `Super + Ctrl + W`.

Bakgrunder kan vara videor såväl som stillbilder. Släpp en `mp4`-, `m4v`-, `mov`-, `webm`-, `mkv`- eller `avi`-fil i samma mapp så visas den tillsammans med bilderna. Videor spelas upp av OWE wallpaper engine. Den avkodar videon en gång för alla skärmar och spelar upp dess ljud via standardljudutgången, och den stoppar uppspelningen när ingenting kan se den. En videobakgrund drar fortfarande betydligt mer ström än en stillbildsbakgrund.

Teman kan innehålla ett kort intro för en stillbildsbakgrund. För `backgrounds/road.webp` finns den matchande videon på `backgrounds/intros/road.mp4`. Den spelas upp automatiskt vid uppstart och när du byter till ett tema med den bakgrunden vald, och återgår sedan till stillbilden. Introvideor visas inte i bakgrundsväljaren och loopar aldrig.

Att stänga av _Appearance > Animations_ stänger också av bakgrundsintron. Omarchy gör detta som standard i en virtuell maskin. Kommandot `omarchy theme bg intro toggle` kan växla intron separat. Att uppdatera ett tema eller välja en annan bakgrund inom samma tema spelar inte upp något intro.

Du hittar en enorm samling coola, noggrant utvalda bakgrunder i [dharmx/walls](https://github.com/dharmx/walls).

Låsskärmen visar en stillbild från en videobakgrund, på samma sätt som den visar en stillbild från en animerad GIF.
