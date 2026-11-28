# Urambazaji

Kila kitu katika Omarchy hutokea kupitia kibodi — _KILA KITU!_ Mfumo unapoanza mara ya kwanza, kihalisi huwezi kufanya chochote kwa kipanya pekee. Lakini unaweza kubonyeza `Super + Space` ili kuonyesha Menyu ya Omarchy na kuanzia hapa unaweza kufanya karibu kila kitu.

Lakini menyu ya Omarchy haikukusudiwa hata kuwa njia kuu ya kuendesha mfumo kwa sehemu kubwa ya muda. Tunaweza kufanya haraka zaidi kuliko hiyo! Programu zote muhimu zaidi zimefungwa moja kwa moja kwenye hotkey za kibinafsi. Unaanzisha terminal kwa `Super + Return` na kivinjari kwa `Super + Shift + Return`. Jaribu kufanya moja baada ya nyingine, na utaona uchawi wa kupanga tiles wa Hyprland ukifanya kazi:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Unaweza kisha kubonyeza `Super + J` ili kuzipanga moja juu ya nyingine badala ya kando kwa kando:

 ![navigation-stacked](images/navigation-stacked.webp)

Bonyeza `Super + J` tena ili kuzirudisha kwenye nafasi zao za kando kwa kando. Kisha jaribu `Super + Shift + Arrow Right` ukiwa kwenye kivinjari ili kubadilisha madirisha.

Sasa jaribu `Super + Shift + T` ili kuanzisha kifuatiliaji cha Activity. Hiyo itaonekana kama dirisha linaloelea, lenye upau wa kichwa wa kuliburuta na vitufe vya kukupunguza, kukukuza, na kulifunga. Kila dirisha linaloelea hupata moja, popote lilipo. Unaweza kulipanga kwa tiles ukitumia `Super + T` (na bonyeza hiyo tena ili kulifanya lielee tena). Sasa bonyeza `Super + Shift + F` ili kufungua kidhibiti cha faili. Utakuwa na mpangilio mzuri wa njia nne:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Unasogeza kati ya dirisha unalotaka liwe linalofanya kazi kwa `Super + Arrow`. Hii itabadilisha focus na kusogeza kishale hadi katikati ya programu mpya. Kwenye ukingo wa skrini, inaendelea hadi kwenye monitor iliyo upande huo.

Ukibonyeza `Super + Shift + 2`, utasogeza programu ya sasa iliyolengwa hadi kwenye workspace ya pili. `Super + Shift + 1` huirudisha. (Na `Super + Shift + Alt + 2` itasogeza programu ya sasa iliyolengwa hadi kwenye workspace ya pili bila kubadili kwenda kwake).

Ukiwa na monitor zaidi ya moja, kila monitor ina workspace 1 hadi 10 zake yenyewe. `Super + 2` huenda kwenye workspace ya pili ya monitor uliyopo, na upau wa juu wa kila monitor huonyesha workspace zake na ile inayoonyesha. `Super + Tab` hupita kwenye workspace za monitor uliyopo. `Super + Shift + Ctrl + Arrows` husogeza dirisha ulilopo hadi kwenye monitor iliyo upande huo, hadi kwenye workspace inayoonyesha, na `Super + Shift + Alt + Arrows` husogeza workspace uliyopo hadi kwenye monitor iliyo upande huo, ambapo inachukua nambari ile ile ikiwa iko wazi. Monitor huhifadhi workspace zake unapoichomoa: huungana na za skrini nyingine, zikiwa na nambari baada ya zile ilizonazo tayari, na hurudi chini ya nambari zao za zamani monitor inapokurudia.

Ukishikilia `Super` na kutumia kipanya kubofya dirisha, utaweza kupanga upya mahali lilipo. Ukishikilia `Super` na kutumia kitufe cha kulia kwenye kipanya, unaweza kubadilisha ukubwa wa dirisha kwa uhuru.

Unafunga dirisha kwa `Super + W` au `Super + Q` (na funga madirisha yote kwa `Ctrl + Alt + Delete`).

