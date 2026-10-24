# Schermafbeeldingen & opname

Alles wat je van het scherm kunt pakken hangt aan de Print Screen-toets. Eén toets op zichzelf maakt een foto, en de modifiers maken een opname, een kleur, of de tekst binnen een gebied. Als je toetsenbord helemaal geen Print Screen-toets heeft, opent `Super + Ctrl + C` dezelfde set als een menu.

| Sneltoets | Functie |
| ------ | -------- |
| `Print Screen` | Schermafbeelding |
| `Alt + Print Screen` | Schermopname (of stop degene die draait) |
| `Super + Print Screen` | Kleurkiezer |
| `Super + Ctrl + Print Screen` | Tekst uit een gebied extraheren |
| `Super + Ctrl + C` | Vastleg-menu |
| `Super + Ctrl + .` | Een afbeelding of video transcoderen |

## Schermafbeeldingen

Druk op `Print Screen` en Omasnap legt de gefocuste monitor vast voordat zijn overlay verschijnt, zodat niets onder je verschuift terwijl je mikt. Sleep een vrij gebied, klik op een venster om het vast te leggen, of klik op open ruimte om de hele monitor vast te leggen. Druk op `S` voordat je tekent om een scrollend gebied vast te leggen. Van gedachten veranderd? Druk opnieuw op `Print Screen` om Omasnap te sluiten.

Nadat je een gebied hebt geselecteerd, slaat Omasnap de opname op, kopieert hem naar het klembord en toont een preview voor 10 seconden. Gebruik de pin-knop van de preview of `Ctrl + P` om hem op het scherm te houden, of kies Bewerken om hem te annoteren.

De annotatie-editor kan pijlen, lijnen, vormen, markeringen, genummerde markers, tekst en beveiligde redacties tekenen; een deel van de afbeelding bijsnijden of uitsnijden; de tekst OCR'en; en een achtergrond toevoegen. Druk in de editor op `Enter` om de voltooide PNG te kopiëren en op te slaan, `Ctrl + C` om hem te kopiëren zonder op te slaan, of `Ctrl + S` om hem op te slaan zonder te kopiëren.

Opgeslagen schermafbeeldingen landen standaard in `~/Pictures/Screenshots`, met een naam zoals `screenshot-2026-08-13_14-22-05-firefox.png`. Stel `OMASNAP_SCREENSHOT_DIR` in om een andere map te gebruiken — zie [de FAQ](46-faq.md) voor waar je sessie-omgevingsvariabelen plaatst. Omasnap maakt de map aan wanneer hij de eerste foto opslaat. Stel `[output] autosave = false` in in `~/.config/omasnap/omasnap.conf` om automatisch opslaan uit te schakelen.

Vanaf de terminal opent `omarchy screenshot` dezelfde overlay, en je kunt zijn startmodus kiezen: `omarchy capture screenshot region`, `windows`, `fullscreen` of `scroll`. Een tweede argument van `copy` of `save` slaat de preview over en stuurt de foto rechtstreeks naar die bestemming. Om te bewerken vóór uitvoer gebruik je `omarchy screenshot --editor=overlay` voor een editor op volledig scherm of `omarchy screenshot --editor=window` voor een apart venster.

### De kiezer bedienen vanaf het toetsenbord

Terwijl de selectie actief is, hoef je de muis helemaal niet te gebruiken:

| Toets | Functie |
| --- | -------- |
| `S` | Schakel scrollend-gebied-modus |
| `Super + Arrow keys` | Beweeg tussen vensters in Venstermodus |
| `Return` | Leg het gemarkeerde venster vast |
| `Ctrl + A` | Leg de volledige gefocuste monitor vast |
| `R` | Herstel het laatste gebied dat in deze sessie is getekend |
| `Esc` | Sluit Omasnap |

Deze bindingen bestaan alleen terwijl Omasnap open is, dus ze kunnen niet botsen met iets in je eigen config.

## Schermopname

`Alt + Print Screen` opent _Activeren > Vastleggen > Schermopname_, dat vraagt wat je op de soundtrack wilt: geen audio, desktopaudio, desktop plus microfoon, of desktop plus microfoon plus webcam. Die laatste verschijnt alleen als je daadwerkelijk een camera hebt aangesloten. Kies er een en Omarchy's opnamekiezer laat je een gebied slepen of op een venster of monitor klikken.

Opname draait op gpu-screen-recorder, dat op de GPU encodeert met 60fps en terugvalt op de CPU als het moet. Het resultaat is een MP4 in `~/Videos`, met de naam `screenrecording-2026-08-13_14-22-05.mp4`. Stel `OMARCHY_SCREENRECORD_DIR` in om dat te veranderen — maar merk op dat deze map, in tegenstelling tot de schermafbeeldingenmap, al moet bestaan, anders weigert de opname te starten.

