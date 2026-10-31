# Urambazaji

Kila kitu katika Omarchy hutokea kupitia kibodi — _KILA KITU!_ Mfumo unapoanza kwa mara ya kwanza, kihalisi huwezi kufanya chochote kwa kutumia kipanya pekee. Lakini unaweza kubonyeza `Super + Space` ili kufunua Menyu ya Omarchy na kuanzia hapa unaweza kufanya karibu kila kitu.

Lakini menyu ya Omarchy hata haijakusudiwa kuwa njia kuu ya kuendesha mfumo kwa sehemu kubwa ya muda. Tunaweza kuwa wepesi zaidi kuliko hivyo! Programu zote muhimu zaidi zimefungwa moja kwa moja kwenye vitufe vya haraka vya kibinafsi. Unaanzisha terminal kwa `Super + Return` na kivinjari kwa `Super + Shift + Return`. Jaribu kufanya moja baada ya jingine, na utaona uchawi wa kupanga madirisha kama vigae wa Hyprland ukifanya kazi:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Unaweza kisha kubonyeza `Super + J` ili kuyapanga juu ya kila moja badala ya kando kwa kando:

 ![navigation-stacked](images/navigation-stacked.webp)

Bonyeza `Super + J` tena ili kuyarudisha kwenye nafasi zao za kando kwa kando. Kisha jaribu `Super + Shift + Arrow Right` ukiwa kwenye kivinjari ili kubadilishana madirisha.

Sasa jaribu `Super + Shift + T` ili kuanzisha Activity monitor. Hiyo itaonekana kama dirisha linaloelea. Unaweza kulipanga kama kigae kwa kutumia `Super + T` (na kubonyeza hiyo tena ili kulifanya lielee tena). Sasa bonyeza `Super + Shift + F` ili kufungua kidhibiti faili. Utakuwa na mpangilio nadhifu wa njia nne:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Unapita kati ya dirisha unalotaka liwe linalofanya kazi kwa kutumia `Super + Arrow`. Hii itabadili lengo na kusogeza kielekezi hadi katikati ya programu mpya. Kwenye ukingo wa skrini, inaendelea hadi kwenye monita iliyo upande huo.

Ukibonyeza `Super + Shift + 2`, utasogeza programu iliyolengwa sasa hivi hadi kwenye eneo la pili la kazi. `Super + Shift + 1` huirudisha. (Na `Super + Shift + Alt + 2` itasogeza programu iliyolengwa sasa hivi hadi kwenye eneo la pili la kazi bila kubadilisha kwenda kwake).

Ukiwa na monita zaidi ya moja, kila monita ina maeneo yake ya kazi 1 hadi 10. `Super + 2` huenda kwenye eneo la pili la kazi la monita uliyopo, na upau wa juu wa kila monita huonyesha maeneo yake ya kazi na lile inalolionyesha. `Super + Tab` huzunguka kupitia maeneo ya kazi kwenye monita uliyopo. `Super + Shift + Ctrl + Arrows` husogeza dirisha ulilopo hadi kwenye monita iliyo upande huo, hadi kwenye eneo la kazi inalolionyesha, na `Super + Shift + Alt + Arrows` husogeza eneo la kazi ulilopo hadi kwenye monita iliyo upande huo, ambapo linachukua nambari ile ile ikiwa iko huru. Monita huhifadhi maeneo yake ya kazi unapoichomoa: huungana na ya skrini nyingine, yakihesabiwa baada ya yale ambayo tayari inayo, na hurudi chini ya nambari zao za zamani monita inaporejeshwa.

Ukishikilia `Super` na kutumia kipanya kubofya dirisha, utaweza kupanga upya mahali linapokaa. Ukishikilia `Super` na kutumia kitufe cha kulia cha kipanya, unaweza kubadilisha ukubwa wa dirisha kwa uhuru.

Unafunga dirisha kwa `Super + W` au `Super + Q` (na unafunga madirisha yote kwa `Ctrl + Alt + Delete`).

