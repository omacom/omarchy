# Vionyeshi

Omarchy huchukulia kwa chaguo-msingi kuwa unatumia kionyeshi cha kiwango cha retina chenye uwezo wa 2x. Hiki ndicho unachohitaji kupata fonti hizo nzuri, kali za watengenezaji programu. Ndicho takriban kompyuta mpakato zote mpya za bei ya juu zenye skrini za ubora wa juu zimeboreshwa kwa ajili yake. Ndicho ungependa kutumia kwenye 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) au 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Lakini kama hutumii kionyeshi chenye PPI ya 218 au zaidi, utahitaji kubadilisha mipangilio ya kionyeshi. Kwa mfano, kama una 4K ya 27" au 32", unaweza kuchagua kipimo cha sehemu kwa ajili yake kutoka kwenye paneli ya kionyeshi kwenye upau wa juu, au kuweka chaguo-msingi kwa kila kionyeshi kwa kufungua `~/.config/hypr/monitors.lua` na kubadilisha kwenda kwenye mapendekezo ya mchanganyiko huo:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Kama unatumia kionyeshi cha 1080p au 1440p, huenda utataka tu kutumia upimaji wa 1x, na vivyo hivyo kwa programu za GTK na X11, kwa hivyo unaweza kutumia:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Mabadiliko kwenye `GDK_SCALE` hutumika kwa programu zinazoanzishwa baada ya mabadiliko (na GTK hutii nambari kamili tu, kwa hivyo iweke kwenye nambari kamili iliyo karibu zaidi na kipimo cha kionyeshi chako). Kwa hivyo hakikisha unafunga madirisha uliyo nayo ambayo ni makubwa kupita kiasi baada ya mabadiliko (au funga madirisha yote kwa `Ctrl + Alt + Del`!).

Unaweza pia kupita haraka kwenye uwiano mkuu wa upimaji wa kionyeshi (1x, 1.25x, 1.6x, 2x, 3x, 4x) kwa kutumia `Super + /` kwenda juu zaidi na `Super + Alt + /` kwenda chini zaidi, au kuchagua kimoja kutoka kwenye paneli ya kionyeshi kwenye upau wa juu. Hivi hubadilisha tu kionyeshi unachokilenga, kwa hivyo skrini ya kompyuta mpakato na kionyeshi cha nje kila kimoja kinaweza kuwa na kipimo chake. Paneli pia huweka ubora wa picha wa kila kionyeshi. Machaguo yako huhifadhiwa kwa kionyeshi hicho halisi katika `~/.local/state/omarchy/monitors/settings`, kwa hivyo hudumu baada ya kuwasha upya na humfuata kionyeshi kwenye mlango au doki yoyote kitakachochomekwa baadaye. Huwa na kipaumbele kuliko kanuni yoyote ya kionyeshi hicho hicho katika `~/.config/hypr/monitors.lua`, ambayo Omarchy haihariri kamwe. Kama ungependa kuweka vionyeshi vyako kabisa katika faili hiyo, ongeza `omarchy_monitor_panel_settings = false` humo, na mabadiliko ya paneli yatadumu tu hadi Hyprland ipakie upya. Kwa kuwa `GDK_SCALE` ni thamani moja kwa skrini zote, kipimo kilichochaguliwa huiweka kutoka kwenye kionyeshi chenye kipimo cha chini zaidi, kwa hivyo programu za X11 hutokea ndogo kidogo kwenye skrini yenye msongamano mkubwa zaidi badala ya kuwa kubwa kupita kiasi kwenye nyingine.

### Kufanya maandishi kuwa makubwa au madogo zaidi

Upimaji wa kionyeshi hubadilisha ukubwa wa kila kitu. Kama unachotaka ni _maandishi_ makubwa au madogo zaidi tu, kuna kifaa kimoja tu cha kudhibiti hilo:

```
omarchy display text size 14
```

Hiyo huchukua ukubwa wa pikseli kati ya 9 na 20, na husogeza ganda la Omarchy, programu za GTK, na terminali yako pamoja, kwa hivyo eneo-kazi lote hubaki kwa uwiano. Iendeshe bila hoja yoyote kuona ulipo, na `omarchy display text size reset` kurudi kwenye chaguo-msingi. Foot ndiyo iliyochelewa pekee: haina njia ya kupakia upya usanidi wake, kwa hivyo terminali zinazoendeshwa hubaki na ukubwa wake wa zamani hadi ufungue mpya.

### Kupanua na kuakisi vionyeshi vya kompyuta mpakato

Unapounganisha skrini ya nje kwenye kompyuta yako mpakato, kionyeshi hupanuliwa kiotomatiki. Lakini unaweza kubadilisha hiyo kuwa uakisi badala yake kwa kutumia _Trigger > Hardware_ kwenye menyu ya Omarchy au `Super + Ctrl + Alt + Delete`. Hii ni muhimu hasa kama skrini hiyo ya nje ni projekta, na unataka kuonyesha kitu huku ukifanya kazi.

