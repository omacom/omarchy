# Leiðsögn

Allt í Omarchy gerist í gegnum lyklaborðið — _ALLT!_ Þegar kerfið ræsist fyrst geturðu bókstaflega ekki gert neitt með músinni einni. En þú getur ýtt á `Super + Space` til að birta Omarchy-valmyndina og þaðan geturðu gert næstum allt.

En Omarchy-valmyndin er ekki einu sinni ætluð sem aðalleiðin til að stjórna kerfinu mestan tímann. Við getum orðið hraðari en svo! Öll mikilvægustu forritin eru bundin beint við einstaka flýtilykla. Þú ræsir útstöðina með `Super + Return` og vafra með `Super + Shift + Return`. Prófaðu að gera annað á eftir hinu og þú sérð töfra Hyprland-flísalagnsins í verki:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Þú getur síðan ýtt á `Super + J` til að stafla þeim ofan á hvorn annan í stað þess að hafa þá hlið við hlið:

 ![navigation-stacked](images/navigation-stacked.webp)

Ýttu aftur á `Super + J` til að færa þá aftur í stöðuna hlið við hlið. Prófaðu síðan `Super + Shift + Arrow Right` á meðan þú ert í vafranum til að skipta á gluggunum.

Prófaðu nú `Super + Shift + T` til að ræsa Activity monitor. Hann birtist sem fljótandi gluggi, með titilstiku til að draga hann til og hnöppum til að lágmarka, hámarka og loka honum. Sérhver fljótandi gluggi fær slíka, hvar sem hann er. Þú getur flísalagt hann með `Super + T` (og ýtt aftur á það til að gera hann fljótandi aftur). Ýttu nú á `Super + Shift + F` til að opna skráastjórann. Þú verður með snyrtilega fjórskipta uppsetningu:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Þú færir þig á milli gluggans sem þú vilt að sé virkur með `Super + Arrow`. Það skiptir um fókus og færir bendilinn í miðju nýja forritsins. Við jaðar skjás heldur það áfram yfir á skjáinn þeim megin.

Ef þú ýtir á `Super + Shift + 2` færirðu forritið sem nú er í fókus yfir á annað vinnusvæðið. `Super + Shift + 1` færir það til baka. (Og `Super + Shift + Alt + 2` færir forritið sem nú er í fókus yfir á annað vinnusvæðið án þess að skipta yfir á það).

Þegar þú ert með fleiri en einn skjá hefur sérhver skjár vinnusvæði 1 til 10 fyrir sig. `Super + 2` fer á annað vinnusvæði skjásins sem þú ert á og efsta stika hvers skjás sýnir vinnusvæði hans og það sem hann sýnir. `Super + Tab` fer í hring í gegnum vinnusvæðin á skjánum sem þú ert á. `Super + Shift + Ctrl + Arrows` færir gluggann sem þú ert á yfir á skjáinn í þá átt, á vinnusvæðið sem hann sýnir, og `Super + Shift + Alt + Arrows` færir vinnusvæðið sem þú ert á yfir á skjáinn í þá átt, þar sem það fær sama númer ef það er laust. Skjár heldur vinnusvæðum sínum þegar þú tekur hann úr sambandi: þau sameinast vinnusvæðum annars skjás, númeruð á eftir þeim sem sá skjár hefur þegar, og fara aftur undir gömlu númerin sín þegar skjárinn kemur til baka.

Ef þú heldur niðri `Super` og notar músina til að smella á glugga geturðu endurraðað því hvar hann situr. Ef þú heldur niðri `Super` og notar hægri hnappinn á músinni geturðu breytt stærð gluggans að vild.

Þú lokar glugga með `Super + W` eða `Super + Q` (og lokar öllum gluggum með `Ctrl + Alt + Delete`).

Þú getur líka farið í fullan skjá með `Super + F` eða bara í fulla breidd (og haldið efstu stikunni) með `Super + Alt + F` eða í fullan skjá inni í glugga með `Super + Ctrl + F` (gott fyrir YouTube!).

### Dwindle á móti skrunskipulagi

