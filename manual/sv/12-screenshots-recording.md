# Skärmbilder & inspelning

Allt du kan ta från skärmen hänger på Print Screen-tangenten. En tangent på egen hand tar en bild, och modifierarna tar en inspelning, en färg eller texten inuti en region. Om ditt tangentbord inte har någon Print Screen-tangent alls öppnar `Super + Ctrl + C` samma uppsättning som en meny.

| Snabbtangent | Funktion |
| ------ | -------- |
| `Print Screen` | Skärmbild |
| `Alt + Print Screen` | Skärminspelning (eller stoppa den som körs) |
| `Super + Print Screen` | Färgväljare |
| `Super + Ctrl + Print Screen` | Extrahera text från en region |
| `Super + Ctrl + C` | Fångstmeny |
| `Super + Ctrl + .` | Omkoda en bild eller video |

## Skärmbilder

Tryck på `Print Screen` och Omasnap fångar den fokuserade skärmen innan dess overlay visas, så att ingenting flyttar sig under dig medan du siktar. Dra en frihandsregion, klicka på ett fönster för att fånga det eller klicka på öppet utrymme för att fånga hela skärmen. Tryck på `S` innan du ritar för att fånga en rullande region. Ändrat dig? Tryck på `Print Screen` igen för att avvisa Omasnap.

När du har valt ett område sparar Omasnap fångsten, kopierar den till urklippet och visar en förhandsgranskning i 10 sekunder. Använd förhandsgranskningens fästknapp eller `Ctrl + P` för att hålla kvar den på skärmen, eller välj Edit för att annotera den.

Annoteringsredigeraren kan rita pilar, linjer, former, markeringar, numrerade markörer, text och säkra maskeringar; beskära eller klippa ut en del av bilden; OCR:a dess text; och lägga till en bakgrund. I redigeraren, tryck på `Enter` för att kopiera och spara den färdiga PNG:n, `Ctrl + C` för att kopiera den utan att spara, eller `Ctrl + S` för att spara den utan att kopiera.

Sparade skärmbilder hamnar i `~/Pictures/Screenshots` som standard, med ett namn som `screenshot-2026-08-13_14-22-05-firefox.png`. Ställ in `OMASNAP_SCREENSHOT_DIR` för att använda en annan katalog — se [FAQ](46-faq.md) för var du placerar sessionsmiljövariabler. Omasnap skapar katalogen när den sparar den första bilden. Ställ in `[output] autosave = false` i `~/.config/omasnap/omasnap.conf` för att inaktivera automatisk sparning.

Från terminalen öppnar `omarchy screenshot` samma overlay, och du kan välja dess startläge: `omarchy capture screenshot region`, `windows`, `fullscreen` eller `scroll`. Ett andra argument `copy` eller `save` hoppar över förhandsgranskningen och skickar bilden direkt till den destinationen. För att redigera före utmatning, använd `omarchy screenshot --editor=overlay` för en helskärmsredigerare eller `omarchy screenshot --editor=window` för ett separat fönster.

### Styra väljaren från tangentbordet

Medan urvalet är uppe behöver du inte använda musen alls:

| Tangent | Funktion |
| --- | -------- |
| `S` | Växla rullande region-läge |
| `Super + Arrow keys` | Flytta mellan fönster i fönsterläge |
| `Return` | Fånga det markerade fönstret |
| `Ctrl + A` | Fånga hela den fokuserade skärmen |
| `R` | Återställ den senaste regionen som ritats i denna session |
| `Esc` | Avvisa Omasnap |

Dessa bindningar existerar bara medan Omasnap är öppen, så de kan inte krocka med någonting i din egen konfiguration.

## Skärminspelning

`Alt + Print Screen` öppnar _Trigger > Capture > Screenrecord_, som frågar vad du vill ha på ljudspåret: inget ljud, skrivbordsljud, skrivbord plus mikrofon eller skrivbord plus mikrofon plus webbkamera. Det sista visas bara om du faktiskt har en kamera inkopplad. Välj ett så låter Omarchys inspelningsväljare dig dra en region eller klicka på ett fönster eller en skärm.

