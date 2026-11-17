# Skærmbilleder & optagelse

Alt, hvad du kan hive ud af skærmen, hænger på Print Screen-tasten. Tasten alene tager et billede, og modifikatorerne tager en optagelse, en farve eller teksten i et område. Hvis dit tastatur slet ikke har en Print Screen-tast, tager `Super + Ctrl + Alt + C` det samme skærmbillede, og `Super + Ctrl + C` åbner hele sættet som en menu.

| Genvejstast | Funktion |
| ------ | -------- |
| `Print Screen` | Skærmbillede |
| `Super + Ctrl + Alt + C` | Skærmbillede |
| `Alt + Print Screen` | Skærmoptagelse (eller stop den, der kører) |
| `Super + Print Screen` | Farvevælger |
| `Super + Ctrl + Print Screen` | Udtræk tekst fra et område |
| `Super + Ctrl + C` | Optagelsesmenu |
| `Super + Ctrl + .` | Transkodér et billede eller en video |

## Skærmbilleder

Tryk på `Print Screen` (eller `Super + Ctrl + Alt + C`), og Omasnap optager den fokuserede skærm, før dens overlay vises, så intet flytter sig under dig, mens du sigter. Træk et område i fri form, klik på et vindue for at optage det, eller klik på et tomt område for at optage hele skærmen. Tryk på `S`, før du tegner, for at optage et rullende område. Har du skiftet mening? Tryk på samme tast igen for at lukke Omasnap.

Når du har valgt et område, gemmer Omasnap optagelsen, kopierer den til udklipsholderen og viser en notifikation med dens miniature, ligesom en gemt skærmoptagelse gør. Vælg Open for at se det gemte billede i din billedfremviser, eller Edit for at annotere det.

Annoteringseditoren kan tegne pile, linjer, former, fremhævninger, nummererede markører, tekst og sikre censureringer; beskære eller skære en del af billedet ud; OCR'e dets tekst; og tilføje en baggrund. I editoren skal du trykke på `Enter` for at kopiere og gemme den færdige PNG, `Ctrl + C` for at kopiere den uden at gemme eller `Ctrl + S` for at gemme den uden at kopiere.

