# GUIs

## Skrár

Files (Folio) er myndræni skráarstjórinn. `Super + Shift + F` opnar hann og `Super + Shift + Alt + F` opnar hann í möppunni sem útstöðin þín er í, sem sparar mikið klikk. `Ctrl + L` gerir þér kleift að slá inn slóð og með því að ýta á `Space` á einhverja skrá forskoðarðu hana í fullri stærð án þess að opna hana.

Stingdu USB-minnislykli eða SD-korti í samband og það er tengt sjálfkrafa, svo það birtist bara í hliðarstikunni. Fyrir eitthvað umfangsmeira — að forsníða drif, athuga SMART-heilsu, búa til disksneiðar — skaltu ræsa _Disks_ úr forritaræsinum (`Super + Space`).

Dulritað drif biður um lykilorðið sitt þegar því er stungið í samband. Til að láta eitt opnast sjálfkrafa skaltu bæta lykilskrá við það með `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` og setja þá lykilskrá í `~/.config/omarchy/drive-keys/<UUID>`, nefnda eftir UUID-inu sem `lsblk -dno UUID /dev/sdX1` prentar fyrir dulrituðu disksneiðina, og aðeins læsilega af þér (`chmod 600`). Ef sú lykilskrá vantar eða henni er hafnað er beðið um lykilorðið eins og venjulega.

Tvísmellir fylgja skynsamlegum sjálfgefnum stillingum: myndir, myndbönd og tónlist opnast í Omaview, PDF-skjöl í Document Viewer, Markdown í Omawrite og venjulegur texti í ritlinum þínum, Plain nema þú veljir annan undir _Setup > Defaults > Editor_.

## Disktree

