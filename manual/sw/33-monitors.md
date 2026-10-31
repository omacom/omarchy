# Monita

Omarchy hudhani kuwa unatumia onyesho la kiwango cha retina lenye uwezo wa 2x kwa chaguo-msingi. Hiki ndicho unachohitaji ili kupata fonti hizo nzuri na kali za programu. Ndicho karibu kompyuta mpakato zote mpya za bei ya juu zenye skrini za ubora wa juu zimeboreshwa kukitumia. Ndicho ungependa kutumia kwenye 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) au 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Lakini kama hutumii onyesho lenye PPI wa 218 au zaidi, utahitaji kubadilisha mipangilio ya monita. Kwa mfano, kama una 4K ya 27" au 32", unaweza kuchagua kipimo cha sehemu kwake kutoka kwenye paneli ya monita iliyo kwenye upau wa juu, au kuweka chaguo-msingi kwa kila monita kwa kufungua `~/.config/hypr/monitors.lua` na kubadili kwenda kwenye pendekezo la mchanganyiko huo:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Kama unatumia onyesho la 1080p au 1440p, huenda utataka tu kutumia kipimo cha 1x, na vivyo hivyo kwa programu za GTK na X11, hivyo unaweza kutumia:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Mabadiliko kwenye `GDK_SCALE` hutumika kwa programu zinazoanzishwa baada ya mabadiliko (na GTK hukubali nambari kamili tu, hivyo iweke kwenye nambari kamili iliyo karibu zaidi na kipimo cha monita yako). Hivyo hakikisha unafunga madirisha uliyo nayo ambayo ni makubwa kupita kiasi baada ya mabadiliko (au funga madirisha yote kwa `Ctrl + Alt + Del`!).

Unaweza pia kupita haraka kupitia uwiano mkuu wa vipimo vya monita (1x, 1.25x, 1.6x, 2x, 3x, 4x) kwa kutumia `Super + /` kwenda juu zaidi na `Super + Alt + /` kwenda chini zaidi, au kuchagua kimoja kutoka kwenye paneli ya monita iliyo kwenye upau wa juu. Hizi hubadilisha tu monita uliyoilenga, hivyo skrini ya kompyuta mpakato na onyesho la nje kila kimoja kinaweza kuwa na kipimo chake. Paneli pia huweka ubora wa kila monita. Chaguo zako huhifadhiwa kwa monita hiyo halisi katika `~/.local/state/omarchy/monitors/settings`, hivyo hubaki baada ya kuwasha upya na huifuata monita kwenye mlango au doki yoyote itakayochomekwa baadaye. Huchukua nafasi ya kwanza dhidi ya kanuni yoyote ya monita hiyo hiyo katika `~/.config/hypr/monitors.lua`, ambayo Omarchy haihariri kamwe. Kwa kuwa `GDK_SCALE` ni thamani moja kwa skrini zote, kipimo kilichochaguliwa huiweka kutoka kwenye monita yenye kipimo kidogo zaidi, hivyo programu za X11 hutokea ndogo kidogo kwenye skrini yenye msongamano mkubwa zaidi badala ya kuwa kubwa kupita kiasi kwenye nyingine.

### Kufanya maandishi yawe makubwa au madogo

Kipimo cha monita hubadilisha ukubwa wa kila kitu. Kama unachotaka tu ni maandishi makubwa au madogo _zaidi_, kuna kipimo kimoja tu kwa hilo:

```
omarchy display text size 14
```

Hiyo huchukua ukubwa wa pikseli kati ya 9 na 20, na husogeza shell ya Omarchy, programu za GTK, na terminali yako pamoja, hivyo eneo-kazi lote hubaki kwa uwiano. Itumie bila hoja kuona ulipo, na `omarchy display text size reset` kurudi kwenye chaguo-msingi. Foot ndiyo iliyobaki nyuma pekee: haina njia ya kupakia upya usanidi wake, hivyo terminali zinazoendeshwa hubaki na ukubwa wake wa zamani hadi ufungue mpya.

### Kueneza na kuakisi skrini za kompyuta mpakato

Unapounganisha skrini ya nje kwenye kompyuta yako mpakato, onyesho huenezwa kiotomatiki. Lakini unaweza kubadilisha hilo kuwa uakisi badala yake kwa kutumia _Trigger > Hardware_ katika menyu ya Omarchy au `Super + Ctrl + Alt + Delete`. Hii ni muhimu hasa kama skrini hiyo ya nje ni projekta, na unataka kuonyesha kitu wakati unafanya kazi.

