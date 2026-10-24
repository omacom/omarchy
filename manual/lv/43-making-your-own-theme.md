# Savas tēmas veidošana

Savas tēmas varat pievienot mapē `~/.config/omarchy/themes`. Vienkārši par pamatu nokopējiet kādu no esošajām (meklējiet mapē `/usr/share/omarchy/themes`), pēc tam pielāgojiet pēc sirds patikas. Kamēr jūsu tēma ir šajā mapē, tā tiks iekļauta tēmu atlases izvēlnē.

Galvenais fails, kas jāpielāgo, ir `colors.toml`. Tas nosaka krāsu kopu, ko pēc tam izmanto konfigurāciju ģenerēšanai terminālim (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian un visai Omarchy čaulai (augšējai joslai, izvēlnei, paziņojumiem, OSD un bloķēšanas ekrānam).

Jaunas tēmas veidošanai varat izmantot arī iekļauto lietotni Aether ar jauku GUI saskarni, lai spēlētos ar krāsām un meklētu fonus. Vienkārši palaidiet to no lietotņu režģa ar `Super + Alt + Space`.

### Ko var saturēt instalēta tēma

Tēma, ko pats rakstāt mapē `~/.config/omarchy/themes`, var saturēt jebko — tā ir jūsu iekārta un jūsu fails, un Omarchy lieto to visu.

Tēma, ko instalējat no kāda cita repozitorija ar `omarchy theme install`, saglabā visu, kas ir krāsa, un zaudē tos nedaudzos failus, kas jūsu iekārtā palaistu kodu: jebkuru `.lua` failu, termināļa konfigurācijas (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) un `vscode.json`. Tēmas `hyprland.lua` ir Lua, ko jūsu kompozitors palaiž pieteikšanās brīdī, termināļa konfigurācija nosauc programmu, ko jūsu terminālis startē, un `vscode.json` nosauc instalējamo VSCode paplašinājumu. Kāda cita tēmas instalēšanai jāmaina tas, kā jūsu darbvirsma izskatās, nekad tas, ko tā palaiž.

Viss pārējais joprojām darbojas tieši tā, kā tēmas autors to uzrakstīja — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, foni un priekšskatījumi tiek saglabāti. Tikai atmestais jūsu iekārtā tiek reģenerēts no `colors.toml`.

Omarchy abus atšķir pēc tā, vai tēmai tajā ir savs git repozitorijs, ko `omarchy theme install` atstāj, kad klonē. Tāpēc jūsu rakstītā tēma paliek jūsējā, bet no interneta paņemtā paliek krāsas.

### Gaišais režīms

Ja veidojat gaišā režīma tēmu, faila `colors.toml` augšpusē iestatiet `mode = "light"`. Tad tā automātiski tiks savienota ar gaišo režīmu visās lietotnēs. (Vecais veids, tēmas saknē ieliekot tukšu failu ar nosaukumu `light.mode`, arī joprojām darbojas.)

### Ikonu krāsas

Ja vēlaties failu pārvaldnieka ikonas pieskaņot savas tēmas krāsām, pievienojiet failu ar nosaukumu `icons.theme` ar tās ikonu kopas nosaukumu, ko vēlaties izmantot. Pēc noklusējuma opcijas ir: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Atbloķēšanas attēls

Tēmas ar attēliem `unlock.png` un `preview-unlock.png` tiks uzskaitītas sadaļā _Stils > Atbloķēt_. Jūsu `unlock.png` vēlams caurspīdīgu png. Un priekšskatījuma attēlu varat izveidot ar `omarchy plymouth preview`.

### Lietotņu, ko Omarchy neaptver, tēmošana

Ja izmantojat lietotni, kuras nav šajā sarakstā, varat Omarchy iemācīt to tēmot pats ar veidni. Ielieciet failu mapē `~/.config/omarchy/themed/` ar tās konfigurācijas nosaukumu, ko tā ģenerē, plus paplašinājumu `.tpl`, un uzrakstiet konfigurāciju ar `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` līdz `{{ color15 }}` un pārējo paleti kā vietturus. Katru reizi, kad pārslēdzat tēmas, fails tiek reģenerēts ar šīs tēmas krāsām.

Šajā mapē ir pilnībā komentēts `alacritty.toml.tpl.sample`, no kā kopēt — tajā uzskaitīts katrs mainīgais, ko varat izmantot, plus modifikatori `_strip` un `_rgb` lietotnēm, kas vēlas savas krāsas bez `#` vai kā decimālus RGB. Jūsu veidnēm ir prioritāte pār paša Omarchy veidnēm, tāpēc to varat izmantot arī, lai pārrakstītu, kā tiek tēmota iebūvēta lietotne.

### Tēmas izplatīšana

Ja vēlaties izplatīt savu tēmu, lai citi to varētu izmantot, jums tā jāliek publiskā git serverī, piemēram, GitHub. Tad cilvēki to var instalēt Omarchy izvēlnē sadaļā _Instalēt > Stils > Tēma_, izmantojot šo URL. Ieteicams ievērot nosaukumu konvenciju `omarchy-[themename]-theme`, jo pēc instalēšanas tēma atlases izvēlnē pareizi parādīsies vienkārši kā `[themename]`.

Šis atlikušais `[themename]` kļūst par tēmas direktorija nosaukumu, tāpēc tam jābūt tādam, ko Omarchy var droši padot apkārt: tam jāsākas ar burtu, ciparu vai pasvītrojumu, un pārējā daļā drīkst būt burti, cipari, `.`, `_`, `+` un `-`. Lielie burti jums tiek pārvērsti par mazajiem, bet viss pārējais — atstarpe, pēdiņa, neangļu rakstzīme — instalēšanas laikā tiek noraidīts, nevis pārvērsts par direktorija nosaukumu. Tāpēc `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` un `omarchy-c++-theme` visas instalējas labi.

Atcerieties, ka, tiklīdz tā ir instalēta no repozitorija, jebkurš tās `.lua`, termināļa konfigurācija vai `vscode.json` tiek atmests, tāpēc nebūvējiet tēmu ap tiem.

Savu tēmu varat pievienot [papildu tēmu lapai](https://omarchy.org/themes/), nosūtot pull request uz [omarchy-site repozitoriju](https://github.com/omacom-io/omarchy-site).
