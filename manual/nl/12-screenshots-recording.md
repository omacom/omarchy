# Schermafbeeldingen en opnamen

Alles wat je van het scherm kunt pakken, hangt aan de Print Screen-toets. Eén toets op zichzelf maakt een foto, en de modificatietoetsen maken een opname, pakken een kleur of halen de tekst uit een gebied. Als je toetsenbord helemaal geen Print Screen-toets heeft, maakt `Super + Ctrl + Alt + C` dezelfde schermafbeelding en opent `Super + Ctrl + C` de hele set als menu.

| Sneltoets | Functie |
| ------ | -------- |
| `Print Screen` | Schermafbeelding |
| `Super + Ctrl + Alt + C` | Schermafbeelding |
| `Alt + Print Screen` | Schermopname (of stop degene die loopt) |
| `Super + Print Screen` | Kleurkiezer |
| `Super + Ctrl + Print Screen` | Tekst uit een gebied halen |
| `Super + Ctrl + C` | Vastlegmenu |
| `Super + Ctrl + .` | Een afbeelding of video omzetten |

## Schermafbeeldingen

Druk op `Print Screen` (of `Super + Ctrl + Alt + C`) en Omasnap legt de monitor met focus vast voordat de overlay verschijnt, zodat er niets onder je verschuift terwijl je mikt. Sleep een vrij gevormd gebied, klik op een venster om dat vast te leggen, of klik op open ruimte om de hele monitor vast te leggen. Druk op `S` voordat je tekent om een scrollend gebied vast te leggen. Van gedachten veranderd? Druk opnieuw op dezelfde toets om Omasnap te sluiten.

Nadat je een gebied hebt geselecteerd, slaat Omasnap de opname op, kopieert die naar het klembord en toont een melding met de miniatuur ervan, net zoals een opgeslagen schermopname doet. Kies Openen om de opgeslagen opname in je afbeeldingenviewer te bekijken, of Bewerken om er aantekeningen op te maken.

De annotatie-editor kan pijlen, lijnen, vormen, markeringen, genummerde markers en tekst tekenen en beveiligde redacties aanbrengen; een deel van de afbeelding bijsnijden of eruit knippen; de tekst eruit OCR'en; en een achtergrond toevoegen. Druk in de editor op `Enter` om de voltooide PNG te kopiëren en op te slaan, op `Ctrl + C` om die te kopiëren zonder op te slaan, of op `Ctrl + S` om die op te slaan zonder te kopiëren.

Opgeslagen schermafbeeldingen belanden standaard in `~/Pictures/Screenshots`, met een naam zoals `screenshot-2026-08-13_14-22-05-firefox.png`. Stel `OMASNAP_SCREENSHOT_DIR` in om een andere map te gebruiken — zie [de FAQ](46-faq.md) voor waar je omgevingsvariabelen voor de sessie moet zetten. Omasnap maakt de map aan wanneer het de eerste opname opslaat. Stel `[output] autosave = false` in in `~/.config/omasnap/omasnap.conf` om automatisch opslaan uit te schakelen; opnamen worden dan alleen gekopieerd en 7 seconden lang in een voorbeeld getoond dat je met de vastpin-knop of `Ctrl + P` op het scherm kunt houden.

Vanuit de terminal opent `omarchy screenshot` dezelfde overlay, en je kunt de startmodus kiezen: `omarchy capture screenshot region`, `windows`, `fullscreen` of `scroll`. Een tweede argument van `copy` of `save` stuurt de opname rechtstreeks naar die bestemming. Gebruik om vóór de uitvoer te bewerken `omarchy screenshot --editor=overlay` voor een editor op volledig scherm of `omarchy screenshot --editor=window` voor een apart venster.

### De kiezer bedienen vanaf het toetsenbord

Terwijl de selectie openstaat, hoef je de muis helemaal niet te gebruiken:

| Toets | Functie |
| --- | -------- |
| `S` | Scrollend-gebiedmodus in- of uitschakelen |
| `Super + Arrow keys` | Tussen vensters bewegen in Venstermodus |
| `Return` | Het gemarkeerde venster vastleggen |
| `Ctrl + A` | De volledige monitor met focus vastleggen |
| `R` | Het laatste gebied herstellen dat in deze sessie is getekend |
| `Esc` | Omasnap sluiten |

Deze toetscombinaties bestaan alleen terwijl Omasnap open is, dus ze kunnen nergens mee botsen in je eigen configuratie.

## Schermopname

`Alt + Print Screen` opent _Trigger > Vastleggen > Schermopname_, waarin wordt gevraagd wat je op de geluidsband wilt: geen audio, bureaubladaudio, bureaublad plus microfoon, of bureaublad plus microfoon plus webcam. Die laatste verschijnt alleen als je daadwerkelijk een camera hebt aangesloten. Kies er een en met de opnamekiezer van Omarchy kun je een gebied slepen of op een venster of monitor klikken.