Unapoeneza, kufunga kifuniko cha kompyuta mpakato kutazima skrini ya ndani kiotomatiki. Kufungua kifuniko kutairejesha. Unaweza pia kudhibiti hili mwenyewe kwa kutumia _Trigger > Hardware_ katika menyu ya Omarchy au `Super + Ctrl + Delete`.

### Kupanga skrini nyingi

Hyprland hufanya kazi vizuri sana na skrini nyingi. Paneli ya monita iliyo kwenye upau wa juu huzichora pale zilipo: buruta moja dhidi ya upande wa nyingine kuisogeza hapo, na mpangilio huhifadhiwa pamoja na mipangilio mingine ya kila monita. Kwa chochote ambacho paneli haishughulikii, soma zaidi kuhusu jinsi ya kuzipanga katika [nyaraka za Hyprland kuhusu monita](https://wiki.hypr.land/Configuring/Basics/Monitors/). Katika Omarchy, hizi huenda katika `~/.config/hypr/monitors.lua` kama vipengee vya `hl.monitor` — faili huja na mifano iliyotolewa maoni ya kubandika monita mahususi kwenye ubora, nafasi, na mzunguko.

Kila monita ina nafasi za kazi 1 hadi 10 zake, hivyo `Super + 1` daima humaanisha nafasi ya kwanza ya kazi ya monita uliyo nayo. Nyuma ya pazia, Hyprland bado huhesabu nafasi za kazi katika monita zote: skrini yako ya kompyuta mpakato (au monita ya kwanza) hupata 1–10, monita inayofuata 11–20, na kuendelea, na kila monita huhifadhi kitalu chake kila unapoichomeka. Tumia nambari hizo kama unaandika [kanuni za nafasi za kazi](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) au kanuni za madirisha kwa monita mahususi, hivyo nafasi ya kazi 12 ni nafasi ya pili ya kazi ya monita yako ya pili. `~/.local/state/omarchy/monitors/workspaces` huorodhesha kitalu gani kila monita inacho.

Vitufe vya mishale hufanya kazi katika monita zinazoshiriki ukingo katika mpangilio wako. Skrini zinazogusana tu kwenye kona, au zenye pengo kati yake, si majirani, hivyo tumia `Ctrl + Alt + Tab` kupita kati yake.

| Kitufe cha Mkato | Kati ya monita |
| --- | --- |
| `Super + Arrow` | Husogeza lengo kwenye monita iliyo upande huo mara tu kunapokuwa hakuna dirisha lililobaki katika mwelekeo huo |
| `Super + Shift + Arrow` | Hubadilishana na dirisha lililo kwenye monita iliyo upande huo |
| `Super + Alt + Arrow` | Husogeza dirisha kwenye kikundi kilicho kwenye monita iliyo upande huo |
| `Super + Shift + Ctrl + Arrow` | Husogeza dirisha kwenye monita iliyo upande huo, kwenye nafasi ya kazi inayoonyesha |
| `Super + Shift + Alt + Arrow` | Husogeza nafasi ya kazi kwenye monita iliyo upande huo, ikiweka nambari yake kama iko wazi |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Husogeza lengo kwenye monita inayofuata au iliyotangulia, chochote mpangilio ulivyo |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Hubaki kwenye monita uliyo nayo |

Unaweza pia kuangalia [Hyprmon](https://github.com/erans/hyprmon/), kama ungependa TUI ikusaidie katika uwekaji wa skrini nyingi.

### Kudhibiti mwangaza

Mwangaza wa monita hudhibitiwa na vitufe maalum vya kazi vya kuongeza/kupunguza mwangaza. Kama utashikilia shift wakati unabonyeza hivi, utaenda kwenye mwangaza wa juu zaidi au wa chini zaidi. Vitufe hudhibiti onyesho ulilolilenga, hivyo monita za nje zinazozungumza DDC/CI hurekebishwa kwa njia sawa na skrini ya kompyuta mpakato.

### Skrini za Apple

Kama unatumia onyesho la Apple, vitufe vya kawaida vya mwangaza vya kibodi pia vitafanya kazi kiotomatiki, kama umelenga onyesho la Apple. Hii hufanywa kupitia amri ya `asdcontrol`.

Kumbuka kuwa kama unatumia onyesho la Apple 6K XDR, unaweza kuona skrini ya mzuka katika orodha yako ya `hyprctl monitors`. Unaweza kuzima hii kwa kitu kama `hl.monitor({ output = "DP-2", disabled = true })` katika `~/.config/hypr/monitors.lua`.

Kwenye mashine za Intel, unapaswa kuunganisha kwenye maonyesho ya Apple kwa kutumia kebo ya kawaida ya Thunderbolt. Kwenye mashine nyingine zisizo na Thunderbolt, kwa kawaida itakubidi kutumia [kebo ya DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) kuifanya ifanye kazi.
