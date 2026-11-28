# Urambazaji

Kila kitu katika Omarchy hufanyika kupitia kibodi — _KILA KITU!_ Mfumo unapoanza kwa mara ya kwanza, kihalisi huwezi kufanya chochote kwa kutumia kipanya pekee. Lakini unaweza kubonyeza `Super + Space` ili kuonyesha Menyu ya Omarchy na kutoka hapo unaweza kufanya karibu kila kitu.

Lakini menyu ya Omarchy hata haijakusudiwa kuwa njia kuu ya kuendesha mfumo kwa muda mwingi. Tunaweza kwenda haraka zaidi kuliko hivyo! Programu muhimu zaidi zote zimeunganishwa moja kwa moja na vitufe vya haraka vya binafsi. Unaanzisha terminal kwa `Super + Return` na kivinjari kwa `Super + Shift + Return`. Jaribu kufanya moja baada ya nyingine, na utaona uchawi wa kupanga vioo wa Hyprland ukifanya kazi:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Kisha unaweza kubonyeza `Super + J` ili kuzipanga moja juu ya nyingine badala ya kando kwa kando:

 ![navigation-stacked](images/navigation-stacked.webp)

Bonyeza `Super + J` tena ili kuzirudisha katika nafasi zao za kando kwa kando. Kisha jaribu `Super + Shift + Arrow Right` ukiwa kwenye kivinjari ili kubadilishana madirisha.

Sasa jaribu `Super + Shift + T` ili kuanzisha Kichunguzi cha Shughuli. Hicho kitaonekana kama dirisha linaloelea, likiwa na upau wa kichwa wa kulivuta na vitufe vya kulipunguza, kulikuza, na kulifunga. Kila dirisha linaloelea hupata upau mmoja, popote lilipo. Unaweza kulipanga kwa vioo kwa kutumia `Super + T` (na kubonyeza tena ili kulifanya lielee tena). Sasa bonyeza `Super + Shift + F` ili kufungua kidhibiti cha faili. Utakuwa na mpangilio mzuri wa njia nne:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Unasogea kati ya dirisha unalotaka liwe amilifu kwa `Super + Arrow`. Hii itabadilisha lengo na kusogeza kishale hadi katikati ya programu mpya. Ukingoni mwa skrini, inaendelea hadi kwenye monita iliyo upande huo.

Ukibonyeza `Super + Shift + 2`, utasogeza programu iliyolengwa sasa hivi hadi kwenye nafasi ya kazi ya pili. `Super + Shift + 1` huirudisha. (Na `Super + Shift + Alt + 2` itasogeza programu iliyolengwa sasa hivi hadi kwenye nafasi ya kazi ya pili bila kubadili kwenda huko).

Ukiwa na monita zaidi ya moja, kila monita ina nafasi zake za kazi 1 hadi 10. `Super + 2` huenda kwenye nafasi ya kazi ya pili ya monita uliyo nayo, na upau wa juu wa kila monita huonyesha nafasi zake za kazi na ile inayoonyeshwa. `Super + Tab` huzunguka kupitia nafasi za kazi kwenye monita uliyo nayo. `Super + Shift + Ctrl + Arrows` husogeza dirisha ulilo nalo hadi kwenye monita iliyo upande huo, kwenye nafasi ya kazi inayoonyeshwa, na `Super + Shift + Alt + Arrows` husogeza nafasi ya kazi uliyo nayo hadi kwenye monita iliyo upande huo, ambapo huchukua namba ile ile ikiwa iko huru. Monita huhifadhi nafasi zake za kazi unapoichomoa: huungana na za skrini nyingine, zikiwa na namba baada ya zile ilizo nazo tayari, na hurudi chini ya namba zao za zamani monita inapourudi.

Ukishikilia `Super` na kutumia kipanya kubofya dirisha, utaweza kupanga upya mahali lilipokaa. Ukishikilia `Super` na kutumia kitufe cha kulia cha kipanya, unaweza kubadilisha ukubwa wa dirisha kwa uhuru.

Unafunga dirisha kwa `Super + W` au `Super + Q` (na kufunga madirisha yote kwa `Ctrl + Alt + Delete`).

Unaweza pia kwenda skrini nzima kwa `Super + F` au hata upana kamili tu (ukiweka upau wa juu) kwa `Super + Alt + F` au skrini nzima ndani ya dirisha kwa `Super + Ctrl + F` (nzuri kwa YouTube!).

### Mpangilio wa dwindle dhidi ya scrolling

