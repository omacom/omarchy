# Navigācija

Viss Omarchy notiek ar tastatūru — _VISU!_ Kad sistēma pirmo reizi startējas, jūs burtiski neko nevarat izdarīt tikai ar peli. Bet jūs varat nospiest `Super + Space`, lai atvērtu Omarchy izvēlni, un no šejienes jūs varat izdarīt gandrīz visu.

Bet Omarchy izvēlne pat nav paredzēta kā galvenais veids, kā lielāko daļu laika darboties ar sistēmu. Mēs varam ātrāk! Visas svarīgākās lietotnes ir piesaistītas tieši atsevišķiem karstajiem taustiņiem. Jūs startējat termināli ar `Super + Return` un pārlūku ar `Super + Shift + Return`. Mēģiniet izdarīt vienu pēc otra, un jūs redzēsiet Hyprland flīzēšanas maģiju darbībā:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Pēc tam jūs varat nospiest `Super + J`, lai sakrautu tos vienu virs otra, nevis blakus:

 ![navigation-stacked](images/navigation-stacked.webp)

Nospiediet `Super + J` vēlreiz, lai atgrieztu tos blakus pozīcijās. Pēc tam mēģiniet nospiest `Super + Shift + Arrow Right`, kamēr esat pārlūkā, lai samainītu logus vietām.

Tagad mēģiniet nospiest `Super + Shift + T`, lai startētu Aktivitātes monitoru. Tas parādīsies kā peldošs logs. Jūs varat to flīzēt, izmantojot `Super + T` (un nospiest to vēlreiz, lai padarītu to atkal peldošu). Tagad nospiediet `Super + Shift + F`, lai atvērtu failu pārvaldnieku. Jums būs glīts četru logu izkārtojums:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Jūs pārvietojaties starp logu, kuru vēlaties padarīt aktīvu, ar `Super + Arrow`. Tas pārslēgs fokusu un pārvietos kursoru uz jaunās lietotnes centru. Ekrāna malā tas turpinās uz monitoru tajā pusē.

Ja jūs nospiedīsiet `Super + Shift + 2`, jūs pārvietosiet pašreizējo fokusēto lietotni uz otro darbvietu. `Super + Shift + 1` pārvieto to atpakaļ. (Un `Super + Shift + Alt + 2` pārvietos pašreizējo fokusēto lietotni uz otro darbvietu, nepārslēdzoties uz to).

Ar vairāk nekā vienu monitoru katram monitoram ir savas darbvietas no 1 līdz 10. `Super + 2` dodas uz tā monitora otro darbvietu, kurā atrodaties, un katra monitora augšējā josla rāda savas darbvietas un to, kuru tas rāda. `Super + Tab` cikliski pārslēdz darbvietas monitorā, kurā atrodaties. `Super + Shift + Ctrl + Arrows` pārvieto logu, kurā atrodaties, uz monitoru tajā virzienā, uz darbvietu, kuru tas rāda, un `Super + Shift + Alt + Arrows` pārvieto darbvietu, kurā atrodaties, uz monitoru tajā virzienā, kur tā iegūst to pašu numuru, ja tas ir brīvs. Monitors saglabā savas darbvietas, kad jūs to atvienojat: tās pievienojas cita ekrāna darbvietām, numurētas pēc tām, kas tam jau ir, un atgriežas ar saviem vecajiem numuriem, kad monitors atgriežas.

Ja jūs turat nospiestu `Super` un izmantojat peli, lai noklikšķinātu uz loga, jūs varēsiet pārkārtot, kur tas atrodas. Ja jūs turat `Super` un izmantojat peles labo pogu, jūs varat brīvi mainīt loga izmēru.

Jūs aizverat logu ar `Super + W` vai `Super + Q` (un aizverat visus logus ar `Ctrl + Alt + Delete`).

Jūs varat arī pāriet pilnekrāna režīmā ar `Super + F` vai pat tikai pilnā platumā (saglabājot augšējo joslu) ar `Super + Alt + F` vai pilnekrāna režīmā loga iekšpusē ar `Super + Ctrl + F` (labi piemērots YouTube!).

### Dwindle pret ritināšanas izkārtojumu

Omarchy noklusējuma izkārtojums tiek saukts par dwindle. Tas visu laiku saglabā visus logus, kurus atverat vienā darbvietā, redzamus, pat ja tam tie jāsamazina.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Bet jūs varat arī izvēlēties pārvērst darbvietu ritināšanas izkārtojumā, kur logi ir sarindoti blakus, aiz displeja redzamās malas. Jūs pārvēršat vienu darbvietu šajā izkārtojumā, izmantojot `Super + L`.

Vēlreiz nospiežot `Super + L`, darbvieta kļūst peldoša, kur logi brīvi pārklājas un jūs tos novietojat pats, un trešā nospiešana atgriež to uz dwindle. `Super + Alt + L` iziet tos otrā virzienā. Logs, kas tik un tā peld — tāds, kuru jūs izcēlāt ar `Super + T`, vai lietotne, kas vienmēr atveras peldoša — turpina peldēt, kad darbvieta atgriežas flīzēšanā. Augšējā josla atzīmē darbvietu, kurā atrodaties, ar tās izkārtojumu: kvadrāts dwindle, aplis ritināšanai un trijstūris peldošajam. Noklikšķinot uz šīs atzīmes, arī cikliski mainās izkārtojums.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izvēle ir katrai darbvietai atsevišķi, un tā saglabājas. Tātad jūs varat saglabāt 1. darbvietu dwindle pārlūkošanai un 2. darbvietu ritināšanai kodam, un tās atgriezīsies tādā veidā pēc restartēšanas.

