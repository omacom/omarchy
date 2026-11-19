# GUIs

## Files

Files (Nautilus) er grafíski skráastjórinn. `Super + Shift + F` opnar hann og `Super + Shift + Alt + F` opnar hann í möppunni sem útstöðin þín er í, sem sparar mikið af smellum. `Ctrl + L` lætur þig slá inn slóð og að ýta á `Space` á einhverri skrá gefur þér fljótlega forskoðun án þess að opna neitt.

Stingdu USB-kubbi eða SD-korti í samband og það er tengt sjálfkrafa, svo það birtist bara í hliðarstikunni. Fyrir eitthvað flóknara — að forsníða drif, athuga SMART-heilsu, búa til disksneiðar — skaltu ræsa _Disks_ úr forritaræsinum (`Super + Space`).

Tvísmellir fylgja skynsamlegum sjálfgefnum stillingum: myndir, myndbönd og tónlist opnast í Omaview, PDF-skjöl í Document Viewer, Markdown í Omawrite og venjulegur texti í ritlinum sem valinn er undir _Setup > Default > Editor_.

## Disktree

Þegar drifið fyllist og þú hefur ekki hugmynd um hvað er að éta það skaltu ræsa [Disktree](https://github.com/tobi/disktree) úr forritaræsinum (`Super + Space`). Það sýnir grafískt trékort af heimamöppunni þinni. Stærri reitir taka meira pláss; farðu inn í möppur með lyklaborðinu eða músinni, merktu það sem á að fara og farðu yfir valið þitt áður en þú fjarlægir nokkuð. Keyrðu `disktree --disk` til að skanna allan diskinn.

## Obsidian

[Obsidian](https://obsidian.md/) er ókeypis og mjög útvíkkanlegt glósuforrit sem notar einfaldar Markdown-skrár til geymslu.

Obsidian er ókeypis í öllum tilgangi, þar á meðal til einkanota, viðskiptanota og nota í óhagnaðardrifnum tilgangi.

Obsidian býður einnig upp á [greidda viðbót fyrir samstillingu](https://obsidian.md/sync) við farsímaforrit á iOS og Android. (https://obsidian.md/pricing).

Þú ræsir Obsidian með `Super + Shift + O`. Til að nota samstillingu þema verður þú að velja `Omarchy`-þemað í stillingunum.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) er eigið, dauðeinfalt Markdown-ritforrit Omarchy. Ekkert vault, engar viðbætur, bara þú og orðin.

Þú ræsir Omawrite með `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) er einfalt myndvinnslutól sem er frábært til að klippa til, breyta stærð og gera aðrar einfaldar breytingar. Búist bara ekki við valkosti við Photoshop. En það er samt með Magic Wand og lög!

Þú ræsir Pinta í gegnum forritaræsinn (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) er þemaforrit sem getur dregið liti úr bakgrunnsmynd og breytt þeim í heildstætt, samræmt þema. Það er auðveldasta leiðin til að [búa til þitt eigið þema](43-making-your-own-theme.md).

Þú ræsir Aether í gegnum forritaræsinn (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) lætur þig senda skrár til annarra tækja á sama neti sem keyra forritið, eins og AirDrop frá Apple. Það virkar þó á mörgum kerfum, svo þú getur sent skrár til og frá Windows, macOS, Android, iOS og auðvitað Linux.

Þú getur opnað Share-valmyndina með `Super + Ctrl + S` eða undir _Trigger > Share_ í Omarchy-valmyndinni. Hún gefur þér fjóra valkosti:

- **Clipboard** sendir allt sem þú hefur afritað sem textaskrá. Frábært til að koma hlekk eða búti yfir í símann þinn án þess að senda sjálfum þér tölvupóst.
- **File** opnar skráaveljara þar sem þú getur valið nokkrar í einu.
- **Folder** sendir heila möppu.
- **Receive** opnar LocalSend sjálft svo annað tæki geti sent þér eitthvað.

Það sama virkar úr útstöðinni með `omarchy share clipboard`, `omarchy share file [path]` og `omarchy share folder [path]`. Slepptu slóðinni og þú færð veljarann.

Þú getur líka sent beint úr skráastjóranum: hægrismelltu á eitthvert val í Nautilus og veldu _Send via LocalSend_.

Eldveggur Omarchy er lokaður sjálfgefið nema fyrir gátt LocalSend, svo þetta virkar strax í nýrri uppsetningu. Sjá [öryggi](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) er heildstæður skrifstofupakki með ritvinnslu, töflureikni, kynningum, teikniforriti og fleira. Hann er samhæfur skrám frá Microsoft Office, svo þetta er frábær leið til að geta opnað þessi Word-skjal.

Þú ræsir LibreOffice í gegnum forritaræsinn (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) er eigið, dauðeinfalt kynningarforrit Omarchy. Kynningin þín er ein Markdown-skrá með myndum og myndböndum við hliðina: skrifaðu hverja glæru fyrir neðan lifandi forskoðun, dragðu glærurnar í röð og kynntu síðan í fullum skjá eða fluttu út í PDF og PowerPoint. Það tekur meira að segja upp Omarchy-þemað þitt.

Þú ræsir Hype í gegnum forritaræsinn (`Super + Space`). Ýttu á `?` inni í því til að sjá alla flýtilykla.

## Signed

[Signed](https://github.com/omacom/signed) er eigin, dauðeinfalda leið Omarchy til að undirrita PDF-skjöl og fylla þau út. Settu vistaða undirskriftina þína, texta og dagsetningu dagsins í dag hvar sem er á síðu og vistaðu síðan undirritað afrit við hlið frumritsins. Sjá [Að fylla út PDF-skjöl](27-filling-out-pdfs.md) fyrir leiðbeiningar.

Þú ræsir Signed í gegnum forritaræsinn (`Super + Space`) eða opnar PDF-skjal með því úr skráastjóranum.

## Game Vibes

Game Vibes, í forritaræsinum (`Super + Space`), er þar sem litlu leikir Omarchy búa: Checkmate, 3D skákleikur á móti vini eða innbyggða andstæðingnum; Cards, Klondike kapall; og Neon Swarm, arkadeskotleikur. Hver þeirra er ein vefsíða sem fylgir þemanu þínu. Veldu einn með örvunum og `Enter` og farðu aftur í listann með `Esc` á titilskjá leiks eða `Q` á meðan hann er í hléi. Hann opnast í fullum skjá: `Super + F` gerir hann að glugga og `Super + W` lokar honum.

Leikirnir sem þú gerir með umboðsmanni birtast hér líka: veldu _Make something cool → Game_ í umboðsmannaspjaldinu og lýstu einum, eða nefndu leik sem er þegar í Game Vibes til að halda áfram að vinna í honum. Umboðsmaðurinn afritar hann í `~/Games/vibes`, þar sem hann er þinn til að breyta, og opnar hann þegar hann er búinn. Þú getur gert það afrit sjálfur með `omarchy games vibes copy <game>`. Leikur sem einhver annar deilir setur sig upp eins og þema: veldu _Install > Gaming > Game Vibes_ og límdu git-slóð hans, eða keyrðu `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ fjarlægir einn aftur og _Update > Game Vibes Games_ sækir nýjar útgáfur. Leikir hlaða three.js af vefnum, svo þeir þurfa tengingu til að ræsa.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) er eigin, dauðeinfalda reiknivél Omarchy, sem opnast í fljótandi glugga.

Þú ræsir Omacalc með `Super + Shift + Q` (eða reiknivélarlyklinum, ef lyklaborðið þitt er með slíkan).

## Signal

[Signal](https://signal.org/) er frumkvöðull E2E-dulkóðaðra skilaboða og frábær samskiptakostur fyrir alla sem vilja frekar ekki fara í gegnum einn af stóru tæknirisunum.

Þú ræsir Signal með `Super + Shift + G`. Það er ekki hluti af grunnuppsetningunni, svo í fyrsta skipti sem þú ýtir á það býður Omarchy upp á að setja það upp fyrir þig (það er líka undir _Install > Service_ í Omarchy-valmyndinni).

## Omaview

[Omaview](https://github.com/omacom/omaview) er eigin, dauðeinfaldi myndskoðari og margmiðlunarspilari Omarchy: einn gluggi fyrir ljósmyndirnar þínar, myndbönd og tónlist. Opnaðu ljósmynd og örvalyklarnir færa þig í gegnum afganginn af möppunni hennar, `N` og `P` gera það fyrir allt og `Ctrl + M` sýnir alla möppuna sem rist. Hann sýnir líka HEIC-, AVIF- og JPEG XL-ljósmyndir og heldur áfram þar sem þú hættir í öllu löngu.

Ýttu á `F` fyrir fullan skjá, `E` til að breyta mynd í Omasnap eða klippa til myndband í Omacut, `Ctrl + P` til að prenta mynd og `Delete` til að færa skrá í Trash (`Ctrl + Z` kemur henni aftur). Ýttu á `?` inni í því til að sjá alla flýtilykla.

Þú ræsir Omaview sem _Media Viewer_ í gegnum forritaræsinn (`Super + Space`) eða tvísmellir bara á mynd, myndband eða lag í skráastjóranum.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) er eigið, dauðeinfalt tól Omarchy til að snyrta myndbönd. Þegar þú þarft bara að klippa byrjunina og endann af búti slær það því að ræsa fullbúið myndbandsvinnsluforrit.

Þú ræsir Omacut í gegnum forritaræsinn (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) er eigin, dauðeinfaldi vefmyndavélarupptökutól Omarchy. Veldu myndavélina þína og hljóðnemann einu sinni, ýttu síðan á `Space` til að taka upp og aftur til að gera hlé og halda áfram sömu töku. Það tekur alltaf upp í hæstu upplausn myndavélarinnar þinnar, með lifandi hljóðnemamæli svo þú getir athugað hljóðstyrkinn áður en þú byrjar.

Stöðvaðu tökuna og hún opnast strax í innbyggðum ritli. Tvísmelltu á bút til að skipta honum, dragðu handföngin til að snyrta hvern hluta og fjarlægðu hlutana sem þú vilt ekki. Vistaðu hann síðan sem MP4. Upprunalega upptakan þín er geymd þar til þú fleygir henni, svo þú getur alltaf komið aftur og klippt hana öðruvísi.

Þú ræsir Monologue í gegnum forritaræsinn (`Super + Space`).
