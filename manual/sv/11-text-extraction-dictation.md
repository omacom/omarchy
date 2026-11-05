# Textextraktion & diktering

### Textextraktion

Tryck på `Super + Ctrl + PrtScr` för att välja ett område på skärmen för textextraktion. Den öppna OCR-modellen tesseract konverterar sedan snabbt det valda området till text och lägger den i urklippet. Sedan trycker du bara på `Super + V` för att klistra in.

Det här är väldigt användbart för att hämta adresser ur bildsidfötter eller telefonnummer inbäddade i rubriker på webbplatser.

 ![text-extraction](images/text-extraction.webp)

### Diktering

Vid nya installationer är [Superwhisper](https://superwhisper.com/) standardbackend för diktering, med molnbearbetning utan nedladdning av offlinemodeller. Välj Superwhisper, [Voxtype](https://voxtype.io/) eller [Hex](https://anoma.ly/hex/) via _Setup > Defaults > Dictation_ i Omarchy-menyn. Att välja en backend installerar den vid behov och gör den till standard för diktering. Voxtype laddar en engelsk basmodell som tar upp 150MB; byt modell med `voxtype setup model` och ändra andra inställningar via `~/.config/voxtype/config.toml`. Superwhisper öppnar sina inställningar för att välja moln- eller lokal bearbetning, och OPR håller applikationen uppdaterad. Hex laddar ner sin talmodell för enheten under installationen och körs som användartjänsten `hex.service`; öppna dess fönster från fältets systemfältsikon eller genom att köra `hex` för att byta modell och ändra andra inställningar.

Du dikterar genom att hålla ner `Right Alt`, eller genom att växla med `Alt + Space`, och den dikterade texten visas i det fokuserade inmatningsfältet. Dessa genvägar använder den valda backenden. Right Alt startar också diktering när den används i en modifierarkombination; använd Left Alt för de kombinationerna. På tangentbordslayouter där Right Alt är AltGr använder du `Alt + Space` för att hålla AltGr tillgänglig för skrivning. Installationer från innan Alt + Space blev standard behåller `F9` för push-to-talk och `Super + Ctrl + X` för att växla, tillagda i `~/.config/hypr/bindings.lua`; ta bort dem där för att lämna tillbaka de tangenterna till applikationerna.

Samma genvägar fungerar med varje backend. Välj din backend via Setup > Defaults > Dictation. Backendens installerare konfigurerar den och sparar valet. Kör `omarchy default dictation` för att se vilken som är vald. Valet sparas i `~/.config/omarchy/defaults/dictation`. Nya installationer väljer Superwhisper automatiskt.

Omarchy laddar den valda backendens skrivbordsintegration automatiskt. Ingen Superwhisper-konfiguration behövs i `~/.config/hypr/`.

Anpassade bindningar och skript kan använda `omarchy dictation start`, `omarchy dictation stop` och `omarchy dictation toggle`. Den valda backenden hanterar inspelningen och transkriberingen. Att välja Superwhisper inaktiverar dess inbyggda genväg för att hålla ner och sätter dess inbyggda växlingsgenväg till `Ctrl + Alt + Space`, så att den hålls separat från Omarchys inspelningstangenter. Superwhisper kräver minst en inbyggd inspelningsgenväg, och dess avbrytningsgenväg förblir tillgänglig.

Ytterligare backends kan integreras utan att ändra Omarchy. Tillhandahåll en körbar fil med namnet `omarchy-dictation-<backend>` i PATH som accepterar `start`, `stop` och `toggle` och returnerar snabbt, med en status som inte är noll vid fel. Dess installerare konfigurerar leverantören och anropar `omarchy-dictation-use <backend>` efter lyckad installation. Det här stoppar den tidigare backenden och sparar valet atomiskt; `stop` måste lyckas när leverantören är inaktiv eller otillgänglig. Backendnamn använder små bokstäver, siffror och bindestreck. Tillhandahåll `omarchy-install-dictation-<backend>` för installation; `omarchy default dictation <backend>` startar den. Lägg till ett menyalternativ i Defaults via ett Omarchy-menytillägg för att anropa den väljaren. Valfri skrivbordsintegration kan ligga i `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
