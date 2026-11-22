# Urambazaji

Kila kitu katika Omarchy hutokea kupitia kibodi — _KILA KITU!_ Mfumo unapoanza kwa mara ya kwanza, kihalisi huwezi kufanya chochote kwa kipanya pekee. Lakini unaweza kubonyeza `Super + Space` ili kuonyesha Menyu ya Omarchy na kutoka hapa unaweza kufanya takriban kila kitu.

Lakini menyu ya Omarchy hata haijakusudiwa kuwa njia kuu ya kuendesha mfumo kwa sehemu kubwa ya muda. Tunaweza kuwa haraka zaidi kuliko hivyo! Programu zote muhimu zaidi zimefungwa moja kwa moja kwenye vitufe vya mkato vya mtu binafsi. Unaanzisha terminal kwa `Super + Return` na kivinjari kwa `Super + Shift + Return`. Jaribu kufanya moja baada ya jingine, na utaona uchawi wa uwekaji vigae wa Hyprland ukifanya kazi:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Kisha unaweza kubonyeza `Super + J` ili kuziweka moja juu ya nyingine badala ya kando kwa kando:

 ![navigation-stacked](images/navigation-stacked.webp)

Bonyeza `Super + J` tena ili kuzirudisha kwenye nafasi zao za kando kwa kando. Kisha jaribu `Super + Shift + Arrow Right` ukiwa kwenye kivinjari ili kubadilishana madirisha.

Sasa jaribu `Super + Shift + T` ili kuanzisha kifuatiliaji cha Activity. Hicho kitaonekana kama dirisha linaloelea. Unaweza kukiweka kama kigae kwa kutumia `Super + T` (na kubonyeza tena ili kukifanya kielee tena). Sasa bonyeza `Super + Shift + F` ili kufungua kidhibiti cha faili. Utakuwa na mpangilio nadhifu wa njia nne:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Unasafiri kati ya dirisha unalotaka liwe linalofanya kazi kwa `Super + Arrow`. Hii itabadilisha lengo na kusogeza kishale hadi katikati ya programu mpya. Kwenye ukingo wa skrini, inaendelea hadi kwenye monita iliyo upande huo.

Ukibonyeza `Super + Shift + 2`, utasogeza programu iliyolengwa sasa hivi hadi kwenye eneo la pili la kazi. `Super + Shift + 1` inairudisha. (Na `Super + Shift + Alt + 2` itasogeza programu iliyolengwa sasa hivi hadi kwenye eneo la pili la kazi bila kubadili kwenda kwake).

Ukiwa na monita zaidi ya moja, kila monita ina maeneo yake ya kazi 1 hadi 10. `Super + 2` huenda kwenye eneo la pili la kazi la monita uliyo juu yake, na upau wa juu wa kila monita huonyesha maeneo yake ya kazi na lile inalolionyesha. `Super + Tab` huzunguka kupitia maeneo ya kazi kwenye monita uliyo juu yake. `Super + Shift + Ctrl + Arrows` husogeza dirisha ulilopo hadi kwenye monita katika mwelekeo huo, kwenye eneo la kazi inalolionyesha, na `Super + Shift + Alt + Arrows` husogeza eneo la kazi ulilopo hadi kwenye monita katika mwelekeo huo, ambapo linachukua nambari ile ile ikiwa liko wazi. Monita huhifadhi maeneo yake ya kazi unapoichomoa: yanaungana na ya skrini nyingine, yakipewa nambari baada ya yale ambayo tayari inayo, na kurudi chini ya nambari zao za zamani monita inapourudi.

Ukishikilia `Super` na kutumia kipanya kubofya dirisha, utaweza kupanga upya mahali linapokaa. Ukishikilia `Super` na kutumia kitufe cha kulia cha kipanya, unaweza kubadilisha ukubwa wa dirisha kwa uhuru.

Unafunga dirisha kwa `Super + W` au `Super + Q` (na kufunga madirisha yote kwa `Ctrl + Alt + Delete`).

Unaweza pia kwenda skrini nzima kwa `Super + F` au hata upana kamili tu (huku ukiweka upau wa juu) kwa `Super + Alt + F` au skrini nzima ndani ya dirisha kwa `Super + Ctrl + F` (nzuri kwa YouTube!).

