# Schermafbeeldingen & opnames

Alles wat je van het scherm kunt pakken, hangt aan de Print Screen-toets. Eén toets alleen maakt een foto, en de modificatoren maken een opname, pakken een kleur of halen de tekst uit een gebied. Als je toetsenbord helemaal geen Print Screen-toets heeft, maakt `Super + Ctrl + Alt + C` dezelfde schermafbeelding, en `Super + Ctrl + C` opent de hele set als menu.

| Sneltoets | Functie |
| ------ | -------- |
| `Print Screen` | Schermafbeelding |
| `Super + Ctrl + Alt + C` | Schermafbeelding |
| `Alt + Print Screen` | Schermopname (of stop de opname die loopt) |
| `Super + Print Screen` | Kleurkiezer |
| `Super + Ctrl + Print Screen` | Tekst uit een gebied extraheren |
| `Super + Ctrl + C` | Opnamemenu |
| `Super + Ctrl + .` | Een afbeelding of video transcoderen |

## Schermafbeeldingen

Druk op `Print Screen` (of `Super + Ctrl + Alt + C`) en Omasnap legt de gefocuste monitor vast voordat de overlay verschijnt, zodat er niets onder je verschuift terwijl je mikt. Sleep een vrije vorm als gebied, klik op een venster om het vast te leggen, of klik op lege ruimte om de hele monitor vast te leggen. Druk op `S` voordat je tekent om een scrollend gebied vast te leggen. Van gedachten veranderd? Druk opnieuw op dezelfde toets om Omasnap te sluiten.

Nadat je een gebied hebt geselecteerd, slaat Omasnap de opname op, kopieert die naar het klembord en toont een melding met de miniatuur ervan, net als een opgeslagen schermopname doet. Kies Open om de opgeslagen opname in je afbeeldingsviewer te bekijken, of Edit om die te annoteren.

De annotatie-editor kan pijlen, lijnen, vormen, markeringen, genummerde markeringen, tekst en veilige redacties tekenen; een deel van de afbeelding bijsnijden of uitsnijden; de tekst erin via OCR uitlezen; en een achtergrond toevoegen. Druk in de editor op `Enter` om de voltooide PNG te kopiëren en op te slaan, op `Ctrl + C` om die te kopiëren zonder op te slaan, of op `Ctrl + S` om die op te slaan zonder te kopiëren.

Opgeslagen schermafbeeldingen komen standaard terecht in `~/Pictures/Screenshots`, met een naam zoals `screenshot-2026-08-13_14-22-05-firefox.png`. Stel `OMASNAP_SCREENSHOT_DIR` in om een andere map te gebruiken — zie [de FAQ](46-faq.md) voor waar je omgevingsvariabelen voor de sessie moet zetten. Omasnap maakt de map aan wanneer het de eerste opname opslaat. Stel `[output] autosave = false` in in `~/.config/omasnap/omasnap.conf` om automatisch opslaan uit te schakelen; opnames worden dan alleen gekopieerd en 10 seconden in een voorbeeld getoond dat je met de pinknop of `Ctrl + P` op het scherm kunt houden.

Vanaf de terminal opent `omarchy screenshot` dezelfde overlay, en je kunt de startmodus ervan kiezen: `omarchy capture screenshot region`, `windows`, `fullscreen` of `scroll`. Een tweede argument `copy` of `save` stuurt de opname rechtstreeks naar die bestemming. Om te bewerken vóór de uitvoer, gebruik je `omarchy screenshot --editor=overlay` voor een editor op volledig scherm of `omarchy screenshot --editor=window` voor een apart venster.

### De kiezer bedienen vanaf het toetsenbord

Terwijl de selectie openstaat, hoef je de muis helemaal niet te gebruiken:

| Toets | Functie |
| --- | -------- |
| `S` | Scrollend-gebiedmodus in-/uitschakelen |
| `Super + Arrow keys` | Tussen vensters bewegen in Venstermodus |
| `Return` | Het gemarkeerde venster vastleggen |
| `Ctrl + A` | De volledige gefocuste monitor vastleggen |
| `R` | Het laatste gebied herstellen dat in deze sessie is getekend |
| `Esc` | Omasnap sluiten |

Deze bindingen bestaan alleen terwijl Omasnap open is, dus ze kunnen nergens mee botsen in je eigen configuratie.

## Schermopname

`Alt + Print Screen` opent _Trigger > Capture > Screenrecord_, waarin wordt gevraagd wat je op de soundtrack wilt: geen audio, desktopaudio, desktop plus microfoon, of desktop plus microfoon plus webcam. Die laatste verschijnt alleen als je daadwerkelijk een camera hebt aangesloten. Kies er een en met de opnamekiezer van Omarchy kun je een gebied slepen of op een venster of monitor klikken.