Sjálfgefið skipulag Omarchy kallast dwindle. Það heldur öllum gluggunum sem þú opnar á einu vinnusvæði sýnilegum á öllum tímum, jafnvel þótt það þurfi að minnka þá.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

En þú getur líka valið að breyta vinnusvæði í skrunskipulagið þar sem gluggar raðast hlið við hlið, út fyrir sýnilegan jaðar skjásins. Þú breytir stöku vinnusvæði í þetta skipulag með `Super + L`.

Að ýta aftur á `Super + L` gerir vinnusvæðið fljótandi, þar sem gluggar skarast frjálst og þú setur þá sjálfur niður, og þriðji ýtingur færir það aftur í dwindle. `Super + Alt + L` fer í gegnum þau í hina áttina. Gluggi sem flýtur hvort sem er — sá sem þú skaust út með `Super + T`, eða forrit sem opnast alltaf fljótandi — heldur áfram að fljóta þegar vinnusvæðið fer aftur í flísalagningu. Efsta stikan merkir vinnusvæðið sem þú ert á með skipulagi þess: ferning fyrir dwindle, hring fyrir skrun og þríhyrning fyrir fljótandi. Að smella á það merki fer líka í hring í gegnum skipulögin, og það gerir skjáalykillinn á fartölvum sem hafa slíkan líka.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valið gildir fyrir hvert vinnusvæði og það helst. Svo þú getur haldið vinnusvæði 1 á dwindle til að vafra og vinnusvæði 2 á skrun fyrir kóða, og þau munu koma þannig til baka eftir endurræsingu.

