# GUIs

## Files

Files (Nautilus) er grafíski skráastjórinn. `Super + Shift + F` opnar hann, og `Super + Shift + Alt + F` opnar hann í möppunni sem útstöðin þín er stödd í, sem sparar mikið af smellum. `Ctrl + L` lætur þig slá inn slóð, og að ýta á `Space` á einhverja skrá gefur þér fljótlega forskoðun án þess að opna neitt.

Stingdu USB-lykli eða SD-korti í samband og það er tengt sjálfkrafa, svo það birtist bara í hliðarstikunni. Fyrir allt sem er flóknara — að forsníða drif, athuga SMART-heilsu, búa til disksneiðar — skaltu ræsa _Disks_ úr forritaræsinum (`Super + Space`).

Tvísmellur fylgir skynsamlegum sjálfgefnum stillingum: myndir, myndbönd og tónlist opnast í Omaview, PDF-skjöl í Document Viewer, Markdown í Omawrite og venjulegur texti í ritlinum sem valinn er undir _Setup > Default > Editor_.

## Disktree

Þegar drifið fyllist og þú hefur ekki hugmynd um hvað er að éta það upp skaltu ræsa [Disktree](https://github.com/tobi/disktree) úr forritaræsinum (`Super + Space`). Það sýnir grafískt trékort af heimamöppunni þinni. Stærri reitir taka meira pláss; farðu inn í möppur með lyklaborðinu eða músinni, merktu það sem á að fara og farðu yfir valið þitt áður en þú fjarlægir neitt. Keyrðu `disktree --disk` til að skanna allan diskinn.

## Obsidian

[Obsidian](https://obsidian.md/) er ókeypis og mjög útvíkkanlegt glósuforrit sem notar einfaldar Markdown-skrár til geymslu.

Obsidian er ókeypis í öllum tilgangi, þar á meðal til persónulegrar notkunar, viðskiptanotkunar og notkunar hjá sjálfseignarstofnunum.

Obsidian býður einnig upp á [viðbót í viðskiptum fyrir samstillingu](https://obsidian.md/sync) við farsímaforrit á iOS og Android. (https://obsidian.md/pricing).

Þú ræsir Obsidian með `Super + Shift + O`. Til að nota samstillingu þema verður þú að velja `Omarchy` þemað undir stillingum.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) er eigið, dauðeinfalt Markdown-ritforrit Omarchy. Engar hirslur, engar viðbætur, bara þú og orðin.

Þú ræsir Omawrite með `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) er einfalt myndvinnsluforrit sem er frábært til að klippa til, breyta stærð og gera aðrar einfaldar breytingar. Búistu bara ekki við valkosti við Photoshop. En það er samt með Magic Wand og lögum!

Þú ræsir Pinta í gegnum forritaræsinn (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) er þemaforrit sem getur dregið liti úr bakgrunnsmynd og breytt þeim í heildstætt, samræmt þema. Það er auðveldasta leiðin til að [búa til þitt eigið þema](43-making-your-own-theme.md).

Þú ræsir Aether í gegnum forritaræsinn (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) lætur þig senda skrár á önnur tæki á sama neti sem keyra forritið, eins og AirDrop frá Apple. Það virkar þó á mörgum kerfum, svo þú getur sent skrár til og frá Windows, macOS, Android, iOS og auðvitað Linux.

Þú getur opnað Share-valmyndina með `Super + Ctrl + S` eða undir _Trigger > Share_ í Omarchy-valmyndinni. Hún gefur þér fjóra valkosti:

- **Clipboard** sendir allt sem þú hefur afritað sem textaskrá. Frábært til að koma tengli eða búti í símann þinn án þess að senda sjálfum þér tölvupóst.
- **File** opnar skráaveljara þar sem þú getur valið nokkrar skrár í einu.
- **Folder** sendir heila möppu.
- **Receive** opnar LocalSend sjálft svo annað tæki geti sent þér eitthvað.

Sama virkar úr útstöðinni með `omarchy share clipboard`, `omarchy share file [path]` og `omarchy share folder [path]`. Slepptu slóðinni og þú færð veljarann.

Þú getur líka sent beint úr skráastjóranum: hægrismelltu á val í Nautilus og veldu _Send via LocalSend_.

Eldveggur Omarchy er lokaður sjálfgefið nema fyrir port LocalSend, svo þetta virkar strax úr kassanum í ferskri uppsetningu. Sjá [öryggi](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) er heildstæður skrifstofupakki með ritvinnsluforriti, töflureikni, kynningum, teikniforriti og fleiru. Hann er samhæfur skrám frá Microsoft Office, svo þetta er frábær leið til að geta opnað þessi Word-skjöl.

Þú ræsir LibreOffice í gegnum forritaræsinn (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) er eigið, dauðeinfalt kynningarforrit Omarchy. Glærusafnið þitt er ein Markdown-skrá með myndirnar og myndböndin við hliðina: skrifaðu hverja glæru fyrir neðan lifandi forskoðun, dragðu glærurnar í rétta röð og kynntu síðan á fullum skjá eða flyttu út í PDF og PowerPoint. Það tekur meira að segja upp Omarchy-þemað þitt.

Þú ræsir Hype í gegnum forritaræsinn (`Super + Space`). Ýttu á `?` inni í því til að sjá alla flýtilykla.

## Signed

[Signed](https://github.com/omacom/signed) er eigin, dauðeinföld leið Omarchy til að undirrita PDF-skjöl og fylla þau út. Settu vistaða undirskriftina þína, texta og dagsetningu dagsins hvar sem er á síðu og vistaðu síðan undirritað eintak við hlið upprunalega skjalsins. Sjá [Að fylla út PDF-skjöl](27-filling-out-pdfs.md) til að sjá hvernig.

Þú ræsir Signed í gegnum forritaræsinn (`Super + Space`), eða opnar PDF-skjal með því úr skráastjóranum.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) er eigið 3D-skákleikur Omarchy. Spilaðu við vin á sömu tölvu eða innbyggða andstæðinginn á þremur erfiðleikastigum, á fjórum mótuðum settum sem hvert hreyfist á sinn hátt: geimför, útskorið tré og fílabein, skógarverur og sælgæti. Leikir eru án klukku og vistast eftir hvern leik.

Þú ræsir Checkmate í gegnum forritaræsinn (`Super + Space`). Ýttu á `?` inni í því til að sjá alla flýtilykla.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) er eigið, dauðeinfalt reiknivélaforrit Omarchy, sem opnast í fljótandi glugga.

Þú ræsir Omacalc með `Super + Shift + Q` (eða reiknivélarlyklinum, ef lyklaborðið þitt er með slíkan).

## Signal

[Signal](https://signal.org/) er frumkvöðull E2E-dulkóðaðra skilaboða og frábær samskiptakostur fyrir alla sem vilja frekar ekki fara í gegnum einn af stóru tæknirisunum.

Þú ræsir Signal með `Super + Shift + G`. Það er ekki hluti af grunnuppsetningunni, svo í fyrsta skipti sem þú ýtir á það býðst Omarchy til að setja það upp fyrir þig (það er líka undir _Install > Service_ í Omarchy-valmyndinni).

## Omaview

[Omaview](https://github.com/omacom/omaview) er eigið, dauðeinfalt myndaskoðara- og margmiðlunarspilaraforrit Omarchy: einn gluggi fyrir ljósmyndirnar þínar, myndbönd og tónlist. Opnaðu ljósmynd og örvatakkarnir færa þig í gegnum restina af möppunni hennar, `N` og `P` gera það fyrir allt, og `Ctrl + M` sýnir alla möppuna sem rist. Það sýnir líka HEIC-, AVIF- og JPEG XL-myndir og heldur áfram þar sem frá var horfið í öllu löngu efni.

Ýttu á `F` fyrir fullan skjá, `E` til að breyta mynd í Omasnap eða klippa myndband í Omacut, `Ctrl + P` til að prenta mynd og `Delete` til að færa skrá í ruslið (`Ctrl + Z` færir hana til baka). Ýttu á `?` inni í því til að sjá alla flýtilykla.

Þú ræsir Omaview sem _Media Viewer_ í gegnum forritaræsinn (`Super + Space`), eða tvísmellir bara á mynd, myndband eða lag í skráastjóranum.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) er eigið, dauðeinfalt myndbandsklippiforrit Omarchy. Þegar þú þarft bara að klippa byrjunina og endann af myndbandi slær það því að ræsa fullbúið myndbandavinnsluforrit.

Þú ræsir Omacut í gegnum forritaræsinn (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) er eigið, dauðeinfalt vefmyndavélaupptökuforrit Omarchy. Veldu myndavélina þína og hljóðnemann einu sinni, ýttu síðan á `Space` til að taka upp og aftur til að gera hlé og halda áfram með sömu töku. Það tekur alltaf upp í hæstu upplausn myndavélarinnar þinnar, með lifandi hljóðnemamæli svo þú getir athugað hljóðstyrkinn áður en þú byrjar.

Stöðvaðu tökuna og hún opnast strax í innbyggðum ritli. Tvísmelltu á búta til að skipta honum, dragðu í handföngin til að klippa hvern hluta til og fjarlægðu hlutana sem þú vilt ekki. Vistaðu hann síðan sem MP4. Upprunalega upptakan er geymd þar til þú hendir henni, svo þú getur alltaf komið aftur og klippt hana öðruvísi.

Þú ræsir Monologue í gegnum forritaræsinn (`Super + Space`).
