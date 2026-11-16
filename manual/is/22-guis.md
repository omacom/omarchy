# Grafísk forrit

## Skrár

Skrár (Nautilus) er grafíski skráastjórinn. `Super + Shift + F` opnar hann og `Super + Shift + Alt + F` opnar hann í möppunni sem útstöðin þín er í, sem sparar hellings smelli. `Ctrl + L` lætur þig slá inn slóð og með því að ýta á `Space` á hvaða skrá sem er færðu flýtiforskoðun án þess að opna neitt.

Stingdu USB-lykli eða SD-korti í samband og það er tengt sjálfkrafa, svo það birtist bara í hliðarstikunni. Fyrir eitthvað flóknara — að forsníða drif, athuga SMART-heilsu, búa til disksneiðar — ræstu _Disks_ úr forritavalmyndinni (`Super + Space`).

Tvísmellur fylgir skynsamlegum sjálfgefnum stillingum: myndir, myndbönd og tónlist opnast í Omaview, PDF-skjöl í Document Viewer, Markdown í Omawrite og venjulegur texti í ritlinum sem valinn er undir _Setup > Default > Editor_.

## Disktree

Þegar drifið fyllist og þú hefur ekki hugmynd um hvað er að éta það, ræstu [Disktree](https://github.com/tobi/disktree) úr forritavalmyndinni (`Super + Space`). Það sýnir grafískt trékort af heimamöppunni þinni. Stærri reitir taka meira pláss; farðu inn í möppur með lyklaborðinu eða músinni, merktu það sem á að fara og farðu yfir valið þitt áður en þú fjarlægir eitthvað. Keyrðu `disktree --disk` til að skanna allan diskinn.

## Obsidian

[Obsidian](https://obsidian.md/) er ókeypis og mjög útvíkkanlegt glósuforrit sem notar einfaldar Markdown-skrár til geymslu.

Obsidian er ókeypis í öllum tilgangi, þar á meðal til einkanota, viðskipta og fyrir félagasamtök án hagnaðarsjónarmiða.

Obsidian býður einnig upp á [greidda viðbót fyrir samstillingu](https://obsidian.md/sync) við farsímaforrit á iOS og Android. (https://obsidian.md/pricing).

Þú ræsir Obsidian með `Super + Shift + O`. Til að nota þemasamstillingu verðurðu að velja `Omarchy` þemað undir stillingum.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) er ofureinfalt Markdown-ritforrit frá Omarchy sjálfu. Engin gagnahvolf, engar viðbætur, bara þú og orðin.

Þú ræsir Omawrite með `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) er einfalt myndvinnslutól sem er frábært til að klippa til, breyta stærð og gera aðrar einfaldar breytingar. Búist bara ekki við valkosti við Photoshop. En það er samt með Magic Wand og lög!

Þú ræsir Pinta í gegnum forritavalmyndina (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) er þemaforrit sem getur dregið liti úr bakgrunnsmynd og breytt þeim í heildstætt, samræmt þema. Það er auðveldasta leiðin til að [búa til þitt eigið þema](43-making-your-own-theme.md).

Þú ræsir Aether í gegnum forritavalmyndina (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) lætur þig senda skrár í önnur tæki á sama neti sem keyra forritið, eins og AirDrop frá Apple. Það er þó fjölpalla, svo þú getur sent skrár til og frá Windows, macOS, Android, iOS og auðvitað Linux.

Þú getur opnað Share-valmyndina á `Super + Ctrl + S` eða undir _Trigger > Share_ í Omarchy-valmyndinni. Hún gefur þér fjóra kosti:

- **Clipboard** sendir það sem þú hefur afritað sem textaskrá. Frábært til að koma tengli eða búti yfir á símann þinn án þess að senda sjálfum þér tölvupóst.
- **File** opnar skráaval þar sem þú getur valið nokkrar í einu.
- **Folder** sendir heila möppu.
- **Receive** opnar LocalSend sjálft svo annað tæki geti sent þér eitthvað.

Sama virkar frá útstöðinni með `omarchy share clipboard`, `omarchy share file [path]` og `omarchy share folder [path]`. Slepptu slóðinni og þú færð valið.

Þú getur líka sent beint úr skráastjóranum: hægrismelltu á val í Nautilus og veldu _Send via LocalSend_.

Eldveggur Omarchy er lokaður sjálfgefið nema fyrir gátt LocalSend, svo þetta virkar beint úr kassanum í ferskri uppsetningu. Sjá [öryggi](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) er heill skrifstofupakki með ritvinnslu, töflureikni, kynningum, teikniforriti og fleira. Það er samhæft við skrár frá Microsoft Office, svo þetta er frábær leið til að geta opnað þessi Word-skjöl.

Þú ræsir LibreOffice í gegnum forritavalmyndina (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) er ofureinfalt kynningarforrit frá Omarchy sjálfu. Glærusafnið þitt er ein Markdown-skrá með myndum og myndböndum við hliðina: skrifaðu hverja glæru fyrir neðan lifandi forskoðun, dragðu glærur í röð, kynntu síðan í fullum skjá eða flyttu út í PDF og PowerPoint. Það tekur meira að segja upp Omarchy-þemað þitt.

Þú ræsir Hype í gegnum forritavalmyndina (`Super + Space`). Ýttu á `?` inni í því til að sjá alla flýtilykla.

## Signed

[Signed](https://github.com/omacom/signed) er ofureinföld leið Omarchy til að undirrita PDF-skjöl og fylla þau út. Settu vistaða undirskriftina þína, texta og dagsetningu dagsins hvar sem er á síðu, vistaðu síðan undirritað afrit við hlið upprunalega skjalsins. Sjá [Að fylla út PDF-skjöl](27-filling-out-pdfs.md) til að sjá hvernig.

Þú ræsir Signed í gegnum forritavalmyndina (`Super + Space`), eða opnar PDF-skjal með því úr skráastjóranum.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) er 3D-skákleikur frá Omarchy sjálfu. Spilaðu við vin á sömu tölvu eða innbyggða andstæðinginn á þremur erfiðleikastigum, á fjórum mótuðum settum sem hvert hreyfist á sinn hátt: sporbaugaför, útskorið tré og fílabein, skógarverur og nammi. Leikir eru án klukku og vistast eftir hvern leik.

Þú ræsir Checkmate í gegnum forritavalmyndina (`Super + Space`), þar sem það er skráð sem Chess. Ýttu á `?` inni í því til að sjá alla flýtilykla.

## Cards

[Cards](https://github.com/omacom/cards) er Klondike-kapall frá Omarchy sjálfu. Dragðu þrjú, án takmarkana á umferðum, í fjórum spilaröðum: ein teiknuð í litum þema þíns og þrjár með sitt eigið útlit. Smelltu á spil og síðan þangað sem það á að fara, dragðu það, eða tvísmelltu til að senda það á besta staðinn. Leikir vistast eftir hvern leik.

Þú ræsir Cards í gegnum forritavalmyndina (`Super + Space`). Smelltu á nafn þess, eða ýttu á `?`, til að sjá alla flýtilykla.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) er ofureinföld reiknivél frá Omarchy sjálfu, sem opnast í fljótandi glugga.

Þú ræsir Omacalc með `Super + Shift + Q` (eða reiknivélarlyklinum, ef lyklaborðið þitt er með slíkan).

## Signal

[Signal](https://signal.org/) er frumkvöðullinn í enda-í-enda dulkóðuðum skilaboðum og frábær samskiptakostur fyrir alla sem vilja frekar ekki fara í gegnum eitt af stóru tæknirisunum.

Þú ræsir Signal með `Super + Shift + G`. Það er ekki hluti af grunnuppsetningunni, svo í fyrsta skipti sem þú ýtir á það mun Omarchy bjóða þér að setja það upp fyrir þig (það er líka undir _Install > Service_ í Omarchy-valmyndinni).

## Omaview

[Omaview](https://github.com/omacom/omaview) er ofureinfaldur myndaskoðari og margmiðlunarspilari frá Omarchy sjálfu: einn gluggi fyrir myndirnar þínar, myndböndin og tónlistina. Opnaðu mynd og örvatakkarnir færa þig í gegnum restina af möppunni hennar, `N` og `P` gera það fyrir hvað sem er og `Ctrl + M` sýnir alla möppuna sem yfirlitsrist. Það sýnir líka HEIC, AVIF og JPEG XL myndir og heldur áfram þar sem þú hættir í hverju sem er löngu.

Ýttu á `F` fyrir fullan skjá, `E` til að breyta mynd í Omasnap eða klippa myndband í Omacut, `Ctrl + P` til að prenta mynd og `Delete` til að færa skrá í Trash (`Ctrl + Z` færir hana til baka). Ýttu á `?` inni í því til að sjá alla flýtilykla.

Þú ræsir Omaview sem _Media Viewer_ í gegnum forritavalmyndina (`Super + Space`), eða tvísmellir bara á mynd, myndband eða lag í skráastjóranum.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) er ofureinfaldur myndbandsklippir frá Omarchy sjálfu. Þegar allt sem þú þarft er að klippa byrjunina og endann af klippu er það miklu betra en að ræsa fullbúinn myndbandsritil.

Þú ræsir Omacut í gegnum forritavalmyndina (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) er ofureinfalt vefmyndavélaupptökuforrit frá Omarchy sjálfu. Veldu myndavélina þína og hljóðnemann einu sinni, ýttu síðan á `Space` til að taka upp og aftur til að gera hlé og halda áfram sömu töku. Það tekur alltaf upp í hæstu upplausn myndavélarinnar þinnar, með lifandi hljóðnemamæli svo þú getir athugað hljóðstyrkinn áður en þú byrjar.

Stöðvaðu tökuna og hún opnast strax í innbyggðum ritli. Tvísmelltu á klippu til að skipta henni, dragðu handföngin til að klippa hvern hluta til og fjarlægðu hlutana sem þú vilt ekki. Vistaðu hana síðan sem MP4. Upprunalega upptakan þín er geymd þar til þú hendir henni, svo þú getur alltaf komið til baka og klippt hana á annan hátt.

Þú ræsir Monologue í gegnum forritavalmyndina (`Super + Space`).
