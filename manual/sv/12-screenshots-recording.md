# Skärmbilder & inspelning

Allt du kan fånga från skärmen hänger på Print Screen-tangenten. En tangent på egen hand tar en bild, och modifierarna tar en inspelning, en färg eller texten inuti en region. Om ditt tangentbord inte har någon Print Screen-tangent alls tar `Super + Ctrl + Alt + C` samma skärmbild, och `Super + Ctrl + C` öppnar hela uppsättningen som en meny.

| Snabbtangent | Funktion |
| ------ | -------- |
| `Print Screen` | Skärmbild |
| `Super + Ctrl + Alt + C` | Skärmbild |
| `Alt + Print Screen` | Skärminspelning (eller stoppa den som körs) |
| `Super + Print Screen` | Färgväljare |
| `Super + Ctrl + Print Screen` | Extrahera text från en region |
| `Super + Ctrl + C` | Fångstmeny |
| `Super + Ctrl + .` | Transkoda en bild eller video |

## Skärmbilder

Tryck på `Print Screen` (eller `Super + Ctrl + Alt + C`) så fångar Omasnap den fokuserade skärmen innan dess överlägg visas, så att inget flyttar sig under dig medan du siktar. Dra en region i fri form, klicka på ett fönster för att fånga det, eller klicka på öppen yta för att fånga hela skärmen. Tryck på `S` innan du ritar för att fånga en rullande region. Ändrat dig? Tryck på samma tangent igen för att stänga Omasnap.

När du har valt ett område sparar Omasnap fångsten, kopierar den till urklipp och visar en avisering med dess miniatyrbild, precis som en sparad skärminspelning gör. Välj Open för att visa den sparade bilden i din bildvisare, eller Edit för att annotera den.

Annoteringsredigeraren kan rita pilar, linjer, former, markeringar, numrerade markörer, text och säkra maskeringar; beskära eller skära ut en del av bilden; OCR:a dess text; och lägga till en bakgrundsplatta. I redigeraren trycker du på `Enter` för att kopiera och spara den färdiga PNG:n, `Ctrl + C` för att kopiera den utan att spara, eller `Ctrl + S` för att spara den utan att kopiera.

Sparade skärmbilder hamnar som standard i `~/Pictures/Screenshots`, med ett namn som `screenshot-2026-08-13_14-22-05-firefox.png`. Ställ in `OMASNAP_SCREENSHOT_DIR` för att använda en annan katalog — se [FAQ:n](46-faq.md) för var du ska placera miljövariabler för sessionen. Omasnap skapar katalogen när den sparar den första bilden. Ställ in `[output] autosave = false` i `~/.config/omasnap/omasnap.conf` för att inaktivera automatisk sparning; fångster kopieras då bara, och visas i en förhandsgranskning i 10 sekunder som du kan hålla kvar på skärmen med dess nålknapp eller `Ctrl + P`.

Från terminalen öppnar `omarchy screenshot` samma överlägg, och du kan välja dess startläge: `omarchy capture screenshot region`, `windows`, `fullscreen` eller `scroll`. Ett andra argument med `copy` eller `save` skickar bilden direkt till den destinationen. För att redigera innan utmatning använder du `omarchy screenshot --editor=overlay` för en redigerare i helskärm eller `omarchy screenshot --editor=window` för ett separat fönster.

### Styr väljaren från tangentbordet

Medan markeringen är uppe behöver du inte använda musen alls:

| Tangent | Funktion |
| --- | -------- |
| `S` | Växla läge för rullande region |
| `Super + Arrow keys` | Flytta mellan fönster i fönsterläge |
| `Return` | Fånga det markerade fönstret |
| `Ctrl + A` | Fånga hela den fokuserade skärmen |
| `R` | Återställ den senaste regionen som ritades i den här sessionen |
| `Esc` | Stäng Omasnap |

De här bindningarna finns bara medan Omasnap är öppen, så de kan inte krocka med något i din egen konfiguration.

## Skärminspelning

`Alt + Print Screen` öppnar _Trigger > Capture > Screenrecord_, som frågar vad du vill ha på ljudspåret: inget ljud, skrivbordsljud, skrivbord plus mikrofon, eller skrivbord plus mikrofon plus webbkamera. Det sista alternativet visas bara om du faktiskt har en kamera inkopplad. Välj ett så låter Omarchy:s inspelningsväljare dig dra en region eller klicka på ett fönster eller en skärm.

