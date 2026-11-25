# Skrini

Omarchy, kwa chaguomsingi, inadhani unatumia skrini ya kiwango cha retina yenye uwezo wa 2x. Hii ndiyo unayohitaji ili kupata fonti hizo nzuri na safi za watengenezaji programu. Karibu kompyuta mpakato zote mpya za bei ghali zenye skrini za ubora wa juu zimeboreshwa kwa ajili ya hili. Hivi ndivyo ungependa kutumia kwenye 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) au 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Lakini ikiwa hutumii skrini yenye PPI ya 218 au zaidi, utahitaji kubadilisha mipangilio ya skrini. Kwa mfano, ikiwa una 4K ya 27" au 32", unaweza kuchagua kipimo cha sehemu kwa ajili yake kutoka kwenye paneli ya skrini iliyo kwenye upau wa juu, au kuweka chaguomsingi kwa kila skrini kwa kufungua `~/.config/hypr/monitors.lua` na kubadili hadi mapendekezo ya mchanganyiko huo:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Ikiwa unatumia skrini ya 1080p au 1440p, pengine utahitaji tu kutumia upimaji wa 1x, na vivyo hivyo kwa programu za GTK na X11, kwa hivyo unaweza kutumia:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Mabadiliko kwenye `GDK_SCALE` hutumika kwa programu zinazoanzishwa baada ya mabadiliko (na GTK hukubali nambari kamili pekee, kwa hivyo iweke kwenye nambari kamili iliyo karibu zaidi na kipimo cha skrini yako). Kwa hivyo hakikisha unayafunga madirisha uliyo nayo ambayo ni makubwa kupita kiasi baada ya mabadiliko (au funga madirisha yote kwa `Ctrl + Alt + Del`!).

Unaweza pia kupita haraka katika uwiano mkuu wa upimaji wa skrini (1x, 1.25x, 1.6x, 2x, 3x, 4x) kwa kutumia `Super + /` kwenda juu zaidi na `Super + Alt + /` kwenda chini zaidi, au kuchagua moja kutoka kwenye paneli ya skrini iliyo kwenye upau wa juu. Hizi hubadilisha skrini unayoiangalia pekee, kwa hivyo skrini ya kompyuta mpakato na skrini ya nje zinaweza kila moja kuwa na kipimo chake. Paneli pia huweka azimio, kiwango cha kuonyesha upya na mzunguko wa kila skrini. Chaguo zako huhifadhiwa kwa skrini hiyo halisi katika `~/.local/state/omarchy/monitors/settings`, kwa hivyo hudumu baada ya kuwasha upya na huifuata skrini hadi kwenye mlango au kituo chochote itakachochomekwa baadaye. Zinachukua nafasi ya kwanza kuliko sheria yoyote ya skrini hiyo hiyo katika `~/.config/hypr/monitors.lua`, ambayo Omarchy haihariri kamwe. Ikiwa ungependa kuweka skrini zako kabisa katika faili hiyo, ongeza `omarchy_monitor_panel_settings = false` humo, na mabadiliko ya paneli yatadumu hadi Hyprland itakapopakia upya tu. Kwa kuwa `GDK_SCALE` ni thamani moja kwa skrini zote, kipimo kilichochaguliwa huiweka kutoka kwenye skrini yenye kipimo cha chini kabisa, kwa hivyo programu za X11 hutokea ndogo kidogo kwenye skrini yenye msongamano mkubwa zaidi badala ya kuwa kubwa kupita kiasi kwenye nyingine.

### Kufanya maandishi kuwa makubwa au madogo

Upimaji wa skrini hubadilisha ukubwa wa kila kitu. Ikiwa unachotaka pekee ni _maandishi_ makubwa au madogo zaidi, kuna kidhibiti kimoja tu kwa ajili hiyo:

```
omarchy display text size 14
```

Hiyo huchukua ukubwa wa pikseli kati ya 9 na 20, na husogeza ganda la Omarchy, programu za GTK, na terminali yako kwa pamoja, ili eneo-kazi lote libaki katika uwiano. Iendeshe bila hoja yoyote ili kuona ulipo, na `omarchy display text size reset` ili kurudi kwenye chaguomsingi. Foot ndiyo iliyobaki nyuma: haina njia ya kupakia upya usanidi wake, kwa hivyo terminali zinazoendeshwa hubaki na ukubwa wake wa zamani hadi utakapofungua mpya.

### Kupanua na kuakisi skrini za kompyuta mpakato

Unapounganisha skrini ya nje kwenye kompyuta yako mpakato, skrini hupanuliwa kiotomatiki. Lakini unaweza kubadilisha hiyo na kuwa uakisi badala yake kwa _Extend_ | _Mirror_ katika paneli ya skrini iliyo kwenye upau wa juu, _Trigger > Hardware_ katika menyu ya Omarchy, au `Super + Ctrl + Alt + Delete`. Hii ni muhimu hasa ikiwa skrini hiyo ya nje ni projekta, na unataka kuonyesha kitu unapofanya kazi.

