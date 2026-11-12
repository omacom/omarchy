# Urambazaji

Kila kitu katika Omarchy hufanyika kupitia kibodi — _KILA KITU!_ Mfumo unapoanza kwa mara ya kwanza, kihalisi huwezi kufanya chochote kwa kipanya pekee. Lakini unaweza kubonyeza `Super + Space` ili kufunua Menyu ya Omarchy na kuanzia hapa unaweza kufanya takriban kila kitu.

Lakini menyu ya Omarchy hata haikukusudiwa kuwa njia kuu ya kuendesha mfumo kwa muda mwingi. Tunaweza kuwa wepesi zaidi ya hivyo! Programu zote muhimu zaidi zimefungwa moja kwa moja kwenye vitufe vya haraka vya pekee. Unaanzisha terminal kwa `Super + Return` na kivinjari kwa `Super + Shift + Return`. Jaribu kufanya moja baada ya nyingine, na utaona uchawi wa upigaji vigae wa Hyprland ukifanya kazi:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Unaweza kisha kubonyeza `Super + J` ili kuyapanga moja juu ya nyingine badala ya kando kwa kando:

 ![navigation-stacked](images/navigation-stacked.webp)

Bonyeza `Super + J` tena ili kuyarudisha katika nafasi zao za kando kwa kando. Kisha jaribu `Super + Shift + Arrow Right` ukiwa katika kivinjari ili kubadilishana madirisha.

Sasa jaribu `Super + Shift + T` ili kuanzisha Activity monitor. Hiyo itaonekana kama dirisha linaloelea. Unaweza kulipanga kwa vigae kwa kutumia `Super + T` (na kubonyeza hiyo tena ili kulifanya lielee tena). Sasa bonyeza `Super + Shift + F` ili kufungua kidhibiti faili. Utakuwa na mpangilio nadhifu wa njia nne:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Unasogea kati ya dirisha unalotaka liwe linalofanya kazi kwa `Super + Arrow`. Hii itahamisha mwelekeo na kusogeza kishale hadi katikati ya programu mpya. Kwenye ukingo wa skrini, inaendelea hadi kwenye kifuatiliaji kilicho upande huo.

Ukibonyeza `Super + Shift + 2`, utasogeza programu iliyolengwa sasa hadi kwenye nafasi ya kazi ya pili. `Super + Shift + 1` inairudisha. (Na `Super + Shift + Alt + 2` itasogeza programu iliyolengwa sasa hadi kwenye nafasi ya kazi ya pili bila kubadili kwenda kwake).

Ukiwa na vifuatiliaji zaidi ya kimoja, kila kifuatiliaji kina nafasi za kazi 1 hadi 10 zake chenyewe. `Super + 2` huenda kwenye nafasi ya kazi ya pili ya kifuatiliaji ulichopo, na upau wa juu wa kila kifuatiliaji huonyesha nafasi zake za kazi na ile inayoonyeshwa. `Super + Tab` huzunguka kupitia nafasi za kazi kwenye kifuatiliaji ulichopo. `Super + Shift + Ctrl + Arrows` husogeza dirisha ulilopo hadi kwenye kifuatiliaji katika mwelekeo huo, hadi kwenye nafasi ya kazi inayoonyeshwa, na `Super + Shift + Alt + Arrows` husogeza nafasi ya kazi uliyopo hadi kwenye kifuatiliaji katika mwelekeo huo, ambapo inachukua nambari ile ile ikiwa iko wazi. Kifuatiliaji huhifadhi nafasi zake za kazi unapokichomoa: zinajiunga na za skrini nyingine, zikiwa na nambari baada ya zile ilizonazo tayari, na hurudi chini ya nambari zao za zamani kifuatiliaji kinaporejea.

Ukiishikilia `Super` na kutumia kipanya kubofya dirisha, utaweza kupanga upya mahali linapokaa. Ukiishikilia `Super` na kutumia kitufe cha kulia cha kipanya, unaweza kubadilisha ukubwa wa dirisha kwa uhuru.

Unafunga dirisha kwa `Super + W` au `Super + Q` (na kufunga madirisha yote kwa `Ctrl + Alt + Delete`).

