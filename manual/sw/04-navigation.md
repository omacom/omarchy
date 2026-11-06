# Urambazaji

Kila kitu katika Omarchy hufanyika kupitia kibodi — _KILA KITU!_ Mfumo unapoanza kwa mara ya kwanza, kihalisi huwezi kufanya chochote kwa kipanya pekee. Lakini unaweza kubonyeza `Super + Space` ili kuonyesha Omarchy Menu na kuanzia hapa unaweza kufanya karibu kila kitu.

Lakini menyu ya Omarchy hata haikukusudiwa kuwa njia kuu ya kuendesha mfumo kwa muda mwingi. Tunaweza kuwa wepesi zaidi kuliko hivyo! Programu zote muhimu zaidi zimeunganishwa moja kwa moja na vitufe vya mkato vya pekee. Unaanzisha terminal kwa `Super + Return` na kivinjari kwa `Super + Shift + Return`. Jaribu kufanya moja baada ya nyingine, na utaona uchawi wa upigaji vigae wa Hyprland ukifanya kazi:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Kisha unaweza kubonyeza `Super + J` ili kuviweka juu ya kila kingine badala ya ubavu kwa ubavu:

 ![navigation-stacked](images/navigation-stacked.webp)

Bonyeza `Super + J` tena ili kuvirudisha katika nafasi zake za ubavu kwa ubavu. Kisha jaribu `Super + Shift + Arrow Right` ukiwa katika kivinjari ili kubadilishana madirisha.

Sasa jaribu `Super + Shift + T` ili kuanzisha kifuatiliaji cha Activity. Hicho kitaonekana kama dirisha linaloelea. Unaweza kulipanga kwa vigae kwa kutumia `Super + T` (na bonyeza hiyo tena ili kulifanya lielee tena). Sasa bonyeza `Super + Shift + F` ili kufungua kidhibiti cha faili. Utakuwa na mpangilio nadhifu wa njia nne:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Unasogea kati ya dirisha unalotaka liwe linalofanya kazi kwa `Super + Arrow`. Hii itabadilisha lengo na kuhamisha kishale hadi katikati ya programu mpya. Katika ukingo wa skrini, huendelea hadi kwenye monita iliyo upande huo.

Ukibonyeza `Super + Shift + 2`, utahamisha programu iliyolengwa sasa hadi kwenye eneo la pili la kazi. `Super + Shift + 1` huirudisha. (Na `Super + Shift + Alt + 2` itahamisha programu iliyolengwa sasa hadi kwenye eneo la pili la kazi bila kubadilisha kwenda kwake).

Ukiwa na monita zaidi ya moja, kila monita ina maeneo yake ya kazi 1 hadi 10. `Super + 2` huenda kwenye eneo la pili la kazi la monita uliyopo, na upau wa juu wa kila monita huonyesha maeneo yake ya kazi na lile inalolionyesha. `Super + Tab` huzunguka kupitia maeneo ya kazi kwenye monita uliyopo. `Super + Shift + Ctrl + Arrows` huhamisha dirisha ulilopo hadi kwenye monita iliyo katika mwelekeo huo, kwenye eneo la kazi inalolionyesha, na `Super + Shift + Alt + Arrows` huhamisha eneo la kazi ulilopo hadi kwenye monita iliyo katika mwelekeo huo, ambapo huchukua nambari ile ile ikiwa ni wazi. Monita huhifadhi maeneo yake ya kazi unapoichomoa: huungana na ya skrini nyingine, yakipewa nambari baada ya yale ambayo tayari inayo, na hurudi chini ya nambari zake za zamani monita inapokurudia.

Ukishikilia `Super` na kutumia kipanya kubofya dirisha, utaweza kupanga upya mahali linapokaa. Ukishikilia `Super` na kutumia kitufe cha kulia cha kipanya, unaweza kubadilisha ukubwa wa dirisha kwa uhuru.

Unafunga dirisha kwa `Super + W` au `Super + Q` (na kufunga madirisha yote kwa `Ctrl + Alt + Delete`).

