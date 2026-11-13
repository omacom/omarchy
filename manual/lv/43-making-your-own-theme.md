# Sava motīva izveide

Savus motīvus vari pievienot `~/.config/omarchy/themes`. Vienkārši nokopē kādu no esošajiem par pamatu (skaties `/usr/share/omarchy/themes`), pēc tam pielāgo pēc sirds patikas. Kamēr tavs motīvs atrodas tajā mapē, tas tiks iekļauts motīvu izvēles izvēlnē.

Galvenais fails, kas tev jāpielāgo, ir `colors.toml`. Tas nosaka krāsu kopu, ko pēc tam izmanto, lai ģenerētu konfigurācijas terminālim (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian un visam Omarchy apvalkam (augšjoslai, izvēlnei, paziņojumiem, OSD un bloķēšanas ekrānam).

Vari arī izmantot iekļauto Aether lietotni, lai izveidotu jaunu motīvu, izmantojot jauku GUI saskarni, kurā spēlēties ar krāsām un meklēt fonus. Vienkārši palaid to no lietotņu režģa ar `Super + Alt + Space`.

### Ko instalēts motīvs drīkst saturēt

Motīvs, ko tu pats raksti `~/.config/omarchy/themes`, var saturēt, ko vien vēlies — tā ir tava mašīna un tavs fails, un Omarchy piemēro to visu.

Motīvs, ko instalē no kāda cita repozitorija ar `omarchy theme install`, saglabā visu, kas ir krāsa, un zaudē to nedaudzo failu, kas tavā mašīnā palaistu kodu: jebkuru `.lua` failu, termināļa konfigurācijas (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) un `vscode.json`. Motīva `hyprland.lua` ir Lua, ko tavs kompozitors palaiž pie pieteikšanās, termināļa konfigurācija nosauc programmu, ko tavs terminālis startē, un `vscode.json` nosauc instalējamo VSCode paplašinājumu. Kādas personas motīva instalēšanai vajadzētu mainīt to, kā tava darbvirsma izskatās, nekad ne to, ko tā palaiž.

Viss pārējais joprojām darbojas tieši tā, kā motīva autors to uzrakstījis — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, foni un priekšskatījumi visi tiek saglabāti. Tikai tas, kas tika atmests, tavā mašīnā tiek ģenerēts no jauna no `colors.toml`.

Omarchy tos abus atšķir pēc tā, vai motīva iekšpusē ir tā paša git repozitorijs, ko `omarchy theme install` atstāj aiz sevis, kad tas klonē. Tātad motīvs, ko tu uzrakstīji, paliek tavs, bet tas, ko tu novilki no interneta, paliek krāsas.

### Gaišais režīms

Ja tu veido gaišā režīma motīvu, iestati `mode = "light"` sava `colors.toml` augšpusē. Tad tas automātiski tiks saistīts ar gaišo režīmu visām lietotnēm. (Vecais veids — ievietot tukšu failu ar nosaukumu `light.mode` tava motīva saknē — joprojām arī darbojas.)

### Atbloķēšanas attēls

Motīvi, kas piegādāti ar `unlock.png` un `preview-unlock.png` attēliem, tiks uzskaitīti sadaļā _Appearance > Unlock_. Tavai `unlock.png` vēlams būt caurspīdīgam png. Un priekšskatījuma attēlu vari izveidot, izmantojot `omarchy plymouth preview`.

### Motīvu piemērošana lietotnēm, ko Omarchy neaptver

Ja tu izmanto lietotni, kuras nav tajā sarakstā, tu vari pats iemācīt Omarchy piemērot tai motīvu ar veidni. Ieliec failu `~/.config/omarchy/themed/`, nosaucot to pēc konfigurācijas, ko tas ģenerē, plus `.tpl` paplašinājumu, un raksti konfigurāciju ar `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` līdz `{{ color15 }}` un pārējo paleti kā vietturiem. Katru reizi, kad pārslēdz motīvus, fails tiek ģenerēts no jauna ar tā motīva krāsām.

Tajā mapē ir pilnībā komentēts `alacritty.toml.tpl.sample`, no kura kopēt — tas uzskaita katru mainīgo, ko vari izmantot, plus `_strip` un `_rgb` modifikatorus lietotnēm, kuras vēlas savas krāsas bez `#` vai kā decimālu RGB. Tavām veidnēm ir priekšroka pār Omarchy paša veidnēm, tāpēc vari to izmantot arī, lai pārlabotu, kā iebūvētai lietotnei tiek piemērots motīvs.

### Tava motīva izplatīšana

Ja vēlies izplatīt savu motīvu, lai citi to varētu izmantot, tev tas jānovieto publiskā git serverī, piemēram, GitHub. Tad cilvēki varēs to instalēt, Omarchy izvēlnē izmantojot _Install > Style > Theme_ ar šo URL. Ieteicams ievērot nosaukumu konvenciju `omarchy-[themename]-theme`, jo pēc instalēšanas motīvs motīvu izvēles izvēlnē pareizi parādīsies tikai kā `[themename]`.

Tā palikusī `[themename]` daļa kļūst par motīva direktorijas nosaukumu, tāpēc tam jābūt tādam, ko Omarchy var droši nodot apkārt: tam jāsākas ar burtu, ciparu vai pasvītrojumu, un pārējā daļa drīkst saturēt burtus, ciparus, `.`, `_`, `+` un `-`. Lielie burti tavā vietā tiek pārvērsti par mazajiem burtiem, bet jebkas cits — atstarpe, pēdiņa, rakstzīme, kas nav angļu valodā — instalēšanas laikā tiek noraidīts, nevis pārvērsts direktorijas nosaukumā. Tāpēc `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` un `omarchy-c++-theme` visi instalējas bez problēmām.

Atceries, ka tiklīdz tas ir instalēts no repozitorija, jebkurš `.lua`, termināļa konfigurācija vai `vscode.json`, ko tas piegādā, tiek atmests, tāpēc nebūvē motīvu ap tiem.

Tu vari panākt, ka tavs motīvs tiek pievienots [papildu motīvu lapai](https://omarchy.org/themes/), nosūtot pull request uz [omarchy-site repozitoriju](https://github.com/omacom-io/omarchy-site).
