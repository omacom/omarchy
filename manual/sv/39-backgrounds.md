# Bakgrunder

Varje tema levereras med sin egen uppsättning bakgrunder, och du kan lägga till dina egna extra i `~/.config/omarchy/backgrounds/[theme]`. Om du till exempel vill lägga till en extra bakgrundsbild till temat nord lägger du helt enkelt filen i `~/.config/omarchy/backgrounds/nord`.

Det gör du enklast genom att gå till _Install > Style > Background_ i Omarchy Menu. Då öppnas mappen där bakgrunderna för det temat lagras. Tryck på `Super + Shift + F` för att starta en till filhanterare, leta upp din bakgrund och kopiera över den. Nu finns den med bland bakgrunderna du kan välja mellan med `Super + Ctrl + W`.

Bakgrunder kan vara videor såväl som stillbilder. Släpp en fil i formatet `mp4`, `m4v`, `mov`, `webm`, `mkv` eller `avi` i samma mapp så dyker den upp bredvid bilderna. Videor spelas upp av bakgrundsmotorn OWE. Den avkodar videon en gång för alla skärmar och spelar upp ljudet via standardljudutgången, och den stoppar uppspelningen när ingenting kan se den. En videobakgrund drar fortfarande betydligt mer ström än en stillbild.

Teman kan innehålla ett kort intro för en stillbildsbakgrund. För `backgrounds/road.webp` ligger den matchande videon på `backgrounds/intros/road.mp4`. Den spelas upp automatiskt vid uppstart, när du byter till ett tema med den bakgrunden vald och när du väljer den bakgrunden, och återgår sedan till stillbilden. Introvideor hålls utanför bakgrundsväljaren och loopar aldrig.

Att stänga av _Appearance > Animations_ stänger också av bakgrundsintron. Omarchy gör detta som standard i en virtuell maskin. Kommandot `omarchy theme bg intro toggle` kan växla intron separat. Att uppdatera ett tema spelar inte upp något intro.

Du hittar en enorm samling coola, handplockade bakgrunder i [dharmx/walls](https://github.com/dharmx/walls).

Låsskärmen visar en stillbild från en videobakgrund, på samma sätt som den visar en stillbild från en animerad GIF.