Gemte skærmbilleder lander som standard i `~/Pictures/Screenshots` med et navn som `screenshot-2026-08-13_14-22-05-firefox.png`. Sæt `OMASNAP_SCREENSHOT_DIR` for at bruge et andet bibliotek — se [FAQ'en](46-faq.md) for, hvor du skal placere sessionsmiljøvariabler. Omasnap opretter biblioteket, når det gemmer det første billede. Sæt `[output] autosave = false` i `~/.config/omasnap/omasnap.conf` for at deaktivere automatisk lagring; optagelser kopieres derefter kun og vises i en forhåndsvisning i 10 sekunder, som du kan holde på skærmen med dens fastgørelsesknap eller `Ctrl + P`.

Fra terminalen åbner `omarchy screenshot` det samme overlay, og du kan vælge dets starttilstand: `omarchy capture screenshot region`, `windows`, `fullscreen` eller `scroll`. Et andet argument på `copy` eller `save` sender billedet direkte til den destination. Hvis du vil redigere før output, skal du bruge `omarchy screenshot --editor=overlay` til en editor i fuld skærm eller `omarchy screenshot --editor=window` til et separat vindue.

### Sådan styrer du vælgeren med tastaturet

Mens markeringen er fremme, behøver du slet ikke bruge musen:

| Tast | Funktion |
| --- | -------- |
| `S` | Slå tilstanden for rullende område til/fra |
| `Super + Arrow keys` | Bevæg dig mellem vinduer i vinduestilstand |
| `Return` | Optag det fremhævede vindue |
| `Ctrl + A` | Optag hele den fokuserede skærm |
| `R` | Gendan det sidste område, der blev tegnet i denne session |
| `Esc` | Luk Omasnap |

Disse bindinger findes kun, mens Omasnap er åben, så de kan ikke kollidere med noget i din egen konfiguration.

## Skærmoptagelse

`Alt + Print Screen` åbner _Trigger > Capture > Screenrecord_, som spørger, hvad du vil have på lydsporet: ingen lyd, skrivebordslyd, skrivebord plus mikrofon eller skrivebord plus mikrofon plus webcam. Den sidste mulighed vises kun, hvis du rent faktisk har et kamera tilsluttet. Vælg én, og Omarchys optagelsesvælger lader dig trække et område eller klikke på et vindue eller en skærm.

Optagelsen kører på gpu-screen-recorder, som encoder på GPU'en ved 60fps og falder tilbage til CPU'en, hvis den er nødt til det. Resultatet er en MP4 i `~/Videos` med navnet `screenrecording-2026-08-13_14-22-05.mp4`. Sæt `OMARCHY_SCREENRECORD_DIR` for at ændre det — men bemærk, at i modsætning til biblioteket til skærmbilleder skal dette bibliotek allerede findes, ellers nægter optagelsen at starte.

Mens du optager, vises en lille indikator i baren. Klik på den for at stoppe. Du kan også stoppe med `Alt + Print Screen` igen eller med punktet _Stop Screenrecording_ under _Trigger > Capture > Screenrecord_, som kun vises, mens der rent faktisk optages noget.

Når du stopper, ryddes der lidt op, før du får filen: Den første frame trimmes væk, og hvis der er lyd, normaliseres den til -14 LUFS, mens PipeWire-optagelsens pop i selve starten dæmpes væk. Derefter vises en notifikation med en miniature fra optagelsen. Klik på den for at afspille filen i Omaview.

### Webcam-overlayet

Når du optager med et webcam, vises kameraet som et fastgjort, beskåret portrætvindue i nederste højre hjørne af det, du optager. Hvis det ligger oven på noget, du har brug for, kan du ændre størrelsen på det med det samme:

| Genvejstast | Funktion |
| ------ | -------- |
| `Super + Alt + [` | Gør webcam-overlayet mindre |
| `Super + Alt + ]` | Gør webcam-overlayet større |

Der er tre størrelser — small, medium og large — og genvejstasterne går mellem dem. Medium er standarden. De er proportionale med optagelsen, så kameraet fylder den samme andel af billedet, uanset om du optager en 1080p-skærm eller en 6K-skærm. Og hvis du optog et område i stedet for en hel skærm, forankres overlayet til det pågældende områdes hjørne i stedet for skærmens, så det bliver inde i billedet.

Du kan også kalde det direkte med `omarchy-capture-webcam-resize small` eller `reset` for at gå tilbage til medium.

## Tekst, QR-koder og farver

`Super + Ctrl + Print Screen` vælger et område og OCR'er det til udklipsholderen. Det er dækket ordentligt i [Tekstudtrækning & diktering](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ laver det samme trick med QR-koder. Vælg området med koden i, og den afkodede værdi går til udklipsholderen. Den leder kun efter QR-koder — tæt skærmindhold har det ellers med at give falske positiver som stregkode. Værd at vide: Den afkodede værdi går til udklipsholderen og ingen andre steder. Den udskrives ikke, den er ikke i notifikationen, og den er markeret som følsom, så den ikke bliver hængende i [udklipsholderhistorikken](08-unified-clipboard-history.md). QR-koder indeholder rutinemæssigt hemmeligheder — `otpauth://` URI'en bag en opsætningskode til 2FA, for eksempel — og dem vil du ikke have i en log. Indsættelse fungerer stadig fint.

`Super + Print Screen` (eller _Trigger > Capture > Color_) forvandler markøren til en pipette. Klik på hvad som helst på skærmen, og farven lander i udklipsholderen. Tryk på genvejstasten igen for at bakke ud uden at vælge.

## Transkodning, før du deler

En skærmoptagelse i 4K eller en rå HEIC fra din telefon er ofte for stor til bare at sende. `Super + Ctrl + .` (eller _Trigger > Transcode_) klarer det. Den giver dig en fuzzy filvælger over `~/Pictures` og `~/Videos` og spørger derefter om et format og en størrelse.

Billeder går til jpg eller png på høj, mellem eller lav, som begrænser bredden til 3160, 2160 og 1080 pixels. Videoer går til mp4 eller en animeret gif på 4k, 1080p eller 720p. Den konverterede fil skrives ved siden af originalen med opløsningen i navnet — `demo-1080p.mp4` — og stien kopieres til udklipsholderen som en fil-URI, så du kan indsætte den direkte i en app, der tager imod fildrop.

Det virker også fra terminalen, hvis du allerede ved, hvad du vil have: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Der findes også `omarchy transcode ascii`, som forvandler et billede til ASCII-kunst — den er mest til [branding](41-branding.md).

## Sådan sender du det af sted

Når du har filen, åbner `Super + Ctrl + S` menuen Share og sender den til en anden enhed på dit netværk via LocalSend. Se [GUIs](22-guis.md) for det.
