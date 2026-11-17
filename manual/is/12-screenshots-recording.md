# Skjámyndir og upptaka

Allt sem þú getur gripið af skjánum hangir á Print Screen-lyklinum. Einn lykill út af fyrir sig tekur mynd og breytilyklarnir taka upptöku, lit eða textann innan svæðis. Ef lyklaborðið þitt er alls ekki með Print Screen-lykil tekur `Super + Ctrl + Alt + C` sömu skjámynd og `Super + Ctrl + C` opnar allt settið sem valmynd.

| Flýtilykill | Virkni |
| ------ | -------- |
| `Print Screen` | Skjámynd |
| `Super + Ctrl + Alt + C` | Skjámynd |
| `Alt + Print Screen` | Skjáupptaka (eða stöðva þá sem er í gangi) |
| `Super + Print Screen` | Litaveljari |
| `Super + Ctrl + Print Screen` | Draga texta út úr svæði |
| `Super + Ctrl + C` | Tökuvalmynd |
| `Super + Ctrl + .` | Umkóða mynd eða myndband |

## Skjámyndir

Ýttu á `Print Screen` (eða `Super + Ctrl + Alt + C`) og Omasnap tekur skjáinn sem er í fókus áður en yfirlögn þess birtist, svo ekkert færist undir þér á meðan þú miðar. Dragðu frjálst svæði, smelltu á glugga til að taka hann, eða smelltu á autt svæði til að taka allan skjáinn. Ýttu á `S` áður en þú teiknar til að taka skrunanlegt svæði. Hætt við? Ýttu aftur á sama lykil til að loka Omasnap.

Eftir að þú velur svæði vistar Omasnap myndina, afritar hana á klippiborðið og sýnir tilkynningu með smámynd hennar, eins og vistuð skjáupptaka gerir. Veldu Open til að skoða vistaða myndina í myndaskoðaranum þínum eða Edit til að setja athugasemdir á hana.

Athugasemdarithillinn getur teiknað örvar, línur, form, áherslumerkingar, númeraða merkimiða, texta og öruggar felur; klippt til eða skorið út hluta myndarinnar; OCR-að texta hennar; og bætt við bakgrunni. Í ritlinum ýtir þú á `Enter` til að afrita og vista fullbúnu PNG-myndina, `Ctrl + C` til að afrita hana án þess að vista, eða `Ctrl + S` til að vista hana án þess að afrita.

Vistaðar skjámyndir lenda sjálfgefið í `~/Pictures/Screenshots`, með nafni á borð við `screenshot-2026-08-13_14-22-05-firefox.png`. Stilltu `OMASNAP_SCREENSHOT_DIR` til að nota aðra möppu — sjá [algengu spurningarnar](46-faq.md) um hvar eigi að setja umhverfisbreytur lotu. Omasnap býr möppuna til þegar það vistar fyrstu myndina. Stilltu `[output] autosave = false` í `~/.config/omasnap/omasnap.conf` til að slökkva á sjálfvirkri vistun; myndirnar eru þá aðeins afritaðar og sýndar í forskoðun í 10 sekúndur sem þú getur haldið á skjánum með festihnappnum hennar eða `Ctrl + P`.

Úr skipanalínunni opnar `omarchy screenshot` sömu yfirlögnina og þú getur valið upphafsham hennar: `omarchy capture screenshot region`, `windows`, `fullscreen` eða `scroll`. Annað viðfang, `copy` eða `save`, sendir myndina beint á þann áfangastað. Til að breyta fyrir úttak skaltu nota `omarchy screenshot --editor=overlay` fyrir ritil á öllum skjánum eða `omarchy screenshot --editor=window` fyrir sérstakan glugga.

### Að stýra veljaranum með lyklaborðinu

Á meðan valið er uppi þarftu alls ekki að nota músina:

| Lykill | Virkni |
| --- | -------- |
| `S` | Kveikja/slökkva á ham fyrir skrunanlegt svæði |
| `Super + Arrow keys` | Fara á milli glugga í gluggaham |
| `Return` | Taka gluggann sem er auðkenndur |
| `Ctrl + A` | Taka allan skjáinn sem er í fókus |
| `R` | Endurheimta síðasta svæði sem teiknað var í þessari lotu |
| `Esc` | Loka Omasnap |

Þessar tengingar eru aðeins til á meðan Omasnap er opið, svo þær geta ekki rekist á neitt í þinni eigin stillingu.

## Skjáupptaka

`Alt + Print Screen` opnar _Trigger > Capture > Screenrecord_, sem spyr hvað þú viljir hafa á hljóðrásinni: ekkert hljóð, hljóð af skjáborði, skjáborð plús hljóðnemi, eða skjáborð plús hljóðnemi plús vefmyndavél. Sá síðasti birtist aðeins ef þú ert raunverulega með myndavél tengda. Veldu einn og upptökuveljari Omarchy leyfir þér að draga svæði eða smella á glugga eða skjá.