Inspelningen körs på gpu-screen-recorder, som kodar på GPU:n i 60fps och faller tillbaka på CPU:n om den måste. Resultatet blir en MP4 i `~/Videos`, med namnet `screenrecording-2026-08-13_14-22-05.mp4`. Ställ in `OMARCHY_SCREENRECORD_DIR` för att ändra det — men notera att den här katalogen, till skillnad från skärmbildskatalogen, måste finnas redan, annars vägrar inspelningen att starta.

Medan du spelar in dyker en liten indikator upp i panelen. Klicka på den för att stoppa. Du kan också stoppa med `Alt + Print Screen` igen, eller med posten _Stop Screenrecording_ under _Trigger > Capture > Screenrecord_, som bara visas medan något faktiskt spelar in.

Att stoppa gör lite städning innan du får filen: den första bildrutan trimmas bort, och om det finns ljud normaliseras det till -14 LUFS med det där poppet från PipeWire-fångsten alldeles i början bortdämpat. Sedan visas en avisering med en miniatyrbild från inspelningen. Klicka på den för att spela upp filen i Omaview.

### Webbkameraöverlägget

När du spelar in med en webbkamera visas kameran som ett fastnålat, beskuret porträttfönster i det nedre högra hörnet av det du spelar in. Om den ligger ovanpå något du behöver kan du ändra storleken på den i farten:

| Snabbtangent | Funktion |
| ------ | -------- |
| `Super + Alt + [` | Gör webbkameraöverlägget mindre |
| `Super + Alt + ]` | Gör webbkameraöverlägget större |

Det finns tre storlekar — liten, medel och stor — och snabbtangenterna stegar mellan dem. Medel är standard. De är proportionella mot inspelningen, så kameran tar upp samma andel av bilden vare sig du spelar in en skärm i 1080p eller en i 6K. Och om du spelade in en region snarare än en hel skärm förankras överlägget i den regionens hörn snarare än skärmens, så att det håller sig inuti bilden.

Du kan också anropa det direkt med `omarchy-capture-webcam-resize small`, eller `reset` för att gå tillbaka till medel.

## Text, QR-koder och färger

`Super + Ctrl + Print Screen` väljer en region och OCR:ar den till urklipp. Det täcks ordentligt i [Textextrahering & diktering](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ gör samma trick för QR-koder. Välj regionen med koden i den, så hamnar det avkodade värdet i urklipp. Den letar bara efter QR-koder — tätt skärminnehåll har en vana att annars felaktigt hittas som en streckkod. Värt att veta: det avkodade värdet hamnar i urklipp och ingen annanstans. Det skrivs inte ut, det finns inte i aviseringen, och det markeras som känsligt så att det inte blir kvar i [urklippshistoriken](08-unified-clipboard-history.md). QR-koder bär rutinmässigt på hemligheter — `otpauth://`-URI:n bakom en 2FA-inställningskod, till exempel — och den vill du inte ha i en logg. Att klistra in fungerar fortfarande utmärkt.

`Super + Print Screen` (eller _Trigger > Capture > Color_) förvandlar markören till en pipett. Klicka på vad som helst på skärmen så hamnar färgen i urklipp. Tryck på snabbtangenten igen för att backa ur utan att välja.

## Transkodning innan du delar

En skärminspelning i 4K eller en rå HEIC från din telefon är ofta för stor för att bara skicka. `Super + Ctrl + .` (eller _Trigger > Transcode_) fixar det. Den ger dig en suddig filsökare över `~/Pictures` och `~/Videos`, och frågar sedan efter ett format och en storlek.

Bilder går till jpg eller png i hög, medel eller låg, vilket begränsar bredden till 3160, 2160 respektive 1080 pixlar. Videor går till mp4 eller en animerad gif i 4k, 1080p eller 720p. Den konverterade filen skrivs bredvid originalet med upplösningen i namnet — `demo-1080p.mp4` — och sökvägen kopieras till urklipp som en fil-URI, så att du kan klistra in den direkt i en app som tar emot fildropp.

Det fungerar från terminalen också, om du redan vet vad du vill: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Det finns också `omarchy transcode ascii`, som förvandlar en bild till ASCII-konst — den är mest till för [varumärkesprofilering](41-branding.md).

## Skicka den någonstans

När du har fått filen öppnar `Super + Ctrl + S` Share-menyn och skickar den till en annan enhet på ditt nätverk via LocalSend. Se [GUIs](22-guis.md) för det.