Unaweza pia kwenda kwenye skrini nzima kwa `Super + F` au hata upana kamili tu (huku ukiacha upau wa juu) kwa `Super + Alt + F` au skrini nzima ndani ya dirisha kwa `Super + Ctrl + F` (nzuri kwa YouTube!).

### Dwindle dhidi ya mpangilio wa scrolling

Mpangilio chaguo-msingi wa Omarchy unaitwa dwindle. Huweka madirisha yote unayofungua kwenye eneo moja la kazi yaonekane wakati wote, hata ikiwa inabidi kuyapunguza ukubwa.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Lakini unaweza pia kuchagua kubadilisha eneo la kazi kuwa mpangilio wa scrolling ambapo madirisha yamepangwa ubavu kwa ubavu, kupita ukingo unaoonekana wa onyesho. Unabadilisha eneo moja la kazi kuwa mpangilio huu kupitia `Super + L`.

Kubonyeza `Super + L` tena hubadilisha eneo la kazi kuwa linaloelea, ambapo madirisha huingiliana kwa uhuru na unayaweka mwenyewe, na kubonyeza kwa mara ya tatu hulirudisha kwenye dwindle. `Super + Alt + L` hupitia hayo kwa mwelekeo wa kinyume. Dirisha ambalo huelea vyovyote vile — lile ulilotoa nje kwa `Super + T`, au programu ambayo daima hufunguka ikielea — huendelea kuelea eneo la kazi linaporudi kwenye upigaji vigae. Upau wa juu huweka alama kwenye eneo la kazi ulilopo kwa mpangilio wake: mraba kwa dwindle, duara kwa scrolling, na pembe tatu kwa kuelea. Kubofya alama hiyo pia huzungusha mpangilio.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Chaguo ni kwa kila eneo la kazi, na hudumu. Kwa hivyo unaweza kuweka eneo la kazi 1 kwenye dwindle kwa kuvinjari na eneo la kazi 2 kwenye scrolling kwa msimbo, na vitarejea hivyo baada ya kuwasha upya.

