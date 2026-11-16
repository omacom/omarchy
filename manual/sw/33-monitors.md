# Monita

Kwa chaguo-msingi, Omarchy hudhani unatumia onyesho la daraja la retina lenye uwezo wa 2x. Hiki ndicho unachohitaji ili upate fonti hizo nzuri, kali za waandishi wa programu. Ni kile ambacho karibu kompyuta mpakato zote mpya za bei ya juu zenye skrini za mwonekano wa juu zimeboreshwa kukitumia. Ni kile ambacho ungependa kukitumia kwenye 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) au 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Lakini kama hutumii onyesho lenye PPI ya 218 au zaidi, utahitaji kubadilisha mipangilio ya monita. Kwa mfano, kama una 4K ya 27" au 32", unaweza kuchagua kipimo cha sehemu kwa ajili yake kutoka kwenye paneli ya monita iliyo kwenye upau wa juu, au kuweka chaguo-msingi kwa kila monita kwa kufungua `~/.config/hypr/monitors.lua` na kubadilisha kwenda kwenye pendekezo la mchanganyiko huo:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Kama unatumia onyesho la 1080p au 1440p, huenda utataka tu kutumia ukuzaji wa 1x, na vivyo hivyo kwa programu za GTK na X11, hivyo unaweza kutumia:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Mabadiliko kwenye `GDK_SCALE` hutumika kwa programu zinazofunguliwa baada ya mabadiliko hayo (na GTK huheshimu nambari kamili pekee, hivyo iweke kwenye nambari kamili iliyo karibu zaidi na kipimo cha monita yako). Kwa hiyo hakikisha unafunga madirisha uliyo nayo yaliyokuwa makubwa kupita kiasi baada ya mabadiliko (au funga madirisha yote kwa `Ctrl + Alt + Del`!).

Unaweza pia kupitia haraka uwiano mkuu wa ukuzaji wa monita (1x, 1.25x, 1.6x, 2x, 3x, 4x) kwa kutumia `Super + /` kwenda juu zaidi na `Super + Alt + /` kwenda chini zaidi, au kuchagua kimoja kutoka kwenye paneli ya monita iliyo kwenye upau wa juu. Hizi hubadilisha tu monita unayoilenga, hivyo skrini ya kompyuta mpakato na onyesho la nje kila kimoja kinaweza kuwa na kipimo chake. Paneli pia huweka mwonekano, kasi ya uonyeshaji upya na mzunguko wa kila monita. Machaguo yako huhifadhiwa kwa monita hiyo halisi katika `~/.local/state/omarchy/monitors/settings`, hivyo hudumu hata baada ya kuwasha upya na huifuata monita kwenda kwenye mlango au doki yoyote itakayochomekwa baadae. Huwa na kipaumbele kuliko kanuni yoyote ya monita hiyo hiyo katika `~/.config/hypr/monitors.lua`, ambayo Omarchy haihariri kamwe. Kama ungependa kuweka monita zako yote katika faili hiyo, ongeza `omarchy_monitor_panel_settings = false` ndani yake, na mabadiliko ya paneli yatadumu tu hadi Hyprland itakapopakiwa upya. Kwa kuwa `GDK_SCALE` ni thamani moja kwa skrini zote, kipimo kilichochaguliwa huiweka kutoka kwenye monita yenye kipimo cha chini zaidi, hivyo programu za X11 hutokea ndogo kidogo kwenye skrini yenye msongamano mkubwa zaidi badala ya kuwa kubwa kupita kiasi kwenye nyingine.

### Kufanya maandishi yawe makubwa au madogo zaidi

Ukuzaji wa monita hubadilisha ukubwa wa kila kitu. Kama unachotaka ni _maandishi_ makubwa au madogo zaidi tu, kuna kifaa kimoja cha kudhibiti hilo:

```
omarchy display text size 14
```

Hiyo huchukua ukubwa wa pikseli kati ya 9 na 20, na husogeza ganda la Omarchy, programu za GTK, na terminali yako kwa pamoja, hivyo eneo-kazi lote hubaki katika uwiano unaofaa. Iendeshe bila hoja yoyote kuona ulipo, na `omarchy display text size reset` kurudi kwenye chaguo-msingi. Foot ndiyo iliyobaki nyuma: haina njia ya kupakia upya usanidi wake, hivyo terminali zinazoendelea huweka ukubwa wao wa zamani hadi utakapofungua mpya.

### Kupanua na kunakili maonyesho ya kompyuta mpakato

Unapounganisha skrini ya nje kwenye kompyuta yako mpakato, onyesho hupanuliwa kiotomatiki. Lakini unaweza kubadilisha hilo kuwa kunakili badala yake kwa kutumia _Trigger > Hardware_ katika menyu ya Omarchy au `Super + Ctrl + Alt + Delete`. Hii ni muhimu hasa kama skrini hiyo ya nje ni projekta, na unataka kuonyesha kitu huku ukifanya kazi.

