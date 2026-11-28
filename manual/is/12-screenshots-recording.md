# Skjámyndir og upptaka

Allt sem þú getur gripið af skjánum hangir á Print Screen takkanum. Einn takki einn og sér tekur mynd, og breytitakkarnir taka upp, taka lit eða textann innan svæðis. Ef lyklaborðið þitt hefur alls engan Print Screen takka tekur `Super + Ctrl + Alt + C` sömu skjámyndina, og `Super + Ctrl + C` opnar allt settið sem valmynd.

| Flýtilykill | Virkni |
| ------ | -------- |
| `Print Screen` | Skjámynd |
| `Super + Ctrl + Alt + C` | Skjámynd |
| `Alt + Print Screen` | Skjáupptaka (eða stöðva þá sem er í gangi) |
| `Super + Print Screen` | Litaveljari |
| `Super + Ctrl + Print Screen` | Draga texta út úr svæði |
| `Super + Ctrl + C` | Tökuvalmynd |
| `Super + Ctrl + .` | Umbreyta mynd eða myndbandi |

## Skjámyndir

Ýttu á `Print Screen` (eða `Super + Ctrl + Alt + C`) og Omasnap tekur skjáinn í fókus áður en yfirlögn þess birtist, svo ekkert færist undir þér á meðan þú miðar. Dragðu frjálst svæði, smelltu á glugga til að taka hann, eða smelltu á opið rými til að taka allan skjáinn. Ýttu á `S` áður en þú teiknar til að taka rúllandi svæði. Hættur við? Ýttu aftur á sama takkann til að loka Omasnap.

Eftir að þú velur svæði vistar Omasnap myndina, afritar hana á klemmuspjaldið og sýnir tilkynningu með smámynd hennar, eins og vistuð skjáupptaka gerir. Veldu Open til að skoða vistaðu myndina í myndaskoðaranum þínum, eða Edit til að skrifa athugasemdir á hana.

Athugasemdaritillinn getur teiknað örvar, línur, form, áherslur, númeraða merkimiða, texta og öruggar felur; klippt til eða klippt út hluta af myndinni; OCR-að texta hennar; og bætt við bakgrunni. Í ritlinum ýtir þú á `Enter` til að afrita og vista fullbúna PNG-myndina, `Ctrl + C` til að afrita hana án þess að vista, eða `Ctrl + S` til að vista hana án þess að afrita.

Vistaðar skjámyndir lenda sjálfgefið í `~/Pictures/Screenshots`, með nafni eins og `screenshot-2026-08-13_14-22-05-firefox.png`. Stilltu `OMASNAP_SCREENSHOT_DIR` til að nota aðra möppu — sjá [algengar spurningar](46-faq.md) um hvar á að setja umhverfisbreytur lotunnar. Omasnap býr möppuna til þegar það vistar fyrstu myndina. Stilltu `[output] autosave = false` í `~/.config/omasnap/omasnap.conf` til að slökkva á sjálfvirkri vistun; myndir eru þá aðeins afritaðar og sýndar í forskoðun í 7 sekúndur sem þú getur haldið á skjánum með festihnappinum hennar eða `Ctrl + P`.

Frá flugstöðinni opnar `omarchy screenshot` sömu yfirlögnina, og þú getur valið upphafsham hennar: `omarchy capture screenshot region`, `windows`, `fullscreen` eða `scroll`. Annað viðfang af gerðinni `copy` eða `save` sendir myndina beint á þann áfangastað. Til að breyta fyrir úttak notar þú `omarchy screenshot --editor=overlay` fyrir ritil á fullum skjá eða `omarchy screenshot --editor=window` fyrir sérstakan glugga.

### Að stýra veljaranum með lyklaborðinu

Á meðan valið er uppi þarftu alls ekki að nota músina:

| Takki | Virkni |
| --- | -------- |
| `S` | Skipta um ham fyrir rúllandi svæði |
| `Super + Arrow keys` | Fara á milli glugga í gluggaham |
| `Return` | Taka auðkennda gluggann |
| `Ctrl + A` | Taka allan skjáinn í fókus |
| `R` | Endurheimta síðasta svæðið sem teiknað var í þessari lotu |
| `Esc` | Loka Omasnap |

Þessar bindingar eru aðeins til á meðan Omasnap er opið, svo þær geta ekki rekist á við neitt í þinni eigin stillingu.

## Skjáupptaka

`Alt + Print Screen` opnar _Trigger > Capture > Screenrecord_, sem spyr hvað þú vilt hafa á hljóðrásinni: ekkert hljóð, hljóð úr tölvunni, hljóð úr tölvunni plús hljóðnema, eða hljóð úr tölvunni plús hljóðnema plús vefmyndavél. Sá síðasti birtist aðeins ef þú ert í raun með myndavél tengda. Veldu einn og upptökuveljari Omarchy lætur þig draga svæði eða smella á glugga eða skjá.

