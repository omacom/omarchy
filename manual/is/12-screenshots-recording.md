# Skjámyndir og upptaka

Allt sem þú getur gripið af skjánum hangir á Print Screen-lyklinum. Einn lykill einn og sér tekur mynd, og breytislyklarnir taka upptöku, lit eða textann inni á svæði. Ef lyklaborðið þitt hefur engan Print Screen-lykil opnar `Super + Ctrl + C` sama safn sem valmynd.

| Flýtilykill | Virkni |
| ------ | -------- |
| `Print Screen` | Skjámynd |
| `Alt + Print Screen` | Skjáupptaka (eða stöðva þá sem er í gangi) |
| `Super + Print Screen` | Litaval |
| `Super + Ctrl + Print Screen` | Draga texta út úr svæði |
| `Super + Ctrl + C` | Fangvalmynd |
| `Super + Ctrl + .` | Umkóða mynd eða myndband |

## Skjámyndir

Ýttu á `Print Screen` og Omasnap fangar virka skjáinn áður en yfirlag hans birtist, svo ekkert færist undir þér á meðan þú miðar. Dragðu frjálst svæði, smelltu á glugga til að fanga hann eða smelltu á opið rými til að fanga allan skjáinn. Ýttu á `S` áður en þú teiknar til að fanga skrunsvæði. Breyttirðu um hug? Ýttu á `Print Screen` aftur til að hafna Omasnap.

Eftir að þú hefur valið svæði vistar Omasnap fangið, afritar það á klippiborðið og sýnir forskoðun í 10 sekúndur. Notaðu festihnapp forskoðunarinnar eða `Ctrl + P` til að halda henni á skjánum, eða veldu Breyta til að merkja við hana.

Merkingarritillinn getur teiknað örvar, línur, form, áherslur, númeraða merkimiða, texta og öruggar ritrýndar eyður; klippt til eða skorið út hluta myndarinnar; OCR-að texta hennar; og bætt við bakgrunni. Í ritlinum skaltu ýta á `Enter` til að afrita og vista fullkláraða PNG-skrána, `Ctrl + C` til að afrita hana án þess að vista, eða `Ctrl + S` til að vista hana án þess að afrita.

Vistaðar skjámyndir lenda sjálfgefið í `~/Pictures/Screenshots`, með nafni eins og `screenshot-2026-08-13_14-22-05-firefox.png`. Stilltu `OMASNAP_SCREENSHOT_DIR` til að nota aðra möppu — sjá [algengar spurningar](46-faq.md) um hvar á að setja umhverfisbreytur lotunnar. Omasnap býr til möppuna þegar það vistar fyrstu myndina. Stilltu `[output] autosave = false` í `~/.config/omasnap/omasnap.conf` til að slökkva á sjálfvirkri vistun.

Úr terminal opnar `omarchy screenshot` sama yfirlag, og þú getur valið byrjunarham þess: `omarchy capture screenshot region`, `windows`, `fullscreen` eða `scroll`. Annað viðfang, `copy` eða `save`, sleppir forskoðuninni og sendir myndina beint á þann áfangastað. Til að breyta fyrir úttak skaltu nota `omarchy screenshot --editor=overlay` fyrir ritil í fullum skjá eða `omarchy screenshot --editor=window` fyrir sérglugga.

### Að stjórna veljaranum með lyklaborðinu

Á meðan valið er uppi þarftu alls ekki að nota músina:

| Lykill | Virkni |
| --- | -------- |
| `S` | Víxla skrunsvæðaham |
| `Super + Arrow keys` | Færast á milli glugga í gluggaham |
| `Return` | Fanga auðkennda gluggann |
| `Ctrl + A` | Fanga allan virka skjáinn |
| `R` | Endurheimta síðasta svæði sem var teiknað í þessari lotu |
| `Esc` | Hafna Omasnap |

Þessar tengingar eru aðeins til á meðan Omasnap er opið, svo þær geta ekki rekist á neitt í þinni eigin stillingu.

## Skjáupptaka

`Alt + Print Screen` opnar _Kveikja > Fanga > Skjáupptaka_, sem spyr hvað þú vilt á hljóðrásinni: ekkert hljóð, skjáborðshljóð, skjáborð ásamt hljóðnema, eða skjáborð ásamt hljóðnema ásamt vefmyndavél. Sá síðasti birtist aðeins ef þú hefur í alvöru myndavél í sambandi. Veldu einn og upptökuveljari Omarchy lætur þig draga svæði eða smella á glugga eða skjá.

Upptakan keyrir á gpu-screen-recorder, sem kóðar á GPU á 60 fps og fellur aftur á CPU ef það þarf. Niðurstaðan er MP4-skrá í `~/Videos`, sem heitir `screenrecording-2026-08-13_14-22-05.mp4`. Stilltu `OMARCHY_SCREENRECORD_DIR` til að breyta því — en athugaðu að ólíkt skjámyndamöppunni verður þessi að vera til fyrir, annars neitar upptakan að byrja.

