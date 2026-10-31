# Textextraktion & diktering

### Textextraktion

Tryck på `Super + Ctrl + PrtScr` för att välja ett område på skärmen för textextraktion. OCR-modellen tesseract med öppen källkod omvandlar sedan snabbt det valda området till text och placerar den i urklippet. Sedan trycker du bara på `Super + V` för att klistra in.

Det här är mycket användbart för att hämta adresser ur bilders sidfötter eller telefonnummer inbäddade i rubriker på webbplatser.

 ![text-extraction](images/text-extraction.webp)

### Diktering

Vid nya installationer är [Superwhisper](https://superwhisper.com/) standardbackend för diktering, med bearbetning i molnet utan nedladdning av offlinemodeller. Välj Superwhisper eller [Voxtype](https://voxtype.io/) via _Setup > Defaults > Dictation_ i Omarchy-menyn. När du väljer en backend installeras den vid behov och görs till standard för diktering. Voxtype laddar en engelsk basmodell som tar upp 150MB; byt modell med `voxtype setup model` och ändra andra inställningar via `~/.config/voxtype/config.toml`. Superwhisper öppnar sina inställningar så att du kan välja bearbetning i molnet eller lokalt, och OPR håller programmet uppdaterat.

Du dikterar genom att hålla ned `Right Alt`, eller genom att växla med `Alt + Space`, och den dikterade texten visas i det fokuserade inmatningsområdet. Dessa genvägar använder den valda backenden. Right Alt startar också diktering när den används i en modifierarkombination; använd Left Alt för de kombinationerna. På tangentbordslayouter där Right Alt är AltGr använder du `Alt + Space` för att hålla AltGr tillgänglig för skrivning. Installationer från tiden innan Alt + Space blev standard behåller `F9` för push-to-talk och `Super + Ctrl + X` för att växla, tillagda i `~/.config/hypr/bindings.lua`; ta bort dem där för att ge tillbaka de tangenterna till programmen.

Samma genvägar fungerar med båda backendalternativen. Välj din backend via Setup > Defaults > Dictation. Backendens installerare konfigurerar den och sparar valet. Kör `omarchy default dictation` för att se vilken som är vald. Valet sparas i `~/.config/omarchy/defaults/dictation`. Vid nya installationer väljs Superwhisper automatiskt.

Omarchy laddar automatiskt den valda backendens skrivbordsintegration. Ingen konfiguration av Superwhisper behövs i `~/.config/hypr/`.

Anpassade bindningar och skript kan använda `omarchy dictation start`, `omarchy dictation stop` och `omarchy dictation toggle`. Den valda backenden hanterar inspelningen och transkriberingen. När du väljer Superwhisper inaktiveras dess inbyggda genväg för att hålla ned, och dess inbyggda växlingsgenväg ställs in på `Ctrl + Alt + Space`, så att den hålls åtskild från Omarchys inspelningstangenter. Superwhisper kräver minst en inbyggd inspelningsgenväg, och dess genväg för att avbryta förblir tillgänglig.

Ytterligare backendalternativ kan integreras utan att Omarchy ändras. Tillhandahåll en körbar fil med namnet `omarchy-dictation-<backend>` i PATH som accepterar `start`, `stop` och `toggle` och returnerar direkt, med en status som inte är noll vid fel. Dess installerare konfigurerar leverantören och anropar `omarchy-dictation-use <backend>` efter lyckad installation. Detta stoppar den tidigare backenden och sparar valet atomiskt; `stop` måste lyckas när leverantören är inaktiv eller otillgänglig. Backendnamn använder gemena bokstäver, siffror och bindestreck. Tillhandahåll `omarchy-install-dictation-<backend>` för installation; `omarchy default dictation <backend>` startar den. Lägg till en post i Defaults-menyn via ett meny-tillägg för Omarchy som anropar den väljaren. Valfri skrivbordsintegration kan ligga i `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
