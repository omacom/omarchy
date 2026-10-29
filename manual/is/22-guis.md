# Grafísk forrit

## Skrár

Skrár (Nautilus) er grafíski skráarstjórinn. `Super + Shift + F` opnar hann, og `Super + Shift + Alt + F` opnar hann í möppunni sem útstöðin þín er í, sem sparar þér hellings smells. `Ctrl + L` gerir þér kleift að slá inn slóð, og ef þú ýtir á `Space` á einhverja skrá færðu fljótlega forskoðun án þess að opna neitt.

Stingdu USB-lykli eða SD-korti í samband og það er tengt sjálfkrafa, svo það birtist bara í hliðarstikunni. Fyrir eitthvað flóknara — að forsníða drif, athuga SMART-heilsu, búa til disksneiðar — skaltu ræsa _Disks_ úr forritaræsinum (`Super + Space`).

Tvísmellur fylgir skynsamlegum sjálfgefnum stillingum: myndir opnast í imv, myndband í mpv, PDF-skjöl í Document Viewer og venjulegur texti í Neovim.

## Disktree

Þegar drifið fyllist og þú hefur ekki hugmynd um hvað er að éta það skaltu ræsa [Disktree](https://github.com/tobi/disktree) úr forritaræsinum (`Super + Space`). Það sýnir grafískt trékort af heimamöppunni þinni. Stærri kubbar taka meira pláss; farðu inn í möppur með lyklaborðinu eða músinni, merktu það sem á að fara og farðu yfir valið þitt áður en þú fjarlægir nokkuð. Keyrðu `disktree --disk` til að skanna allan diskinn.

## Obsidian

[Obsidian](https://obsidian.md/) er ókeypis og mjög útvíkkanlegt glósuforrit sem notar einfaldar Markdown-skrár til geymslu.

Obsidian er ókeypis í öllum tilgangi, þar á meðal til einkanota, viðskiptanota og nota í félagasamtökum.

Obsidian býður einnig upp á [viðbót í viðskiptum fyrir samstillingu](https://obsidian.md/sync) við farsímaforrit á iOS og Android. (https://obsidian.md/pricing).

Þú ræsir Obsidian með `Super + Shift + O`. Til að nota samstillingu þema verður þú að velja `Omarchy` þemað í stillingunum.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) er ofureinfalt Markdown-ritforrit frá Omarchy sjálfu. Engar hirslur, engar viðbætur, bara þú og orðin.

Þú ræsir Omawrite með `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) er einfalt myndvinnslutól sem er frábært til að klippa til, breyta stærð og gera aðrar einfaldar breytingar. Ekki búast við Photoshop-valkosti, samt. En það er samt með Magic Wand og lög!

Þú ræsir Pinta í gegnum forritaræsinn (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) er þemaforrit sem getur dregið liti úr bakgrunnsmynd og breytt þeim í heildstætt, samræmt þema. Það er auðveldasta leiðin til að [búa til þitt eigið þema](43-making-your-own-theme.md).

Þú ræsir Aether í gegnum forritaræsinn (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) gerir þér kleift að senda skrár til annarra tækja á sama neti sem keyra forritið, eins og AirDrop frá Apple. Það er þó þverpalla, svo þú getur sent skrár til og frá Windows, macOS, Android, iOS og auðvitað Linux.

Þú getur opnað Share-valmyndina með `Super + Ctrl + S` eða undir _Trigger > Share_ í Omarchy-valmyndinni. Hún gefur þér fjóra möguleika:

- **Clipboard** sendir það sem þú hefur afritað sem textaskrá. Frábært til að koma hlekk eða búti í símann þinn án þess að senda sjálfum þér tölvupóst.
- **File** opnar skráarveljara þar sem þú getur valið nokkrar í einu.
- **Folder** sendir heila möppu.
- **Receive** opnar LocalSend sjálft svo annað tæki geti sent þér eitthvað.

Það sama virkar úr útstöðinni með `omarchy share clipboard`, `omarchy share file [path]` og `omarchy share folder [path]`. Slepptu slóðinni og þú færð veljarann.

Þú getur líka sent beint úr skráarstjóranum: hægrismelltu á hvaða val sem er í Nautilus og veldu _Send via LocalSend_.

Eldveggur Omarchy er lokaður sjálfgefið nema fyrir gátt LocalSend, svo þetta virkar beint upp úr kassanum á nýrri uppsetningu. Sjá [öryggi](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) er heildstæð skrifstofupakki með ritvinnslu, töflureikni, kynningum, teikniforriti og fleira. Hann er samhæfur skrám frá Microsoft Office, svo þetta er frábær leið til að geta opnað þessi Word-skjöl.

Þú ræsir LibreOffice í gegnum forritaræsinn (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) er ofureinfalt kynningarforrit frá Omarchy sjálfu. Glærusafnið þitt er ein Markdown-skrá með myndum og myndböndum við hliðina: skrifaðu hverja glæru undir lifandi forskoðun, dragðu glærurnar í röð og kynntu svo á fullum skjá eða flyttu út í PDF og PowerPoint. Það sækir meira að segja Omarchy-þemað þitt.

Þú ræsir Hype í gegnum forritaræsinn (`Super + Space`). Ýttu á `?` inni í því til að sjá alla flýtilykla.

## Signed

[Signed](https://github.com/omacom/signed) er ofureinföld leið frá Omarchy sjálfu til að undirrita PDF-skjöl og fylla þau út. Settu vistaða undirskriftina þína, texta og dagsetningu dagsins hvar sem er á síðu og vistaðu svo undirritað afrit við hlið frumritsins. Sjá [Að fylla út PDF-skjöl](27-filling-out-pdfs.md) til að sjá hvernig.

Þú ræsir Signed í gegnum forritaræsinn (`Super + Space`), eða opnar PDF-skjal með því úr skráarstjóranum.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) er ofureinfaldur reiknivél frá Omarchy sjálfu, sem opnast í fljótandi glugga.

Þú ræsir Omacalc með `Super + Shift + Q` (eða reiknivélarlyklinum, ef lyklaborðið þitt er með slíkan).

## Signal

[Signal](https://signal.org/) er frumkvöðull E2E-dulritunar skilaboða og frábær samskiptamöguleiki fyrir alla sem vilja frekar ekki fara í gegnum eitt af stóru tæknifyrirtækjunum.

Þú ræsir Signal með `Super + Shift + G`. Það er ekki hluti af grunnuppsetningunni, svo í fyrsta skipti sem þú ýtir á það býður Omarchy þér að setja það upp fyrir þig (það er líka undir _Install > Service_ í Omarchy-valmyndinni).

## mpv

[mpv](https://mpv.io/) er einfaldur, fljótur margmiðlunarspilari sem spilar næstum hvað sem er frá hvaða upptökum sem er. Frábær til að horfa á myndbönd.

Þú ræsir mpv í gegnum forritaræsinn (`Super + Space`) eða tvísmellir bara á myndband í skráarstjóranum.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) er ofureinfaldur myndbandsklippir frá Omarchy sjálfu. Þegar þú þarft bara að klippa byrjunina og endann af búti slær það því við að ræsa fullbúið myndbandsvinnsluforrit.

Þú ræsir Omacut í gegnum forritaræsinn (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) er ofureinfaldur vefmyndavélarupptökumaður frá Omarchy sjálfu. Veldu myndavélina þína og hljóðnemann einu sinni, ýttu svo á `Space` til að taka upp og aftur til að gera hlé og halda áfram með sömu töku. Hann tekur alltaf upp í hæstu upplausn myndavélarinnar þinnar, með lifandi hljóðnemamæli svo þú getir athugað hljóðstyrkinn áður en þú byrjar.

Stöðvaðu tökuna og hún opnast strax í innbyggðum ritli. Tvísmelltu á bút til að skipta honum, dragðu handföngin til að klippa hvern hluta til og fjarlægðu þá hluta sem þú vilt ekki. Vistaðu hann svo sem MP4. Upprunalega upptakan þín er geymd þar til þú hendir henni, svo þú getur alltaf komið aftur og klippt hana öðruvísi.

Þú ræsir Monologue í gegnum forritaræsinn (`Super + Space`).