Unaweza pia kwenda skrini nzima kwa `Super + F` au hata upana kamili tu (ukihifadhi upau wa juu) kwa `Super + Alt + F` au skrini nzima ndani ya dirisha kwa `Super + Ctrl + F` (nzuri kwa YouTube!).

### Mpangilio wa dwindle dhidi ya wa scrolling

Mpangilio chaguomsingi wa Omarchy unaitwa dwindle. Huhifadhi madirisha yote unayofungua kwenye workspace moja yakiwa yanaonekana wakati wote, hata kama inabidi iyapunguze ukubwa.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Lakini unaweza pia kuchagua kugeuza workspace kuwa mpangilio wa scrolling ambapo madirisha yamepangwa kando kwa kando, zaidi ya ukingo unaoonekana wa onyesho. Unageuza workspace moja kuwa mpangilio huu kupitia `Super + L`.

Kubonyeza `Super + L` tena hugeuza workspace kuwa floating, ambapo madirisha huingiliana kwa uhuru na unayaweka mwenyewe, na kubonyeza mara ya tatu huirudisha kwenye dwindle. `Super + Alt + L` hupitia humo kwa upande mwingine. Dirisha linaloelea hata hivyo — moja ulilotoa kwa `Super + T`, au programu ambayo daima hufunguka ikielea — hubaki likielea wakati workspace inarudi kwenye tiling. Upau wa juu huweka alama kwenye workspace uliyopo kwa mpangilio wake: mraba kwa dwindle, duara kwa scrolling, na pembetatu kwa floating. Kubofya alama hiyo hupitia mipangilio pia, na vivyo hivyo kitufe cha onyesho kwenye laptop zenye kimoja.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Chaguo ni kwa kila workspace, na hubaki. Kwa hivyo unaweza kuweka workspace 1 kwenye dwindle kwa kuvinjari na workspace 2 kwenye scrolling kwa code, na zitarudi hivyo baada ya kuanzisha upya.

