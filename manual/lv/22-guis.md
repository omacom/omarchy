# GUIs

## Files

Files (Folio) ir grafiskais failu pārvaldnieks. `Super + Shift + F` to atver, un `Super + Shift + Alt + F` to atver direktorijā, kurā atrodas jūsu terminālis, kas ietaupa daudz klikšķu. `Ctrl + L` ļauj ierakstīt ceļu, un, nospiežot `Space` uz jebkura faila, to var priekšskatīt pilnā izmērā, to neatverot.

Pievienojiet USB atmiņu vai SD karti, un tā tiek pievienota automātiski, tāpēc vienkārši parādās sānjoslā. Sarežģītākām darbībām — diska formatēšanai, SMART veselības pārbaudei, nodalījumu izveidei — palaidiet _Disks_ no lietotņu palaidēja (`Super + Space`).

Dubultklikšķis ievēro saprātīgus noklusējumus: attēli, video un mūzika atveras Omaview, PDF faili — Document Viewer, Markdown — Omawrite, un vienkāršs teksts — jūsu redaktorā, Plain, ja vien sadaļā _Setup > Defaults > Editor_ neizvēlaties citu.

## Disktree

Kad disks piepildās un jums nav ne jausmas, kas to apēd, palaidiet [Disktree](https://github.com/tobi/disktree) no lietotņu palaidēja (`Super + Space`). Tas parāda jūsu mājas direktorija grafisku koka karti. Lielāki bloki aizņem vairāk vietas; pārvietojieties pa direktorijiem ar tastatūru vai peli, atzīmējiet, kam jāiet, un pārskatiet savu izvēli, pirms kaut ko noņemat. Palaidiet `disktree --disk`, lai skenētu visu disku.

## Obsidian

[Obsidian](https://obsidian.md/) ir bezmaksas un ļoti paplašināma piezīmju lietotne, kas glabāšanai izmanto vienkāršus Markdown failus.

Obsidian ir bezmaksas visiem mērķiem, tostarp personīgai, komerciālai un bezpeļņas lietošanai.

Obsidian piedāvā arī [komerciālu papildinājumu sinhronizācijai](https://obsidian.md/sync) ar mobilajām lietotnēm iOS un Android ierīcēs. (https://obsidian.md/pricing).

Obsidian palaižat ar `Super + Shift + O`. Lai izmantotu tēmu sinhronizāciju, iestatījumos jāizvēlas `Omarchy` tēma.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ir Omarchy paša ārkārtīgi vienkāršā Markdown rakstīšanas lietotne. Nekādu krātuvju, nekādu spraudņu, tikai jūs un vārdi.

Omawrite palaižat ar `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ir vienkāršs attēlu rediģēšanas rīks, kas ir lielisks apgriešanai, izmēru maiņai un citām pamata manipulācijām. Tikai negaidiet Photoshop alternatīvu. Bet tajā joprojām ir Magic Wand un slāņi!

Pinta palaižat, izmantojot lietotņu palaidēju (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ir tēmu lietotne, kas var iegūt krāsas no fona attēla un pārvērst tās pilnīgā, vienotā tēmā. Tas ir vienkāršākais veids, kā [izveidot savu tēmu](43-making-your-own-theme.md).

Aether palaižat, izmantojot lietotņu palaidēju (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) ļauj sūtīt failus uz citām ierīcēm tajā pašā tīklā, kurās darbojas šī lietotne, līdzīgi kā Apple AirDrop. Tomēr tā ir starpplatformu, tāpēc varat sūtīt failus uz un no Windows, macOS, Android, iOS un, protams, Linux.

Kopīgošanas izvēlni varat atvērt ar `Super + Ctrl + S` vai Omarchy izvēlnē sadaļā _Trigger > Share_. Tā piedāvā četras iespējas:

- **Clipboard** nosūta visu, ko esat nokopējis, kā teksta failu. Lieliski, lai saiti vai fragmentu nogādātu tālrunī, nesūtot sev e-pastu.
- **File** atver failu atlasītāju, kurā varat atlasīt vairākus vienlaikus.
- **Folder** nosūta veselu direktoriju.
- **Receive** atver pašu LocalSend, lai cita ierīce varētu jums kaut ko nosūtīt.

Tas pats darbojas no termināļa ar `omarchy share clipboard`, `omarchy share file [path]` un `omarchy share folder [path]`. Izlaidiet ceļu, un iegūsiet atlasītāju.

Varat sūtīt arī tieši no failu pārvaldnieka: ar labo pogu noklikšķiniet uz jebkuras atlases Files un kopīgojiet to ar LocalSend.

Omarchy ugunsmūris pēc noklusējuma ir slēgts, izņemot LocalSend portu, tāpēc tas darbojas uzreiz pēc jaunas instalēšanas. Skatiet [drošība](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ir pilnīga biroja pakotne ar tekstapstrādi, izklājlapām, prezentācijām, zīmēšanas lietotni un daudz ko citu. Tā ir saderīga ar Microsoft Office failiem, tāpēc tas ir lielisks veids, kā atvērt tos Word dokumentus.

LibreOffice palaižat, izmantojot lietotņu palaidēju (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ir Omarchy paša ārkārtīgi vienkāršā prezentāciju lietotne. Jūsu slaidu kopa ir viens Markdown fails ar attēliem un video blakus tam: rakstiet katru slaidu zem tiešā priekšskatījuma, velciet slaidus vajadzīgajā secībā, pēc tam prezentējiet pilnekrāna režīmā vai eksportējiet uz PDF un PowerPoint. Tā pat pārņem jūsu Omarchy tēmu.

Hype palaižat, izmantojot lietotņu palaidēju (`Super + Space`). Nospiediet tajā `?`, lai redzētu visus īsinājumtaustiņus.

## Signed

[Signed](https://github.com/omacom/signed) ir Omarchy paša ārkārtīgi vienkāršais veids, kā parakstīt PDF failus un tos aizpildīt. Novietojiet savu saglabāto parakstu, tekstu un šodienas datumu jebkurā lapas vietā, pēc tam saglabājiet parakstītu kopiju blakus oriģinālam. Skatiet [PDF failu aizpildīšana](27-filling-out-pdfs.md), lai uzzinātu, kā.

Signed palaižat, izmantojot lietotņu palaidēju (`Super + Space`), vai atveriet ar to PDF failu no failu pārvaldnieka.

## Game Vibes

Game Vibes lietotņu palaidējā (`Super + Space`) ir vieta, kur dzīvo Omarchy mazās spēles: Checkmate, 3D šaha spēle pret draugu vai iebūvēto pretinieku; Cards, Klondike pasjanss; Death Wish, līdz pikselim precīza platformu spēle ar desmit telpām, pilna ar smailēm un zāģiem; un Neon Swarm, arkādes šaušanas spēle. Katra ir viena tīmekļa lapa, kas seko jūsu tēmai. Izvēlieties vienu ar bultiņām un `Enter` un atgriezieties sarakstā ar `Esc` no spēles sākuma ekrāna vai `Q`, kamēr tā ir pauzē. Tā atveras pilnekrāna režīmā: `Super + F` padara to par logu, un `Super + W` to aizver.

Arī spēles, ko izveidojat ar aģentu, parādās šeit: aģentu panelī izvēlieties _Make something cool → Game_ un aprakstiet kādu, vai nosauciet spēli, kas jau ir Game Vibes, lai turpinātu strādāt pie tās. Aģents to kopē uz `~/Games/vibes`, kur tā ir jūsu rīcībā mainīšanai, un atver to, kad ir pabeidzis. Šo kopiju varat izveidot pats ar `omarchy games vibes copy <game>`. Spēle, ar kuru dalās kāds cits, instalējas kā tēma: izvēlieties _Install > Gaming > Game Vibes_ un ielīmējiet tās git adresi, vai palaidiet `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ to atkal noņem, un _Update > Game Vibes Games_ iegūst jaunas versijas. Spēles ielādē three.js no tīmekļa, tāpēc to palaišanai nepieciešams savienojums.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ir Omarchy paša ārkārtīgi vienkāršais kalkulators, kas atveras peldošā logā.

Omacalc palaižat ar `Super + Shift + Q` (vai ar kalkulatora taustiņu, ja jūsu tastatūrai tāds ir).

## Signal

[Signal](https://signal.org/) ir E2E šifrētas ziņojumapmaiņas pionieris un lieliska saziņas iespēja ikvienam, kurš nevēlas iet caur kādu no lielajiem tehnoloģiju konglomerātiem.

Signal palaižat ar `Super + Shift + G`. Tas nav pamata instalācijas daļa, tāpēc, pirmo reizi to nospiežot, Omarchy piedāvās to instalēt jūsu vietā (tas ir pieejams arī Omarchy izvēlnē sadaļā _Install > Service_). 

## Omaview

[Omaview](https://github.com/omacom/omaview) ir Omarchy paša ārkārtīgi vienkāršais attēlu skatītājs un multivides atskaņotājs: viens logs jūsu fotoattēliem, video un mūzikai. Atveriet fotoattēlu, un bulttaustiņi pārvietojas pa pārējiem tās mapes failiem, `N` un `P` to dara jebkam, un `Ctrl + M` parāda visu mapi kā režģi. Tas rāda arī HEIC, AVIF un JPEG XL fotoattēlus un turpina no vietas, kur pārtraucāt, jebko garu.

Nospiediet `F` pilnekrāna režīmam, `E`, lai rediģētu attēlu Omasnap vai apgrieztu video Omacut, `Ctrl + P`, lai izdrukātu attēlu, un `Delete`, lai pārvietotu failu uz Trash (`Ctrl + Z` to atgriež). Nospiediet tajā `?`, lai redzētu visus īsinājumtaustiņus.

Omaview palaižat kā _Media Viewer_, izmantojot lietotņu palaidēju (`Super + Space`), vai vienkārši veiciet dubultklikšķi uz attēla, video vai dziesmas failu pārvaldniekā.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ir Omarchy paša ārkārtīgi vienkāršais video apgriezējs. Kad jums tikai jānogriež klipa sākums un beigas, tas pārspēj pilna video redaktora palaišanu.

Omacut palaižat, izmantojot lietotņu palaidēju (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ir Omarchy paša ārkārtīgi vienkāršais tīmekļa kameras ierakstītājs. Vienreiz izvēlieties kameru un mikrofonu, pēc tam nospiediet `Space`, lai ierakstītu, un vēlreiz, lai pauzētu un atsāktu to pašu ierakstu. Tas vienmēr ieraksta jūsu kameras augstākajā izšķirtspējā, ar dzīvu mikrofona līmeņa mērītāju, lai pirms sākšanas varētu pārbaudīt līmeņus.

Apturiet ierakstu, un tas uzreiz atveras iebūvētā redaktorā. Veiciet dubultklikšķi uz klipa, lai to sadalītu, velciet rokturus, lai apgrieztu katru daļu, un noņemiet daļas, kuras nevēlaties. Pēc tam saglabājiet to kā MP4. Jūsu oriģinālais ieraksts tiek saglabāts, līdz to izmetat, tāpēc vienmēr varat atgriezties un sagriezt to citādi.

Monologue palaižat, izmantojot lietotņu palaidēju (`Super + Space`).
