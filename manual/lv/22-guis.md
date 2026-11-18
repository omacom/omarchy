# GUIs

## Files

Files (Nautilus) ir grafiskais failu pārvaldnieks. `Super + Shift + F` to atver, un `Super + Shift + Alt + F` to atver direktorijā, kurā atrodas jūsu terminālis, kas ietaupa daudz klikšķu. `Ctrl + L` ļauj ierakstīt ceļu, un, nospiežot `Space` uz jebkura faila, iegūstat ātru priekšskatījumu, neko neatverot.

Pievienojiet USB atmiņu vai SD karti, un tā tiek montēta automātiski, tāpēc tā vienkārši parādās sānjoslā. Sarežģītākiem darbiem — diska formatēšanai, SMART veselības pārbaudei, nodalījumu izveidei — palaidiet _Disks_ no lietotņu palaidēja (`Super + Space`).

Dubultklikšķis ievēro saprātīgus noklusējumus: attēli, video un mūzika atveras Omaview, PDF faili — Document Viewer, Markdown — Omawrite, bet vienkāršs teksts — redaktorā, kas izvēlēts sadaļā _Setup > Default > Editor_.

## Disktree

Kad disks piepildās un jums nav ne jausmas, kas to apēd, palaidiet [Disktree](https://github.com/tobi/disktree) no lietotņu palaidēja (`Super + Space`). Tas parāda jūsu mājas direktorijas grafisku kokveida karti. Lielāki bloki aizņem vairāk vietas; pārvietojieties pa direktorijām ar tastatūru vai peli, atzīmējiet, kam jāiet, un pārskatiet savu izvēli, pirms kaut ko izņemat. Palaidiet `disktree --disk`, lai skenētu visu disku.

## Obsidian

[Obsidian](https://obsidian.md/) ir bezmaksas un ļoti paplašināma piezīmju veikšanas lietotne, kas glabāšanai izmanto vienkāršus Markdown failus.

Obsidian ir bez maksas visiem mērķiem, tostarp personīgai, komerciālai un bezpeļņas lietošanai.

Obsidian piedāvā arī [komerciālu sinhronizācijas papildinājumu](https://obsidian.md/sync) ar mobilajām lietotnēm iOS un Android ierīcēs. (https://obsidian.md/pricing).

Obsidian palaižat ar `Super + Shift + O`. Lai izmantotu tēmu sinhronizāciju, iestatījumos jāizvēlas `Omarchy` tēma.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ir Omarchy paša pavisam vienkāršā Markdown rakstīšanas lietotne. Nekādu krātuvju, nekādu spraudņu, tikai jūs un vārdi.

Omawrite palaižat ar `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ir vienkāršs attēlu rediģēšanas rīks, kas lieliski noder apgriešanai, izmēru mainīšanai un citām pamata manipulācijām. Tikai negaidiet Photoshop alternatīvu. Bet tajā tomēr ir Magic Wand un slāņi!

Pinta palaižat, izmantojot lietotņu palaidēju (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ir tēmu lietotne, kas var iegūt krāsas no fona attēla un pārvērst tās pilnīgā, vienotā tēmā. Tas ir vienkāršākais veids, kā [izveidot savu tēmu](43-making-your-own-theme.md).

Aether palaižat, izmantojot lietotņu palaidēju (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) ļauj sūtīt failus uz citām ierīcēm tajā pašā tīklā, kurās darbojas šī lietotne, līdzīgi kā Apple AirDrop. Tomēr tā ir starpplatformu, tāpēc varat sūtīt failus uz un no Windows, macOS, Android, iOS un, protams, Linux.

Share izvēlni varat atvērt ar `Super + Ctrl + S` vai sadaļā _Trigger > Share_ Omarchy izvēlnē. Tā piedāvā četras iespējas:

- **Clipboard** nosūta visu, ko esat nokopējis, kā teksta failu. Lieliski, lai saiti vai fragmentu nogādātu tālrunī, nesūtot sev e-pastu.
- **File** atver failu izvēlni, kurā varat izvēlēties vairākus uzreiz.
- **Folder** nosūta veselu direktoriju.
- **Receive** atver pašu LocalSend, lai cita ierīce varētu kaut ko nosūtīt jums.

Tas pats darbojas arī no termināļa ar `omarchy share clipboard`, `omarchy share file [path]` un `omarchy share folder [path]`. Izlaidiet ceļu, un iegūsit izvēlni.

Varat sūtīt arī tieši no failu pārvaldnieka: ar labo pogu noklikšķiniet uz jebkuras izvēles Nautilus un izvēlieties _Send via LocalSend_.

Omarchy ugunsmūris pēc noklusējuma ir slēgts, izņemot LocalSend portu, tāpēc tas darbojas uzreiz pēc svaigas instalēšanas. Skatiet [drošība](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ir pilnīgs biroja pakotnes komplekts ar tekstapstrādi, izklājlapām, prezentācijām, zīmēšanas lietotni un vēl daudz ko citu. Tas ir saderīgs ar Microsoft Office failiem, tāpēc tas ir lielisks veids, kā varēt atvērt tos Word dokumentus.

LibreOffice palaižat, izmantojot lietotņu palaidēju (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ir Omarchy paša pavisam vienkāršā prezentāciju lietotne. Jūsu prezentācija ir viens Markdown fails ar attēliem un video blakus tam: rakstiet katru slaidu zem tiešā priekšskatījuma, velciet slaidus vajadzīgajā secībā, pēc tam prezentējiet pilnekrāna režīmā vai eksportējiet uz PDF un PowerPoint. Tā pat uztver jūsu Omarchy tēmu.

Hype palaižat, izmantojot lietotņu palaidēju (`Super + Space`). Nospiediet `?` tajā, lai redzētu visus īsinājumtaustiņus.

## Signed

[Signed](https://github.com/omacom/signed) ir Omarchy paša pavisam vienkāršais veids, kā parakstīt PDF failus un tos aizpildīt. Novietojiet savu saglabāto parakstu, tekstu un šodienas datumu jebkurā lapas vietā, pēc tam saglabājiet parakstītu kopiju blakus oriģinālam. Skatiet [PDF aizpildīšana](27-filling-out-pdfs.md), lai uzzinātu, kā.

Signed palaižat, izmantojot lietotņu palaidēju (`Super + Space`), vai atveriet ar to PDF failu no failu pārvaldnieka.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) ir Omarchy paša 3D šaha spēle. Spēlējiet ar draugu uz tā paša datora vai pret iebūvēto pretinieku trīs līmeņos, ar četriem veidotu figūru komplektiem, kas katrs pārvietojas savā veidā: orbitālie kosmosa kuģi, grebts koks un ziloņkauls, meža radības un konfektes. Spēlēm nav pulksteņa, un tās saglabājas pēc katra gājiena.

Checkmate palaižat, izmantojot lietotņu palaidēju (`Super + Space`), kur tas ir norādīts kā Chess. Nospiediet `?` tajā, lai redzētu visus īsinājumtaustiņus.

## Cards

[Cards](https://github.com/omacom/cards) ir Omarchy paša Klondike pasjanss. Ņemiet pa trim, bez ierobežojuma tam, cik reižu varat iet cauri kavai, četrās kāršu sērijās: viena uzzīmēta jūsu tēmas krāsās un trīs ar savu izskatu. Noklikšķiniet uz kārts un pēc tam uz vietu, kur tai jādodas, velciet to vai veiciet dubultklikšķi, lai nosūtītu to uz labāko vietu. Spēles saglabājas pēc katra gājiena.

Cards palaižat, izmantojot lietotņu palaidēju (`Super + Space`). Noklikšķiniet uz tā nosaukuma vai nospiediet `?`, lai redzētu visus īsinājumtaustiņus.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ir Omarchy paša pavisam vienkāršais kalkulators, kas atveras peldošā logā.

Omacalc palaižat ar `Super + Shift + Q` (vai kalkulatora taustiņu, ja jūsu tastatūrai tāds ir).

## Signal

[Signal](https://signal.org/) ir E2E šifrētas ziņapmaiņas pionieris un lieliska saziņas iespēja ikvienam, kurš nevēlas iet caur kādu no lielajiem tehnoloģiju konglomerātiem.

Signal palaižat ar `Super + Shift + G`. Tas nav daļa no pamata instalācijas, tāpēc pirmajā reizē, kad to nospiedīsit, Omarchy piedāvās to instalēt jūsu vietā (tas ir arī sadaļā _Install > Service_ Omarchy izvēlnē).

## Omaview

[Omaview](https://github.com/omacom/omaview) ir Omarchy paša pavisam vienkāršais attēlu skatītājs un multivides atskaņotājs: viens logs jūsu fotoattēliem, video un mūzikai. Atveriet fotoattēlu, un bulttaustiņi pāriet cauri pārējiem tās mapes failiem, `N` un `P` to dara jebkam, un `Ctrl + M` parāda visu mapi kā režģi. Tas rāda arī HEIC, AVIF un JPEG XL fotoattēlus, un garos ierakstos turpina no vietas, kur jūs apstājāties.

Nospiediet `F`, lai ieslēgtu pilnekrāna režīmu, `E`, lai rediģētu attēlu Omasnap vai apgrieztu video Omacut, `Ctrl + P`, lai izdrukātu attēlu, un `Delete`, lai pārvietotu failu uz Trash (`Ctrl + Z` to atgriež). Nospiediet `?` tajā, lai redzētu visus īsinājumtaustiņus.

Omaview palaižat kā _Media Viewer_, izmantojot lietotņu palaidēju (`Super + Space`), vai vienkārši veiciet dubultklikšķi uz attēla, video vai dziesmas failu pārvaldniekā.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ir Omarchy paša pavisam vienkāršais video apgriešanas rīks. Kad jums tikai vajag nogriezt klipa sākumu un beigas, tas pārspēj pilna video redaktora palaišanu.

Omacut palaižat, izmantojot lietotņu palaidēju (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ir Omarchy paša pavisam vienkāršais tīmekļa kameras ierakstītājs. Vienreiz izvēlieties kameru un mikrofonu, pēc tam nospiediet `Space`, lai ierakstītu, un vēlreiz, lai pauzētu un atsāktu to pašu uzņemšanu. Tas vienmēr ieraksta jūsu kameras augstākajā izšķirtspējā, ar tiešo mikrofona līmeņa mērītāju, lai jūs varētu pārbaudīt līmeņus pirms sākšanas.

Apturiet uzņemšanu, un tā uzreiz atveras iebūvētajā redaktorā. Veiciet dubultklikšķi uz klipa, lai to sadalītu, velciet rokturus, lai apgrieztu katru daļu, un izņemiet daļas, kuras nevēlaties. Pēc tam saglabājiet to kā MP4. Jūsu oriģinālais ieraksts tiek saglabāts, līdz jūs to izmetat, tāpēc vienmēr varat atgriezties un sagriezt to citādi.

Monologue palaižat, izmantojot lietotņu palaidēju (`Super + Space`).
