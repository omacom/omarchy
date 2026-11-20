# Skjermbilder og opptak

Alt du kan hente fra skjermen, henger på Print Screen-tasten. Én tast alene tar et bilde, og modifikatorene tar et opptak, en farge eller teksten inne i et område. Hvis tastaturet ditt ikke har en Print Screen-tast i det hele tatt, tar `Super + Ctrl + Alt + C` det samme skjermbildet, og `Super + Ctrl + C` åpner hele settet som en meny.

| Hurtigtast | Funksjon |
| ------ | -------- |
| `Print Screen` | Skjermbilde |
| `Super + Ctrl + Alt + C` | Skjermbilde |
| `Alt + Print Screen` | Skjermopptak (eller stopp det som kjører) |
| `Super + Print Screen` | Fargevelger |
| `Super + Ctrl + Print Screen` | Hent tekst fra et område |
| `Super + Ctrl + C` | Opptaksmeny |
| `Super + Ctrl + .` | Transkod et bilde eller en video |

## Skjermbilder

Trykk `Print Screen` (eller `Super + Ctrl + Alt + C`), så fanger Omasnap den fokuserte skjermen før overlegget vises, så ingenting flytter seg under deg mens du sikter. Dra et område i fri form, klikk på et vindu for å fange det, eller klikk på åpen plass for å fange hele skjermen. Trykk `S` før du tegner for å fange et rullende område. Har du ombestemt deg? Trykk samme tast igjen for å lukke Omasnap.

Etter at du har valgt et område, lagrer Omasnap bildet, kopierer det til utklippstavlen og viser et varsel med miniatyrbildet sitt, slik et lagret skjermopptak gjør. Velg Open for å se det lagrede bildet i bildeviseren din, eller Edit for å legge til merknader i det.

Redigeringsverktøyet for merknader kan tegne piler, linjer, former, uthevinger, nummererte markører, tekst og sikre sladdinger; beskjære eller klippe ut en del av bildet; gjenkjenne teksten med OCR; og legge til en bakgrunn. I redigeringsverktøyet trykker du `Enter` for å kopiere og lagre den ferdige PNG-en, `Ctrl + C` for å kopiere den uten å lagre, eller `Ctrl + S` for å lagre den uten å kopiere.

Lagrede skjermbilder havner som standard i `~/Pictures/Screenshots`, med et navn som `screenshot-2026-08-13_14-22-05-firefox.png`. Angi `OMASNAP_SCREENSHOT_DIR` for å bruke en annen mappe — se [FAQ-en](46-faq.md) for hvor du skal legge miljøvariabler for økten. Omasnap oppretter mappen når den lagrer det første bildet. Angi `[output] autosave = false` i `~/.config/omasnap/omasnap.conf` for å slå av automatisk lagring; bildene blir da bare kopiert, og vist i en forhåndsvisning i 10 sekunder som du kan holde på skjermen med festeknappen eller `Ctrl + P`.

Fra terminalen åpner `omarchy screenshot` det samme overlegget, og du kan velge startmodusen: `omarchy capture screenshot region`, `windows`, `fullscreen` eller `scroll`. Et andre argument med `copy` eller `save` sender bildet rett til den destinasjonen. For å redigere før utdata bruker du `omarchy screenshot --editor=overlay` for et redigeringsverktøy i fullskjerm eller `omarchy screenshot --editor=window` for et eget vindu.

### Styre velgeren fra tastaturet

Mens utvalget er oppe, trenger du ikke bruke musen i det hele tatt:

| Tast | Funksjon |
| --- | -------- |
| `S` | Veksle modus for rullende område |
| `Super + Arrow keys` | Flytt mellom vinduer i vindusmodus |
| `Return` | Fang det uthevede vinduet |
| `Ctrl + A` | Fang hele den fokuserte skjermen |
| `R` | Gjenopprett det siste området tegnet i denne økten |
| `Esc` | Lukk Omasnap |

Disse bindingene finnes bare mens Omasnap er åpen, så de kan ikke kollidere med noe i din egen konfigurasjon.

## Skjermopptak

`Alt + Print Screen` åpner _Trigger > Capture > Screenrecord_, som spør hva du vil ha på lydsporet: ingen lyd, skrivebordslyd, skrivebord pluss mikrofon, eller skrivebord pluss mikrofon pluss webkamera. Det siste alternativet vises bare hvis du faktisk har et kamera koblet til. Velg ett, så lar Omarchys opptaksvelger deg dra et område eller klikke på et vindu eller en skjerm.