Þegar drifið fyllist og þú hefur ekki hugmynd um hvað er að éta það skaltu ræsa [Disktree](https://github.com/tobi/disktree) úr forritaræsinum (`Super + Space`). Það sýnir myndrænt trékort af heimamöppunni þinni. Stærri reitir taka meira pláss; farðu inn í möppur með lyklaborðinu eða músinni, merktu það sem á að fara og farðu yfir valið þitt áður en þú fjarlægir eitthvað. Keyrðu `disktree --disk` til að skanna allan diskinn.

## Obsidian

[Obsidian](https://obsidian.md/) er ókeypis og mjög útvíkkanlegt minnisforrit sem notar einfaldar Markdown-skrár til geymslu.

Obsidian er ókeypis í öllum tilgangi, þar á meðal til einkanota, viðskipta og fyrir félagasamtök án gróðamarkmiðs.

Obsidian býður einnig upp á [viðskiptalega viðbót fyrir samstillingu](https://obsidian.md/sync) við farsímaforrit á iOS og Android. (https://obsidian.md/pricing).

Þú ræsir Obsidian með `Super + Shift + O`. Til að nota samstillingu þema verður þú að velja `Omarchy`-þemað í stillingunum.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) er bráðeinfalt Markdown-ritunarforrit frá Omarchy sjálfu. Engar hvelfingar, engar viðbætur, bara þú og orðin.

Þú ræsir Omawrite með `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) er einfalt myndvinnslutól sem er frábært til að klippa til, breyta stærð og framkvæma aðrar grunnbreytingar. Búist bara ekki við valkosti við Photoshop. En það er samt með Magic Wand og lög!

Þú ræsir Pinta í gegnum forritaræsinn (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) er þemaforrit sem getur dregið liti úr bakgrunnsmynd og breytt þeim í heildstætt, samræmt þema. Það er auðveldasta leiðin til að [búa til þitt eigið þema](43-making-your-own-theme.md).

Þú ræsir Aether í gegnum forritaræsinn (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) gerir þér kleift að senda skrár í önnur tæki á sama neti sem keyra forritið, eins og AirDrop frá Apple. Það virkar þó á mörgum kerfum, svo þú getur sent skrár til og frá Windows, macOS, Android, iOS og auðvitað Linux.

Þú getur opnað Share-valmyndina með `Super + Ctrl + S` eða undir _Trigger > Share_ í Omarchy-valmyndinni. Hún gefur þér fjóra valkosti:

- **Clipboard** sendir allt sem þú hefur afritað sem textaskrá. Frábært til að koma tengli eða búti í símann þinn án þess að senda sjálfum þér tölvupóst.
- **File** opnar skráaveljara þar sem þú getur valið nokkrar í einu.
- **Folder** sendir heila möppu.
- **Receive** opnar LocalSend sjálft svo annað tæki geti sent þér eitthvað.

Sama hluturinn virkar úr útstöðinni með `omarchy share clipboard`, `omarchy share file [path]` og `omarchy share folder [path]`. Slepptu slóðinni og þú færð veljarann.

Þú getur líka sent beint úr skráarstjóranum: hægrismelltu á eitthvað val í Files og deildu því með LocalSend.

Eldveggur Omarchy er lokaður sjálfgefið nema fyrir gátt LocalSend, svo þetta virkar beint úr kassanum á nýrri uppsetningu. Sjá [öryggi](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) er heildstæður skrifstofupakki með ritvinnsluforriti, töflureikni, kynningum, teikniforriti og fleira. Hann er samhæfur skrám frá Microsoft Office, svo þetta er frábær leið til að geta opnað þessi Word-skjöl.

Þú ræsir LibreOffice í gegnum forritaræsinn (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) er bráðeinfalt kynningarforrit frá Omarchy sjálfu. Glærupakkinn þinn er ein Markdown-skrá með myndunum og myndböndunum við hliðina: skrifaðu hverja glæru fyrir neðan lifandi forskoðun, dragðu glærurnar í röð og kynntu síðan á fullum skjá eða fluttu út í PDF og PowerPoint. Það tekur meira að segja upp Omarchy-þemað þitt.

Þú ræsir Hype í gegnum forritaræsinn (`Super + Space`). Ýttu á `?` inni í því til að sjá alla flýtilykla.

## Signed

[Signed](https://github.com/omacom/signed) er bráðeinföld leið Omarchy sjálfs til að undirrita PDF-skjöl og fylla þau út. Settu vistaða undirskriftina þína, texta og dagsetninguna í dag hvar sem er á síðu og vistaðu síðan undirritað eintak við hlið upprunalega eintaksins. Sjá [Að fylla út PDF-skjöl](27-filling-out-pdfs.md) til að sjá hvernig.

Þú ræsir Signed í gegnum forritaræsinn (`Super + Space`) eða opnar PDF-skjal með því úr skráarstjóranum.

## Game Vibes

Game Vibes, í forritaræsinum (`Super + Space`), er þar sem litlu leikirnir frá Omarchy búa: Checkmate, þrívíður skákleikur á móti vini eða innbyggða andstæðingnum; Cards, Klondike-kaball; Death Wish, pixla-nákvæmur platformleikur með tíu herbergjum fullum af göddum og sögum; og Neon Swarm, arkade-skotleikur. Hver þeirra er ein vefsíða sem fylgir þemanu þínu. Veldu einn með örvunum og `Enter` og farðu aftur í listann með `Esc` af titilskjá leiks eða `Q` á meðan hann er í hléi. Hann opnast á fullum skjá: `Super + F` gerir hann að glugga og `Super + W` lokar honum.

Leikirnir sem þú býrð til með umboðsmanni birtast hér líka: veldu _Make something cool → Game_ í umboðsmannaspjaldinu og lýstu einum, eða nefndu leik sem er þegar í Game Vibes til að halda áfram að vinna í honum. Umboðsmaðurinn afritar hann í `~/Games/vibes`, þar sem hann er þinn til að breyta, og opnar hann þegar hann er búinn. Þú getur búið til það afrit á eigin spýtur með `omarchy games vibes copy <game>`. Leikur sem einhver annar deilir setur þú upp eins og þema: veldu _Install > Gaming > Game Vibes_ og límdu git-slóð hans, eða keyrðu `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ fjarlægir einn aftur og _Update > Game Vibes Games_ sækir nýjar útgáfur. Leikir hlaða three.js af vefnum, svo þeir þurfa nettengingu til að hefjast.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) er bráðeinfaldur reiknivél frá Omarchy sjálfu, sem opnast í fljótandi glugga.

Þú ræsir Omacalc með `Super + Shift + Q` (eða reiknivélarlyklinum, ef lyklaborðið þitt er með einn slíkan).

## Signal

[Signal](https://signal.org/) er frumkvöðull E2E-dulritaðra skilaboða og frábær samskiptamöguleiki fyrir alla sem vilja helst ekki fara í gegnum eina af stóru tæknisamsteypunum.

Þú ræsir Signal með `Super + Shift + G`. Hann er ekki hluti af grunnuppsetningunni, svo í fyrsta skipti sem þú ýtir á það býður Omarchy þér að setja hann upp fyrir þig (hann er líka undir _Install > Service_ í Omarchy-valmyndinni).

## Omaview

[Omaview](https://github.com/omacom/omaview) er bráðeinfaldur myndaskoðari og margmiðlunarspilari frá Omarchy sjálfu: einn gluggi fyrir ljósmyndirnar þínar, myndböndin og tónlistina. Opnaðu ljósmynd og örvalyklarnir færa þig í gegnum afganginn af möppunni hennar, `N` og `P` gera það fyrir allt og `Ctrl + M` sýnir alla möppuna sem yfirlitsrist. Hann sýnir líka HEIC-, AVIF- og JPEG XL-ljósmyndir og heldur áfram þar sem þú hættir í hverju sem er löngu.

Ýttu á `F` fyrir fullan skjá, `E` til að breyta mynd í Omasnap eða klippa myndband í Omacut, `Ctrl + P` til að prenta mynd og `Delete` til að færa skrá í Trash (`Ctrl + Z` færir hana til baka). Ýttu á `?` inni í honum til að sjá alla flýtilykla.

Þú ræsir Omaview sem _Media Viewer_ í gegnum forritaræsinn (`Super + Space`) eða tvísmellir bara á mynd, myndband eða lag í skráarstjóranum.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) er bráðeinfaldur myndbandsklippir frá Omarchy sjálfu. Þegar allt sem þú þarft er að klippa byrjunina og endann af klippu er hann miklu betri en að ræsa fullbúinn myndbandsritil.

Þú ræsir Omacut í gegnum forritaræsinn (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) er bráðeinfaldur vefmyndavélarupptökumaður frá Omarchy sjálfu. Veldu myndavélina og hljóðnemann einu sinni, ýttu síðan á `Space` til að taka upp og aftur til að gera hlé og halda sömu töku áfram. Hann tekur alltaf upp í hæstu upplausn myndavélarinnar, með lifandi hljóðnemamæli svo þú getir athugað hljóðstyrkinn áður en þú byrjar.

Stöðvaðu tökuna og hún opnast strax í innbyggðum ritli. Tvísmelltu á klippu til að skipta henni, dragðu handföngin til að klippa hvern hluta til og fjarlægðu hlutana sem þú vilt ekki. Vistaðu hana síðan sem MP4. Upprunalega upptakan þín er geymd þar til þú hentir henni, svo þú getur alltaf komið til baka og klippt hana öðruvísi.

Þú ræsir Monologue í gegnum forritaræsinn (`Super + Space`).
