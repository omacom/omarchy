# Schermafbeeldingen & opnames

Alles wat je van het scherm kunt pakken, hangt onder de Print Screen-toets. Eén toets op zichzelf maakt een foto, en de modificatoren maken een opname, pakken een kleur of halen de tekst uit een gebied. Als je toetsenbord helemaal geen Print Screen-toets heeft, maakt `Super + Ctrl + Alt + C` dezelfde schermafbeelding, en opent `Super + Ctrl + C` de hele set als menu.

| Sneltoets | Functie |
| ------ | -------- |
| `Print Screen` | Schermafbeelding |
| `Super + Ctrl + Alt + C` | Schermafbeelding |
| `Alt + Print Screen` | Schermopname (of stop de opname die loopt) |
| `Super + Print Screen` | Kleurenpipet |
| `Super + Ctrl + Print Screen` | Tekst uit een gebied halen |
| `Super + Ctrl + C` | Menu Vastleggen |
| `Super + Ctrl + .` | Een foto of video transcoderen |

## Schermafbeeldingen

Druk op `Print Screen` (of `Super + Ctrl + Alt + C`) en Omasnap legt de gefocuste monitor vast voordat zijn overlay verschijnt, zodat er niets onder je verschuift terwijl je mikt. Sleep een gebied in vrije vorm, klik op een venster om het vast te leggen, of klik op open ruimte om de hele monitor vast te leggen. Druk op `S` voordat je begint te tekenen om een scrollend gebied vast te leggen. Van gedachten veranderd? Druk opnieuw op dezelfde toets om Omasnap te sluiten.

Nadat je een gebied hebt geselecteerd, slaat Omasnap de opname op, kopieert hij die naar het klembord en toont hij 10 seconden lang een voorvertoning. Gebruik de vastpikknop van de voorvertoning of `Ctrl + P` om hem op het scherm te houden, of kies Bewerken om hem te annoteren.

De annotatie-editor kan pijlen, lijnen, vormen, markeringen, genummerde markers, tekst en veilige zwartlakkingen tekenen; een deel van de afbeelding bijsnijden of eruit knippen; OCR op de tekst toepassen; en een achtergrond toevoegen. Druk in de editor op `Enter` om de voltooide PNG te kopiëren en op te slaan, op `Ctrl + C` om hem te kopiëren zonder op te slaan, of op `Ctrl + S` om hem op te slaan zonder te kopiëren.

Opgeslagen schermafbeeldingen belanden standaard in `~/Pictures/Screenshots`, met een naam zoals `screenshot-2026-08-13_14-22-05-firefox.png`. Stel `OMASNAP_SCREENSHOT_DIR` in om een andere map te gebruiken — zie [de FAQ](46-faq.md) voor waar je omgevingsvariabelen voor de sessie moet zetten. Omasnap maakt de map aan wanneer hij de eerste opname opslaat. Stel `[output] autosave = false` in in `~/.config/omasnap/omasnap.conf` om automatisch opslaan uit te schakelen.

Vanuit de terminal opent `omarchy screenshot` dezelfde overlay, en je kunt zijn startmodus kiezen: `omarchy capture screenshot region`, `windows`, `fullscreen` of `scroll`. Een tweede argument `copy` of `save` slaat de voorvertoning over en stuurt de opname rechtstreeks naar die bestemming. Om te bewerken voordat je uitvoert, gebruik je `omarchy screenshot --editor=overlay` voor een editor op het volledige scherm of `omarchy screenshot --editor=window` voor een apart venster.

### De kiezer bedienen vanaf het toetsenbord

Terwijl de selectie openstaat, hoef je de muis helemaal niet te gebruiken:

| Toets | Functie |
| --- | -------- |
| `S` | Modus voor scrollend gebied in- of uitschakelen |
| `Super + Arrow keys` | Tussen vensters bewegen in de venstermodus |
| `Return` | Het gemarkeerde venster vastleggen |
| `Ctrl + A` | De volledige gefocuste monitor vastleggen |
| `R` | Het laatste gebied herstellen dat in deze sessie is getekend |
| `Esc` | Omasnap sluiten |

Deze toetscombinaties bestaan alleen terwijl Omasnap openstaat, dus ze kunnen niet botsen met iets in je eigen configuratie.

## Schermopname

`Alt + Print Screen` opent _Trigger > Vastleggen > Schermopname_, waarin wordt gevraagd wat je op de geluidsband wilt: geen audio, desktopaudio, desktop plus microfoon, of desktop plus microfoon plus webcam. Die laatste verschijnt alleen als je daadwerkelijk een camera hebt aangesloten. Kies er een en met de opnamekiezer van Omarchy kun je een gebied slepen of op een venster of monitor klikken.

