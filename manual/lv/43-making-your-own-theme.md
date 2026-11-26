# Savas tēmas izveide

Savus tēmas varat pievienot mapē `~/.config/omarchy/themes`. Vienkārši nokopējiet kādu no esošajām tēmām kā pamatu (meklējiet `/usr/share/omarchy/themes`), pēc tam pielāgojiet pēc sirds patikas. Kamēr jūsu tēma atrodas šajā mapē, tā tiks iekļauta tēmu izvēles izvēlnē.

Galvenais fails, kas jāpielāgo, ir `colors.toml`. Tas definē krāsu kopu, kas pēc tam tiek izmantota, lai ģenerētu konfigurācijas terminālim (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt lietotnēm, tastatūras fona apgaismojumam, ievades metodei, ekrāna kopīgošanas izvēlnei, lietotņu ikonām, vairākiem AI rīkiem (Claude, Pi, Hermes, T3 Code, Herdr) un visai Omarchy videi (augšējai joslai, izvēlnei, paziņojumiem, OSD un bloķēšanas ekrānam).

Varat arī izmantot iekļauto Aether lietotni, lai izveidotu jaunu tēmu, izmantojot jauku GUI saskarni, kurā spēlēties ar krāsām un meklēt fonus. Vienkārši palaidiet to no lietotņu režģa ar `Super + Alt + Space`.

### Ko var saturēt instalēta tēma

Tēma, ko rakstāt pats mapē `~/.config/omarchy/themes`, var saturēt visu, ko vēlaties — tā ir jūsu mašīna un jūsu fails, un Omarchy piemēro to visu.

Tēma, ko instalējat no kāda cita repozitorija ar `omarchy theme install`, saglabā visu, kas ir krāsa, un zaudē tos nedaudzos failus, kas jūsu mašīnā palaistu kodu: jebkuru `.lua` failu, termināļa konfigurācijas (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) un `vscode.json`. Tēmas `hyprland.lua` ir Lua, ko jūsu kompozitors palaiž pie pieteikšanās, termināļa konfigurācija nosauc programmu, ko jūsu terminālis palaiž, un `vscode.json` nosauc instalējamo VSCode paplašinājumu. Kādas personas tēmas instalēšanai vajadzētu mainīt tikai to, kā jūsu darbvirsma izskatās, nekad to, ko tā palaiž.

Viss pārējais joprojām darbojas tieši tā, kā tēmas autors to uzrakstīja — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, foni un priekšskatījumi tiek saglabāti visi. Tikai tas, kas tika atmests, jūsu mašīnā tiek no jauna ģenerēts no `colors.toml`.

Omarchy abus atšķir pēc tā, vai tēmai iekšpusē ir savs git repozitorijs, ko `omarchy theme install` atstāj aiz sevis, kad tā klonē. Tāpēc tēma, ko uzrakstījāt jūs, paliek jūsu, bet tā, ko paņēmāt no interneta, paliek tikai krāsas.

### Gaišais režīms

Ja veidojat gaišā režīma tēmu, iestatiet `mode = "light"` savas `colors.toml` augšpusē. Tad tā visām lietotnēm automātiski tiks savienota ar gaišo režīmu. (Vecais veids — iemest tukšu failu ar nosaukumu `light.mode` jūsu tēmas saknē — joprojām darbojas.)

### Atbloķēšanas attēls

Tēmas, kas piegādātas ar `unlock.png` un `preview-unlock.png` attēliem, tiks norādītas sadaļā _Appearance > Unlock_. Jūsu `unlock.png` vēlams būt caurspīdīgam png. Un priekšskatījuma attēlu varat izveidot, izmantojot `omarchy plymouth preview`.

### Lietotņu tēmošana, kuras Omarchy neaptver

Ja izmantojat lietotni, kuras nav šajā sarakstā, varat iemācīt Omarchy to tēmot pats ar veidni. Iemetiet failu mapē `~/.config/omarchy/themed/`, nosaucot to pēc konfigurācijas, ko tas ģenerē, plus `.tpl` paplašinājumu, un rakstiet konfigurāciju ar `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` līdz `{{ color15 }}` un pārējo paleti kā vietturiem. Katru reizi, kad pārslēdzat tēmas, fails tiek ģenerēts no jauna ar attiecīgās tēmas krāsām.

Šajā mapē ir pilnībā komentēts `alacritty.toml.tpl.sample`, no kura kopēt — tajā ir uzskaitīts katrs mainīgais, ko varat izmantot, kā arī `_strip` un `_rgb` modifikatori lietotnēm, kas vēlas savas krāsas bez `#` vai kā decimālus RGB. Jūsu veidnēm ir prioritāte pār Omarchy paša veidnēm, tāpēc varat to izmantot arī, lai aizstātu to, kā tiek tēmota iebūvēta lietotne.

### Savas tēmas izplatīšana

Ja vēlaties izplatīt savu tēmu, lai citi to varētu izmantot, jums tā jāievieto publiskā git serverī, piemēram, GitHub. Pēc tam cilvēki to var instalēt, izmantojot _Install > Style > Theme_ Omarchy izvēlnē, norādot šo URL. Ieteicams ievērot nosaukumu konvenciju `omarchy-[themename]-theme`, jo pēc instalēšanas tēma tēmu izvēles izvēlnē tiks pareizi parādīta vienkārši kā `[themename]`.

Šis atlikušais `[themename]` kļūst par tēmas direktorijas nosaukumu, tāpēc tam jābūt tādam, ko Omarchy var droši nodot tālāk: tam jāsākas ar burtu, ciparu vai pasvītrojumu, un pārējā daļā var būt burti, cipari, `.`, `_`, `+` un `-`. Lielie burti jums tiek pārvērsti mazajos burtos, bet viss pārējais — atstarpe, pēdiņa, rakstzīme, kas nav angļu valodā — instalēšanas laikā tiek noraidīts, nevis pārvērsts par direktorijas nosaukumu. Tāpēc `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` un `omarchy-c++-theme` visas instalējas bez problēmām.

Atcerieties: tiklīdz tā ir instalēta no repozitorija, jebkurš `.lua`, termināļa konfigurācija vai `vscode.json`, ko tā piegādā, tiek atmests, tāpēc neveidojiet tēmu ap tiem.

Savu tēmu varat pievienot [papildu tēmu lapai](https://omarchy.org/themes/), nosūtot pull request uz [omarchy-site repozitoriju](https://github.com/omacom-io/omarchy-site).
