# Grafiskās saskarnes

## Faili

Files (Folio) ir grafiskais failu pārvaldnieks. `Super + Shift + F` to atver, un `Super + Shift + Alt + F` to atver direktorijā, kurā pašlaik atrodas jūsu terminālis, kas ietaupa daudz klikšķu. `Ctrl + L` ļauj ierakstīt ceļu, un, nospiežot `Space` uz jebkura faila, tas tiek priekšskatīts pilnā izmērā, to neatverot.

Pievienojiet USB atmiņu vai SD karti, un tā tiek piemontēta automātiski, tāpēc tā vienkārši parādās sānjoslā. Ja vajag ko sarežģītāku — diska formatēšanu, SMART veselības pārbaudi, partīciju izveidi — palaidiet _Disks_ no lietotņu palaidēja (`Super + Space`).

Šifrēts disks, to pievienojot, prasa tā paroli. Lai tas atslēgtos pats, pievienojiet tam atslēgas failu ar `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` un novietojiet šo atslēgas failu šeit: `~/.config/omarchy/drive-keys/<UUID>`, nosauktu pēc UUID, ko šifrētajai partīcijai izdrukā `lsblk -dno UUID /dev/sdX1`, un lasāmu tikai jums (`chmod 600`). Ja šī atslēgas faila nav vai tas tiek noraidīts, parole jums tiek prasīta kā parasti.

Dubultklikšķis ievēro saprātīgus noklusējumus: attēli, video un mūzika atveras Omaview, PDF faili — Document Viewer, Markdown — Omawrite, un vienkāršs teksts — jūsu redaktorā, Plain, ja vien sadaļā _Setup > Defaults > Editor_ neizvēlaties citu.

## Disktree

