# Skjámyndir og upptaka

Allt sem þú getur gripið af skjánum hangir á Print Screen takkanum. Einn takki út af fyrir sig tekur mynd, og breytitakkarnir taka upptöku, lit eða textann innan svæðis. Ef lyklaborðið þitt er alls ekki með Print Screen takka tekur `Super + Ctrl + Alt + C` sömu skjámyndina, og `Super + Ctrl + C` opnar allt settið sem valmynd.

| Flýtilykill | Virkni |
| ------ | -------- |
| `Print Screen` | Skjámynd |
| `Super + Ctrl + Alt + C` | Skjámynd |
| `Alt + Print Screen` | Skjáupptaka (eða stöðva þá sem er í gangi) |
| `Super + Print Screen` | Litaveljari |
| `Super + Ctrl + Print Screen` | Draga texta úr svæði |
| `Super + Ctrl + C` | Tökuvalmynd |
| `Super + Ctrl + .` | Umkóða mynd eða myndband |

## Skjámyndir

Ýttu á `Print Screen` (eða `Super + Ctrl + Alt + C`) og Omasnap grípur virka skjáinn áður en yfirlögn þess birtist, svo ekkert færist undir þér á meðan þú miðar. Dragðu frjálst svæði, smelltu á glugga til að grípa hann, eða smelltu á autt svæði til að grípa allan skjáinn. Ýttu á `S` áður en þú teiknar til að grípa skrunsvæði. Breyttirðu um skoðun? Ýttu aftur á sama takkann til að loka Omasnap.

Eftir að þú velur svæði vistar Omasnap tökuna, afritar hana á klippiborðið og sýnir tilkynningu með smámynd hennar, eins og vistuð skjáupptaka gerir. Veldu Open til að skoða vistaða myndina í myndaskoðaranum þínum, eða Edit til að setja athugasemdir inn í hana.

Ritillinn fyrir athugasemdir getur teiknað örvar, línur, form, áherslumerkingar, númeraða merkimiða, texta og öruggar felumerkingar; klippt til eða klippt út hluta af myndinni; OCR-að texta hennar; og bætt við bakgrunni. Í ritlinum ýtirðu á `Enter` til að afrita og vista fullbúnu PNG myndina, `Ctrl + C` til að afrita hana án þess að vista, eða `Ctrl + S` til að vista hana án þess að afrita.

Vistaðar skjámyndir lenda í `~/Pictures/Screenshots` sjálfgefið, með nafni eins og `screenshot-2026-08-13_14-22-05-firefox.png`. Stilltu `OMASNAP_SCREENSHOT_DIR` til að nota aðra möppu — sjá [algengar spurningar](46-faq.md) um hvar á að setja umhverfisbreytur lotunnar. Omasnap býr möppuna til þegar það vistar fyrstu myndina. Stilltu `[output] autosave = false` í `~/.config/omasnap/omasnap.conf` til að slökkva á sjálfvirkri vistun; tökurnar eru þá aðeins afritaðar, og sýndar í forskoðun í 10 sekúndur sem þú getur haldið á skjánum með festihnappnum hennar eða `Ctrl + P`.

Í skelinni opnar `omarchy screenshot` sömu yfirlögnina, og þú getur valið upphafsham hennar: `omarchy capture screenshot region`, `windows`, `fullscreen`, eða `scroll`. Annað viðfang, `copy` eða `save`, sendir myndina beint á þann áfangastað. Til að breyta áður en þú gefur út skaltu nota `omarchy screenshot --editor=overlay` fyrir ritil á öllum skjánum eða `omarchy screenshot --editor=window` fyrir sérstakan glugga.

### Að stýra veljaranum með lyklaborðinu

Á meðan valið er uppi þarftu alls ekki að nota músina:

| Takki | Virkni |
| --- | -------- |
| `S` | Kveikja/slökkva á skrunsvæðisham |
| `Super + Arrow keys` | Færa á milli glugga í gluggaham |
| `Return` | Grípa auðkennda gluggann |
| `Ctrl + A` | Grípa allan virka skjáinn |
| `R` | Endurheimta síðasta svæði sem teiknað var í þessari lotu |
| `Esc` | Loka Omasnap |

Þessar bindingar eru aðeins til á meðan Omasnap er opið, svo þær geta ekki rekist á neitt í eigin stillingum þínum.

## Skjáupptaka

`Alt + Print Screen` opnar _Trigger > Capture > Screenrecord_, sem spyr hvað þú viljir hafa á hljóðrásinni: ekkert hljóð, skjáborðshljóð, skjáborð auk hljóðnema, eða skjáborð auk hljóðnema auk vefmyndavélar. Sá síðasti birtist aðeins ef þú ert raunverulega með myndavél tengda. Veldu einn og upptökuveljari Omarchy lætur þig draga svæði eða smella á glugga eða skjá.