### Mpangilio wa dwindle dhidi ya scrolling

Mpangilio chaguomsingi wa Omarchy unaitwa dwindle. Huweka madirisha yote unayofungua kwenye eneo moja la kazi yakiwa yanaonekana wakati wote, hata ikiwa inabidi kuyapunguza ukubwa.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Lakini unaweza pia kuchagua kubadilisha eneo la kazi kuwa mpangilio wa scrolling ambapo madirisha yamepangwa kando kwa kando, kupita ukingo unaoonekana wa onyesho. Unabadilisha eneo moja la kazi kuwa mpangilio huu kupitia `Super + L`.

Kubonyeza `Super + L` tena hubadilisha eneo la kazi kuwa linaloelea, ambapo madirisha huingiliana kwa uhuru na unayaweka mwenyewe, na kubonyeza mara ya tatu kunalirudisha kwenye dwindle. `Super + Alt + L` hupitia hivyo kwa mwelekeo mwingine. Dirisha linaloelea hata hivyo — lile ulilolitoa kwa `Super + T`, au programu ambayo daima hufunguka ikielea — hubaki likielea eneo la kazi linaporudi kwenye uwekaji vigae. Upau wa juu huweka alama kwenye eneo la kazi ulilopo kwa mpangilio wake: mraba kwa dwindle, duara kwa scrolling, na pembe tatu kwa kuelea. Kubofya alama hiyo pia huzungusha mpangilio, na vivyo hivyo kitufe cha onyesho kwenye laptops zinazokuwa nacho.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Chaguo ni kwa kila eneo la kazi, na hubaki. Kwa hivyo unaweza kuweka eneo la kazi 1 kwenye dwindle kwa kuvinjari na eneo la kazi 2 kwenye scrolling kwa msimbo, na vitarejea hivyo baada ya kuwasha upya.

