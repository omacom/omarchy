# Navigācija

Omarchy vidē viss notiek ar tastatūru — _VISU!_ Kad sistēma tikko startējusies, ar peli vien tu burtiski neko nespēj izdarīt. Bet vari nospiest `Super + Space`, lai atvērtu Omarchy Menu, un no šejienes vari izdarīt gandrīz visu.

Tomēr Omarchy izvēlne lielāko daļu laika pat nav paredzēta kā galvenais sistēmas vadīšanas veids. Mēs varam ātrāk! Visas svarīgākās lietotnes ir piesaistītas tieši atsevišķiem karstajiem taustiņiem. Termināli palaiž ar `Super + Return`, bet pārlūku — ar `Super + Shift + Return`. Pamēģini vienu pēc otra, un redzēsi Hyprland flīzēšanas burvību darbībā:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Tad vari nospiest `Super + J`, lai sakrautu tos vienu virs otra, nevis blakus:

 ![navigation-stacked](images/navigation-stacked.webp)

Nospied `Super + J` vēlreiz, lai atgrieztu tos blakus novietojumā. Tad, esot pārlūkā, pamēģini `Super + Shift + Arrow Right`, lai apmainītu logus vietām.

Tagad pamēģini `Super + Shift + T`, lai palaistu Activity monitor. Tas parādīsies kā peldošs logs ar virsrakstjoslu, aiz kuras to vilkt, un pogām, lai to minimizētu, maksimizētu un aizvērtu. Tādu saņem katrs peldošs logs, lai kur tas atrastos. Vari to noflīzēt ar `Super + T` (un nospiest to vēlreiz, lai atkal padarītu to peldošu). Tagad nospied `Super + Shift + F`, lai atvērtu failu pārvaldnieku. Tev būs glīts četru logu izkārtojums:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Starp logiem, kuru vēlies aktivizēt, pārvietojies ar `Super + Arrow`. Tas pārslēgs fokusu un pārvietos kursoru uz jaunās lietotnes centru. Ekrāna malā tas turpinās uz monitoru tajā pusē.

Ja nospiedīsi `Super + Shift + 2`, pārvietosi pašlaik fokusēto lietotni uz otro darbvietu. `Super + Shift + 1` to pārvieto atpakaļ. (Un `Super + Shift + Alt + 2` pārvietos pašlaik fokusēto lietotni uz otro darbvietu, nepārslēdzoties uz to).

Ja ir vairāk nekā viens monitors, katram monitoram ir savas darbvietas no 1 līdz 10. `Super + 2` dodas uz tā monitora otro darbvietu, kurā atrodies, un katra monitora augšjoslā ir redzamas tā paša darbvietas un tā, kuru tas rāda. `Super + Tab` cikliski pārslēdz darbvietas monitorā, kurā atrodies. `Super + Shift + Ctrl + Arrows` pārvieto logu, kurā atrodies, uz monitoru tajā virzienā, uz darbvietu, kuru tas rāda, un `Super + Shift + Alt + Arrows` pārvieto darbvietu, kurā atrodies, uz monitoru tajā virzienā, kur tā iegūst to pašu numuru, ja tas ir brīvs. Monitors saglabā savas darbvietas, kad to atvieno: tās pievienojas cita ekrāna darbvietām, sanumurētas pēc tām, kas tam jau ir, un atgriežas ar saviem vecajiem numuriem, kad monitors atgriežas.

Ja turēsi nospiestu `Super` un ar peli noklikšķināsi uz loga, varēsi pārkārtot, kur tas atrodas. Ja turēsi `Super` un izmantosi peles labo pogu, varēsi brīvi mainīt loga izmēru.

Logu aizver ar `Super + W` vai `Super + Q` (un visus logus aizver ar `Ctrl + Alt + Delete`).

Vari arī ieslēgt pilnekrāna režīmu ar `Super + F` vai pat tikai pilnu platumu (saglabājot augšjoslu) ar `Super + Alt + F`, vai pilnekrāna režīmu loga iekšienē ar `Super + Ctrl + F` (lieliski YouTube!).

