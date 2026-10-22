# Skrini

Omarchy huchukulia unaendesha onyesho la kiwango cha retina lenye uwezo wa 2x kwa chaguomsingi. Hii ndiyo unayohitaji kupata fonti nzuri, wazi za programu. Ndicho karibu kompyuta mpakato zote mpya za bei ya juu zenye skrini za ubora wa juu zimeboreshewa. Ndicho ambacho ungependa kuendesha kwenye [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ya 27" 5K au [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) ya 32" 6K.

Lakini kama hauendeshi onyesho lenye PPI ya 218 au zaidi, utataka kubadilisha mipangilio ya skrini. Kwa mfano, kama una 27" au 32" 4K, unaweza kutumia upanuzi wa sehemu kwa kufungua `~/.config/hypr/monitors.lua` (kupitia _Sanidi > Skrini_ katika menyu ya Omarchy) na kubadilisha hadi pendekezo kwa mchanganyiko huo:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Kama unatumia onyesho la 1080p au 1440p, labda utataka tu kutumia upanuzi wa 1x, hivyo unaweza kutumia:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Mabadiliko kwenye `GDK_SCALE` hutumika kwa programu zilizoanzishwa baada ya mabadiliko (na GTK huheshimu nambari kamili tu, hivyo iache kwenye nambari kamili iliyo karibu zaidi ya upanuzi wako wa skrini). Hivyo hakikisha unaacha madirisha uliyonayo ambayo ni makubwa kupita kiasi baada ya mabadiliko (au funga madirisha yote kwa `Ctrl + Alt + Del`!).

Unaweza pia kupita haraka uwiano mkuu wa upanuzi wa skrini (1x, 1.25x, 1.6x, 2x, 3x, 4x) kwa kutumia `Super + /` kwenda juu na `Super + Alt + /` kwenda chini. Kama una usanidi chaguomsingi, mabadiliko haya pia yataendelea baada ya kuwashwa upya.

### Kufanya maandishi kuwa makubwa au madogo zaidi

Upanuzi wa skrini hubadilisha ukubwa wa kila kitu. Kama unachokitaka ni _maandishi_ makubwa au madogo zaidi, kuna kisu kimoja kwa hilo:

```
omarchy display text size 14
```

Hiyo huchukua ukubwa wa pikseli kati ya 9 na 20, na husogeza shell ya Omarchy, programu za GTK, na terminali yako pamoja, hivyo eneo-kazi lote hubakia sawia. Endesha bila hoja kuona uliko, na `omarchy display text size reset` kurudi kwenye chaguomsingi. Foot ndiye aliyebakia nyuma: haina njia ya kupakia upya usanidi wake, hivyo terminali zinazoendeshwa huhifadhi ukubwa wao wa zamani hadi utakapofungua mpya.

### Kupanua na kuakisi maonyesho ya kompyuta mpakato

Unapounganisha skrini ya nje kwenye kompyuta yako mpakato, onyesho hupanuliwa kiotomatiki. Lakini unaweza kubadilisha hilo kuwa uakisi badala yake kwa kutumia _Anzisha > Vifaa_ katika menyu ya Omarchy au `Super + Ctrl + Alt + Delete`. Hii ni muhimu sana kama skrini hiyo ya nje ni projekta, na unataka kuonyesha kitu unapofanya kazi.

Unapopanua, kufunga kifuniko kwenye kompyuta mpakato kutaizima skrini ya ndani kiotomatiki. Kufungua kifuniko kutaiwasha tena. Unaweza pia kudhibiti hili kwa mikono kwa kutumia _Anzisha > Vifaa_ katika menyu ya Omarchy au `Super + Ctrl + Delete`.

### Kupanga skrini nyingi

Hyprland hufanya kazi vizuri na skrini nyingi. Soma zaidi kuhusu jinsi ya kuzipanga katika [nyaraka za skrini za Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Unaweza [kufunga nafasi za kazi maalum kwa skrini maalum](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) pia. Katika Omarchy, sheria hizi huenda katika `~/.config/hypr/monitors.lua` kama viingilio vya `hl.monitor` — faili huja na mifano iliyo na maoni ya kubana skrini maalum kwa ubora, nafasi, na mzunguko.

Unaweza pia kuangalia [Hyprmon](https://github.com/erans/hyprmon/), kama ungependa TUI kukusaidia na uwekaji nafasi wa skrini nyingi.

### Kudhibiti mwangaza

Mwangaza wa skrini hudhibitiwa na vitufe maalum vya kazi kwa mwangaza juu/chini. Kama utashikilia shift unapobofya hivi, utakwenda kwenye mwangaza wa juu zaidi au chini zaidi. Vitufe hudhibiti onyesho unalolenga, hivyo skrini za nje zinazozungumza DDC/CI hurekebishwa kwa njia ile ile kama skrini ya kompyuta mpakato.

### Maonyesho ya Apple

Kama unatumia onyesho la Apple, vitufe vya kawaida vya mwangaza wa kibodi pia vitafanya kazi kiotomatiki, kama umelenga onyesho la Apple. Hii hufanywa kupitia amri ya `asdcontrol`.

Kumbuka kwamba kama unatumia onyesho la Apple 6K XDR, unaweza kuona skrini ya kivuli katika orodha yako ya `hyprctl monitors`. Unaweza kuzima hili kwa kitu kama `hl.monitor({ output = "DP-2", disabled = true })` kupitia _Sanidi > Skrini_.

Kwenye mashine za Intel, unapaswa kuunganisha kwenye maonyesho ya Apple kwa kutumia kebo ya kawaida ya Thunderbolt. Kwenye mashine nyingine bila Thunderbolt, kwa kawaida itabidi utumie [kebo ya DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) kuifanya ifanye kazi.