Upptakan keyrir á gpu-screen-recorder, sem umkóðar á GPU á 60fps og fellur aftur á CPU ef það þarf. Niðurstaðan er MP4 í `~/Videos`, sem heitir `screenrecording-2026-08-13_14-22-05.mp4`. Stilltu `OMARCHY_SCREENRECORD_DIR` til að breyta því — en athugaðu að ólíkt skjámyndamöppunni verður þessi að vera til þegar, annars neitar upptakan að hefjast.

Á meðan þú tekur upp birtist lítill vísir á stikunni. Smelltu á hann til að stöðva. Þú getur líka stöðvað aftur með `Alt + Print Screen`, eða með _Stop Screenrecording_ færslunni undir _Trigger > Capture > Screenrecord_, sem birtist aðeins á meðan eitthvað er raunverulega í upptöku.

Þegar stöðvað er fer fram smá tiltekt áður en þú færð skrána í hendurnar: fyrsti ramminn er klipptur af, og ef það er hljóð er það staðlað í -14 LUFS með PipeWire tökuhvellinn alveg í upphafinu þaggaðan niður. Síðan birtist tilkynning með smámynd úr upptökunni. Smelltu á hana til að spila skrána í mpv.

### Yfirlögn vefmyndavélarinnar

Þegar þú tekur upp með vefmyndavél birtist myndavélin sem festur, tilklipptur andlitsgluggi í neðra hægra horninu á því sem þú ert að taka upp. Ef hún situr ofan á einhverju sem þú þarft skaltu breyta stærð hennar á flugi:

| Flýtilykill | Virkni |
| ------ | -------- |
| `Super + Alt + [` | Gera yfirlögn vefmyndavélarinnar minni |
| `Super + Alt + ]` | Gera yfirlögn vefmyndavélarinnar stærri |

Það eru þrjár stærðir — lítil, meðal og stór — og flýtilyklarnir stíga á milli þeirra. Meðal er sjálfgefið. Þær eru í hlutfalli við upptökuna, svo myndavélin tekur sama hluta rammans hvort sem þú ert að taka upp 1080p skjá eða 6K skjá. Og ef þú tókst upp svæði frekar en allan skjáinn festist yfirlögnin við horn þess svæðis frekar en skjásins, svo hún helst inni í myndinni.

Þú getur líka kallað á hana beint með `omarchy-capture-webcam-resize small`, eða `reset` til að fara aftur í meðal.

## Texti, QR kóðar og litir

`Super + Ctrl + Print Screen` velur svæði og OCR-ar það á klippiborðið. Það er fjallað almennilega um það í [Útdráttur texta og talinnsláttur](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ gerir sama bragðið fyrir QR kóða. Veldu svæðið með kóðanum í, og afkóðaða gildið fer á klippiborðið. Það leitar aðeins að QR kóðum — þétt skjáefni hefur það til að gefa falska jákvæða svörun sem strikamerki annars. Gott að vita: afkóðaða gildið fer á klippiborðið og hvergi annars staðar. Það er ekki prentað, það er ekki í tilkynningunni, og það er merkt viðkvæmt svo það festist ekki í [sögu klippiborðs](08-unified-clipboard-history.md). QR kóðar bera reglulega leyndarmál — `otpauth://` URI-ið á bak við uppsetningarkóða fyrir 2FA, til dæmis — og þú vilt ekki hafa það í annál. Að líma virkar samt alveg fínt.

`Super + Print Screen` (eða _Trigger > Capture > Color_) breytir bendlinum í dropateljara. Smelltu á hvað sem er á skjánum og liturinn lendir á klippiborðinu. Ýttu aftur á flýtilykilinn til að bakka út án þess að velja.

## Umkóðun áður en þú deilir

4K skjáupptaka eða hrátt HEIC af símanum þínum er oft of stórt til að bara senda. `Super + Ctrl + .` (eða _Trigger > Transcode_) lagar það. Það býður þér óljósan skráaveljara yfir `~/Pictures` og `~/Videos`, og spyr síðan um snið og stærð.

Myndir fara í jpg eða png í háu, meðal eða lágu, sem takmarka breiddina við 3160, 2160 og 1080 pixla. Myndbönd fara í mp4 eða hreyft gif í 4k, 1080p eða 720p. Umbreytta skráin er skrifuð við hliðina á frumritinu með upplausninni í nafninu — `demo-1080p.mp4` — og slóðin er afrituð á klippiborðið sem skráar-URI, svo þú getur límt hana beint inn í forrit sem tekur við skráum sem sleppt er.

Það virkar líka í skelinni, ef þú veist þegar hvað þú vilt: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Það er líka til `omarchy transcode ascii`, sem breytir mynd í ASCII list — sú er aðallega fyrir [vörumerkingu](41-branding.md).

## Að senda það eitthvert

Þegar þú ert kominn með skrána opnar `Super + Ctrl + S` Share valmyndina og sendir hana á annað tæki á netinu þínu í gegnum LocalSend. Sjá [GUIs](22-guis.md) um það.