Unapopanua, kufunga kifuniko cha kompyuta mpakato kutazima skrini ya ndani kiotomatiki. Kufungua kifuniko kutairejesha. Unaweza pia kudhibiti hii mwenyewe kwa kutumia _Trigger > Hardware_ kwenye menyu ya Omarchy au `Super + Ctrl + Delete`.

### Kupanga skrini nyingi

Hyprland hufanya kazi vizuri sana na skrini nyingi. Paneli ya kionyeshi kwenye upau wa juu huzichora pale zilipo: buruta moja ukaiguse upande wa nyingine ili kuihamishia hapo, na mpangilio huhifadhiwa pamoja na mipangilio mingine ya kila kionyeshi. Kwa chochote ambacho paneli haishughulikii, soma zaidi kuhusu jinsi ya kuzipanga katika [hati za kionyeshi za Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Katika Omarchy, hizi huenda katika `~/.config/hypr/monitors.lua` kama maingizo ya `hl.monitor` — faili huja na mifano iliyotiwa maoni ya kubandika kionyeshi maalum kwenye ubora wa picha, mahali, na mzunguko maalum.

Kila kionyeshi kina maeneo ya kazi 1 hadi 10 yake yenyewe, kwa hivyo `Super + 1` humaanisha daima eneo la kazi la kwanza la kionyeshi ulichopo. Nyuma ya pazia, Hyprland bado huweka nambari za maeneo ya kazi kwenye vionyeshi vyote: skrini ya kompyuta mpakato (au kionyeshi cha kwanza) hupata 1–10, kionyeshi kinachofuata 11–20, na kadhalika, na kila kionyeshi huhifadhi kitalu chake kila unapokichomeka. Tumia nambari hizo kama unaandika [kanuni za eneo la kazi](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) au kanuni za dirisha kwa kionyeshi maalum, kwa hivyo eneo la kazi 12 ni eneo la kazi la pili la kionyeshi chako cha pili. `~/.local/state/omarchy/monitors/workspaces` huorodhesha kitalu gani kila kionyeshi nacho.

Vitufe vya mishale hufanya kazi kuvuka vionyeshi vinavyoshiriki ukingo katika mpangilio wako. Skrini zinazogusana kwenye kona tu, au zenye pengo kati yake, si majirani, kwa hivyo tumia `Ctrl + Alt + Tab` kupita kati yake.

| Kitufe cha mkato | Kuvuka vionyeshi |
| --- | --- |
| `Super + Arrow` | Husogeza mwelekeo kwenye kionyeshi kilicho upande huo mara tu kunapokuwa hakuna dirisha lililobaki katika mwelekeo huo |
| `Super + Shift + Arrow` | Hubadilishana na dirisha kwenye kionyeshi kilicho upande huo |
| `Super + Alt + Arrow` | Husogeza dirisha kwenye kikundi kwenye kionyeshi kilicho upande huo |
| `Super + Shift + Ctrl + Arrow` | Husogeza dirisha kwenye kionyeshi kilicho upande huo, kwenye eneo la kazi linaloonyeshwa |
| `Super + Shift + Alt + Arrow` | Husogeza eneo la kazi kwenye kionyeshi kilicho upande huo, na kulihifadhi nambari yake kama ni huru |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Husogeza mwelekeo kwenye kionyeshi kinachofuata au kilichotangulia, chochote mpangilio ulivyo |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Hubaki kwenye kionyeshi ulichopo |

Unaweza pia kuangalia [Hyprmon](https://github.com/erans/hyprmon/), kama ungependa TUI ikusaidie katika kuweka skrini nyingi mahali pake.

### Kudhibiti mwangaza

Mwangaza wa kionyeshi hudhibitiwa na vitufe maalum vya utendakazi vya kuongeza/kupunguza mwangaza. Kama utashikilia Shift huku ukibonyeza hivi, utaenda kwenye mwangaza wa juu zaidi au wa chini zaidi. Vitufe hudhibiti kionyeshi unachokilenga, kwa hivyo vionyeshi vya nje vinavyozungumza DDC/CI hurekebishwa kwa njia ile ile kama skrini ya kompyuta mpakato.

### Vionyeshi vya Apple

Kama unatumia kionyeshi cha Apple, vitufe vya kawaida vya mwangaza vya kibodi pia vitafanya kazi kiotomatiki, kama umelenga kionyeshi cha Apple. Hii hufanywa kupitia amri ya `asdcontrol`.

Kumbuka kuwa kama unatumia kionyeshi cha Apple 6K XDR, unaweza kuona skrini ya mzuka katika orodha yako ya `hyprctl monitors`. Unaweza kuzima hii kwa kitu kama `hl.monitor({ output = "DP-2", disabled = true })` katika `~/.config/hypr/monitors.lua`.

Kwenye mashine za Intel, unapaswa kuunganisha kwenye vionyeshi vya Apple kwa kutumia kebo ya kawaida ya Thunderbolt. Kwenye mashine nyingine zisizo na Thunderbolt, kwa kawaida utalazimika kutumia [kebo ya DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) ili ifanye kazi.
