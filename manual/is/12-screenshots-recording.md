# Skjámyndir og upptaka

Allt sem þú getur gripið af skjánum hangir á Print Screen takkanum. Einn takki út af fyrir sig tekur mynd, og breytitakkarnir taka upptöku, lit eða textann innan svæðis. Ef lyklaborðið þitt er alls ekki með Print Screen takka tekur `Super + Ctrl + Alt + C` sömu skjámyndina, og `Super + Ctrl + C` opnar allt settið sem valmynd.

| Hotkey | Function |
| ------ | -------- |
| `Print Screen` | Skjámynd |
| `Super + Ctrl + Alt + C` | Skjámynd |
| `Alt + Print Screen` | Skjáupptaka (eða stöðva þá sem er í gangi) |
| `Super + Print Screen` | Litaval |
| `Super + Ctrl + Print Screen` | Draga texta út úr svæði |
| `Super + Ctrl + C` | Tökuvalmynd |
| `Super + Ctrl + .` | Umkóða mynd eða myndband |

## Skjámyndir

Ýttu á `Print Screen` (eða `Super + Ctrl + Alt + C`) og Omasnap tekur skjámynd af virka skjánum áður en yfirlagið hans birtist, svo ekkert hreyfist undir þér á meðan þú miðar. Dragðu frjálst svæði, smelltu á glugga til að taka mynd af honum, eða smelltu á opið rými til að taka mynd af öllum skjánum. Ýttu á `S` áður en þú teiknar til að taka mynd af skrunanlegu svæði. Breyttirðu um skoðun? Ýttu aftur á sama takkann til að loka Omasnap.

Eftir að þú velur svæði vistar Omasnap myndina, afritar hana á klippiborðið og sýnir forskoðun í 10 sekúndur. Notaðu festihnapp forskoðunarinnar eða `Ctrl + P` til að halda henni á skjánum, eða veldu Edit til að skrifa á hana.

Athugasemdarithöfundurinn getur teiknað örvar, línur, form og áherslur, bætt við númeruðum merkjum, texta og öruggum afmáunum; skorið af eða skorið út hluta myndarinnar; lesið texta hennar með OCR; og bætt við bakgrunni. Í ritlinum ýtirðu á `Enter` til að afrita og vista fullunna PNG mynd, `Ctrl + C` til að afrita hana án þess að vista, eða `Ctrl + S` til að vista hana án þess að afrita.

Vistaðar skjámyndir lenda sjálfgefið í `~/Pictures/Screenshots`, með nafni eins og `screenshot-2026-08-13_14-22-05-firefox.png`. Stilltu `OMASNAP_SCREENSHOT_DIR` til að nota aðra möppu — sjá [algengar spurningar](46-faq.md) um hvar eigi að setja umhverfisbreytur lotunnar. Omasnap býr möppuna til þegar hann vistar fyrstu myndina. Stilltu `[output] autosave = false` í `~/.config/omasnap/omasnap.conf` til að slökkva á sjálfvirkri vistun.

Í skipanalínunni opnar `omarchy screenshot` sama yfirlagið, og þú getur valið upphafsham hans: `omarchy capture screenshot region`, `windows`, `fullscreen` eða `scroll`. Annað viðfang, `copy` eða `save`, sleppir forskoðuninni og sendir myndina beint á þann áfangastað. Til að breyta fyrir úttak skaltu nota `omarchy screenshot --editor=overlay` fyrir ritil á öllum skjánum eða `omarchy screenshot --editor=window` fyrir sérstakan glugga.

### Að stýra valinu með lyklaborðinu

Á meðan valið er uppi þarftu alls ekki að nota músina:

| Key | Function |
| --- | -------- |
| `S` | Kveikja eða slökkva á ham fyrir skrunanlegt svæði |
| `Super + Arrow keys` | Fara á milli glugga í Window ham |
| `Return` | Taka mynd af auðkennda glugganum |
| `Ctrl + A` | Taka mynd af öllum virka skjánum |
| `R` | Endurheimta síðasta svæðið sem teiknað var í þessari lotu |
| `Esc` | Loka Omasnap |

Þessar bindingar eru aðeins til á meðan Omasnap er opið, svo þær geta ekki rekist á neitt í þinni eigin stillingu.

## Skjáupptaka

`Alt + Print Screen` opnar _Trigger > Capture > Screenrecord_, sem spyr hvað þú viljir hafa á hljóðrásinni: ekkert hljóð, hljóð af skjáborði, hljóð af skjáborði ásamt hljóðnema, eða hljóð af skjáborði ásamt hljóðnema og vefmyndavél. Sá síðasti birtist aðeins ef þú ert í raun með myndavél tengda. Veldu einn og upptökuval Omarchy lætur þig draga svæði eða smella á glugga eða skjá.

