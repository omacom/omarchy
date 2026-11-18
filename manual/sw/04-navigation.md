# Urambazaji

Kila kitu katika Omarchy hufanyika kupitia kibodi — _KILA KITU!_ Mfumo unapoanza kwa mara ya kwanza, kihalisi huwezi kufanya chochote kwa kipanya pekee. Lakini unaweza kubonyeza `Super + Space` ili kufunua Menyu ya Omarchy na kuanzia hapa unaweza kufanya karibu kila kitu.

Lakini menyu ya Omarchy hata haijakusudiwa kuwa njia kuu ya kuendesha mfumo kwa muda mwingi. Tunaweza kwenda haraka zaidi kuliko hivyo! Programu zote muhimu zaidi zimefungwa moja kwa moja kwenye vitufe vya mkato vya pekee. Unawasha terminali kwa `Super + Return` na kivinjari kwa `Super + Shift + Return`. Jaribu kufanya moja baada ya jingine, na utaona uchawi wa upangaji wa vigae wa Hyprland ukifanya kazi:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Unaweza kisha kubonyeza `Super + J` ili kuvipanga moja juu ya jingine badala ya kando kwa kando:

 ![navigation-stacked](images/navigation-stacked.webp)

Bonyeza `Super + J` tena ili kuvirudisha kwenye nafasi zake za kando kwa kando. Kisha jaribu `Super + Shift + Arrow Right` ukiwa kwenye kivinjari ili kubadilishana madirisha.

Sasa jaribu `Super + Shift + T` ili kuwasha kifuatiliaji cha Activity. Hicho kitaonekana kama dirisha linaloelea. Unaweza kulipanga kama kigae kwa kutumia `Super + T` (na bonyeza hiyo tena ili kulifanya lielee tena). Sasa bonyeza `Super + Shift + F` ili kufungua kidhibiti cha faili. Utakuwa na mpangilio safi wa njia nne:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Unasafiri kati ya dirisha unalotaka liwe amilifu kwa `Super + Arrow`. Hii itabadilisha mwelekeo na kusogeza kishale katikati ya programu mpya. Ukingoni mwa skrini, inaendelea hadi kwenye monita iliyo upande huo.

Ukibonyeza `Super + Shift + 2`, utasogeza programu iliyolengwa sasa hivi hadi kwenye nafasi ya kazi ya pili. `Super + Shift + 1` inairejesha. (Na `Super + Shift + Alt + 2` itasogeza programu iliyolengwa sasa hivi hadi kwenye nafasi ya kazi ya pili bila kubadili kwenda kwake).

Ukiwa na monita zaidi ya moja, kila monita ina nafasi zake za kazi 1 hadi 10. `Super + 2` inaenda kwenye nafasi ya kazi ya pili ya monita uliyo juu yake, na upau wa juu wa kila monita unaonyesha nafasi zake za kazi na ile inayoonyesha. `Super + Tab` inazunguka kupitia nafasi za kazi kwenye monita uliyo juu yake. `Super + Shift + Ctrl + Arrows` inasogeza dirisha ulilo juu yake hadi kwenye monita iliyo upande huo, hadi kwenye nafasi ya kazi inayoonyesha, na `Super + Shift + Alt + Arrows` inasogeza nafasi ya kazi uliyo juu yake hadi kwenye monita iliyo upande huo, ambapo inachukua nambari ile ile ikiwa iko wazi. Monita huhifadhi nafasi zake za kazi unapoichomoa: zinajiunga na za skrini nyingine, zikiwa na nambari baada ya zile ilizo nazo tayari, na hurudi chini ya nambari zake za awali monita inaporudi.

Ukishikilia `Super` na kutumia kipanya kubofya dirisha, utaweza kupanga upya mahali linapokaa. Ukishikilia `Super` na kutumia kitufe cha kulia cha kipanya, unaweza kubadilisha ukubwa wa dirisha kwa uhuru.

Unafunga dirisha kwa `Super + W` au `Super + Q` (na kufunga madirisha yote kwa `Ctrl + Alt + Delete`).

