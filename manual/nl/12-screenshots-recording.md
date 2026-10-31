# Schermafbeeldingen & opname

Alles wat je van het scherm kunt pakken, hangt aan de Print Screen-toets. Eén toets alleen maakt een foto, en de modificatietoetsen maken een opname, pakken een kleur of halen de tekst uit een regio. Als je toetsenbord helemaal geen Print Screen-toets heeft, maakt `Super + Ctrl + Alt + C` dezelfde schermafbeelding, en `Super + Ctrl + C` opent de hele set als menu.

| Sneltoets | Functie |
| ------ | -------- |
| `Print Screen` | Schermafbeelding |
| `Super + Ctrl + Alt + C` | Schermafbeelding |
| `Alt + Print Screen` | Schermopname (of stop de opname die loopt) |
| `Super + Print Screen` | Kleurkiezer |
| `Super + Ctrl + Print Screen` | Tekst uit een regio halen |
| `Super + Ctrl + C` | Opnamemenu |
| `Super + Ctrl + .` | Een afbeelding of video transcoderen |

## Schermafbeeldingen

Druk op `Print Screen` (of `Super + Ctrl + Alt + C`) en Omasnap legt de gefocuste monitor vast voordat de overlay verschijnt, zodat er niets onder je verschuift terwijl je mikt. Sleep een regio in vrije vorm, klik op een venster om het vast te leggen, of klik op open ruimte om de hele monitor vast te leggen. Druk op `S` voordat je tekent om een scrollende regio vast te leggen. Van gedachten veranderd? Druk opnieuw op dezelfde toets om Omasnap te sluiten.

Nadat je een gebied hebt geselecteerd, slaat Omasnap de opname op, kopieert deze naar het klembord en toont een melding met de miniatuur, net zoals een opgeslagen schermopname doet. Kies Open om de opgeslagen opname in je afbeeldingsviewer te bekijken, of Edit om deze te annoteren.

De annotatie-editor kan pijlen, lijnen, vormen, markeringen, genummerde markers en tekst tekenen, en beveiligde redacties aanbrengen; een deel van de afbeelding bijsnijden of eruit knippen; de tekst eruit OCR'en; en een achtergrond toevoegen. Druk in de editor op `Enter` om de voltooide PNG te kopiëren en op te slaan, op `Ctrl + C` om deze te kopiëren zonder op te slaan, of op `Ctrl + S` om deze op te slaan zonder te kopiëren.

Opgeslagen schermafbeeldingen komen standaard terecht in `~/Pictures/Screenshots`, met een naam zoals `screenshot-2026-08-13_14-22-05-firefox.png`. Stel `OMASNAP_SCREENSHOT_DIR` in om een andere map te gebruiken — zie [de FAQ](46-faq.md) voor waar je omgevingsvariabelen voor de sessie moet plaatsen. Omasnap maakt de map aan wanneer het de eerste opname opslaat. Stel `[output] autosave = false` in in `~/.config/omasnap/omasnap.conf` om automatisch opslaan uit te schakelen; opnames worden dan alleen gekopieerd, en 10 seconden lang getoond in een voorbeeld dat je met de pinknop of `Ctrl + P` op het scherm kunt houden.

Vanuit de terminal opent `omarchy screenshot` dezelfde overlay, en je kunt de startmodus kiezen: `omarchy capture screenshot region`, `windows`, `fullscreen` of `scroll`. Een tweede argument `copy` of `save` stuurt de opname rechtstreeks naar die bestemming. Om te bewerken vóór de uitvoer gebruik je `omarchy screenshot --editor=overlay` voor een editor op volledig scherm of `omarchy screenshot --editor=window` voor een apart venster.

### De kiezer bedienen met het toetsenbord

Terwijl de selectie openstaat, hoef je de muis helemaal niet te gebruiken:

| Toets | Functie |
| --- | -------- |
| `S` | Modus voor scrollende regio in-/uitschakelen |
| `Super + Arrow keys` | Tussen vensters bewegen in Venstermodus |
| `Return` | Het gemarkeerde venster vastleggen |
| `Ctrl + A` | De volledige gefocuste monitor vastleggen |
| `R` | De laatste regio herstellen die in deze sessie is getekend |
| `Esc` | Omasnap sluiten |

Deze toetscombinaties bestaan alleen zolang Omasnap open is, dus ze kunnen nergens mee botsen in je eigen configuratie.

## Schermopname

`Alt + Print Screen` opent _Trigger > Capture > Screenrecord_, dat vraagt wat je op de soundtrack wilt: geen audio, desktopaudio, desktop plus microfoon, of desktop plus microfoon plus webcam. Die laatste verschijnt alleen als je daadwerkelijk een camera hebt aangesloten. Kies er een en met de opnamekiezer van Omarchy kun je een regio slepen of op een venster of monitor klikken.