Unaweza pia kwenda skrini nzima kwa `Super + F` au hata upana kamili tu (ukiubakiza upau wa juu) kwa `Super + Alt + F` au skrini nzima ndani ya dirisha kwa `Super + Ctrl + F` (nzuri kwa YouTube!).

### Mpangilio wa dwindle dhidi ya scrolling

Mpangilio chaguomsingi wa Omarchy unaitwa dwindle. Huweka madirisha yote unayofungua kwenye nafasi moja ya kazi yaonekane wakati wote, hata ikiwa inabidi iyapunguze ukubwa.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Lakini unaweza pia kuchagua kugeuza nafasi ya kazi kuwa mpangilio wa scrolling ambapo madirisha yamepangwa kando kwa kando, kupita ukingo unaoonekana wa onyesho. Unaigeuza nafasi moja ya kazi kuwa mpangilio huu kupitia `Super + L`.

Kubonyeza `Super + L` tena hugeuza nafasi ya kazi kuwa inayoelea, ambapo madirisha huingiliana kwa uhuru na unayaweka mwenyewe, na kubonyeza kwa mara ya tatu huirudisha kwenye dwindle. `Super + Alt + L` hupitia hayo kwa mwelekeo wa kinyume. Dirisha linaloelea vyovyote vile — ulilotoa kwa `Super + T`, au programu inayofunguka kila wakati ikielea — hubaki likielea nafasi ya kazi inapojirudisha kwenye upigaji vigae. Upau wa juu huweka alama kwenye nafasi ya kazi uliyopo kwa mpangilio wake: mraba kwa dwindle, duara kwa scrolling, na pembetatu kwa inayoelea. Kubofya alama hiyo pia huzungusha mpangilio.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Chaguo ni kwa kila nafasi ya kazi, na hubaki. Kwa hiyo unaweza kuweka nafasi ya kazi 1 kwenye dwindle kwa kuvinjari na nafasi ya kazi 2 kwenye scrolling kwa msimbo, na zitarudi hivyo baada ya kuwasha upya.