Opptaket kjører på gpu-screen-recorder, som koder på GPU-en med 60fps og faller tilbake til CPU-en hvis den må. Resultatet er en MP4 i `~/Videos`, med navn som `screenrecording-2026-08-13_14-22-05.mp4`. Angi `OMARCHY_SCREENRECORD_DIR` for å endre det — men merk at i motsetning til mappen for skjermbilder må denne finnes fra før, ellers nekter opptaket å starte.

Mens du tar opp, dukker det opp en liten indikator i linjen. Klikk på den for å stoppe. Du kan også stoppe med `Alt + Print Screen` igjen, eller med oppføringen _Stop Screenrecording_ under _Trigger > Capture > Screenrecord_, som bare vises mens noe faktisk tas opp.

Når du stopper, rydder den litt opp før den gir deg filen: det første bildet trimmes bort, og hvis det er lyd, normaliseres den til -14 LUFS, med PipeWire-kneppet fra opptaket helt i starten dempet bort. Deretter vises et varsel med et miniatyrbilde fra opptaket. Klikk på det for å spille av filen i Omaview.

### Webkameraoverlegget

Når du tar opp med et webkamera, vises kameraet som et festet, beskåret portrettvindu i hjørnet nederst til høyre i det du tar opp. Hvis det ligger over noe du trenger, kan du endre størrelsen på det i farten:

| Hurtigtast | Funksjon |
| ------ | -------- |
| `Super + Alt + [` | Gjør webkameraoverlegget mindre |
| `Super + Alt + ]` | Gjør webkameraoverlegget større |

Det finnes tre størrelser — liten, medium og stor — og hurtigtastene går trinnvis mellom dem. Medium er standarden. De er proporsjonale med opptaket, så kameraet tar opp samme andel av bildet enten du tar opp en 1080p-skjerm eller en 6K-skjerm. Og hvis du tok opp et område i stedet for en hel skjerm, forankres overlegget til hjørnet av det området i stedet for skjermens, så det holder seg inne i bildet.

Du kan også kalle det direkte med `omarchy-capture-webcam-resize small`, eller `reset` for å gå tilbake til medium.

## Tekst, QR-koder og farger

`Super + Ctrl + Print Screen` velger et område og gjenkjenner teksten i det med OCR til utklippstavlen. Det er dekket skikkelig i [Tekstuttrekking og diktering](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ gjør det samme trikset for QR-koder. Velg området med koden i, så går den avkodede verdien til utklippstavlen. Den leter bare etter QR-koder — tett skjerminnhold har ellers en tendens til å gi falske treff som strekkode. Verdt å vite: den avkodede verdien går til utklippstavlen og ingen andre steder. Den skrives ikke ut, den er ikke i varselet, og den er merket som sensitiv så den ikke blir liggende i [utklippstavlehistorikken](08-unified-clipboard-history.md). QR-koder bærer jevnlig på hemmeligheter — `otpauth://`-URI-en bak en oppsettskode for 2FA, for eksempel — og det vil du ikke ha i en logg. Å lime inn fungerer fortsatt helt fint.

`Super + Print Screen` (eller _Trigger > Capture > Color_) gjør markøren til en pipette. Klikk på hva som helst på skjermen, så havner fargen på utklippstavlen. Trykk hurtigtasten igjen for å trekke deg ut uten å velge.

## Transkoding før du deler

Et skjermopptak i 4K eller en rå HEIC fra telefonen din er ofte for stort til bare å sende. `Super + Ctrl + .` (eller _Trigger > Transcode_) fikser det. Den gir deg en filvelger med uskarpt søk over `~/Pictures` og `~/Videos`, og spør deretter om et format og en størrelse.

Bilder går til jpg eller png i høy, medium eller lav, som begrenser bredden til 3160, 2160 og 1080 piksler. Videoer går til mp4 eller en animert gif i 4k, 1080p eller 720p. Den konverterte filen skrives ved siden av originalen med oppløsningen i navnet — `demo-1080p.mp4` — og banen kopieres til utklippstavlen som en fil-URI, så du kan lime den rett inn i en app som tar imot filslipp.

Det fungerer fra terminalen også, hvis du allerede vet hva du vil ha: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Det finnes også `omarchy transcode ascii`, som gjør et bilde til ASCII-kunst — den er mest for [merkevarebygging](41-branding.md).

## Sende det et sted

Når du har filen, åpner `Super + Ctrl + S` Share-menyen og sender den til en annen enhet på nettverket ditt via LocalSend. Se [GUI-er](22-guis.md) for det.