Unaweza pia kwenda skrini nzima kwa `Super + F` au hata upana kamili tu (huku ukiweka upau wa juu) kwa `Super + Alt + F` au skrini nzima ndani ya dirisha kwa `Super + Ctrl + F` (nzuri kwa YouTube!).

### Mpangilio wa dwindle dhidi ya scrolling

Mpangilio chaguomsingi wa Omarchy unaitwa dwindle. Huweka madirisha yote unayofungua kwenye nafasi moja ya kazi yaonekane wakati wote, hata ikiwa inabidi kuyapunguza ukubwa.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Lakini pia unaweza kuchagua kubadilisha nafasi ya kazi kuwa mpangilio wa scrolling ambapo madirisha yamepangwa kando kwa kando, zaidi ya ukingo unaoonekana wa onyesho. Unabadilisha nafasi moja ya kazi kuwa mpangilio huu kupitia `Super + L`.

Kubonyeza `Super + L` tena kunabadilisha nafasi ya kazi kuwa inayoelea, ambapo madirisha huingiliana kwa uhuru na unayaweka mwenyewe, na kubonyeza mara ya tatu kunairudisha kwenye dwindle. `Super + Alt + L` hupitia hayo kwa njia nyingine. Dirisha linaloelea hata hivyo — lile ulilochomoza kwa `Super + T`, au programu ambayo daima hufunguka ikielea — huendelea kuelea wakati nafasi ya kazi inarudi kwenye upangaji wa vigae. Upau wa juu huweka alama kwenye nafasi ya kazi uliyo juu yake kwa mpangilio wake: mraba kwa dwindle, duara kwa scrolling, na pembetatu kwa inayoelea. Kubofya alama hiyo pia huzungusha mpangilio.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Chaguo ni kwa kila nafasi ya kazi, na hubaki. Kwa hivyo unaweza kuweka nafasi ya kazi 1 kwenye dwindle kwa kuvinjari na nafasi ya kazi 2 kwenye scrolling kwa msimbo, na zitarudi hivyo baada ya kuwasha upya.