Ikiwa unataka kutumia mpangilio wa scrolling kama chaguomsingi, unaweza kuweka hilo katika `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Nafasi za kazi zinazoelea

Nafasi ya kazi inayoelea hufanya kazi kama eneo-kazi la kitamaduni: madirisha huingiliana, na wewe huyasogeza na kuyabadilisha ukubwa mwenyewe. Kila dirisha hupata upau wa kichwa katika rangi za mandhari yako, wenye vitufe vya kupunguza, kukuza, na kufunga. `Super + M` pia hupunguza dirisha lililolengwa. Dirisha lililopunguzwa husubiri katika dock; bofya programu yake ili kulirudisha. Bofya dirisha ili kulileta mbele. Libadilishe ukubwa kutoka ukingo au kona yoyote. Bofya mara mbili upau wa kichwa ili kukuza dirisha huku upau wa juu ukiendelea kuonekana, na tena ili kupata ukubwa wake wa zamani. Chrome na vivinjari vingine vinavyotegemea Chromium, Disks na Document Viewer huruka upau wa kichwa na kutumia kichwa chao wenyewe badala yake; `Super + Alt + F` huyakuza, na `Super + M` huyapunguza.

Nafasi ya kazi inayoelea pia huonyesha dock, yenye programu zako zilizobandikwa, kila kitu kinachoendeshwa, na gridi ya kila programu nyuma ya kitufe cha programu, ambayo `Super + Alt + Space` na _Apps_ katika menyu ya Omarchy pia huifungua. Bofya kulia programu kwenye gridi, au bonyeza `Delete`, ili kuiondoa. Bofya programu ili kuifungua, au kuleta dirisha lake mbele; bofya tena ili kuzunguka kupitia madirisha yake. Kubofya kwa kitufe cha kati hufungua dirisha jipya. Buruta aikoni kando ya dock ili kuisogeza; kuburuta programu inayoendeshwa kati ya nyingine huiweka pale. Bofya kulia ili kuweka programu katika dock, kuitoa, au kuifunga. Dock hujiondoa mbele ya dirisha la skrini nzima. Bofya kulia kitufe cha programu ili kusogeza dock hadi ukingo mwingine au kuifanya ifichike hadi kishale kifike ukingoni mwake. Nafasi pia iko chini ya _Appearance > Dock > Dock Position_, na `omarchy dock position left` na `omarchy dock autohide on` huweka zote mbili kutoka kwenye terminal. Programu unazoweka katika dock hufifia zikiwa haziendeshwi.

Nafasi mpya za kazi, na yoyote ambayo hujaipa mpangilio wake yenyewe kwa `Super + L`, hutumia mpangilio chaguomsingi. Kubadilisha chaguomsingi huweka upya kila nafasi ya kazi isiyo na madirisha kwake, ilhali ile yenye madirisha hubaki na mpangilio ilionao. Dirisha lililopunguzwa hadi kwenye dock bado huhesabika kama dirisha kwenye nafasi ya kazi lililotoka. Lichague chini ya _Appearance > Workspace Layout_: Tiling, Scrolling, au Floating. `omarchy-hyprland-workspace-layout-default scrolling` huliweka kutoka kwenye terminal.

### Kupanga madirisha katika vikundi

Madirisha yanaweza kupangwa katika vikundi kwa kutumia `Super + G`. Ukishaingia katika kikundi, kila dirisha unaloanzisha wakati hicho kinafanya kazi litakuwa la kikundi. Unaweza kusogea kati ya madirisha haya yaliyopangwa katika vikundi kwa kutumia `Super + Ctrl + Arrow Left/Right` au `Super + Alt + 1/2/3/4` ili kwenda moja kwa moja kwenye madirisha yaliyopangwa kwa mpangilio.

Unaweza kusogeza dirisha kutoka kwenye kikundi kwa `Super + Alt + G` au kuvunja kikundi kizima kwa kubonyeza `Super + G` tena. Mwishowe, unaweza kusogeza madirisha yaliyo nje ya kikundi kuingia ndani yake kwa `Super + Alt + Arrows`.

### Kutoa madirisha

Unaweza kutoa dirisha kutoka kwenye ugawaji wake wa nafasi ya kazi kwa `Super + O`. Hilo litalibandika kama dirisha linaloelea linalokufuata kwenye nafasi yoyote ya kazi unayoenda. Nzuri kwa vicheza video na vingine kama hivyo.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Nafasi ya kazi ya scratchpad

Kuna nafasi maalum ya kazi ya scratchpad ya ukubwa kamili inayofunika nafasi yoyote ya kazi uliyopo sasa. Unafikia kilichomo kwa kutumia `Super + S`, na unaweka madirisha huko kwa kutumia `Super + Alt + S`.

Inafanya kazi vizuri kwa vidhibiti au terminal unayotaka kuingiliana nayo haraka bila kuondoka kwenye nafasi ya kazi ya sasa.

### Konsoli ya Quake

Mwishowe, kuna konsoli ya Quake ya nusu urefu inayoshuka juu ya nafasi yoyote ya kazi uliyopo sasa. Ibadilishe kwa `Super + Grave`, na weka dirisha huko kwa kutumia `Super + Shift + Grave`.

Inafunguka ikiwa na agent wako chaguomsingi tayari kuanza. Konsoli ikiwa na dirisha moja tu, hushuka kama paneli iliyowekwa katikati badala ya kuenea skrini. Weka programu ya pili juu yake na inarudi kwenye upana kamili, ili hizo mbili zipate nafasi ya kukaa kando kwa kando.

Ili kusogeza dirisha kutoka kwenye scratchpad au konsoli, lipeleke moja kwa moja kwenye nafasi nyingine ya kazi kwa kitu kama `Super + Shift + 1`.

### Inahitaji kuzoea kidogo!

Inachukua muda mfupi kuzoea kuendesha eneo-kazi lako hivi, lakini ukishazoea, itakuwa vigumu kurudi kwenye uzoefu wa kitamaduni wa eneo-kazi unaoendeshwa na kipanya!