Mpangilio chaguomsingi wa Omarchy unaitwa dwindle. Huweka madirisha yote unayofungua kwenye nafasi moja ya kazi yaonekane wakati wote, hata ikiwa inabidi ayapunguze ukubwa.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Lakini unaweza pia kuchagua kugeuza nafasi ya kazi kuwa mpangilio wa scrolling ambapo madirisha yamepangwa kando kwa kando, zaidi ya ukingo unaoonekana wa onyesho. Unageuza nafasi moja ya kazi kuwa mpangilio huu kupitia `Super + L`.

Kubonyeza `Super + L` tena hugeuza nafasi ya kazi kuwa inayoelea, ambapo madirisha huingiliana kwa uhuru na unayaweka mwenyewe, na kubonyeza mara ya tatu huirudisha kwenye dwindle. `Super + Alt + L` hupitia hiyo kwa njia nyingine. Dirisha linaloelea hata hivyo — lile ulilolitoa nje kwa `Super + T`, au programu ambayo kila wakati hufunguka ikielea — huendelea kuelea nafasi ya kazi inapourudi kwenye kupanga vioo. Upau wa juu huweka alama kwenye nafasi ya kazi uliyo nayo kwa mpangilio wake: mraba kwa dwindle, duara kwa scrolling, na pembetatu kwa kuelea. Kubofya alama hiyo huzungusha mpangilio pia, na vivyo hivyo kitufe cha onyesho kwenye kompyuta ndogo zilizo nacho.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Uchaguzi ni kwa kila nafasi ya kazi, na hudumu. Hivyo unaweza kuweka nafasi ya kazi 1 kwenye dwindle kwa kuvinjari na nafasi ya kazi 2 kwenye scrolling kwa kuandika msimbo, na zitarudi hivyo baada ya kuwasha upya.

