# Grafiskās saskarnes

## Files

Files (Nautilus) ir grafiskais failu pārvaldnieks. `Super + Shift + F` to atver, un `Super + Shift + Alt + F` to atver direktorijā, kurā pašlaik atrodas jūsu terminālis, kas ietaupa daudz klikšķu. `Ctrl + L` ļauj ierakstīt ceļu, un, nospiežot `Space` uz jebkura faila, iegūstat ātru priekšskatījumu, neko neatverot.

Pieslēdziet USB atmiņu vai SD karti, un tā tiek automātiski piemontēta, tāpēc vienkārši parādās sānjoslā. Sarežģītākām darbībām — diska formatēšanai, SMART veselības pārbaudei, partīciju izveidei — palaidiet _Disks_ no lietotņu palaidēja (`Super + Space`).

Dubultklikšķis ievēro saprātīgus noklusējumus: attēli, video un mūzika atveras Omaview, PDF faili — Document Viewer, Markdown — Omawrite, un vienkāršs teksts — redaktorā, kas izvēlēts _Setup > Default > Editor_.

## Disktree

Kad disks piepildās un jums nav ne jausmas, kas to apēd, palaidiet [Disktree](https://github.com/tobi/disktree) no lietotņu palaidēja (`Super + Space`). Tas parāda jūsu mājas direktorijas grafisku kokveida karti. Lielāki bloki aizņem vairāk vietas; pārvietojieties pa direktorijām ar tastatūru vai peli, atzīmējiet, kam jāiet prom, un pārskatiet savu izvēli pirms jebkā dzēšanas. Palaidiet `disktree --disk`, lai skenētu visu disku.

## Obsidian

[Obsidian](https://obsidian.md/) ir bezmaksas un ļoti paplašināma piezīmju lietotne, kas glabāšanai izmanto vienkāršus Markdown failus.

Obsidian ir bezmaksas visiem mērķiem, tostarp personīgai, komerciālai un bezpeļņas lietošanai.

Obsidian piedāvā arī [komerciālu papildinājumu sinhronizēšanai](https://obsidian.md/sync) ar mobilajām lietotnēm iOS un Android ierīcēs. (https://obsidian.md/pricing).

Jūs palaižat Obsidian ar `Super + Shift + O`. Lai izmantotu tēmu sinhronizēšanu, iestatījumos jāizvēlas `Omarchy` tēma.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ir Omarchy paša pavisam vienkāršā Markdown rakstīšanas lietotne. Nekādu krātuvju, nekādu spraudņu, tikai jūs un vārdi.

Jūs palaižat Omawrite ar `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ir vienkāršs attēlu rediģēšanas rīks, kas ir lieliski piemērots apgriešanai, izmēra maiņai un citām pamata manipulācijām. Tikai negaidiet Photoshop alternatīvu. Bet tajā joprojām ir Magic Wand un slāņi!

Jūs palaižat Pinta ar lietotņu palaidēju (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ir tematizēšanas lietotne, kas var iegūt krāsas no fona attēla un pārvērst tās pilnīgā, vienotā tēmā. Tas ir vienkāršākais veids, kā [izveidot savu tēmu](43-making-your-own-theme.md).

Jūs palaižat Aether ar lietotņu palaidēju (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) ļauj sūtīt failus uz citām ierīcēm tajā pašā tīklā, kurās darbojas šī lietotne, līdzīgi Apple AirDrop. Tomēr tā ir starpplatformu, tāpēc varat sūtīt failus uz un no Windows, macOS, Android, iOS un, protams, Linux.

Kopīgošanas izvēlni varat atvērt ar `Super + Ctrl + S` vai Omarchy izvēlnē zem _Trigger > Share_. Tā piedāvā četras iespējas:

- **Clipboard** nosūta visu, ko esat nokopējis, kā teksta failu. Lieliski piemērots, lai dabūtu saiti vai fragmentu uz tālruni, nesūtot sev e-pastu.
- **File** atver failu atlasītāju, kurā varat atlasīt vairākus vienlaikus.
- **Folder** nosūta visu direktoriju.
- **Receive** atver pašu LocalSend, lai cita ierīce varētu jums kaut ko nosūtīt.

Tas pats darbojas arī no termināļa ar `omarchy share clipboard`, `omarchy share file [path]` un `omarchy share folder [path]`. Izlaidiet ceļu, un iegūsiet atlasītāju.

Varat arī sūtīt tieši no failu pārvaldnieka: ar labo pogu noklikšķiniet uz jebkuras atlases Nautilus un izvēlieties _Send via LocalSend_.

Omarchy ugunsmūris pēc noklusējuma ir slēgts, izņemot LocalSend portu, tāpēc tas darbojas uzreiz pēc svaigas instalēšanas. Skatiet [drošību](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ir pilnīga biroja pakotne ar tekstapstrādi, izklājlapām, prezentācijām, zīmēšanas lietotni un vēl daudz ko citu. Tā ir saderīga ar Microsoft Office failiem, tāpēc tas ir lielisks veids, kā varēt atvērt tos Word dokumentus.

Jūs palaižat LibreOffice ar lietotņu palaidēju (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ir Omarchy paša pavisam vienkāršā prezentāciju lietotne. Jūsu prezentācija ir viens Markdown fails ar attēliem un video blakus tam: rakstiet katru slaidu zem tiešā priekšskatījuma, velciet slaidus vajadzīgajā secībā, pēc tam prezentējiet pilnekrāna režīmā vai eksportējiet uz PDF un PowerPoint. Tā pat pārņem jūsu Omarchy tēmu.

Jūs palaižat Hype ar lietotņu palaidēju (`Super + Space`). Nospiediet `?` tajā, lai redzētu visus īsinājumtaustiņus.

## Signed

[Signed](https://github.com/omacom/signed) ir Omarchy paša pavisam vienkāršais veids, kā parakstīt PDF failus un tos aizpildīt. Novietojiet savu saglabāto parakstu, tekstu un šodienas datumu jebkurā lapas vietā, pēc tam saglabājiet parakstītu kopiju blakus oriģinālam. Skatiet [PDF failu aizpildīšana](27-filling-out-pdfs.md), lai uzzinātu, kā.

Jūs palaižat Signed ar lietotņu palaidēju (`Super + Space`) vai atveriet ar to PDF failu no failu pārvaldnieka.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) ir Omarchy paša 3D šaha spēle. Spēlējiet ar draugu uz tā paša datora vai ar iebūvēto pretinieku trijos līmeņos, ar četriem skulpturāliem komplektiem, kas katrs pārvietojas savā veidā: orbitālie lidaparāti, grebts koks un ziloņkauls, meža radības un konfektes. Spēlēm nav pulksteņa, un tās saglabājas pēc katra gājiena.

Jūs palaižat Checkmate ar lietotņu palaidēju (`Super + Space`), kur tā ir norādīta kā Chess. Nospiediet `?` tajā, lai redzētu visus īsinājumtaustiņus.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ir Omarchy paša pavisam vienkāršais kalkulators, kas atveras peldošā logā.

Jūs palaižat Omacalc ar `Super + Shift + Q` (vai kalkulatora taustiņu, ja jūsu tastatūrai tāds ir).

## Signal

[Signal](https://signal.org/) ir E2E šifrētās ziņojumapmaiņas pionieris un lieliska saziņas iespēja ikvienam, kurš labprātāk neietu caur kādu no lielajiem tehnoloģiju konglomerātiem.

Jūs palaižat Signal ar `Super + Shift + G`. Tas nav daļa no pamata instalācijas, tāpēc pirmo reizi, kad nospiedīsiet šo kombināciju, Omarchy piedāvās to instalēt jūsu vietā (tas ir arī Omarchy izvēlnē zem _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) ir Omarchy paša pavisam vienkāršais attēlu skatītājs un multivides atskaņotājs: viens logs jūsu fotoattēliem, video un mūzikai. Atveriet fotoattēlu, un bulttaustiņi pāriet cauri pārējiem tā mapes failiem, `N` un `P` dara to jebkam, un `Ctrl + M` parāda visu mapi kā režģi. Tas parāda arī HEIC, AVIF un JPEG XL fotoattēlus un jebkurā garā saturā turpina no vietas, kur apstājāties.

Nospiediet `F`, lai ieslēgtu pilnekrāna režīmu, `E`, lai rediģētu attēlu Omasnap vai apgrieztu video Omacut, `Ctrl + P`, lai izdrukātu attēlu, un `Delete`, lai pārvietotu failu uz Trash (`Ctrl + Z` to atgriež). Nospiediet `?` tajā, lai redzētu visus īsinājumtaustiņus.

Jūs palaižat Omaview kā _Media Viewer_ ar lietotņu palaidēju (`Super + Space`) vai vienkārši veiciet dubultklikšķi uz attēla, video vai dziesmas failu pārvaldniekā.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ir Omarchy paša pavisam vienkāršais video apgriešanas rīks. Kad jums tikai vajag nogriezt klipa sākumu un beigas, tas ir krietni ērtāk nekā vērt vaļā pilnu video redaktoru.

Jūs palaižat Omacut ar lietotņu palaidēju (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ir Omarchy paša pavisam vienkāršais tīmekļa kameras ierakstītājs. Izvēlieties kameru un mikrofonu vienu reizi, pēc tam nospiediet `Space`, lai ierakstītu, un vēlreiz, lai pauzētu un atsāktu to pašu uzņemšanu. Tas vienmēr ieraksta jūsu kameras augstākajā izšķirtspējā, ar tiešo mikrofona līmeņa mērītāju, lai pirms sākšanas varētu pārbaudīt līmeņus.

Beidziet uzņemšanu, un tas uzreiz atveras iebūvētā redaktorā. Veiciet dubultklikšķi uz klipa, lai to sadalītu, velciet rokturus, lai apgrieztu katru gabalu, un noņemiet daļas, kuras nevēlaties. Pēc tam saglabājiet to kā MP4. Jūsu oriģinālais ieraksts tiek saglabāts, līdz to izmetat, tāpēc vienmēr varat atgriezties un sagriezt to citādi.

Jūs palaižat Monologue ar lietotņu palaidēju (`Super + Space`).