De opname draait op gpu-screen-recorder, dat op de GPU encodeert met 60fps en terugvalt op de CPU als het moet. Het resultaat is een MP4 in `~/Videos`, met de naam `screenrecording-2026-08-13_14-22-05.mp4`. Stel `OMARCHY_SCREENRECORD_DIR` in om dat te wijzigen — maar let op: anders dan de map voor schermafbeeldingen moet deze al bestaan, anders weigert de opname te starten.

Terwijl je opneemt, verschijnt er een kleine indicator in de balk. Klik erop om te stoppen. Je kunt ook opnieuw stoppen met `Alt + Print Screen`, of met het item _Stop Screenrecording_ onder _Trigger > Capture > Screenrecord_, dat alleen verschijnt zolang er daadwerkelijk iets wordt opgenomen.

Stoppen ruimt eerst wat op voordat het je het bestand overhandigt: het eerste frame wordt eraf geknipt, en als er audio is, wordt die genormaliseerd naar -14 LUFS, met de opnameplop van PipeWire helemaal aan het begin eruit gedempt. Daarna verschijnt er een melding met een miniatuur uit de opname. Klik erop om het bestand in mpv af te spelen.

### De webcam-overlay

Wanneer je opneemt met een webcam, verschijnt de camera als een vastgezet, bijgesneden portretvenster in de rechterbenedenhoek van wat je ook opneemt. Als hij boven op iets zit dat je nodig hebt, pas je de grootte direct aan:

| Sneltoets | Functie |
| ------ | -------- |
| `Super + Alt + [` | De webcam-overlay kleiner maken |
| `Super + Alt + ]` | De webcam-overlay groter maken |

Er zijn drie formaten — klein, medium en groot — en de sneltoetsen stappen ertussen. Medium is de standaard. Ze zijn proportioneel ten opzichte van de opname, dus de camera neemt hetzelfde deel van het frame in, of je nu een 1080p-monitor of een 6K-monitor opneemt. En als je een regio hebt opgenomen in plaats van een volledig scherm, verankert de overlay zich aan de hoek van die regio in plaats van aan die van de monitor, zodat hij binnen de opname blijft.

Je kunt het ook rechtstreeks aanroepen met `omarchy-capture-webcam-resize small`, of `reset` om terug te gaan naar medium.

## Tekst, QR-codes en kleuren

`Super + Ctrl + Print Screen` selecteert een regio en OCR't deze naar het klembord. Dat wordt goed behandeld in [Tekstextractie & dicteren](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ doet dezelfde truc voor QR-codes. Selecteer de regio met de code erin, en de gedecodeerde waarde gaat naar het klembord. Het zoekt alleen naar QR-codes — dichte scherminhoud heeft anders de gewoonte om vals-positief als barcode te worden gezien. Goed om te weten: de gedecodeerde waarde gaat naar het klembord en nergens anders heen. Hij wordt niet afgedrukt, hij staat niet in de melding, en hij is gemarkeerd als gevoelig zodat hij niet blijft hangen in de [klembordgeschiedenis](08-unified-clipboard-history.md). QR-codes dragen routinematig geheimen met zich mee — de `otpauth://`-URI achter een 2FA-instelcode, bijvoorbeeld — en die wil je niet in een log hebben. Plakken werkt nog steeds prima.

`Super + Print Screen` (of _Trigger > Capture > Color_) verandert de cursor in een pipet. Klik op wat dan ook op het scherm en de kleur belandt op het klembord. Druk opnieuw op de sneltoets om terug te gaan zonder iets te kiezen.

## Transcoderen voordat je deelt

Een 4K-schermopname of een rauwe HEIC van je telefoon is vaak te groot om zomaar te versturen. `Super + Ctrl + .` (of _Trigger > Transcode_) lost dat op. Het biedt je een fuzzy bestandskiezer over `~/Pictures` en `~/Videos`, en vraagt daarna om een formaat en een grootte.

Afbeeldingen gaan naar jpg of png op hoog, medium of laag, wat de breedte begrenst op 3160, 2160 en 1080 pixels. Video's gaan naar mp4 of een geanimeerde gif op 4k, 1080p of 720p. Het geconverteerde bestand wordt naast het origineel geschreven met de resolutie in de naam — `demo-1080p.mp4` — en het pad wordt als bestands-URI naar het klembord gekopieerd, zodat je het rechtstreeks kunt plakken in een app die bestandsdrops accepteert.

Het werkt ook vanuit de terminal, als je al weet wat je wilt: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Er is ook `omarchy transcode ascii`, dat een afbeelding omzet in ASCII-kunst — die is vooral voor [branding](41-branding.md).

## Ergens naartoe sturen

Zodra je het bestand hebt, opent `Super + Ctrl + S` het Share-menu en stuurt het via LocalSend naar een ander apparaat op je netwerk. Zie [GUIs](22-guis.md) daarvoor.