De opname draait op gpu-screen-recorder, dat op de GPU codeert met 60fps en indien nodig terugvalt op de CPU; op GPU's die dat niet ondersteunt, zoals die van Apple Silicon, neemt Omarchy in plaats daarvan op met wf-recorder. Het resultaat is een MP4 in `~/Videos`, met de naam `screenrecording-2026-08-13_14-22-05.mp4`. Stel `OMARCHY_SCREENRECORD_DIR` in om dat te wijzigen — maar let op: anders dan de map voor schermafbeeldingen moet deze al bestaan, anders weigert de opname te starten.

Terwijl je opneemt, verschijnt er een kleine indicator in de balk. Klik erop om te stoppen. Je kunt ook opnieuw stoppen met `Alt + Print Screen`, of met het item _Schermopname stoppen_ onder _Trigger > Vastleggen > Schermopname_, dat alleen verschijnt terwijl er daadwerkelijk iets wordt opgenomen.

Stoppen ruimt eerst een beetje op voordat je het bestand krijgt: het eerste frame wordt eraf geknipt, en als er audio is, wordt die genormaliseerd naar -14 LUFS, waarbij de opnameplop van PipeWire helemaal aan het begin wordt gedempt. Daarna verschijnt er een melding met een miniatuur uit de opname. Kies _Openen_ om het bestand in Omaview af te spelen, of _Knippen_ om het in Omacut bij te snijden.

### De webcam-overlay

Wanneer je opneemt met een webcam, verschijnt de camera als een vastgepind, bijgesneden portretvenster in de rechteronderhoek van wat je ook opneemt. Als die bovenop iets staat dat je nodig hebt, pas je de grootte direct aan:

| Sneltoets | Functie |
| ------ | -------- |
| `Super + Alt + [` | De webcam-overlay kleiner maken |
| `Super + Alt + ]` | De webcam-overlay groter maken |

Er zijn drie groottes — klein, middelgroot en groot — en de sneltoetsen stappen ertussen. Middelgroot is de standaard. Ze zijn proportioneel aan de opname, dus de camera neemt hetzelfde deel van het frame in, of je nu een 1080p-monitor of een 6K-monitor opneemt. En als je een gebied hebt opgenomen in plaats van een volledig scherm, verankert de overlay zich aan de hoek van dat gebied in plaats van aan die van de monitor, zodat die binnen de opname blijft.

Je kunt het ook rechtstreeks aanroepen met `omarchy-capture-webcam-resize small`, of met `reset` om terug te gaan naar middelgroot.

## Tekst, QR-codes en kleuren

`Super + Ctrl + Print Screen` selecteert een gebied en OCR't dat naar het klembord. Dat wordt goed behandeld in [Tekstextractie en dicteren](11-text-extraction-dictation.md).

_Trigger > Vastleggen > QR Code_ doet dezelfde truc voor QR-codes. Selecteer het gebied met de code erin, en de gedecodeerde waarde gaat naar het klembord. Het zoekt alleen naar QR-codes — dichte scherminhoud heeft anders de gewoonte om als barcode vals positief uit te slaan. Goed om te weten: de gedecodeerde waarde gaat naar het klembord en nergens anders heen. Die wordt niet afgedrukt, staat niet in de melding en is als gevoelig gemarkeerd, zodat die niet blijft hangen in de [klembordgeschiedenis](08-unified-clipboard-history.md). QR-codes dragen routinematig geheimen met zich mee — de `otpauth://` URI achter een 2FA-instelcode, bijvoorbeeld — en die wil je niet in een logboek hebben. Plakken werkt nog steeds prima.

`Super + Print Screen` (of _Trigger > Vastleggen > Kleur_) verandert de cursor in een pipet. Klik op iets op het scherm en de kleur belandt op het klembord. Druk opnieuw op de sneltoets om terug te gaan zonder iets te kiezen.

## Omzetten voordat je deelt

Een 4K-schermopname of een rauwe HEIC van je telefoon is vaak te groot om zomaar te versturen. `Super + Ctrl + .` (of _Trigger > Omzetten_) lost dat op. Het biedt je een fuzzy bestands kiezer over `~/Pictures` en `~/Videos`, en vraagt daarna om een formaat en een grootte.

Afbeeldingen gaan naar jpg of png op hoog, middelgroot of laag, wat de breedte beperkt tot 3160, 2160 en 1080 pixels. Video's gaan naar mp4 of een geanimeerde gif op 4k, 1080p of 720p. Het geconverteerde bestand wordt naast het origineel geschreven, met de resolutie in de naam — `demo-1080p.mp4` — en het pad wordt als bestands-URI naar het klembord gekopieerd, zodat je het rechtstreeks kunt plakken in een app die bestandsslepen accepteert.

Het werkt ook vanuit de terminal, als je al weet wat je wilt: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Er is ook `omarchy transcode ascii`, dat een afbeelding omzet in ASCII-kunst — die is vooral voor [huisstijl](41-branding.md).

## Ergens naartoe sturen

Zodra je het bestand hebt, opent `Super + Ctrl + S` het menu Delen en stuurt het via LocalSend naar een ander apparaat op je netwerk. Zie [GUI's](22-guis.md) daarvoor.