Ef þú vilt nota skrunskipulagið sem sjálfgefið skipulag geturðu stillt það í `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Fljótandi vinnusvæði

Fljótandi vinnusvæði virkar eins og hefðbundið skjáborð: gluggar skarast og þú færir þá og breytir stærð þeirra sjálfur. Sérhver gluggi fær titilstiku í litum þemans þíns, með hnöppum til að lágmarka, hámarka og loka. `Super + M` lágmarkar líka gluggann sem er í fókus. Lágmarkaður gluggi bíður í bryggjunni; smelltu á forrit hans til að sækja hann aftur. Smelltu á glugga til að færa hann fram. Breyttu stærð hans frá hvaða jaðri eða horni sem er. Tvísmelltu á titilstiku til að hámarka gluggann á meðan efsta stikan helst sýnileg, og aftur til að fá gömlu stærð hans til baka. Chrome og aðrir vafrar byggðir á Chromium, Disks og Document Viewer sleppa titilstikunni og nota sinn eigin haus í staðinn; `Super + Alt + F` hámarkar þá og `Super + M` lágmarkar þá.

Sérhvert vinnusvæði hefur bryggju, með föstum forritum þínum, öllu sem er í gangi og rist af hverju forriti á bak við forritahnappinn, sem `Super + Alt + Space` og _Forrit_ í Omarchy-valmyndinni opna líka. Hægrismelltu á forrit á ristinni, eða ýttu á `Delete`, til að fjarlægja það. Smelltu á forrit til að opna það, eða til að færa glugga þess fram; smelltu aftur til að fara í hring í gegnum glugga þess. Files sækir aðeins aftur glugga frá vinnusvæðinu sem þú ert á og opnar annars nýjan, og Terminal og Agent ræsa alltaf annan til viðbótar, þótt lágmarkaður gluggi komi fyrst til baka. Miðsmellur opnar nýjan glugga. Dragðu tákn eftir bryggjunni til að færa það; að draga forrit í gangi inn á milli hinna heldur því þar. Hægrismelltu til að halda forriti í bryggjunni, taka það út eða hætta í því. Bryggjan helst úti á meðan vinnusvæði er tómt, og þegar vinnusvæðið hefur glugga felur hún sig þar til bendillinn nær að jaðri hennar. Gluggi í fullum skjá felur hana alveg. Dragðu forritahnappinn í átt að öðrum jaðri skjásins til að færa bryggjuna þangað. Hægrismelltu á hann fyrir _Staðsetningu_, til að velja jaðar, _Skipulag_, til að stilla sjálfgefna skipulagið eins og _Útlit > Skipulag vinnusvæðis_ gerir, og _Sýnileika_, til að halda bryggjunni alltaf á, láta fyrsta forritið fela hana eða halda henni alltaf falinni. `omarchy dock visibility always` stillir það frá útstöð. Staðsetningin er líka undir _Útlit > Bryggja > Staðsetning bryggju_, og `omarchy dock position left` stillir hana frá útstöð. Forrit sem þú heldur í bryggjunni eru dauf á meðan þau eru ekki í gangi. Til að takmarka bryggjuna við fljótandi vinnusvæði skaltu nota _Útlit > Bryggja > Bryggja aðeins á fljótandi_ eða `omarchy dock tiling off`.

Ný vinnusvæði, og öll sem þú hefur ekki gefið eigið skipulag með `Super + L`, nota sjálfgefna skipulagið. Að breyta sjálfgefna skipulaginu endurstillir hvert vinnusvæði án glugga yfir á það, á meðan vinnusvæði með glugga á heldur skipulaginu sem það hefur. Gluggi sem lágmarkaður er í bryggjuna telst enn sem gluggi á vinnusvæðinu sem hann fór frá. Veldu það undir _Útlit > Skipulag vinnusvæðis_: Flísalagning, Skrun eða Fljótandi. `omarchy hyprland workspace layout default scrolling` stillir það frá útstöð.

### Að hópa glugga

Hægt er að hópa glugga með `Super + G`. Þegar þú ert kominn í hóp mun sérhver gluggi sem þú ræsir á meðan það er virkt tilheyra hópnum. Þú getur fært þig á milli þessara hópuðu glugga með `Super + Ctrl + Arrow Left/Right` eða `Super + Alt + 1/2/3/4` til að fara beint að hópuðum gluggum í röð.

Þú getur fært glugga út úr hópuninni með `Super + Alt + G` eða tekið allan hópinn í sundur með því að ýta aftur á `Super + G`. Að lokum geturðu fært glugga utan hópsins inn í hann með `Super + Alt + Arrows`.

### Að skjóta út gluggum

Þú getur skotið glugga út úr úthlutun vinnusvæðis hans með `Super + O`. Það festir hann sem fljótandi glugga sem fylgir þér á hvaða vinnusvæði sem þú ferð á. Frábært fyrir myndbandsspilar og þess háttar.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Kladdavinnusvæði

Það er sérstakt kladdavinnusvæði í fullri stærð sem leggst yfir hvaða vinnusvæði sem þú ert á. Þú opnar það sem er á því með `Super + S`, og þú setur glugga þangað með `Super + Alt + S`.

Það hentar vel fyrir stjórntæki eða útstöð sem þú vilt nota fljótt án þess að fara af núverandi vinnusvæði.

### Quake-stjórnborð

Að lokum er Quake-stjórnborð í hálfri hæð sem fellur niður yfir hvaða vinnusvæði sem þú ert á. Kveiktu og slökktu á því með `Super + the key above Tab` (grave á bandarískum lyklaborðum), og settu glugga þangað með `Super + Shift + the key above Tab`.

Í fyrsta skipti sem það opnast ræsir það sjálfgefna agentinn þinn, eða biður þig að velja einn ef þú hefur ekki valið einn enn. Á meðan stjórnborðið heldur einum glugga fellur það niður sem miðjusett spjald í stað þess að spanna skjáinn. Settu annað forrit á það og það fer aftur í fulla breidd, svo þau tvö hafi rými til að sitja hlið við hlið.

Til að færa glugga af annaðhvort kladdavinnusvæðinu eða stjórnborðinu skaltu senda hann beint á annað vinnusvæði með einhverju eins og `Super + Shift + 1`.

### Þetta tekur tíma að venjast!

Það tekur smástund að venjast því að fletta skjáborðinu þínu svona, en þegar þú gerir það verður erfitt að fara aftur í hefðbundna, músdrifna skjáborðsupplifun!
