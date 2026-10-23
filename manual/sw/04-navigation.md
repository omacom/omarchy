# Urambazaji

Kila kitu katika Omarchy hufanyika kupitia kibodi — _KILA KITU!_ Mfumo unapoanza kwa mara ya kwanza, kwa kweli huwezi kufanya chochote kwa kipanya pekee. Lakini unaweza kubonyeza `Super + Space` ili kufunua Menyu ya Omarchy na kuanzia hapa unaweza kufanya karibu kila kitu.

Lakini menyu ya Omarchy hata haikukusudiwa kuwa njia kuu ya kuendesha mfumo mara nyingi. Tunaweza kuwa wepesi zaidi ya hivyo! Programu zote muhimu zaidi zimefungwa moja kwa moja kwenye vitufe vya mkato vya kibinafsi. Unaanzisha terminal kwa `Super + Return` na kivinjari kwa `Super + Shift + Return`. Jaribu kufanya moja baada ya nyingine, na utaona uchawi wa kupanga vigae wa Hyprland ukifanya kazi:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Kisha unaweza kubonyeza `Super + J` ili kuyapanga juu ya mengine badala ya kando kwa kando:

 ![navigation-stacked](images/navigation-stacked.webp)

Bonyeza `Super + J` tena ili kuyarudisha kwenye nafasi zao za kando kwa kando. Kisha jaribu `Super + Shift + Arrow Right` ukiwa kwenye kivinjari ili kubadilishana madirisha.

Sasa jaribu `Super + Ctrl + T` ili kuanzisha kifuatiliaji cha Activity. Hicho kitaonekana kama dirisha linaloelea. Unaweza kulipanga kama kigae kwa kutumia `Super + T` (na bonyeza hiyo tena ili kulifanya lielee tena). Sasa bonyeza `Super + Shift + F` ili kufungua kidhibiti cha faili. Utakuwa na mpangilio mzuri wa sehemu nne:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Unasogeza kati ya dirisha unalotaka liwe amilifu kwa `Super + Arrow`. Hii itabadilisha mwelekeo na kusogeza kishale katikati ya programu mpya.

Ukibonyeza `Super + Shift + 2`, utahamisha programu iliyoelekezwa sasa kwenye nafasi ya kazi ya pili. `Super + Shift + 1` huirudisha. (Na `Super + Shift + Alt + 2` itahamisha programu iliyoelekezwa sasa kwenye nafasi ya kazi ya pili bila kubadilika kwenda huko).

Ukishikilia `Super` na kutumia kipanya kubofya dirisha, utaweza kupanga upya mahali linapokaa. Ukishikilia `Super` na kutumia kitufe cha kulia cha kipanya, unaweza kubadilisha ukubwa wa dirisha kwa uhuru.

Unafunga dirisha kwa `Super + W` au `Super + Q` (na kufunga madirisha yote kwa `Ctrl + Alt + Delete`).

Unaweza pia kwenda skrini nzima kwa `Super + F` au hata upana kamili tu (ukihifadhi upau wa juu) kwa `Super + Alt + F` au skrini nzima ndani ya dirisha kwa `Super + Ctrl + F` (nzuri kwa YouTube!).

### Dwindle dhidi ya mpangilio wa kusogeza

Mpangilio wa chaguo-msingi wa Omarchy unaitwa dwindle. Huweka madirisha yote unayofungua kwenye nafasi moja ya kazi yaonekane wakati wote, hata kama inabidi kuyapunguza ukubwa.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Lakini unaweza pia kuchagua kugeuza nafasi ya kazi kuwa mpangilio wa kusogeza ambapo madirisha yamepangwa kando kwa kando, zaidi ya ukingo unaoonekana wa onyesho. Unageuza nafasi moja ya kazi kuwa mpangilio huu kupitia `Super + L`.

Kubonyeza `Super + L` tena hugeuza nafasi ya kazi kuwa inayoelea, ambapo madirisha huingiliana kwa uhuru na unayaweka mwenyewe, na kubonyeza kwa mara ya tatu huirudisha kwenye dwindle. `Super + Alt + L` hupitia kwa njia nyingine. Dirisha linaloelea vyovyote vile — moja ulilotoa kwa `Super + T`, au programu ambayo hufunguka ikielea kila wakati — hubaki likielea nafasi ya kazi inapobudi kwenye kupanga vigae. Upau wa juu huweka alama kwenye nafasi ya kazi uliyopo kwa mpangilio wake: mraba kwa dwindle, duara kwa kusogeza, na pembetatu kwa kuelea. Kubofya alama hiyo pia huzungusha mpangilio.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Chaguo ni kwa kila nafasi ya kazi, na hudumu. Kwa hivyo unaweza kuweka nafasi ya kazi 1 kwenye dwindle kwa kuvinjari na nafasi ya kazi 2 kwenye kusogeza kwa msimbo, na zitarudi hivyo baada ya kuanzisha upya.