Kad disks piepildās un jums nav ne jausmas, kas to apēd, palaidiet [Disktree](https://github.com/tobi/disktree) no lietotņu palaidēja (`Super + Space`). Tas parāda jūsu mājas direktorija grafisku koka karti. Lielāki bloki aizņem vairāk vietas; staigājiet pa direktorijiem ar tastatūru vai peli, atzīmējiet, kam jāiet projām, un pirms jebkā dzēšanas pārskatiet savu izvēli. Palaidiet `disktree --disk`, lai skenētu visu disku.

## Obsidian

[Obsidian](https://obsidian.md/) ir bezmaksas un ļoti paplašināma piezīmju lietotne, kas glabāšanai izmanto vienkāršus Markdown failus.

Obsidian ir bez maksas visiem mērķiem, tostarp personīgai, komerciālai un bezpeļņas lietošanai.

Obsidian piedāvā arī [komerciālu sinhronizācijas papildinājumu](https://obsidian.md/sync) ar mobilajām lietotnēm iOS un Android ierīcēs. (https://obsidian.md/pricing).

Obsidian palaiž ar `Super + Shift + O`. Lai izmantotu motīvu sinhronizāciju, iestatījumos jāizvēlas motīvs `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ir Omarchy paša pavisam vienkāršā Markdown rakstīšanas lietotne. Nekādu krātuvju, nekādu spraudņu, tikai jūs un vārdi.

Omawrite palaiž ar `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ir vienkāršs attēlu rediģēšanas rīks, kas lieliski noder apgriešanai, izmēra maiņai un citām vienkāršām darbībām. Tikai negaidiet Photoshop alternatīvu. Bet tajā joprojām ir Magic Wand un slāņi!

Pinta palaiž ar lietotņu palaidēju (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ir motīvu lietotne, kas var iegūt krāsas no fona attēla un pārvērst tās pilnīgā, saskaņotā motīvā. Tas ir visvieglākais veids, kā [izveidot savu motīvu](43-making-your-own-theme.md).

Aether palaiž ar lietotņu palaidēju (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) ļauj sūtīt failus uz citām ierīcēm tajā pašā tīklā, kurās darbojas šī lietotne, līdzīgi kā Apple AirDrop. Taču tā ir starpplatformu, tāpēc varat sūtīt failus uz Windows, macOS, Android, iOS un, protams, Linux ierīcēm un saņemt no tām.

Kopīgošanas izvēlni var atvērt ar `Super + Ctrl + S` vai Omarchy izvēlnē sadaļā _Trigger > Share_. Tā piedāvā četras iespējas:

- **Clipboard** nosūta visu, ko esat kopējis, kā teksta failu. Lieliski noder, lai saiti vai fragmentu nogādātu tālrunī, nesūtot sev e-pastu.
- **File** atver failu atlasītāju, kurā varat izvēlēties vairākus uzreiz.
- **Folder** nosūta veselu direktoriju.
- **Receive** atver pašu LocalSend, lai cita ierīce varētu jums kaut ko nosūtīt.

Tas pats darbojas no termināļa ar `omarchy share clipboard`, `omarchy share file [path]` un `omarchy share folder [path]`. Izlaidiet ceļu, un saņemsit atlasītāju.

Varat arī sūtīt tieši no failu pārvaldnieka: ar labo pogu noklikšķiniet uz jebkuras izvēles lietotnē Faili un kopīgojiet to ar LocalSend.

Omarchy ugunsmūris pēc noklusējuma ir slēgts, izņemot LocalSend portu, tāpēc svaigā instalācijā tas darbojas uzreiz pēc instalēšanas. Skatiet [drošību](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ir pilnīgs biroja lietotņu komplekts ar teksta procesoru, izklājlapām, prezentācijām, zīmēšanas lietotni un vēl daudz ko citu. Tas ir saderīgs ar Microsoft Office failiem, tāpēc tas ir lielisks veids, kā atvērt tos Word dokumentus.

LibreOffice palaiž ar lietotņu palaidēju (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ir Omarchy paša pavisam vienkāršā prezentāciju lietotne. Jūsu prezentācija ir viens Markdown fails, kuram blakus atrodas tās attēli un video: rakstiet katru slaidu zem tiešā priekšskatījuma, velciet slaidus vajadzīgajā secībā, pēc tam prezentējiet pilnekrānā vai eksportējiet uz PDF un PowerPoint. Tā pat pārņem jūsu Omarchy motīvu.

Hype palaiž ar lietotņu palaidēju (`Super + Space`). Nospiediet `?` tajā, lai redzētu visus īsinājumtaustiņus.

## Signed

[Signed](https://github.com/omacom/signed) ir Omarchy paša pavisam vienkāršais veids, kā parakstīt PDF failus un tos aizpildīt. Novietojiet saglabāto parakstu, tekstu un šodienas datumu jebkurā lapas vietā, pēc tam saglabājiet parakstītu kopiju blakus oriģinālam. Kā to darīt, skatiet [PDF failu aizpildīšana](27-filling-out-pdfs.md).

Signed palaiž ar lietotņu palaidēju (`Super + Space`) vai atveriet ar to PDF failu no failu pārvaldnieka.

## Game Vibes

Game Vibes lietotņu palaidējā (`Super + Space`) ir vieta, kur mīt Omarchy mazās spēles: Checkmate, 3D šaha spēle pret draugu vai iebūvēto pretinieku; Cards, Klondike solitārs; Death Wish, līdz pikselim precīza platformspēle ar desmit telpām, pilna ar dzelkšņiem un zāģiem; un Neon Swarm, arkādes šaujamspēle. Katra ir viena tīmekļa lapa, kas seko jūsu motīvam. Izvēlieties kādu ar bultiņām un `Enter`, un atgriezieties sarakstā ar `Esc` no spēles sākumekrāna vai `Q`, kamēr tā ir pauzēta. Tā atveras pilnekrānā: `Super + F` pārvērš to par logu, un `Super + W` to aizver.

Arī spēles, ko izveidojat ar aģentu, parādās šeit: aģentu panelī izvēlieties _Make something cool → Game_ un aprakstiet kādu, vai nosauciet spēli, kas jau ir Game Vibes, lai turpinātu pie tās strādāt. Aģents to iekopē `~/Games/vibes`, kur tā ir jūsu un varat to mainīt, un, kad tas ir gatavs, to atver. Šo kopiju varat izveidot pats ar `omarchy games vibes copy <game>`. Spēle, ar ko dalās kāds cits, tiek instalēta kā motīvs: izvēlieties _Install > Gaming > Game Vibes_ un ielīmējiet tās git adresi vai palaidiet `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ to atkal izņem, un _Update > Game Vibes Games_ ielādē jaunās versijas. Spēles ielādē three.js no tīmekļa, tāpēc to palaišanai nepieciešams savienojums.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ir Omarchy paša pavisam vienkāršais kalkulators, kas atveras peldošā logā.

Omacalc palaiž ar `Super + Shift + Q` (vai ar kalkulatora taustiņu, ja jūsu tastatūrai tāds ir).

## Signal

[Signal](https://signal.org/) ir E2E šifrētās ziņapmaiņas pionieris un lieliska saziņas iespēja ikvienam, kurš nevēlas iet caur kādu no lielajiem tehnoloģiju konglomerātiem.

Signal palaiž ar `Super + Shift + G`. Tā nav daļa no pamata instalācijas, tāpēc pirmo reizi, kad nospiedīsiet šo kombināciju, Omarchy piedāvās to instalēt jūsu vietā (tā ir arī Omarchy izvēlnes sadaļā _Install > Service_). 

## Omaview

[Omaview](https://github.com/omacom/omaview) ir Omarchy paša pavisam vienkāršais attēlu skatītājs un multivides atskaņotājs: viens logs jūsu fotoattēliem, video un mūzikai. Atveriet fotoattēlu, un bultiņu taustiņi izies cauri pārējai tā mapei, `N` un `P` to dara jebkam, un `Ctrl + M` parāda visu mapi kā režģi. Tas rāda arī HEIC, AVIF un JPEG XL fotoattēlus un, ja kaut kas ir garš, turpina no vietas, kur beidzāt.

Nospiediet `F`, lai ieslēgtu pilnekrānu, `E`, lai rediģētu attēlu Omasnap vai apgrieztu video Omacut, `Ctrl + P`, lai izdrukātu attēlu, un `Delete`, lai pārvietotu failu uz Atkritni (`Ctrl + Z` to atgriež). Nospiediet `?` tajā, lai redzētu visus īsinājumtaustiņus.

Omaview palaiž kā _Media Viewer_ ar lietotņu palaidēju (`Super + Space`) vai vienkārši veiciet dubultklikšķi uz attēla, video vai dziesmas failu pārvaldniekā.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ir Omarchy paša pavisam vienkāršais video apgriezējs. Kad jums vajag tikai nogriezt klipa sākumu un beigas, tas pārspēj pilna video redaktora palaišanu.

Omacut palaiž ar lietotņu palaidēju (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ir Omarchy paša pavisam vienkāršais tīmekļa kameras ierakstītājs. Vienreiz izvēlieties kameru un mikrofonu, pēc tam nospiediet `Space`, lai ierakstītu, un vēlreiz, lai pauzētu un atsāktu to pašu ierakstu. Tas vienmēr ieraksta jūsu kameras augstākajā izšķirtspējā, ar reāllaika mikrofona līmeņa mērītāju, lai pirms sākšanas varētu pārbaudīt līmeņus.

Apturiet ierakstu, un tas uzreiz atveras iebūvētajā redaktorā. Veiciet dubultklikšķi uz klipa, lai to sadalītu, velciet rokturus, lai apgrieztu katru daļu, un izņemiet daļas, kuras nevēlaties. Pēc tam saglabājiet to kā MP4. Oriģinālais ieraksts tiek saglabāts, līdz to izmetat, tāpēc vienmēr varat atgriezties un sagriezt to citādi.

Monologue palaiž ar lietotņu palaidēju (`Super + Space`).
