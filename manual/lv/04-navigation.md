# Navigācija

Viss Omarchy notiek ar tastatūru — _VISU!_ Kad sistēma pirmoreiz startējas, jūs burtiski neko nevarat izdarīt tikai ar peli. Bet jūs varat nospiest `Super + Space`, lai atvērtu Omarchy izvēlni, un no šejienes jūs varat izdarīt gandrīz visu.

Bet Omarchy izvēlne pat nav paredzēta kā galvenais veids, kā lielāko daļu laika darboties ar sistēmu. Mēs varam ātrāk! Visas svarīgākās lietotnes ir piesaistītas tieši atsevišķiem karstajiem taustiņiem. Jūs startējat termināli ar `Super + Return` un pārlūku ar `Super + Shift + Return`. Pamēģiniet vienu pēc otra, un jūs redzēsiet Hyprland flīzēšanas maģiju darbībā:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Jūs tad varat nospiest `Super + J`, lai sakrautu tos vienu virs otra, nevis blakus:

 ![navigation-stacked](images/navigation-stacked.webp)

Nospiediet `Super + J` vēlreiz, lai atgrieztu tos blakus novietojumā. Tad pamēģiniet `Super + Shift + Arrow Right`, kamēr esat pārlūkā, lai samainītu logus vietām.

Tagad pamēģiniet `Super + Shift + T`, lai startētu Activity monitoru. Tas parādīsies kā peldošs logs. Jūs varat to ieflīzēt ar `Super + T` (un nospiest to vēlreiz, lai atkal padarītu to peldošu). Tagad nospiediet `Super + Shift + F`, lai atvērtu failu pārvaldnieku. Jums būs glīts četru logu izkārtojums:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Jūs pārvietojaties starp logiem, kurus vēlaties padarīt aktīvus, ar `Super + Arrow`. Tas pārslēgs fokusu un pārvietos kursoru uz jaunās lietotnes centru. Ekrāna malā tas turpinās uz monitoru tajā pusē.

Ja nospiedīsiet `Super + Shift + 2`, jūs pārvietosiet pašlaik fokusēto lietotni uz otro darbvietu. `Super + Shift + 1` to pārvieto atpakaļ. (Un `Super + Shift + Alt + 2` pārvietos pašlaik fokusēto lietotni uz otro darbvietu, nepārslēdzoties uz to).

Ar vairāk nekā vienu monitoru katram monitoram ir savas darbvietas no 1 līdz 10. `Super + 2` dodas uz monitora, kurā esat, otro darbvietu, un katra monitora augšējā josla rāda savas darbvietas un to, kuru tas rāda. `Super + Tab` cikliski pārslēdzas starp monitora, kurā esat, darbvietām. `Super + Shift + Ctrl + Arrows` pārvieto logu, kurā esat, uz monitoru tajā virzienā, uz darbvietu, kuru tas rāda, un `Super + Shift + Alt + Arrows` pārvieto darbvietu, kurā esat, uz monitoru tajā virzienā, kur tā iegūst to pašu numuru, ja tas ir brīvs. Monitors saglabā savas darbvietas, kad to atvienojat: tās pievienojas cita ekrāna darbvietām, numurētas pēc tām, kas tam jau ir, un atgriežas ar saviem vecajiem numuriem, kad monitors atgriežas.

Ja turēsiet nospiestu `Super` un izmantosiet peli, lai noklikšķinātu uz loga, jūs varēsiet pārkārtot, kur tas atrodas. Ja turēsiet `Super` un izmantosiet peles labo pogu, jūs varat brīvi mainīt loga izmēru.

Jūs aizverat logu ar `Super + W` vai `Super + Q` (un aizverat visus logus ar `Ctrl + Alt + Delete`).

Jūs varat arī ieslēgt pilnekrāna režīmu ar `Super + F` vai pat tikai pilnu platumu (saglabājot augšējo joslu) ar `Super + Alt + F`, vai pilnekrāna režīmu loga iekšienē ar `Super + Ctrl + F` (ideāli YouTube!).

### Dwindle un ritināšanas izkārtojums

Omarchy noklusējuma izkārtojumu sauc par dwindle. Tas visu laiku tur visus jūsu atvērtos logus vienā darbvietā redzamus, pat ja tam tie jāsamazina.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Bet jūs varat arī izvēlēties pārvērst darbvietu ritināšanas izkārtojumā, kur logi ir sarindoti blakus, aiz displeja redzamās malas. Jūs pārvēršat vienu darbvietu šajā izkārtojumā ar `Super + L`.

Vēlreiz nospiežot `Super + L`, darbvieta kļūst peldoša, kur logi brīvi pārklājas un jūs tos novietojat paši, un trešā nospiešana to atgriež pie dwindle. `Super + Alt + L` iet caur tiem otrā virzienā. Logs, kas tik un tā ir peldošs — tāds, ko izcēlāt ar `Super + T`, vai lietotne, kas vienmēr atveras peldoša — paliek peldošs, kad darbvieta atgriežas pie flīzēšanas. Augšējā josla atzīmē darbvietu, kurā esat, ar tās izkārtojumu: kvadrāts dwindle, aplis ritināšanai un trijstūris peldošam. Noklikšķinot uz šīs zīmes, izkārtojums arī cikliski mainās.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izvēle ir katrai darbvietai atsevišķa, un tā saglabājas. Tāpēc jūs varat turēt 1. darbvietu uz dwindle pārlūkošanai un 2. darbvietu uz ritināšanas kodam, un tās atgriezīsies tādas pašas pēc restartēšanas.