Á meðan þú tekur upp birtist lítill vísi í stikunni. Smelltu á hann til að stöðva. Þú getur líka stöðvað með `Alt + Print Screen` aftur, eða með færslunni _Stöðva skjáupptöku_ undir _Kveikja > Fanga > Skjáupptaka_, sem birtist aðeins á meðan eitthvað er í alvöru að taka upp.

Að stöðva gerir smá tiltekt áður en það afhendir þér skrána: fyrsti ramminn er klipptur burtu, og ef það er hljóð er það staðlað í -14 LUFS með PipeWire-fangsmellinum alveg í byrjun þaggaðum út. Síðan birtist tilkynning með smámynd úr upptökunni. Smelltu á hana til að spila skrána í mpv.

### Yfirlag vefmyndavélarinnar

Þegar þú tekur upp með vefmyndavél birtist myndavélin sem festur, tilklipptur andlitsgluggi í neðra hægra horni þess sem þú ert að taka upp. Ef hún situr ofan á einhverju sem þú þarft skaltu breyta stærð hennar á flugi:

| Flýtilykill | Virkni |
| ------ | -------- |
| `Super + Alt + [` | Minnka yfirlag vefmyndavélarinnar |
| `Super + Alt + ]` | Stækka yfirlag vefmyndavélarinnar |

Það eru þrjár stærðir — lítil, miðlungs og stór — og flýtilyklarnir stíga á milli þeirra. Miðlungs er sjálfgefið. Þær eru hlutfallslegar við upptökuna, svo myndavélin tekur sama hlutfall rammans hvort sem þú tekur upp 1080p-skjá eða 6K-skjá. Og ef þú tókst upp svæði frekar en allan skjá festist yfirlagið við horn þess svæðis frekar en skjásins, svo það helst inni í myndinni.

Þú getur líka kallað á það beint með `omarchy-capture-webcam-resize small`, eða `reset` til að fara aftur í miðlungs.

## Texti, QR-kóðar og litir

`Super + Ctrl + Print Screen` velur svæði og OCR-ar það á klippiborðið. Það er tekið fyrir almennilega í [Textaútdrætti og upplesningu](11-text-extraction-dictation.md).

_Kveikja > Fanga > QR-kóði_ gerir sama bragð fyrir QR-kóða. Veldu svæðið með kóðanum í og afkóðaða gildið fer á klippiborðið. Það leitar aðeins að QR-kóðum — þétt skjáinnihald á það til að villa um sig sem strikamerki annars. Það er þess virði að vita: afkóðaða gildið fer á klippiborðið og hvergi annars staðar. Það er ekki prentað, það er ekki í tilkynningunni, og það er merkt viðkvæmt svo það helst ekki í [klippiborðssögunni](08-unified-clipboard-history.md). QR-kóðar bera reglulega leyndarmál — `otpauth://`-URI-ið á bak við 2FA-uppsetningarkóða, til dæmis — og þú vilt ekki hafa það í annál. Líming virkar samt fínt.

`Super + Print Screen` (eða _Kveikja > Fanga > Litur_) breytir bendlinum í dropateljara. Smelltu á hvað sem er á skjánum og liturinn lendir á klippiborðinu. Ýttu á flýtilykilinn aftur til að bakka út án þess að velja.

## Umkóðun áður en þú deilir

4K-skjáupptaka eða hrá HEIC-skrá af símanum þínum er oft of stór til að senda bara svoleiðis. `Super + Ctrl + .` (eða _Kveikja > Umkóða_) lagar það. Það býður þér óljósan skráaveljara yfir `~/Pictures` og `~/Videos` og spyr síðan um snið og stærð.

Myndir fara í jpg eða png í háu, miðlungs eða lágu, sem takmarka breiddina við 3160, 2160 og 1080 punkta. Myndbönd fara í mp4 eða hreyfanlegt gif í 4k, 1080p eða 720p. Umbreytta skráin er skrifuð við hliðina á frumgerðinni með upplausninni í nafninu — `demo-1080p.mp4` — og slóðin er afrituð á klippiborðið sem skráa-URI, svo þú getur límt hana beint inn í forrit sem tekur við skráaköstum.

Það virkar líka úr terminal ef þú veist þegar hvað þú vilt: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Það er líka `omarchy transcode ascii`, sem breytir mynd í ASCII-list — það er aðallega fyrir [vörumerki](41-branding.md).

## Að senda það einhvert

Þegar þú hefur fengið skrána opnar `Super + Ctrl + S` deilivalmyndina og sendir hana í annað tæki á netinu þínu með LocalSend. Sjá [GUI-forrit](22-guis.md) um það.
