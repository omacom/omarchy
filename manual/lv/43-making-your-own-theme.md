# Sava motīva izveide

Tu vari pievienot savus motīvus mapē `~/.config/omarchy/themes`. Vienkārši nokopē kādu no esošajiem motīviem kā pamatu (skaties `/usr/share/omarchy/themes`), pēc tam pielāgo pēc patikas. Kamēr tavs motīvs atrodas šajā mapē, tas tiks iekļauts motīvu izvēles izvēlnē.

Galvenais fails, kas jāpielāgo, ir `colors.toml`. Tas nosaka krāsu kopu, kas pēc tam tiek izmantota, lai ģenerētu konfigurācijas termināļiem (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian un visai Omarchy čaulai (augšējā josla, izvēlne, paziņojumi, OSD un bloķēšanas ekrāns).

Tu vari arī izmantot iekļauto Aether lietotni, lai izveidotu jaunu motīvu ar jauku GUI saskarni, kurā spēlēties ar krāsām un meklēt fonus. Vienkārši palaid to no lietotņu režģa ar `Super + Alt + Space`.

### Ko var saturēt instalēts motīvs

Motīvs, ko tu pats raksti `~/.config/omarchy/themes`, var saturēt jebko, ko vēlies — tā ir tava iekārta un tavs fails, un Omarchy to visu piemēro.

Motīvs, ko tu instalē no kāda cita repozitorija ar `omarchy theme install`, saglabā visu, kas ir krāsa, un zaudē tos nedaudzos failus, kas tavā iekārtā palaistu kodu: jebkuru `.lua` failu, termināļu konfigurācijas (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) un `vscode.json`. Motīva `hyprland.lua` ir Lua, ko tavs kompozitors palaiž pie pieteikšanās, termināļa konfigurācija norāda programmu, ko tavs terminālis startē, un `vscode.json` norāda instalējamo VSCode paplašinājumu. Kādas personas motīva instalēšanai vajadzētu mainīt to, kā tava darbvirsma izskatās, nevis to, ko tā palaiž.

Viss pārējais joprojām darbojas tieši tā, kā motīva autors to ir uzrakstījis — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, foni un priekšskatījumi tiek saglabāti visi. Tikai tas, kas tika atmests, tavā iekārtā tiek atkārtoti ģenerēts no `colors.toml`.

Omarchy tos abus atšķir pēc tā, vai motīvam iekšā ir savs git repozitorijs, ko pēc klonēšanas aiz sevis atstāj `omarchy theme install`. Tātad motīvs, ko tu uzrakstīji, paliek tavs, bet motīvs, ko tu paņēmi no interneta, paliek tikai krāsas.

### Gaišais režīms

Ja tu veido gaišā režīma motīvu, iestati `mode = "light"` sava `colors.toml` augšā. Tad tas automātiski tiks savienots ar gaišo režīmu visām lietotnēm. (Vecais veids — iemest tukšu failu ar nosaukumu `light.mode` tava motīva saknē — arī joprojām darbojas.)

### Ikonu krāsas

Ja tu vēlies pieskaņot failu pārvaldnieka ikonas savam motīvam, pievieno failu ar nosaukumu `icons.theme` un tajā ieraksti vēlamās ikonu kopas nosaukumu. Pēc noklusējuma iespējas ir: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Atbloķēšanas attēls

Motīvi, kas piegādāti ar `unlock.png` un `preview-unlock.png` attēliem, tiks norādīti sadaļā _Izskats > Atbloķēšana_. Tavai `unlock.png` vēlams būt caurspīdīgam png. Un tu vari izveidot priekšskatījuma attēlu, izmantojot `omarchy plymouth preview`.

### Motīvu piemērošana lietotnēm, ko Omarchy neaptver

Ja tu izmanto lietotni, kas nav šajā sarakstā, tu vari iemācīt Omarchy piemērot tai motīvu pats, izmantojot veidni. Iemet failu mapē `~/.config/omarchy/themed/`, nosauc to tāpat kā konfigurāciju, ko tas ģenerē, pievienojot `.tpl` paplašinājumu, un raksti konfigurāciju ar `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` līdz `{{ color15 }}` un pārējo paleti kā vietturiem. Katru reizi, kad tu pārslēdz motīvus, fails tiek atkārtoti ģenerēts ar attiecīgā motīva krāsām.

Šajā mapē ir pilnībā komentēts `alacritty.toml.tpl.sample`, no kura kopēt — tajā ir uzskaitīts katrs mainīgais, ko tu vari izmantot, kā arī `_strip` un `_rgb` modifikatori lietotnēm, kuras vēlas savas krāsas bez `#` vai kā decimālus RGB. Tavām veidnēm ir prioritāte pār paša Omarchy veidnēm, tāpēc tu vari to izmantot arī, lai ignorētu to, kā iebūvētai lietotnei tiek piemērots motīvs.

### Motīva izplatīšana

Ja tu vēlies izplatīt savu motīvu, lai citi varētu to izmantot, tev tas jāievieto publiskā git serverī, piemēram, GitHub. Pēc tam cilvēki varēs to instalēt, Omarchy izvēlnē izmantojot _Instalēt > Stils > Motīvs_ un šo URL. Ieteicams ievērot nosaukumu konvenciju `omarchy-[themename]-theme`, jo pēc instalēšanas motīvs motīvu izvēles izvēlnē pareizi parādīsies vienkārši kā `[themename]`.

Šis atlikušais `[themename]` kļūst par motīva direktorija nosaukumu, tāpēc tam jābūt tādam, ko Omarchy var droši nodot tālāk: tam jāsākas ar burtu, ciparu vai pasvītrojumu, bet pārējā daļa var saturēt burtus, ciparus, `.`, `_`, `+` un `-`. Lielie burti tev tiek pārveidoti par mazajiem, bet jebkas cits — atstarpe, pēdiņa, rakstzīme, kas nav angļu — instalēšanas laikā tiek noraidīts, nevis pārvērsts par direktorija nosaukumu. Tāpēc `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` un `omarchy-c++-theme` visi instalējas labi.

Atceries, ka, tiklīdz tas ir instalēts no repozitorija, jebkurš `.lua`, termināļa konfigurācija vai `vscode.json`, ko tas piegādā, tiek atmests, tāpēc nebūvē motīvu ap tiem.

Tu vari panākt, ka tavs motīvs tiek pievienots [papildu motīvu lapai](https://omarchy.org/themes/), nosūtot pull request uz [omarchy-site repozitoriju](https://github.com/omacom-io/omarchy-site).