Unaweza pia kwenda skrini nzima kwa `Super + F` au hata upana kamili tu (ukihifadhi upau wa juu) kwa `Super + Alt + F` au skrini nzima ndani ya dirisha kwa `Super + Ctrl + F` (nzuri kwa YouTube!).

### Dwindle dhidi ya mpangilio wa scrolling

Mpangilio chaguomsingi wa Omarchy unaitwa dwindle. Huhifadhi madirisha yote unayofungua kwenye eneo moja la kazi yakiwa yanaonekana wakati wote, hata ikiwa inabidi kuyapunguza ukubwa.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Lakini unaweza pia kuchagua kubadilisha eneo la kazi kuwa mpangilio wa scrolling ambapo madirisha yamepangwa kando kwa kando, zaidi ya ukingo unaoonekana wa onyesho. Unabadilisha eneo moja la kazi kuwa mpangilio huu kupitia `Super + L`.

Kubonyeza `Super + L` tena hubadilisha eneo la kazi kuwa linaloelea, ambapo madirisha huingiliana kwa uhuru na unayaweka mwenyewe, na kubonyeza kwa mara ya tatu hulirudisha kwenye dwindle. `Super + Alt + L` hupitia hivyo kwa mwelekeo mwingine. Dirisha linaloelea vyovyote vile — lile ulilotoa nje kwa `Super + T`, au programu ambayo daima hufunguka ikielea — hubaki likielea eneo la kazi linaporejea kwenye kupanga kama vigae. Upau wa juu huweka alama kwenye eneo la kazi ulilopo kwa mpangilio wake: mraba kwa dwindle, duara kwa scrolling, na pembetatu kwa linaloelea. Kubofya alama hiyo pia huzungusha mpangilio.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Chaguo ni kwa kila eneo la kazi, na hukaa. Hivyo unaweza kuhifadhi eneo la kazi 1 kwenye dwindle kwa kuvinjari na eneo la kazi 2 kwenye scrolling kwa msimbo, na vitarejea hivyo baada ya kuwasha upya.

