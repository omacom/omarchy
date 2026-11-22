# Skjermbilder og opptak

Alt du kan hente fra skjermen, henger på Print Screen-tasten. Én tast alene tar et bilde, og modifikatortastene tar et opptak, en farge eller teksten inne i et område. Hvis tastaturet ditt ikke har en Print Screen-tast i det hele tatt, tar `Super + Ctrl + Alt + C` det samme skjermbildet, og `Super + Ctrl + C` åpner hele settet som en meny.

| Hurtigtast | Funksjon |
| ------ | -------- |
| `Print Screen` | Skjermbilde |
| `Super + Ctrl + Alt + C` | Skjermbilde |
| `Alt + Print Screen` | Skjermopptak (eller stopp det som kjører) |
| `Super + Print Screen` | Fargevelger |
| `Super + Ctrl + Print Screen` | Hent ut tekst fra et område |
| `Super + Ctrl + C` | Fangstmeny |
| `Super + Ctrl + .` | Transkod et bilde eller en video |

## Skjermbilder

Trykk `Print Screen` (eller `Super + Ctrl + Alt + C`), så fanger Omasnap den fokuserte skjermen før overlegget vises, slik at ingenting flytter seg under deg mens du sikter. Dra et område i fri form, klikk på et vindu for å fange det, eller klikk på åpen plass for å fange hele skjermen. Trykk `S` før du tegner for å fange et rullende område. Har du ombestemt deg? Trykk samme tast igjen for å lukke Omasnap.

Etter at du velger et område, lagrer Omasnap fangsten, kopierer den til utklippstavlen og viser et varsel med miniatyrbildet, slik et lagret skjermopptak gjør. Velg Open for å se det lagrede bildet i bildeviseren din, eller Edit for å merke det.

Merknadseditoren kan tegne piler, linjer, former, uthevinger, nummererte markører, tekst og sikre sladdinger; beskjære eller klippe ut en del av bildet; OCR-e teksten i det; og legge til en bakgrunn. I editoren trykker du `Enter` for å kopiere og lagre den ferdige PNG-en, `Ctrl + C` for å kopiere den uten å lagre, eller `Ctrl + S` for å lagre den uten å kopiere.

Lagrede skjermbilder havner som standard i `~/Pictures/Screenshots`, med et navn som `screenshot-2026-08-13_14-22-05-firefox.png`. Sett `OMASNAP_SCREENSHOT_DIR` for å bruke en annen katalog — se [FAQ-en](46-faq.md) for hvor du skal legge miljøvariabler for økten. Omasnap oppretter katalogen når den lagrer det første bildet. Sett `[output] autosave = false` i `~/.config/omasnap/omasnap.conf` for å slå av automatisk lagring; fangster blir da bare kopiert og vist i en forhåndsvisning i 7 sekunder, som du kan beholde på skjermen med festeknappen eller `Ctrl + P`.

Fra terminalen åpner `omarchy screenshot` det samme overlegget, og du kan velge startmodusen: `omarchy capture screenshot region`, `windows`, `fullscreen` eller `scroll`. Et andre argument med `copy` eller `save` sender bildet rett til den destinasjonen. For å redigere før utdata bruker du `omarchy screenshot --editor=overlay` for en fullskjermeditor eller `omarchy screenshot --editor=window` for et eget vindu.

### Styre velgeren fra tastaturet

Mens valget er oppe, trenger du ikke bruke musen i det hele tatt:

| Tast | Funksjon |
| --- | -------- |
| `S` | Veksle modus for rullende område |
| `Super + Arrow keys` | Flytt mellom vinduer i Window mode |
| `Return` | Fang det uthevede vinduet |
| `Ctrl + A` | Fang hele den fokuserte skjermen |
| `R` | Gjenopprett det siste området som ble tegnet i denne økten |
| `Esc` | Lukk Omasnap |

Disse bindingene finnes bare mens Omasnap er åpen, så de kan ikke kollidere med noe i din egen konfigurasjon.

## Skjermopptak

`Alt + Print Screen` åpner _Trigger > Capture > Screenrecord_, som spør hva du vil ha på lydsporet: ingen lyd, skrivebordslyd, skrivebord pluss mikrofon, eller skrivebord pluss mikrofon pluss webkamera. Det siste alternativet vises bare hvis du faktisk har et kamera koblet til. Velg ett, så lar Omarchys opptaksvelger deg dra et område eller klikke på et vindu eller en skjerm.

