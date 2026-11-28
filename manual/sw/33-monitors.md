# Skrini

Omarchy huchukulia kwa chaguo-msingi kuwa unatumia skrini ya kiwango cha retina yenye uwezo wa 2x. Hii ndiyo unayohitaji ili kupata fonti hizo nzuri, kali za watengenezaji programu. Ndiyo ambayo karibu kompyuta mpakato zote mpya za premium zenye skrini za ubora wa juu zimeboreshwa kwa ajili yake. Ndiyo ambayo ungependa kutumia kwenye 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) au 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Lakini kama hutumii skrini yenye PPI ya 218 au zaidi, utahitaji kubadilisha mipangilio ya skrini. Kwa mfano, kama una 27" au 32" 4K, unaweza kuchagua kipimo cha sehemu kwa ajili yake kutoka kwenye paneli ya skrini kwenye upau wa juu, au kuweka chaguo-msingi kwa kila skrini kwa kufungua `~/.config/hypr/monitors.lua` na kubadilisha kwenda kwenye pendekezo la mchanganyiko huo:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Kama unatumia skrini ya 1080p au 1440p, pengine utataka tu kutumia kipimo cha 1x, na vivyo hivyo kwa programu za GTK na X11, hivyo unaweza kutumia:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Mabadiliko ya `GDK_SCALE` hutumika kwa programu zinazoanzishwa baada ya mabadiliko (na GTK hukubali nambari kamili tu, hivyo iache kwenye nambari kamili iliyo karibu zaidi na kipimo cha skrini yako). Hivyo hakikisha umefunga madirisha uliyo nayo yaliyo makubwa kupita kiasi baada ya mabadiliko (au funga madirisha yote kwa `Ctrl + Alt + Del`!).

Unaweza pia kupita haraka kwenye uwiano mkuu wa vipimo vya skrini (1x, 1.25x, 1.6x, 2x, 3x, 4x) kwa kutumia `Super + /` kwenda juu na `Super + Alt + /` kwenda chini, au kuchagua kimoja kutoka kwenye paneli ya skrini kwenye upau wa juu. Hivi hubadilisha tu skrini uliyolenga, hivyo skrini ya kompyuta mpakato na skrini ya nje kila moja inaweza kuwa na kipimo chake. Paneli pia huweka kwa kila skrini ubora wake wa kuonyesha, kasi ya kuonyesha upya na mzunguko. Chaguo zako huhifadhiwa kwa skrini hiyo halisi katika `~/.local/state/omarchy/monitors/settings`, hivyo hudumu baada ya kuwasha upya na huifuata skrini kwenye mlango au doki yoyote itakayochomekwa baadaye. Huchukua nafasi ya kwanza kuliko kanuni yoyote ya skrini hiyo hiyo katika `~/.config/hypr/monitors.lua`, ambayo Omarchy haihariri kamwe. Kama ungependelea kuweka skrini zako kabisa katika faili hiyo, ongeza `omarchy_monitor_panel_settings = false` humo, na mabadiliko ya paneli yatadumu tu hadi Hyprland ipakie upya. Kwa kuwa `GDK_SCALE` ni thamani moja kwa skrini zote, kipimo kilichochaguliwa huiweka kutoka kwenye skrini yenye kipimo cha chini zaidi, hivyo programu za X11 hutokea ndogo kidogo kwenye skrini yenye msongamano mkubwa zaidi badala ya kuwa kubwa kupita kiasi kwenye nyingine.

### Kufanya maandishi kuwa makubwa au madogo

Kipimo cha skrini hubadilisha ukubwa wa kila kitu. Kama unachotaka ni _maandishi_ makubwa au madogo tu, kuna kifaa kimoja cha kudhibiti hilo:

```
omarchy display text size 14
```

Hicho huchukua ukubwa wa pikseli kati ya 9 na 20, na husogeza ganda la Omarchy, programu za GTK, na terminali yako kwa pamoja, hivyo eneo-kazi lote hubaki katika uwiano. Kiendeshe bila hoja ili kuona ulipo, na `omarchy display text size reset` ili kurudi kwenye chaguo-msingi. Foot ndiye aliyebaki nyuma pekee: haina njia ya kupakia upya usanidi wake, hivyo terminali zinazoendeshwa hubaki na ukubwa wao wa zamani hadi ufungue mpya.

### Kupanua na kuakisi skrini za kompyuta mpakato

Unapounganisha skrini ya nje kwenye kompyuta yako mpakato, skrini hupanuliwa kiotomatiki. Lakini unaweza kubadilisha hilo kuwa kuakisi badala yake kwa kutumia _Extend_ | _Mirror_ kwenye paneli ya skrini kwenye upau wa juu, _Trigger > Hardware_ kwenye menyu ya Omarchy, au `Super + Ctrl + Alt + Delete`. Hii ni muhimu hasa kama skrini hiyo ya nje ni projekta, na unataka kuonyesha kitu wakati unafanya kazi.

Unapopanua, kufunga kifuniko kwenye kompyuta mpakato kutazima kiotomatiki skrini ya ndani. Kufungua kifuniko kutaiwasha tena. Unaweza pia kudhibiti hii mwenyewe kwa kutumia _Trigger > Hardware_ kwenye menyu ya Omarchy au `Super + Ctrl + Delete`.