Ukitaka kutumia mpangilio wa scrolling kama chaguomsingi, unaweza kuweka hiyo katika `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Maeneo ya kazi yanayoelea

Eneo la kazi linaloelea hufanya kazi kama eneo-kazi la kitamaduni: madirisha huingiliana, na unayasogeza na kuyabadilisha ukubwa mwenyewe. Kila dirisha hupata upau wa kichwa katika rangi za mandhari yako, wenye vitufe vya kupunguza, kupanua hadi ukubwa wa juu, na kufunga. `Super + M` pia hupunguza dirisha lililolengwa. Dirisha lililopunguzwa husubiri katika dock; bofya programu yake ili kulirejesha. Bofya dirisha ili kulileta mbele. Libadilishe ukubwa kutoka kwenye ukingo au kona yoyote. Bofya mara mbili upau wa kichwa ili kupanua dirisha hadi ukubwa wa juu huku ukiweka upau wa juu ukionekana, na tena ili kupata ukubwa wake wa zamani.

Eneo la kazi linaloelea pia huonyesha dock, yenye programu zako zilizobandikwa, kila kitu kinachoendeshwa, na gridi ya kila programu nyuma ya kitufe cha programu, ambacho `Super + Alt + Space` na _Apps_ katika menyu ya Omarchy pia huvifungua. Bofya kulia programu kwenye gridi, au bonyeza `Delete`, ili kuiondoa. Bofya programu ili kuifungua, au kuleta dirisha lake mbele; bofya tena ili kuzunguka kupitia madirisha yake. Bofya kati hufungua dirisha jipya. Buruta aikoni kando ya dock ili kuisogeza; kuburuta programu inayoendeshwa kati ya nyingine huiweka hapo. Bofya kulia ili kuweka programu katika dock, kuitoa, au kuiacha. Dock huondoka njiani mwa dirisha la skrini nzima. Bofya kulia kitufe cha programu ili kusogeza dock hadi ukingo mwingine au kuifanya ifichike hadi kielekezi kifike ukingoni mwake. Nafasi pia iko chini ya _Appearance > Dock > Dock Position_, na `omarchy dock position left` na `omarchy dock autohide on` huweka yote mawili kutoka kwenye terminal. Programu unazoweka katika dock hufifia zikiwa haziendeshwi.

Maeneo mapya ya kazi, na yoyote ambayo hujayapa mpangilio wake yenyewe kwa `Super + L`, hutumia mpangilio chaguomsingi. Kubadilisha chaguomsingi huweka upya kila eneo la kazi lisilo na madirisha kwake, ilhali lenye madirisha juu yake huhifadhi mpangilio lililo nao. Dirisha lililopunguzwa hadi kwenye dock bado huhesabika kama dirisha kwenye eneo la kazi lililoliacha. Ichague chini ya _Appearance > Workspace Layout_: Tiling, Scrolling, au Floating. `omarchy-hyprland-workspace-layout-default scrolling` huiweka kutoka kwenye terminal.

### Kupanga madirisha katika vikundi

Madirisha yanaweza kupangwa katika vikundi kwa kutumia `Super + G`. Ukiwa katika kikundi, kila dirisha unaloanzisha wakati huo linafanya kazi litakuwa la kikundi. Unaweza kusogea kati ya madirisha haya yaliyopangwa katika vikundi kwa kutumia `Super + Ctrl + Arrow Left/Right` au `Super + Alt + 1/2/3/4` ili kwenda moja kwa moja kwenye dirisha lililopangwa katika kikundi kwa mpangilio.

Unaweza kusogeza dirisha kutoka kwenye kikundi kwa `Super + Alt + G` au kuvunja kikundi kizima kwa kubonyeza `Super + G` tena. Hatimaye, unaweza kusogeza madirisha yaliyo nje ya kikundi kuingia ndani yake kwa `Super + Alt + Arrows`.

### Kutoa madirisha nje

Unaweza kutoa dirisha kutoka kwenye mgawo wake wa eneo la kazi kwa `Super + O`. Hiyo italibandika kama dirisha linaloelea linalokufuata kwenye eneo lolote la kazi unaloenda. Nzuri kwa vichezeshi video na vingine kama hivyo.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Eneo la kazi la Scratchpad

Kuna eneo maalum la kazi la scratchpad la ukubwa kamili linalofunika eneo lolote la kazi ulilopo sasa. Unafikia kilicho juu yake kwa kutumia `Super + S`, na unaweka madirisha huko kwa kutumia `Super + Alt + S`.

Hufanya kazi vizuri kwa vidhibiti au terminal unayotaka kuingiliana nayo haraka bila kuondoka kwenye eneo la sasa la kazi.

### Dashibodi ya Quake

Hatimaye, kuna dashibodi ya Quake ya nusu urefu inayoshuka juu ya eneo lolote la kazi ulilopo sasa. Ibadilishe kwa `Super + Grave`, na weka dirisha huko kwa kutumia `Super + Shift + Grave`.

Hufunguka ikiwa na agent wako chaguomsingi yuko tayari kwenda. Dashibodi inaposhikilia dirisha moja, hushuka kama paneli iliyowekwa katikati badala ya kuenea skrini. Weka programu ya pili juu yake na inarudi kwenye upana kamili, hivyo hizo mbili zina nafasi ya kukaa kando kwa kando.

Ili kusogeza dirisha kutoka kwenye scratchpad au dashibodi, lipeleke moja kwa moja kwenye eneo lingine la kazi kwa kitu kama `Super + Shift + 1`.

### Inachukua muda kuizoea!

Inachukua muda mfupi kuizoea kupitia eneo-kazi lako kama hivi, lakini ukishaizoea, itakuwa ngumu kurudi kwenye uzoefu wa kitamaduni wa eneo-kazi unaoendeshwa na kipanya!
