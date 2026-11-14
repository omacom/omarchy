# Navigācija

Viss Omarchy notiek ar tastatūru — _VISU!_ Kad sistēma pirmo reizi startējas, ar peli vien tu burtiski neko nevari izdarīt. Bet vari nospiest `Super + Space`, lai atvērtu Omarchy Menu, un no šejienes vari izdarīt gandrīz visu.

Bet Omarchy izvēlne pat nav paredzēta kā galvenais veids, kā lielāko daļu laika darbināt sistēmu. Mēs varam ātrāk! Visas svarīgākās lietotnes ir piesaistītas tieši atsevišķiem karstajiem taustiņiem. Termināli startē ar `Super + Return` un pārlūku ar `Super + Shift + Return`. Pamēģini vienu pēc otra, un redzēsi Hyprland flīzēšanas burvību darbībā:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Pēc tam vari nospiest `Super + J`, lai sakārtotu tos vienu virs otra, nevis blakus:

 ![navigation-stacked](images/navigation-stacked.webp)

Nospied `Super + J` vēlreiz, lai atgrieztu tos blakus pozīcijās. Pēc tam pamēģini `Super + Shift + Arrow Right`, kamēr esi pārlūkā, lai samainītu logus vietām.

Tagad pamēģini `Super + Shift + T`, lai startētu Activity monitoru. Tas parādīsies kā peldošs logs. Vari to flīzēt ar `Super + T` (un nospiest to vēlreiz, lai atkal padarītu to peldošu). Tagad nospied `Super + Shift + F`, lai atvērtu failu pārvaldnieku. Tev būs glīts četru logu izkārtojums:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Starp logiem, kuru vēlies aktivizēt, pārvietojies ar `Super + Arrow`. Tas pārslēgs fokusu un pārvietos kursoru uz jaunās lietotnes centru. Ekrāna malā tas turpinās uz monitoru tajā pusē.

Ja nospiedīsi `Super + Shift + 2`, pārvietosi pašlaik fokusēto lietotni uz otro darbvietu. `Super + Shift + 1` to pārvieto atpakaļ. (Un `Super + Shift + Alt + 2` pārvietos pašlaik fokusēto lietotni uz otro darbvietu, nepārslēdzoties uz to).

Ja ir vairāk nekā viens monitors, katram monitoram ir savas darbvietas no 1 līdz 10. `Super + 2` pāriet uz monitora, kurā esi, otro darbvietu, un katra monitora augšējā josla rāda tā darbvietas un to, kuru tas rāda. `Super + Tab` cikliski pārslēdzas starp monitora, kurā esi, darbvietām. `Super + Shift + Ctrl + Arrows` pārvieto logu, kurā esi, uz monitoru tajā virzienā, uz darbvietu, kuru tas rāda, un `Super + Shift + Alt + Arrows` pārvieto darbvietu, kurā esi, uz monitoru tajā virzienā, kur tā iegūst to pašu numuru, ja tas ir brīvs. Monitors saglabā savas darbvietas, kad to atvieno: tās pievienojas cita ekrāna darbvietām, numurētas pēc tām, kas tam jau ir, un atgriežas ar saviem vecajiem numuriem, kad monitors atgriežas.

Ja turēsi nospiestu `Super` un ar peli noklikšķināsi uz loga, varēsi pārkārtot, kur tas atrodas. Ja turēsi `Super` un izmantosi peles labo pogu, varēsi brīvi mainīt loga izmēru.

Logu aizver ar `Super + W` vai `Super + Q` (un visus logus aizver ar `Ctrl + Alt + Delete`).

Vari arī pāriet pilnekrāna režīmā ar `Super + F` vai pat tikai pilnā platumā (saglabājot augšējo joslu) ar `Super + Alt + F`, vai pilnekrāna režīmā loga iekšienē ar `Super + Ctrl + F` (lieliski der YouTube!).

### Dwindle pret ritināšanas izkārtojumu

Omarchy noklusējuma izkārtojumu sauc par dwindle. Tas visu laiku tur visus logus, ko atver vienā darbvietā, redzamus, pat ja tam tie jāsamazina.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Bet vari arī izvēlēties pārvērst darbvietu ritināšanas izkārtojumā, kur logi ir sarindoti blakus, aiz displeja redzamās malas. Vienu darbvietu šajā izkārtojumā pārvērt ar `Super + L`.

Vēlreiz nospiežot `Super + L`, darbvieta kļūst peldoša, kur logi brīvi pārklājas un tu tos izvieto pats, un trešais spiediens to atgriež uz dwindle. `Super + Alt + L` iziet tiem cauri otrā virzienā. Logs, kas tāpat peld — tāds, ko izcēli ar `Super + T`, vai lietotne, kas vienmēr atveras peldoša — turpina peldēt, kad darbvieta atgriežas flīzēšanā. Augšējā josla apzīmē darbvietu, kurā esi, ar tās izkārtojumu: kvadrāts dwindle, aplis ritināšanai un trijstūris peldošajam. Noklikšķinot uz šīs zīmes, izkārtojums arī cikliski mainās.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izvēle ir katrai darbvietai atsevišķi, un tā saglabājas. Tā vari turēt 1. darbvietu uz dwindle pārlūkošanai un 2. darbvietu uz ritināšanas kodam, un tās atgriezīsies tādas pašas pēc restartēšanas.