Ukitaka kutumia mpangilio wa scrolling kama chaguo-msingi, unaweza kuweka hiyo katika `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Maeneo ya kazi yanayoelea

Eneo la kazi linaloelea hufanya kazi kama eneo-kazi la kitamaduni: madirisha huingiliana, na unayahamisha na kuyapima ukubwa mwenyewe. Kila dirisha hupata upau wa kichwa wenye rangi za mandhari yako, wenye vitufe vya kupunguza, kukuza, na kufunga. `Super + M` pia hupunguza dirisha lililolengwa. Dirisha lililopunguzwa husubiri kwenye dock; bofya programu yake ili kulirudisha. Bofya dirisha ili kulileta mbele. Libadilishe ukubwa kutoka kwenye ukingo au pembe yoyote. Bofya mara mbili upau wa kichwa ili kukuza dirisha huku ukiacha upau wa juu uonekane, na tena ili kupata ukubwa wake wa zamani.

Eneo la kazi linaloelea pia huonyesha dock, yenye programu zako zilizobandikwa, kila kitu kinachoendeshwa, na gridi ya kila programu nyuma ya kitufe cha programu, ambayo `Super + Alt + Space` na _Programu_ katika menyu ya Omarchy pia huifungua. Bofya kulia programu kwenye gridi, au bonyeza `Delete`, ili kuiondoa. Bofya programu ili kuifungua, au kuleta dirisha lake mbele; bofya tena ili kuzunguka kupitia madirisha yake. Kubofya kwa kitufe cha kati hufungua dirisha jipya. Buruta ikoni kando ya dock ili kuihamisha; kuburuta programu inayoendeshwa kati ya nyingine huibakisha hapo. Bofya kulia ili kuweka programu kwenye dock, kuitoa, au kuifunga. Dock huondoka njiani mwa dirisha la skrini nzima. Bofya kulia kitufe cha programu ili kuhamisha dock hadi kwenye ukingo mwingine au kuifanya ifiche hadi kishale kifike kwenye ukingo wake. Nafasi pia iko chini ya _Mwonekano > Dock > Nafasi ya Dock_, na `omarchy dock position left` na `omarchy dock autohide on` huweka zote mbili kutoka kwenye terminal. Programu unazoweka kwenye dock hufifia zikiwa haziendeshwi.

Maeneo mapya ya kazi, na yoyote ambayo hujayapa mpangilio wake yenyewe kwa `Super + L`, hutumia mpangilio chaguo-msingi. Kubadilisha chaguo-msingi huweka upya kila eneo la kazi lisilo na madirisha kwake, wakati lile lenye madirisha hubakisha mpangilio lililo nao. Dirisha lililopunguzwa hadi kwenye dock bado huhesabika kama dirisha kwenye eneo la kazi lililoliacha. Lichague chini ya _Mwonekano > Mpangilio wa Eneo la Kazi_: Upigaji Vigae, Scrolling, au Kuelea. `omarchy-hyprland-workspace-layout-default scrolling` huliweka kutoka kwenye terminal.

### Kupanga madirisha katika vikundi

Madirisha yanaweza kupangwa katika vikundi kwa kutumia `Super + G`. Mara tu unapokuwa katika kikundi, kila dirisha unaloanzisha wakati huo unafanya kazi litakuwa la kikundi. Unaweza kusogea kati ya madirisha haya yaliyopangwa katika vikundi kwa kutumia `Super + Ctrl + Arrow Left/Right` au `Super + Alt + 1/2/3/4` ili kwenda moja kwa moja kwenye madirisha yaliyopangwa katika vikundi kwa mpangilio.

Unaweza kuhamisha dirisha kutoka kwenye kikundi kwa `Super + Alt + G` au kuvunja kikundi kizima kwa kubonyeza `Super + G` tena. Mwishowe, unaweza kuhamisha madirisha yaliyo nje ya kikundi kuingia ndani yake kwa `Super + Alt + Arrows`.

### Kutoa madirisha nje

Unaweza kutoa dirisha nje ya mgao wake wa eneo la kazi kwa `Super + O`. Hiyo italibandika kama dirisha linaloelea ambalo hukufuata kwenye eneo lolote la kazi unaloenda. Nzuri kwa vicheza video na vingine kama hivyo.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Eneo la kazi la scratchpad

Kuna eneo maalum la kazi la scratchpad lenye ukubwa kamili ambalo hufunika juu ya eneo lolote la kazi ulilopo sasa. Unafikia kilicho juu yake kwa kutumia `Super + S`, na unaweka madirisha hapo kwa kutumia `Super + Alt + S`.

Hufanya kazi vizuri kwa vidhibiti au terminal unayotaka kuingiliana nayo haraka bila kuacha eneo la sasa la kazi.

### Konsoli ya Quake

Mwishowe, kuna konsoli ya Quake yenye nusu urefu ambayo hushuka juu ya eneo lolote la kazi ulilopo sasa. Ibadilishe kwa `Super + Grave`, na uweke dirisha hapo kwa kutumia `Super + Shift + Grave`.

Hufunguka ikiwa na agent wako chaguo-msingi tayari kwenda. Wakati konsoli ina dirisha moja, hushuka kama paneli iliyowekwa katikati badala ya kuenea skrini nzima. Weka programu ya pili juu yake na hurudi kwenye upana kamili, ili hizi mbili ziwe na nafasi ya kukaa ubavu kwa ubavu.

Ili kuhamisha dirisha kutoka kwenye scratchpad au konsoli, lipeleke moja kwa moja kwenye eneo lingine la kazi kwa kitu kama `Super + Shift + 1`.

### Inahitaji kuzoea kidogo!

Inachukua muda kidogo kuzoea kusogea kwenye eneo-kazi lako hivi, lakini mara tu unapozoea, itakuwa ngumu kurudi kwenye uzoefu wa kitamaduni wa eneo-kazi unaoendeshwa na kipanya!
