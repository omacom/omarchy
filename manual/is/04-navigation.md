# Flakk

Allt í Omarchy gerist með lyklaborðinu — _ALLT!_ Þegar kerfið ræsist í fyrsta sinn geturðu bókstaflega ekki gert neitt með músinni einni saman. En þú getur ýtt á `Super + Space` til að opna Omarchy-valmyndina og þaðan geturðu gert nánast allt.

En Omarchy-valmyndin er ekki einu sinni ætluð sem helsta leiðin til að stjórna kerfinu mestan tímann. Við getum verið hraðari en það! Öll mikilvægustu forritin eru bundin beint við einstaka flýtilykla. Þú ræsir terminal með `Super + Return` og vafra með `Super + Shift + Return`. Prófaðu annað á eftir hinu og þú sérð töfra flísalags Hyprland í verki:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Þú getur síðan ýtt á `Super + J` til að stafla þeim hvorn ofan á annan í stað þess að hafa þá hlið við hlið:

 ![navigation-stacked](images/navigation-stacked.webp)

Ýttu aftur á `Super + J` til að færa þá aftur í stöðuna hlið við hlið. Prófaðu síðan `Super + Shift + Arrow Right` á meðan þú ert í vafranum til að víxla gluggunum.

Prófaðu nú `Super + Shift + T` til að ræsa Activity monitor. Hann birtist sem fljótandi gluggi. Þú getur flísað hann með `Super + T` (og ýtt aftur á það til að gera hann aftur fljótandi). Ýttu nú á `Super + Shift + F` til að opna skráarstjórann. Þú verður með snyrtilega uppsetningu í fjórar áttir:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Þú ferð á milli glugganna sem þú vilt hafa virka með `Super + Arrow`. Það skiptir um fókus og færir bendilinn í miðju nýja forritsins. Við jaðar skjás heldur það áfram yfir á skjáinn þeim megin.

Ef þú ýtir á `Super + Shift + 2` færirðu forritið sem nú er í fókus yfir á annað vinnusvæðið. `Super + Shift + 1` færir það til baka. (Og `Super + Shift + Alt + 2` færir forritið sem nú er í fókus yfir á annað vinnusvæðið án þess að skipta yfir á það).

Með fleiri en einum skjá hefur hver skjár sín eigin vinnusvæði 1 til 10. `Super + 2` fer á annað vinnusvæði skjásins sem þú ert á og efsta stika hvers skjás sýnir vinnusvæði hans sjálfs og það sem hann sýnir. `Super + Tab` fer í gegnum vinnusvæðin á skjánum sem þú ert á. `Super + Shift + Ctrl + Arrows` færir gluggann sem þú ert á yfir á skjáinn í þá átt, á vinnusvæðið sem hann sýnir, og `Super + Shift + Alt + Arrows` færir vinnusvæðið sem þú ert á yfir á skjáinn í þá átt, þar sem það fær sama númer ef það er laust. Skjár heldur vinnusvæðum sínum þegar þú tekur hann úr sambandi: þau sameinast vinnusvæðum annars skjás, númeruð á eftir þeim sem hann hefur fyrir, og fara aftur undir gömlu númerin sín þegar skjárinn kemur til baka.

Ef þú heldur inni `Super` og notar músina til að smella á glugga geturðu endurraðað því hvar hann situr. Ef þú heldur inni `Super` og notar hægri hnappinn á músinni geturðu breytt stærð gluggans að vild.

Þú lokar glugga með `Super + W` eða `Super + Q` (og lokar öllum gluggum með `Ctrl + Alt + Delete`).

Þú getur líka farið á fullan skjá með `Super + F` eða jafnvel bara í fulla breidd (og haldið efstu stikunni) með `Super + Alt + F` eða á fullan skjá innan glugga með `Super + Ctrl + F` (gott fyrir YouTube!).

### Dwindle á móti skrunskipulagi

Sjálfgefið skipulag Omarchy heitir dwindle. Það heldur öllum gluggunum sem þú opnar á einu vinnusvæði sýnilegum öllum stundum, jafnvel þótt það þurfi að minnka þá.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

En þú getur líka valið að breyta vinnusvæði í skrunskipulagið þar sem gluggar raðast hlið við hlið, út fyrir sýnilegan jaðar skjásins. Þú breytir einu vinnusvæði í þetta skipulag með `Super + L`.

Að ýta aftur á `Super + L` gerir vinnusvæðið fljótandi, þar sem gluggar skarast frjálst og þú staðsetur þá sjálfur, og þriðji smellurinn færir það aftur í dwindle. `Super + Alt + L` fer í gegnum þau í hina áttina. Gluggi sem flýtur hvort sem er — einn sem þú sprettir út með `Super + T`, eða forrit sem opnast alltaf fljótandi — heldur áfram að fljóta þegar vinnusvæðið fer aftur í flísalag. Efsta stikan merkir vinnusvæðið sem þú ert á með skipulagi þess: ferning fyrir dwindle, hring fyrir skrun og þríhyrning fyrir fljótandi. Að smella á það merki fer líka í gegnum skipulögin, og það gerir skjáhnappurinn líka á fartölvum sem hafa slíkan hnapp.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valið gildir fyrir hvert vinnusvæði fyrir sig og það helst. Þannig geturðu haft vinnusvæði 1 á dwindle fyrir vafur og vinnusvæði 2 á skrun fyrir kóða, og þau koma þannig til baka eftir endurræsingu.

