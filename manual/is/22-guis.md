# Grafísk forrit

## Skrár

Files (Nautilus) er grafíski skráarstjórinn. `Super + Shift + F` opnar hann og `Super + Shift + Alt + F` opnar hann í möppunni sem útstöðin þín er í, sem sparar mikið smelliklið. Með `Ctrl + L` geturðu slegið inn slóð og með því að ýta á `Space` á einhverja skrá færðu flýtiforskoðun án þess að opna neitt.

Tengdu USB-lykil eða SD-kort og það er tengt sjálfkrafa, svo það birtist bara í hliðarstikunni. Fyrir eitthvað flóknara — að formatta drif, athuga SMART-heilsu, búa til disksneiðingar — skaltu ræsa _Disks_ úr forritavalmyndinni (`Super + Space`).

Það að tvísmella fylgir skynsamlegum sjálfgefnum stillingum: myndir, myndbönd og tónlist opnast í Omaview, PDF-skjöl í Document Viewer, Markdown í Omawrite og venjulegur texti í ritlinum sem valinn er undir _Setup > Default > Editor_.

## Disktree

Þegar drifið fyllist og þú hefur ekki hugmynd um hvað er að éta það skaltu ræsa [Disktree](https://github.com/tobi/disktree) úr forritavalmyndinni (`Super + Space`). Það sýnir grafískt trékort af heimamöppunni þinni. Stærri reitir taka meira pláss; farðu inn í möppur með lyklaborðinu eða músinni, merktu það sem á að fara og farðu yfir valið þitt áður en þú fjarlægir nokkuð. Keyrðu `disktree --disk` til að skanna allan diskinn.

## Obsidian

[Obsidian](https://obsidian.md/) er ókeypis og mjög útvíkkanlegt glósuforrit sem notar einfaldar Markdown-skrár til geymslu.

Obsidian er ókeypis í öllum tilgangi, þar á meðal til einkanota, í viðskiptum og í óhagnaðarskyni.

Obsidian býður einnig upp á [viðbót í viðskiptalegum tilgangi fyrir samstillingu](https://obsidian.md/sync) við farsímaforrit á iOS og Android. (https://obsidian.md/pricing).

Þú ræsir Obsidian með `Super + Shift + O`. Til að nota þemasamstillingu verðurðu að velja `Omarchy`-þemað í stillingunum.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) er ofureinfalt Markdown-ritunarforrit Omarchy. Ekkert glósusafn, engar viðbætur, bara þú og orðin.

Þú ræsir Omawrite með `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) er einfalt myndvinnsluforrit sem er frábært til að klippa til, breyta stærð og gera aðrar einfaldar breytingar. Ekki búast við Photoshop-valkosti. En það er samt með Magic Wand og lög!

Þú ræsir Pinta úr forritavalmyndinni (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) er þemaforrit sem getur dregið liti út úr bakgrunnsmynd og breytt þeim í heildstætt, samræmt þema. Það er auðveldasta leiðin til að [búa til þitt eigið þema](43-making-your-own-theme.md).

Þú ræsir Aether úr forritavalmyndinni (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) lætur þig senda skrár yfir á önnur tæki á sama neti sem keyra forritið, eins og AirDrop frá Apple. Það er þó fjölpalla, svo þú getur sent skrár til og frá Windows, macOS, Android, iOS og auðvitað Linux.

Þú getur opnað Share-valmyndina með `Super + Ctrl + S` eða undir _Trigger > Share_ í Omarchy-valmyndinni. Hún gefur þér fjóra möguleika:

- **Clipboard** sendir það sem þú hefur afritað sem textaskrá. Frábært til að koma tengli eða bút í símann þinn án þess að senda sjálfum þér tölvupóst.
- **File** opnar skráarveljara þar sem þú getur valið nokkrar í einu.
- **Folder** sendir heila möppu.
- **Receive** opnar LocalSend sjálft svo annað tæki geti sent þér eitthvað.

Sama virkar úr útstöðinni með `omarchy share clipboard`, `omarchy share file [path]` og `omarchy share folder [path]`. Slepptu slóðinni og þú færð veljarann.

Þú getur líka sent beint úr skráarstjóranum: hægrismelltu á hvaða val sem er í Nautilus og veldu _Send via LocalSend_.

Eldveggur Omarchy er lokaður sjálfgefið nema fyrir gátt LocalSend, svo þetta virkar strax á nýrri uppsetningu. Sjá [öryggi](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) er heildstæður skrifstofupakki með ritvinnslu, töflureikni, kynningum, teikniforriti og fleira. Hann er samhæfur skrám frá Microsoft Office, svo þetta er frábær leið til að geta opnað þessi Word-skjöl.

Þú ræsir LibreOffice úr forritavalmyndinni (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) er ofureinfalt kynningarforrit Omarchy. Glærusafnið þitt er ein Markdown-skrá með myndum og myndböndum við hliðina: skrifaðu hverja glæru fyrir neðan lifandi forskoðun, dragðu glærurnar í röð og kynntu svo á fullum skjá eða flyttu út í PDF og PowerPoint. Það tekur meira að segja upp Omarchy-þemað þitt.

Þú ræsir Hype úr forritavalmyndinni (`Super + Space`). Ýttu á `?` inni í því til að sjá alla flýtilykla.

## Signed

[Signed](https://github.com/omacom/signed) er ofureinföld leið Omarchy til að undirrita PDF-skjöl og fylla þau út. Settu vistaða undirskriftina þína, texta og dagsetningu dagsins hvar sem er á síðu og vistaðu svo undirritað afrit við hlið upprunalega skjalsins. Sjá [Að fylla út PDF-skjöl](27-filling-out-pdfs.md) til að sjá hvernig.

Þú ræsir Signed úr forritavalmyndinni (`Super + Space`) eða opnar PDF-skjal með því úr skráarstjóranum.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) er 3D-skákleikur Omarchy sjálfs. Spilaðu við vin á sömu tölvu eða innbyggða andstæðinginn á þremur erfiðleikastigum, á fjórum mótuðum taflsettum sem hvert hreyfist á sinn hátt: sporbaugsför, útskorinn viður og fílabein, skógarverur og nammi. Leikir eru án klukku og vistast eftir hvern leik.

Þú ræsir Checkmate úr forritavalmyndinni (`Super + Space`), þar sem það er skráð sem Chess. Ýttu á `?` inni í því til að sjá alla flýtilykla.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) er ofureinfalda reiknivél Omarchy, sem opnast í fljótandi glugga.

Þú ræsir Omacalc með `Super + Shift + Q` (eða reiknivélarlyklinum, ef lyklaborðið þitt er með slíkan).

## Signal

[Signal](https://signal.org/) er frumkvöðullinn í enda-í-enda dulkóðuðum skilaboðum og frábær samskiptamöguleiki fyrir alla sem vilja frekar ekki fara í gegnum eitthvert af stóru tæknisamsteypunum.

Þú ræsir Signal með `Super + Shift + G`. Það er ekki hluti af grunnuppsetningunni, svo í fyrsta skipti sem þú ýtir á það býðst Omarchy til að setja það upp fyrir þig (það er líka undir _Install > Service_ í Omarchy-valmyndinni).

## Omaview

[Omaview](https://github.com/omacom/omaview) er ofureinfaldur myndaskoðari og margmiðlunarspilari Omarchy: einn gluggi fyrir myndirnar þínar, myndböndin og tónlistina. Opnaðu mynd og örvalyklarnir þrepa í gegnum restina af möppunni hennar, `N` og `P` gera það fyrir allt og `Ctrl + M` sýnir alla möppuna sem net reita. Hann sýnir líka HEIC-, AVIF- og JPEG XL-myndir og heldur áfram þar sem þú hættir í hverju sem er langt.

Ýttu á `F` fyrir fullan skjá, `E` til að breyta mynd í Omasnap eða klippa myndband í Omacut, `Ctrl + P` til að prenta mynd og `Delete` til að færa skrá í Trash (`Ctrl + Z` kemur henni til baka). Ýttu á `?` inni í því til að sjá alla flýtilykla.

Þú ræsir Omaview sem _Media Viewer_ úr forritavalmyndinni (`Super + Space`) eða tvísmellir bara á mynd, myndband eða lag í skráarstjóranum.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) er ofureinfaldur myndbandsklippir Omarchy. Þegar þú þarft bara að klippa upphafið og endann af klippu er það betra en að ræsa fullbúið myndvinnsluforrit.

Þú ræsir Omacut úr forritavalmyndinni (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) er ofureinfalt upptökuforrit Omarchy fyrir vefmyndavél. Veldu myndavélina þína og hljóðnemann einu sinni, ýttu svo á `Space` til að taka upp og aftur til að gera hlé og halda áfram sömu töku. Það tekur alltaf upp í hæstu upplausn myndavélarinnar þinnar, með lifandi hljóðnemamæli svo þú getir athugað hljóðstyrkinn áður en þú byrjar.

Stöðvaðu tökuna og hún opnast strax í innbyggðum klippiritli. Tvísmelltu á klippu til að skipta henni, dragðu handföngin til að klippa hvern hluta til og fjarlægðu hlutana sem þú vilt ekki. Vistaðu hana svo sem MP4. Upprunalega upptakan þín er geymd þar til þú hendir henni, svo þú getur alltaf komið til baka og klippt hana á annan hátt.

Þú ræsir Monologue úr forritavalmyndinni (`Super + Space`).
