# Grafiskās saskarnes

## Files

Files (Nautilus) ir grafiskais failu pārvaldnieks. `Super + Shift + F` to atver, un `Super + Shift + Alt + F` to atver direktorijā, kurā atrodas jūsu terminālis, kas ietaupa daudz klikšķināšanas. `Ctrl + L` ļauj ierakstīt ceļu, un `Space` nospiešana uz jebkura faila sniedz ātru priekšskatījumu, neko neatverot.

Pievienojiet USB atmiņu vai SD karti, un tā tiek piemontēta automātiski, tāpēc vienkārši parādās sānjoslā. Kam sarežģītākam — diska formatēšanai, SMART veselības pārbaudei, nodalījumu izveidei — palaidiet _Disks_ no lietotņu palaidēja (`Super + Space`).

Dubultklikšķis ievēro saprātīgus noklusējumus: attēli, video un mūzika atveras Omaview, PDF Document Viewer, Markdown Omawrite un vienkāršs teksts redaktorā, kas izvēlēts sadaļā _Setup > Default > Editor_.

## Disktree

Kad disks piepildās un jums nav ne jausmas, kas to apēd, palaidiet [Disktree](https://github.com/tobi/disktree) no lietotņu palaidēja (`Super + Space`). Tas rāda jūsu mājas direktorijas grafisku kokveida karti. Lielāki bloki aizņem vairāk vietas; staigājiet pa direktorijām ar tastatūru vai peli, atzīmējiet, kam jāiet, un pārskatiet savu izvēli, pirms kaut ko izņemat. Palaidiet `disktree --disk`, lai skenētu visu disku.

## Obsidian

[Obsidian](https://obsidian.md/) ir bezmaksas un ļoti paplašināma piezīmju lietotne, kas glabāšanai izmanto vienkāršus Markdown failus.

Obsidian ir bez maksas visiem nolūkiem, ieskaitot personisku, komerciālu un bezpeļņas lietošanu.

Obsidian piedāvā arī [komerciālu sinhronizācijas papildinājumu](https://obsidian.md/sync) ar mobilajām lietotnēm iOS un Android. (https://obsidian.md/pricing).

Obsidian palaižat ar `Super + Shift + O`. Lai izmantotu tēmu sinhronizāciju, iestatījumos jāizvēlas `Omarchy` tēma.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ir Omarchy pašas neticami vienkāršā Markdown rakstīšanas lietotne. Nekādu krātuvju, nekādu spraudņu, tikai jūs un vārdi.

Omawrite palaižat ar `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ir pamata attēlu rediģēšanas rīks, kas ir lielisks apgriešanai, izmēru mainīšanai un citām pamata manipulācijām. Tikai negaidiet Photoshop alternatīvu. Bet tajā joprojām ir Magic Wand un slāņi!

Pinta palaižat caur lietotņu palaidēju (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ir tēmu lietotne, kas var izvilkt krāsas no fona attēla un pārvērst tās pilnīgā, saskaņotā tēmā. Tas ir vienkāršākais veids, kā [izveidot savu tēmu](43-making-your-own-theme.md).

Aether palaižat caur lietotņu palaidēju (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) ļauj sūtīt failus uz citām ierīcēm tajā pašā tīklā, kurās darbojas šī lietotne, līdzīgi Apple AirDrop. Taču tā ir starpplatformu, tāpēc varat sūtīt failus uz Windows, macOS, Android, iOS un, protams, Linux, un no tiem.

Share izvēlni varat atvērt ar `Super + Ctrl + S` vai sadaļā _Trigger > Share_ Omarchy izvēlnē. Tā sniedz četras iespējas:

- **Clipboard** nosūta visu, ko esat nokopējuši, kā teksta failu. Lieliski, lai dabūtu saiti vai fragmentu uz savu tālruni, nesūtot sev e-pastu.
- **File** atver failu izvēlni, kurā varat izvēlēties vairākus uzreiz.
- **Folder** nosūta visu direktoriju.
- **Receive** atver pašu LocalSend, lai cita ierīce varētu kaut ko nosūtīt jums.

Tas pats darbojas no termināļa ar `omarchy share clipboard`, `omarchy share file [path]` un `omarchy share folder [path]`. Izlaidiet ceļu, un iegūsit izvēlni.

Varat arī sūtīt tieši no failu pārvaldnieka: ar labo pogu noklikšķiniet uz jebkuras izvēles Nautilus un izvēlieties _Send via LocalSend_.

Omarchy ugunsmūris pēc noklusējuma ir slēgts, izņemot LocalSend portu, tāpēc svaigā instalācijā tas darbojas uzreiz. Skatiet [drošību](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ir pilnīgs biroja pakotnes komplekts ar tekstapstrādi, izklājlapām, prezentācijām, zīmēšanas lietotni un vēl. Tas ir saderīgs ar Microsoft Office failiem, tāpēc tas ir lielisks veids, kā varēt atvērt tos Word dokumentus.

LibreOffice palaižat caur lietotņu palaidēju (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ir Omarchy pašas neticami vienkāršā prezentāciju lietotne. Jūsu klājs ir viens Markdown fails ar tā attēliem un video blakus: rakstiet katru slaidu zem tieša priekšskatījuma, velciet slaidus kārtībā, pēc tam prezentējiet pilnekrānā vai eksportējiet uz PDF un PowerPoint. Tas pat pārņem jūsu Omarchy tēmu.

Hype palaižat caur lietotņu palaidēju (`Super + Space`). Nospiediet `?` tajā, lai redzētu katru saīsni.

## Signed

[Signed](https://github.com/omacom/signed) ir Omarchy pašas neticami vienkāršais veids, kā parakstīt PDF un aizpildīt tos. Novietojiet savu saglabāto parakstu, tekstu un šodienas datumu jebkurā vietā lapā, pēc tam saglabājiet parakstītu kopiju blakus oriģinālam. Kā to darīt, skatiet [PDF aizpildīšana](27-filling-out-pdfs.md).

Signed palaižat caur lietotņu palaidēju (`Super + Space`) vai atveriet ar to PDF no failu pārvaldnieka.

## Game Vibes

Game Vibes lietotņu palaidējā (`Super + Space`) ir vieta, kur dzīvo Omarchy mazās spēles: Checkmate, 3D šaha spēle pret draugu vai iebūvēto pretinieku; Cards, Klondike pasjanss; un Neon Swarm, arkādes šaušanas spēle. Katra ir viena tīmekļa lapa, kas seko jūsu tēmai. Izvēlieties vienu ar bultiņām un `Enter`, un atgriezieties sarakstā ar `Esc` no spēles virsraksta ekrāna vai `Q`, kamēr tā ir apturēta. Tā atveras pilnekrānā: `Super + F` padara to par logu, un `Super + W` to aizver.

Spēles, ko izveidojat ar aģentu, arī parādās šeit: aģentu panelī izvēlieties _Make something cool → Game_ un aprakstiet vienu, vai nosauciet spēli, kas jau ir Game Vibes, lai turpinātu strādāt pie tās. Aģents to kopē uz `~/Games/vibes`, kur tā ir jūsu izmainīšanai, un atver to, kad ir pabeidzis. Šo kopiju varat izveidot pats ar `omarchy games vibes copy <game>`. Spēle, ar kuru dalās kāds cits, instalējas kā tēma: izvēlieties _Install > Gaming > Game Vibes_ un ielīmējiet tās git adresi, vai palaidiet `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ vienu atkal izņem, un _Update > Game Vibes Games_ atnes jaunas versijas. Spēles ielādē three.js no tīmekļa, tāpēc tām startam nepieciešams savienojums.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ir Omarchy pašas neticami vienkāršais kalkulators, kas atveras peldošā logā.

Omacalc palaižat ar `Super + Shift + Q` (vai kalkulatora taustiņu, ja jūsu tastatūrai tāds ir).

## Signal

[Signal](https://signal.org/) ir E2E šifrētās ziņapmaiņas pionieris un lieliska saziņas iespēja ikvienam, kurš labprātāk neietu caur kādu no lielajiem tehnoloģiju konglomerātiem.

Signal palaižat ar `Super + Shift + G`. Tas nav pamata instalācijas daļa, tāpēc pirmo reizi, kad to nos piedīsit, Omarchy piedāvās to instalēt jūsu vietā (tas ir arī sadaļā _Install > Service_ Omarchy izvēlnē).

## Omaview

[Omaview](https://github.com/omacom/omaview) ir Omarchy pašas neticami vienkāršais attēlu skatītājs un multivides atskaņotājs: viens logs jūsu fotoattēliem, video un mūzikai. Atveriet fotoattēlu, un bulttaustiņi iziet cauri pārējiem tās mapē, `N` un `P` to dara jebkam, un `Ctrl + M` rāda visu mapi kā režģi. Tas rāda arī HEIC, AVIF un JPEG XL fotoattēlus, un turpina no vietas, kur apstājāties jebkurā garā materiālā.

Nospiediet `F` pilnekrānam, `E`, lai rediģētu attēlu Omasnap vai apgrieztu video Omacut, `Ctrl + P`, lai izdrukātu attēlu, un `Delete`, lai pārvietotu failu uz Trash (`Ctrl + Z` to atnes atpakaļ). Nospiediet `?` tajā, lai redzētu katru saīsni.

Omaview palaižat kā _Media Viewer_ caur lietotņu palaidēju (`Super + Space`) vai vienkārši veiciet dubultklikšķi uz attēla, video vai dziesmas failu pārvaldniekā.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ir Omarchy pašas neticami vienkāršais video apgriezējs. Kad jums vajag tikai nogriezt klipa sākumu un beigas, tas pārspēj pilna video redaktora palaišanu.

Omacut palaižat caur lietotņu palaidēju (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ir Omarchy pašas neticami vienkāršais tīmekļa kameras ierakstītājs. Vienreiz izvēlieties savu kameru un mikrofonu, pēc tam nospiediet `Space`, lai ierakstītu, un vēlreiz, lai apturētu un atsāktu to pašu uzņēmumu. Tas vienmēr ieraksta jūsu kameras augstākajā izšķirtspējā, ar tiešu mikrofona līmeņa mērītāju, lai pirms sākšanas varētu pārbaudīt savus līmeņus.

Apturiet uzņēmumu, un tas uzreiz atveras iebūvētā redaktorā. Veiciet dubultklikšķi uz klipa, lai to sadalītu, velciet turus, lai apgrieztu katru gabalu, un izņemiet daļas, kuras nevēlaties. Pēc tam saglabājiet to kā MP4. Jūsu oriģinālais ieraksts tiek saglabāts, līdz to izmetat, tāpēc vienmēr varat atgriezties un griezt to citādi.

Monologue palaižat caur lietotņu palaidēju (`Super + Space`).