Unapopanua, kufunga kifuniko cha kompyuta mpakato kutazima skrini ya ndani kiotomatiki. Kufungua kifuniko kutaiwasha tena. Unaweza pia kudhibiti hili mwenyewe kwa kutumia _Trigger > Hardware_ katika menyu ya Omarchy au `Super + Ctrl + Delete`.

### Kupanga skrini nyingi

Hyprland hufanya kazi vizuri sana na skrini nyingi. Paneli ya skrini iliyo kwenye upau wa juu huzichora pale zilipo: buruta moja dhidi ya upande wa nyingine ili kuisogeza huko, na mpangilio huhifadhiwa pamoja na mipangilio mingine ya kila skrini. Kwa chochote ambacho paneli haishughulikii, soma zaidi kuhusu jinsi ya kuzipanga katika [nyaraka za skrini za Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Katika Omarchy, hizi huenda katika `~/.config/hypr/monitors.lua` kama viingizo vya `hl.monitor` — faili huja na mifano iliyotiwa maoni ya kuweka skrini ikiwa imezimwa, modi ambazo paneli haitoi, rangi ya 10-bit, na kiwango cha kuonyesha upya kinachobadilika.

Kila skrini ina maeneo yake ya kazi 1 hadi 10 yenyewe, kwa hivyo `Super + 1` kila mara humaanisha eneo la kwanza la kazi la skrini uliyo juu yake. Nyuma ya pazia, Hyprland bado huweka nambari za maeneo ya kazi katika skrini zote: skrini yako ya kompyuta mpakato (au skrini ya kwanza) hupata 1–10, skrini inayofuata 11–20, na kadhalika, na kila skrini huhifadhi kitalu chake kila unapoichomeka. Tumia nambari hizo ikiwa unaandika [sheria za eneo la kazi](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) au sheria za madirisha kwa skrini mahususi, ili eneo la kazi 12 liwe eneo la pili la kazi la skrini yako ya pili. `~/.local/state/omarchy/monitors/workspaces` huorodhesha kitalu ambacho kila skrini inacho.

Vitufe vya mishale hufanya kazi katika skrini zinazoshiriki ukingo katika mpangilio wako. Skrini zinazogusana kwenye kona pekee, au zenye pengo kati yake, si majirani, kwa hivyo tumia `Ctrl + Alt + Tab` kusogea kati yake.

| Hotkey | Kupitia skrini |
| --- | --- |
| `Super + Arrow` | Husogeza mwelekeo kwenye skrini iliyo upande huo mara tu kunapokuwa hakuna dirisha lililobaki katika mwelekeo huo |
| `Super + Shift + Arrow` | Hubadilishana na dirisha lililo kwenye skrini iliyo upande huo |
| `Super + Alt + Arrow` | Husogeza dirisha kwenye kikundi kilicho kwenye skrini iliyo upande huo |
| `Super + Shift + Ctrl + Arrow` | Husogeza dirisha kwenye skrini iliyo upande huo, kwenye eneo la kazi inaloonyesha |
| `Super + Shift + Alt + Arrow` | Husogeza eneo la kazi kwenye skrini iliyo upande huo, likihifadhi nambari yake ikiwa ni wazi |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Husogeza mwelekeo kwenye skrini inayofuata au iliyotangulia, bila kujali mpangilio |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Hubaki kwenye skrini uliyo juu yake |

Unaweza pia kuangalia [Hyprmon](https://github.com/erans/hyprmon/), ikiwa ungependa TUI ikusaidie katika uwekaji wa nafasi za skrini nyingi.

### Kudhibiti mwangaza

Mwangaza wa skrini hudhibitiwa na vitufe maalum vya utendaji vya kuongeza na kupunguza mwangaza. Ukishikilia Shift unapobonyeza vitufe hivi, utaenda kwenye mwangaza wa juu kabisa au wa chini kabisa. Vitufe hudhibiti skrini unayoiangalia, kwa hivyo skrini za nje zinazotumia DDC/CI hurekebishwa kwa njia sawa na skrini ya kompyuta mpakato.

### Skrini za Apple

Ikiwa unatumia skrini ya Apple, vitufe vya kawaida vya mwangaza vya kibodi pia vitafanya kazi kiotomatiki, ikiwa umeangalia skrini ya Apple. Hii hufanywa kupitia amri ya `asdcontrol`.

Kumbuka kuwa ikiwa unatumia skrini ya Apple 6K XDR, unaweza kuona skrini ya mzuka katika orodha yako ya `hyprctl monitors`. Unaweza kuizima kwa kitu kama `hl.monitor({ output = "DP-2", disabled = true })` katika `~/.config/hypr/monitors.lua`.

Kwenye mashine za Intel, unapaswa kuunganisha kwenye skrini za Apple kwa kutumia kebo ya kawaida ya Thunderbolt. Kwenye mashine nyingine zisizo na Thunderbolt, kwa kawaida utalazimika kutumia [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) ili ifanye kazi.
