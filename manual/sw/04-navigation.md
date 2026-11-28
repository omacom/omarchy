# Urambazaji

Kila kitu katika Omarchy hutokea kupitia kibodi — _KILA KITU!_ Mfumo unapoanza kwa mara ya kwanza, kihalisi huwezi kufanya chochote kwa kipanya pekee. Lakini unaweza kubonyeza `Super + Space` ili kufunua Menyu ya Omarchy na kuanzia hapa unaweza kufanya karibu kila kitu.

Lakini menyu ya Omarchy hata haikukusudiwa kuwa njia kuu ya kuendesha mfumo mara nyingi. Tunaweza kuwa wepesi zaidi kuliko hivyo! Programu zote muhimu zaidi zimefungwa moja kwa moja kwenye vitufe vya mkato vya kibinafsi. Unaanzisha terminal kwa `Super + Return` na kivinjari kwa `Super + Shift + Return`. Jaribu kufanya moja baada ya jingine, na utaona uchawi wa kupanga tiles wa Hyprland ukifanya kazi:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Kisha unaweza kubonyeza `Super + J` ili kuziweka moja juu ya nyingine badala ya kando kwa kando:

 ![navigation-stacked](images/navigation-stacked.webp)

Bonyeza `Super + J` tena ili kuzirudisha katika nafasi zao za kando kwa kando. Kisha jaribu `Super + Shift + Arrow Right` ukiwa kwenye kivinjari ili kubadilishana madirisha.

Sasa jaribu `Super + Shift + T` ili kuanzisha Activity monitor. Hiyo itaonekana kama dirisha linaloelea. Unaweza kulipanga kama tile kwa kutumia `Super + T` (na bonyeza hiyo tena ili kulifanya lielee tena). Sasa bonyeza `Super + Shift + F` ili kufungua kidhibiti cha faili. Utakuwa na mpangilio nadhifu wa njia nne:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Unasafiri kati ya dirisha unalotaka liwe linalofanya kazi kwa `Super + Arrow`. Hii itabadilisha lengo na kuhamisha kishale hadi katikati ya programu mpya. Kwenye ukingo wa skrini, inaendelea hadi kwenye monita iliyo upande huo.

Ukibonyeza `Super + Shift + 2`, utahamisha programu iliyolengwa sasa hadi kwenye nafasi ya kazi ya pili. `Super + Shift + 1` huirudisha. (Na `Super + Shift + Alt + 2` itahamisha programu iliyolengwa sasa hadi kwenye nafasi ya kazi ya pili bila kubadilisha kwenda huko).

Ukiwa na monita zaidi ya moja, kila monita ina nafasi zake za kazi 1 hadi 10. `Super + 2` huenda kwenye nafasi ya kazi ya pili ya monita uliyo juu yake, na upau wa juu wa kila monita huonyesha nafasi zake za kazi na ile inayoonyesha. `Super + Tab` huzunguka kupitia nafasi za kazi kwenye monita uliyo juu yake. `Super + Shift + Ctrl + Arrows` huhamisha dirisha ulilopo hadi kwenye monita katika mwelekeo huo, hadi kwenye nafasi ya kazi inayoonyesha, na `Super + Shift + Alt + Arrows` huhamisha nafasi ya kazi uliyo juu yake hadi kwenye monita katika mwelekeo huo, ambapo inachukua nambari ile ile ikiwa iko wazi. Monita huhifadhi nafasi zake za kazi unapoichomoa: huungana na za skrini nyingine, zikiwa na nambari baada ya zile ilizonazo tayari, na hurudi chini ya nambari zao za zamani monita inaporudi.

Ukishikilia `Super` na kutumia kipanya kubofya dirisha, utaweza kupanga upya mahali linapokaa. Ukishikilia `Super` na kutumia kitufe cha kulia kwenye kipanya, unaweza kubadilisha ukubwa wa dirisha kwa uhuru.

Unafunga dirisha kwa `Super + W` au `Super + Q` (na unafunga madirisha yote kwa `Ctrl + Alt + Delete`).

