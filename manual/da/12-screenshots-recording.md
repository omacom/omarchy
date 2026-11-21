# Skærmbilleder & optagelse

Alt, hvad du kan fange fra skærmen, hænger på Print Screen-tasten. Tasten alene tager et billede, og med modifikatorer tager den en optagelse, en farve eller teksten i et område. Hvis dit tastatur slet ikke har en Print Screen-tast, tager `Super + Ctrl + Alt + C` det samme skærmbillede, og `Super + Ctrl + C` åbner hele sættet som en menu.

| Genvej | Funktion |
| ------ | -------- |
| `Print Screen` | Skærmbillede |
| `Super + Ctrl + Alt + C` | Skærmbillede |
| `Alt + Print Screen` | Skærmoptagelse (eller stop den, der kører) |
| `Super + Print Screen` | Farvevælger |
| `Super + Ctrl + Print Screen` | Udtræk tekst fra et område |
| `Super + Ctrl + C` | Optagemenu |
| `Super + Ctrl + .` | Omkod et billede eller en video |

## Skærmbilleder

Tryk på `Print Screen` (eller `Super + Ctrl + Alt + C`), så fanger Omasnap den fokuserede skærm, før dens overlay vises, så intet flytter sig under dig, mens du sigter. Træk et frit område, klik på et vindue for at fange det, eller klik på åbent område for at fange hele skærmen. Tryk på `S`, før du tegner, for at fange et rullende område. Har du ombestemt dig? Tryk på den samme tast igen for at lukke Omasnap.

Når du har valgt et område, gemmer Omasnap optagelsen, kopierer den til udklipsholderen og viser en notifikation med dens miniature, ligesom en gemt skærmoptagelse gør. Vælg Open for at se det gemte billede i din billedfremviser, eller Edit for at annotere det.

Annoteringseditoren kan tegne pile, linjer, former, fremhævninger, nummererede markører, tekst og sikre overstrygninger; beskære eller skære en del af billedet ud; OCR'e dets tekst; og tilføje en baggrund. I editoren skal du trykke på `Enter` for at kopiere og gemme den færdige PNG, `Ctrl + C` for at kopiere den uden at gemme, eller `Ctrl + S` for at gemme den uden at kopiere.