Inspelningen körs på gpu-screen-recorder, som kodar på GPU:n i 60fps och faller tillbaka på CPU:n om den måste. Resultatet är en MP4 i `~/Videos`, med namnet `screenrecording-2026-08-13_14-22-05.mp4`. Ställ in `OMARCHY_SCREENRECORD_DIR` för att ändra det — men observera att till skillnad från skärmbildskatalogen måste den här redan existera, annars vägrar inspelningen att starta.

Medan du spelar in visas en liten indikator i fältet. Klicka på den för att stoppa. Du kan också stoppa med `Alt + Print Screen` igen, eller med posten _Stop Screenrecording_ under _Trigger > Capture > Screenrecord_, som bara visas medan något faktiskt spelar in.

Att stoppa gör lite städning innan den ger dig filen: den första bildrutan trimmas, och om det finns ljud normaliseras det till -14 LUFS med PipeWire-fångst-poppen allra i början avstängd. Sedan visas en avisering med en miniatyr från inspelningen. Klicka på den för att spela upp filen i mpv.

### Webbkamera-overlayen

När du spelar in med en webbkamera visas kameran som ett fäst, beskuret porträttfönster i det nedre högra hörnet av vad du än spelar in. Om den sitter ovanpå något du behöver, ändra storlek på den i farten:

| Snabbtangent | Funktion |
| ------ | -------- |
| `Super + Alt + [` | Gör webbkamera-overlayen mindre |
| `Super + Alt + ]` | Gör webbkamera-overlayen större |

Det finns tre storlekar — liten, medel och stor — och snabbtangenterna stiger mellan dem. Medel är standard. De är proportionella mot inspelningen, så kameran tar upp samma andel av bildrutan oavsett om du spelar in en 1080p-skärm eller en 6K-skärm. Och om du spelade in en region snarare än en hel skärm förankras overlayen i den regionens hörn snarare än skärmens, så att den stannar inuti bilden.

Du kan också anropa den direkt med `omarchy-capture-webcam-resize small`, eller `reset` för att gå tillbaka till medel.

## Text, QR-koder och färger

`Super + Ctrl + Print Screen` väljer en region och OCR:ar den till urklippet. Det behandlas ordentligt i [Textextrahering & diktering](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ gör samma trick för QR-koder. Välj regionen med koden i den, så går det avkodade värdet till urklippet. Den letar bara efter QR-koder — tätt skärminnehåll har annars en vana att falskpositiva som streckkod. Värt att veta: det avkodade värdet går till urklippet och ingen annanstans. Det skrivs inte ut, det finns inte i aviseringen och det är markerat som känsligt så att det inte stannar kvar i [urklippshistoriken](08-unified-clipboard-history.md). QR-koder bär rutinmässigt hemligheter — `otpauth://`-URI:n bakom en 2FA-konfigurationskod, till exempel — och du vill inte ha det i en logg. Inklistring fungerar fortfarande bra.

`Super + Print Screen` (eller _Trigger > Capture > Color_) förvandlar markören till en pipett. Klicka på vad som helst på skärmen så hamnar färgen på urklippet. Tryck på snabbtangenten igen för att backa ut utan att välja.

## Omkodning innan du delar

En 4K-skärminspelning eller en rå HEIC från din telefon är ofta för stor för att bara skicka. `Super + Ctrl + .` (eller _Trigger > Transcode_) fixar det. Den erbjuder dig en fuzzy-filvaljare över `~/Pictures` och `~/Videos` och frågar sedan efter ett format och en storlek.

Bilder går till jpg eller png på hög, medel eller låg, vilket begränsar bredden till 3160, 2160 och 1080 pixlar. Videor går till mp4 eller en animerad gif i 4k, 1080p eller 720p. Den konverterade filen skrivs bredvid originalet med upplösningen i namnet — `demo-1080p.mp4` — och sökvägen kopieras till urklippet som en fil-URI, så att du kan klistra in den direkt i en app som tar fildroppar.

Det fungerar från terminalen också, om du redan vet vad du vill: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Det finns också `omarchy transcode ascii`, som förvandlar en bild till ASCII-konst — den är mest för [branding](41-branding.md).

## Skicka den någonstans

När du väl har filen öppnar `Super + Ctrl + S` Dela-menyn och skickar den till en annan enhet i ditt nätverk via LocalSend. Se [GUI:er](22-guis.md) för det.
