# Textextrahering & diktering

### Textextrahering

Tryck på `Super + Ctrl + PrtScr` för att välja en region på skärmen för textextrahering. Tesseract OCR-modellen med öppen källkod konverterar sedan snabbt det urvalet till text och placerar det på urklippet. Sedan trycker du bara på `Super + V` för att klistra in.

Detta är mycket hjälpsamt för att plocka adresser ur bildsidfötter eller telefonnummer inbäddade i webbsidesrubriker.

 ![text-extraction](images/text-extraction.webp)

### Diktering

Vid nya installationer är [Superwhisper](https://superwhisper.com/) standardbackend för diktering, med molnbearbetning utan offline-modellnedladdningar. Välj Superwhisper eller [Voxtype](https://voxtype.io/) via _Setup > Defaults > Dictation_ i Omarchy-menyn. Att välja en backend installerar den vid behov och gör den till standard för diktering. Voxtype laddar en engelsk basmodell som tar upp 150MB; ändra modellen med `voxtype setup model` och andra inställningar via `~/.config/voxtype/config.toml`. Superwhisper öppnar sina inställningar för att välja moln- eller lokal bearbetning, och OPR håller applikationen uppdaterad.

Du dikterar genom att hålla ned `Right Alt` eller `F9`, eller genom att växla med `Super + Ctrl + X`, och den dikterade texten visas i det fokuserade inmatningsområdet. Dessa genvägar använder den valda backend. Right Alt startar också diktering när den används i ett modifierarackord; använd Left Alt för de ackorden. På tangentbordslayouter där Right Alt är AltGr, använd `F9` för att hålla AltGr tillgänglig för skrivning.

Samma genvägar fungerar med båda backend. Välj din backend via Setup > Defaults > Dictation. Backend-installatören konfigurerar den och sparar valet. Kör `omarchy default dictation` för att se vilken som är vald. Valet sparas i `~/.config/omarchy/defaults/dictation`. Nya installationer väljer Superwhisper automatiskt.

Omarchy laddar den valda backendens skrivbordsintegration automatiskt. Ingen Superwhisper-konfiguration behövs i `~/.config/hypr/`.

Anpassade bindningar och skript kan använda `omarchy dictation start`, `omarchy dictation stop` och `omarchy dictation toggle`. Den valda backend hanterar inspelningen och transkriberingen. Att välja Superwhisper inaktiverar dess inbyggda håll-genväg och ställer in dess inbyggda växling till `Alt + Space`, så att den hålls separat från Omarchys inspelningstangenter. Superwhisper kräver minst en inbyggd inspelningsgenväg, och dess avbryt-genväg förblir tillgänglig.

Ytterligare backend kan integreras utan att ändra Omarchy. Tillhandahåll en körbar fil med namnet `omarchy-dictation-<backend>` på PATH som accepterar `start`, `stop` och `toggle` och returnerar snabbt, med en status skild från noll vid fel. Dess installatör konfigurerar leverantören och anropar `omarchy-dictation-use <backend>` efter lyckad konfiguration. Detta stoppar föregående backend och sparar valet atomiskt; `stop` måste lyckas när leverantören är inaktiv eller otillgänglig. Backend-namn använder små bokstäver, siffror och bindestreck. Tillhandahåll `omarchy-install-dictation-<backend>` för konfiguration; `omarchy default dictation <backend>` startar den. Lägg till en Defaults-menypost via ett Omarchy-menytillägg för att anropa den väljaren. Valfri skrivbordsintegration kan bo i `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
