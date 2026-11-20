# Grafísk viðmót

## Files

Files (Folio) er grafíski skráastjórinn. `Super + Shift + F` opnar hann, og `Super + Shift + Alt + F` opnar hann í möppunni sem útstöðin þín er í, sem sparar mikla smelli. `Ctrl + L` gerir þér kleift að slá inn slóð, og með því að ýta á `Space` á einhverja skrá forskoðarðu hana í fullri stærð án þess að opna hana.

Tengdu USB-lykil eða SD-kort og það er tengt sjálfkrafa, svo það birtist bara í hliðarstikunni. Fyrir eitthvað flóknara — að forsníða drif, athuga SMART-heilsu, búa til disksneiðar — ræstu _Disks_ úr forritaræsinum (`Super + Space`).

Tvísmelling fylgir skynsamlegum sjálfgefnum stillingum: myndir, myndbönd og tónlist opnast í Omaview, PDF-skrár í Document Viewer, Markdown í Omawrite og venjulegur texti í ritlinum sem valinn er undir _Setup > Default > Editor_.

## Disktree

Þegar drifið fyllist og þú hefur ekki hugmynd um hvað er að éta það upp skaltu ræsa [Disktree](https://github.com/tobi/disktree) úr forritaræsinum (`Super + Space`). Það sýnir grafískt trékort af heimamöppunni þinni. Stærri kubbar taka meira pláss; farðu inn í möppur með lyklaborðinu eða músinni, merktu það sem á að fara og farðu yfir valið þitt áður en þú fjarlægir eitthvað. Keyrðu `disktree --disk` til að skanna allan diskinn.

## Obsidian

[Obsidian](https://obsidian.md/) er ókeypis og mjög útvíkkanlegt glósuforrit sem notar einfaldar Markdown-skrár til geymslu.

Obsidian er ókeypis í öllum tilgangi, þar á meðal til einkanota, í viðskiptum og fyrir félagasamtök án hagnaðarsjónarmiða.

Obsidian býður einnig upp á [greidda viðbót fyrir samstillingu](https://obsidian.md/sync) við farsímaforrit á iOS og Android. (https://obsidian.md/pricing).

Þú ræsir Obsidian með `Super + Shift + O`. Til að nota þemasamstillingu verður þú að velja `Omarchy` þemað í stillingunum.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) er afskaplega einfalt Markdown-ritunarforrit frá Omarchy. Engar geymslur, engar viðbætur, bara þú og orðin.

Þú ræsir Omawrite með `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) er einfalt myndvinnslutól sem er frábært til að klippa til, breyta stærð og gera aðrar einfaldar breytingar. Búist bara ekki við valkosti við Photoshop. En það er samt með Magic Wand og lög!

Þú ræsir Pinta í gegnum forritaræsinn (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) er þemaforrit sem getur dregið liti út úr bakgrunnsmynd og breytt þeim í heildstætt, samræmt þema. Það er auðveldasta leiðin til að [búa til þitt eigið þema](43-making-your-own-theme.md).

Þú ræsir Aether í gegnum forritaræsinn (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) gerir þér kleift að senda skrár til annarra tækja á sama neti sem keyra forritið, eins og AirDrop frá Apple. Það virkar þó á mörgum kerfum, svo þú getur sent skrár til og frá Windows, macOS, Android, iOS og auðvitað Linux.

Þú getur opnað Share-valmyndina með `Super + Ctrl + S` eða undir _Trigger > Share_ í Omarchy-valmyndinni. Hún gefur þér fjóra valkosti:

- **Clipboard** sendir það sem þú hefur afritað sem textaskrá. Frábært til að koma hlekk eða bút yfir í símann þinn án þess að senda sjálfum þér tölvupóst.
- **File** opnar skráaveljara þar sem þú getur valið nokkrar í einu.
- **Folder** sendir heila möppu.
- **Receive** opnar LocalSend sjálft svo annað tæki geti sent þér eitthvað.

Sama virkar úr útstöðinni með `omarchy share clipboard`, `omarchy share file [path]` og `omarchy share folder [path]`. Slepptu slóðinni og þú færð veljarann.

Þú getur líka sent beint úr skráastjóranum: hægrismelltu á hvaða val sem er í Files og deildu því með LocalSend.

Eldveggur Omarchy er lokaður sjálfgefið nema fyrir gátt LocalSend, svo þetta virkar strax við ferska uppsetningu. Sjá [öryggi](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) er heildstæður skrifstofupakki með ritvinnsluforriti, töflureikni, kynningum, teikniforriti og fleira. Hann er samhæfur skrám frá Microsoft Office, svo þetta er frábær leið til að geta opnað þessi Word-skjal.

Þú ræsir LibreOffice í gegnum forritaræsinn (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) er afskaplega einfalt kynningarforrit frá Omarchy. Glærusafnið þitt er ein Markdown-skrá með myndirnar og myndböndin við hliðina: skrifaðu hverja glæru fyrir neðan lifandi forskoðun, dragðu glærurnar í röð og kynntu síðan í fullum skjá eða fluttu út í PDF og PowerPoint. Það tekur meira að segja upp Omarchy-þemað þitt.

Þú ræsir Hype í gegnum forritaræsinn (`Super + Space`). Ýttu á `?` inni í því til að sjá alla flýtilykla.

## Signed

[Signed](https://github.com/omacom/signed) er afskaplega einföld leið frá Omarchy til að undirrita PDF-skrár og fylla þær út. Settu vistaða undirskriftina þína, texta og dagsetningu dagsins í dag hvar sem er á síðu og vistaðu síðan undirritað afrit við hlið frumritsins. Sjá [Að fylla út PDF-skrár](27-filling-out-pdfs.md) til að sjá hvernig.

Þú ræsir Signed í gegnum forritaræsinn (`Super + Space`), eða opnar PDF-skrá með því úr skráastjóranum.

## Game Vibes

Game Vibes, í forritaræsinum (`Super + Space`), er þar sem litlu leikir Omarchy búa: Checkmate, þrívíður skákleikur gegn vini eða innbyggða andstæðingnum; Cards, Klondike kapall; og Neon Swarm, arkade-skotleikur. Hver þeirra er ein vefsíða sem fylgir þemanu þínu. Veldu einn með örvunum og `Enter`, og farðu aftur í listann með `Esc` af titilskjá leiks eða `Q` á meðan hann er í hlé. Hann opnast í fullum skjá: `Super + F` gerir hann að glugga og `Super + W` lokar honum.

Leikirnir sem þú býrð til með umboðsmanni birtast hér líka: veldu _Make something cool → Game_ í umboðsmannaspjaldinu og lýstu einum, eða nefndu leik sem þegar er í Game Vibes til að halda áfram að vinna í honum. Umboðsmaðurinn afritar hann inn í `~/Games/vibes`, þar sem hann er þinn til að breyta, og opnar hann þegar hann er búinn. Þú getur búið til það afrit sjálfur með `omarchy games vibes copy <game>`. Leikur sem einhver annar deilir setur sig upp eins og þema: veldu _Install > Gaming > Game Vibes_ og límdu git-vistfangið hans, eða keyrðu `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ fjarlægir einn aftur, og _Update > Game Vibes Games_ sækir nýjar útgáfur. Leikir hlaða three.js af vefnum, svo þeir þurfa tengingu til að hefjast.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) er afskaplega einföld reiknivél frá Omarchy, sem opnast í fljótandi glugga.

Þú ræsir Omacalc með `Super + Shift + Q` (eða reiknivélarlyklinum, ef lyklaborðið þitt er með slíkan).

## Signal

[Signal](https://signal.org/) er frumkvöðull E2E-dulkóðaðra skilaboða og frábær samskiptakostur fyrir alla sem vilja helst ekki fara í gegnum eitt af stóru tæknirisasamsteypunum.

Þú ræsir Signal með `Super + Shift + G`. Það er ekki hluti af grunnuppsetningunni, svo í fyrsta skipti sem þú ýtir á það mun Omarchy bjóða þér að setja það upp fyrir þig (það er líka undir _Install > Service_ í Omarchy-valmyndinni).

## Omaview

[Omaview](https://github.com/omacom/omaview) er afskaplega einfaldur myndaskoðari og margmiðlunarspilari frá Omarchy: einn gluggi fyrir myndirnar þínar, myndbönd og tónlist. Opnaðu mynd og örvalyklarnir stíga í gegnum afganginn af möppunni hennar, `N` og `P` gera það fyrir hvað sem er, og `Ctrl + M` sýnir alla möppuna sem grind. Það sýnir líka HEIC, AVIF og JPEG XL myndir og heldur áfram þar sem þú hættir í öllu löngu.

Ýttu á `F` fyrir fullan skjá, `E` til að breyta mynd í Omasnap eða klippa myndband í Omacut, `Ctrl + P` til að prenta mynd og `Delete` til að færa skrá í Ruslið (`Ctrl + Z` kemur henni aftur). Ýttu á `?` inni í því til að sjá alla flýtilykla.

Þú ræsir Omaview sem _Media Viewer_ í gegnum forritaræsinn (`Super + Space`), eða tvísmellir bara á mynd, myndband eða lag í skráastjóranum.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) er afskaplega einfalt myndbandsklippitól frá Omarchy. Þegar þú þarft bara að klippa upphafið og endann af klippu er það mun betra en að ræsa heilt myndbandsvinnsluforrit.

Þú ræsir Omacut í gegnum forritaræsinn (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) er afskaplega einfalt vefmyndavélaupptökuforrit frá Omarchy. Veldu myndavélina þína og hljóðnemann einu sinni, ýttu síðan á `Space` til að taka upp, og aftur til að gera hlé og halda áfram sömu töku. Það tekur alltaf upp í hæstu upplausn myndavélarinnar þinnar, með lifandi hljóðnemamæli svo þú getir athugað hljóðstigin áður en þú byrjar.

Stöðvaðu tökuna og hún opnast strax í innbyggðum ritli. Tvísmelltu á klippu til að skipta henni, dragðu handföngin til að klippa hvern hluta til og fjarlægðu hlutana sem þú vilt ekki. Vistaðu hana síðan sem MP4. Upprunalega upptakan þín er geymd þangað til þú hendir henni, svo þú getur alltaf komið aftur og klippt hana öðruvísi.

Þú ræsir Monologue í gegnum forritaræsinn (`Super + Space`).
