# Skærmbilleder & optagelse

Alt, hvad du kan hente fra skærmen, hænger på Print Screen-tasten. Én tast for sig tager et billede, og modifikatorerne tager en optagelse, en farve eller teksten inde i et område. Hvis dit tastatur slet ikke har en Print Screen-tast, åbner `Super + Ctrl + C` det samme sæt som en menu.

| Genvejstast | Funktion |
| ------ | -------- |
| `Print Screen` | Skærmbillede |
| `Alt + Print Screen` | Skærmoptagelse (eller stop den, der kører) |
| `Super + Print Screen` | Farvevælger |
| `Super + Ctrl + Print Screen` | Udtræk tekst fra et område |
| `Super + Ctrl + C` | Optagelsesmenu |
| `Super + Ctrl + .` | Omkod et billede eller en video |

## Skærmbilleder

Tryk på `Print Screen`, og Omasnap optager den fokuserede skærm, før dens overlejring vises, så intet flytter sig under dig, mens du sigter. Træk et frit område, klik på et vindue for at optage det, eller klik på åben plads for at optage hele skærmen. Tryk på `S`, før du tegner, for at optage et rullende område. Har du ombestemt dig? Tryk på `Print Screen` igen for at afvise Omasnap.

Når du har valgt et område, gemmer Omasnap optagelsen, kopierer den til udklipsholderen og viser en forhåndsvisning i 10 sekunder. Brug forhåndsvisningens fastgørelsesknap eller `Ctrl + P` for at beholde den på skærmen, eller vælg Rediger for at annotere den.

Annotationseditoren kan tegne pile, linjer, former, fremhævninger, nummererede markører, tekst og sikre sløringer; beskære eller skære en del af billedet ud; OCR'e dens tekst; og tilføje en baggrund. I editoren skal du trykke på `Enter` for at kopiere og gemme den færdige PNG, `Ctrl + C` for at kopiere den uden at gemme eller `Ctrl + S` for at gemme den uden at kopiere.

