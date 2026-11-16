# Grafísk forrit

## Files

Files (Nautilus) er grafíska skráastjórnunartólið. `Super + Shift + F` opnar það, og `Super + Shift + Alt + F` opnar það í möppunni sem útstöðin þín er í, sem sparar mikla smelli. `Ctrl + L` lætur þig slá inn slóð, og að ýta á `Space` á hvaða skrá sem er gefur þér snögga forskoðun án þess að opna neitt.

Tengdu USB-lykil eða SD-kort og það er tengt sjálfkrafa, svo það birtist bara í hliðarstikunni. Fyrir eitthvað flóknara — að forsníða drif, athuga SMART-heilsu, búa til disksneiðar — ræstu _Disks_ úr forritaræsinum (`Super + Space`).

Tvísmellt fylgir skynsamlegum sjálfgefnum stillingum: myndir, myndbönd og tónlist opnast í Omaview, PDF-skjöl í Document Viewer og venjulegur texti í Neovim.

## Disktree

Þegar drifið fyllist og þú hefur ekki hugmynd um hvað er að éta það upp, ræstu [Disktree](https://github.com/tobi/disktree) úr forritaræsinum (`Super + Space`). Það sýnir grafískt trékort af heimamöppunni þinni. Stærri reitir taka meira pláss; farðu inn í möppur með lyklaborðinu eða músinni, merktu það sem á að fara og farðu yfir valið þitt áður en þú fjarlægir nokkuð. Keyrðu `disktree --disk` til að skanna allan diskinn.

## Obsidian

[Obsidian](https://obsidian.md/) er ókeypis og mjög útvíkkanlegt glósuforrit sem notar einfaldar Markdown-skrár til geymslu.

Obsidian er ókeypis í öllum tilgangi, þar með talið til einkanota, viðskipta og starfsemi sem ekki er rekin í hagnaðarskyni.

Obsidian býður einnig upp á [viðskiptalega viðbót fyrir samstillingu](https://obsidian.md/sync) með farsímaforritum á iOS og Android. (https://obsidian.md/pricing).

Þú ræsir Obsidian með `Super + Shift + O`. Til að nota samstillingu þema verður þú að velja `Omarchy` þemað undir stillingum.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) er eigið, dauðeinfalt Markdown-ritforrit Omarchy. Engin söfn, engar viðbætur, bara þú og orðin.

Þú ræsir Omawrite með `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) er einfalt myndvinnsluforrit sem er frábært til að klippa til, breyta stærð og aðrar grunnbreytingar. Búist bara ekki við valkosti við Photoshop. En það er samt með Magic Wand og lögum!

Þú ræsir Pinta úr forritaræsinum (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) er þemaforrit sem getur dregið liti úr bakgrunnsmynd og breytt þeim í heildstætt, samræmt þema. Það er auðveldasta leiðin til að [búa til þitt eigið þema](43-making-your-own-theme.md).

Þú ræsir Aether úr forritaræsinum (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) lætur þig senda skrár til annarra tækja á sama neti sem keyra forritið, eins og AirDrop frá Apple. Það er þó fjölpalla, svo þú getur sent skrár til og frá Windows, macOS, Android, iOS og auðvitað Linux.

Þú getur opnað Share-valmyndina með `Super + Ctrl + S` eða undir _Trigger > Share_ í Omarchy-valmyndinni. Hún gefur þér fjóra valkosti:

- **Clipboard** sendir allt sem þú hefur afritað sem textaskrá. Frábært til að koma tengli eða búti á símann þinn án þess að senda sjálfum þér tölvupóst.
- **File** opnar skráaveljara þar sem þú getur valið nokkrar í einu.
- **Folder** sendir heila möppu.
- **Receive** opnar LocalSend sjálft svo annað tæki geti sent þér eitthvað.

Það sama virkar úr útstöðinni með `omarchy share clipboard`, `omarchy share file [path]` og `omarchy share folder [path]`. Slepptu slóðinni og þú færð veljarann.

Þú getur líka sent beint úr skráastjórnunartólinu: hægrismelltu á hvaða val sem er í Nautilus og veldu _Send via LocalSend_.

Eldveggur Omarchy er lokaður sjálfgefið nema fyrir gátt LocalSend, svo þetta virkar strax á nýrri uppsetningu. Sjá [öryggi](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) er heildstæður skrifstofupakki með ritvinnslu, töflureikni, kynningum, teikniforriti og fleira. Hann er samhæfur skrám frá Microsoft Office, svo þetta er frábær leið til að geta opnað þessi Word-skjöl.

Þú ræsir LibreOffice úr forritaræsinum (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) er eigið, dauðeinfalt kynningarforrit Omarchy. Glærusafnið þitt er ein Markdown-skrá með myndum sínum og myndböndum við hliðina: skrifaðu hverja glæru fyrir neðan lifandi forskoðun, dragðu glærur í röð, kynntu síðan í fullum skjá eða flyttu út í PDF og PowerPoint. Það tekur meira að segja upp Omarchy-þemað þitt.

Þú ræsir Hype úr forritaræsinum (`Super + Space`). Ýttu á `?` inni í því til að sjá alla flýtilykla.

## Signed

[Signed](https://github.com/omacom/signed) er eigið, dauðeinfalt tól Omarchy til að undirrita PDF-skjöl og fylla þau út. Settu vistaða undirskriftina þína, texta og dagsetningu dagsins hvar sem er á síðu, vistaðu síðan undirritað afrit við hlið frumritsins. Sjá [Að fylla út PDF-skjöl](27-filling-out-pdfs.md) fyrir leiðbeiningar um það.

Þú ræsir Signed úr forritaræsinum (`Super + Space`), eða opnar PDF-skjal með því úr skráastjórnunartólinu.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) er eigið, dauðeinfalt reiknivélarforrit Omarchy, sem opnast í fljótandi glugga.

Þú ræsir Omacalc með `Super + Shift + Q` (eða reiknivélarlyklinum, ef lyklaborðið þitt er með slíkan).

## Signal

[Signal](https://signal.org/) er frumkvöðullinn í E2E-dulkóðuðum skilaboðum og frábær samskiptamöguleiki fyrir alla sem vilja frekar ekki fara í gegnum eitthvert af stóru tæknifyrirtækjunum.

Þú ræsir Signal með `Super + Shift + G`. Það er ekki hluti af grunnuppsetningunni, svo í fyrsta skipti sem þú ýtir á það býður Omarchy upp á að setja það upp fyrir þig (það er líka undir _Install > Service_ í Omarchy-valmyndinni).

## Omaview

[Omaview](https://github.com/omacom/omaview) er eigið, dauðeinfalt myndaskoðunar- og margmiðlunarspilaraforrit Omarchy: einn gluggi fyrir ljósmyndirnar þínar, myndbönd og tónlist. Opnaðu ljósmynd og örvatakkarnir færa þig í gegnum restina af möppunni hennar, `N` og `P` gera það fyrir hvað sem er, og `Ctrl + M` sýnir alla möppuna sem hnitanet. Það sýnir líka HEIC-, AVIF- og JPEG XL-ljósmyndir og heldur áfram þar sem frá var horfið í öllu löngu.

Ýttu á `F` fyrir fullan skjá, `E` til að breyta mynd í Omasnap eða klippa myndband til í Omacut, `Ctrl + P` til að prenta mynd og `Delete` til að færa skrá í ruslið (`Ctrl + Z` kemur henni til baka). Ýttu á `?` inni í því til að sjá alla flýtilykla.

Þú ræsir Omaview sem _Media Viewer_ úr forritaræsinum (`Super + Space`), eða tvísmellir bara á mynd, myndband eða lag í skráastjórnunartólinu.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) er eigið, dauðeinfalt myndbandsklippiforrit Omarchy. Þegar allt sem þú þarft er að klippa byrjunina og endann af klippu slær það því að ræsa fullbúið myndbandsvinnsluforrit.

Þú ræsir Omacut úr forritaræsinum (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) er eigið, dauðeinfalt vefmyndavélaupptökuforrit Omarchy. Veldu myndavélina þína og hljóðnemann einu sinni, ýttu síðan á `Space` til að taka upp og aftur til að gera hlé og halda áfram með sömu töku. Það tekur alltaf upp í hæstu upplausn myndavélarinnar þinnar, með lifandi hljóðnemamæli svo þú getir athugað hljóðstyrkinn áður en þú byrjar.

Stöðvaðu tökuna og hún opnast strax í innbyggðu klippiforriti. Tvísmelltu á klippu til að skipta henni, dragðu handföngin til að klippa hvern hluta til og fjarlægðu hlutana sem þú vilt ekki. Vistaðu hana síðan sem MP4. Upprunalega upptakan þín er geymd þar til þú fleygir henni, svo þú getur alltaf komið til baka og klippt hana öðruvísi.

Þú ræsir Monologue úr forritaræsinum (`Super + Space`).