### Dwindle pret ritināšanas izkārtojumu

Omarchy noklusējuma izkārtojumu sauc par dwindle. Tas visu laiku tur visus logus, kurus atver vienā darbvietā, redzamus, pat ja tam tie jāsamazina.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Bet vari arī izvēlēties darbvietu pārvērst ritināšanas izkārtojumā, kur logi sarindoti blakus aiz displeja redzamās malas. Vienu darbvietu šajā izkārtojumā pārvērt ar `Super + L`.

Nospiežot `Super + L` vēlreiz, darbvieta kļūst peldoša, kur logi brīvi pārklājas un tu tos novieto pats, un trešā nospiešana to atgriež pie dwindle. `Super + Alt + L` iet caur tiem otrā virzienā. Logs, kas tāpat peldošs — tāds, kuru izcēli ar `Super + T`, vai lietotne, kas vienmēr atveras peldoša, — paliek peldošs, kad darbvieta atgriežas pie flīzēšanas. Augšjosla atzīmē darbvietu, kurā atrodies, ar tās izkārtojumu: kvadrāts dwindle, aplis ritināšanai un trijstūris peldošajam. Noklikšķinot uz šīs atzīmes, izkārtojums arī cikliski mainās, tāpat kā ar displeja taustiņu klēpjdatoros, kuriem tāds ir.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izvēle ir katrai darbvietai atsevišķi, un tā saglabājas. Tā vari darbvietu 1 turēt dwindle pārlūkošanai un darbvietu 2 ritināšanā kodam, un pēc restartēšanas tās atgriezīsies tādas pašas.