Upptakan keyrir á gpu-screen-recorder, sem kóðar á GPU á 60fps og grípur til CPU ef það verður að gera það. Útkoman er MP4 í `~/Videos`, með nafninu `screenrecording-2026-08-13_14-22-05.mp4`. Stilltu `OMARCHY_SCREENRECORD_DIR` til að breyta því — en athugaðu að ólíkt skjámyndamöppunni verður þessi að vera til fyrir, annars neitar upptakan að hefjast.

Á meðan þú tekur upp birtist lítill vísir á stikunni. Smelltu á hann til að stöðva. Þú getur líka stöðvað aftur með `Alt + Print Screen`, eða með færslunni _Stop Screenrecording_ undir _Trigger > Capture > Screenrecord_, sem birtist aðeins á meðan eitthvað er raunverulega í upptöku.

Þegar stöðvað er er aðeins snyrt til áður en þú færð skrána í hendurnar: fyrsti ramminn er skorinn af og ef hljóð er til staðar er það jafnað í -14 LUFS þar sem smellurinn úr PipeWire-tökunni alveg í byrjun er þaggaður niður. Síðan birtist tilkynning með smámynd úr upptökunni. Smelltu á hana til að spila skrána í Omaview.

### Yfirlögn vefmyndavélarinnar

Þegar þú tekur upp með vefmyndavél birtist myndavélin sem festur, klipptur andlitsgluggi í neðra hægra horni þess sem þú ert að taka upp. Ef hún situr ofan á einhverju sem þú þarft skaltu breyta stærð hennar á flugi:

| Flýtilykill | Virkni |
| ------ | -------- |
| `Super + Alt + [` | Gera yfirlögn vefmyndavélarinnar minni |
| `Super + Alt + ]` | Gera yfirlögn vefmyndavélarinnar stærri |

Til eru þrjár stærðir — lítil, meðal og stór — og flýtilyklarnir stíga á milli þeirra. Meðal er sjálfgefin. Þær eru í hlutfalli við upptökuna, svo myndavélin tekur sama hlutfall rammans hvort sem þú tekur upp 1080p-skjá eða 6K-skjá. Og ef þú tókst upp svæði frekar en allan skjáinn festist yfirlögnin við horn þess svæðis frekar en skjásins, svo hún helst innan myndarinnar.

Þú getur líka kallað beint í það með `omarchy-capture-webcam-resize small`, eða `reset` til að fara aftur í meðalstærð.

## Texti, QR-kóðar og litir

`Super + Ctrl + Print Screen` velur svæði og OCR-ar það á klippiborðið. Það er fjallað almennilega um það í [Útdráttur texta og talinnsláttur](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ gerir sama bragðið fyrir QR-kóða. Veldu svæðið með kóðanum í og afkóðaða gildið fer á klippiborðið. Það leitar aðeins að QR-kóðum — þétt skjáefni hefur það til að gefa falskar jákvæðar niðurstöður sem strikamerki annars. Gott að vita: afkóðaða gildið fer á klippiborðið og hvergi annars staðar. Það er ekki prentað út, það er ekki í tilkynningunni og það er merkt sem viðkvæmt svo það hangi ekki eftir í [sögu klippiborðs](08-unified-clipboard-history.md). QR-kóðar bera jafnan leyndarmál — `otpauth://`-URI-ið á bak við uppsetningarkóða fyrir 2FA, til dæmis — og þú vilt ekki hafa það í annál. Að líma virkar samt alveg fínt.

`Super + Print Screen` (eða _Trigger > Capture > Color_) breytir bendlinum í dropateljara. Smelltu á hvað sem er á skjánum og liturinn lendir á klippiborðinu. Ýttu aftur á flýtilykilinn til að hætta við án þess að velja.

## Umkóðun áður en þú deilir

4K-skjáupptaka eða hrátt HEIC úr símanum þínum er oft of stórt til að senda bara svona. `Super + Ctrl + .` (eða _Trigger > Transcode_) lagar það. Það býður þér óljósan skráaveljara yfir `~/Pictures` og `~/Videos` og spyr síðan um snið og stærð.

Myndir fara í jpg eða png í háu, meðal eða lágu, sem takmarka breiddina við 3160, 2160 og 1080 díla. Myndbönd fara í mp4 eða hreyft gif í 4k, 1080p eða 720p. Umbreytta skráin er skrifuð við hlið frumritsins með upplausninni í nafninu — `demo-1080p.mp4` — og slóðin er afrituð á klippiborðið sem skráar-URI, svo þú getir límt hana beint inn í forrit sem tekur við skrám sem sleppt er.

Það virkar líka úr skipanalínunni ef þú veist nú þegar hvað þú vilt: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Til er líka `omarchy transcode ascii`, sem breytir mynd í ASCII-list — sú er aðallega fyrir [vörumerki](41-branding.md).

## Að senda það eitthvert

Þegar þú ert kominn með skrána opnar `Super + Ctrl + S` Share-valmyndina og sendir hana á annað tæki á netinu þínu í gegnum LocalSend. Sjá [grafísk viðmót](22-guis.md) um það.
