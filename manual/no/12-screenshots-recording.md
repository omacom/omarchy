# Skjermbilder og opptak

Alt du kan hente av skjermen henger på Print Screen-tasten. Én tast alene tar et bilde, og modifikatorene tar et opptak, en farge eller teksten inne i et område. Hvis tastaturet ditt ikke har noen Print Screen-tast i det hele tatt, åpner `Super + Ctrl + C` det samme settet som en meny.

| Snarvei | Funksjon |
| ------ | -------- |
| `Print Screen` | Skjermbilde |
| `Alt + Print Screen` | Skjermopptak (eller stopp det som kjører) |
| `Super + Print Screen` | Fargevelger |
| `Super + Ctrl + Print Screen` | Trekk tekst ut av et område |
| `Super + Ctrl + C` | Opptaksmeny |
| `Super + Ctrl + .` | Omkod et bilde eller en video |

## Skjermbilder

Trykk `Print Screen`, og Omasnap fanger den fokuserte skjermen før overlegget dens dukker opp, slik at ingenting skifter under deg mens du sikter. Dra et frittformet område, klikk et vindu for å fange det, eller klikk åpen plass for å fange hele skjermen. Trykk `S` før du tegner for å fange et rullende område. Angret deg? Trykk `Print Screen` igjen for å avbryte Omasnap.

Etter at du har valgt et område, lagrer Omasnap fangsten, kopierer den til utklippstavlen og viser en forhåndsvisning i 10 sekunder. Bruk forhåndsvisningens festeknapp eller `Ctrl + P` for å beholde den på skjermen, eller velg Rediger for å annotere den.

Annoteringseditoren kan tegne piler, linjer, former, uthevinger, nummererte markører, tekst og sikre sladdinger; beskjære eller klippe ut en del av bildet; OCR-e teksten dens; og legge til et bakteppe. I editoren trykker du `Enter` for å kopiere og lagre den ferdige PNG-en, `Ctrl + C` for å kopiere den uten å lagre, eller `Ctrl + S` for å lagre den uten å kopiere.

Lagrede skjermbilder havner som standard i `~/Pictures/Screenshots`, med et navn som `screenshot-2026-08-13_14-22-05-firefox.png`. Sett `OMASNAP_SCREENSHOT_DIR` for å bruke en annen mappe — se [FAQ-en](46-faq.md) for hvor øktmiljøvariabler skal legges. Omasnap oppretter mappen når den lagrer det første skuddet. Sett `[output] autosave = false` i `~/.config/omasnap/omasnap.conf` for å deaktivere automatisk lagring.

Fra terminalen åpner `omarchy screenshot` det samme overlegget, og du kan velge startmodusen dens: `omarchy capture screenshot region`, `windows`, `fullscreen` eller `scroll`. Et andre argument `copy` eller `save` hopper over forhåndsvisningen og sender skuddet rett til den destinasjonen. For å redigere før utdata, bruker du `omarchy screenshot --editor=overlay` for en fullskjermeditor eller `omarchy screenshot --editor=window` for et eget vindu.

### Styre velgeren fra tastaturet

Mens valget er oppe, trenger du ikke bruke musen i det hele tatt:

| Tast | Funksjon |
| --- | -------- |
| `S` | Veksle modus for rullende område |
| `Super + Arrow keys` | Flytt mellom vinduer i vindusmodus |
| `Return` | Fang det uthevede vinduet |
| `Ctrl + A` | Fang hele den fokuserte skjermen |
| `R` | Gjenopprett det siste området tegnet i denne økten |
| `Esc` | Avbryt Omasnap |

Disse bindingene finnes bare mens Omasnap er åpen, så de kan ikke kollidere med noe i din egen konfigurasjon.

## Skjermopptak

`Alt + Print Screen` åpner _Utløs > Opptak > Skjermopptak_, som spør hva du vil ha på lydsporet: ingen lyd, skrivebordslyd, skrivebord pluss mikrofon, eller skrivebord pluss mikrofon pluss webcam. Den siste vises bare hvis du faktisk har et kamera plugget inn. Velg én, og Omarchys opptaksvelger lar deg dra et område eller klikke et vindu eller en skjerm.

