# Savas tēmas izveide

Savām tēmām varat pievienot mapē `~/.config/omarchy/themes`. Vienkārši nokopējiet kādu no esošajām tēmām kā pamatu (skatieties `/usr/share/omarchy/themes`), pēc tam pielāgojiet to pēc savas patikas. Kamēr jūsu tēma atrodas šajā mapē, tā tiks iekļauta tēmu izvēles izvēlnē.

Galvenais fails, kas jāpielāgo, ir `colors.toml`. Tas nosaka krāsu kopu, kas pēc tam tiek izmantota, lai ģenerētu konfigurācijas terminālim (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt lietotnēm, tastatūras fona apgaismojumam, ievades metodei, ekrāna kopīgošanas izvēlnei, lietotņu ikonām, vairākiem AI rīkiem (Claude, Pi, Hermes, T3 Code, Herdr) un visai Omarchy videi (augšējai joslai, izvēlnei, paziņojumiem, OSD un bloķēšanas ekrānam).

Varat arī izmantot iekļauto Aether lietotni, lai izveidotu jaunu tēmu, izmantojot jauku GUI saskarni krāsu pamēģināšanai un fonu meklēšanai. Vienkārši palaidiet to no lietotņu režģa ar `Super + Alt + Space`.

### Ko var saturēt instalēta tēma

Tēma, kuru pats uzrakstāt mapē `~/.config/omarchy/themes`, var saturēt visu, ko vēlaties — tā ir jūsu iekārta un jūsu fails, un Omarchy piemēro to visu.

Tēma, kuru instalējat no kāda cita repozitorija ar `omarchy theme install`, saglabā visu, kas ir krāsa, un zaudē tos nedaudzos failus, kas jūsu iekārtā palaistu kodu: jebkuru `.lua` failu, termināļa konfigurācijas (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) un `vscode.json`. Tēmas `hyprland.lua` ir Lua, ko jūsu kompozitors palaiž pieteikšanās laikā, termināļa konfigurācija nosauc programmu, ko jūsu terminālis palaiž, un `vscode.json` nosauc instalējamo VSCode paplašinājumu. Kāda cita tēmas instalēšanai vajadzētu mainīt to, kā jūsu darbvirsma izskatās, nevis to, ko tā palaiž.

Viss pārējais joprojām darbojas tieši tā, kā tēmas autors to uzrakstīja — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, foni un priekšskatījumi tiek saglabāti visi. Tikai tas, kas tika atmests, jūsu iekārtā tiek ģenerēts no jauna no `colors.toml`.

Omarchy atšķir šos divus gadījumus pēc tā, vai tēmai tajā ir savs git repozitorijs, ko `omarchy theme install` atstāj aiz sevis klonēšanas laikā. Tāpēc tēma, kuru uzrakstījāt pats, paliek jūsu, bet tā, kuru paņēmāt no interneta, paliek tikai krāsas.

### Gaišais režīms

Ja veidojat gaišā režīma tēmu, iestatiet `mode = "light"` sava `colors.toml` augšdaļā. Tad tā automātiski tiks savienota ar gaišo režīmu visām lietotnēm. (Vecais veids, ievietojot tukšu failu ar nosaukumu `light.mode` jūsu tēmas saknē, arī joprojām darbojas.)

### Sāknēšanas un pieteikšanās ekrāni

Ekrāns, kas sāknēšanas laikā prasa diska paroli, un pieteikšanās ekrāns zīmē Omarchy logotipu jūsu tēmas `accent` krāsā uz tās `background`, ar paroles lauku tās `foreground` krāsā un `red` nepareizai parolei. Tiem nav nekā papildu, ko piegādāt: Omarchy vairs neizmanto tēmas `unlock.png` vai `preview-unlock.png`. Apple Silicon Mac datoros diska paroles ekrāns saglabā Omarchy noklusējuma izskatu neatkarīgi no tēmas.

### Tēmu piemērošana lietotnēm, kuras Omarchy neaptver

Ja izmantojat lietotni, kas nav šajā sarakstā, varat iemācīt Omarchy piemērot tai tēmu pats ar veidni. Ievietojiet failu mapē `~/.config/omarchy/themed/` ar nosaukumu pēc konfigurācijas, ko tā ģenerē, plus paplašinājumu `.tpl`, un uzrakstiet konfigurāciju ar `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` līdz `{{ color15 }}` un pārējo paleti kā vietturiem. Katru reizi, kad pārslēdzat tēmas, fails tiek ģenerēts no jauna ar attiecīgās tēmas krāsām.

Šajā mapē ir pilnībā komentēts `alacritty.toml.tpl.sample`, no kura kopēt — tajā ir uzskaitīts katrs mainīgais, ko varat izmantot, kā arī modifikatori `_strip` un `_rgb` lietotnēm, kuras vēlas savas krāsas bez `#` vai kā decimālus RGB. Jūsu veidnēm ir prioritāte pār Omarchy pašas veidnēm, tāpēc varat to izmantot arī, lai ignorētu, kā iebūvēta lietotne saņem tēmu.

### Tēmas izplatīšana

Ja vēlaties izplatīt savu tēmu, lai citi varētu to izmantot, tā jāievieto publiskā git serverī, piemēram, GitHub. Pēc tam cilvēki to var instalēt, izmantojot _Install > Style > Theme_ Omarchy izvēlnē ar šo URL. Ieteicams ievērot nosaukumu piešķiršanas konvenciju `omarchy-[themename]-theme`, jo pēc instalēšanas tēma tēmu izvēles izvēlnē pareizi parādīsies tikai kā `[themename]`.

Šis atlikušais `[themename]` kļūst par tēmas direktorija nosaukumu, tāpēc tam jābūt tādam, ko Omarchy var droši nodot tālāk: tam jāsākas ar burtu, ciparu vai pasvītrojumzīmi, un pārējā daļā var būt burti, cipari, `.`, `_`, `+` un `-`. Lielie burti jums tiek pārvērsti mazajos burtos, bet viss pārējais — atstarpe, pēdiņa, rakstzīme, kas nav angļu valodā — instalēšanas laikā tiek noraidīts, nevis pārvērsts par direktorija nosaukumu. Tāpēc `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` un `omarchy-c++-theme` visas instalējas bez problēmām.

Atcerieties, ka, tiklīdz tā ir instalēta no repozitorija, jebkurš `.lua`, termināļa konfigurācija vai `vscode.json`, ko tā piegādā, tiek atmests, tāpēc neveidojiet tēmu ap tiem.

Savu tēmu varat pievienot [papildu tēmu lapai](https://omarchy.org/themes/), nosūtot pull request uz [omarchy-site repozitoriju](https://github.com/omacom-io/omarchy-site).