Ikiwa unataka kutumia mpangilio wa scrolling kama chaguomsingi, unaweza kuweka hivyo katika `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Nafasi za kazi zinazoelea

Nafasi ya kazi inayoelea hufanya kazi kama eneo-kazi la kitamaduni: madirisha huingiliana, na unayasogeza na kuyabadilisha ukubwa mwenyewe. Kila dirisha hupata upau wa kichwa katika rangi za mandhari yako, ukiwa na vitufe vya kupunguza, kukuza, na kufunga. `Super + M` hupunguza dirisha lililolengwa pia. Dirisha lililopunguzwa husubiri kwenye dock; bofya programu yake ili kulirudisha. Bofya dirisha ili kulileta mbele. Libadilishe ukubwa kutoka ukingo au kona yoyote. Bofya mara mbili upau wa kichwa ili kukuza dirisha huku ukiweka upau wa juu uonekane, na tena ili kupata ukubwa wake wa zamani. Chrome na vivinjari vingine vinavyotegemea Chromium, Disks na Document Viewer huruka upau wa kichwa na kutumia kichwa chake badala yake; `Super + Alt + F` huzikuza, na `Super + M` huzipunguza.

Kila nafasi ya kazi ina dock, ikiwa na programu zako zilizobandikwa, kila kitu kinachoendeshwa, na gridi ya kila programu nyuma ya kitufe cha programu, ambacho `Super + Alt + Space` na _Apps_ katika menyu ya Omarchy hufungua pia. Bofya kulia programu kwenye gridi, au bonyeza `Delete`, ili kuiondoa. Bofya programu ili kuifungua, au kuleta dirisha lake mbele; bofya tena ili kuzunguka kupitia madirisha yake. Files hurudisha tu dirisha kutoka nafasi ya kazi uliyo nayo na vinginevyo hufungua jipya, na Terminal na Agent kila wakati huanzisha nyingine, ingawa dirisha lililopunguzwa hurudi kwanza. Bofya katikati hufungua dirisha jipya. Vuta ikoni kando ya dock ili kuisogeza; kuvuta programu inayoendeshwa kati ya nyingine huiweka hapo. Bofya kulia ili kuweka programu kwenye dock, kuitoa, au kuifunga. Dock hubaki nje wakati nafasi ya kazi iko tupu, na mara tu nafasi ya kazi inapokuwa na dirisha hujificha hadi kishale kifike ukingoni mwake. Dirisha la skrini nzima huificha kabisa. Vuta kitufe cha programu kuelekea ukingo mwingine wa skrini ili kusogeza dock huko. Bofya kulia kwa _Position_, ili kuchagua ukingo, _Layout_, ili kuweka mpangilio chaguomsingi kama _Appearance > Workspace Layout_ inavyofanya, na _Visibility_, ili kuweka dock iwepo kila wakati, kufanya programu ya kwanza iifiche, au kuiweka imefichwa kila wakati. `omarchy dock visibility always` huweka hivyo kutoka kwenye terminal. Nafasi pia iko chini ya _Appearance > Dock > Dock Position_, na `omarchy dock position left` huiweka kutoka kwenye terminal. Programu unazoweka kwenye dock zimefifia wakati haziendeshwi. Ili kuweka dock kwenye nafasi za kazi zinazoelea tu, tumia _Appearance > Dock > Dock Only on Floating_ au `omarchy dock tiling off`.

Nafasi mpya za kazi, na yoyote ambayo hujaitia mpangilio wake mwenyewe kwa `Super + L`, hutumia mpangilio chaguomsingi. Kubadilisha chaguomsingi huweka upya kila nafasi ya kazi isiyo na madirisha kwake, wakati ile yenye madirisha huhifadhi mpangilio ilio nao. Dirisha lililopunguzwa hadi kwenye dock bado huhesabika kama dirisha kwenye nafasi ya kazi iliyoacha. Ichague chini ya _Appearance > Workspace Layout_: Tiling, Scrolling, au Floating. `omarchy hyprland workspace layout default scrolling` huiweka kutoka kwenye terminal.

### Kupanga madirisha katika vikundi

Madirisha yanaweza kupangwa katika vikundi kwa kutumia `Super + G`. Mara tu unapoingia kwenye kikundi, kila dirisha unaloanzisha wakati huo likiwa amilifu litakuwa la kikundi. Unaweza kusogea kati ya madirisha haya yaliyopangwa kwa kutumia `Super + Ctrl + Arrow Left/Right` au `Super + Alt + 1/2/3/4` ili kwenda moja kwa moja kwenye madirisha yaliyopangwa kwa mpangilio.

Unaweza kusogeza dirisha kutoka kwenye kikundi kwa `Super + Alt + G` au kuvunja kikundi kizima kwa kubonyeza `Super + G` tena. Mwishowe, unaweza kusogeza madirisha yaliyo nje ya kikundi kuingia ndani yake kwa `Super + Alt + Arrows`.

### Kutoa madirisha nje

Unaweza kutoa dirisha nje ya mgao wake wa nafasi ya kazi kwa `Super + O`. Hilo litalibandika kama dirisha linaloelea linalokufuata kwenye nafasi yoyote ya kazi unayoenda. Nzuri kwa vicheza video na vingine kama hivyo.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Nafasi ya kazi ya scratchpad

Kuna nafasi maalum ya kazi ya scratchpad yenye ukubwa kamili ambayo hufunika nafasi yoyote ya kazi uliyo nayo sasa hivi. Unafikia kilicho juu yake kwa kutumia `Super + S`, na unaweka madirisha huko kwa kutumia `Super + Alt + S`.

Inafanya kazi vizuri kwa vidhibiti au terminal unayotaka kuingiliana nayo haraka bila kuacha nafasi ya kazi ya sasa.

### Dashibodi ya Quake

Mwishowe, kuna dashibodi ya Quake yenye nusu urefu ambayo hushuka juu ya nafasi yoyote ya kazi uliyo nayo sasa hivi. Igeuze kwa `Super + the key above Tab` (grave kwenye mipangilio ya US), na weka dirisha huko kwa kutumia `Super + Shift + the key above Tab`.

Mara ya kwanza inapofunguka, huanzisha agent wako chaguomsingi, au hukuomba uchague mmoja ikiwa bado hujachagua. Wakati dashibodi ina dirisha moja tu, hushuka kama paneli iliyo katikati badala ya kuenea skrini. Weka programu ya pili juu yake na inarudi kwenye upana kamili, hivyo hizo mbili zina nafasi ya kukaa kando kwa kando.

Ili kusogeza dirisha kutoka kwenye scratchpad au dashibodi, litume moja kwa moja hadi kwenye nafasi nyingine ya kazi kwa kitu kama `Super + Shift + 1`.

### Inahitaji kuzoea kidogo!

Inachukua muda kidogo kuzoea kurambaza eneo-kazi lako hivi, lakini mara tu unapozoea, itakuwa ngumu kurudi kwenye uzoefu wa kitamaduni wa eneo-kazi unaoendeshwa kwa kipanya!