Unapopanua, kufunga kifuniko cha kompyuta mpakato kutazima skrini ya ndani kiotomatiki. Kufungua kifuniko kutairejesha. Unaweza pia kudhibiti hili mwenyewe kwa kutumia _Trigger > Hardware_ katika menyu ya Omarchy au `Super + Ctrl + Delete`.

### Kupanga skrini nyingi

Hyprland hufanya kazi vizuri sana na skrini nyingi. Paneli ya monita iliyo kwenye upau wa juu huzichora pale zilipo: buruta moja dhidi ya upande wa nyingine kuisogeza hapo, na mpangilio huhifadhiwa pamoja na mipangilio mingine ya kila monita. Kwa chochote ambacho paneli haishughulikii, soma zaidi kuhusu jinsi ya kuzipanga katika [nyaraka za monita za Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Katika Omarchy, hizi huenda katika `~/.config/hypr/monitors.lua` kama viingilio vya `hl.monitor` — faili huja na mifano iliyofafanuliwa ya kuweka monita ikiwa imezimwa, hali ambazo paneli haitoi, rangi ya 10-bit, na kasi ya uonyeshaji upya inayobadilika.

Kila monita ina maeneo ya kazi 1 hadi 10 yake yenyewe, hivyo `Super + 1` humaanisha daima eneo la kazi la kwanza la monita uliyopo. Nyuma ya pazia, Hyprland bado hutoa nambari za maeneo ya kazi katika monita zote: skrini ya kompyuta yako mpakato (au monita ya kwanza) hupata 1–10, monita inayofuata 11–20, na kuendelea, na kila monita huhifadhi kizuizi chake kila unapoichomeka. Tumia nambari hizo kama unaandika [kanuni za maeneo ya kazi](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) au kanuni za madirisha kwa monita mahususi, hivyo eneo la kazi 12 ni eneo la kazi la pili la monita yako ya pili. `~/.local/state/omarchy/monitors/workspaces` huorodhesha ni kizuizi gani kila monita inacho.

Vitufe vya mishale hufanya kazi katika monita zinazoshiriki ukingo katika mpangilio wako. Skrini zinazogusana kwenye kona tu, au zenye pengo kati yake, si majirani, hivyo tumia `Ctrl + Alt + Tab` kusafiri kati yake.

| Kitufe cha mkato | Kati ya monita |
| --- | --- |
| `Super + Arrow` | Husogeza lengo kwenda kwenye monita iliyo upande huo mara tu kunapokuwa hakuna dirisha lililobaki katika mwelekeo huo |
| `Super + Shift + Arrow` | Hubadilishana na dirisha lililo kwenye monita iliyo upande huo |
| `Super + Alt + Arrow` | Husogeza dirisha ndani ya kikundi kilicho kwenye monita iliyo upande huo |
| `Super + Shift + Ctrl + Arrow` | Husogeza dirisha kwenda kwenye monita iliyo upande huo, kwenye eneo la kazi inaloonyesha |
| `Super + Shift + Alt + Arrow` | Husogeza eneo la kazi kwenda kwenye monita iliyo upande huo, ikiweka nambari yake kama iko wazi |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Husogeza lengo kwenda kwenye monita inayofuata au iliyotangulia, chochote kiwe mpangilio |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Hubaki kwenye monita uliyopo |

Unaweza pia kuangalia [Hyprmon](https://github.com/erans/hyprmon/), kama ungependa TUI ikusaidie katika uwekaji wa skrini nyingi.

### Kudhibiti mwangaza

Mwangaza wa monita hudhibitiwa na vitufe maalum vya utendakazi vya kuongeza/kupunguza mwangaza. Kama utashikilia shift huku ukibonyeza hivi, utaenda kwenye mwangaza wa juu zaidi au wa chini zaidi. Vitufe hudhibiti onyesho unalolilenga, hivyo monita za nje zinazozungumza DDC/CI hurekebishwa kwa njia sawa na skrini ya kompyuta mpakato.

### Maonyesho ya Apple

Kama unatumia onyesho la Apple, vitufe vya kawaida vya mwangaza vya kibodi pia vitafanya kazi kiotomatiki, kama umelilenga onyesho la Apple. Hii hufanywa kupitia amri ya `asdcontrol`.

Kumbuka kuwa kama unatumia onyesho la Apple 6K XDR, unaweza kuona skrini ya mzuka katika orodha yako ya `hyprctl monitors`. Unaweza kuzima hii kwa kitu kama `hl.monitor({ output = "DP-2", disabled = true })` katika `~/.config/hypr/monitors.lua`.

Kwenye mashine za Intel, unapaswa kuunganisha kwenye maonyesho ya Apple kwa kutumia kebo ya kawaida ya Thunderbolt. Kwenye mashine nyingine zisizo na Thunderbolt, kwa kawaida utalazimika kutumia [kebo ya DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) ili ifanye kazi.