Ja vēlies izmantot ritināšanas izkārtojumu kā noklusējumu, vari to iestatīt `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Peldošās darbvietas

Peldoša darbvieta darbojas kā tradicionāla darbvirsma: logi pārklājas, un tu tos pats pārvieto un maini to izmēru. Katrs logs iegūst virsrakstjoslu tavas tēmas krāsās ar pogām minimizēšanai, maksimizēšanai un aizvēršanai. Arī `Super + M` minimizē fokusēto logu. Minimizēts logs gaida dokā; noklikšķini uz tā lietotnes, lai to atgrieztu. Noklikšķini uz loga, lai izvirzītu to priekšplānā. Maini tā izmēru no jebkuras malas vai stūra. Veic dubultklikšķi uz virsrakstjoslas, lai maksimizētu logu, saglabājot augšējo joslu redzamu, un vēlreiz, lai atgūtu tā veco izmēru. Chrome un citi uz Chromium balstīti pārlūki, Disks un Document Viewer izlaiž virsrakstjoslu un tā vietā izmanto savējo galveni; `Super + Alt + F` tos maksimizē, un `Super + M` tos minimizē.

Peldoša darbvieta rāda arī doku ar tavām piespraustajām lietotnēm, visu, kas darbojas, un režģi ar katru lietotni aiz lietotņu pogas, ko atver arī `Super + Alt + Space` un _Apps_ Omarchy izvēlnē. Ar labo pogu noklikšķini uz lietotnes režģī vai nospied `Delete`, lai to atinstalētu. Noklikšķini uz lietotnes, lai to atvērtu vai izvirzītu tās logu priekšplānā; noklikšķini vēlreiz, lai cikliski pārslēgtos starp tās logiem. Klikšķis ar vidējo pogu atver jaunu logu. Velc ikonu gar doku, lai to pārvietotu; ievelkot darbojošos lietotni starp pārējām, tā tur paliek. Noklikšķini ar labo pogu, lai paturētu lietotni dokā, izņemtu to no tā vai aizvērtu to. Doks atkāpjas pilnekrāna loga priekšā. Noklikšķini ar labo pogu uz lietotņu pogas, lai pārvietotu doku uz citu malu vai liktu tam slēpties, līdz rādītājs sasniedz tā malu. Pozīcija ir arī sadaļā _Appearance > Dock > Dock Position_, un `omarchy dock position left` un `omarchy dock autohide on` iestata abas no termināļa. Lietotnes, ko turi dokā, ir izbalējušas, kamēr tās nedarbojas.

Jaunas darbvietas un jebkura, kurai neesi piešķīris savu izkārtojumu ar `Super + L`, izmanto noklusējuma izkārtojumu. Mainot noklusējumu, katra darbvieta bez logiem tiek atiestatīta uz to, bet darbvieta ar logiem saglabā izkārtojumu, kas tai ir. Logs, kas minimizēts dokā, joprojām skaitās logs darbvietā, kuru tas pameta. Izvēlies to sadaļā _Appearance > Workspace Layout_: Tiling, Scrolling vai Floating. `omarchy-hyprland-workspace-layout-default scrolling` to iestata no termināļa.

### Logu grupēšana

Logus var grupēt ar `Super + G`. Kad esi grupā, katrs logs, ko startē, kamēr tā ir aktīva, piederēs grupai. Starp šiem grupētajiem logiem vari pārvietoties ar `Super + Ctrl + Arrow Left/Right` vai `Super + Alt + 1/2/3/4`, lai dotos tieši uz grupētajiem logiem pēc kārtas.

Logu vari pārvietot ārā no grupēšanas ar `Super + Alt + G` vai izjaukt visu grupu, vēlreiz nospiežot `Super + G`. Visbeidzot, logus ārpus grupas vari pārvietot tajā ar `Super + Alt + Arrows`.

### Logu izcelšana

Logu vari izcelt no tā darbvietas piešķīruma ar `Super + O`. Tas to piespraudīs kā peldošu logu, kas seko tev uz jebkuru darbvietu, uz kuru dodies. Lieliski der video atskaņotājiem un tamlīdzīgām lietām.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad darbvieta

Ir īpaša pilna izmēra scratchpad darbvieta, kas pārklāj jebkuru darbvietu, kurā pašlaik esi. Tam, kas tajā ir, piekļūsti ar `Super + S`, un logus tur izvieto ar `Super + Alt + S`.

Tā labi der vadīklām vai terminālim, ar ko vēlies ātri mijiedarboties, nepametot pašreizējo darbvietu.

### Quake konsole

Visbeidzot, ir pustāla Quake konsole, kas nolaižas pāri jebkurai darbvietai, kurā pašlaik esi. Pārslēdz to ar `Super + Grave` un izvieto tur logu ar `Super + Shift + Grave`.

Tā atveras ar tavu noklusējuma agent gatavu darbam. Kamēr konsolē ir viens logs, tā nolaižas kā centrēts panelis, nevis stiepjas pāri ekrānam. Ieliec tajā otru lietotni, un tā atgriežas pilnā platumā, lai abām būtu vieta blakus.

Lai pārvietotu logu prom no scratchpad vai konsoles, sūti to tieši uz citu darbvietu ar kaut ko līdzīgu `Super + Shift + 1`.

### Pie tā jāpierod!

Vajag nedaudz laika, lai pierastu šādi pārvietoties pa savu darbvirsmu, bet, kad pieradīsi, būs grūti atgriezties pie tradicionālas ar peli darbināmas darbvirsmas pieredzes!
