# Monitori

Omarchy inadhania, kwa chaguo-msingi, kuwa unatumia onyesho la daraja la retina lenye uwezo wa 2x. Hiki ndicho unachohitaji ili kupata fonti hizo nzuri na nyororo za wapangaji programu. Ni kile ambacho karibu kompyuta mpakato zote mpya za bei ya juu zenye skrini za ubora wa juu zimeboreshwa kukitumia. Ni kile ambacho ungependa kukitumia kwenye [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ya inchi 27 ya 5K au [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) ya inchi 32 ya 6K.

Lakini kama hutumii onyesho lenye PPI ya 218 au zaidi, utataka kubadilisha mipangilio ya monitori. Kwa mfano, kama una 4K ya inchi 27 au inchi 32, unaweza kutumia upanuzi wa sehemu kwa kufungua `~/.config/hypr/monitors.lua` (kupitia _Usanidi > Monitori_ katika menyu ya Omarchy) na kubadilisha hadi kwenye pendekezo la mchanganyiko huo:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Kama unatumia onyesho la 1080p au 1440p, huenda ukataka tu kutumia upanuzi wa 1x, hivyo unaweza kutumia:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Mabadiliko kwenye `GDK_SCALE` hutumika kwa programu zinazoanzishwa baada ya mabadiliko (na GTK hukubali nambari kamili tu, hivyo iache kwenye nambari kamili iliyo karibu zaidi na kipimo cha monitori yako). Hivyo hakikisha unafunga madirisha uliyonayo ambayo ni makubwa kupita kiasi baada ya mabadiliko (au funga madirisha yote kwa `Ctrl + Alt + Del`!).

Unaweza pia kupita haraka kwenye uwiano mkuu wa upanuzi wa monitori (1x, 1.25x, 1.6x, 2x, 3x, 4x) kwa kutumia `Super + /` kwenda juu zaidi na `Super + Alt + /` kwenda chini zaidi, au chagua moja kutoka kwenye paneli ya monitori kwenye upau wa juu. Haya hubadilisha monitori unayoiangalia tu, hivyo skrini ya kompyuta mpakato na onyesho la nje kila moja inaweza kuwa na kipimo chake. Chaguo huhifadhiwa kwenye `~/.config/hypr/monitors.lua` kama sheria ya `hl.monitor` kwa monitori hiyo, hivyo huendelea kubaki baada ya kuwasha upya na huchukua nafasi ya kwanza kabla ya `omarchy_monitor_scale`, ambayo hubaki kuwa kipimo cha kila monitori isiyo na sheria yake yenyewe. Kwa kuwa `GDK_SCALE` ni thamani moja kwa skrini zote, mabadiliko haya huiweka kutoka kwenye monitori yenye kipimo cha chini zaidi, hivyo programu za X11 hutokea ndogo kidogo kwenye skrini yenye msongamano mkubwa zaidi badala ya kuwa kubwa kupita kiasi kwenye nyingine.

### Kufanya maandishi yawe makubwa au madogo zaidi

Upanuzi wa monitori hubadilisha ukubwa wa kila kitu. Kama unachotaka tu ni _maandishi_ makubwa au madogo zaidi, kuna kitufe kimoja tu cha kufanya hivyo:

```
omarchy display text size 14
```

Hiyo huchukua ukubwa wa pikseli kati ya 9 na 20, na huhamisha shell ya Omarchy, programu za GTK, na terminal yako pamoja, hivyo dawati lote hubaki katika uwiano. Iendeshe bila hoja yoyote ili kuona ulipo, na `omarchy display text size reset` ili kurudi kwenye chaguo-msingi. Foot ndiyo iliyobaki nyuma pekee: haina njia ya kupakia upya usanidi wake, hivyo terminal zinazoendelea huweka ukubwa wao wa zamani hadi utakapofungua mpya.

### Kupanua na kuakisi maonyesho ya kompyuta mpakato

Unapounganisha skrini ya nje kwenye kompyuta yako mpakato, onyesho hupanuliwa kiotomatiki. Lakini unaweza kubadilisha hilo kuwa uakisi badala yake kwa kutumia _Kichocheo > Vifaa_ katika menyu ya Omarchy au `Super + Ctrl + Alt + Delete`. Hii husaidia hasa kama skrini hiyo ya nje ni projekta, na unataka kuonyesha kitu unapofanya kazi.

Unapopanua, kufunga kifuniko cha kompyuta mpakato kutazima skrini ya ndani kiotomatiki. Kufungua kifuniko kutairejesha. Unaweza pia kudhibiti hili mwenyewe kwa kutumia _Kichocheo > Vifaa_ katika menyu ya Omarchy au `Super + Ctrl + Delete`.

### Kupanga skrini nyingi

Hyprland hufanya kazi vizuri sana na skrini nyingi. Soma zaidi kuhusu jinsi ya kuzipanga katika [nyaraka za monitori za Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Katika Omarchy, hizi huingia katika `~/.config/hypr/monitors.lua` kama vipengee vya `hl.monitor` — faili huja na mifano iliyotiwa maoni ya kubandika monitori maalum kwenye ubora, nafasi, na mzunguko fulani.

Kila monitori ina nafasi za kazi 1 hadi 10 zake yenyewe, hivyo `Super + 1` daima humaanisha nafasi ya kazi ya kwanza ya monitori uliyopo. Kwa nyuma ya pazia, Hyprland bado huweka nambari kwenye nafasi za kazi kwenye monitori zote: skrini ya kompyuta yako mpakato (au monitori ya kwanza) hupata 1–10, monitori inayofuata 11–20, na kuendelea hivyo, na kila monitori huweka kitalu chake kila unapoiunganisha. Tumia nambari hizo kama unaandika [sheria za nafasi za kazi](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) au sheria za madirisha kwa monitori maalum, hivyo nafasi ya kazi 12 ni nafasi ya kazi ya pili ya monitori yako ya pili. `~/.local/state/omarchy/monitor-workspaces` huorodhesha kitalu ambacho kila monitori inacho.

Vitufe vya mishale hufanya kazi kwenye monitori zinazoshiriki ukingo katika mpangilio wako. Skrini zinazogusana kwenye kona tu, au zenye pengo kati yazo, si majirani, hivyo tumia `Ctrl + Alt + Tab` ili kupita kati yazo.

| Hotkey | Kwenye monitori zote |
| --- | --- |
| `Super + Arrow` | Huhamisha mwelekeo hadi kwenye monitori iliyo upande huo mara tu kunapokuwa hakuna dirisha lililobaki upande huo |
| `Super + Shift + Arrow` | Hubadilishana na dirisha lililo kwenye monitori iliyo upande huo |
| `Super + Alt + Arrow` | Huhamisha dirisha hadi kwenye kikundi kilicho kwenye monitori iliyo upande huo |
| `Super + Shift + Ctrl + Arrow` | Huhamisha dirisha hadi kwenye monitori iliyo upande huo, kwenye nafasi ya kazi inayoonyesha |
| `Super + Shift + Alt + Arrow` | Huhamisha nafasi ya kazi hadi kwenye monitori iliyo upande huo, ikiweka nambari yake kama iko wazi |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Huhamisha mwelekeo hadi kwenye monitori inayofuata au iliyotangulia, chochote kilicho mpangilio |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Hubaki kwenye monitori uliyopo |

Unaweza pia kuangalia [Hyprmon](https://github.com/erans/hyprmon/), kama ungependa TUI ikusaidie katika kuziweka skrini nyingi katika nafasi zake.

### Kudhibiti mwangaza

Mwangaza wa monitori hudhibitiwa na vitufe maalum vya utendaji vya kuongeza/kupunguza mwangaza. Kama utashikilia shift unapobonyeza hivi, utaenda kwenye mwangaza wa juu zaidi au wa chini zaidi. Vitufe hudhibiti onyesho unaloliangalia, hivyo monitori za nje zinazozungumza DDC/CI hurekebishwa kwa njia ileile kama skrini ya kompyuta mpakato.

### Maonyesho ya Apple

Kama unatumia onyesho la Apple, vitufe vya kawaida vya mwangaza vya kibodi pia vitafanya kazi kiotomatiki, kama umeangalia onyesho la Apple. Hii hufanywa kupitia amri ya `asdcontrol`.

Kumbuka kuwa kama unatumia onyesho la Apple 6K XDR, unaweza kuona skrini ya mzuka katika orodha yako ya `hyprctl monitors`. Unaweza kuzima hii kwa kitu kama `hl.monitor({ output = "DP-2", disabled = true })` kupitia _Usanidi > Monitori_.

Kwenye mashine za Intel, unapaswa kuunganisha kwenye maonyesho ya Apple kwa kutumia kebo ya kawaida ya Thunderbolt. Kwenye mashine nyingine zisizo na Thunderbolt, kwa kawaida itabidi utumie [kebo ya DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) ili kuifanya ifanye kazi.