Opptaket kjører på gpu-screen-recorder, som koder på GPU-en ved 60fps og faller tilbake til CPU-en hvis den må; på GPU-er den ikke støtter, som Apple Silicons, tar Omarchy i stedet opp med wf-recorder. Resultatet er en MP4 i `~/Videos`, med navn som `screenrecording-2026-08-13_14-22-05.mp4`. Sett `OMARCHY_SCREENRECORD_DIR` for å endre det — men merk at i motsetning til skjermbildekatalogen må denne finnes fra før, ellers nekter opptaket å starte.

Mens du tar opp, vises en liten indikator i linjen. Klikk på den for å stoppe. Du kan også stoppe med `Alt + Print Screen` igjen, eller med _Stop Screenrecording_-oppføringen under _Trigger > Capture > Screenrecord_, som bare vises mens noe faktisk tar opp.

Når du stopper, rydder den litt før den gir deg filen: den første rammen trimmes bort, og hvis det er lyd, normaliseres den til -14 LUFS med PipeWire-fangstsmellet helt i starten dempet bort. Deretter vises et varsel med et miniatyrbilde fra opptaket. Velg _Open_ for å spille filen i Omaview, eller _Cut_ for å trimme den i Omacut.

### Webkameraoverlegget

Når du tar opp med et webkamera, vises kameraet som et festet, beskåret portrettvindu i nederste høyre hjørne av det du tar opp. Hvis det ligger oppå noe du trenger, kan du endre størrelsen på direkten:

| Hurtigtast | Funksjon |
| ------ | -------- |
| `Super + Alt + [` | Gjør webkameraoverlegget mindre |
| `Super + Alt + ]` | Gjør webkameraoverlegget større |

Det finnes tre størrelser — liten, middels og stor — og hurtigtastene går trinnvis mellom dem. Middels er standarden. De er proporsjonale med opptaket, så kameraet tar samme andel av bildet enten du tar opp en 1080p-skjerm eller en 6K-skjerm. Og hvis du tok opp et område i stedet for en hel skjerm, forankres overlegget til hjørnet av det området i stedet for skjermens, så det blir værende inne i bildet.

Du kan også kalle det direkte med `omarchy-capture-webcam-resize small`, eller `reset` for å gå tilbake til middels.

## Tekst, QR-koder og farger

`Super + Ctrl + Print Screen` velger et område og OCR-er det til utklippstavlen. Det er dekket ordentlig i [Tekstuthenting og diktering](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ gjør det samme trikset for QR-koder. Velg området med koden i, så går den avkodede verdien til utklippstavlen. Den ser bare etter QR-koder — tett skjerminnhold har en tendens til ellers å gi falske treff som strekkode. Verdt å vite: den avkodede verdien går til utklippstavlen og ingen andre steder. Den skrives ikke ut, den står ikke i varselet, og den er merket som sensitiv slik at den ikke blir liggende i [utklippstavlehistorikken](08-unified-clipboard-history.md). QR-koder bærer jevnlig hemmeligheter — `otpauth://`-URI-en bak en 2FA-oppsettskode, for eksempel — og det vil du ikke ha i en logg. Å lime inn fungerer fortsatt helt fint.

`Super + Print Screen` (eller _Trigger > Capture > Color_) gjør markøren til en pipette. Klikk på hva som helst på skjermen, så havner fargen på utklippstavlen. Trykk hurtigtasten igjen for å trekke deg ut uten å velge.

## Transkoding før du deler

Et 4K-skjermopptak eller en rå HEIC fra telefonen din er ofte for stor til bare å sende. `Super + Ctrl + .` (eller _Trigger > Transcode_) fikser det. Den gir deg en filvelger med fuzzysøk over `~/Pictures` og `~/Videos`, og spør deretter om format og størrelse.

Bilder går til jpg eller png i høy, middels eller lav, som begrenser bredden til 3160, 2160 og 1080 piksler. Videoer går til mp4 eller en animert gif i 4k, 1080p eller 720p. Den konverterte filen skrives ved siden av originalen med oppløsningen i navnet — `demo-1080p.mp4` — og stien kopieres til utklippstavlen som en fil-URI, så du kan lime den rett inn i en app som tar imot filslipp.

Det fungerer fra terminalen også, hvis du allerede vet hva du vil ha: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Det finnes også `omarchy transcode ascii`, som gjør et bilde om til ASCII-kunst — den er mest til [merkevarebygging](41-branding.md).

## Sende det et sted

Når du har filen, åpner `Super + Ctrl + S` Share-menyen og sender den til en annen enhet på nettverket ditt via LocalSend. Se [GUI-er](22-guis.md) for det.
