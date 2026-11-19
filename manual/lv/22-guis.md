# Grafiskās saskarnes

## Files

Files (Folio) ir grafiskais failu pārvaldnieks. `Super + Shift + F` to atver, bet `Super + Shift + Alt + F` to atver direktorijā, kurā atrodas tavs terminālis, kas ietaupa daudz klikšķināšanas. `Ctrl + L` ļauj ierakstīt ceļu, bet `Space` nospiešana uz jebkura faila to priekšskata pilnā izmērā, to neatverot.

Pievieno USB atmiņu vai SD karti, un tā tiek piemontēta automātiski, tāpēc vienkārši parādās sānjoslā. Kaut kam sarežģītākam — diska formatēšanai, SMART veselības pārbaudei, partīciju izveidei — palaid _Disks_ no lietotņu palaidēja (`Super + Space`).

Dubultklikšķis ievēro saprātīgus noklusējumus: attēli, video un mūzika atveras Omaview, PDF faili — Document Viewer, Markdown — Omawrite, bet vienkāršs teksts — redaktorā, kas izvēlēts sadaļā _Setup > Default > Editor_.

## Disktree

Kad disks piepildās un tev nav ne jausmas, kas to apēd, palaid [Disktree](https://github.com/tobi/disktree) no lietotņu palaidēja (`Super + Space`). Tas rāda tava mājas direktorija grafisku koka karti. Lielāki bloki aizņem vairāk vietas; staigā pa direktorijiem ar tastatūru vai peli, atzīmē, kam jāiet, un pārskati savas izvēles, pirms kaut ko izdzēs. Palaid `disktree --disk`, lai skenētu visu disku.

## Obsidian

[Obsidian](https://obsidian.md/) ir bezmaksas un ļoti paplašināma piezīmju lietotne, kas glabāšanai izmanto vienkāršus Markdown failus.

Obsidian ir bezmaksas visiem mērķiem, tostarp personīgai, komerciālai un bezpeļņas lietošanai.

Obsidian piedāvā arī [komerciālu sinhronizācijas papildinājumu](https://obsidian.md/sync) ar mobilajām lietotnēm iOS un Android ierīcēs. (https://obsidian.md/pricing).

Obsidian palaid ar `Super + Shift + O`. Lai izmantotu tēmu sinhronizāciju, iestatījumos jāizvēlas `Omarchy` tēma.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ir Omarchy pašas pavisam vienkāršā Markdown rakstīšanas lietotne. Nekādu krātuvju, nekādu spraudņu, tikai tu un vārdi.

Omawrite palaid ar `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ir vienkāršs attēlu rediģēšanas rīks, kas lieliski noder apgriešanai, izmēra maiņai un citām vienkāršām manipulācijām. Tikai negaidi Photoshop alternatīvu. Bet Magic Wand un slāņi tai tomēr ir!

Pinta palaid no lietotņu palaidēja (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ir tēmu lietotne, kas var izgūt krāsas no fona attēla un pārvērst tās pilnīgā, saskaņotā tēmā. Tas ir vienkāršākais veids, kā [izveidot savu tēmu](43-making-your-own-theme.md).

Aether palaid no lietotņu palaidēja (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) ļauj sūtīt failus uz citām ierīcēm tajā pašā tīklā, kurās darbojas šī lietotne, līdzīgi kā Apple AirDrop. Taču tā ir starpplatformu, tāpēc vari sūtīt failus uz Windows, macOS, Android, iOS un, protams, Linux un saņemt no tiem.

Kopīgošanas izvēlni vari atvērt ar `Super + Ctrl + S` vai Omarchy izvēlnē sadaļā _Trigger > Share_. Tā piedāvā četras iespējas:

- **Clipboard** nosūta visu, ko esi nokopējis, kā teksta failu. Lieliski noder, lai saiti vai fragmentu nogādātu telefonā, nesūtot sev e-pastu.
- **File** atver failu izvēli, kurā vari izvēlēties vairākus uzreiz.
- **Folder** nosūta veselu direktoriju.
- **Receive** atver pašu LocalSend, lai cita ierīce varētu kaut ko nosūtīt tev.

Tas pats darbojas arī no termināļa ar `omarchy share clipboard`, `omarchy share file [path]` un `omarchy share folder [path]`. Izlaid ceļu, un iegūsi izvēli.

Vari sūtīt arī tieši no failu pārvaldnieka: ar labo pogu noklikšķini uz jebkuras izvēles Files un kopīgo to ar LocalSend.

Omarchy ugunsmūris pēc noklusējuma ir slēgts, izņemot LocalSend portu, tāpēc jaunā instalācijā tas darbojas uzreiz. Skaties [drošību](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ir pilnīgs biroja komplekts ar teksta procesoru, izklājlapām, prezentācijām, zīmēšanas lietotni un vēl daudz ko citu. Tas ir saderīgs ar Microsoft Office failiem, tāpēc tas ir lielisks veids, kā atvērt tos Word dokumentus.

LibreOffice palaid no lietotņu palaidēja (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ir Omarchy pašas pavisam vienkāršā prezentāciju lietotne. Tava prezentācija ir viens Markdown fails ar attēliem un video tam blakus: raksti katru slaidu zem tieša priekšskatījuma, velc slaidus vajadzīgajā secībā, pēc tam rādi pilnekrānā vai eksportē uz PDF un PowerPoint. Tā pat pārņem tavu Omarchy tēmu.

Hype palaid no lietotņu palaidēja (`Super + Space`). Nospied `?` tajā, lai redzētu visus īsinājumtaustiņus.

## Signed

[Signed](https://github.com/omacom/signed) ir Omarchy pašas pavisam vienkāršais veids, kā parakstīt PDF failus un tos aizpildīt. Ieliec savu saglabāto parakstu, tekstu un šodienas datumu jebkurā lapas vietā, pēc tam saglabā parakstītu kopiju blakus oriģinālam. Kā to darīt, skaties [PDF failu aizpildīšanā](27-filling-out-pdfs.md).

Signed palaid no lietotņu palaidēja (`Super + Space`) vai atver ar to PDF failu no failu pārvaldnieka.

## Game Vibes

Game Vibes lietotņu palaidējā (`Super + Space`) ir vieta, kur dzīvo Omarchy mazās spēles: Checkmate, 3D šaha spēle pret draugu vai iebūvēto pretinieku; Cards, Klondike solitārs; un Neon Swarm, arkādes šaušanas spēle. Katra ir viena tīmekļa lapa, kas seko tavai tēmai. Izvēlies vienu ar bultiņām un `Enter` un atgriezies sarakstā ar `Esc` no spēles sākuma ekrāna vai `Q`, kamēr tā ir pauzē. Tā atveras pilnekrānā: `Super + F` padara to par logu, bet `Super + W` to aizver.

Arī spēles, ko izveido ar aģentu, parādās šeit: aģentu panelī izvēlies _Make something cool → Game_ un apraksti kādu vai nosauc spēli, kas jau ir Game Vibes, lai turpinātu strādāt pie tās. Aģents to nokopē uz `~/Games/vibes`, kur tā ir tava un vari to mainīt, un atver to, kad ir gatavs. Šo kopiju vari izveidot arī pats ar `omarchy games vibes copy <game>`. Spēle, ar kuru dalās kāds cits, instalējas kā tēma: izvēlies _Install > Gaming > Game Vibes_ un ielīmē tās git adresi vai palaid `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ to atkal izņem, bet _Update > Game Vibes Games_ atnes jaunas versijas. Spēles ielādē three.js no tīmekļa, tāpēc palaišanai tām vajag savienojumu.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ir Omarchy pašas pavisam vienkāršais kalkulators, kas atveras peldošā logā.

Omacalc palaid ar `Super + Shift + Q` (vai kalkulatora taustiņu, ja tavai tastatūrai tāds ir).

## Signal

[Signal](https://signal.org/) ir E2E šifrētas ziņojumapmaiņas pionieris un lieliska saziņas iespēja ikvienam, kurš labprātāk neietu caur kādu no lielajiem tehnoloģiju konglomerātiem.

Signal palaid ar `Super + Shift + G`. Tā nav daļa no pamata instalācijas, tāpēc pirmo reizi, kad to nospiest, Omarchy piedāvās to instalēt tavā vietā (tā ir arī Omarchy izvēlnē sadaļā _Install > Service_). 

## Omaview

[Omaview](https://github.com/omacom/omaview) ir Omarchy pašas pavisam vienkāršais attēlu skatītājs un multivides atskaņotājs: viens logs tavām fotogrāfijām, video un mūzikai. Atver fotogrāfiju, un bulttaustiņi iziet cauri pārējai tās mapei, `N` un `P` to dara jebkam, bet `Ctrl + M` rāda visu mapi kā režģi. Tas rāda arī HEIC, AVIF un JPEG XL fotogrāfijas un turpina no vietas, kur apstājies jebkurā garā materiālā.

Nospied `F` pilnekrānam, `E`, lai rediģētu attēlu Omasnap vai apgrieztu video Omacut, `Ctrl + P`, lai izdrukātu attēlu, un `Delete`, lai pārvietotu failu uz Trash (`Ctrl + Z` to atgriež). Nospied `?` tajā, lai redzētu visus īsinājumtaustiņus.

Omaview palaid kā _Media Viewer_ no lietotņu palaidēja (`Super + Space`) vai vienkārši veic dubultklikšķi uz attēla, video vai dziesmas failu pārvaldniekā.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ir Omarchy pašas pavisam vienkāršais video apgriezējs. Kad tev vajag tikai nogriezt klipa sākumu un beigas, tas pārspēj pilna video redaktora palaišanu.

Omacut palaid no lietotņu palaidēja (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ir Omarchy pašas pavisam vienkāršais tīmekļa kameras ierakstītājs. Vienreiz izvēlies kameru un mikrofonu, pēc tam nospied `Space`, lai ierakstītu, un vēlreiz, lai pauzētu un atsāktu to pašu ierakstu. Tas vienmēr ieraksta tavas kameras augstākajā izšķirtspējā, ar tiešu mikrofona mērītāju, lai pirms sākšanas vari pārbaudīt līmeņus.

Apturi ierakstu, un tas uzreiz atveras iebūvētajā redaktorā. Veic dubultklikšķi uz klipa, lai to sadalītu, velc rokturus, lai apgrieztu katru gabalu, un izņem daļas, kuras negribi. Pēc tam saglabā to kā MP4. Tavs oriģinālais ieraksts tiek saglabāts, līdz to izmet, tāpēc vienmēr vari atgriezties un sagriezt to citādi.

Monologue palaid no lietotņu palaidēja (`Super + Space`).