Unaweza pia kwenda skrini nzima kwa `Super + F` au hata upana kamili tu (huku ukiweka upau wa juu) kwa `Super + Alt + F` au skrini nzima ndani ya dirisha kwa `Super + Ctrl + F` (nzuri kwa YouTube!).

### Dwindle dhidi ya mpangilio wa scrolling

Mpangilio chaguomsingi wa Omarchy unaitwa dwindle. Huweka madirisha yote unayofungua kwenye nafasi moja ya kazi yaonekane wakati wote, hata ikiwa inabidi iyapunguze ukubwa.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Lakini unaweza pia kuchagua kugeuza nafasi ya kazi kuwa mpangilio wa scrolling ambapo madirisha yamepangwa kando kwa kando, zaidi ya ukingo unaoonekana wa onyesho. Unageuza nafasi moja ya kazi kuwa mpangilio huu kupitia `Super + L`.

Kubonyeza `Super + L` tena hugeuza nafasi ya kazi kuwa inayoelea, ambapo madirisha huingiliana kwa uhuru na unayaweka mwenyewe, na kubonyeza mara ya tatu huirudisha kwenye dwindle. `Super + Alt + L` hupitia hivyo kwa mwelekeo wa kinyume. Dirisha linaloelea hata hivyo — lile ulilotoa nje kwa `Super + T`, au programu ambayo daima hufunguka ikielea — hubaki likielea nafasi ya kazi inaporudi kwenye kupanga tiles. Upau wa juu huweka alama kwenye nafasi ya kazi uliyo juu yake kwa mpangilio wake: mraba kwa dwindle, duara kwa scrolling, na pembetatu kwa inayoelea. Kubofya alama hiyo pia huzungusha mpangilio, na vivyo hivyo kitufe cha onyesho kwenye laptop zilizo nacho.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Chaguo ni kwa kila nafasi ya kazi, na hubaki. Kwa hivyo unaweza kuweka nafasi ya kazi 1 kwenye dwindle kwa kuvinjari na nafasi ya kazi 2 kwenye scrolling kwa msimbo, na zitarudi hivyo baada ya kuwasha upya.

