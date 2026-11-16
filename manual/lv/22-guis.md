# Grafiskās saskarnes

## Faili

Faili (Nautilus) ir grafiskais failu pārvaldnieks. `Super + Shift + F` to atver, un `Super + Shift + Alt + F` to atver direktorijā, kurā atrodas jūsu terminālis, kas ietaupa daudz klikšķu. `Ctrl + L` ļauj ierakstīt ceļu, un `Space` nospiešana uz jebkura faila sniedz ātru priekšskatījumu, neko neatverot.

Pievienojiet USB atmiņu vai SD karti, un tā tiek piemontēta automātiski, tāpēc vienkārši parādās sānjoslā. Sarežģītākiem darbiem — diska formatēšanai, SMART veselības pārbaudei, partīciju veidošanai — palaidiet _Disks_ no programmu palaišanas rīka (`Super + Space`).

Dubultklikšķis ievēro saprātīgus noklusējumus: attēli, video un mūzika atveras Omaview, PDF faili — Document Viewer, Markdown — Omawrite, un vienkāršs teksts — redaktorā, kas izvēlēts sadaļā _Setup > Default > Editor_.

## Disktree

Kad disks piepildās un jums nav ne jausmas, kas to apēd, palaidiet [Disktree](https://github.com/tobi/disktree) no programmu palaišanas rīka (`Super + Space`). Tas parāda grafisku jūsu mājas direktorijas bloku karti. Lielāki bloki aizņem vairāk vietas; staigājiet pa direktorijām ar tastatūru vai peli, atzīmējiet, kas jādzēš, un pirms jebkā dzēšanas pārskatiet savu izvēli. Palaidiet `disktree --disk`, lai skenētu visu disku.

## Obsidian

[Obsidian](https://obsidian.md/) ir bezmaksas un ļoti paplašināma piezīmju programma, kas glabāšanai izmanto vienkāršus Markdown failus.

Obsidian ir bezmaksas visiem mērķiem, tostarp personīgai, komerciālai un bezpeļņas lietošanai.

Obsidian piedāvā arī [komerciālu sinhronizēšanas papildinājumu](https://obsidian.md/sync) ar mobilajām lietotnēm iOS un Android. (https://obsidian.md/pricing).

Jūs palaižat Obsidian ar `Super + Shift + O`. Lai izmantotu motīvu sinhronizēšanu, iestatījumos jāizvēlas `Omarchy` motīvs.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ir Omarchy pašas ļoti vienkāršā Markdown rakstīšanas programma. Nekādu krātuvju, nekādu spraudņu, tikai jūs un vārdi.

Jūs palaižat Omawrite ar `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ir pamata attēlu rediģēšanas rīks, kas lieliski noder apgriešanai, izmēru mainīšanai un citām pamata manipulācijām. Tikai negaidiet Photoshop alternatīvu. Bet tajā joprojām ir Magic Wand un slāņi!

Jūs palaižat Pinta ar programmu palaišanas rīku (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ir motīvu veidošanas programma, kas var iegūt krāsas no fona attēla un pārvērst tās pilnīgā, saskaņotā motīvā. Tas ir vienkāršākais veids, kā [izveidot savu motīvu](43-making-your-own-theme.md).

Jūs palaižat Aether ar programmu palaišanas rīku (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) ļauj sūtīt failus uz citām ierīcēm tajā pašā tīklā, kurās darbojas šī programma, līdzīgi kā Apple AirDrop. Taču tā ir starpplatformu, tāpēc varat sūtīt failus uz un no Windows, macOS, Android, iOS un, protams, Linux.

Kopīgošanas izvēlni varat atvērt ar `Super + Ctrl + S` vai sadaļā _Trigger > Share_ Omarchy izvēlnē. Tā sniedz četras iespējas:

- **Clipboard** nosūta visu jūsu kopēto kā teksta failu. Lieliski noder, lai saiti vai fragmentu nogādātu tālrunī, nesūtot sev e-pastu.
- **File** atver failu izvēlni, kur varat izvēlēties vairākus uzreiz.
- **Folder** nosūta veselu direktoriju.
- **Receive** atver pašu LocalSend, lai cita ierīce varētu jums kaut ko nosūtīt.

Tas pats darbojas no termināļa ar `omarchy share clipboard`, `omarchy share file [path]` un `omarchy share folder [path]`. Izlaidiet ceļu, un saņemsiet izvēlni.

Varat arī sūtīt tieši no failu pārvaldnieka: ar labo pogu noklikšķiniet uz jebkuras izvēles Nautilus un izvēlieties _Send via LocalSend_.

Omarchy ugunsmūris pēc noklusējuma ir slēgts, izņemot LocalSend portu, tāpēc tas darbojas uzreiz jaunā instalācijā. Skatiet [drošību](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ir pilnīgs biroja komplekts ar tekstapstrādi, izklājlapām, prezentācijām, zīmēšanas programmu un daudz ko citu. Tas ir saderīgs ar Microsoft Office failiem, tāpēc tas ir lielisks veids, kā varēt atvērt tos Word dokumentus.

Jūs palaižat LibreOffice ar programmu palaišanas rīku (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ir Omarchy pašas ļoti vienkāršā prezentāciju programma. Jūsu prezentācija ir viens Markdown fails ar attēliem un video blakus: rakstiet katru slaidu zem tiešā priekšskatījuma, velciet slaidus kārtībā, pēc tam prezentējiet pilnekrānā vai eksportējiet uz PDF un PowerPoint. Tā pat uztver jūsu Omarchy motīvu.

Jūs palaižat Hype ar programmu palaišanas rīku (`Super + Space`). Nospiediet `?` programmā, lai redzētu visus īsinājumtaustiņus.

## Signed

[Signed](https://github.com/omacom/signed) ir Omarchy pašas ļoti vienkāršais veids, kā parakstīt PDF un tos aizpildīt. Novietojiet savu saglabāto parakstu, tekstu un šodienas datumu jebkur uz lapas, pēc tam saglabājiet parakstītu kopiju blakus oriģinālam. Skatiet [PDF aizpildīšanu](27-filling-out-pdfs.md), kā to izdarīt.

Jūs palaižat Signed ar programmu palaišanas rīku (`Super + Space`) vai atverat ar to PDF failu no failu pārvaldnieka.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) ir Omarchy pašas 3D šaha spēle. Spēlējiet ar draugu uz tā paša datora vai pret iebūvēto pretinieku trīs līmeņos, ar četriem veidotiem komplektiem, kas katrs pārvietojas savā veidā: orbitālie kuģi, griezts koks un ziloņkauls, meža radības un konfektes. Spēlēm nav pulksteņa, un tās saglabājas pēc katra gājiena.

Jūs palaižat Checkmate ar programmu palaišanas rīku (`Super + Space`). Nospiediet `?` programmā, lai redzētu visus īsinājumtaustiņus.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ir Omarchy pašas ļoti vienkāršais kalkulators, kas atveras peldošā logā.

Jūs palaižat Omacalc ar `Super + Shift + Q` (vai kalkulatora taustiņu, ja jūsu tastatūrai tāds ir).

## Signal

[Signal](https://signal.org/) ir E2E šifrētas ziņojumapmaiņas pionieris un lieliska saziņas iespēja ikvienam, kurš nevēlas iet caur vienu no lielajiem tehnoloģiju konglomerātiem.

Jūs palaižat Signal ar `Super + Shift + G`. Tas nav daļa no pamata instalācijas, tāpēc pirmo reizi, kad to nospiedīsiet, Omarchy piedāvās to instalēt jūsu vietā (tas ir arī sadaļā _Install > Service_ Omarchy izvēlnē).

## Omaview

[Omaview](https://github.com/omacom/omaview) ir Omarchy pašas ļoti vienkāršais attēlu skatītājs un multivides atskaņotājs: viens logs jūsu fotoattēliem, video un mūzikai. Atveriet fotoattēlu, un bulttaustiņi pāriet cauri pārējai tā mapei, `N` un `P` dara to jebkam, un `Ctrl + M` parāda visu mapi kā režģi. Tas rāda arī HEIC, AVIF un JPEG XL fotoattēlus un turpina no vietas, kur apstājāties, jebkurā garā saturā.

Nospiediet `F` pilnekrānam, `E`, lai rediģētu attēlu Omasnap vai apgrieztu video Omacut, `Ctrl + P`, lai izdrukātu attēlu, un `Delete`, lai pārvietotu failu uz Trash (`Ctrl + Z` to atgriež atpakaļ). Nospiediet `?` programmā, lai redzētu visus īsinājumtaustiņus.

Jūs palaižat Omaview kā _Media Viewer_ ar programmu palaišanas rīku (`Super + Space`) vai vienkārši veiciet dubultklikšķi uz attēla, video vai dziesmas failu pārvaldniekā.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ir Omarchy pašas ļoti vienkāršais video apgriešanas rīks. Kad jums tikai jānogriež klipa sākums un beigas, tas pārspēj pilna video redaktora palaišanu.

Jūs palaižat Omacut ar programmu palaišanas rīku (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ir Omarchy pašas ļoti vienkāršais tīmekļa kameras ierakstītājs. Izvēlieties kameru un mikrofonu vienreiz, pēc tam nospiediet `Space`, lai ierakstītu, un vēlreiz, lai pauzētu un atsāktu to pašu uzņemšanu. Tas vienmēr ieraksta jūsu kameras augstākajā izšķirtspējā, ar tiešo mikrofona līmeņa mērītāju, lai pirms sākšanas varētu pārbaudīt līmeņus.

Apturiet uzņemšanu, un tas uzreiz atveras iebūvētajā redaktorā. Veiciet dubultklikšķi uz klipa, lai to sadalītu, velciet rokturus, lai apgrieztu katru daļu, un noņemiet daļas, kuras nevēlaties. Pēc tam saglabājiet to kā MP4. Jūsu oriģinālais ieraksts tiek saglabāts, līdz to izmetat, tāpēc vienmēr varat atgriezties un sagriezt to citādi.

Jūs palaižat Monologue ar programmu palaišanas rīku (`Super + Space`).