Ukitaka kutumia mpangilio wa scrolling kama chaguomsingi, unaweza kuweka hiyo katika `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Nafasi za kazi zinazoelea

Nafasi ya kazi inayoelea hufanya kazi kama eneo-kazi la kitamaduni: madirisha huingiliana, na unayasogeza na kuyabadilisha ukubwa mwenyewe. Kila dirisha hupata upau wa kichwa katika rangi za mandhari yako, wenye vitufe vya kupunguza, kukuza, na kufunga. `Super + M` pia hupunguza dirisha lililolengwa. Dirisha lililopunguzwa husubiri kwenye dock; bofya programu yake ili kulirejesha. Bofya dirisha ili kulileta mbele. Libadilishe ukubwa kutoka ukingo au kona yoyote. Bofya mara mbili upau wa kichwa ili kukuza dirisha huku ukiweka upau wa juu uonekane, na tena ili kupata ukubwa wake wa awali. Chrome na vivinjari vingine vinavyotegemea Chromium, Disks na Document Viewer huruka upau wa kichwa na hutumia kichwa chake badala yake; `Super + Alt + F` huvikuza, na `Super + M` huvipunguza.

Nafasi ya kazi inayoelea pia inaonyesha dock, yenye programu zako zilizobandikwa, kila kitu kinachoendeshwa, na gridi ya kila programu nyuma ya kitufe cha programu, ambacho `Super + Alt + Space` na _Apps_ katika menyu ya Omarchy pia hufungua. Bofya kulia programu kwenye gridi, au bonyeza `Delete`, ili kuiondoa. Bofya programu ili kuifungua, au kuleta dirisha lake mbele; bofya tena ili kuzunguka kupitia madirisha yake. Files hurejesha tu dirisha kutoka nafasi ya kazi uliyo juu yake na vinginevyo hufungua jipya, na Terminal na Agent daima huwasha jingine, ingawa dirisha lililopunguzwa hurudi kwanza. Kubofya katikati hufungua dirisha jipya. Buruta ikoni kando ya dock ili kuisogeza; kuburuta programu inayoendeshwa kati ya zingine huiweka hapo. Bofya kulia ili kuweka programu kwenye dock, kuitoa, au kuifunga. Dock hujiondoa kwenye njia ya dirisha la skrini nzima. Bofya kulia kitufe cha programu ili kusogeza dock hadi ukingo mwingine au kuifanya ifiche hadi kishale kifike ukingoni mwake. Nafasi pia iko chini ya _Appearance > Dock > Dock Position_, na `omarchy dock position left` na `omarchy dock autohide on` huweka zote mbili kutoka kwenye terminali. Programu unazoziweka kwenye dock hufifia zikiwa haziendeshwi.

Nafasi mpya za kazi, na yoyote ambayo hujaipa mpangilio wake mwenyewe kwa `Super + L`, hutumia mpangilio chaguomsingi. Kubadilisha chaguomsingi huweka upya kila nafasi ya kazi isiyo na madirisha kwake, wakati ile yenye madirisha juu yake huhifadhi mpangilio ilio nao. Dirisha lililopunguzwa hadi kwenye dock bado huhesabika kama dirisha kwenye nafasi ya kazi lililotoka. Ichague chini ya _Appearance > Workspace Layout_: Tiling, Scrolling, au Floating. `omarchy-hyprland-workspace-layout-default scrolling` huiweka kutoka kwenye terminali.

### Kupanga madirisha katika vikundi

Madirisha yanaweza kupangwa katika vikundi kwa kutumia `Super + G`. Mara ukiwa katika kikundi, kila dirisha unalowasha wakati huo ni amilifu litakuwa la kikundi. Unaweza kusogea kati ya madirisha haya yaliyopangwa katika vikundi kwa kutumia `Super + Ctrl + Arrow Left/Right` au `Super + Alt + 1/2/3/4` ili kwenda moja kwa moja kwenye madirisha yaliyopangwa katika vikundi kwa mpangilio.

Unaweza kusogeza dirisha nje ya kikundi kwa `Super + Alt + G` au kuvunja kikundi kizima kwa kubonyeza `Super + G` tena. Mwishowe, unaweza kusogeza madirisha yaliyo nje ya kikundi kuingia ndani yake kwa `Super + Alt + Arrows`.

### Kuchomoza madirisha

Unaweza kuchomoza dirisha kutoka kwenye ugawaji wake wa nafasi ya kazi kwa `Super + O`. Hiyo italibandika kama dirisha linaloelea linalokufuata kwenye nafasi yoyote ya kazi unayoenda. Nzuri kwa vicheza video na vingine kama hivyo.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Nafasi ya kazi ya scratchpad

Kuna nafasi maalum ya kazi ya scratchpad ya ukubwa kamili inayofunika nafasi yoyote ya kazi uliyo juu yake kwa sasa. Unafikia kilicho juu yake kwa kutumia `Super + S`, na unaweka madirisha huko kwa kutumia `Super + Alt + S`.

Inafanya kazi vizuri kwa vidhibiti au terminali unayotaka kuingiliana nayo haraka bila kuondoka kwenye nafasi ya kazi ya sasa.

### Konsoli ya Quake

Mwishowe, kuna konsoli ya Quake ya nusu urefu inayoshuka juu ya nafasi yoyote ya kazi uliyo juu yake kwa sasa. Ibadilishe kwa `Super + Grave`, na weka dirisha huko kwa kutumia `Super + Shift + Grave`.

Inafunguka na wakala wako chaguomsingi akiwa tayari kwenda. Wakati konsoli inashikilia dirisha moja, inashuka kama paneli iliyowekwa katikati badala ya kuchukua skrini nzima. Weka programu ya pili juu yake na inarudi kwenye upana kamili, ili hizi mbili ziwe na nafasi ya kukaa kando kwa kando.

Ili kusogeza dirisha kutoka kwenye scratchpad au konsoli, lipeleke moja kwa moja hadi kwenye nafasi nyingine ya kazi kwa kitu kama `Super + Shift + 1`.

### Inachukua muda kuzoea!

Inachukua muda kidogo kuzoea kusafiri kwenye eneo-kazi lako kama hivi, lakini mara ukishafanya hivyo, itakuwa vigumu kurudi kwenye uzoefu wa kitamaduni wa eneo-kazi unaoendeshwa na kipanya!