Terwijl je opneemt, verschijnt er een kleine indicator in de balk. Klik erop om te stoppen. Je kunt ook stoppen met opnieuw `Alt + Print Screen`, of met het item _Schermopname stoppen_ onder _Activeren > Vastleggen > Schermopname_, dat alleen verschijnt terwijl er daadwerkelijk iets opneemt.

Stoppen doet wat opruimwerk voordat het je het bestand geeft: het eerste frame wordt bijgesneden, en als er audio is wordt het genormaliseerd naar -14 LUFS waarbij de PipeWire-vastleg-pop aan het begin wordt gedempt. Dan verschijnt er een melding met een thumbnail van de opname. Klik erop om het bestand af te spelen in mpv.

### De webcam-overlay

Wanneer je opneemt met een webcam, verschijnt de camera als een vastgepind, bijgesneden portretvenster in de rechterbenedenhoek van wat je opneemt. Als hij bovenop iets zit wat je nodig hebt, resize je hem on the fly:

| Sneltoets | Functie |
| ------ | -------- |
| `Super + Alt + [` | Maak de webcam-overlay kleiner |
| `Super + Alt + ]` | Maak de webcam-overlay groter |

Er zijn drie maten — klein, medium en groot — en de sneltoetsen stappen ertussen. Medium is de standaard. Ze zijn proportioneel aan de opname, dus de camera neemt hetzelfde deel van het frame in of je nu een 1080p-monitor of een 6K-monitor opneemt. En als je een gebied hebt opgenomen in plaats van een heel scherm, verankert de overlay aan de hoek van dat gebied in plaats van die van de monitor, zodat hij binnen de opname blijft.

Je kunt het ook direct aanroepen met `omarchy-capture-webcam-resize small`, of `reset` om terug te gaan naar medium.

## Tekst, QR-codes en kleuren

`Super + Ctrl + Print Screen` selecteert een gebied en OCR't het naar het klembord. Dat wordt goed behandeld in [Tekstextractie & dicteren](11-text-extraction-dictation.md).

_Activeren > Vastleggen > QR-code_ doet dezelfde truc voor QR-codes. Selecteer het gebied met de code erin, en de gedecodeerde waarde gaat naar het klembord. Het zoekt alleen naar QR-codes — dichte scherminhoud heeft de gewoonte om anders false-positive te zijn als barcode. Goed om te weten: de gedecodeerde waarde gaat naar het klembord en nergens anders. Hij wordt niet geprint, hij staat niet in de melding, en hij is gemarkeerd als gevoelig zodat hij niet blijft hangen in de [klembordgeschiedenis](08-unified-clipboard-history.md). QR-codes dragen routinematig geheimen — de `otpauth://`-URI achter een 2FA-setupcode bijvoorbeeld — en dat wil je niet in een log. Plakken werkt nog steeds prima.

`Super + Print Screen` (of _Activeren > Vastleggen > Kleur_) verandert de cursor in een pipet. Klik op iets op het scherm en de kleur landt op het klembord. Druk opnieuw op de sneltoets om terug te gaan zonder te kiezen.

## Transcoderen voordat je deelt

Een 4K-schermopname of een rauwe HEIC van je telefoon is vaak te groot om zomaar te versturen. `Super + Ctrl + .` (of _Activeren > Transcoderen_) fixt dat. Het biedt je een fuzzy bestandskiezer over `~/Pictures` en `~/Videos`, en vraagt dan om een formaat en een grootte.

Afbeeldingen gaan naar jpg of png op hoog, medium of laag, die de breedte begrenzen op 3160, 2160 en 1080 pixels. Video's gaan naar mp4 of een geanimeerde gif op 4k, 1080p of 720p. Het geconverteerde bestand wordt naast het origineel geschreven met de resolutie in de naam — `demo-1080p.mp4` — en het pad wordt gekopieerd naar het klembord als een bestands-URI, zodat je het direct kunt plakken in een app die bestandsdrops accepteert.

Het werkt ook vanaf de terminal, als je al weet wat je wilt: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Er is ook `omarchy transcode ascii`, dat een afbeelding omzet in ASCII-art — die is vooral voor [branding](41-branding.md).

## Het ergens heen sturen

Zodra je het bestand hebt, opent `Super + Ctrl + S` het Delen-menu en stuurt het naar een ander apparaat op je netwerk via LocalSend. Zie [GUIs](22-guis.md) daarvoor.
