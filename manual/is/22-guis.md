# GUI

## Files

Files (Nautilus) er myndræni skráastjórinn. `Super + Shift + F` opnar hann, og `Super + Shift + Alt + F` opnar hann í möppunni sem terminalið þitt situr í, sem sparar mikið smell. `Ctrl + L` leyfir þér að skrifa slóð, og að ýta á `Space` á hvaða skrá sem er gefur þér hraða forskoðun án þess að opna neitt.

Stingdu í samband við USB-lykil eða SD-kort og það er tengt sjálfkrafa, þannig að það birtist bara í hliðarstikunni. Til að gera eitthvað flóknara — að forsníða drif, athuga SMART-heilsu, búa til sneiðar — ræstu _Disks_ úr forritaræsinum (`Super + Space`).

Tvísmellur fylgir skynsamlegum sjálfgildum: myndir opnast í imv, myndbönd í mpv, PDF í Document Viewer og venjulegur texti í Neovim.

## Disktree

Þegar drifið fyllist og þú hefur enga hugmynd um hvað er að éta það skaltu ræsa [Disktree](https://github.com/tobi/disktree) úr forritaræsinum (`Super + Space`). Það sýnir myndrænt trékort af heimamöppunni þinni. Stærri kubbar taka meira pláss; gakktu inn í möppur með lyklaborðinu eða músinni, merktu það sem á að fara, og farðu yfir val þitt áður en þú fjarlægir nokkuð. Keyrðu `disktree --disk` til að skanna allan diskinn.

## Obsidian

[Obsidian](https://obsidian.md/) er ókeypis og mjög útvíkkanlegt minnisblaðsforrit sem notar einfaldar Markdown-skrár til geymslu.

Obsidian er ókeypis í öllum tilgangi, þar á meðal persónulegri, viðskiptalegri og óhagnaðardrifinni notkun.

Obsidian býður líka upp á [viðskiptaviðbót fyrir samstillingu](https://obsidian.md/sync) með snjallforritum á iOS og Android. (https://obsidian.md/pricing).

Þú ræsir Obsidian með `Super + Shift + O`. Til að nota þemasamstillingu verðurðu að velja þemað `Omarchy` í stillingum.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) er dauðeinfalt Markdown-ritforrit Omarchy. Engin hvelfingar, engar viðbætur, bara þú og orðin.

Þú ræsir Omawrite með `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) er einfalt myndvinnslutól sem er frábært til að skera, breyta stærð og aðrar grunnbreytingar. Búist bara ekki við Photoshop-valkosti. En það hefur samt Magic Wand og lög!

Þú ræsir Pinta í gegnum forritaræsinn (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) er þemaforrit sem getur dregið liti úr bakgrunnsmynd og breytt þeim í heilt, samhangandi þema. Það er auðveldasta leiðin til að [búa til þitt eigið þema](43-making-your-own-theme.md).

Þú ræsir Aether í gegnum forritaræsinn (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) leyfir þér að senda skrár til annarra tækja á sama neti sem keyra forritið, eins og AirDrop frá Apple. Það er þó fjölpalla, þannig að þú getur sent skrár til og frá Windows, macOS, Android, iOS og auðvitað Linux.

Þú getur opnað valmyndina Deila með `Super + Ctrl + S` eða undir _Kveikja > Deila_ í Omarchy-valmyndinni. Hún gefur þér fjóra valkosti:

- **Klippiborð** sendir það sem þú hefur afritað sem textaskrá. Frábært til að koma tengli eða bút í símann þinn án þess að senda sjálfum þér tölvupóst.
- **Skrá** opnar skráaval þar sem þú getur valið nokkrar í einu.
- **Mappa** sendir heila möppu.
- **Taka á móti** opnar LocalSend sjálft þannig að annað tæki getur sent þér eitthvað.

Sama virkar úr terminalinu með `omarchy share clipboard`, `omarchy share file [path]` og `omarchy share folder [path]`. Slepptu slóðinni og þú færð valið.

Þú getur líka sent beint úr skráastjóranum: hægrismelltu á hvaða val sem er í Nautilus og veldu _Send via LocalSend_.

Eldveggur Omarchy er sjálfgefið lokaður nema fyrir port LocalSend, þannig að þetta virkar beint úr kassanum á nýrri uppsetningu. Sjá [öryggi](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) er heill skrifstofupakki með ritvinnslu, töflureikni, kynningum, teikniforriti og fleiru. Hann er samhæfur við skrár frá Microsoft Office, þannig að þetta er frábær leið til að geta opnað þessi Word-skjöl.

Þú ræsir LibreOffice í gegnum forritaræsinn (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) er dauðeinfalt kynningarforrit Omarchy. Glærusafnið þitt er ein Markdown-skrá með myndum sínum og myndböndum við hliðina: skrifaðu hverja glæru fyrir neðan lifandi forskoðun, dragðu glærur í röð, kynntu síðan á fullum skjá eða fluttu út í PDF og PowerPoint. Það tekur jafnvel upp Omarchy-þemað þitt.

Þú ræsir Hype í gegnum forritaræsinn (`Super + Space`). Ýttu á `?` inni í því til að sjá alla flýtilykla.

## Signed

[Signed](https://github.com/omacom/signed) er dauðeinfalda leið Omarchy til að undirrita PDF og fylla þau út. Settu vistaða undirskriftina þína, texta og dagsetningu dagsins í dag hvar sem er á síðu, vistaðu síðan undirritað eintak við hlið upprunalega. Sjá [Að fylla út PDF](27-filling-out-pdfs.md) fyrir leiðbeiningar.

Þú ræsir Signed í gegnum forritaræsinn (`Super + Space`), eða opnar PDF með því úr skráastjóranum.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) er dauðeinfaldur reiknivél Omarchy, sem opnast í fljótandi glugga.

Þú ræsir Omacalc með `Super + Ctrl + Q` (eða reiknivélarlyklinum, ef lyklaborðið þitt er með einn).

## Signal

[Signal](https://signal.org/) er brautryðjandi E2E-dulkóðaðra skilaboða, og frábær samskiptakostur fyrir alla sem vilja frekar ekki fara í gegnum eitt af stóru tæknifyrirtækjunum.

Þú ræsir Signal með `Super + Shift + G`. Það er ekki hluti af grunnuppsetningunni, þannig að í fyrsta skipti sem þú ýtir á það mun Omarchy bjóðast til að setja það upp fyrir þig (það er líka undir _Setja upp > Þjónusta_ í Omarchy-valmyndinni).

## mpv

[mpv](https://mpv.io/) er einfaldur, hraður margmiðlunarspilari sem spilar næstum hvað sem er frá hvaða uppruna sem er. Frábær til að horfa á myndbönd.

Þú ræsir mpv í gegnum forritaræsinn (`Super + Space`) eða tvísmellir bara á myndband í skráastjóranum.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) er dauðeinfaldur myndbandaklippir Omarchy. Þegar þú þarft bara að klippa byrjun og enda af klippu slær það því við að ræsa fullan myndbandsritil.

Þú ræsir Omacut í gegnum forritaræsinn (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) er dauðeinfaldur vefmyndavélarupptökutæki Omarchy. Veldu myndavélina þína og hljóðnemann einu sinni, ýttu síðan á `Space` til að taka upp, og aftur til að gera hlé og halda áfram sömu töku. Það tekur alltaf upp í hæstu upplausn myndavélarinnar þinnar, með lifandi hljóðnemamæli þannig að þú getir athugað stigin áður en þú byrjar.

Stöðvaðu tökuna og hún opnast strax í innbyggðum ritli. Tvísmelltu á klippu til að skipta henni, dragðu handföngin til að snyrta hvert stykki, og fjarlægðu hlutana sem þú vilt ekki. Vistaðu það síðan sem MP4. Upprunaleg upptaka þín er geymd þar til þú fleygir henni, þannig að þú getur alltaf komið aftur og klippt hana öðruvísi.

Þú ræsir Monologue í gegnum forritaræsinn (`Super + Space`).