Ikiwa unataka kutumia mpangilio wa scrolling kama chaguomsingi, unaweza kuweka hiyo katika `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Nafasi za kazi zinazoelea

Nafasi ya kazi inayoelea hufanya kazi kama desktop ya kitamaduni: madirisha huingiliana, na unayahamisha na kuyabadilisha ukubwa mwenyewe. Kila dirisha hupata upau wa kichwa katika rangi za mandhari yako, na vitufe vya kupunguza, kupanua, na kufunga. `Super + M` pia hupunguza dirisha lililolengwa. Dirisha lililopunguzwa husubiri kwenye dock; bofya programu yake ili kulirudisha. Bofya dirisha ili kulileta mbele. Libadilishe ukubwa kutoka ukingo au kona yoyote. Bofya mara mbili upau wa kichwa ili kupanua dirisha huku ukiweka upau wa juu uonekane, na tena ili kupata ukubwa wake wa zamani. Chrome na vivinjari vingine vinavyotegemea Chromium, Disks na Document Viewer huruka upau wa kichwa na kutumia kichwa chao wenyewe badala yake; `Super + Alt + F` huyapanua, na `Super + M` huyapunguza.

Nafasi ya kazi inayoelea pia huonyesha dock, na programu zako zilizobandikwa, kila kitu kinachoendesha, na gridi ya kila programu nyuma ya kitufe cha programu, ambayo `Super + Alt + Space` na _Apps_ katika menyu ya Omarchy pia hufungua. Bofya kulia programu kwenye gridi, au bonyeza `Delete`, ili kuiondoa. Bofya programu ili kuifungua, au kuleta dirisha lake mbele; bofya tena ili kuzunguka kupitia madirisha yake. Files hurudisha tu dirisha kutoka nafasi ya kazi uliyo juu yake na vinginevyo hufungua jipya, na Terminal na Agent kila mara huanzisha jingine, ingawa dirisha lililopunguzwa hurudi kwanza. Bofya katikati hufungua dirisha jipya. Buruta ikoni kando ya dock ili kuihamisha; kuburuta programu inayoendesha kati ya nyingine huiweka hapo. Bofya kulia ili kuweka programu kwenye dock, kuitoa, au kuifunga. Dock huondoka mbele ya dirisha la skrini nzima. Bofya kulia kitufe cha programu ili kuhamisha dock hadi ukingo mwingine au kuifanya ifichike hadi kishale kifike ukingoni mwake. Nafasi pia iko chini ya _Appearance > Dock > Dock Position_, na `omarchy dock position left` na `omarchy dock autohide on` huweka zote mbili kutoka terminal. Programu unazoweka kwenye dock zimefifia wakati haziendeshi.

Nafasi mpya za kazi, na yoyote ambayo hujaipa mpangilio wake yenyewe kwa `Super + L`, hutumia mpangilio chaguomsingi. Kubadilisha chaguomsingi huweka upya kila nafasi ya kazi isiyo na madirisha kwake, wakati ile yenye madirisha juu yake huhifadhi mpangilio ilionao. Dirisha lililopunguzwa hadi kwenye dock bado huhesabika kama dirisha kwenye nafasi ya kazi iliyoiacha. Ichague chini ya _Appearance > Workspace Layout_: Tiling, Scrolling, au Floating. `omarchy hyprland workspace layout default scrolling` huiweka kutoka terminal.

### Kupanga madirisha katika vikundi

Madirisha yanaweza kupangwa katika vikundi kwa kutumia `Super + G`. Mara tu unapokuwa kwenye kikundi, kila dirisha unaloanzisha wakati huo likiwa linafanya kazi litakuwa la kikundi. Unaweza kusafiri kati ya madirisha haya yaliyopangwa kwa kutumia `Super + Ctrl + Arrow Left/Right` au `Super + Alt + 1/2/3/4` ili kwenda moja kwa moja kwenye madirisha yaliyopangwa kwa mpangilio.

Unaweza kuhamisha dirisha nje ya kikundi kwa `Super + Alt + G` au kuvunja kikundi chote kwa kubonyeza `Super + G` tena. Mwishowe, unaweza kuhamisha madirisha yaliyo nje ya kikundi hadi ndani yake kwa `Super + Alt + Arrows`.

### Kutoa madirisha nje

Unaweza kutoa dirisha nje ya mgawo wake wa nafasi ya kazi kwa `Super + O`. Hiyo italibandika kama dirisha linaloelea linalokufuata kwenye nafasi yoyote ya kazi unayoenda. Nzuri kwa vicheza video na kadhalika.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Nafasi ya kazi ya scratchpad

Kuna nafasi maalum ya kazi ya scratchpad ya ukubwa kamili inayofunika nafasi yoyote ya kazi uliyo juu yake sasa. Unafikia kilichomo kwa kutumia `Super + S`, na unaweka madirisha huko kwa kutumia `Super + Alt + S`.

Inafanya kazi vizuri kwa vidhibiti au terminal unayotaka kuingiliana nayo haraka bila kuondoka kwenye nafasi ya kazi ya sasa.

### Konsoli ya Quake

Mwishowe, kuna konsoli ya Quake ya nusu urefu inayoshuka juu ya nafasi yoyote ya kazi uliyo juu yake sasa. Ibadilishe kwa `Super + the key above Tab` (grave katika mipangilio ya US), na weka dirisha huko kwa kutumia `Super + Shift + the key above Tab`.

Mara ya kwanza inapofunguka, huanzisha agent wako chaguomsingi, au hukuomba uchague mmoja ikiwa bado hujaamua mmoja. Wakati konsoli ina dirisha moja tu, hushuka kama paneli iliyowekwa katikati badala ya kuenea skrini. Weka programu ya pili juu yake na inarudi kwenye upana kamili, ili hizo mbili ziwe na nafasi ya kukaa kando kwa kando.

Ili kuhamisha dirisha kutoka scratchpad au konsoli, lipeleke moja kwa moja hadi nafasi nyingine ya kazi kwa kitu kama `Super + Shift + 1`.

### Inachukua muda kuzoea!

Inachukua muda kidogo kuzoea kusafiri kwenye desktop yako kama hii, lakini mara tu unapozoea, itakuwa vigumu kurudi kwenye uzoefu wa desktop wa kitamaduni unaoendeshwa na kipanya!