Upptakan keyrir á gpu-screen-recorder, sem kóðar á GPU á 60fps og fellur aftur á CPU ef hann verður að gera það. Útkoman er MP4 í `~/Videos`, með nafnið `screenrecording-2026-08-13_14-22-05.mp4`. Stilltu `OMARCHY_SCREENRECORD_DIR` til að breyta því — en athugaðu að ólíkt skjámyndamöppunni verður þessi að vera til þegar, annars neitar upptakan að hefjast.

Á meðan þú tekur upp birtist lítill vísir á stikunni. Smelltu á hann til að stöðva. Þú getur líka stöðvað aftur með `Alt + Print Screen`, eða með færslunni _Stop Screenrecording_ undir _Trigger > Capture > Screenrecord_, sem birtist aðeins á meðan eitthvað er í raun í upptöku.

Þegar stöðvað er er aðeins snyrt til áður en þú færð skrána í hendurnar: fyrsti ramminn er klipptur burt, og ef hljóð er til staðar er það staðlað í -14 LUFS og PipeWire smellurinn í byrjun upptökunnar er þaggaður niður. Síðan birtist tilkynning með smámynd úr upptökunni. Smelltu á hana til að spila skrána í mpv.

### Yfirlag vefmyndavélarinnar

Þegar þú tekur upp með vefmyndavél birtist myndavélin sem festur, afskorinn andlitsgluggi í neðra hægra horni þess sem þú ert að taka upp. Ef hún situr ofan á einhverju sem þú þarft skaltu breyta stærð hennar á flugi:

| Hotkey | Function |
| ------ | -------- |
| `Super + Alt + [` | Gera yfirlag vefmyndavélarinnar minna |
| `Super + Alt + ]` | Gera yfirlag vefmyndavélarinnar stærra |

Stærðirnar eru þrjár — lítil, meðalstór og stór — og flýtilyklarnir færa þig á milli þeirra. Meðalstór er sjálfgefin. Þær eru í hlutfalli við upptökuna, svo myndavélin tekur sama hluta rammans hvort sem þú tekur upp 1080p skjá eða 6K skjá. Og ef þú tókst upp svæði frekar en heilan skjá festist yfirlagið við horn þess svæðis frekar en skjásins, svo það helst inni í myndinni.

Þú getur líka kallað beint í það með `omarchy-capture-webcam-resize small`, eða `reset` til að fara aftur í meðalstærð.

## Texti, QR kóðar og litir

`Super + Ctrl + Print Screen` velur svæði og les texta þess með OCR yfir á klippiborðið. Fjallað er almennilega um það í [Textaútdráttur og diktun](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ gerir sama bragðið fyrir QR kóða. Veldu svæðið með kóðanum á, og afkóðaða gildið fer á klippiborðið. Það leitar aðeins að QR kóðum — þétt skjáefni hefur það til að gefa falskar jákvæðar niðurstöður sem strikamerki annars. Gott að vita: afkóðaða gildið fer á klippiborðið og hvergi annars staðar. Það er ekki prentað, það er ekki í tilkynningunni, og það er merkt viðkvæmt svo það festist ekki í [sögu klippiborðsins](08-unified-clipboard-history.md). QR kóðar bera reglulega leyndarmál — `otpauth://` URI-ið á bak við uppsetningarkóða fyrir 2FA, til dæmis — og þú vilt ekki hafa það í annál. Að líma virkar samt alveg fínt.

`Super + Print Screen` (eða _Trigger > Capture > Color_) breytir bendlinum í pipettu. Smelltu á hvað sem er á skjánum og liturinn lendir á klippiborðinu. Ýttu aftur á flýtilykilinn til að bakka út án þess að velja.

## Umkóðun áður en þú deilir

4K skjáupptaka eða hrátt HEIC af símanum þínum er oft of stórt til að bara senda. `Super + Ctrl + .` (eða _Trigger > Transcode_) lagar það. Það býður þér upp á óskýrt skráaval yfir `~/Pictures` og `~/Videos`, og spyr síðan um snið og stærð.

Myndir fara í jpg eða png í háu, meðal eða lágu, sem takmarka breiddina við 3160, 2160 og 1080 pixla. Myndbönd fara í mp4 eða hreyft gif í 4k, 1080p eða 720p. Umbreytta skráin er skrifuð við hlið frumritsins með upplausninni í nafninu — `demo-1080p.mp4` — og slóðin er afrituð á klippiborðið sem skráar-URI, svo þú getur sleppt henni beint í forrit sem tekur við skráum sem sleppt er.

Það virkar líka í skipanalínunni, ef þú veist þegar hvað þú vilt: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Það er líka til `omarchy transcode ascii`, sem breytir mynd í ASCII list — sú er aðallega fyrir [vörumerkingu](41-branding.md).

## Að senda það eitthvað

Þegar þú ert kominn með skrána opnar `Super + Ctrl + S` Share valmyndina og sendir hana á annað tæki á netinu þínu í gegnum LocalSend. Sjá [GUIs](22-guis.md) um það.