Ukitaka kutumia mpangilio wa scrolling kama chaguomsingi, unaweza kuweka hilo katika `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Workspace zinazoelea

Workspace inayoelea hufanya kazi kama desktop ya kitamaduni: madirisha huingiliana, na unayasogeza na kuyabadilisha ukubwa mwenyewe. Kila dirisha hupata upau wa kichwa katika rangi za theme yako, na vitufe vya kukupunguza, kukukuza, na kufunga. `Super + M` hukupunguza dirisha lililolengwa pia. Dirisha lililopunguzwa husubiri kwenye dock; bofya programu yake ili kulirudisha. Bofya dirisha ili kulileta mbele. Libadilishe ukubwa kutoka ukingo au kona yoyote. Bofya mara mbili upau wa kichwa ili kukuza dirisha huku ukiweka upau wa juu ukionekana, na tena ili kupata ukubwa wake wa zamani. Chrome na vivinjari vingine vinavyotumia Chromium, Disks na Document Viewer huruka upau wa kichwa na kutumia header yao wenyewe badala yake; `Super + Alt + F` huyakuza, na `Super + M` huyapunguza.

Kila workspace ina dock, yenye programu zako zilizobandikwa, kila kitu kinachoendelea, na gridi ya kila programu nyuma ya kitufe cha programu, ambayo `Super + Alt + Space` na _Apps_ katika menyu ya Omarchy hufungua pia. Bofya kulia programu kwenye gridi, au bonyeza `Delete`, ili kuiondoa. Bofya programu ili kuifungua, au kuleta dirisha lake mbele; bofya tena ili kupita kwenye madirisha yake. Files hurudisha tu dirisha kutoka workspace uliyopo na vinginevyo hufungua jipya, na Terminal na Agent daima huanzisha jingine, ingawa dirisha lililopunguzwa hurudi kwanza. Bofya katikati hufungua dirisha jipya. Buruta ikoni kando ya dock ili kuisogeza; kuburuta programu inayoendelea kati ya nyingine huiweka hapo. Bofya kulia ili kuweka programu kwenye dock, kuitoa, au kuiacha. Dock hubaki nje wakati workspace iko tupu, na mara workspace inapokuwa na dirisha hujificha hadi kielekezi kifike ukingoni mwake. Dirisha la skrini nzima huificha kabisa. Buruta kitufe cha programu kuelekea ukingo mwingine wa skrini ili kusogeza dock huko. Bofya kulia kwa _Position_, ili kuchagua ukingo, na _Layout_, ili kuweka mpangilio chaguomsingi kama _Appearance > Workspace Layout_ inavyofanya. Nafasi pia iko chini ya _Appearance > Dock > Dock Position_, na `omarchy dock position left` huiweka kutoka terminal. Programu unazoweka kwenye dock zimefifia wakati haziendelei. Ili kuweka dock kwenye workspace zinazoelea tu, tumia _Appearance > Dock > Dock Only on Floating_ au `omarchy dock tiling off`.

Workspace mpya, na yoyote ambayo hujaipa mpangilio wake mwenyewe kwa `Super + L`, hutumia mpangilio chaguomsingi. Kubadilisha chaguomsingi huweka upya kila workspace isiyo na madirisha kwake, wakati ile yenye madirisha hubaki na mpangilio ilionao. Dirisha lililopunguzwa hadi kwenye dock bado huhesabika kama dirisha kwenye workspace iliyoiacha. Lichague chini ya _Appearance > Workspace Layout_: Tiling, Scrolling, au Floating. `omarchy hyprland workspace layout default scrolling` huiweka kutoka terminal.

### Kupanga madirisha katika vikundi

Madirisha yanaweza kupangwa katika vikundi kwa kutumia `Super + G`. Mara unapokuwa katika kikundi, kila dirisha unaloanzisha wakati hicho kinafanya kazi litakuwa la kikundi. Unaweza kusogeza kati ya madirisha haya yaliyopangwa katika vikundi kwa kutumia `Super + Ctrl + Arrow Left/Right` au `Super + Alt + 1/2/3/4` kwenda moja kwa moja kwenye madirisha yaliyopangwa katika vikundi kwa mpangilio.

Unaweza kusogeza dirisha nje ya kikundi kwa `Super + Alt + G` au kutenganisha kikundi kizima kwa kubonyeza `Super + G` tena. Mwishowe, unaweza kusogeza madirisha yaliyo nje ya kikundi kuingia humo kwa `Super + Alt + Arrows`.

### Kutoa madirisha

Unaweza kutoa dirisha kutoka kwenye ugawaji wake wa workspace kwa `Super + O`. Hiyo italibandika kama dirisha linaloelea linalokufuata kwenye workspace yoyote unayoenda. Nzuri kwa vicheza video na kadhalika.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Workspace ya scratchpad

Kuna workspace maalum ya scratchpad ya ukubwa kamili inayofunika workspace yoyote uliyopo sasa. Unafikia kilichomo kwa kutumia `Super + S`, na unaweka madirisha huko kwa kutumia `Super + Alt + S`.

Inafanya kazi vizuri kwa vidhibiti au terminal unayotaka kuingiliana nayo haraka bila kuacha workspace ya sasa.

### Console ya Quake

Mwishowe, kuna console ya Quake ya nusu urefu inayoshuka juu ya workspace yoyote uliyopo sasa. Ibadilishe kwa `Super + the key above Tab` (grave kwenye mipangilio ya US), na weka dirisha huko kwa kutumia `Super + Shift + the key above Tab`.

Mara ya kwanza inapofunguka, inaanzisha agent wako chaguomsingi, au inakuomba uchague mmoja ikiwa bado hujachagua mmoja. Wakati console inashikilia dirisha moja, inashuka kama paneli iliyowekwa katikati badala ya kuenea skrini. Weka programu ya pili juu yake na inarudi kwenye upana kamili, ili hizi mbili ziwe na nafasi ya kukaa kando kwa kando.

Ili kusogeza dirisha kutoka scratchpad au console, litume moja kwa moja hadi workspace nyingine kwa kitu kama `Super + Shift + 1`.

### Inachukua muda kuzoea!

Inachukua muda kidogo kuzoea kusogeza desktop yako hivi, lakini mara unapofanya hivyo, itakuwa vigumu kurudi kwenye uzoefu wa desktop ya kitamaduni inayoendeshwa kwa kipanya!