Ef þú vilt nota skrunskipulagið sem sjálfgefið skipulag geturðu stillt það í `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Fljótandi vinnusvæði

Fljótandi vinnusvæði virkar eins og hefðbundið skjáborð: gluggar skarast og þú færir þá og breytir stærð þeirra sjálfur. Hver gluggi fær titilstiku í litum þemans þíns, með hnöppum til að lágmarka, hámarka og loka. `Super + M` lágmarkar líka gluggann sem er í fókus. Lágmarkaður gluggi bíður í bryggjunni; smelltu á forritið hans til að fá hann til baka. Smelltu á glugga til að koma honum fram. Breyttu stærð hans frá hvaða jaðri eða horni sem er. Tvísmelltu á titilstiku til að hámarka gluggann en halda efstu stikunni sýnilegri, og aftur til að fá gömlu stærðina hans til baka. Chrome og aðrir vafrar byggðir á Chromium, Disks og Document Viewer sleppa titilstikunni og nota sinn eigin haus í staðinn; `Super + Alt + F` hámarkar þá og `Super + M` lágmarkar þá.

Fljótandi vinnusvæði sýnir líka bryggju, með festum forritunum þínum, öllu sem er í gangi og rist af öllum forritum á bak við forritahnappinn, sem `Super + Alt + Space` og _Forrit_ í Omarchy-valmyndinni opna líka. Hægrismelltu á forrit á ristinni, eða ýttu á `Delete`, til að fjarlægja það. Smelltu á forrit til að opna það, eða til að koma glugganum þess fram; smelltu aftur til að fara í gegnum glugga þess. Files fær aðeins til baka glugga frá vinnusvæðinu sem þú ert á og opnar annars nýjan, og Terminal og Agent ræsa alltaf annan til viðbótar, þótt lágmarkaður gluggi komi fyrst til baka. Að smella með miðhnappi opnar nýjan glugga. Dragðu tákn eftir bryggjunni til að færa það; að draga forrit í gangi inn á milli hinna heldur því þar. Hægrismelltu til að halda forriti í bryggjunni, taka það þaðan út eða hætta í því. Bryggjan víkur fyrir glugga á fullum skjá. Hægrismelltu á forritahnappinn til að flytja bryggjuna á annan jaðar eða láta hana felast þar til bendillinn nær á jaðar hennar. Staðsetningin er líka undir _Útlit > Bryggja > Staðsetning bryggju_, og `omarchy dock position left` og `omarchy dock autohide on` stilla hvort tveggja úr terminal. Forrit sem þú heldur í bryggjunni eru dauf á meðan þau eru ekki í gangi.

Ný vinnusvæði, og öll sem þú hefur ekki gefið sitt eigið skipulag með `Super + L`, nota sjálfgefna skipulagið. Að breyta sjálfgefna skipulaginu endurstillir hvert vinnusvæði án glugga yfir á það, en vinnusvæði með glugga á heldur skipulaginu sem það hefur. Gluggi sem er lágmarkaður í bryggjuna telst enn vera gluggi á vinnusvæðinu sem hann fór frá. Veldu það undir _Útlit > Skipulag vinnusvæðis_: Flísalag, Skrun eða Fljótandi. `omarchy hyprland workspace layout default scrolling` stillir það úr terminal.

### Að flokka glugga saman

Hægt er að flokka glugga saman með `Super + G`. Þegar þú ert kominn í hóp mun hver gluggi sem þú ræsir á meðan það er virkt tilheyra hópnum. Þú getur farið á milli þessara flokkuðu glugga með `Super + Ctrl + Arrow Left/Right` eða `Super + Alt + 1/2/3/4` til að fara beint á flokkaða glugga í röð.

Þú getur fært glugga út úr flokkuninni með `Super + Alt + G` eða tekið allan hópinn í sundur með því að ýta aftur á `Super + G`. Að lokum geturðu fært glugga utan hópsins inn í hann með `Super + Alt + Arrows`.

### Að spretta gluggum út

Þú getur spretti glugga út úr úthlutun hans á vinnusvæði með `Super + O`. Það festir hann sem fljótandi glugga sem fylgir þér á hvaða vinnusvæði sem þú ferð á. Frábært fyrir myndbandsspilar og þess háttar.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-vinnusvæði

Það er sérstakt Scratchpad-vinnusvæði í fullri stærð sem leggst yfir hvaða vinnusvæði sem þú ert á. Þú nálgast það sem er á því með `Super + S`, og þú staðsetur glugga þar með `Super + Alt + S`.

Það hentar vel fyrir stjórntæki eða terminal sem þú vilt nota fljótt án þess að yfirgefa núverandi vinnusvæði.

### Quake-stjórnborð

Að lokum er Quake-stjórnborð í hálfri hæð sem fellur niður yfir hvaða vinnusvæði sem þú ert á. Kveiktu og slökktu á því með `Super + Grave`, og staðsettu glugga þar með `Super + Shift + Grave`.

Í fyrsta sinn sem það opnast ræsir það sjálfgefna agentinn þinn, eða biður þig að velja einn ef þú hefur ekki valið einn enn. Á meðan stjórnborðið geymir einn glugga fellur það niður sem miðjusett spjald í stað þess að teygja sig yfir skjáinn. Settu annað forrit á það og það fer aftur í fulla breidd, svo þau tvö hafi rými til að sitja hlið við hlið.

Til að færa glugga af annaðhvort Scratchpad-vinnusvæðinu eða stjórnborðinu skaltu senda hann beint á annað vinnusvæði með einhverju eins og `Super + Shift + 1`.

### Þetta krefst aðeins venju!

Það tekur smástund að venjast því að flakka um skjáborðið þitt svona, en þegar þú gerir það verður erfitt að fara aftur í hefðbundna upplifun á skjáborði sem er stjórnað með músinni!