Gemte skærmbilleder lander som standard i `~/Pictures/Screenshots` med et navn som `screenshot-2026-08-13_14-22-05-firefox.png`. Sæt `OMASNAP_SCREENSHOT_DIR` for at bruge en anden mappe — se [FAQ'en](46-faq.md) for, hvor du skal placere sessionsmiljøvariabler. Omasnap opretter mappen, når den gemmer det første billede. Sæt `[output] autosave = false` i `~/.config/omasnap/omasnap.conf` for at deaktivere automatisk lagring; optagelser kopieres derefter kun og vises i en forhåndsvisning i 7 sekunder, som du kan holde på skærmen med dens fastgørelsesknap eller `Ctrl + P`.

Fra terminalen åbner `omarchy screenshot` det samme overlay, og du kan vælge dens starttilstand: `omarchy capture screenshot region`, `windows`, `fullscreen` eller `scroll`. Et andet argument med `copy` eller `save` sender billedet direkte til den destination. For at redigere før output skal du bruge `omarchy screenshot --editor=overlay` til en editor i fuld skærm eller `omarchy screenshot --editor=window` til et separat vindue.

### Styr vælgeren fra tastaturet

Mens markeringen er oppe, behøver du slet ikke bruge musen:

| Tast | Funktion |
| --- | -------- |
| `S` | Slå tilstand for rullende område til/fra |
| `Super + Arrow keys` | Flyt mellem vinduer i vinduestilstand |
| `Return` | Fang det fremhævede vindue |
| `Ctrl + A` | Fang hele den fokuserede skærm |
| `R` | Gendan det sidste område, der blev tegnet i denne session |
| `Esc` | Luk Omasnap |

Disse bindinger findes kun, mens Omasnap er åben, så de kan ikke kollidere med noget i din egen konfiguration.

## Skærmoptagelse

`Alt + Print Screen` åbner _Trigger > Capture > Screenrecord_, som spørger, hvad du vil have på lydsporet: ingen lyd, skrivebordslyd, skrivebord plus mikrofon eller skrivebord plus mikrofon plus webcam. Den sidste mulighed vises kun, hvis du rent faktisk har et kamera tilsluttet. Vælg en, og Omarchys optagelsesvælger lader dig trække et område eller klikke på et vindue eller en skærm.

Optagelsen kører på gpu-screen-recorder, som koder på GPU'en ved 60fps og falder tilbage til CPU'en, hvis den er nødt til det; på GPU'er, den ikke understøtter, såsom Apple Silicons, optager Omarchy i stedet med wf-recorder. Resultatet er en MP4 i `~/Videos` med navnet `screenrecording-2026-08-13_14-22-05.mp4`. Sæt `OMARCHY_SCREENRECORD_DIR` for at ændre det — men bemærk, at i modsætning til mappen til skærmbilleder skal denne mappe allerede findes, ellers nægter optagelsen at starte.

Mens du optager, vises en lille indikator i bjælken. Klik på den for at stoppe. Du kan også stoppe med `Alt + Print Screen` igen eller med punktet _Stop Screenrecording_ under _Trigger > Capture > Screenrecord_, som kun vises, mens noget rent faktisk optager.

Når du stopper, rydder den lidt op, før den giver dig filen: den første frame trimmes væk, og hvis der er lyd, normaliseres den til -14 LUFS, mens PipeWire-optagelsens pop i den allerførste start dæmpes væk. Derefter vises en notifikation med en miniature fra optagelsen. Vælg _Open_ for at afspille filen i Omaview eller _Cut_ for at trimme den i Omacut.

### Webcam-overlayet

Når du optager med et webcam, vises kameraet som et fastgjort, beskåret portrætvindue i nederste højre hjørne af det, du optager. Hvis det ligger oven på noget, du har brug for, kan du ændre størrelsen på det i farten:

| Genvej | Funktion |
| ------ | -------- |
| `Super + Alt + [` | Gør webcam-overlayet mindre |
| `Super + Alt + ]` | Gør webcam-overlayet større |

Der er tre størrelser — lille, mellem og stor — og genvejene træder mellem dem. Mellem er standarden. De er proportionale med optagelsen, så kameraet fylder den samme andel af billedet, uanset om du optager en 1080p-skærm eller en 6K-skærm. Og hvis du optog et område i stedet for en hel skærm, forankres overlayet til det områdes hjørne i stedet for skærmens, så det bliver inde i billedet.

Du kan også kalde det direkte med `omarchy-capture-webcam-resize small` eller `reset` for at gå tilbage til mellem.

## Tekst, QR-koder og farver

`Super + Ctrl + Print Screen` vælger et område og OCR'er det til udklipsholderen. Det er dækket ordentligt i [Tekstudtræk & diktering](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ gør det samme trick for QR-koder. Vælg området med koden i, og den afkodede værdi ryger i udklipsholderen. Den leder kun efter QR-koder — tæt skærmindhold har det ellers med at give falske positive som stregkode. Værd at vide: den afkodede værdi ryger i udklipsholderen og ingen andre steder. Den udskrives ikke, den er ikke i notifikationen, og den er markeret som følsom, så den ikke bliver hængende i [udklipsholderhistorikken](08-unified-clipboard-history.md). QR-koder bærer rutinemæssigt på hemmeligheder — `otpauth://`-URI'en bag en 2FA-opsætningskode, for eksempel — og den vil du ikke have i en log. Indsættelse virker stadig fint.

`Super + Print Screen` (eller _Trigger > Capture > Color_) forvandler markøren til en pipette. Klik på hvad som helst på skærmen, og farven lander i udklipsholderen. Tryk på genvejen igen for at bakke ud uden at vælge.

## Omkodning, før du deler

En 4K-skærmoptagelse eller en rå HEIC fra din telefon er ofte for stor til bare at sende. `Super + Ctrl + .` (eller _Trigger > Transcode_) klarer det. Den giver dig en fuzzy filvælger over `~/Pictures` og `~/Videos` og spørger derefter om et format og en størrelse.

Billeder går til jpg eller png ved høj, mellem eller lav, som begrænser bredden til 3160, 2160 og 1080 pixels. Videoer går til mp4 eller en animeret gif ved 4k, 1080p eller 720p. Den konverterede fil skrives ved siden af originalen med opløsningen i navnet — `demo-1080p.mp4` — og stien kopieres til udklipsholderen som en fil-URI, så du kan indsætte den direkte i en app, der tager imod filslip.

Det virker også fra terminalen, hvis du allerede ved, hvad du vil have: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Der er også `omarchy transcode ascii`, som forvandler et billede til ASCII-kunst — den er mest til [branding](41-branding.md).

## Send det et sted hen

Når du har filen, åbner `Super + Ctrl + S` Share-menuen og sender den til en anden enhed på dit netværk via LocalSend. Se [GUI'er](22-guis.md) for det.