Ja vēlaties izmantot ritināšanas izkārtojumu kā noklusējumu, jūs to varat iestatīt `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Peldošās darbvietas

Peldoša darbvieta darbojas kā tradicionāla darbvirsma: logi pārklājas, un jūs tos pārvietojat un maināt to izmēru paši. Katram logam ir virsrakstjosla jūsu motīva krāsās, ar pogām minimizēšanai, maksimizēšanai un aizvēršanai. `Super + M` arī minimizē fokusēto logu. Minimizēts logs gaida dokā; noklikšķiniet uz tā lietotnes, lai to atgrieztu. Noklikšķiniet uz loga, lai to izceltu priekšplānā. Mainiet tā izmēru no jebkuras malas vai stūra. Veiciet dubultklikšķi uz virsrakstjoslas, lai maksimizētu logu, vienlaikus saglabājot augšējo joslu redzamu, un vēlreiz, lai atgūtu tā veco izmēru.

Peldoša darbvieta rāda arī doku, ar jūsu piespraustajām lietotnēm, visu, kas darbojas, un visu lietotņu režģi aiz lietotņu pogas, kuru atver arī `Super + Alt + Space` un _Apps_ Omarchy izvēlnē. Ar labo pogu noklikšķiniet uz lietotnes režģī, vai nospiediet `Delete`, lai to atinstalētu. Noklikšķiniet uz lietotnes, lai to atvērtu, vai lai izceltu tās logu priekšplānā; noklikšķiniet vēlreiz, lai cikliski pārslēgtos starp tās logiem. Klikšķis ar vidējo pogu atver jaunu logu. Velciet ikonu gar doku, lai to pārvietotu; ievelkot darbojošos lietotni starp citām, tā tur paliek. Ar labo pogu noklikšķiniet, lai paturētu lietotni dokā, izņemtu to ārā vai aizvērtu to. Doks novācas no ceļa pilnekrāna logam. Ar labo pogu noklikšķiniet uz lietotņu pogas, lai pārvietotu doku uz citu malu vai liktu tam slēpties, līdz rādītājs sasniedz tā malu. Novietojums ir arī sadaļā _Appearance > Dock > Dock Position_, un `omarchy dock position left` un `omarchy dock autohide on` abus iestata no termināļa. Lietotnes, kuras paturat dokā, ir izbalējušas, kamēr tās nedarbojas.

Jaunas darbvietas, un jebkuras, kurām neesat ar `Super + L` piešķīruši savu izkārtojumu, izmanto noklusējuma izkārtojumu. Noklusējuma maiņa atiestata uz to katru darbvietu bez logiem, bet darbvieta ar logiem saglabā izkārtojumu, kāds tai ir. Logs, kas minimizēts uz doku, joprojām skaitās kā logs darbvietā, kuru tas atstāja. Izvēlieties to sadaļā _Appearance > Workspace Layout_: Tiling, Scrolling vai Floating. `omarchy-hyprland-workspace-layout-default scrolling` to iestata no termināļa.

### Logu grupēšana

Logus var grupēt, izmantojot `Super + G`. Kad esat grupā, katrs logs, ko startējat, kamēr tā ir aktīva, piederēs grupai. Jūs varat pārvietoties starp šiem grupētajiem logiem, izmantojot `Super + Ctrl + Arrow Left/Right` vai `Super + Alt + 1/2/3/4`, lai dotos tieši uz grupēto logu pēc kārtas.

Jūs varat pārvietot logu ārā no grupas ar `Super + Alt + G` vai izjaukt visu grupu, vēlreiz nospiežot `Super + G`. Visbeidzot, jūs varat pārvietot logus ārpus grupas tajā iekšā ar `Super + Alt + Arrows`.

### Logu izcelšana

Jūs varat izcelt logu no tā darbvietas piešķīruma ar `Super + O`. Tas to piespraudīs kā peldošu logu, kas seko jums, uz kuru darbvietu jūs dotos. Lieliski video atskaņotājiem un tamlīdzīgiem.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad darbvieta

Ir īpaša pilna izmēra scratchpad darbvieta, kas pārklāj jebkuru darbvietu, kurā pašlaik esat. Jūs piekļūstat tam, kas tajā ir, izmantojot `Super + S`, un jūs novietojat logus tur, izmantojot `Super + Alt + S`.

Tas labi darbojas vadīklām vai terminālim, ar ko vēlaties ātri mijiedarboties, neatstājot pašreizējo darbvietu.

### Quake konsole

Visbeidzot, ir pustāla Quake konsole, kas nolaižas pāri jebkurai darbvietai, kurā pašlaik esat. Pārslēdziet to ar `Super + Grave`, un novietojiet logu tur, izmantojot `Super + Shift + Grave`.

Tā atveras ar jūsu noklusējuma agent gatavu darbam. Kamēr konsolē ir viens logs, tā nolaižas kā centrēts panelis, nevis plešas pa visu ekrānu. Novietojiet tajā otro lietotni, un tā atgriežas pilnā platumā, lai abām būtu vieta sēdēt blakus.

Lai pārvietotu logu nost no scratchpad vai konsoles, nosūtiet to tieši uz citu darbvietu ar kaut ko līdzīgu `Super + Shift + 1`.

### Pie tā ir nedaudz jāpierod!

Ir vajadzīgs nedaudz laika, lai pierastu šādi pārvietoties savā darbvirsmā, bet, kad pieradīsiet, būs grūti atgriezties pie tradicionālas, ar peli vadītas darbvirsmas pieredzes!
