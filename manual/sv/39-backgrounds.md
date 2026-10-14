# Bakgrunder

Varje tema levereras med sin egen uppsättning bakgrunder, och du kan lägga till egna extratillbehör i `~/.config/omarchy/backgrounds/[theme]`. Om du vill lägga till en extra bakgrundsbild till exempelvis nord-temat lägger du bara filen i `~/.config/omarchy/backgrounds/nord`.

Detta gör du enklast genom att gå till _Installera > Stil > Bakgrund_ i Omarchy-menyn. Då öppnas mappen där bakgrunderna för det temat lagras. Tryck på `Super + Shift + F` för att starta en annan filhanterare, hitta din bakgrund, kopiera över den. Nu ingår den i de val av bakgrunder du kan välja mellan med `Super + Ctrl + Space`.

Bakgrunder kan vara videor såväl som stillbilder. Släpp en fil med formatet `mp4`, `m4v`, `mov`, `webm`, `mkv` eller `avi` i samma mapp så visas den bredvid bilderna. Videor spelas av OWE-bakgrundsmotorn. Den avkodar videon en gång för alla skärmar och spelar dess ljud via standardljudutgången, och den stoppar uppspelningen när ingenting kan se den. Låsskärmen ritar samma avkodning, tystad, via OWE. En videobakgrund kostar fortfarande mycket mer ström än en stillbildsbakgrund.

Teman kan inkludera en kort introduktion för en stillbildsbakgrund. För `backgrounds/road.webp` bor den matchande videon på `backgrounds/intros/road.mp4`. Den spelas automatiskt vid start och när du byter till ett tema med den bakgrunden vald, och återgår sedan till stillbilden. Introvideor hålls borta från bakgrundsväljaren och loopar aldrig.

Att stänga av _Utlös > Utseende > Animeringar_ stänger också av bakgrundsintron. Omarchy gör detta som standard i en virtuell maskin. Kommandot `omarchy theme bg intro toggle` kan växla intron separat. Att uppdatera ett tema eller välja en annan bakgrund inom samma tema spelar inte upp något intro.

Du kan hitta en enorm samling coola kuraterade bakgrunder på https://github.com/dharmx/walls.

Videobakgrunder behåller en cachad stillbild på låsskärmen medan uppspelningen är pausad eller otillgänglig. Animerade GIF:ar spelas på skrivbordet och visar en stillbild på låsskärmen.