Ja vēlies ritināšanas izkārtojumu izmantot kā noklusējumu, vari to iestatīt `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Peldošās darbvietas

Peldoša darbvieta darbojas kā tradicionāla darbvirsma: logi pārklājas, un tu tos pārvieto un maini to izmēru pats. Katrs logs saņem virsrakstjoslu tavas tēmas krāsās ar pogām, lai minimizētu, maksimizētu un aizvērtu. `Super + M` arī minimizē fokusēto logu. Minimizēts logs gaida dokā; noklikšķini uz tā lietotnes, lai to atgrieztu. Noklikšķini uz loga, lai izceltu to priekšplānā. Maini tā izmēru no jebkuras malas vai stūra. Veic dubultklikšķi uz virsrakstjoslas, lai maksimizētu logu, saglabājot augšjoslu redzamu, un vēlreiz, lai atgūtu tā veco izmēru. Chrome un citi uz Chromium balstīti pārlūki, Disks un Document Viewer izlaiž virsrakstjoslu un tā vietā izmanto savējo galveni; `Super + Alt + F` tos maksimizē, un `Super + M` tos minimizē.

Katrai darbvietai ir doks ar piespraustajām lietotnēm, visu, kas darbojas, un visu lietotņu režģi aiz lietotņu pogas, kuru atver arī `Super + Alt + Space` un _Apps_ Omarchy izvēlnē. Ar labo pogu noklikšķini uz lietotnes režģī vai nospied `Delete`, lai to atinstalētu. Noklikšķini uz lietotnes, lai to atvērtu vai izceltu tās logu priekšplānā; noklikšķini vēlreiz, lai cikliski pārslēgtos starp tās logiem. Files atgriež tikai logu no darbvietas, kurā atrodies, un citādi atver jaunu, un Terminal un Agent vienmēr palaiž vēl vienu, lai gan minimizēts logs atgriežas vispirms. Klikšķis ar vidējo pogu atver jaunu logu. Velc ikonu gar doku, lai to pārvietotu; ievelkot darbojošos lietotni starp pārējām, tā tur paliek. Ar labo pogu noklikšķini, lai paturētu lietotni dokā, izņemtu to no tā vai aizvērtu. Doks paliek ārā, kamēr darbvieta ir tukša, un, tiklīdz darbvietā ir logs, tas paslēpjas, līdz rādītājs sasniedz tā malu. Pilnekrāna logs to paslēpj pavisam. Velc lietotņu pogu citas ekrāna malas virzienā, lai pārvietotu doku tur. Ar labo pogu noklikšķini uz tās, lai ar _Position_ izvēlētos malu, ar _Layout_ iestatītu noklusējuma izkārtojumu, kā to dara _Appearance > Workspace Layout_, un ar _Visibility_ paturētu doku vienmēr ieslēgtu, liktu pirmajai lietotnei to paslēpt vai paturētu to vienmēr paslēptu. `omarchy dock visibility always` to iestata no termināļa. Pozīcija ir arī zem _Appearance > Dock > Dock Position_, un `omarchy dock position left` to iestata no termināļa. Lietotnes, kuras turi dokā, ir izbalējušas, kamēr tās nedarbojas. Lai doku paturētu tikai peldošām darbvietām, izmanto _Appearance > Dock > Dock Only on Floating_ vai `omarchy dock tiling off`.

Jaunas darbvietas un jebkura, kurai neesi piešķīris savu izkārtojumu ar `Super + L`, izmanto noklusējuma izkārtojumu. Noklusējuma maiņa atiestata uz to katru darbvietu bez logiem, bet tā, kurā ir logi, saglabā izkārtojumu, kas tai ir. Dokā minimizēts logs joprojām skaitās logs darbvietā, kuru tas atstāja. Izvēlies to zem _Appearance > Workspace Layout_: Tiling, Scrolling vai Floating. `omarchy hyprland workspace layout default scrolling` to iestata no termināļa.

### Logu grupēšana

Logus var grupēt, izmantojot `Super + G`. Tiklīdz esi grupā, katrs logs, kuru palaidīsi, kamēr tā ir aktīva, piederēs grupai. Starp šiem grupētajiem logiem vari pārvietoties, izmantojot `Super + Ctrl + Arrow Left/Right` vai `Super + Alt + 1/2/3/4`, lai dotos tieši uz grupētajiem logiem pēc kārtas.

Logu vari izņemt no grupas ar `Super + Alt + G` vai izjaukt visu grupu, nospiežot `Super + G` vēlreiz. Visbeidzot, logus ārpus grupas vari pārvietot tajā ar `Super + Alt + Arrows`.

### Logu izcelšana

Logu vari izcelt no tā darbvietas piešķīruma ar `Super + O`. Tas to piespraudīs kā peldošu logu, kas seko tev, uz kuru darbvietu vien dodies. Lieliski video atskaņotājiem un tamlīdzīgiem.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad darbvieta

Ir īpaša pilna izmēra scratchpad darbvieta, kas pārklājas pār jebkuru darbvietu, kurā pašlaik atrodies. Tam, kas tajā atrodas, piekļūsti ar `Super + S`, un logus tur novieto ar `Super + Alt + S`.

Tā labi der vadīklām vai terminālim, ar kuru vēlies ātri sazināties, nepametot pašreizējo darbvietu.

### Quake konsole

Visbeidzot, ir pusaugstuma Quake konsole, kas nolaižas pār jebkuru darbvietu, kurā pašlaik atrodies. Pārslēdz to ar `Super + the key above Tab` (ASV izkārtojumos gravis), un logu tur novieto ar `Super + Shift + the key above Tab`.

Pirmajā atvēršanas reizē tā palaiž tavu noklusējuma aģentu vai lūdz izvēlēties vienu, ja vēl neesi to izvēlējies. Kamēr konsolē ir viens logs, tā nolaižas kā centrēts panelis, nevis stiepjas pāri ekrānam. Novieto tajā otro lietotni, un tā atgriežas pilnā platumā, lai abām būtu vieta blakus.

Lai logu pārvietotu prom vai nu no scratchpad, vai konsoles, nosūti to tieši uz citu darbvietu ar kaut ko līdzīgu `Super + Shift + 1`.

### Pie tā mazliet jāpierod!

Paies mazliet laika, līdz pieradīsi šādi pārvietoties pa savu darbvirsmu, bet, tiklīdz pieradīsi, būs grūti atgriezties pie tradicionālas, ar peli vadītas darbvirsmas pieredzes!