Wakati kompyuta mpakato imechomekwa kwenye umeme, kufunga kifuniko hakuiweki kamwe katika usingizi, hivyo kompyuta mpakato iliyowekwa kwenye doki hubaki macho hata kama skrini ya nje itajitenga kwa muda mfupi. Bila skrini ya nje iliyounganishwa, kufunga kifuniko ukiwa kwenye umeme huifunga tu. Kwenye betri, kufunga kifuniko huisitisha kama kawaida.

### Kupanga skrini nyingi

Hyprland hufanya kazi vizuri sana na skrini nyingi. Paneli ya skrini kwenye upau wa juu huzichora pale zilipo: buruta moja dhidi ya upande wa nyingine ili kuisogeza huko, na mpangilio huhifadhiwa pamoja na mipangilio mingine ya kila skrini. Kwa chochote ambacho paneli haishughulikii, soma zaidi kuhusu jinsi ya kuzipanga katika [nyaraka za skrini za Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Katika Omarchy, hizi huingia katika `~/.config/hypr/monitors.lua` kama maingizo ya `hl.monitor` — faili hiyo huja na mifano iliyotiwa maoni kwa ajili ya kuacha skrini ikiwa imezimwa, hali ambazo paneli haitoi, rangi ya biti 10, na kasi ya kuonyesha upya inayobadilika.

Kila skrini ina nafasi za kazi 1 hadi 10 za kwake, hivyo `Super + 1` humaanisha daima nafasi ya kazi ya kwanza ya skrini uliyopo. Nyuma ya pazia, Hyprland bado huweka nambari za nafasi za kazi kwenye skrini zote: skrini yako ya kompyuta mpakato (au skrini ya kwanza) hupata 1–10, skrini inayofuata 11–20, na kadhalika, na kila skrini huhifadhi kitalu chake kila unapoichomeka. Tumia nambari hizo kama unaandika [kanuni za nafasi za kazi](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) au kanuni za madirisha kwa skrini maalum, hivyo nafasi ya kazi 12 ni nafasi ya kazi ya pili ya skrini yako ya pili. `~/.local/state/omarchy/monitors/workspaces` huorodhesha ni kitalu gani kila skrini inacho.

Vitufe vya mishale hufanya kazi kwenye skrini zinazoshiriki ukingo katika mpangilio wako. Skrini zinazogusana tu kwenye kona, au zilizo na pengo kati yake, si majirani, hivyo tumia `Ctrl + Alt + Tab` ili kupita kati yake.

| Hotkey | Across monitors |
| --- | --- |
| `Super + Arrow` | Husogeza mwelekeo kwenye skrini iliyo upande huo mara tu kusiwe tena na dirisha lililobaki katika mwelekeo huo |
| `Super + Shift + Arrow` | Hubadilishana na dirisha kwenye skrini iliyo upande huo |
| `Super + Alt + Arrow` | Husogeza dirisha kwenye kikundi kwenye skrini iliyo upande huo |
| `Super + Shift + Ctrl + Arrow` | Husogeza dirisha kwenye skrini iliyo upande huo, kwenye nafasi ya kazi inayoonyesha |
| `Super + Shift + Alt + Arrow` | Husogeza nafasi ya kazi kwenye skrini iliyo upande huo, ikiweka nambari yake kama iko wazi |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Husogeza mwelekeo kwenye skrini inayofuata au iliyotangulia, chochote mpangilio ulivyo |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Hubaki kwenye skrini uliyopo |

Unaweza pia kuangalia [Hyprmon](https://github.com/erans/hyprmon/), kama ungependa TUI ikusaidie katika kuweka skrini nyingi.

### Kudhibiti mwangaza

Mwangaza wa skrini hudhibitiwa na vitufe maalum vya utendaji vya mwangaza juu/chini. Kama ukishikilia Shift wakati unabonyeza hivi, utakwenda kwenye mwangaza wa juu kabisa au wa chini kabisa. Vitufe hudhibiti skrini uliyolenga, hivyo skrini za nje zinazozungumza DDC/CI hurekebishwa kwa njia ile ile kama skrini ya kompyuta mpakato.

### Skrini za Apple

Kama unatumia skrini ya Apple, vitufe vya kawaida vya mwangaza vya kibodi pia vitafanya kazi kiotomatiki, kama umelenga skrini ya Apple. Hii hufanywa kupitia amri ya `asdcontrol`.

Kumbuka kuwa kama unatumia skrini ya Apple 6K XDR, unaweza kuona skrini ya mzuka katika orodha yako ya `hyprctl monitors`. Unaweza kuzima hii kwa kitu kama `hl.monitor({ output = "DP-2", disabled = true })` katika `~/.config/hypr/monitors.lua`.

Kwenye mashine za Intel, unapaswa kuunganisha kwenye skrini za Apple kwa kutumia kebo ya kawaida ya Thunderbolt. Kwenye mashine nyingine zisizo na Thunderbolt, kwa kawaida itabidi utumie [kebo ya DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) ili kuifanya ifanye kazi.
