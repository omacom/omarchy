# Textextraktion & diktering

### Textextraktion

Tryck på `Super + Ctrl + PrtScr` för att välja ett område på skärmen för textextraktion. OCR-modellen tesseract med öppen källkod omvandlar sedan snabbt det valet till text och placerar den på urklippshanteraren. Sedan trycker du bara på `Super + V` för att klistra in.

Det här är väldigt användbart för att fånga upp adresser ur bildsidfötter eller telefonnummer inbäddade i rubriker på webbplatser.

 ![text-extraction](images/text-extraction.webp)

### Diktering

Vid nya installationer är [Superwhisper](https://superwhisper.com/) standardbackend för diktering, med molnbearbetning utan nedladdningar av offlinemodeller. Välj Superwhisper, [Voxtype](https://voxtype.io/) eller [Hex](https://anoma.ly/hex/) via _Setup > Defaults > Dictation_ i Omarchy-menyn. Att välja en backend installerar den vid behov och gör den till standard för diktering. Voxtype laddar en grundläggande engelsk modell som tar upp 150MB; ändra modellen med `voxtype setup model` och andra inställningar via `~/.config/voxtype/config.toml`. Superwhisper öppnar sina inställningar för att välja moln- eller lokal bearbetning, och OPR håller applikationen uppdaterad. Hex laddar ner sin talmodell på enheten under installationen och körs som användartjänsten `hex.service`; öppna dess fönster från ikonen i fältets systemfält eller genom att köra `hex` för att ändra modellen och andra inställningar.

Du dikterar genom att hålla ner `Right Alt`, eller genom att växla med `Alt + Space`, och den dikterade texten visas i det fokuserade inmatningsområdet. Dessa genvägar använder den valda backenden. Right Alt startar också diktering när den används i en modifierarkombination; använd Left Alt för de kombinationerna. På tangentbordslayouter där Right Alt är AltGr använder du `Alt + Space` för att hålla AltGr tillgängligt när du skriver. Installationer från innan Alt + Space blev standard behåller `F9` för push-to-talk och `Super + Ctrl + X` för att växla, tillagda i `~/.config/hypr/bindings.lua`, där den `Super + Ctrl + X` tar agentpanelens plats; ta bort dem där för att ge tillbaka de tangenterna till applikationer och panelen.

Samma genvägar fungerar med varje backend. Välj din backend via Setup > Defaults > Dictation. Backendens installationsprogram konfigurerar den och sparar valet. Kör `omarchy default dictation` för att se vilken som är vald. Valet sparas i `~/.config/omarchy/defaults/dictation`. Nya installationer väljer Superwhisper automatiskt.

Omarchy laddar automatiskt den valda backendens skrivbordsintegration. Ingen Superwhisper-konfiguration behövs i `~/.config/hypr/`.

Anpassade bindningar och skript kan använda `omarchy dictation start`, `omarchy dictation stop` och `omarchy dictation toggle`. Den valda backenden hanterar inspelningen och transkriberingen. Att välja Superwhisper inaktiverar dess inbyggda hållgenväg och ställer in dess inbyggda växlingsgenväg till `Ctrl + Alt + Space`, så att den hålls separat från Omarchys inspelningstangenter. Superwhisper kräver minst en inbyggd inspelningsgenväg, och dess avbrytgenväg förblir tillgänglig.

Ytterligare backends kan integreras utan att ändra Omarchy. Tillhandahåll en körbar fil med namnet `omarchy-dictation-<backend>` på PATH som accepterar `start`, `stop` och `toggle` och returnerar direkt, med en status som inte är noll vid fel. Dess installationsprogram konfigurerar leverantören och anropar `omarchy-dictation-use <backend>` efter lyckad installation. Detta stoppar den tidigare backenden och sparar valet atomiskt; `stop` måste lyckas när leverantören är inaktiv eller otillgänglig. Backendnamn använder små bokstäver, siffror och bindestreck. Tillhandahåll `omarchy-install-dictation-<backend>` för installation; `omarchy default dictation <backend>` startar den. Lägg till en post i Defaults-menyn via ett menytillägg för Omarchy för att anropa den väljaren. Valfri skrivbordsintegration kan ligga i `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