De opname draait op gpu-screen-recorder, dat op de GPU codeert op 60fps en terugvalt op de CPU als het moet. Het resultaat is een MP4 in `~/Videos`, met de naam `screenrecording-2026-08-13_14-22-05.mp4`. Stel `OMARCHY_SCREENRECORD_DIR` in om dat te wijzigen — maar let op: anders dan de map voor schermafbeeldingen moet deze al bestaan, anders weigert de opname te starten.

Terwijl je opneemt, verschijnt er een kleine indicator in de balk. Klik erop om te stoppen. Je kunt ook stoppen door opnieuw op `Alt + Print Screen` te drukken, of met het item _Schermopname stoppen_ onder _Trigger > Vastleggen > Schermopname_, dat alleen verschijnt terwijl er daadwerkelijk iets wordt opgenomen.

Stoppen doet nog wat opruimwerk voordat je het bestand krijgt: het eerste frame wordt weggeknipt, en als er audio is, wordt die genormaliseerd naar -14 LUFS, waarbij de opnameplof van PipeWire helemaal aan het begin wordt gedempt. Daarna verschijnt er een melding met een miniatuur uit de opname. Klik erop om het bestand af te spelen in mpv.

### De webcam-overlay

Wanneer je opneemt met een webcam, verschijnt de camera als een vastgepind, bijgesneden portretvenster in de rechteronderhoek van wat je ook opneemt. Als hij boven op iets staat dat je nodig hebt, pas je zijn formaat direct aan:

| Sneltoets | Functie |
| ------ | -------- |
| `Super + Alt + [` | De webcam-overlay kleiner maken |
| `Super + Alt + ]` | De webcam-overlay groter maken |

Er zijn drie formaten — klein, middelgroot en groot — en de sneltoetsen stappen ertussen. Middelgroot is de standaard. Ze zijn proportioneel aan de opname, dus de camera neemt hetzelfde deel van het frame in, of je nu een 1080p-monitor opneemt of een 6K-monitor. En als je een gebied hebt opgenomen in plaats van een volledig scherm, verankert de overlay zich aan de hoek van dat gebied in plaats van die van de monitor, zodat hij binnen de opname blijft.

Je kunt hem ook rechtstreeks aanroepen met `omarchy-capture-webcam-resize small`, of met `reset` om terug te gaan naar middelgroot.

## Tekst, QR-codes en kleuren

`Super + Ctrl + Print Screen` selecteert een gebied en past er OCR op toe naar het klembord. Dat wordt goed behandeld in [Tekstextractie & dicteren](11-text-extraction-dictation.md).

_Trigger > Vastleggen > QR-code_ doet dezelfde truc voor QR-codes. Selecteer het gebied met de code erin, en de gedecodeerde waarde gaat naar het klembord. Hij zoekt alleen naar QR-codes — dichte scherminhoud wordt anders maar al te graag ten onrechte voor een streepjescode aangezien. Goed om te weten: de gedecodeerde waarde gaat naar het klembord en nergens anders heen. Hij wordt niet afgedrukt, hij staat niet in de melding, en hij is als gevoelig gemarkeerd zodat hij niet blijft hangen in de [klembordgeschiedenis](08-unified-clipboard-history.md). QR-codes dragen routinematig geheimen met zich mee — de `otpauth://` URI achter een 2FA-instelcode, bijvoorbeeld — en die wil je niet in een log hebben. Plakken werkt nog prima.

`Super + Print Screen` (of _Trigger > Vastleggen > Kleur_) verandert de cursor in een pipet. Klik op iets op het scherm en de kleur belandt op het klembord. Druk opnieuw op de sneltoets om terug te gaan zonder iets te kiezen.

## Transcoderen voordat je deelt

Een 4K-schermopname of een rauwe HEIC van je telefoon is vaak te groot om zomaar te versturen. `Super + Ctrl + .` (of _Trigger > Transcoderen_) lost dat op. Het biedt je een fuzzy bestandskiezer over `~/Pictures` en `~/Videos`, en vraagt je dan om een formaat en een grootte.

Foto's gaan naar jpg of png op hoog, middelgroot of laag, wat de breedte beperkt tot 3160, 2160 en 1080 pixels. Video's gaan naar mp4 of een geanimeerde gif op 4k, 1080p of 720p. Het geconverteerde bestand wordt naast het origineel geschreven met de resolutie in de naam — `demo-1080p.mp4` — en het pad wordt als bestands-URI naar het klembord gekopieerd, zodat je het rechtstreeks kunt plakken in een app die bestanden accepteert die je erop laat vallen.

Het werkt ook vanuit de terminal, als je al weet wat je wilt: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Er is ook `omarchy transcode ascii`, dat een afbeelding omzet in ASCII-kunst — die is vooral voor [branding](41-branding.md).

## Ergens naartoe sturen

Zodra je het bestand hebt, opent `Super + Ctrl + S` het menu Delen en stuurt het via LocalSend naar een ander apparaat op je netwerk. Zie [GUI's](22-guis.md) daarvoor.