Ikiwa unataka kutumia mpangilio wa scrolling kama chaguomsingi, unaweza kuweka hilo katika `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Maeneo ya kazi yanayoelea

Eneo la kazi linaloelea hufanya kazi kama desktop ya kitamaduni: madirisha huingiliana, na unayasogeza na kuyabadilisha ukubwa mwenyewe. Kila dirisha hupata upau wa kichwa katika rangi za mandhari yako, ukiwa na vitufe vya kupunguza, kuongeza ukubwa, na kufunga. `Super + M` pia hupunguza dirisha lililolengwa. Dirisha lililopunguzwa husubiri kwenye dock; bofya programu yake ili kulirudisha. Bofya dirisha ili kulileta mbele. Libadilishe ukubwa kutoka kwenye ukingo au kona yoyote. Bofya mara mbili upau wa kichwa ili kuongeza ukubwa wa dirisha huku ukiweka upau wa juu ukionekana, na tena ili kupata ukubwa wake wa zamani. Chrome na vivinjari vingine vinavyotegemea Chromium, Disks na Document Viewer huruka upau wa kichwa na kutumia kichwa chao wenyewe badala yake; `Super + Alt + F` huwaongezea ukubwa, na `Super + M` huwapunguza.

Eneo la kazi linaloelea pia huonyesha dock, ikiwa na programu zako zilizobandikwa, kila kitu kinachoendeshwa, na gridi ya kila programu nyuma ya kitufe cha programu, ambacho `Super + Alt + Space` na _Apps_ katika menyu ya Omarchy pia hufungua. Bofya kulia programu kwenye gridi, au bonyeza `Delete`, ili kuiondoa. Bofya programu ili kuifungua, au kuleta dirisha lake mbele; bofya tena ili kuzunguka kupitia madirisha yake. Files hurudisha tu dirisha kutoka kwenye eneo la kazi ulilopo na vinginevyo hufungua jipya, na Terminal na Agent daima huanzisha jingine, ingawa dirisha lililopunguzwa hurudi kwanza. Bofya katikati hufungua dirisha jipya. Buruta aikoni kando ya dock ili kuisogeza; kuburuta programu inayoendeshwa kati ya nyingine huiweka hapo. Bofya kulia ili kuweka programu kwenye dock, kuitoa, au kuiacha. Dock huondoka njiani mwa dirisha la skrini nzima. Bofya kulia kitufe cha programu ili kusogeza dock hadi ukingo mwingine au kuifanya ifichike hadi kishale kifike ukingoni mwake. Nafasi pia iko chini ya _Mwonekano > Dock > Nafasi ya Dock_, na `omarchy dock position left` na `omarchy dock autohide on` huweka vyote viwili kutoka kwenye terminal. Programu unazoziweka kwenye dock hufifia zikiwa haziendeshwi.

Maeneo mapya ya kazi, na yoyote ambayo hujayapa mpangilio wake yenyewe kwa `Super + L`, hutumia mpangilio chaguomsingi. Kubadilisha chaguomsingi huweka upya kila eneo la kazi lisilo na madirisha kwake, ilhali lenye madirisha juu yake huhifadhi mpangilio lililo nao. Dirisha lililopunguzwa kwenda kwenye dock bado huhesabika kama dirisha kwenye eneo la kazi lililotoka. Ichague chini ya _Mwonekano > Mpangilio wa Eneo la Kazi_: Uwekaji Vigae, Scrolling, au Kuelea. `omarchy hyprland workspace layout default scrolling` huiweka kutoka kwenye terminal.

### Kupanga madirisha katika vikundi

Madirisha yanaweza kupangwa katika vikundi kwa kutumia `Super + G`. Ukishaingia kwenye kikundi, kila dirisha unaloanzisha wakati hicho kinafanya kazi litakuwa la kikundi hicho. Unaweza kusogeza kati ya madirisha haya yaliyopangwa katika vikundi kwa kutumia `Super + Ctrl + Arrow Left/Right` au `Super + Alt + 1/2/3/4` ili kwenda moja kwa moja kwenye madirisha yaliyopangwa kwa mpangilio.

Unaweza kusogeza dirisha kutoka kwenye kikundi kwa `Super + Alt + G` au kuvunja kikundi chote kwa kubonyeza `Super + G` tena. Mwishowe, unaweza kusogeza madirisha yaliyo nje ya kikundi kuingia ndani yake kwa `Super + Alt + Arrows`.

### Kutoa madirisha nje

Unaweza kutoa dirisha kutoka kwenye mgawanyo wake wa eneo la kazi kwa `Super + O`. Hilo litalibandika kama dirisha linaloelea linalokufuata kwenye eneo lolote la kazi unaloenda. Nzuri kwa vicheza video na vingine kama hivyo.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Eneo la kazi la scratchpad

Kuna eneo maalum la kazi la scratchpad la ukubwa kamili linalofunika eneo lolote la kazi ulilopo sasa hivi. Unafikia kilichopo juu yake kwa kutumia `Super + S`, na unaweka madirisha hapo kwa kutumia `Super + Alt + S`.

Hufanya kazi vizuri kwa vidhibiti au terminal unayotaka kuingiliana nayo haraka bila kuondoka kwenye eneo la kazi la sasa.

### Konsoli ya Quake

Mwishowe, kuna konsoli ya Quake ya nusu urefu inayoshuka juu ya eneo lolote la kazi ulilopo sasa hivi. Ibadilishe kwa `Super + Grave`, na uweke dirisha hapo kwa kutumia `Super + Shift + Grave`.

Mara ya kwanza inapofunguka, huanzisha wakala wako chaguomsingi, au kukuomba uchague mmoja ikiwa bado hujachagua. Wakati konsoli ina dirisha moja, hushuka kama paneli iliyowekwa katikati badala ya kuenea skrini. Weka programu ya pili juu yake na inarudi kwenye upana kamili, ili hizi mbili ziwe na nafasi ya kukaa kando kwa kando.

Ili kusogeza dirisha kutoka kwenye scratchpad au konsoli, lipeleke moja kwa moja kwenye eneo jingine la kazi kwa kitu kama `Super + Shift + 1`.

### Inahitaji kuzoea kidogo!

Inachukua muda kidogo kuzoea kuendesha desktop yako hivi, lakini ukishazoea, itakuwa vigumu kurudi kwenye uzoefu wa desktop wa kitamaduni unaoendeshwa na kipanya!