Opptaket kjører på gpu-screen-recorder, som koder på GPU-en ved 60 fps og faller tilbake til CPU-en hvis den må. Resultatet er en MP4 i `~/Videos`, kalt `screenrecording-2026-08-13_14-22-05.mp4`. Sett `OMARCHY_SCREENRECORD_DIR` for å endre det — men merk at i motsetning til skjermbildemappen må denne finnes allerede, ellers nekter opptaket å starte.

Mens du tar opp, dukker en liten indikator opp i linjen. Klikk den for å stoppe. Du kan også stoppe med `Alt + Print Screen` igjen, eller med oppføringen _Stopp skjermopptak_ under _Utløs > Opptak > Skjermopptak_, som bare vises mens noe faktisk tar opp.

Å stoppe gjør litt rydding før den gir deg filen: den første rammen trimmes, og hvis det er lyd, normaliseres den til -14 LUFS med PipeWire-fangstøyen helt i starten dempet. Deretter dukker et varsel opp med et miniatyrbilde fra opptaket. Klikk det for å spille av filen i mpv.

### Webcam-overlegget

Når du tar opp med et webcam, vises kameraet som et festet, beskåret portrettvindu i nedre høyre hjørne av det du tar opp. Hvis det sitter oppå noe du trenger, endrer du størrelsen i farten:

| Snarvei | Funksjon |
| ------ | -------- |
| `Super + Alt + [` | Gjør webcam-overlegget mindre |
| `Super + Alt + ]` | Gjør webcam-overlegget større |

Det finnes tre størrelser — liten, middels og stor — og snarveiene går mellom dem. Middels er standarden. De er proporsjonale med opptaket, så kameraet tar opp samme andel av rammen enten du tar opp en 1080p-skjerm eller en 6K-skjerm. Og hvis du tok opp et område snarere enn en hel skjerm, forankres overlegget til det områdets hjørne i stedet for skjermens, slik at det forblir inne i skuddet.

Du kan også kalle det direkte med `omarchy-capture-webcam-resize small`, eller `reset` for å gå tilbake til middels.

## Tekst, QR-koder og farger

`Super + Ctrl + Print Screen` velger et område og OCR-er det til utklippstavlen. Det dekkes ordentlig i [Tekstuttrekking og diktering](11-text-extraction-dictation.md).

_Utløs > Opptak > QR-kode_ gjør det samme trikset for QR-koder. Velg området med koden i, og den avkodede verdien går til utklippstavlen. Den ser bare etter QR-koder — tett skjerminnhold har en tendens til å gi falske positiver som en strekkode ellers. Verdt å vite: den avkodede verdien går til utklippstavlen og ingen andre steder. Den skrives ikke ut, den er ikke i varselet, og den markeres som sensitiv slik at den ikke blir hengende i [utklippshistorikken](08-unified-clipboard-history.md). QR-koder bærer rutinemessig hemmeligheter — `otpauth://`-URI-en bak en 2FA-oppsettkode, for eksempel — og du vil ikke ha det i en logg. Innliming fungerer fortsatt fint.

`Super + Print Screen` (eller _Utløs > Opptak > Farge_) gjør markøren til en pipette. Klikk hva som helst på skjermen, og fargen havner på utklippstavlen. Trykk snarveien igjen for å trekke deg ut uten å velge.

## Omkoding før du deler

Et 4K-skjermopptak eller en rå HEIC fra telefonen er ofte for stor til bare å sende. `Super + Ctrl + .` (eller _Utløs > Omkod_) fikser det. Den tilbyr deg en fuzzy filvelger over `~/Pictures` og `~/Videos`, og spør deretter om et format og en størrelse.

Bilder går til jpg eller png i høy, middels eller lav, som begrenser bredden til 3160, 2160 og 1080 piksler. Videoer går til mp4 eller en animert gif i 4k, 1080p eller 720p. Den konverterte filen skrives ved siden av originalen med oppløsningen i navnet — `demo-1080p.mp4` — og banen kopieres til utklippstavlen som en fil-URI, slik at du kan lime den direkte inn i en app som tar filslipp.

Den fungerer fra terminalen også, hvis du allerede vet hva du vil ha: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Det finnes også `omarchy transcode ascii`, som gjør et bilde om til ASCII-kunst — den er mest for [merkevarebygging](41-branding.md).

## Sende det et sted

Når du har filen, åpner `Super + Ctrl + S` Del-menyen og sender den til en annen enhet på nettverket ditt via LocalSend. Se [GUI-er](22-guis.md) for det.