Upptakan keyrir á gpu-screen-recorder, sem kóðar á GPU á 60fps og grípur til CPU ef það þarf; á GPU-um sem það styður ekki, eins og þeim í Apple Silicon, tekur Omarchy þess í stað upp með wf-recorder. Útkoman er MP4 í `~/Videos`, sem heitir `screenrecording-2026-08-13_14-22-05.mp4`. Stilltu `OMARCHY_SCREENRECORD_DIR` til að breyta því — en athugaðu að ólíkt skjámyndamöppunni verður þessi að vera til þegar, annars neitar upptakan að hefjast.

Á meðan þú tekur upp birtist lítill vísir í stönginni. Smelltu á hann til að stöðva. Þú getur líka stöðvað með `Alt + Print Screen` aftur, eða með færslunni _Stop Screenrecording_ undir _Trigger > Capture > Screenrecord_, sem birtist aðeins á meðan eitthvað er í raun verið að taka upp.

Þegar stöðvað er er aðeins snyrt til áður en þú færð skrána í hendurnar: fyrsti ramminn er klipptur burt, og ef það er hljóð er það staðlað í -14 LUFS og PipeWire-tökusprungan alveg í byrjun þögguð út. Svo birtist tilkynning með smámynd úr upptökunni. Veldu _Open_ til að spila skrána í Omaview, eða _Cut_ til að klippa hana í Omacut.

### Yfirlögn vefmyndavélarinnar

Þegar þú tekur upp með vefmyndavél birtist myndavélin sem festur, klipptur andlitsmyndargluggi í neðra hægra horninu á því sem þú ert að taka upp. Ef hún situr ofan á einhverju sem þú þarft að sjá geturðu breytt stærð hennar á flugi:

| Flýtilykill | Virkni |
| ------ | -------- |
| `Super + Alt + [` | Minnka yfirlögn vefmyndavélarinnar |
| `Super + Alt + ]` | Stækka yfirlögn vefmyndavélarinnar |

Það eru þrjár stærðir — lítil, meðal og stór — og flýtilyklarnir þrepa á milli þeirra. Meðal er sjálfgefið. Þær eru í hlutfalli við upptökuna, svo myndavélin tekur sama hlutfall rammans hvort sem þú tekur upp 1080p skjá eða 6K skjá. Og ef þú tókst upp svæði frekar en heilan skjá festist yfirlögnin við horn þess svæðis frekar en skjásins, svo hún helst innan myndarinnar.

Þú getur líka kallað beint í það með `omarchy-capture-webcam-resize small`, eða `reset` til að fara aftur í meðal.

## Texti, QR-kóðar og litir

`Super + Ctrl + Print Screen` velur svæði og OCR-ar það á klemmuspjaldið. Því er lýst almennilega í [Útdráttur texta og talinnsláttur](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ gerir sama bragð fyrir QR-kóða. Veldu svæðið með kóðanum í, og afkóðaða gildið fer á klemmuspjaldið. Það leitar aðeins að QR-kóðum — þétt skjáefni á það til að gefa falskar jákvæðar niðurstöður sem strikamerki annars. Gott að vita: afkóðaða gildið fer á klemmuspjaldið og hvergi annars staðar. Það er ekki prentað, það er ekki í tilkynningunni, og það er merkt viðkvæmt svo það festist ekki í [sögu klemmuspjaldsins](08-unified-clipboard-history.md). QR-kóðar bera reglulega leyndarmál — `otpauth://` URI-ið á bak við 2FA-uppsetningarkóða, svo dæmi sé tekið — og þú vilt ekki hafa það í annál. Að líma virkar samt fínt.

`Super + Print Screen` (eða _Trigger > Capture > Color_) breytir bendlinum í dropateljara. Smelltu á hvað sem er á skjánum og liturinn lendir á klemmuspjaldinu. Ýttu aftur á flýtilykilinn til að bakka út án þess að velja.

## Umbreyting áður en þú deilir

4K skjáupptaka eða hrátt HEIC af símanum þínum er oft of stórt til að bara senda. `Super + Ctrl + .` (eða _Trigger > Transcode_) lagar það. Það býður þér óljósan skráaveljara yfir `~/Pictures` og `~/Videos`, og spyr svo um snið og stærð.

Myndir fara í jpg eða png á háu, meðal eða lágu, sem takmarka breiddina við 3160, 2160 og 1080 pixla. Myndbönd fara í mp4 eða hreyft gif á 4k, 1080p eða 720p. Umbreytta skráin er skrifuð við hliðina á frumritinu með upplausninni í nafninu — `demo-1080p.mp4` — og slóðin er afrituð á klemmuspjaldið sem skráar-URI, svo þú getur límt hana beint inn í forrit sem tekur við skráum sem sleppt er.

Það virkar líka frá flugstöðinni, ef þú veist þegar hvað þú vilt: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Það er líka `omarchy transcode ascii`, sem breytir mynd í ASCII-list — sú er aðallega fyrir [vörumerking](41-branding.md).

## Að senda það eitthvert

Þegar þú ert kominn með skrána opnar `Super + Ctrl + S` Share-valmyndina og sendir hana á annað tæki á netinu þínu í gegnum LocalSend. Sjá [GUIs](22-guis.md) um það.