De opname draait op gpu-screen-recorder, die op de GPU encodeert op 60fps en indien nodig terugvalt op de CPU. Het resultaat is een MP4 in `~/Videos`, met de naam `screenrecording-2026-08-13_14-22-05.mp4`. Stel `OMARCHY_SCREENRECORD_DIR` in om dat te wijzigen — maar let op: anders dan de map voor schermafbeeldingen moet deze al bestaan, anders weigert de opname te starten.

Terwijl je opneemt, verschijnt er een kleine indicator in de balk. Klik erop om te stoppen. Je kunt ook stoppen door opnieuw op `Alt + Print Screen` te drukken, of met het item _Stop Screenrecording_ onder _Trigger > Capture > Screenrecord_, dat alleen verschijnt terwijl er daadwerkelijk iets wordt opgenomen.

Stoppen ruimt eerst een beetje op voordat je het bestand krijgt: het eerste frame wordt bijgesneden, en als er audio is, wordt die genormaliseerd naar -14 LUFS, waarbij de PipeWire-opnameplof helemaal aan het begin wordt gedempt. Daarna verschijnt er een melding met een miniatuur uit de opname. Klik erop om het bestand in Omaview af te spelen.

### De webcam-overlay

Wanneer je met een webcam opneemt, verschijnt de camera als een vastgezet, bijgesneden portretvenster in de rechteronderhoek van wat je opneemt. Als die bovenop iets staat dat je nodig hebt, pas je de grootte direct aan:

| Sneltoets | Functie |
| ------ | -------- |
| `Super + Alt + [` | De webcam-overlay kleiner maken |
| `Super + Alt + ]` | De webcam-overlay groter maken |

Er zijn drie groottes — klein, medium en groot — en de sneltoetsen stappen ertussen. Medium is de standaard. Ze zijn proportioneel ten opzichte van de opname, dus de camera neemt hetzelfde deel van het frame in, of je nu een 1080p-monitor of een 6K-monitor opneemt. En als je een gebied hebt opgenomen in plaats van een heel scherm, verankert de overlay aan de hoek van dat gebied in plaats van aan die van de monitor, zodat die binnen de opname blijft.

Je kunt het ook rechtstreeks aanroepen met `omarchy-capture-webcam-resize small`, of `reset` om terug te gaan naar medium.

## Tekst, QR-codes en kleuren

`Super + Ctrl + Print Screen` selecteert een gebied en zet de tekst ervan via OCR op het klembord. Dat wordt goed behandeld in [Tekstextractie & dicteren](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ doet dezelfde truc voor QR-codes. Selecteer het gebied met de code erin, en de gedecodeerde waarde gaat naar het klembord. Het zoekt alleen naar QR-codes — dichte scherminhoud wordt anders nogal eens ten onrechte als barcode gezien. Goed om te weten: de gedecodeerde waarde gaat naar het klembord en nergens anders heen. Die wordt niet afgedrukt, staat niet in de melding en is als gevoelig gemarkeerd, zodat die niet blijft hangen in de [klembordgeschiedenis](08-unified-clipboard-history.md). QR-codes bevatten routinematig geheimen — de `otpauth://`-URI achter een 2FA-instelcode bijvoorbeeld — en die wil je niet in een log hebben. Plakken werkt nog steeds prima.

`Super + Print Screen` (of _Trigger > Capture > Color_) verandert de cursor in een pipet. Klik op iets op het scherm en de kleur belandt op het klembord. Druk opnieuw op de sneltoets om terug te gaan zonder iets te kiezen.

## Transcoderen voordat je deelt

Een 4K-schermopname of een rauwe HEIC van je telefoon is vaak te groot om zomaar te versturen. `Super + Ctrl + .` (of _Trigger > Transcode_) lost dat op. Het biedt je een fuzzy bestandskiezer over `~/Pictures` en `~/Videos`, en vraagt dan om een formaat en een grootte.

Afbeeldingen gaan naar jpg of png op hoog, medium of laag, wat de breedte beperkt tot 3160, 2160 en 1080 pixels. Video's gaan naar mp4 of een geanimeerde gif op 4k, 1080p of 720p. Het geconverteerde bestand wordt naast het origineel geschreven, met de resolutie in de naam — `demo-1080p.mp4` — en het pad wordt als bestands-URI naar het klembord gekopieerd, zodat je het rechtstreeks kunt plakken in een app die bestanden accepteert via slepen en neerzetten.

Het werkt ook vanaf de terminal, als je al weet wat je wilt: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Er is ook `omarchy transcode ascii`, waarmee je een afbeelding omzet in ASCII-kunst — die is vooral voor [huisstijl](41-branding.md).

## Ergens heen sturen

Zodra je het bestand hebt, opent `Super + Ctrl + S` het Share-menu en stuurt het via LocalSend naar een ander apparaat op je netwerk. Zie [GUI's](22-guis.md) daarvoor.
