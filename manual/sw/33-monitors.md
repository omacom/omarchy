# Monita

Omarchy huchukulia kuwa unatumia onyesho lenye uwezo wa 2x la daraja la retina kwa chaguo-msingi. Hivi ndivyo unavyohitaji ili kupata fonti hizo nzuri, kali za waandaaji programu. Ni kile ambacho takriban kompyuta mpakato zote mpya za bei ya juu zenye skrini za ubora wa juu zimeboreshwa kukitumia. Ni kile ambacho ungependa kutumia kwenye [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ya 27" 5K au [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) ya 32" 6K.

Lakini ikiwa hutumii onyesho lenye PPI ya 218 au zaidi, utataka kubadilisha mipangilio ya monita. Kwa mfano, ikiwa una 4K ya 27" au 32", unaweza kutumia ukuzaji wa sehemu kwa kufungua `~/.config/hypr/monitors.lua` (kupitia _Setup > Monitors_ kwenye menyu ya Omarchy) na kubadilisha kwenda kwenye pendekezo la mchanganyiko huo:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Ikiwa unatumia onyesho la 1080p au 1440p, huenda utataka tu kutumia ukuzaji wa 1x, kwa hivyo unaweza kutumia:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Mabadiliko ya `GDK_SCALE` hutumika kwa programu zilizoanzishwa baada ya mabadiliko (na GTK hukubali namba kamili tu, kwa hivyo iweke kwenye namba kamili iliyo karibu zaidi na ukuzaji wa monita yako). Kwa hivyo hakikisha unafunga madirisha uliyo nayo ambayo ni makubwa kupita kiasi baada ya mabadiliko (au funga madirisha yote kwa `Ctrl + Alt + Del`!).

Unaweza pia kupitia haraka uwiano mkuu wa ukuzaji wa monita (1x, 1.25x, 1.6x, 2x, 3x, 4x) kwa kutumia `Super + /` kwenda juu na `Super + Alt + /` kwenda chini. Ikiwa una usanidi chaguo-msingi, mabadiliko haya pia yatadumu baada ya kuwasha upya.

### Kufanya maandishi kuwa makubwa au madogo

Ukuzaji wa monita hubadilisha ukubwa wa kila kitu. Ikiwa unachotaka tu ni _maandishi_ makubwa au madogo, kuna kitufe kimoja cha kufanya hivyo:

```
omarchy display text size 14
```

Hiyo huchukua ukubwa wa pikseli kati ya 9 na 20, na husogeza ganda la Omarchy, programu za GTK, na terminali yako kwa pamoja, ili eneo-kazi lote libaki katika uwiano. Iendeshe bila hoja ili kuona ulipo, na `omarchy display text size reset` ili kurudi kwenye chaguo-msingi. Foot ndiyo iliyobaki nyuma pekee: haina njia ya kupakia upya usanidi wake, kwa hivyo terminali zinazoendeshwa hubaki na ukubwa wao wa zamani hadi ufungue mpya.

### Kupanua na kuakisi skrini za kompyuta mpakato

Unapounganisha skrini ya nje kwenye kompyuta yako mpakato, onyesho hupanuliwa kiotomatiki. Lakini unaweza kubadilisha hilo kuwa kuakisi badala yake kwa kutumia _Trigger > Hardware_ kwenye menyu ya Omarchy au `Super + Ctrl + Alt + Delete`. Hii ni muhimu hasa ikiwa skrini hiyo ya nje ni projekta, na unataka kuonyesha kitu huku ukifanya kazi.

Unapopanua, kufunga mfuniko wa kompyuta mpakato kutazima skrini ya ndani kiotomatiki. Kufungua mfuniko kutairejesha. Unaweza pia kudhibiti hili mwenyewe kwa kutumia _Trigger > Hardware_ kwenye menyu ya Omarchy au `Super + Ctrl + Delete`.

### Kupanga skrini nyingi

Hyprland hufanya kazi vizuri sana na skrini nyingi. Soma zaidi kuhusu jinsi ya kuzipanga katika [hati za monita za Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Katika Omarchy, hizi huingia katika `~/.config/hypr/monitors.lua` kama viingilio vya `hl.monitor` — faili huja na mifano iliyotolewa maoni ya kubandika monita mahususi kwenye ubora, nafasi, na mzunguko.

Kila monita ina nafasi za kazi 1 hadi 10 za kwake, kwa hivyo `Super + 1` daima humaanisha nafasi ya kazi ya kwanza ya monita uliyo juu yake. Nyuma ya pazia, Hyprland bado huhesabu nafasi za kazi kwenye monita zote: skrini ya kompyuta yako mpakato (au monita ya kwanza) hupata 1–10, monita inayofuata 11–20, na kadhalika, na kila monita huhifadhi kitalu chake kila unapoichomeka. Tumia namba hizo ikiwa unaandika [sheria za nafasi za kazi](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) au sheria za madirisha kwa monita mahususi, kwa hivyo nafasi ya kazi 12 ni nafasi ya kazi ya pili ya monita yako ya pili. `~/.local/state/omarchy/monitor-workspaces` huorodhesha kitalu ambacho kila monita inacho.

Vitufe vya mishale hufanya kazi kati ya monita zinazoshiriki ukingo katika mpangilio wako. Skrini zinazogusana tu kwenye kona, au zenye pengo kati yake, si majirani, kwa hivyo tumia `Ctrl + Alt + Tab` kusonga kati yake.

| Kitufe cha mkato | Kati ya monita |
| --- | --- |
| `Super + Arrow` | Husogeza lengo kwenye monita iliyo upande huo mara tu kunapokuwa hakuna dirisha lililobaki katika mwelekeo huo |
| `Super + Shift + Arrow` | Hubadilishana na dirisha lililo kwenye monita iliyo upande huo |
| `Super + Alt + Arrow` | Husogeza dirisha kwenye kikundi kilicho kwenye monita iliyo upande huo |
| `Super + Shift + Ctrl + Arrow` | Husogeza dirisha kwenye monita iliyo upande huo, kwenye nafasi ya kazi inayoonyesha |
| `Super + Shift + Alt + Arrow` | Husogeza nafasi ya kazi kwenye monita iliyo upande huo, ikiweka namba yake ikiwa iko huru |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Husogeza lengo kwenye monita inayofuata au iliyotangulia, vyovyote mpangilio ulivyo |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Hubaki kwenye monita uliyo juu yake |

Unaweza pia kuangalia [Hyprmon](https://github.com/erans/hyprmon/), ikiwa ungependa TUI ikusaidie katika kuweka skrini nyingi katika nafasi.

### Kudhibiti mwangaza

Mwangaza wa monita hudhibitiwa na vitufe maalum vya utendaji vya kuongeza/kupunguza mwangaza. Ikiwa utashikilia shift huku ukibonyeza hivi, utafika kwenye mwangaza wa juu zaidi au wa chini zaidi. Vitufe hudhibiti onyesho ulilolilenga, kwa hivyo monita za nje zinazozungumza DDC/CI hurekebishwa kwa njia sawa na skrini ya kompyuta mpakato.

### Maonyesho ya Apple

Ikiwa unatumia onyesho la Apple, vitufe vya kawaida vya mwangaza vya kibodi pia vitafanya kazi kiotomatiki, ikiwa umelenga onyesho la Apple. Hili hufanywa kupitia amri ya `asdcontrol`.

Kumbuka kuwa ikiwa unatumia onyesho la Apple 6K XDR, unaweza kuona skrini ya mzuka katika orodha yako ya `hyprctl monitors`. Unaweza kuzima hii kwa kitu kama `hl.monitor({ output = "DP-2", disabled = true })` kupitia _Setup > Monitors_.

Kwenye mashine za Intel, unapaswa kuunganisha kwenye maonyesho ya Apple kwa kutumia kebo ya kawaida ya Thunderbolt. Kwenye mashine nyingine zisizo na Thunderbolt, kwa kawaida itabidi utumie [kebo ya DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) ili ifanye kazi.