Ja vēlaties izmantot ritināšanas izkārtojumu kā noklusējumu, jūs varat to iestatīt `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Peldošās darbvietas

Peldoša darbvieta darbojas kā tradicionāla darbvirsma: logi pārklājas, un jūs tos pārvietojat un maināt to izmēru pats. Katrs logs iegūst virsrakstjoslu jūsu motīva krāsās, ar pogām minimizēšanai, maksimizēšanai un aizvēršanai. `Super + M` minimizē arī fokusēto logu. Minimizēts logs gaida dokā; noklikšķiniet uz tā lietotnes, lai to atgrieztu. Noklikšķiniet uz loga, lai izvirzītu to priekšplānā. Mainiet tā izmēru no jebkuras malas vai stūra. Veiciet dubultklikšķi uz virsrakstjoslas, lai maksimizētu logu, vienlaikus saglabājot augšējo joslu redzamu, un vēlreiz, lai atgūtu tā veco izmēru.

Peldoša darbvieta rāda arī doku ar jūsu piespraustajām lietotnēm, visu, kas darbojas, un visu lietotņu režģi aiz lietotņu pogas, kuru atver arī `Super + Alt + Space` un _Lietotnes_ Omarchy izvēlnē. Ar peles labo pogu noklikšķiniet uz lietotnes režģī vai nospiediet `Delete`, lai to atinstalētu. Noklikšķiniet uz lietotnes, lai to atvērtu vai izvirzītu tās logu priekšplānā; noklikšķiniet vēlreiz, lai cikliski pārslēgtos starp tās logiem. Vidējais klikšķis atver jaunu logu. Velciet ikonu gar doku, lai to pārvietotu; ievelkot darbojošos lietotni starp pārējām, tā tur paliek. Ar peles labo pogu noklikšķiniet, lai paturētu lietotni dokā, izņemtu to vai aizvērtu to. Doks atkāpjas pilnekrāna logam. Ar peles labo pogu noklikšķiniet uz lietotņu pogas, lai pārvietotu doku uz citu malu vai liktu tam slēpties, līdz rādītājs sasniedz tā malu. Pozīcija ir arī sadaļā _Izskats > Doks > Doka pozīcija_, un `omarchy dock position left` un `omarchy dock autohide on` iestata abus no termināļa. Lietotnes, kuras jūs paturat dokā, ir izbalējušas, kamēr tās nedarbojas.

Jaunas darbvietas un jebkuras, kurām neesat piešķīris savu izkārtojumu ar `Super + L`, izmanto noklusējuma izkārtojumu. Noklusējuma maiņa atiestata katru darbvietu bez logiem uz to, bet darbvieta ar logiem saglabā izkārtojumu, kāds tai ir. Logs, kas minimizēts dokā, joprojām tiek uzskatīts par logu darbvietā, kuru tas pameta. Izvēlieties to sadaļā _Izskats > Darbvietas izkārtojums_: Flīzēšana, Ritināšana vai Peldošais. `omarchy-hyprland-workspace-layout-default scrolling` iestata to no termināļa.

### Logu grupēšana

Logus var grupēt, izmantojot `Super + G`. Kad esat grupā, katrs logs, kuru startējat, kamēr tā ir aktīva, piederēs grupai. Jūs varat pārvietoties starp šiem grupētajiem logiem, izmantojot `Super + Ctrl + Arrow Left/Right` vai `Super + Alt + 1/2/3/4`, lai dotos tieši uz grupētajiem logiem kārtībā.

Jūs varat pārvietot logu ārā no grupēšanas ar `Super + Alt + G` vai izjaukt visu grupu, vēlreiz nospiežot `Super + G`. Visbeidzot, jūs varat pārvietot logus ārpus grupas tajā ar `Super + Alt + Arrows`.

### Logu izcelšana

Jūs varat izcelt logu no tā darbvietas piešķīruma ar `Super + O`. Tas to piespraudīs kā peldošu logu, kas seko jums uz jebkuru darbvietu, uz kuru dodaties. Lieliski piemērots video atskaņotājiem un tamlīdzīgiem.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad darbvieta

Ir īpaša pilna izmēra Scratchpad darbvieta, kas pārklājas pār jebkuru darbvietu, kurā pašlaik atrodaties. Jūs piekļūstat tam, kas tajā atrodas, izmantojot `Super + S`, un jūs novietojat logus tur, izmantojot `Super + Alt + S`.

Tā labi darbojas vadīklām vai terminālim, ar kuru vēlaties ātri mijiedarboties, nepametot pašreizējo darbvietu.

### Quake konsole

Visbeidzot, ir pusaugstuma Quake konsole, kas nolaižas pār jebkuru darbvietu, kurā pašlaik atrodaties. Pārslēdziet to ar `Super + Grave` un novietojiet logu tur, izmantojot `Super + Shift + Grave`.

Tā atveras ar jūsu noklusējuma aģentu gatavu darbam. Kamēr konsolē ir viens logs, tā nolaižas kā centrēts panelis, nevis stiepjas pāri ekrānam. Novietojiet tajā otro lietotni, un tā atgriežas pilnā platumā, lai abām būtu vieta blakus.

Lai pārvietotu logu nost no Scratchpad vai konsoles, nosūtiet to tieši uz citu darbvietu ar kaut ko līdzīgu `Super + Shift + 1`.

### Pie tā jāpierod!

Ir nepieciešams nedaudz laika, lai pierastu šādi pārvietoties pa darbvirsmu, bet, kad jūs to izdarīsiet, būs grūti atgriezties pie tradicionālas ar peli vadītas darbvirsmas pieredzes!