Ikiwa unataka kutumia mpangilio wa kusogeza kama chaguo-msingi, unaweza kuweka hiyo katika `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Nafasi za kazi zinazoelea

Nafasi ya kazi inayoelea hufanya kazi kama eneo-kazi la kitamaduni: madirisha huingiliana, na unayasogeza na kubadilisha ukubwa wake mwenyewe. Kila dirisha hupata upau wa kichwa katika rangi za mandhari yako, ukiwa na vitufe vya kupunguza, kupanua, na kufunga. `Super + M` pia hupunguza dirisha lililoelekezwa. Dirisha lililopunguzwa hungoja kwenye dock; bofya programu yake ili kulirudisha. Bofya dirisha ili kulileta mbele. Libadilishe ukubwa kutoka ukingo au kona yoyote. Bofya mara mbili upau wa kichwa ili kupanua dirisha huku ukihifadhi upau wa juu uonekane, na tena ili kupata ukubwa wake wa zamani.

Nafasi ya kazi inayoelea pia huonyesha dock, ikiwa na programu zako zilizobandikwa, kila kitu kinachoendeshwa, na gridi ya kila programu nyuma ya kitufe cha programu, ambacho `Super + Alt + Space` na _Programu_ katika menyu ya Omarchy hufungua pia. Bofya kulia programu kwenye gridi, au bonyeza `Delete`, ili kuiondoa. Bofya programu ili kuifungua, au kuleta dirisha lake mbele; bofya tena ili kuzunguka kupitia madirisha yake. Bofya katikati hufungua dirisha jipya. Buruta ikoni kando ya dock ili kuisogeza; kuburuta programu inayoendeshwa kati ya nyingine huiweka hapo. Bofya kulia ili kuweka programu kwenye dock, kuiondoa, au kuifunga. Dock huondoka njiani mwa dirisha la skrini nzima. Bofya kulia kitufe cha programu ili kusogeza dock kwenye ukingo mwingine au kuifanya ifichike hadi kishale kifike ukingoni mwake. Nafasi pia iko chini ya _Trigger > Mwonekano > Dock > Nafasi ya Dock_, na `omarchy dock position left` na `omarchy dock autohide on` huweka zote mbili kutoka kwenye terminal. Programu unazoweka kwenye dock hufifia zikiwa haziendeshwi.

Nafasi mpya za kazi, na yoyote ambayo hujaipa mpangilio wake mwenyewe kwa `Super + L`, hutumia mpangilio wa chaguo-msingi. Kubadilisha chaguo-msingi huweka upya kila nafasi ya kazi isiyo na madirisha kwake, wakati ile iliyo na madirisha juu yake huhifadhi mpangilio ilionao. Dirisha lililopunguzwa kwenye dock bado huhesabika kama dirisha kwenye nafasi ya kazi iliyotoka. Ichague chini ya _Trigger > Mwonekano > Mpangilio wa Nafasi ya Kazi_: Vigae, Kusogeza, au Kuelea. `omarchy-hyprland-workspace-layout-default scrolling` huiweka kutoka kwenye terminal.

### Kupanga madirisha katika vikundi

Madirisha yanaweza kupangwa katika vikundi kwa kutumia `Super + G`. Mara tu unapokuwa kwenye kikundi, kila dirisha unaloanzisha wakati huo ukiwa amilifu litakuwa la kikundi. Unaweza kusogeza kati ya madirisha haya yaliyopangwa kwa kutumia `Super + Ctrl + Arrow Left/Right` au `Super + Alt + 1/2/3/4` kwenda moja kwa moja kwenye dirisha lililopangwa kwa mpangilio.

Unaweza kusogeza dirisha kutoka kwenye kikundi kwa `Super + Alt + G` au kuvunja kikundi chote kwa kubonyeza `Super + G` tena. Mwishowe, unaweza kusogeza madirisha yaliyo nje ya kikundi ndani yake kwa `Super + Alt + Arrows`.

### Kutoa madirisha

Unaweza kutoa dirisha kutoka kwenye ugawaji wake wa nafasi ya kazi kwa `Super + O`. Hiyo italibandika kama dirisha linaloelea linalokufuata kwenye nafasi yoyote ya kazi unayokwenda. Nzuri kwa vicheza video na kadhalika.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Nafasi ya kazi ya scratchpad

Mwishowe, kuna nafasi maalum ya kazi ya scratchpad inayoshuka juu ya nafasi yoyote ya kazi uliyopo sasa, kama vile kiweko cha Quake. Igeuze kwa `Super + Grave` au `Super + S`, na uweke dirisha hapo kwa kutumia `Super + Shift + Grave` au `Super + Alt + S`.

Inafanya kazi vizuri hasa kwa terminal inayoendesha wakala, au kwa vidhibiti unavyotaka kuingiliana navyo haraka bila kuondoka kwenye nafasi ya sasa ya kazi. Ili kusogeza dirisha kutoka kwenye scratchpad, litume moja kwa moja kwenye nafasi nyingine ya kazi kwa kitu kama `Super + Shift + 1`.

Wakati scratchpad ina dirisha moja, hushuka kama paneli iliyo katikati badala ya kuenea skrini. Weka programu ya pili juu yake na inarudi kwenye upana kamili, ili hizo mbili ziwe na nafasi ya kukaa kando kwa kando.

### Inachukua muda kuzoea!

Inachukua muda kidogo kuzoea kusogeza eneo-kazi lako kama hivi, lakini mara tu unapofanya, itakuwa vigumu kurudi kwenye uzoefu wa kitamaduni wa eneo-kazi linaloongozwa na kipanya!
