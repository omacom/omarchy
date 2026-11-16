# Grafiskās lietotnes

## Files

Files (Nautilus) ir grafiskais failu pārvaldnieks. `Super + Shift + F` to atver, un `Super + Shift + Alt + F` to atver direktorijā, kurā atrodas jūsu terminālis, kas ietaupa daudz klikšķu. `Ctrl + L` ļauj ierakstīt ceļu, un `Space` nospiešana uz jebkura faila sniedz ātru priekšskatījumu, neko neatverot.

Pievienojiet USB atmiņu vai SD karti, un tā tiek automātiski pievienota, tāpēc vienkārši parādās sānjoslā. Sarežģītākām lietām — diska formatēšanai, SMART veselības pārbaudei, nodalījumu izveidei — palaidiet _Disks_ no lietotņu palaidēja (`Super + Space`).

Dubultklikšķis ievēro saprātīgus noklusējumus: attēli, video un mūzika atveras Omaview, PDF faili — Document Viewer, Markdown — Omawrite, bet vienkāršs teksts — redaktorā, kas izvēlēts sadaļā _Setup > Default > Editor_.

## Disktree

Kad disks piepildās un jums nav ne jausmas, kas to apēd, palaidiet [Disktree](https://github.com/tobi/disktree) no lietotņu palaidēja (`Super + Space`). Tas parāda jūsu mājas direktorijas grafisku koka karti. Lielāki bloki aizņem vairāk vietas; staigājiet pa direktorijām ar tastatūru vai peli, atzīmējiet, kam jāiet, un pārskatiet savu izvēli, pirms kaut ko izņemat. Palaidiet `disktree --disk`, lai skenētu visu disku.

## Obsidian

[Obsidian](https://obsidian.md/) ir bezmaksas un ļoti paplašināma piezīmju veikšanas lietotne, kas glabāšanai izmanto vienkāršus Markdown failus.

Obsidian ir bezmaksas visiem nolūkiem, tostarp personīgai, komerciālai un bezpeļņas lietošanai.

Obsidian piedāvā arī [komerciālu papildinājumu sinhronizācijai](https://obsidian.md/sync) ar mobilajām lietotnēm iOS un Android. (https://obsidian.md/pricing).

Obsidian palaižat ar `Super + Shift + O`. Lai izmantotu tēmu sinhronizāciju, iestatījumos jāizvēlas `Omarchy` tēma.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ir Omarchy pašas ārkārtīgi vienkāršā Markdown rakstīšanas lietotne. Nekādu krātuvju, nekādu spraudņu, tikai jūs un vārdi.

Omawrite palaižat ar `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ir vienkāršs attēlu rediģēšanas rīks, kas lieliski noder apgriešanai, izmēru maiņai un citām pamata manipulācijām. Tikai negaidiet Photoshop alternatīvu. Bet tajā joprojām ir Magic Wand un slāņi!

Pinta palaižat, izmantojot lietotņu palaidēju (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ir tēmu veidošanas lietotne, kas var iegūt krāsas no fona attēla un pārvērst tās pilnīgā, saskaņotā tēmā. Tas ir vienkāršākais veids, kā [izveidot savu tēmu](43-making-your-own-theme.md).

Aether palaižat, izmantojot lietotņu palaidēju (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) ļauj sūtīt failus uz citām ierīcēm tajā pašā tīklā, kurās darbojas šī lietotne, līdzīgi kā Apple AirDrop. Tomēr tā ir daudzplatformu, tāpēc varat sūtīt failus uz Windows, macOS, Android, iOS un, protams, Linux un no tiem.

Kopīgošanas izvēlni varat atvērt ar `Super + Ctrl + S` vai Omarchy izvēlnē sadaļā _Trigger > Share_. Tā sniedz četras iespējas:

- **Clipboard** nosūta visu jūsu kopēto kā teksta failu. Lieliski piemērots, lai saiti vai fragmentu dabūtu uz tālruni, nesūtot sev e-pastu.
- **File** atver failu atlasītāju, kurā varat izvēlēties vairākus uzreiz.
- **Folder** nosūta veselu direktoriju.
- **Receive** atver pašu LocalSend, lai cita ierīce varētu kaut ko nosūtīt jums.

Tas pats darbojas no termināļa ar `omarchy share clipboard`, `omarchy share file [path]` un `omarchy share folder [path]`. Atstājiet ceļu tukšu, un iegūsiet atlasītāju.

Varat sūtīt arī tieši no failu pārvaldnieka: ar labo pogu noklikšķiniet uz jebkuras izvēles Nautilus un izvēlieties _Send via LocalSend_.

Omarchy ugunsmūris pēc noklusējuma ir slēgts, izņemot LocalSend portu, tāpēc tas darbojas uzreiz pēc instalēšanas svaigā sistēmā. Skatiet [drošību](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ir pilnīgs biroja pakotne ar tekstapstrādi, izklājlapām, prezentācijām, zīmēšanas lietotni un vēl vairāk. Tā ir saderīga ar Microsoft Office failiem, tāpēc tas ir lielisks veids, kā varēt atvērt tos Word dokumentus.

LibreOffice palaižat, izmantojot lietotņu palaidēju (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ir Omarchy pašas ārkārtīgi vienkāršā prezentāciju lietotne. Jūsu prezentācija ir viens Markdown fails ar attēliem un video blakus: rakstiet katru slaidu zem tieša priekšskatījuma, velciet slaidus vajadzīgajā kārtībā, pēc tam prezentējiet pilnekrāna režīmā vai eksportējiet uz PDF un PowerPoint. Tā pat pārņem jūsu Omarchy tēmu.

Hype palaižat, izmantojot lietotņu palaidēju (`Super + Space`). Nospiediet `?` tajā, lai redzētu visus saīsnes taustiņus.

## Signed

[Signed](https://github.com/omacom/signed) ir Omarchy pašas ārkārtīgi vienkāršais veids, kā parakstīt PDF failus un aizpildīt tos. Novietojiet savu saglabāto parakstu, tekstu un šodienas datumu jebkurā lapas vietā, pēc tam saglabājiet parakstītu kopiju blakus oriģinālam. Skatiet [PDF aizpildīšana](27-filling-out-pdfs.md), kā to izdarīt.

Signed palaižat, izmantojot lietotņu palaidēju (`Super + Space`), vai atverat ar to PDF failu no failu pārvaldnieka.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ir Omarchy pašas ārkārtīgi vienkāršais kalkulators, kas atveras peldošā logā.

Omacalc palaižat ar `Super + Shift + Q` (vai kalkulatora taustiņu, ja jūsu tastatūrai tāds ir).

## Signal

[Signal](https://signal.org/) ir E2E šifrētas ziņojumapmaiņas pionieris un lieliska saziņas iespēja ikvienam, kurš nevēlas iet caur kādu no lielajiem tehnoloģiju konglomerātiem.

Signal palaižat ar `Super + Shift + G`. Tas nav pamata instalācijas daļa, tāpēc pirmo reizi, kad to nospiedīsiet, Omarchy piedāvās to instalēt jūsu vietā (tas ir arī Omarchy izvēlnē sadaļā _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) ir Omarchy pašas ārkārtīgi vienkāršais attēlu skatītājs un multivides atskaņotājs: viens logs jūsu fotoattēliem, video un mūzikai. Atveriet fotoattēlu, un bulttaustiņi pāriet cauri pārējiem tā mapē, `N` un `P` to dara jebkam, un `Ctrl + M` parāda visu mapi kā režģi. Tas parāda arī HEIC, AVIF un JPEG XL fotoattēlus un turpina no vietas, kur apstājāties, jebkurā garā saturā.

Nospiediet `F` pilnekrāna režīmam, `E`, lai rediģētu attēlu Omasnap vai apgrieztu video Omacut, `Ctrl + P`, lai izdrukātu attēlu, un `Delete`, lai pārvietotu failu uz Trash (`Ctrl + Z` to atgriež). Nospiediet `?` tajā, lai redzētu visus saīsnes taustiņus.

Omaview palaižat kā _Media Viewer_, izmantojot lietotņu palaidēju (`Super + Space`), vai vienkārši veiciet dubultklikšķi uz attēla, video vai dziesmas failu pārvaldniekā.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ir Omarchy pašas ārkārtīgi vienkāršais video apgriezējs. Kad jums tikai jānogriež klipa sākums un beigas, tas pārspēj pilna video redaktora palaišanu.

Omacut palaižat, izmantojot lietotņu palaidēju (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ir Omarchy pašas ārkārtīgi vienkāršais tīmekļa kameras ierakstītājs. Vienreiz izvēlieties kameru un mikrofonu, pēc tam nospiediet `Space`, lai ierakstītu, un vēlreiz, lai pauzētu un atsāktu to pašu uzņemšanu. Tas vienmēr ieraksta jūsu kameras augstākajā izšķirtspējā, ar tiešu mikrofona mērītāju, lai pirms sākšanas varētu pārbaudīt līmeņus.

Pārtrauciet uzņemšanu, un tā uzreiz atveras iebūvētā redaktorā. Veiciet dubultklikšķi uz klipa, lai to sadalītu, velciet rokturus, lai apgrieztu katru daļu, un izņemiet daļas, kuras nevēlaties. Pēc tam saglabājiet to kā MP4. Jūsu oriģinālais ieraksts tiek saglabāts, līdz to izmetat, tāpēc vienmēr varat atgriezties un sagriezt to citādi.

Monologue palaižat, izmantojot lietotņu palaidēju (`Super + Space`).
