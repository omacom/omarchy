# GUI lietotnes

## Files

Files (Nautilus) ir grafiskais failu pārvaldnieks. `Super + Shift + F` to atver, bet `Super + Shift + Alt + F` to atver tajā direktorijā, kurā pašlaik atrodas jūsu terminālis, kas ietaupa daudz klikšķināšanas. Ar `Ctrl + L` varat ievadīt ceļu, bet, nospiežot `Space` uz jebkura faila, iegūstat ātru priekšskatījumu, neko neatverot.

Pievienojiet USB zibatmiņu vai SD karti, un tā tiek piemontēta automātiski, tāpēc tā vienkārši parādās sānjoslā. Kaut kam sarežģītākam — diska formatēšanai, SMART veselības pārbaudei, nodalījumu izveidei — palaidiet _Disks_ no lietotņu palaišanas programmas (`Super + Space`).

Veicot dubultklikšķi, tiek ievēroti saprātīgi noklusējumi: attēli, videoklipi un mūzika tiek atvērti programmā Omaview, PDF faili — programmā Document Viewer, bet vienkāršs teksts — programmā Neovim.

## Disktree

Kad disks piepildās un jums nav ne jausmas, kas to apēd, palaidiet [Disktree](https://github.com/tobi/disktree) no lietotņu palaišanas programmas (`Super + Space`). Tas parāda jūsu mājas direktorija grafisku koka karti. Lielāki bloki aizņem vairāk vietas; staigājiet pa direktorijiem ar tastatūru vai peli, atzīmējiet, kam jāiet, un pirms kaut ko dzēšat, pārskatiet savu izvēli. Palaidiet `disktree --disk`, lai skenētu visu disku.

## Obsidian

[Obsidian](https://obsidian.md/) ir bezmaksas un ļoti paplašināma piezīmju veikšanas lietotne, kas glabāšanai izmanto vienkāršus Markdown failus.

Obsidian ir bez maksas visiem nolūkiem, ieskaitot personisku, komerciālu un bezpeļņas lietošanu.

Obsidian piedāvā arī [komerciālu sinhronizēšanas papildinājumu](https://obsidian.md/sync) ar mobilajām lietotnēm iOS un Android ierīcēs. (https://obsidian.md/pricing).

Obsidian palaižat ar `Super + Shift + O`. Lai izmantotu tēmu sinhronizēšanu, iestatījumos jāizvēlas `Omarchy` tēma.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ir Omarchy paša pavisam vienkāršā Markdown rakstīšanas lietotne. Nekādu krātuvju, nekādu spraudņu, tikai jūs un vārdi.

Omawrite palaižat ar `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ir vienkāršs attēlu rediģēšanas rīks, kas ir lieliski piemērots apgriešanai, izmēru mainīšanai un citām pamata manipulācijām. Tikai negaidiet Photoshop alternatīvu. Bet tajā joprojām ir Magic Wand un slāņi!

Pinta palaižat, izmantojot lietotņu palaišanas programmu (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ir tēmu veidošanas lietotne, kas var iegūt krāsas no fona attēla un pārvērst tās pilnīgā, vienotā tēmā. Tas ir vienkāršākais veids, kā [izveidot savu tēmu](43-making-your-own-theme.md).

Aether palaižat, izmantojot lietotņu palaišanas programmu (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) ļauj sūtīt failus uz citām ierīcēm tajā pašā tīklā, kurās darbojas šī lietotne, līdzīgi kā Apple AirDrop. Tomēr tā darbojas vairākās platformās, tāpēc varat sūtīt failus uz un no Windows, macOS, Android, iOS un, protams, Linux.

Kopīgošanas izvēlni varat atvērt ar `Super + Ctrl + S` vai Omarchy izvēlnē sadaļā _Trigger > Share_. Tā piedāvā četras iespējas:

- **Clipboard** nosūta visu, ko esat nokopējis, kā teksta failu. Lieliski piemērots, lai saiti vai fragmentu nogādātu tālrunī, nesūtot sev e-pastu.
- **File** atver failu atlasītāju, kurā varat atlasīt vairākus vienlaikus.
- **Folder** nosūta veselu direktoriju.
- **Receive** atver pašu LocalSend, lai cita ierīce varētu kaut ko nosūtīt jums.

Tas pats darbojas no termināļa ar `omarchy share clipboard`, `omarchy share file [path]` un `omarchy share folder [path]`. Izlaidiet ceļu, un iegūsit atlasītāju.

Failus varat sūtīt arī tieši no failu pārvaldnieka: ar labo pogu noklikšķiniet uz jebkuras atlases programmā Nautilus un izvēlieties _Send via LocalSend_.

Omarchy ugunsmūris pēc noklusējuma ir slēgts, izņemot LocalSend portu, tāpēc jaunā instalācijā tas darbojas uzreiz, bez papildu iestatījumiem. Skatiet [drošību](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ir pilnīga biroja pakotne ar teksta apstrādes programmu, izklājlapām, prezentācijām, zīmēšanas lietotni un vēl daudz ko citu. Tā ir saderīga ar Microsoft Office failiem, tāpēc tas ir lielisks veids, kā varēt atvērt tos Word dokumentus.

LibreOffice palaižat, izmantojot lietotņu palaišanas programmu (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ir Omarchy paša pavisam vienkāršā prezentāciju lietotne. Jūsu prezentācija ir viens Markdown fails, kuram blakus atrodas tā attēli un videoklipi: rakstiet katru slaidu zem tiešā priekšskatījuma, velkot sakārtojiet slaidus vēlamajā secībā, pēc tam prezentējiet pilnekrāna režīmā vai eksportējiet uz PDF un PowerPoint. Tā pat pārņem jūsu Omarchy tēmu.

Hype palaižat, izmantojot lietotņu palaišanas programmu (`Super + Space`). Nospiediet `?` tajā, lai redzētu visus īsinājumtaustiņus.

## Signed

[Signed](https://github.com/omacom/signed) ir Omarchy paša pavisam vienkāršais veids, kā parakstīt PDF failus un tos aizpildīt. Novietojiet savu saglabāto parakstu, tekstu un šodienas datumu jebkurā vietā lapā, pēc tam saglabājiet parakstītu kopiju blakus oriģinālam. Kā to izdarīt, skatiet [PDF aizpildīšanu](27-filling-out-pdfs.md).

Signed palaižat, izmantojot lietotņu palaišanas programmu (`Super + Space`), vai atveriet PDF ar to no failu pārvaldnieka.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ir Omarchy paša pavisam vienkāršais kalkulators, kas atveras peldošā logā.

Omacalc palaižat ar `Super + Shift + Q` (vai kalkulatora taustiņu, ja jūsu tastatūrai tāds ir).

## Signal

[Signal](https://signal.org/) ir E2E šifrētās ziņojumapmaiņas pionieris un lieliska saziņas iespēja ikvienam, kurš nevēlas iet caur kādu no lielajiem tehnoloģiju konglomerātiem.

Signal palaižat ar `Super + Shift + G`. Tas nav pamata instalācijas daļa, tāpēc pirmo reizi, kad nospiedīsit šo kombināciju, Omarchy piedāvās to instalēt jūsu vietā (tas ir arī Omarchy izvēlnes sadaļā _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) ir Omarchy paša pavisam vienkāršais attēlu skatītājs un multivides atskaņotājs: viens logs jūsu fotoattēliem, videoklipiem un mūzikai. Atveriet fotoattēlu, un bulttaustiņi pāriet cauri pārējai tā mapei, `N` un `P` to dara jebkam, bet `Ctrl + M` parāda visu mapi kā režģi. Tas rāda arī HEIC, AVIF un JPEG XL fotoattēlus un garā saturā turpina no tās vietas, kurā apstājāties.

Nospiediet `F`, lai ieslēgtu pilnekrāna režīmu, `E`, lai rediģētu attēlu programmā Omasnap vai apgrieztu videoklipu programmā Omacut, `Ctrl + P`, lai izdrukātu attēlu, un `Delete`, lai pārvietotu failu uz atkritni (`Ctrl + Z` to atgriež atpakaļ). Nospiediet `?` tajā, lai redzētu visus īsinājumtaustiņus.

Omaview palaižat kā _Media Viewer_, izmantojot lietotņu palaišanas programmu (`Super + Space`), vai vienkārši veiciet dubultklikšķi uz attēla, videoklipa vai dziesmas failu pārvaldniekā.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ir Omarchy paša pavisam vienkāršais videoklipu apgriešanas rīks. Kad jums tikai jānogriež klipa sākums un beigas, tas pārspēj pilna video redaktora palaišanu.

Omacut palaižat, izmantojot lietotņu palaišanas programmu (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ir Omarchy paša pavisam vienkāršais tīmekļa kameras ierakstītājs. Vienreiz izvēlieties kameru un mikrofonu, pēc tam nospiediet `Space`, lai ierakstītu, un vēlreiz, lai pauzētu un atsāktu to pašu ierakstu. Tas vienmēr ieraksta jūsu kameras augstākajā izšķirtspējā, ar reāllaika mikrofona līmeņa mērītāju, lai pirms sākšanas varētu pārbaudīt līmeņus.

Apturiet ierakstu, un tas uzreiz atveras iebūvētajā redaktorā. Veiciet dubultklikšķi uz klipa, lai to sadalītu, velciet rokturus, lai apgrieztu katru daļu, un noņemiet daļas, kuras nevēlaties. Pēc tam saglabājiet to kā MP4. Jūsu oriģinālais ieraksts tiek saglabāts, līdz to izmetat, tāpēc vienmēr varat atgriezties un sagriezt to citādi.

Monologue palaižat, izmantojot lietotņu palaišanas programmu (`Super + Space`).
