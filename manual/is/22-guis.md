# Grafísk viðmót

## Skrár

Files (Nautilus) er grafíska skráastjórnin. `Super + Shift + F` opnar hana og `Super + Shift + Alt + F` opnar hana í möppunni sem útstöðin þín er í, sem sparar þér mikið smelling. `Ctrl + L` gerir þér kleift að slá inn slóð og það að ýta á `Space` á einhverja skrá gefur þér fljótlega forskoðun án þess að opna neitt.

Stingdu USB-lykli eða SD-korti í samband og það er tengt sjálfkrafa, svo það birtist einfaldlega í hliðarstikunni. Fyrir eitthvað flóknara — að forsníða drif, athuga SMART-heilsu, búa til disksneiðar — skaltu ræsa _Disks_ úr forritaræsinum (`Super + Space`).

Það að tvísmella fylgir skynsamlegum sjálfgefnum stillingum: myndir, myndbönd og tónlist opnast í Omaview, PDF-skjöl í Document Viewer, Markdown í Omawrite og venjulegur texti í ritlinum sem valinn er undir _Setup > Default > Editor_.

## Disktree

Þegar drifið fyllist og þú hefur ekki hugmynd um hvað er að éta það upp skaltu ræsa [Disktree](https://github.com/tobi/disktree) úr forritaræsinum (`Super + Space`). Það sýnir grafískt trékort af heimamöppunni þinni. Stærri reitir taka meira pláss; farðu inn í möppur með lyklaborðinu eða músinni, merktu það sem á að fara og farðu yfir valið þitt áður en þú fjarlægir nokkuð. Keyrðu `disktree --disk` til að skanna allan diskinn.

## Obsidian

[Obsidian](https://obsidian.md/) er ókeypis og mjög útvíkkanlegt glósuforrit sem notar einfaldar Markdown-skrár til geymslu.

Obsidian er ókeypis í öllum tilgangi, þar á meðal til einkanota, viðskiptanota og nota í þágu félagasamtaka sem ekki eru rekin í hagnaðarskyni.

Obsidian býður einnig upp á [viðbót í viðskiptaskyni til samstillingar](https://obsidian.md/sync) við farsímaforrit á iOS og Android. (https://obsidian.md/pricing).

Þú ræsir Obsidian með `Super + Shift + O`. Til að nota þemasamstillingu verður þú að velja `Omarchy` þemað undir stillingum.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) er eigið, dauðeinfalt Markdown-ritforrit Omarchy. Engar glósuhirslur, engar viðbætur, bara þú og orðin.

Þú ræsir Omawrite með `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) er einfalt myndvinnslutól sem er frábært til að klippa til, breyta stærð og gera aðrar grunnbreytingar. Búist bara ekki við valkosti við Photoshop. En það er samt með Magic Wand og lög!

Þú ræsir Pinta í gegnum forritaræsinn (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) er þemaforrit sem getur dregið liti úr bakgrunnsmynd og breytt þeim í heildstætt, samræmt þema. Það er auðveldasta leiðin til að [búa til þitt eigið þema](43-making-your-own-theme.md).

Þú ræsir Aether í gegnum forritaræsinn (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) gerir þér kleift að senda skrár til annarra tækja á sama neti sem keyra forritið, eins og AirDrop frá Apple. Það er þó fjölvettvangs, svo þú getur sent skrár til og frá Windows, macOS, Android, iOS og auðvitað Linux.

Þú getur opnað Share-valmyndina með `Super + Ctrl + S` eða undir _Trigger > Share_ í Omarchy-valmyndinni. Hún gefur þér fjóra valkosti:

- **Clipboard** sendir það sem þú hefur afritað sem textaskrá. Frábært til að koma hlekk eða búti yfir á símann þinn án þess að senda sjálfum þér tölvupóst.
- **File** opnar skráaveljara þar sem þú getur valið nokkrar skrár í einu.
- **Folder** sendir heila möppu.
- **Receive** opnar LocalSend sjálft svo annað tæki geti sent þér eitthvað.

Það sama virkar frá útstöðinni með `omarchy share clipboard`, `omarchy share file [path]` og `omarchy share folder [path]`. Slepptu slóðinni og þú færð veljarann.

Þú getur líka sent beint úr skráastjórninni: hægrismelltu á val í Nautilus og veldu _Send via LocalSend_.

Eldveggur Omarchy er lokaður sjálfgefið nema fyrir gátt LocalSend, svo þetta virkar beint upp úr kassanum við nýja uppsetningu. Sjá [öryggi](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) er heildstæður skrifstofupakki með ritvinnslu, töflureikni, kynningum, teikniforriti og fleira. Hann er samhæfur skrám frá Microsoft Office, svo þetta er frábær leið til að geta opnað þau Word-skjöl.

Þú ræsir LibreOffice í gegnum forritaræsinn (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) er eigið, dauðeinfalt kynningarforrit Omarchy. Glærusafnið þitt er ein Markdown-skrá með myndunum og myndböndunum við hliðina: skrifaðu hverja glæru fyrir neðan lifandi forskoðun, dragðu glærurnar í rétta röð og kynntu síðan á fullum skjá eða flyttu út sem PDF og PowerPoint. Það tekur jafnvel upp Omarchy-þemað þitt.

Þú ræsir Hype í gegnum forritaræsinn (`Super + Space`). Ýttu á `?` inni í því til að sjá alla flýtilykla.

## Signed

[Signed](https://github.com/omacom/signed) er eigin, dauðeinföld leið Omarchy til að undirrita PDF-skjöl og fylla þau út. Settu vistaðu undirskriftina þína, texta og dagsetningu dagsins í dag hvar sem er á síðu og vistaðu síðan undirritað eintak við hlið upprunalega skjalsins. Sjá [Að fylla út PDF-skjöl](27-filling-out-pdfs.md) til að sjá hvernig.

Þú ræsir Signed í gegnum forritaræsinn (`Super + Space`), eða opnar PDF-skjal með því úr skráastjórninni.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) er eigin, dauðeinföld reiknivél Omarchy, sem opnast í fljótandi glugga.

Þú ræsir Omacalc með `Super + Shift + Q` (eða reiknivélarlyklinum, ef lyklaborðið þitt er með slíkan).

## Signal

[Signal](https://signal.org/) er frumkvöðullinn í enda-í-enda dulkóðuðum skilaboðum og frábær samskiptakostur fyrir alla sem vilja frekar ekki fara í gegnum eitt af stóru tæknirisunum.

Þú ræsir Signal með `Super + Shift + G`. Það er ekki hluti af grunnuppsetningunni, svo í fyrsta skipti sem þú ýtir á það býður Omarchy upp á að setja það upp fyrir þig (það er líka undir _Install > Service_ í Omarchy-valmyndinni).

## Omaview

[Omaview](https://github.com/omacom/omaview) er eigið, dauðeinfalt myndaskoðunar- og margmiðlunarforrit Omarchy: einn gluggi fyrir ljósmyndirnar þínar, myndbönd og tónlist. Opnaðu ljósmynd og örvatakkarnir færa þig í gegnum restina af möppunni hennar, `N` og `P` gera það fyrir hvað sem er og `Ctrl + M` sýnir alla möppuna sem reitakerfi. Það sýnir líka HEIC-, AVIF- og JPEG XL-ljósmyndir og heldur áfram þar sem þú hættir í öllu sem er langt.

Ýttu á `F` fyrir fullan skjá, `E` til að breyta mynd í Omasnap eða klippa myndband til í Omacut, `Ctrl + P` til að prenta mynd og `Delete` til að færa skrá í Ruslið (`Ctrl + Z` kemur með hana til baka). Ýttu á `?` inni í því til að sjá alla flýtilykla.

Þú ræsir Omaview sem _Media Viewer_ í gegnum forritaræsinn (`Super + Space`), eða tvísmellir einfaldlega á mynd, myndband eða lag í skráastjórninni.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) er eiginn, dauðeinfaldi myndbandsklippir Omarchy. Þegar allt sem þú þarft er að klippa byrjunina og endann af klippu slær það því að þurfa að ræsa fullbúið myndvinnsluforrit.

Þú ræsir Omacut í gegnum forritaræsinn (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) er eigið, dauðeinfalt vefmyndavélaupptökuforrit Omarchy. Veldu myndavélina þína og hljóðnemann einu sinni, ýttu svo á `Space` til að taka upp og aftur til að gera hlé og halda áfram með sömu töku. Það tekur alltaf upp í hæstu upplausn myndavélarinnar þinnar, með lifandi hljóðnemamæli svo þú getir athugað hljóðstigin áður en þú byrjar.

Stöðvaðu tökuna og hún opnast strax í innbyggðu klippiforriti. Tvísmelltu á klippu til að skipta henni, dragðu handföngin til að klippa hvert stykki til og fjarlægðu hlutana sem þú vilt ekki hafa. Vistaðu hana svo sem MP4. Upprunalega upptakan er geymd þar til þú fleygir henni, svo þú getur alltaf komið til baka og klippt hana öðruvísi.

Þú ræsir Monologue í gegnum forritaræsinn (`Super + Space`).