Gemte skærmbilleder lander som standard i `~/Pictures/Screenshots` med et navn som `screenshot-2026-08-13_14-22-05-firefox.png`. Sæt `OMASNAP_SCREENSHOT_DIR` for at bruge en anden mappe — se [FAQ'en](46-faq.md) for, hvor du skal placere sessionsmiljøvariabler. Omasnap opretter mappen, når den gemmer det første billede. Sæt `[output] autosave = false` i `~/.config/omasnap/omasnap.conf` for at deaktivere automatisk lagring.

Fra terminalen åbner `omarchy screenshot` den samme overlejring, og du kan vælge dens starttilstand: `omarchy capture screenshot region`, `windows`, `fullscreen` eller `scroll`. Et andet argument `copy` eller `save` springer forhåndsvisningen over og sender billedet direkte til den destination. For at redigere før output skal du bruge `omarchy screenshot --editor=overlay` til en editor i fuld skærm eller `omarchy screenshot --editor=window` til et separat vindue.

### Styring af vælgeren fra tastaturet

Mens markeringen er oppe, behøver du slet ikke at bruge musen:

| Tast | Funktion |
| --- | -------- |
| `S` | Slå tilstanden for rullende område til/fra |
| `Super + Arrow keys` | Bevæg dig mellem vinduer i vinduestilstand |
| `Return` | Optag det fremhævede vindue |
| `Ctrl + A` | Optag hele den fokuserede skærm |
| `R` | Gendan det sidst tegnede område i denne session |
| `Esc` | Afvis Omasnap |

Disse bindinger findes kun, mens Omasnap er åben, så de kan ikke kollidere med noget i din egen konfiguration.

## Skærmoptagelse

`Alt + Print Screen` åbner _Udløs > Optag > Skærmoptagelse_, som spørger, hvad du ønsker på lydsporet: ingen lyd, skrivebordslyd, skrivebord plus mikrofon eller skrivebord plus mikrofon plus webcam. Den sidste vises kun, hvis du rent faktisk har et kamera tilsluttet. Vælg én, og Omarchys optagelsesvælger lader dig trække et område eller klikke på et vindue eller en skærm.

Optagelse kører på gpu-screen-recorder, som koder på GPU'en ved 60 fps og falder tilbage til CPU'en, hvis den er nødt til det. Resultatet er en MP4 i `~/Videos` med navnet `screenrecording-2026-08-13_14-22-05.mp4`. Sæt `OMARCHY_SCREENRECORD_DIR` for at ændre det — men bemærk, at i modsætning til skærmbilledmappen skal denne findes i forvejen, ellers nægter optagelsen at starte.

Mens du optager, vises en lille indikator på linjen. Klik på den for at stoppe. Du kan også stoppe med `Alt + Print Screen` igen eller med posten _Stop skærmoptagelse_ under _Udløs > Optag > Skærmoptagelse_, som kun vises, mens noget rent faktisk optager.

At stoppe rydder lidt op, før den giver dig filen: den første ramme trimmes, og hvis der er lyd, normaliseres den til -14 LUFS, mens PipeWire-optagelsespoppet i selve starten dæmpes. Derefter vises en notifikation med et miniaturebillede fra optagelsen. Klik på den for at afspille filen i mpv.

### Webcam-overlægningen

Når du optager med et webcam, vises kameraet som et fastgjort, beskåret portrætvindue i nederste højre hjørne af det, du optager. Hvis det sidder oven på noget, du har brug for, kan du tilpasse det i farten:

| Genvejstast | Funktion |
| ------ | -------- |
| `Super + Alt + [` | Gør webcam-overlægningen mindre |
| `Super + Alt + ]` | Gør webcam-overlægningen større |

Der er tre størrelser — lille, mellem og stor — og genvejstasterne træder imellem dem. Mellem er standarden. De er proportionale med optagelsen, så kameraet fylder den samme andel af rammen, uanset om du optager en 1080p-skærm eller en 6K-skærm. Og hvis du optog et område snarere end en hel skærm, forankres overlejringen ved det områdes hjørne snarere end skærmens, så den bliver inde i billedet.

Du kan også kalde den direkte med `omarchy-capture-webcam-resize small` eller `reset` for at gå tilbage til mellem.

## Tekst, QR-koder og farver

`Super + Ctrl + Print Screen` vælger et område og OCR'er det til udklipsholderen. Det er beskrevet ordentligt i [Tekstudtræk & diktering](11-text-extraction-dictation.md).

_Udløs > Optag > QR-kode_ gør det samme trick for QR-koder. Vælg området med koden i det, og den afkodede værdi går til udklipsholderen. Den leder kun efter QR-koder — tæt skærmindhold har en vane med ellers at give falsk positiv som en stregkode. Værd at vide: den afkodede værdi går til udklipsholderen og ingen andre steder. Den udskrives ikke, den er ikke i notifikationen, og den er markeret som følsom, så den ikke bliver hængende i [udklipshistorikken](08-unified-clipboard-history.md). QR-koder bærer rutinemæssigt hemmeligheder — f.eks. `otpauth://`-URI'en bag en 2FA-opsætningskode — og du vil ikke have det i en log. Indsætning virker stadig fint.

`Super + Print Screen` (eller _Udløs > Optag > Farve_) gør markøren til en pipette. Klik på hvad som helst på skærmen, og farven lander på udklipsholderen. Tryk på genvejstasten igen for at bakke ud uden at vælge.

## Omkodning, før du deler

En 4K-skærmoptagelse eller en rå HEIC fra din telefon er ofte for stor til bare at sende. `Super + Ctrl + .` (eller _Udløs > Omkod_) fikser det. Den tilbyder dig en uklar filvælger over `~/Pictures` og `~/Videos` og spørger derefter om et format og en størrelse.

Billeder går til jpg eller png i høj, mellem eller lav, som begrænser bredden til 3160, 2160 og 1080 pixel. Videoer går til mp4 eller en animeret gif i 4k, 1080p eller 720p. Den konverterede fil skrives ved siden af originalen med opløsningen i navnet — `demo-1080p.mp4` — og stien kopieres til udklipsholderen som en fil-URI, så du kan indsætte den direkte i en app, der tager filslip.

Den virker også fra terminalen, hvis du allerede ved, hvad du vil: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Der er også `omarchy transcode ascii`, som gør et billede til ASCII-kunst — den er mest til [branding](41-branding.md).

## At sende det et sted hen

Når du har filen, åbner `Super + Ctrl + S` menuen Del og sender den til en anden enhed på dit netværk via LocalSend. Se [GUI'er](22-guis.md) for det.
