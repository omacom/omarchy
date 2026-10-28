# Monita

Omarchy hudhani kwa chaguo-msingi kuwa unatumia skrini ya kiwango cha retina yenye uwezo wa 2x. Hii ndiyo unayohitaji ili kupata fonti hizo nzuri na kali za wapangaji programu. Ndiyo ambayo karibu kompyuta mpakato zote mpya za bei ghali zenye skrini za ubora wa juu zimeboreshwa kwayo. Ndiyo ambayo ungependa kuitumia kwenye [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ya inchi 27" 5K au [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) ya inchi 32" 6K.

Lakini ikiwa hutumii skrini yenye PPI ya 218 au zaidi, utataka kubadilisha mipangilio ya monita. Kwa mfano, ikiwa una 4K ya inchi 27" au 32", unaweza kutumia ukuzaji wa sehemu kwa kufungua `~/.config/hypr/monitors.lua` (kupitia _Usanidi > Monita_ katika menyu ya Omarchy) na kubadili kwenda kwenye pendekezo la mchanganyiko huo:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Ikiwa unatumia skrini ya 1080p au 1440p, pengine utataka tu kutumia ukuzaji wa 1x, hivyo unaweza kutumia:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Mabadiliko kwenye `GDK_SCALE` hutumika kwa programu zinazoanzishwa baada ya mabadiliko (na GTK hukubali nambari kamili pekee, hivyo iache kwenye nambari kamili iliyo karibu zaidi na ukuzaji wa monita yako). Hivyo hakikisha unafunga madirisha uliyo nayo ambayo ni makubwa kupita kiasi baada ya mabadiliko (au funga madirisha yote kwa `Ctrl + Alt + Del`!).

Unaweza pia kupitia haraka uwiano mkuu wa ukuzaji wa monita (1x, 1.25x, 1.6x, 2x, 3x, 4x) kwa kutumia `Super + /` kwenda juu zaidi na `Super + Alt + /` kwenda chini zaidi, au chagua moja kutoka paneli ya monita kwenye upau wa juu. Hizi hubadilisha monita uliyolenga pekee, hivyo skrini ya kompyuta mpakato na skrini ya nje kila moja inaweza kuwa na ukuzaji wake. Chaguo huhifadhiwa kwenye `~/.config/hypr/monitors.lua` kama kanuni ya `hl.monitor` kwa monita hiyo, hivyo hudumu baada ya kuwasha upya na hutangulika kuliko `omarchy_monitor_scale`, ambayo hubakia kuwa ukuzaji wa kila monita isiyo na kanuni yake yenyewe.

### Kufanya maandishi yawe makubwa au madogo zaidi

Ukuzaji wa monita hubadilisha ukubwa wa kila kitu. Ikiwa unachotaka ni maandishi makubwa au madogo _zaidi_ pekee, kuna kidhibiti kimoja kwa hilo:

```
omarchy display text size 14
```

Hiyo huchukua ukubwa wa pikseli kati ya 9 na 20, na husogeza ganda la Omarchy, programu za GTK, na terminali yako kwa pamoja, hivyo eneo-kazi lote hubakia kwa uwiano. Iendeshe bila hoja yoyote kuona ulipo, na `omarchy display text size reset` kurudi kwenye chaguo-msingi. Foot ndiyo iliyobaki nyuma pekee: haina njia ya kupakia upya usanidi wake, hivyo terminali zinazoendeshwa hubakia na ukubwa wake wa zamani hadi ufungue mpya.

### Kupanua na kuakisi skrini za kompyuta mpakato

Unapounganisha skrini ya nje kwenye kompyuta yako mpakato, skrini hupanuliwa kiotomatiki. Lakini unaweza kubadilisha hiyo kuwa kuakisi badala yake kwa kutumia _Kichocheo > Vifaa_ katika menyu ya Omarchy au `Super + Ctrl + Alt + Delete`. Hii ni muhimu hasa ikiwa skrini hiyo ya nje ni projekta, na unataka kuonyesha kitu wakati unafanya kazi.

Unapopanua, kufunga kifuniko cha kompyuta mpakato huzima skrini ya ndani kiotomatiki. Kufungua kifuniko huirudisha. Unaweza pia kudhibiti hii mwenyewe kwa kutumia _Kichocheo > Vifaa_ katika menyu ya Omarchy au `Super + Ctrl + Delete`.

### Kupanga skrini nyingi

Hyprland hufanya kazi vizuri na skrini nyingi. Soma zaidi kuhusu jinsi ya kuzipanga katika [nyaraka za monita za Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Katika Omarchy, hizi huwekwa kwenye `~/.config/hypr/monitors.lua` kama viingilio vya `hl.monitor` — faili huja na mifano iliyotiwa maoni ya kuambatisha monita maalum kwenye ubora, mahali, na mzunguko maalum.

Kila monita ina nafasi za kazi 1 hadi 10 za kwake, hivyo `Super + 1` humaanisha daima nafasi ya kazi ya kwanza ya monita uliyo juu yake. Nyuma ya pazia, Hyprland bado huweka nambari za nafasi za kazi kwenye monita zote: skrini ya kompyuta yako mpakato (au monita ya kwanza) hupata 1–10, monita inayofuata 11–20, na kuendelea, na kila monita huweka kitalu chake kila unapoichomeka. Tumia nambari hizo ikiwa unaandika [kanuni za nafasi za kazi](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) au kanuni za madirisha kwa monita maalum, hivyo nafasi ya kazi 12 ni nafasi ya kazi ya pili ya monita yako ya pili. `~/.local/state/omarchy/monitor-workspaces` huorodhesha kitalu gani kila monita ina.

Vitufe vya mishale hufanya kazi kwenye monita zinazoshiriki ukingo katika mpangilio wako. Skrini zinazogusana kwenye kona pekee, au zilizo na pengo kati yao, si majirani, hivyo tumia `Ctrl + Alt + Tab` kufika kati yao.

| Kitufe cha mkato | Kwenye monita |
| --- | --- |
| `Super + Arrow` | Husogeza lengo kwenye monita ya upande huo mara tu kunapokuwa hakuna dirisha lililobaki upande huo |
| `Super + Shift + Arrow` | Hubadilishana na dirisha kwenye monita ya upande huo |
| `Super + Alt + Arrow` | Husogeza dirisha kwenye kikundi kwenye monita ya upande huo |
| `Super + Shift + Ctrl + Arrow` | Husogeza dirisha kwenye monita ya upande huo, kwenye nafasi ya kazi inayoonyesha |
| `Super + Shift + Alt + Arrow` | Husogeza nafasi ya kazi kwenye monita ya upande huo, ikiweka nambari yake ikiwa iko wazi |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Husogeza lengo kwenye monita inayofuata au iliyotangulia, chochote mpangilio ulivyo |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Baki kwenye monita uliyo juu yake |

Unaweza pia kuangalia [Hyprmon](https://github.com/erans/hyprmon/), ikiwa ungependa TUI ikusaidie na uwekaji wa skrini nyingi.

### Kudhibiti mwangaza

Mwangaza wa monita hudhibitiwa na vitufe maalum vya utendaji vya kuongeza/kupunguza mwangaza. Ikiwa utashikilia shift unapobonyeza hivi, utaenda kwenye mwangaza wa juu zaidi au wa chini zaidi. Vitufe hudhibiti skrini uliyolenga, hivyo monita za nje zinazozungumza DDC/CI hurekebishwa kwa njia sawa na skrini ya kompyuta mpakato.

### Skrini za Apple

Ikiwa unatumia skrini ya Apple, vitufe vya kawaida vya mwangaza vya kibodi pia vitafanya kazi kiotomatiki, ikiwa umelenga skrini ya Apple. Hii hufanywa kupitia amri ya `asdcontrol`.

Kumbuka kuwa ikiwa unatumia skrini ya Apple 6K XDR, unaweza kuona skrini ya mzuka katika orodha yako ya `hyprctl monitors`. Unaweza kuzima hii kwa kitu kama `hl.monitor({ output = "DP-2", disabled = true })` kupitia _Usanidi > Monita_.

Kwenye mashine za Intel, unapaswa kuunganisha kwenye skrini za Apple kwa kutumia kebo ya kawaida ya Thunderbolt. Kwenye mashine nyingine zisizo na Thunderbolt, kwa kawaida utahitaji kutumia [kebo ya DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) ili ifanye kazi.
